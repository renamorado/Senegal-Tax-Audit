###########
#RF - Function to run RF
###########
#comments:
  #Includes additional lines to generate two tables: 
    # - table_opt_full_and_desk.tex -> Table 9 in paper
    # - table_opt_desk_offices.tex -> Table G2 in annex of paper


# Function to process RF
run_rf <- function(df, target_variable = "y4",
                   weights = NULL, specifics){
  
  # Prepare the formula based on the target variable
  formula <- as.formula(paste(target_variable, "~ L1TVA_filed + L3RAS_IRPP_filed + L2IMP_filed +",
                              "L1TVAAN_filed + L3profitrate + L2TVA_filed + L1MAN_filed +",
                              "L3IMP_filed + L2TVAAN_filed + L1productivity + L3TVA_filed +",
                              "L2MAN_filed + L1EXP_filed + L3TVAAN_filed + L2productivity +",
                              "L1TAF_filed + L3MAN_filed + L2EXP_filed + L1turnover +",
                              "L3productivity + L2TAF_filed + L1IS_filed + L3EXP_filed +",
                              "L2turnover + firmage + L3TAF_filed + L2IS_filed + L1CGU_filed +",
                              "L3turnover + durationcar + L1RAS_IRPP_filed + L3IS_filed +",
                              "L2CGU_filed + L1profitrate + distance + L2RAS_IRPP_filed + L1IMP_filed +",
                              "L3CGU_filed + L2profitrate + bureau_detailed + algorithm + activity_group"))
  
  # Run randomForest with weights
  set.seed(10222024)
  rf <- randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(y4)),
    weights = weights,
    keep.inbag = TRUE
  )
  
  return(rf)
  
}

predict_rf <- function(rf, data, specifics){
  
  # Predict values
  predicted_values <- predict(rf, data)
  
  # Create column for predicted errors and estimated values
  data <- data %>% mutate(yhatrf = predicted_values)
  
  # Create column for predicted errors and estimated values
  df_quality <- data %>%
    filter(is.na(y4) == 0) %>%
    mutate(error = y4 - yhatrf,
           cdf = rank(y4, ties.method = "random") / max(rank(y4)))

  # Store results
  results_df <- data.frame(
    Mean_Squared_Error = mean((df_quality$error)^2)
  )
  
  write.csv(results_df, paste0(output_path, "msqe_",  specifics, "_quality.csv"))
  return(data)
  
}

# Re-optimize across different types
optimization <- function(df, type = 2) {
  
  # Calculate totals by inspector cluster year
  df <- df %>%
    mutate(y2controle = ifelse(y2 == 1 & controle == type, 1, 0)) %>% 
    group_by(inspectorclusteryear) %>%
    mutate(
      totalexecuted = sum(y2controle))
  
  # Unconstrained optimization - select top rows by yhatrf
  df <- df %>%
    group_by(inspectorclusteryear) %>%
    arrange(inspectorclusteryear, desc(yhatrf)) %>%
    mutate(
      optimized_all = row_number() <= first(totalexecuted),
      overlap_unit = ifelse(y2controle == 1 & optimized_all == 1, 1, 0)
    )
  
  return(df)
}

# Create tables with log means
table_logs <- function(df, specifics, type = 2) {
  # Transform back from log to levels
  df <- df %>%
    mutate(evasion_level_realized = exp(y4) - 1,
           evasion_level_predicted = exp(yhatrf) - 1)
  
  #Calculate the mean of yhatrf for each optimization category
  mean_values <- df %>%
    ungroup() %>%
    summarize(
      # Unconstrained optimizations
      optimized_all = log(mean(evasion_level_predicted[optimized_all == 1], na.rm = TRUE))
      
    ) %>%
    pivot_longer(
      cols = everything(), 
      names_to = "Optimization_Category", 
      values_to = "Mean_Evasion"
    ) 
  
  # Calculate the overall mean of y4
  overall_mean_y4 <- log(mean(df$evasion_level_realized[df$y2 == 1 & df$controle == type], na.rm = TRUE))
  
  # Calculate the mean of predictedevasion where y2 == 1
  mean_predictedevasion_y2_1 <- log(mean(df$evasion_level_predicted[df$y2 == 1 & df$controle == type], na.rm = TRUE))
  
  # Add the new metrics to the mean_values dataframe
  mean_values <- mean_values %>%
    bind_rows(
      data.frame(
        Optimization_Category = c("Overall y4", "Predictedevasion y2 == 1"),
        Mean_Evasion = c(overall_mean_y4, mean_predictedevasion_y2_1)
      )
    )
  
  ref <- mean_values$Mean_Evasion[mean_values$Optimization_Category == "Predictedevasion y2 == 1"]
  
  mean_values <- mean_values %>%
    mutate(dif = 100*(exp(Mean_Evasion - ref) - 1)) %>%
    add_row(Optimization_Category = "Overlaps",
            Mean_Evasion = sum(df$optimized_all) - sum(df$overlap_unit),
            dif = (sum(df$optimized_all) - sum(df$overlap_unit))/sum(df$optimized_all))
  
  return(mean_values)
  
}

