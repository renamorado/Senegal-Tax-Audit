set.seed(10222024)

# Part 1 - Set up the data ----

# Open dataset
data_audits = read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

# Keep only audited units
fullaudits = data_audits[data_audits$controle == 2,]

fullaudits <- fullaudits %>%
  filter(safeties != 1 & selection == 1)

# Create evasion dummy - If the log variable is greater than 1 
fullaudits <- fullaudits %>%
  mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))

# Keep only realized
fullaudits_realized <- fullaudits %>% filter(y2 == 1 & !is.na(y4))

# Set list of variables
covariates <- c("L1TVA_filed", "L3RAS_IRPP_filed", "L2IMP_filed",
                "L1TVAAN_filed", "L3profitrate", "L2TVA_filed", "L1MAN_filed",
                "L3IMP_filed", "L2TVAAN_filed", "L1productivity", "L3TVA_filed",
                "L2MAN_filed", "L1EXP_filed", "L3TVAAN_filed", "L2productivity",
                "L1TAF_filed", "L3MAN_filed", "L2EXP_filed", "L1turnover",
                "L3productivity", "L2TAF_filed", "L1IS_filed", "L3EXP_filed",
                "L2turnover", "firmage", "L3TAF_filed", "L2IS_filed", "L1CGU_filed",
                "L3turnover", "durationcar", "L1RAS_IRPP_filed", "L3IS_filed",
                "L2CGU_filed", "L1profitrate", "distance", "L2RAS_IRPP_filed", 
                "L1IMP_filed", "L3CGU_filed", "L2profitrate", "bureau_detailed", 
                "algorithm", "activity_group")

# Part 2 - Classification Problem

# Lets set 70% to be the training dataset
set.seed(10222024)
train_data <- fullaudits_realized %>%
  group_by(bureau_detailed) %>%
  sample_frac(0.7) %>%
  ungroup()

# Remaining is testing data
test_data <- anti_join(fullaudits_realized, train_data)

predictors <- train_data[, covariates]
outcome <- as.factor(train_data$evasion_dummy)

# Create the hyper grid
hyper_grid <- expand.grid(
  mtry       = seq(5, 30, by = 1),
  node_size  = seq(1, 15, by = 1),
  ntree      = c(300, 500, 1000),
  OOB_RMSE   = NA,
  TN         = NA,
  FN         = NA,
  FP         = NA,
  TP         = NA,
  Accuracy_oob = NA,
  Precision_oob = NA,
  Recall_oob = NA
)

set.seed(10222024)
for(i in 1:nrow(hyper_grid)) {
  
  set.seed(10222024)
  # Run randomForest with weights (OOS)
  rf <- randomForest(
    x = predictors,
    y = outcome,
    keep.inbag = TRUE,
    xtest = test_data[, covariates],
    ytest = as.factor(test_data$evasion_dummy),
    keep.forest = TRUE,
    ntree = hyper_grid$ntree[i],
    mtry = hyper_grid$mtry[i],
    nodesize = hyper_grid$node_size[i]
  )
  
  # Add OOB error to grid
  # Get relevant number
  TN = rf$confusion[1]
  FN = rf$confusion[2]
  FP = rf$confusion[3]
  TP = rf$confusion[4]
  
  # Get quality measures
  Accuracy_oob = (TN + TP)/(TN + FN + TP + FP)
  Precision_oob = (TP)/(TP + FP)
  Recall_oob = (TP)/(TP + FN)
  
  # Update hyper_grid with metrics for the current iteration
  hyper_grid$TN[i] <- TN
  hyper_grid$FN[i] <- FN
  hyper_grid$FP[i] <- FP
  hyper_grid$TP[i] <- TP
  hyper_grid$Accuracy_oob[i] <- Accuracy_oob
  hyper_grid$Precision_oob[i] <- Precision_oob
  hyper_grid$Recall_oob[i] <- Recall_oob
  
  if (i %% 50 == 0 || i == nrow(hyper_grid)) {
    print(paste0(i, "_done"))}
  
}

# Part 3 - Test sample exercise, but with weights ----

# Keep only evaders
fullaudits_evaders <- fullaudits_realized %>%
  filter(is.na(y4) == 0 & evasion_dummy == 1)

# Create the hyper grid
hyper_grid <- expand.grid(
  mtry       = seq(5, 30, by = 1),
  node_size  = seq(1, 15, by = 1),
  ntree      = c(300, 500, 1000),
  OOB_RMSE   = NA,
  OOB_rsq    = NA
)

