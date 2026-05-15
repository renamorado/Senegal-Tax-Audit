###########
# Full-audit unweighted RF predicted list rank
###########
# This standalone script mirrors the direct unweighted predicted-evasion
# workflow, but predicts realized evasion rank within each full-audit list
# instead of realized evasion amount.

replication_library <- "C:/Users/wb648862/Dropbox/Senegal tax audits/Analysis all data/replication_package/Code Analyse data/Replication R/renv/library/windows/R-4.5/x86_64-w64-mingw32"
if (dir.exists(replication_library)) {
  .libPaths(c(replication_library, .libPaths()))
}

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(randomForest)
})

if (!exists("data_path")) {
  data_path <- "Working Data/"
}

rank_output_file <- file.path(data_path, "fullaudits_predicted_rank_bureauyear.dta")

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

run_rank_rf <- function(df, target_variable = "rank_y4_bureauyear") {
  formula <- as.formula(paste(target_variable, "~", rf_predictors))

  set.seed(10222024)
  randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(y4) & !is.na(.data[[target_variable]])),
    weights = NULL,
    keep.inbag = TRUE
  )
}

predict_rank_rf <- function(rf, data) {
  data %>%
    mutate(
      predicted_rank_y4_bureauyear = as.numeric(predict(rf, data))
    ) %>%
    group_by(bureau_detailed, selectionyear) %>%
    mutate(
      predicted_rank_order_bureauyear = rank(
        predicted_rank_y4_bureauyear,
        ties.method = "min",
        na.last = "keep"
      ),
      yhatrf_rank_score = -predicted_rank_order_bureauyear,
      yhatrf = yhatrf_rank_score
    ) %>%
    ungroup()
}

data_audits <- read_dta(
  file.path(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta")
)

fullaudits <- data_audits %>%
  filter(controle == 2 & safeties != 1 & selection == 1) %>%
  group_by(bureau_detailed, selectionyear) %>%
  mutate(
    rank_y4_bureauyear = rank(
      ifelse(y2 == 1 & !is.na(y4), -y4, NA_real_),
      ties.method = "min",
      na.last = "keep"
    )
  ) %>%
  ungroup()

training_n <- fullaudits %>%
  filter(y2 == 1 & !is.na(y4) & !is.na(rank_y4_bureauyear)) %>%
  nrow()

if (training_n == 0) {
  stop("No executed full-audit observations with observed y4 are available for rank RF training.")
}

message("Training unweighted full-audit rank random forest on ", training_n, " executed observations.")
rank_rf <- run_rank_rf(fullaudits)

message("Predicting list-level rank for selected non-safety full audits.")
fullaudits_predicted_rank <- predict_rank_rf(rank_rf, fullaudits)

write_dta(fullaudits_predicted_rank, rank_output_file)

message("Wrote ", rank_output_file)
