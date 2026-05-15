###########
# RF optimization gains revision
###########
# This standalone revision preserves 07_Optimization_Exercise.R.
# It recreates the current Table 9 optimization exercise and adds
# top-realized-outlier-excluded revenue-gain and overlap columns using
# the unweighted predicted evasion score.

replication_library <- "C:/Users/wb648862/Dropbox/Senegal tax audits/Analysis all data/replication_package/Code Analyse data/Replication R/renv/library/windows/R-4.5/x86_64-w64-mingw32"
if (dir.exists(replication_library)) {
  .libPaths(c(replication_library, .libPaths()))
}

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(randomForest)
  library(kableExtra)
})

if (!exists("data_path")) {
  data_path <- "Working Data/"
}

if (!exists("r_code_path")) {
  r_code_path <- "Code Analyse data/Replication R/"
}

project_root <- "C:/Users/wb648862/Documents/Projects/Senegal Tax Audits"
if (dir.exists(project_root)) {
  revision_output_path <- file.path(project_root, "Output")
} else if (exists("output_path")) {
  revision_output_path <- output_path
} else {
  revision_output_path <- "Output"
}

dir.create(revision_output_path, showWarnings = FALSE, recursive = TRUE)

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

run_revenue_rf <- function(df, target_variable = "y4", weights = NULL) {
  formula <- as.formula(paste(target_variable, "~", rf_predictors))

  set.seed(10222024)
  randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(.data[[target_variable]])),
    weights = weights,
    keep.inbag = TRUE
  )
}

predict_revenue_rf <- function(rf, data) {
  data %>%
    mutate(yhatrf = as.numeric(predict(rf, data)))
}

optimization <- function(df, type = 2) {
  df <- df %>%
    mutate(y2controle = ifelse(y2 == 1 & controle == type, 1, 0)) %>%
    group_by(inspectorclusteryear) %>%
    mutate(totalexecuted = sum(y2controle, na.rm = TRUE))

  df <- df %>%
    group_by(inspectorclusteryear) %>%
    arrange(inspectorclusteryear, desc(yhatrf), .by_group = FALSE) %>%
    mutate(
      optimized_all = row_number() <= first(totalexecuted),
      overlap_unit = ifelse(y2controle == 1 & optimized_all == 1, 1, 0)
    ) %>%
    ungroup()

  return(df)
}

table_standard <- function(df, type = 2) {
  df <- df %>%
    mutate(
      evasion_level_realized = exp(y4) - 1,
      evasion_level_predicted = exp(yhatrf) - 1
    )

  realized_program <- df %>%
    filter(y2 == 1 & controle == type)

  optimized_program <- df %>%
    filter(optimized_all == 1)

  realized_log_mean <- log(mean(realized_program$evasion_level_realized, na.rm = TRUE))
  audited_predicted_log_mean <- log(mean(realized_program$evasion_level_predicted, na.rm = TRUE))

  revenue_gain <- 100 * (
    mean(optimized_program$evasion_level_predicted, na.rm = TRUE) /
      mean(realized_program$evasion_level_predicted, na.rm = TRUE) -
      1
  )

  overlap_share <- sum(df$overlap_unit, na.rm = TRUE) / sum(df$optimized_all, na.rm = TRUE)

  tibble(
    realized_log_mean = realized_log_mean,
    predicted_log_mean = audited_predicted_log_mean,
    revenue_gain = revenue_gain,
    overlap_share = overlap_share
  )
}

table_top_five_excluded <- function(df, type = 2) {
  df <- df %>%
    mutate(
      evasion_level_realized = exp(y4) - 1,
      evasion_level_predicted = exp(yhatrf) - 1
    )

  realized_program <- df %>%
    filter(y2 == 1 & controle == type)

  optimized_program <- df %>%
    filter(optimized_all == 1)

  revenue_gain_ex_top5 <- 100 * (
    mean(optimized_program$evasion_level_predicted, na.rm = TRUE) /
      mean(realized_program$evasion_level_predicted, na.rm = TRUE) -
      1
  )

  overlap_share_ex_top5 <- sum(df$overlap_unit, na.rm = TRUE) / sum(df$optimized_all, na.rm = TRUE)

  tibble(
    revenue_gain_ex_top5 = revenue_gain_ex_top5,
    overlap_share_ex_top5 = overlap_share_ex_top5
  )
}

drop_top_realized_outliers <- function(df, type = 2, n_outliers = 5) {
  top_realized_cases <- df %>%
    filter(y2 == 1 & controle == type & !is.na(y4)) %>%
    mutate(evasion_level_realized = exp(y4) - 1) %>%
    arrange(desc(evasion_level_realized)) %>%
    slice_head(n = n_outliers) %>%
    pull(revision_case_id)

  df %>%
    filter(!revision_case_id %in% top_realized_cases)
}