##########
#Run model and create graphs
##########

# Open data
data_audits = read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

#Create List to save results to create table
results_list <- list()
panel_labels <- c("Desk Audits", "Full Audits", "Full Audits - Large", 
                  "Full Audits - Medium", "Full Audits - Liberal", 
                  "Full Audits - Small")
index <- 1  # To track the position in the list


for (i in c(1, 2)) {
  
  # Keep only audited units
  fullaudits = data_audits[data_audits$controle == i,]
  
  fullaudits <- fullaudits %>%
    filter(safeties != 1 & selection == 1)
  
  # First lets do the calssification problem
  set.seed(10222024)
  # Prepare the formula based on the target variable
  formula <- as.formula(paste("as.factor(evasion_dummy)", "~ L1TVA_filed + L3RAS_IRPP_filed + L2IMP_filed +",
                              "L1TVAAN_filed + L3profitrate + L2TVA_filed + L1MAN_filed +",
                              "L3IMP_filed + L2TVAAN_filed + L1productivity + L3TVA_filed +",
                              "L2MAN_filed + L1EXP_filed + L3TVAAN_filed + L2productivity +",
                              "L1TAF_filed + L3MAN_filed + L2EXP_filed + L1turnover +",
                              "L3productivity + L2TAF_filed + L1IS_filed + L3EXP_filed +",
                              "L2turnover + firmage + L3TAF_filed + L2IS_filed + L1CGU_filed +",
                              "L3turnover + durationcar + L1RAS_IRPP_filed + L3IS_filed +",
                              "L2CGU_filed + L1profitrate + distance + L2RAS_IRPP_filed + L1IMP_filed +",
                              "L3CGU_filed + L2profitrate + activity_group + bureau_detailed + algorithm"))
  
  
  # Create evasion dummy
  fullaudits <- fullaudits %>%
    mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))
  
  # Run randomForest with weights
  rf <- randomForest(
    formula = formula,
    data = fullaudits %>% filter(y2 == 1 & !is.na(y4)),
    weights = NULL,
    keep.inbag = TRUE
  )
  
  #Let get the importance information
  importance(rf) %>%
    as.data.frame() %>%
    rownames_to_column() %>%
    arrange(MeanDecreaseGini) %>%
    ggplot(aes(x = MeanDecreaseGini , y = reorder(rowname , MeanDecreaseGini))) +
    geom_point() +
    labs(title = "", x = "Importance", y = "") +
    theme_classic()
  ggsave(paste0(output_path, "importance_detection", i, "_plot.pdf"), width = 8, height = 6)
  
  # Predict values
  predicted_values <- predict(rf, fullaudits)
  
  # Create column for predicted zeros
  fullaudits <- fullaudits %>% mutate(evasion_dummy_predicted = predicted_values)
  
  # Lets estimate the RF only on non zeros
  fullaudits_evaders <- fullaudits %>%
    filter(y4 > 0)
  
  # Binary weights per inspectorclusteryear
  name <- paste0("Drop_predicted_zeros_log_evasion_weights_top_quartiles", "_controle_", i)
  
  w_quartiles <- fullaudits_evaders %>%
    filter(is.na(y4) == 0) %>%
    group_by(inspectorclusteryear) %>%
    mutate(quartile = ntile(y4, 4)) %>%
    ungroup() %>%
    select(quartile) %>%
    mutate(binary_weight = ifelse(quartile == 4, 10, 1))
  
  
  # Transform
  rf2 <- fullaudits_evaders %>% 
    run_rf(weights = w_quartiles$binary_weight,
           specifics = name)
  
  #Let get the importance information
  importance(rf2) %>%
    as.data.frame() %>%
    rownames_to_column() %>%
    arrange(IncNodePurity) %>%
    ggplot(aes(x = IncNodePurity , y = reorder(rowname , IncNodePurity ))) +
    geom_point() +
    labs(title = "", x = "Importance", y = "") +
    theme_classic()
  ggsave(paste0(output_path, name, "importance_evasion_plot.pdf"), width = 8, height = 6)
  
  # Predict values
  fullaudits_predicted <- predict_rf(rf2, fullaudits, specifics = name) 
  
  fullaudits_predicted <- fullaudits_predicted %>%
    mutate(evasion_dummy_predicted = evasion_dummy_predicted,
           yhatrf = ifelse(evasion_dummy_predicted == 0, 0, yhatrf))
  
  # Run optimization
  mean_values <- fullaudits_predicted %>%
    filter(selectionyear != 2020) %>%
    optimization(type = i) %>%
    table_logs(type = i)
  
  b <- data.frame(mean_values[2, 2], mean_values[3, 2], mean_values[1, 3], mean_values[4, 3]) %>%
    round(2)
  
  b$dif <- paste0(ifelse(b$dif >= 0, "+ ", "- "), b$dif, "%")
  b$dif.1 <- paste0(100*(1-b$dif.1), "%")
  
  #Save in list to create table later
  b$panel <- panel_labels[index]
  results_list[[index]] <- b
  index <- index + 1
  # Cria a tabela LaTeX com kableExtra
  latex_table <- kable(b, format = "latex", booktabs = FALSE, escape = FALSE) %>%
    kable_styling(latex_options = c("hold_position"))
  
  # Caminho para salvar o arquivo
  file_path <- paste0(output_path, name, "table_opt.tex")
  
  # Escreve diretamente no arquivo
  writeLines(latex_table, con = file_path)
  
  #For desk audits: disagregate the analysis  
  if (i == 2) {
    
    
    fullaudits_predicted <- fullaudits_predicted %>%
      mutate(tax_office_size = case_when(
        bureau_detailed %in% c("CGE BCS1", "CGE BCS2", "CGE BCS3", "CGE BCS4") ~ "Large",
        bureau_detailed %in% c("CME1", "CME2") ~ "Medium",
        bureau_detailed %in% c("CPR") ~ "Liberal",
        bureau_detailed %in% c("DP", "GD", "NGA", "PKG") ~ "Small"))
    
    for (j in c("Large", "Medium", "Liberal", "Small")) {
      
      name <- paste0("Drop_predicted_zeros_log_evasion_weights_top_quartiles", "_controle_", j)
      
      mean_values <- fullaudits_predicted %>%
        filter(selectionyear != 2020) %>%
        filter(tax_office_size == j) %>%
        optimization(type = 2) %>%
        table_logs(type = 2)
      
      b <- data.frame(mean_values[2, 2], mean_values[3, 2], mean_values[1, 3], mean_values[4, 2]) %>%
        round(2)
      
      b <- data.frame(mean_values[2, 2], mean_values[3, 2], mean_values[1, 3], mean_values[4, 3]) %>%
        round(2)
      
      b$dif <- paste0(ifelse(b$dif >= 0, "+ ", "- "), b$dif, "%")
      b$dif.1 <- paste0(100*(1-b$dif.1), "%")
      
      #Save in list for later
      b$panel <- panel_labels[index]
      results_list[[index]] <- b
      index <- index + 1
      
      # Cria a tabela LaTeX com kableExtra
      latex_table <- kable(b, format = "latex", booktabs = FALSE, escape = FALSE) %>%
        kable_styling(latex_options = c("hold_position"))
      
      # Caminho para salvar o arquivo
      file_path <- paste0(output_path, name, "_table_opt.tex")
      
      # Escreve diretamente no arquivo
      writeLines(latex_table, con = file_path)
      
    }
    
  }
  
}