# Lets set 70% to be the training dataset
set.seed(10222024)
train_data <- fullaudits_evaders %>%
  group_by(bureau_detailed) %>%
  sample_frac(0.7) %>%
  ungroup()

# Remaining is testing data
test_data <- anti_join(fullaudits_evaders, train_data)

# Create weights
w_quartiles <-  train_data %>%
  group_by(inspectorclusteryear) %>%
  mutate(quartile = ntile(y4, 4)) %>%
  ungroup() %>%
  select(quartile) %>%
  mutate(binary_weight = ifelse(quartile == 4, 10, 1))

weights <- w_quartiles$binary_weight

predictors <- train_data[, covariates]
outcome <- train_data$y4

set.seed(10222024)
for(i in 1:nrow(hyper_grid)) {
  
  xtest <- test_data[, covariates]
  ytest <- test_data$y4
  
  set.seed(10222024)
  # Run randomForest with weights (OOS)
  rf2 <- randomForest(
    x = predictors,
    y = outcome,
    weights = weights,
    keep.inbag = TRUE,
    xtest = test_data[, covariates],
    ytest = test_data$y4,
    keep.forest = TRUE,
    ntree = hyper_grid$ntree[i],
    mtry = hyper_grid$mtry[i],
    nodesize = hyper_grid$node_size[i]
  )
  
  
  # Add OOB error to grid
  hyper_grid$OOB_RMSE[i] <- tail(rf2$test$mse, 1)
  hyper_grid$OOB_rsq[i] <- tail(rf2$test$rsq, 1)
  
  if (i %% 50 == 0 || i == nrow(hyper_grid)) {
    print(paste0(i, "_done"))}
  
}

hyper_grid$rank <- rank(-hyper_grid$OOB_rsq)
hyper_grid <- hyper_grid %>%
  filter(rank == 1)

# Parameters
opt_mtry <- hyper_grid$mtry
opt_node_size <- hyper_grid$node_size
opt_ntree <- hyper_grid$ntree