build_predicted_data <- function(
    data_audits,
    type,
    weighted_revenue_prediction = TRUE,
    use_detection_gate = TRUE,
    exclude_top_realized_before_optimization = FALSE
) {
  audit_label <- ifelse(type == 2, "Full Audits", "Desk Audits")
  prediction_label <- ifelse(weighted_revenue_prediction, "current weighted", "unweighted")
  message("Building ", prediction_label, " optimization prediction for ", audit_label, ".")

  audits <- data_audits %>%
    filter(controle == type) %>%
    filter(safeties != 1 & selection == 1) %>%
    mutate(revision_case_id = row_number())

  if (use_detection_gate) {
    detection_formula <- as.formula(paste("as.factor(evasion_dummy)", "~", detection_predictors))

    audits <- audits %>%
      mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))

    set.seed(10222024)
    message("  Training detection random forest.")
    detection_rf <- randomForest(
      formula = detection_formula,
      data = audits %>% filter(y2 == 1 & !is.na(y4)),
      weights = NULL,
      keep.inbag = TRUE
    )

    audits <- audits %>%
      mutate(evasion_dummy_predicted = as.character(predict(detection_rf, audits)))

    audits_for_revenue_training <- audits %>%
      filter(y4 > 0)
  } else {
    audits_for_revenue_training <- audits
  }

  revenue_weights <- NULL
  if (weighted_revenue_prediction) {
    revenue_weights <- audits_for_revenue_training %>%
      filter(is.na(y4) == 0) %>%
      group_by(inspectorclusteryear) %>%
      mutate(quartile = ntile(y4, 4)) %>%
      ungroup() %>%
      select(quartile) %>%
      mutate(binary_weight = ifelse(quartile == 4, 10, 1)) %>%
      pull(binary_weight)
  }

  message("  Training ", prediction_label, " revenue random forest.")
  revenue_rf <- audits_for_revenue_training %>%
    run_revenue_rf(weights = revenue_weights)

  message("  Predicting revenue and computing optimized selection.")
  audits_predicted <- predict_revenue_rf(revenue_rf, audits)

  if (use_detection_gate) {
    audits_predicted <- audits_predicted %>%
      mutate(yhatrf = ifelse(evasion_dummy_predicted == "0", 0, yhatrf))
  }

  audits_for_optimization <- audits_predicted %>%
    filter(selectionyear != 2020)

  if (exclude_top_realized_before_optimization) {
    message("  Excluding the five largest realized-revenue audited cases before optimization.")
    audits_for_optimization <- audits_for_optimization %>%
      drop_top_realized_outliers(type = type, n_outliers = 5)
  }

  audits_for_optimization %>%
    optimization(type = type)
}

build_results_for_type <- function(data_audits, type) {
  current_weighted <- build_predicted_data(
    data_audits,
    type = type,
    weighted_revenue_prediction = TRUE
  ) %>%
    table_standard(type = type)

  unweighted_top5 <- build_predicted_data(
    data_audits,
    type = type,
    weighted_revenue_prediction = FALSE,
    use_detection_gate = FALSE,
    exclude_top_realized_before_optimization = TRUE
  ) %>%
    table_top_five_excluded(type = type)

  bind_cols(current_weighted, unweighted_top5)
}

data_audits <- read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta")
)

results_list <- list(
  "Desk Audits" = build_results_for_type(data_audits, type = 1),
  "Full Audits" = build_results_for_type(data_audits, type = 2)
)

full_table <- bind_rows(results_list, .id = "Panel") %>%
  arrange(factor(Panel, levels = c("Full Audits", "Desk Audits")))

table1 <- full_table %>%
  transmute(
    `(1)` = round(realized_log_mean, 2),
    `(2)` = round(predicted_log_mean, 2),
    `(3)` = paste0(ifelse(revenue_gain >= 0, "+ ", "- "), sprintf("%.2f", abs(revenue_gain)), "%"),
    `(4)` = paste0(sprintf("%.0f", 100 * overlap_share), "%"),
    `(5)` = paste0(ifelse(revenue_gain_ex_top5 >= 0, "+ ", "- "), sprintf("%.2f", abs(revenue_gain_ex_top5)), "%"),
    `(6)` = paste0(sprintf("%.0f", 100 * overlap_share_ex_top5), "%")
  )

latex_tabular <- kbl(
  table1,
  format = "latex",
  booktabs = TRUE,
  escape = TRUE,
  align = "cccccc"
) %>%
  add_header_above(c(
    "\\\\shortstack{Realized\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{Predicted\\\\\\\\Revenue\\\\\\\\Log(mean)}" = 1,
    "\\\\shortstack{$\\\\Delta$ Revenue vs Predicted\\\\\\\\w/ RF Selection\\\\\\\\Among Program Cases}" = 1,
    "\\\\shortstack{Overlap Between\\\\\\\\Optimized and\\\\\\\\Realized Audit Program}" = 1,
    "\\\\shortstack{$\\\\Delta$ Revenue vs Unweighted\\\\\\\\Predicted Revenue\\\\\\\\Excl. Top Five Realized Firms}" = 1,
    "\\\\shortstack{Overlap w/ Unweighted\\\\\\\\Predicted Revenue Selection\\\\\\\\Excl. Top Five Realized Firms}" = 1
  ), escape = FALSE) %>%
  pack_rows("A: Full Audits", 1, 1, bold = TRUE) %>%
  pack_rows("B: Desk Audits", 2, 2, bold = TRUE)

writeLines(
  as.character(latex_tabular),
  file.path(revision_output_path, "table_opt_full_and_desk_unweighted_top5_revision.tex")
)

message(
  "Wrote ",
  file.path(revision_output_path, "table_opt_full_and_desk_unweighted_top5_revision.tex")
)
