###########
# RF optimization gains panel revision
###########
# This standalone revision preserves 07_Optimization_Exercise.R.
# It rebuilds the Table 48 optimization-gains check as panel A/B
# scenarios that keep the original four Table 9 columns.

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
  library(tidyr)
  library(tibble)
  library(randomForest)
})

if (!exists("data_path")) {
  data_path <- "Working Data/"
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

table_output_file <- file.path(
  revision_output_path,
  "table_opt_full_and_desk_unweighted_top5_revision.tex"
)

diagnostics_output_file <- file.path(
  revision_output_path,
  "table_opt_full_and_desk_unweighted_top5_revision_diagnostics.csv"
)

rank_export_b1_file <- file.path(
  data_path,
  "fullaudits_predicted_rank_bureauyear_07_b1_allcases.dta"
)

rank_export_b2b3_file <- file.path(
  data_path,
  "fullaudits_predicted_rank_bureauyear_07_b2b3_top5excluded.dta"
)

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

format_number <- function(x) {
  sprintf("%.2f", round(x, 2))
}

format_gain <- function(x) {
  paste0(ifelse(x >= 0, "+ ", "- "), sprintf("%.2f", abs(x)), "\\%")
}

format_share <- function(x) {
  paste0(sprintf("%.0f", 100 * x), "\\%")
}

audit_label <- function(type) {
  ifelse(type == 2, "Full Audits", "Desk Audits")
}

drop_top_realized_outliers <- function(df, type, n_outliers = 5) {
  top_realized_cases <- df %>%
    filter(selectionyear != 2020) %>%
    filter(y2 == 1 & controle == type & !is.na(y4)) %>%
    mutate(evasion_level_realized = exp(y4) - 1) %>%
    arrange(desc(evasion_level_realized), revision_case_id) %>%
    slice_head(n = n_outliers) %>%
    pull(revision_case_id)

  df %>%
    filter(!revision_case_id %in% top_realized_cases)
}

build_base_audits <- function(data_audits, type, exclude_top_realized = FALSE) {
  audits <- data_audits %>%
    filter(controle == type) %>%
    filter(safeties != 1 & selection == 1) %>%
    mutate(revision_case_id = row_number())

  if (exclude_top_realized) {
    audits <- audits %>%
      drop_top_realized_outliers(type = type, n_outliers = 5)
  }

  audits
}

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
    mutate(amount_yhatrf = as.numeric(predict(rf, data)))
}

build_amount_predictions <- function(
    audits,
    weighted_revenue_prediction = TRUE,
    use_detection_gate = TRUE
) {
  prediction_label <- ifelse(weighted_revenue_prediction, "weighted two-step", "unweighted one-step")
  message("  Training ", prediction_label, " amount prediction.")

  if (use_detection_gate) {
    detection_formula <- as.formula(paste("as.factor(evasion_dummy)", "~", detection_predictors))

    audits <- audits %>%
      mutate(evasion_dummy = ifelse(y4 > 1, 1, 0))

    set.seed(10222024)
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
      filter(!is.na(y4)) %>%
      group_by(inspectorclusteryear) %>%
      mutate(quartile = ntile(y4, 4)) %>%
      ungroup() %>%
      mutate(binary_weight = ifelse(quartile == 4, 10, 1)) %>%
      pull(binary_weight)
  }

  revenue_rf <- run_revenue_rf(
    df = audits_for_revenue_training,
    weights = revenue_weights
  )

  audits_predicted <- predict_revenue_rf(revenue_rf, audits)

  if (use_detection_gate) {
    audits_predicted <- audits_predicted %>%
      mutate(amount_yhatrf = ifelse(evasion_dummy_predicted == "0", 0, amount_yhatrf))
  }

  audits_predicted
}

run_rank_rf <- function(df, target_variable = "rank_y4_bureauyear") {
  formula <- as.formula(paste(target_variable, "~", rf_predictors))

  set.seed(10222024)
  randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(.data[[target_variable]])),
    weights = NULL,
    keep.inbag = TRUE
  )
}

