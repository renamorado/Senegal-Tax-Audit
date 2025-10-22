# Create Functions to run RF

# Function to process RF
run_rf <- function(df, target_variable = "y4",
                   weights = NULL){
  
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
    weights = NULL,
    keep.inbag = TRUE
  )
  
  return(rf)
  
}

# Algorithm only
data_audits = read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

# First data clean
fullaudits = data_audits %>%
  filter(controle == 2 & safeties != 1 & selection == 1)

# Train only in realized
fullaudits_realized <- fullaudits %>%
  filter(y2 == 1 & !is.na(y4))

rf <- run_rf(fullaudits_realized)

fullaudits_realized_test <- fullaudits

# Main Figure 4
plot_name <- "10 density predicted evasion R"
source(paste0(r_code_path, "02_Graph_Function.R"))


# Predict on Algorithm-Selected Cases
fullaudits_realized_test <- fullaudits %>% filter(algorithm == 1)

plot_name <- "10 density predicted evasion algorithm R"
source(paste0(r_code_path, "02_Graph_Function.R"))

# Predict on Algorithm-Selected Cases
fullaudits_realized_test <- fullaudits %>% filter(dgid == 1)

plot_name <- "10 density predicted evasion inspector R"
source(paste0(r_code_path, "02_Graph_Function.R"))

# Same for desk audits

# First data clean
fullaudits = data_audits %>%
  filter(controle == 1 & safeties != 1 & selection == 1)

# Train only in realized
fullaudits_realized <- fullaudits %>%
  filter(y2 == 1 & !is.na(y4))

rf <- run_rf(fullaudits_realized)

fullaudits_realized_test <- fullaudits

# Main Figure 4 desk audit
fullaudits_realized_test <- fullaudits
plot_name <- "10 density predicted evasion desk audits R quintiles"
source(paste0(r_code_path, "02_Graph_Desk_Function.R"))
