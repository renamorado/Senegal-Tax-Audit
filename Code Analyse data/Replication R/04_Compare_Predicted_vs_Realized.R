###SENEGAL TAX AUDITS 

###########################
###R packages 
###########################
#pack <- c('plyr',  'dplyr', 'tidyr', 'haven', 'sf', 'tidyverse', 'collapse', 'foreign', 'DescTools','randomForest', 'kableExtra')
pack <- c('dplyr', 'tidyr', 'haven', 'sf', 'tidyverse', 'collapse', 'foreign', 'DescTools','randomForest', 'kableExtra')
#lapply(pack, install.packages, character.only = TRUE) 
lapply(pack, library, character.only = TRUE)
library('grid')
library(datasets)
library(caret)

###########
#RF - Function to run RF
###########

# Function to process RF
run_rf <- function(df, target_variable = "y4",
                   weights = NULL, specifics){
  
  set.seed(10222024)
  
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
  
  return(data)
}

# Re-optimize across different types
optimization <- function(df, type = 2) {
  
  # Generate executed variables
  df <- df %>% mutate(
    executedinsp = y2 * dgid,
    executedalg = y2 * algorithm
  )
  
  
  # Calculate totals by inspector cluster year
  df <- df %>%
    mutate(y2controle = ifelse(y2 == 1 & controle == type, 1, 0),
           executedinspcontrole = ifelse(executedinsp == 1 & controle == type, 1, 0),
           executedalgcontrole = ifelse(executedalg == 1 & controle == type, 1, 0))
  
  df <- df %>% 
    group_by(inspectorclusteryear) %>%
    mutate(
      totalexecuted = sum(y2controle),
      totalexecutedinsp = sum(executedinspcontrole),
      totalexecutedalg = sum(executedalgcontrole)
    )
  
  # Unconstrained optimization - select top rows by yhatrf
  df <- df %>%
    group_by(inspectorclusteryear) %>%
    arrange(inspectorclusteryear, desc(yhatrf)) %>%
    mutate(
      optimized_all = row_number() <= first(totalexecuted)
    )
  
  
  # Optimize based on size
  df <- df %>%
    group_by(inspectorclusteryear) %>%
    arrange(inspectorclusteryear, desc(L1turnover)) %>%
    mutate(
      n = row_number(),
      optimized_size = 0
    ) %>%
    mutate(
      optimized_size = if_else(n <= totalexecuted, 1, optimized_size)
    ) %>%
    select(-n)
  
  return(df)
}

quality_graphs <- function(data, specifics) {
  
  data %>%
    filter(evasion_dummy == 1 & evasion_dummy_predicted == 1) %>%
  ggplot(aes(x = y4, y = yhatrf)) +
    geom_point(color = 'blue', alpha = 0.6) +  # Scatter plot+
    geom_abline(intercept = 0, slope = 1, color = 'red', linetype = "dotted", linewidth = 0.2) + 
    labs(
      x = ' Realized log(Evasion)',  # Rótulo do eixo X
      y = 'Predicted log(Evasion)',  # Rótulo do eixo Y
      title = ''  # Título do gráfico
    ) +
    ylim(0,25) +
    theme_minimal() 
  ggsave(paste0(output_path, "Fig_predicted_vs_realized_", specifics, ".pdf"), width = 8, height = 6)
  
}


##########
#Run model and create graphs
##########

# Open data
data_audits = read_dta(paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

for (i in c(1, 2)) {
  
  # Keep only audited units
  fullaudits = data_audits[data_audits$controle == i,]
  
  fullaudits <- fullaudits %>%
    filter(safeties != 1 & selection == 1)
  
  # Prediction of log evasion
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
                              "L3CGU_filed + L2profitrate + bureau_detailed + algorithm"))
  
  
  # Create evasion dummy
  fullaudits <- fullaudits %>%
    mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))
  
  #Data for evadors
  fullaudits_evaders <- fullaudits %>%
    filter(y4 > 0)
  
  # Run randomForest with weights
  rf <- randomForest(
    formula = formula,
    data = fullaudits %>% filter(y2 == 1 & !is.na(y4)),
    weights = NULL,
    keep.inbag = TRUE
  )
  
  # Predict values
  predicted_values <- predict(rf, fullaudits)
  
  # Create column for predicted zeros
  fullaudits <- fullaudits %>% mutate(evasion_dummy_predicted = predicted_values)
  
  # Keep only predicted to be no zero
  fullaudits_non_evasion_predic <- fullaudits %>%
    filter(evasion_dummy_predicted == 0) %>%
    mutate(yhatrf = 0,
           error = ifelse(evasion_dummy_predicted == evasion_dummy, 0, y4))
  
  # 5a) Binary weights
  name <- paste0("Drop_predicted_zeros_log_evasion_weights_binary", "_controle_", i)
  v_w = ifelse(fullaudits_evaders$y4[!is.na(fullaudits_evaders$y4)] > 20.65, 10, 1)
  
  # Transform
  rf2 <- fullaudits_evaders %>% 
    run_rf(weights = v_w,
           specifics = name)
  
  # Keep only predicted to be no zero
  fullaudits_evasion_predic <- fullaudits %>%
    filter(evasion_dummy_predicted == 1) 
  
  # Predict amoung the evaders
  fullaudits_evasion_predic <- 
    predict_rf(rf2, fullaudits_evasion_predic, specifics = name)
  
  # Bind Rows
  df <- 
    fullaudits_non_evasion_predic %>%
    bind_rows(fullaudits_evasion_predic)

  # Lets create the graphs
  audited <- df %>%
    filter(y2 == 1)
  
  # Create graphs
  quality_graphs(audited, name)

  
  # 5b) Binary weights
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
  
  # Keep only predicted to be no zero
  fullaudits_evasion_predic <- fullaudits %>%
    filter(evasion_dummy_predicted == 1) 
  
  # Predict amoung the evaders
  fullaudits_evasion_predic <- 
    predict_rf(rf2, fullaudits_evasion_predic, specifics = name)
  
  # Bind Rows
  df <- 
    fullaudits_non_evasion_predic %>%
    bind_rows(fullaudits_evasion_predic)
  

  # Lets create the graphs
  audited <- df %>%
    filter(y2 == 1)
  
  # Create graphs
  quality_graphs(audited, name)
  
}