#####
# Exporting Tables 
#####

full_table <- do.call(rbind, results_list) # creates a df with all results
colnames(full_table)[5] <- "Panel" # labeling panel column

full_table <- full_table %>%
  arrange(factor(Panel, levels = c("Full Audits", "Desk Audits")))
# Table 9. Optimization Gains [General] 
table1 <- full_table[1:2, 1:4] # Extracting only general results

rownames(table1) <- NULL  # let kable handle rows
colnames(table1) <- c("(1)", "(2)", "(3)", "(4)") #Add column numbers

# Export: .Tex table fragment with panels and headers
latex_tabular <- kbl(
  table1,
  format = "latex",
  booktabs = TRUE,
  escape = TRUE,
  align = "cccc"
) %>%
  add_header_above(c(
    "\\\\shortstack{Realized\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{Predicted\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{$\\\\Delta$ Revenue vs Predicted\\\\\\\\w/ RF Selection\\\\\\\\Among Program Cases}" = 1,
    "\\\\shortstack{Overlap Between\\\\\\\\Optimized and\\\\\\\\Realized Audit Program}" = 1
  ), escape = FALSE) %>%
  pack_rows("A: Full Audits", 1, 1, bold = TRUE) %>%
  pack_rows("B: Desk Audits", 2, 2, bold = TRUE)

writeLines(as.character(latex_tabular), "output/table_opt_full_and_desk.tex")

#Table G2. Optimization Gains [Disagregated for Desk Audits]

table2 <- full_table[3:6, 1:4] # Extract only disagregated results for desk audits
rownames(table2) <- NULL #let kable handle rows
colnames(table2) <- c("(1)", "(2)", "(3)", "(4)")

# Export: .Tex table fragment with panels and headers
latex_tabular <- kbl(
  table2,
  format = "latex",
  booktabs = TRUE,
  escape = TRUE,
  align = "cccc"
) %>%
  add_header_above(c(
    "\\\\shortstack{Realized\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{Predicted\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{$\\\\Delta$ Revenue vs Predicted\\\\\\\\w/ RF Selection\\\\\\\\Among Program Cases}" = 1,
    "\\\\shortstack{Overlap Between\\\\\\\\Optimized and\\\\\\\\Realized Audit Program}" = 1
  ), escape = FALSE)  %>%
  pack_rows("A: Large Taxpayer Office", 1, 1, bold = TRUE) %>%
  pack_rows("B: Medium Taxpayer Office", 2, 2, bold = TRUE) %>%
  pack_rows("C: Liberal Professions Office", 3, 3, bold = TRUE) %>%
  pack_rows("D: Small Taxpayer Office", 4, 4, bold = TRUE)

# 4) Export desk offices results
writeLines(as.character(latex_tabular),
           "output/table_opt_desk_offices.tex")