set.seed(10222024)
df_final <- data.frame()
df_final_cont <- data.frame()
for (i in c(1,2)) {
  
  # Keep only audited units
  fullaudits = data_audits[data_audits$controle == i,]
  
  fullaudits <- fullaudits %>%
    filter(safeties != 1 & selection == 1)
  
  
  
  set.seed(10222024)
  
  # Formula
  
  formula <- as.formula(paste("as.factor(evasion_dummy)", "~ L1TVA_filed + L3RAS_IRPP_filed + L2IMP_filed +",
                              "L1TVAAN_filed + L3profitrate + L2TVA_filed + L1MAN_filed +",
                              "L3IMP_filed + L2TVAAN_filed + L1productivity + L3TVA_filed +",
                              "L2MAN_filed + L1EXP_filed + L3TVAAN_filed + L2productivity +",
                              "L1TAF_filed + L3MAN_filed + L2EXP_filed + L1turnover +",
                              "L3productivity + L2TAF_filed + L1IS_filed + L3EXP_filed +",
                              "L2turnover + firmage + L3TAF_filed + L2IS_filed + L1CGU_filed +",
                              "L3turnover + durationcar + L1RAS_IRPP_filed + L3IS_filed +",
                              "L2CGU_filed + L1profitrate + distance + L2RAS_IRPP_filed + L1IMP_filed +",
                              "L3CGU_filed + L2profitrate + bureau_detailed + algorithm + activity_group"))
  
  # Create evasion dummy - If the log variable is greater than 1 
  fullaudits <- fullaudits %>%
    mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))
  
  # Keep only realized
  fullaudits_realized <- fullaudits %>% filter(y2 == 1 & !is.na(y4))
  
  # Run randomForest 
  rf <- randomForest(
    formula = formula,
    data = fullaudits_realized,
    weights = NULL,
    keep.inbag = TRUE
  )
  
  # OOB Test
  df <- rf$confusion
  
  # Get relevant number
  TN = rf$confusion[1]
  FN = rf$confusion[2]
  FP = rf$confusion[3]
  TP = rf$confusion[4]
  
  # Get quality measures
  Accuracy_oob = (TN + TP)/(TN + FN + TP + FP)
  Precision_oob = (TP)/(TP + FP)
  Recall_oob = (TP)/(TP + FN)
  
  # Part 2 - Lets calculate in-sample ----
  
  fullaudits_realized <- fullaudits_realized %>%
    mutate(predicted_evasion = predict(rf, fullaudits_realized))
  
  # Get relevant numbers
  TN = sum(fullaudits_realized$evasion_dummy == 0 & fullaudits_realized$predicted_evasion == 0)
  FN = sum(fullaudits_realized$evasion_dummy == 1 & fullaudits_realized$predicted_evasion == 0)
  FP = sum(fullaudits_realized$evasion_dummy == 0 & fullaudits_realized$predicted_evasion == 1)
  TP = sum(fullaudits_realized$evasion_dummy == 1 & fullaudits_realized$predicted_evasion == 1)
  
  # Get quality measures
  Accuracy_ins = (TN + TP)/(TN + FN + TP + FP)
  Precision_ins = (TP)/(TP + FP)
  Recall_ins = (TP)/(TP + FN)
  
  # Part 3 - Will know split the sample ---- 
  
  # Lets set 70% to be the training dataset
  train_data <- fullaudits_realized %>%
    group_by(bureau_detailed) %>%
    sample_frac(0.7) %>%
    ungroup()
  
  # Remaining is testing data
  test_data <- anti_join(fullaudits_realized, train_data)
  
  # Run randomForest 
  rf <- randomForest(
    formula = formula,
    data = train_data,
    weights = NULL,
    keep.inbag = TRUE)
  
  test_data <- test_data %>%
    mutate(predicted_evasion = predict(rf, test_data))
  
  # Get relevant numbers
  TN = sum(test_data$evasion_dummy == 0 & test_data$predicted_evasion == 0)
  FN = sum(test_data$evasion_dummy == 1 & test_data$predicted_evasion == 0)
  FP = sum(test_data$evasion_dummy == 0 & test_data$predicted_evasion == 1)
  TP = sum(test_data$evasion_dummy == 1 & test_data$predicted_evasion == 1)
  
  # Get quality measures
  Accuracy_oos = (TN + TP)/(TN + FN + TP + FP)
  Precision_oos = (TP)/(TP + FP)
  Recall_oos = (TP)/(TP + FN)
  
  # Put all together 
  df_aux <- data.frame(
    Accuracy_oob = Accuracy_oob,
    Precision_oob = Precision_oob,
    Recall_oob = Recall_oob,
    Accuracy_ins = Accuracy_ins,
    Precision_ins= Precision_ins,
    Recall_ins = Recall_ins,
    Accuracy_oos = Accuracy_oos,
    Precision_oos= Precision_oos,
    Recall_oos = Recall_oos,
    year = "Overall")
  
  # Part 4 - Let's get the OOS numbers per year --- 
  # Quality measures per year
  
  df_aux_by_year <-
    test_data %>%
    group_by(year = as.character(selectionyear)) %>%
    summarise(
      TN = sum(evasion_dummy == 0 & predicted_evasion == 0, na.rm = TRUE),
      FN = sum(evasion_dummy == 1 & predicted_evasion == 0, na.rm = TRUE),
      FP = sum(evasion_dummy == 0 & predicted_evasion == 1, na.rm = TRUE),
      TP = sum(evasion_dummy == 1 & predicted_evasion == 1, na.rm = TRUE),
      Accuracy_oos = (TN + TP) / (TN + FN + TP + FP),
      Precision_oos = TP / (TP + FP),
      Recall_oos = TP / (TP + FN)
    ) %>%
    select(Accuracy_oos, Precision_oos, Recall_oos, year)
  
  df_aux <- bind_rows(df_aux, df_aux_by_year) %>%
    mutate(type = i)
  
  df_final <- bind_rows(df_aux, df_final)
  
  
  # Part 5 - We no change for the continuous analyses ---- 
  
  set.seed(10222024)
  
  # Prepare the formula based on the target variable
  covariates <- c("L1TVA_filed", "L3RAS_IRPP_filed", "L2IMP_filed",
                  "L1TVAAN_filed", "L3profitrate", "L2TVA_filed", "L1MAN_filed",
                  "L3IMP_filed", "L2TVAAN_filed", "L1productivity", "L3TVA_filed",
                  "L2MAN_filed", "L1EXP_filed", "L3TVAAN_filed", "L2productivity",
                  "L1TAF_filed", "L3MAN_filed", "L2EXP_filed", "L1turnover",
                  "L3productivity", "L2TAF_filed", "L1IS_filed", "L3EXP_filed",
                  "L2turnover", "firmage", "L3TAF_filed", "L2IS_filed", "L1CGU_filed",
                  "L3turnover", "durationcar", "L1RAS_IRPP_filed", "L3IS_filed",
                  "L2CGU_filed", "L1profitrate", "distance", "L2RAS_IRPP_filed", 
                  "L1IMP_filed", "L3CGU_filed", "L2profitrate", "bureau_detailed", 
                  "algorithm", "activity_group")
  
  # Keep only evaders
  fullaudits_evaders <- fullaudits_realized %>%
    filter(is.na(y4) == 0 & evasion_dummy == 1)
  
  set.seed(10222024)
  # Lets set 70% to be the training dataset
  train_data <- fullaudits_evaders %>%
    group_by(bureau_detailed) %>%
    sample_frac(0.7) %>%
    ungroup()
  
  # Remaining is testing data
  test_data <- anti_join(fullaudits_evaders, train_data)
  
  # Create weights
  w_quartiles <-  train_data %>%
    group_by(inspectorclusteryear) %>%
    mutate(quartile = ntile(y4, 4)) %>%
    ungroup() %>%
    select(quartile) %>%
    mutate(binary_weight = ifelse(quartile == 4, 10, 1))
  
  weights <- w_quartiles$binary_weight
  
  predictors <- train_data[, covariates]
  outcome <- train_data$y4
  
  set.seed(10222024)
  # Run randomForest with weights - full sample (OOB)
  rf1 <- randomForest(
    x = predictors,
    y = outcome,
    weights = weights,
    mtry = opt_mtry,
    nodesize = opt_node_size,
    ntree = opt_ntree,
    keep.inbag = TRUE,
    keep.forest = TRUE
  )
  
  # Now with the splited the sample
  outcome <- train_data$y4
  predictors <- train_data[, covariates]
  
  set.seed(10222024)
  # Run randomForest with weights (OOS)
  rf2 <- randomForest(
    x = predictors,
    y = outcome,
    weights = weights,
    keep.inbag = TRUE,
    xtest = test_data[, covariates],
    ytest = test_data$y4,
    mtry = opt_mtry,
    nodesize = opt_node_size,
    ntree = opt_ntree,
    keep.forest = TRUE
  )
  
  # Put all together 
  df_aux <- data.frame(
    final_rsq_oob = tail(rf1$rsq, 1),
    final_mse_oob = tail(rf1$mse, 1),
    final_rsq_oos = tail(rf2$test$rsq, 1),
    final_mse_oos = tail(rf2$test$mse, 1),
    year = "Overall")
  
  
  # Filter by year and calculate metrics for each year
  years <- c(2018, 2019, 2020)
  
  results_by_year <- lapply(years, function(year) {
    # Filtrar dados do ano específico
    xtest_year <- test_data[test_data$selectionyear == year, covariates]
    ytest_year <- test_data$y4[test_data$selectionyear == year]
    
    
    set.seed(10222024)
    # Treinar o modelo com os dados filtrados
    rf_model <- randomForest(
      x = predictors,
      y = outcome,
      weights = weights,
      keep.inbag = TRUE,
      xtest = xtest_year,
      ytest = ytest_year,
      mtry = opt_mtry,
      nodesize = opt_node_size,
      ntree = opt_ntree,
      keep.forest = TRUE
    )
    
    # Extrair métricas para o ano
    final_rsq <- tail(rf_model$test$rsq, 1)
    final_mse <- tail(rf_model$test$mse, 1)
    
    # Retornar as métricas
    list(
      year = as.character(year),
      final_rsq_oos  = final_rsq,
      final_mse_oos = final_mse
    )
  })
  
  # Converter os resultados em um data frame para melhor visualização
  results_df <- do.call(rbind, lapply(results_by_year, as.data.frame)) 
  
  df_cont_aux <- results_df %>% bind_rows(df_aux) %>%
    mutate(type = i)
  
  df_final_cont <- bind_rows(df_cont_aux, df_final_cont)
}

