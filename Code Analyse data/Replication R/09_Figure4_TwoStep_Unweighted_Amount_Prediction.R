###########
# Figure 4 two-step unweighted amount prediction
###########
# This standalone script exports selected full-audit predictions for a
# Figure 4 replication. It keeps the original optimization-style detection
# gate but removes the top-quartile revenue weights from the amount RF.

replication_libraries <- c(
  "C:/Users/User/Dropbox/Senegal tax audits/Analysis all data/replication_package/Code Analyse data/Replication R/renv/library/windows/R-4.4/x86_64-w64-mingw32",
  "C:/Users/User/Dropbox/Senegal tax audits/Analysis all data/replication_package/Code Analyse data/Replication R/renv/library/windows/R-4.5/x86_64-w64-mingw32",
  "C:/Users/wb648862/Dropbox/Senegal tax audits/Analysis all data/replication_package/Code Analyse data/Replication R/renv/library/windows/R-4.5/x86_64-w64-mingw32"
)
replication_libraries <- replication_libraries[dir.exists(replication_libraries)]
if (length(replication_libraries) > 0) {
  .libPaths(c(replication_libraries, .libPaths()))
}

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(randomForest)
})

if (!exists("data_path")) {
  data_path <- "C:/Users/wb648862/Dropbox/Senegal tax audits/Analysis all data/replication_package/Working data"
}

input_file <- file.path(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta")
project_root <- "C:/Users/wb648862/Documents/Projects/Senegal Tax Audits"
prediction_output_dir <- if (dir.exists(project_root)) {
  file.path(project_root, "Output")
} else {
  data_path
}
prediction_output_file <- file.path(prediction_output_dir, "fullaudits_predicted_twostep_unweighted.dta")

rf_predictors <- paste(
  "L1TVA_filed + L3RAS_IRPP_filed + L2IMP_filed +",
  "L1TVAAN_filed + L3profitrate + L2TVA_filed + L1MAN_filed +",
  "L3IMP_filed + L2TVAAN_filed + L1productivity + L3TVA_filed +",
  "L2MAN_filed + L1EXP_filed + L3TVAAN_filed + L2productivity +",
  "L1TAF_filed + L3MAN_filed + L2EXP_filed + L1turnover +",
  "L3productivity + L2TAF_filed + L1IS_filed + L3EXP_filed +",
  "L2turnover + firmage + L3TAF_filed + L2IS_filed + L1CGU_filed +",
  "L3turnover + durationcar + L1RAS_IRPP_filed + L3IS_filed +",
  "L2CGU_filed + L1profitrate + distance + L2RAS_IRPP_filed + L1IMP_filed +",
  "L3CGU_filed + L2profitrate + bureau_detailed + algorithm + activity_group"
)

detection_predictors <- paste(
  "L1TVA_filed + L3RAS_IRPP_filed + L2IMP_filed +",
  "L1TVAAN_filed + L3profitrate + L2TVA_filed + L1MAN_filed +",
  "L3IMP_filed + L2TVAAN_filed + L1productivity + L3TVA_filed +",
  "L2MAN_filed + L1EXP_filed + L3TVAAN_filed + L2productivity +",
  "L1TAF_filed + L3MAN_filed + L2EXP_filed + L1turnover +",
  "L3productivity + L2TAF_filed + L1IS_filed + L3EXP_filed +",
  "L2turnover + firmage + L3TAF_filed + L2IS_filed + L1CGU_filed +",
  "L3turnover + durationcar + L1RAS_IRPP_filed + L3IS_filed +",
  "L2CGU_filed + L1profitrate + distance + L2RAS_IRPP_filed + L1IMP_filed +",
  "L3CGU_filed + L2profitrate + activity_group + bureau_detailed + algorithm"
)

run_revenue_rf <- function(df) {
  formula <- as.formula(paste("y4", "~", rf_predictors))

  set.seed(10222024)
  randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(y4)),
    weights = NULL,
    keep.inbag = TRUE
  )
}

if (!file.exists(input_file)) {
  stop("Input file not found: ", input_file)
}

data_audits <- read_dta(input_file)

fullaudits <- data_audits %>%
  filter(controle == 2) %>%
  filter(safeties != 1 & selection == 1)

message("Selected non-safety full-audit rows: ", nrow(fullaudits))

detection_formula <- as.formula(paste("as.factor(evasion_dummy)", "~", detection_predictors))

fullaudits <- fullaudits %>%
  mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))

set.seed(10222024)
detection_rf <- randomForest(
  formula = detection_formula,
  data = fullaudits %>% filter(y2 == 1 & !is.na(y4)),
  weights = NULL,
  keep.inbag = TRUE
)

fullaudits <- fullaudits %>%
  mutate(evasion_dummy_predicted = as.character(predict(detection_rf, fullaudits)))

fullaudits_evaders <- fullaudits %>%
  filter(y4 > 0)

message("Positive-evasion rows passed to amount RF: ", nrow(fullaudits_evaders))

amount_rf <- run_revenue_rf(fullaudits_evaders)

fullaudits_predicted <- fullaudits %>%
  mutate(
    yhatrf_raw_twostep_unweighted = as.numeric(predict(amount_rf, fullaudits)),
    yhatrf = ifelse(evasion_dummy_predicted == "0", 0, yhatrf_raw_twostep_unweighted)
  )

required_vars <- c("yhatrf", "y2", "y4", "algorithm", "dgid", "selection", "safeties", "controle")
missing_vars <- setdiff(required_vars, names(fullaudits_predicted))
if (length(missing_vars) > 0) {
  stop("Missing required output variables: ", paste(missing_vars, collapse = ", "))
}

write_dta(fullaudits_predicted, prediction_output_file)

message("Wrote ", prediction_output_file)