build_rank_predictions <- function(audits) {
  message("  Training rank prediction.")

  audits_ranked <- audits %>%
    group_by(bureau_detailed, selectionyear) %>%
    mutate(
      rank_y4_bureauyear = rank(
        ifelse(y2 == 1 & !is.na(y4), -y4, NA_real_),
        ties.method = "min",
        na.last = "keep"
      )
    ) %>%
    ungroup()

  rank_rf <- run_rank_rf(audits_ranked)

  audits_ranked %>%
    mutate(predicted_rank_y4_bureauyear = as.numeric(predict(rank_rf, audits_ranked))) %>%
    group_by(bureau_detailed, selectionyear) %>%
    arrange(bureau_detailed, selectionyear, predicted_rank_y4_bureauyear, revision_case_id, .by_group = FALSE) %>%
    mutate(
      predicted_rank_order_bureauyear = rank(
        predicted_rank_y4_bureauyear,
        ties.method = "min",
        na.last = "keep"
      ),
      rank_priority_score = -predicted_rank_order_bureauyear,
      yhatrf_rank_score = rank_priority_score,
      yhatrf = yhatrf_rank_score
    ) %>%
    ungroup()
}

optimize_selection <- function(df, type, priority_variable) {
  df %>%
    filter(selectionyear != 2020) %>%
    mutate(y2controle = ifelse(y2 == 1 & controle == type, 1, 0)) %>%
    group_by(inspectorclusteryear) %>%
    mutate(totalexecuted = sum(y2controle, na.rm = TRUE)) %>%
    arrange(
      inspectorclusteryear,
      desc(.data[[priority_variable]]),
      revision_case_id,
      .by_group = FALSE
    ) %>%
    mutate(
      optimized_all = row_number() <= first(totalexecuted),
      overlap_unit = ifelse(y2controle == 1 & optimized_all == 1, 1, 0)
    ) %>%
    ungroup()
}