df_final <- df_final %>% left_join(df_final_cont, by = c("year", "type"))

df_final_oos_2 <- df_final %>% filter(type == 2) %>%
  select(year, Precision = Precision_oos, Recall = Recall_oos, MSPE = final_mse_oos, R2 = final_rsq_oos) 

df_final_oos_1 <- df_final %>% filter(type == 1) %>%
  select(year, Precision = Precision_oos, Recall = Recall_oos, MSPE = final_mse_oos, R2 = final_rsq_oos)

df_final_oob_1 <- df_final %>% filter(type == 1, year == "Overall") %>%
  select(year, Precision = Precision_oob, Recall = Recall_oob, MSPE = final_mse_oob, R2 = final_rsq_oob) 

df_final_oob_2 <- df_final %>% filter(type == 2, year == "Overall") %>%
  select(year, Precision = Precision_oob, Recall = Recall_oob, MSPE =  final_mse_oob, R2 = final_rsq_oob)

# Adiciona uma coluna para identificar o tipo de auditoria
df_final_oos_2 <- df_final_oos_2 %>% mutate(Audit_Type = "Full Audits", OOS_OOB = "OOS")
df_final_oos_1 <- df_final_oos_1 %>% mutate(Audit_Type = "Desk Audits", OOS_OOB = "OOS")
df_final_oob_2 <- df_final_oob_2 %>% mutate(Audit_Type = "Full Audits", OOS_OOB = "OOB")
df_final_oob_1 <- df_final_oob_1 %>% mutate(Audit_Type = "Desk Audits", OOS_OOB = "OOB")

