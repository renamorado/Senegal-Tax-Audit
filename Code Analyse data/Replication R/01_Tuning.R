###SENEGAL TAX AUDITS 
###August 2024
###BACHAS BROCKMEYER FERREIRA SARR

###########################
#Description
###########################

#This script tries exercises spliting the data

###########################
###Working directories
###########################


set.seed(10222024)

# Part 1 - Set up the data ----

# Open dataset
data_audits = 
  read_dta(
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

# Part 3 - Test sample exercise, but with weights ----

# Keep only evaders
fullaudits_evaders <- fullaudits_realized %>%
  filter(is.na(y4) == 0 & evasion_dummy == 1)

# Create the hyper grid
hyper_grid <- expand.grid(
  mtry       = seq(1, 15, by = 1),
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
    weights = NULL,
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