summarize_table_row <- function(df, type) {
  df <- df %>%
    mutate(
      evasion_level_realized = exp(y4) - 1,
      evasion_level_predicted = exp(amount_yhatrf) - 1
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

build_scenario_type <- function(
    data_audits,
    type,
    scenario_id,
    scenario_label,
    exclude_top_realized,
    weighted_revenue_prediction,
    use_detection_gate,
    selection_method
) {
  message("Building ", scenario_id, " for ", audit_label(type), ".")

  audits <- build_base_audits(
    data_audits = data_audits,
    type = type,
    exclude_top_realized = exclude_top_realized
  )

  amount_predicted <- build_amount_predictions(
    audits = audits,
    weighted_revenue_prediction = weighted_revenue_prediction,
    use_detection_gate = use_detection_gate
  )

  if (selection_method == "rank") {
    rank_predicted <- build_rank_predictions(audits)
    amount_predicted <- amount_predicted %>%
      left_join(
        rank_predicted %>% select(revision_case_id, rank_priority_score),
        by = "revision_case_id"
      )
    priority_variable <- "rank_priority_score"
  } else {
    rank_predicted <- NULL
    priority_variable <- "amount_yhatrf"
  }

  optimized <- optimize_selection(
    df = amount_predicted,
    type = type,
    priority_variable = priority_variable
  )

  table_values <- summarize_table_row(optimized, type = type) %>%
    mutate(
      scenario_id = scenario_id,
      scenario_label = scenario_label,
      selection_method = selection_method,
      audit_type = audit_label(type),
      .before = 1
    )

  diagnostics <- optimized %>%
    summarize(
      scenario_id = scenario_id,
      scenario_label = scenario_label,
      selection_method = selection_method,
      audit_type = audit_label(type),
      training_rows_amount = sum(y2 == 1 & !is.na(y4)),
      selected_rows_2018_2019 = n(),
      executed_rows_2018_2019 = sum(y2controle, na.rm = TRUE),
      optimized_rows_2018_2019 = sum(optimized_all, na.rm = TRUE),
      overlap_rows_2018_2019 = sum(overlap_unit, na.rm = TRUE),
      rows_2020_in_table = sum(selectionyear == 2020, na.rm = TRUE),
      .groups = "drop"
    )

  list(table_values = table_values, diagnostics = diagnostics, rank_export = rank_predicted)
}

scenario_grid <- tribble(
  ~scenario_id, ~scenario_label, ~panel, ~exclude_top_realized, ~weighted_revenue_prediction, ~use_detection_gate, ~selection_method,
  "A1", "Current weighted two-step amount prediction, all cases", "Panel A: Optimized selection ranked by predicted amount", FALSE, TRUE, TRUE, "amount",
  "A2", "Weighted two-step amount prediction, excluding top five realized cases", "Panel A: Optimized selection ranked by predicted amount", TRUE, TRUE, TRUE, "amount",
  "A3", "Unweighted one-step amount prediction, excluding top five realized cases", "Panel A: Optimized selection ranked by predicted amount", TRUE, FALSE, FALSE, "amount",
  "B1", "Rank-based optimized selection, amounts from A1", "Panel B: Optimized selection ranked by predicted rank", FALSE, TRUE, TRUE, "rank",
  "B2", "Rank-based optimized selection, amounts from A2", "Panel B: Optimized selection ranked by predicted rank", TRUE, TRUE, TRUE, "rank",
  "B3", "Rank-based optimized selection, amounts from A3", "Panel B: Optimized selection ranked by predicted rank", TRUE, FALSE, FALSE, "rank"
)

data_audits <- read_dta(
  file.path(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta")
)

scenario_outputs <- list()
diagnostics_outputs <- list()
output_index <- 1

for (scenario_row in seq_len(nrow(scenario_grid))) {
  for (type in c(2, 1)) {
    result <- build_scenario_type(
      data_audits = data_audits,
      type = type,
      scenario_id = scenario_grid$scenario_id[scenario_row],
      scenario_label = scenario_grid$scenario_label[scenario_row],
      exclude_top_realized = scenario_grid$exclude_top_realized[scenario_row],
      weighted_revenue_prediction = scenario_grid$weighted_revenue_prediction[scenario_row],
      use_detection_gate = scenario_grid$use_detection_gate[scenario_row],
      selection_method = scenario_grid$selection_method[scenario_row]
    )

    scenario_outputs[[output_index]] <- result$table_values %>%
      mutate(panel = scenario_grid$panel[scenario_row], .after = scenario_label)

    diagnostics_outputs[[output_index]] <- result$diagnostics

    if (type == 2 && scenario_grid$scenario_id[scenario_row] == "B1") {
      write_dta(result$rank_export, rank_export_b1_file)
      message("Wrote ", rank_export_b1_file)
    }

    if (type == 2 && scenario_grid$scenario_id[scenario_row] == "B2") {
      write_dta(result$rank_export, rank_export_b2b3_file)
      message("Wrote ", rank_export_b2b3_file)
    }

    output_index <- output_index + 1
  }
}

results_table <- bind_rows(scenario_outputs) %>%
  mutate(
    audit_type = factor(audit_type, levels = c("Full Audits", "Desk Audits")),
    scenario_id = factor(scenario_id, levels = scenario_grid$scenario_id)
  ) %>%
  arrange(scenario_id, audit_type)

diagnostics_table <- bind_rows(diagnostics_outputs) %>%
  mutate(
    audit_type = factor(audit_type, levels = c("Full Audits", "Desk Audits")),
    scenario_id = factor(scenario_id, levels = scenario_grid$scenario_id)
  ) %>%
  arrange(scenario_id, audit_type)

write.csv(diagnostics_table, diagnostics_output_file, row.names = FALSE)

expected_a1 <- tribble(
  ~audit_type, ~realized_log_mean, ~predicted_log_mean, ~revenue_gain, ~overlap_share,
  "Full Audits", 21.24, 21.14, 18.09, 0.65,
  "Desk Audits", 19.00, 18.73, 31.01, 0.61
)

a1_check <- results_table %>%
  filter(scenario_id == "A1") %>%
  transmute(
    audit_type = as.character(audit_type),
    realized_log_mean = round(realized_log_mean, 2),
    predicted_log_mean = round(predicted_log_mean, 2),
    revenue_gain = round(revenue_gain, 2),
    overlap_share = round(overlap_share, 2)
  ) %>%
  left_join(expected_a1, by = "audit_type", suffix = c("_actual", "_expected")) %>%
  mutate(
    reproduces_current =
      realized_log_mean_actual == realized_log_mean_expected &
        predicted_log_mean_actual == predicted_log_mean_expected &
        revenue_gain_actual == revenue_gain_expected &
        overlap_share_actual == overlap_share_expected
  )

if (all(a1_check$reproduces_current)) {
  message("A1 validation passed: current Table 9 values are reproduced.")
} else {
  warning("A1 validation did not exactly reproduce the current Table 9 values. Inspect diagnostics.")
}

latex_header <- c(
  "\\begin{tabular}[t]{lcccccc}",
  "\\toprule",
  " & \\multicolumn{4}{c}{\\textbf{Panel A: Optimized selection by predicted evasion}} & \\multicolumn{2}{c}{\\textbf{Panel B: Optimized selection by predicted rank}}\\\\",
  "\\cmidrule(l{3pt}r{3pt}){2-5} \\cmidrule(l{3pt}r{3pt}){6-7}",
  " & \\multicolumn{1}{c}{\\shortstack{Realized\\\\Revenue\\\\Log(mean)}} & \\multicolumn{1}{c}{\\shortstack{Predicted\\\\Revenue\\\\Log(mean)}} & \\multicolumn{1}{c}{\\shortstack{$\\Delta$ Revenue vs Predicted\\\\w/ RF Selection\\\\Among Program Cases}} & \\multicolumn{1}{c}{\\shortstack{Overlap Between\\\\Optimized and\\\\Realized Audit Program}} & \\multicolumn{1}{c}{\\shortstack{$\\Delta$ Revenue vs Predicted\\\\w/ RF Selection\\\\Among Program Cases}} & \\multicolumn{1}{c}{\\shortstack{Overlap Between\\\\Optimized and\\\\Realized Audit Program}}\\\\",
  "\\cmidrule(l{3pt}r{3pt}){2-2} \\cmidrule(l{3pt}r{3pt}){3-3} \\cmidrule(l{3pt}r{3pt}){4-4} \\cmidrule(l{3pt}r{3pt}){5-5} \\cmidrule(l{3pt}r{3pt}){6-6} \\cmidrule(l{3pt}r{3pt}){7-7}",
  " & (1) & (2) & (3) & (4) & (5) & (6)\\\\",
  "\\midrule"
)

scenario_pairs <- tribble(
  ~amount_id, ~rank_id, ~amount_label, ~rank_label,
  "A1", "B1", "A1: Current weighted two-step amount prediction, all cases", "B1: Predicted-rank selection, valued with A1 amount prediction",
  "A2", "B2", "A2: Weighted two-step amount prediction, excluding top five realized cases", "B2: Predicted-rank selection, valued with A2 amount prediction",
  "A3", "B3", "A3: Unweighted one-step amount prediction, excluding top five realized cases", "B3: Predicted-rank selection, valued with A3 amount prediction"
)

latex_rows <- c()

for (scenario_row in seq_len(nrow(scenario_pairs))) {
  amount_id <- scenario_pairs$amount_id[scenario_row]
  rank_id <- scenario_pairs$rank_id[scenario_row]

  amount_data <- results_table %>%
    filter(.data$scenario_id == .env$amount_id) %>%
    transmute(
      audit_type = as.character(.data$audit_type),
      realized_log_mean = .data$realized_log_mean,
      predicted_log_mean = .data$predicted_log_mean,
      amount_gain = .data$revenue_gain,
      amount_overlap = .data$overlap_share
    )

  rank_data <- results_table %>%
    filter(.data$scenario_id == .env$rank_id) %>%
    transmute(
      audit_type = as.character(.data$audit_type),
      rank_gain = .data$revenue_gain,
      rank_overlap = .data$overlap_share
    )

  scenario_data <- amount_data %>%
    left_join(rank_data, by = "audit_type") %>%
    arrange(factor(.data$audit_type, levels = c("Full Audits", "Desk Audits")))

  latex_rows <- c(
    latex_rows,
    "\\addlinespace[0.45em]",
    paste0(
      "\\multicolumn{5}{l}{\\textit{", scenario_pairs$amount_label[scenario_row], "}} & ",
      "\\multicolumn{2}{l}{\\textit{", scenario_pairs$rank_label[scenario_row], "}}\\\\"
    )
  )

  for (table_row in seq_len(nrow(scenario_data))) {
    latex_rows <- c(
      latex_rows,
      paste0(
        "\\hspace{1em}", scenario_data$audit_type[table_row], " & ",
        format_number(scenario_data$realized_log_mean[table_row]), " & ",
        format_number(scenario_data$predicted_log_mean[table_row]), " & ",
        format_gain(scenario_data$amount_gain[table_row]), " & ",
        format_share(scenario_data$amount_overlap[table_row]), " & ",
        format_gain(scenario_data$rank_gain[table_row]), " & ",
        format_share(scenario_data$rank_overlap[table_row]), "\\\\"
      )
    )
  }
}

latex_footer <- c(
  "\\bottomrule",
  "\\end{tabular}"
)

writeLines(
  c(latex_header, latex_rows, latex_footer),
  table_output_file
)

message("Wrote ", table_output_file)
message("Wrote ", diagnostics_output_file)