# Combina todos os data frames
df_combined <- bind_rows(df_final_oos_2, df_final_oos_1, df_final_oob_2, df_final_oob_1) %>%
  mutate(across(c(Precision, Recall, MSPE, R2), ~ round(., 2)))

panel_a <- df_combined %>%
  filter(Audit_Type == "Full Audits") %>%
  mutate(year = ifelse(year == "Overall", paste0("Overall ", OOS_OOB), year),
         year = factor(year, levels = c("Overall OOS", "Overall OOB", "2018", "2019", "2020"))) %>%
  select(year, Precision, Recall, MSPE, R2) %>%
  arrange(match(year, levels(year)))

panel_b <- df_combined %>%
  filter(Audit_Type == "Desk Audits") %>%
  mutate(year = ifelse(year == "Overall", paste0("Overall ", OOS_OOB), year),
         year = factor(year, levels = c("Overall OOS", "Overall OOB", "2018", "2019", "2020"))) %>%
  select(year, Precision, Recall, MSPE, R2) %>%
  arrange(match(year, levels(year)))



table_text <- print(
  xtable(panel_a),
  include.colnames = FALSE,
  only.contents = TRUE,
  include.rownames = FALSE
)

writeLines(table_text, paste0(output_path, "panel_a_contents.tex"))

table_text <- print(
  xtable(panel_b),
  include.colnames = FALSE,
  only.contents = TRUE,
  include.rownames = FALSE
)

writeLines(table_text, paste0(output_path, "panel_b_contents.tex"))

#####
# Exporting Tables 
#####




hdr <- function(txt, n) setNames(n, txt)

make_panel <- function(dat, audit_type, panel_label){
  ord <- c("Overall OOS","Overall OOB","2018","2019","2020")
  ttl <- sprintf("%s: %s", panel_label, audit_type)
  
  # choose A/B prefix for the two spanners
  prefix <- if (panel_label == "B") "B" else "A"
  sp1 <- sprintf("\\\\shortstack{%s1: Predicting Detection\\\\\\\\$|$~Execution}", prefix)
  sp2 <- sprintf("\\\\shortstack{%s2: Predicting Evasion Amount\\\\\\\\$|$~Detection}", prefix)
  
  dat %>%
    filter(Audit_Type == audit_type) %>%
    mutate(year = ifelse(year == "Overall", paste("Overall", OOS_OOB), year)) %>%
    select(Row = year, Precision, Recall, MSPE, R2) %>%
    mutate(across(-Row, ~round(.x, 2))) %>%
    filter(Row %in% ord) %>%
    mutate(Row = factor(Row, levels = ord)) %>%
    arrange(Row) %>%
    kbl(
      format = "latex", booktabs = TRUE, escape = TRUE,
      align = c("l","c","c","c","c"),
      col.names = c("", "(1)","(2)","(3)","(4)")
    ) %>%
    
    # column-level subheaders just above (1)-(4)
    add_header_above(
      c(" " = 1, "Precision" = 1, "Recall" = 1, "MSPE" = 1, "$R^{2}$" = 1),
      escape = FALSE
    ) %>%
    
    # dynamic col labels
    add_header_above(
      c(" " = 1, hdr(sp1, 2), hdr(sp2, 2)),
      escape = FALSE
    ) %>%
    
    # top title
    add_header_above(hdr(ttl, 5), bold = TRUE, escape = FALSE)
}

tabA <- make_panel(df_combined, "Full Audits", "A")
tabB <- make_panel(df_combined, "Desk Audits", "B")

# Combine both panels adding space between them and write to .tex 
latex_out <- paste(
  tabA,
  "\\addlinespace[0.75em]",
  tabB,
  sep = "\n"
)

writeLines(latex_out, "output/table_G3_RF.tex")
