###########
# RF optimization gains bin-target companion table
###########
# This standalone companion preserves 07_Optimization_Exercise_Unweighted_Top5_Revision.R.
# It rebuilds the amount-prediction Panel A benchmarks and adds a Panel C
# that ranks optimized selections by a one-step high-evasion-bin classifier.

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
if (exists("output_path")) {
  revision_output_path <- output_path
} else if (dir.exists(project_root)) {
  revision_output_path <- file.path(project_root, "Output")
} else {
  revision_output_path <- "Output"
}

dir.create(revision_output_path, showWarnings = FALSE, recursive = TRUE)

table_output_file <- file.path(
  revision_output_path,
  "table_opt_full_and_desk_bin_target_panelc.tex"
)

diagnostics_output_file <- file.path(
  revision_output_path,
  "table_opt_full_and_desk_bin_target_panelc_diagnostics.csv"
)

support_output_file <- file.path(
  revision_output_path,
  "table_opt_full_and_desk_bin_target_support.tex"
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

target_bin_count <- 4
minimum_cases_per_bin <- 2

format_number <- function(x) {
  sprintf("%.2f", round(x, 2))
}

format_gain <- function(x) {
  paste0(ifelse(x >= 0, "+ ", "- "), sprintf("%.2f", abs(x)), "\\%")
}

format_share <- function(x) {
  paste0(sprintf("%.0f", 100 * x), "\\%")
}

format_integer <- function(x) {
  ifelse(is.na(x), "--", as.character(as.integer(x)))
}

bin_label <- function(bin_count) {
  case_when(
    bin_count == 10 ~ "Deciles",
    bin_count == 5 ~ "Quintiles",
    bin_count == 4 ~ "Quartiles",
    bin_count == 3 ~ "Terciles",
    bin_count == 2 ~ "Halves",
    TRUE ~ paste0(bin_count, " bins")
  )
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

choose_support_safe_bin_count <- function(audits) {
  training_list_counts <- audits %>%
    filter(y2 == 1 & !is.na(y4)) %>%
    count(controle, bureau_detailed, selectionyear, name = "executed_observed_cases")

  if (nrow(training_list_counts) == 0) {
    stop("No executed observed cases are available for bin-target training.")
  }

  minimum_supported_cases <- minimum_cases_per_bin * target_bin_count

  supportable_lists <- training_list_counts %>%
    filter(executed_observed_cases >= minimum_supported_cases)

  unsupported_lists <- training_list_counts %>%
    filter(executed_observed_cases < minimum_supported_cases)

  if (nrow(supportable_lists) == 0) {
    stop("No training lists satisfy the minimum support rule for quartiles.")
  }

  list(
    selected_bin_count = target_bin_count,
    supportable_lists = supportable_lists,
    unsupported_lists = unsupported_lists,
    all_training_lists = training_list_counts
  )
}

assign_realized_bins <- function(audits, support_choice) {
  selected_bin_count <- support_choice$selected_bin_count

  target_rows <- audits %>%
    filter(y2 == 1 & !is.na(y4)) %>%
    inner_join(
      support_choice$supportable_lists %>% select(controle, bureau_detailed, selectionyear),
      by = c("controle", "bureau_detailed", "selectionyear")
    ) %>%
    group_by(controle, bureau_detailed, selectionyear) %>%
    arrange(desc(y4), revision_case_id, .by_group = TRUE) %>%
    mutate(
      bin_position = row_number(),
      bin_list_n = n(),
      realized_high_evasion_bin = ceiling(bin_position * selected_bin_count / bin_list_n),
      high_evasion_bin = ifelse(realized_high_evasion_bin == 1, 1, 0)
    ) %>%
    ungroup()

  bin_support <- target_rows %>%
    count(controle, bureau_detailed, selectionyear, realized_high_evasion_bin, name = "cases_per_bin")

  support_summary <- tibble(
    selected_bin_count = selected_bin_count,
    selected_bin_label = bin_label(selected_bin_count),
    bin_selection_rule = paste0("Fixed ", bin_label(selected_bin_count)),
    minimum_cases_per_bin_rule = minimum_cases_per_bin,
    total_training_lists = nrow(support_choice$all_training_lists),
    supportable_training_lists = nrow(support_choice$supportable_lists),
    unsupported_training_lists = nrow(support_choice$unsupported_lists),
    min_executed_observed_cases_list = min(support_choice$all_training_lists$executed_observed_cases, na.rm = TRUE),
    max_executed_observed_cases_list = max(support_choice$all_training_lists$executed_observed_cases, na.rm = TRUE),
    min_cases_per_bin = min(bin_support$cases_per_bin, na.rm = TRUE),
    max_cases_per_bin = max(bin_support$cases_per_bin, na.rm = TRUE),
    singleton_bins = sum(bin_support$cases_per_bin == 1, na.rm = TRUE),
    empty_bins = sum(
      support_choice$supportable_lists$executed_observed_cases * 0 + selected_bin_count
    ) - nrow(bin_support),
    bin_training_rows = nrow(target_rows),
    high_bin_rows = sum(target_rows$high_evasion_bin == 1, na.rm = TRUE)
  )

  list(
    target_rows = target_rows,
    bin_support = bin_support,
    support_summary = support_summary
  )
}

run_bin_rf <- function(df, target_variable = "high_evasion_bin") {
  formula <- as.formula(paste("as.factor(", target_variable, ") ~ ", rf_predictors))

  set.seed(10222024)
  randomForest(
    formula = formula,
    data = df %>% filter(!is.na(.data[[target_variable]])),
    keep.inbag = TRUE
  )
}

build_bin_predictions <- function(audits) {
  message("  Training one-step high-evasion-bin prediction.")

  support_choice <- choose_support_safe_bin_count(audits)
  bin_target <- assign_realized_bins(audits, support_choice)

  bin_training <- bin_target$target_rows %>%
    select(revision_case_id, high_evasion_bin) %>%
    left_join(audits, by = "revision_case_id")

  if (n_distinct(bin_training$high_evasion_bin) < 2) {
    stop("High-evasion-bin target has fewer than two classes.")
  }

  bin_rf <- run_bin_rf(bin_training)
  bin_probability <- as.numeric(predict(bin_rf, audits, type = "prob")[, "1"])

  bin_predicted <- audits %>%
    mutate(
      bin_high_probability = bin_probability,
      bin_priority_score = bin_high_probability
    ) %>%
    left_join(
      bin_target$target_rows %>%
        select(
          revision_case_id,
          realized_high_evasion_bin,
          high_evasion_bin,
          bin_list_n
        ),
      by = "revision_case_id"
    )

  list(
    predictions = bin_predicted,
    support_summary = bin_target$support_summary,
    bin_support = bin_target$bin_support
  )
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

summarize_diagnostics <- function(
    optimized,
    type,
    scenario_id,
    scenario_label,
    selection_method,
    support_summary = NULL
) {
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
      panel_c_uses_amount_yhatrf = selection_method == "bin",
      .groups = "drop"
    )

  if (is.null(support_summary)) {
    diagnostics <- diagnostics %>%
      mutate(
        selected_bin_count = NA_integer_,
        selected_bin_label = NA_character_,
        bin_selection_rule = NA_character_,
        minimum_cases_per_bin_rule = NA_integer_,
        total_training_lists = NA_integer_,
        supportable_training_lists = NA_integer_,
        unsupported_training_lists = NA_integer_,
        min_cases_per_bin = NA_integer_,
        max_cases_per_bin = NA_integer_,
        singleton_bins = NA_integer_,
        empty_bins = NA_integer_,
        bin_training_rows = NA_integer_,
        high_bin_rows = NA_integer_
      )
  } else {
    diagnostics <- bind_cols(diagnostics, support_summary)
  }

  diagnostics
}

build_scenario_pair <- function(
    data_audits,
    type,
    amount_id,
    amount_label,
    bin_id,
    bin_label_text,
    exclude_top_realized,
    weighted_revenue_prediction,
    use_detection_gate
) {
  message("Building ", amount_id, "/", bin_id, " for ", audit_label(type), ".")

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

  amount_optimized <- optimize_selection(
    df = amount_predicted,
    type = type,
    priority_variable = "amount_yhatrf"
  )

  amount_table_values <- summarize_table_row(amount_optimized, type = type) %>%
    mutate(
      scenario_id = amount_id,
      scenario_label = amount_label,
      selection_method = "amount",
      audit_type = audit_label(type),
      .before = 1
    )

  amount_diagnostics <- summarize_diagnostics(
    optimized = amount_optimized,
    type = type,
    scenario_id = amount_id,
    scenario_label = amount_label,
    selection_method = "amount"
  )

  bin_result <- build_bin_predictions(audits)

  bin_amount_predicted <- amount_predicted %>%
    left_join(
      bin_result$predictions %>%
        select(
          revision_case_id,
          bin_high_probability,
          bin_priority_score,
          realized_high_evasion_bin,
          high_evasion_bin,
          bin_list_n
        ),
      by = "revision_case_id"
    )

  bin_optimized <- optimize_selection(
    df = bin_amount_predicted,
    type = type,
    priority_variable = "bin_priority_score"
  )

  bin_table_values <- summarize_table_row(bin_optimized, type = type) %>%
    mutate(
      scenario_id = bin_id,
      scenario_label = bin_label_text,
      selection_method = "bin",
      audit_type = audit_label(type),
      .before = 1
    )

  bin_diagnostics <- summarize_diagnostics(
    optimized = bin_optimized,
    type = type,
    scenario_id = bin_id,
    scenario_label = bin_label_text,
    selection_method = "bin",
    support_summary = bin_result$support_summary
  )

  bin_support <- bin_result$support_summary %>%
    mutate(
      scenario_id = bin_id,
      scenario_label = bin_label_text,
      audit_type = audit_label(type),
      .before = 1
    )

  list(
    table_values = bind_rows(amount_table_values, bin_table_values),
    diagnostics = bind_rows(amount_diagnostics, bin_diagnostics),
    support = bin_support
  )
}

scenario_pairs <- tribble(
  ~amount_id, ~bin_id, ~amount_label, ~bin_label_text, ~exclude_top_realized, ~weighted_revenue_prediction, ~use_detection_gate,
  "A1", "C1", "A1: Current weighted two-step amount prediction, all cases", "C1: Direct quartile-target selection, valued with A1 amount prediction", FALSE, TRUE, TRUE,
  "A2", "C2", "A2: Weighted two-step amount prediction, excluding top five realized cases", "C2: Direct quartile-target selection, valued with A2 amount prediction", TRUE, TRUE, TRUE,
  "A3", "C3", "A3: Unweighted one-step amount prediction, excluding top five realized cases", "C3: Direct quartile-target selection, valued with A3 amount prediction", TRUE, FALSE, FALSE
)

data_audits <- read_dta(
  file.path(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta")
)

scenario_outputs <- list()
diagnostics_outputs <- list()
support_outputs <- list()
output_index <- 1

for (scenario_row in seq_len(nrow(scenario_pairs))) {
  for (type in c(2, 1)) {
    result <- build_scenario_pair(
      data_audits = data_audits,
      type = type,
      amount_id = scenario_pairs$amount_id[scenario_row],
      amount_label = scenario_pairs$amount_label[scenario_row],
      bin_id = scenario_pairs$bin_id[scenario_row],
      bin_label_text = scenario_pairs$bin_label_text[scenario_row],
      exclude_top_realized = scenario_pairs$exclude_top_realized[scenario_row],
      weighted_revenue_prediction = scenario_pairs$weighted_revenue_prediction[scenario_row],
      use_detection_gate = scenario_pairs$use_detection_gate[scenario_row]
    )

    scenario_outputs[[output_index]] <- result$table_values
    diagnostics_outputs[[output_index]] <- result$diagnostics
    support_outputs[[output_index]] <- result$support
    output_index <- output_index + 1
  }
}

scenario_levels <- c(scenario_pairs$amount_id, scenario_pairs$bin_id)

results_table <- bind_rows(scenario_outputs) %>%
  mutate(
    audit_type = factor(audit_type, levels = c("Full Audits", "Desk Audits")),
    scenario_id = factor(scenario_id, levels = scenario_levels)
  ) %>%
  arrange(scenario_id, audit_type)

diagnostics_table <- bind_rows(diagnostics_outputs) %>%
  mutate(
    audit_type = factor(audit_type, levels = c("Full Audits", "Desk Audits")),
    scenario_id = factor(scenario_id, levels = scenario_levels)
  ) %>%
  arrange(scenario_id, audit_type)

support_table <- bind_rows(support_outputs) %>%
  mutate(
    audit_type = factor(audit_type, levels = c("Full Audits", "Desk Audits")),
    scenario_id = factor(scenario_id, levels = scenario_pairs$bin_id)
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
  " & \\multicolumn{4}{c}{\\textbf{Panel A: Optimized selection by predicted evasion}} & \\multicolumn{2}{c}{\\textbf{Panel C: Optimized selection by predicted high-bin probability}}\\\\",
  "\\cmidrule(l{3pt}r{3pt}){2-5} \\cmidrule(l{3pt}r{3pt}){6-7}",
  " & \\multicolumn{1}{c}{\\shortstack{Realized\\\\Revenue\\\\Log(mean)}} & \\multicolumn{1}{c}{\\shortstack{Predicted\\\\Revenue\\\\Log(mean)}} & \\multicolumn{1}{c}{\\shortstack{$\\Delta$ Revenue vs Predicted\\\\w/ RF Selection\\\\Among Program Cases}} & \\multicolumn{1}{c}{\\shortstack{Overlap Between\\\\Optimized and\\\\Realized Audit Program}} & \\multicolumn{1}{c}{\\shortstack{$\\Delta$ Revenue vs Predicted\\\\w/ Bin-Probability Selection\\\\Among Program Cases}} & \\multicolumn{1}{c}{\\shortstack{Overlap Between\\\\Optimized and\\\\Realized Audit Program}}\\\\",
  "\\cmidrule(l{3pt}r{3pt}){2-2} \\cmidrule(l{3pt}r{3pt}){3-3} \\cmidrule(l{3pt}r{3pt}){4-4} \\cmidrule(l{3pt}r{3pt}){5-5} \\cmidrule(l{3pt}r{3pt}){6-6} \\cmidrule(l{3pt}r{3pt}){7-7}",
  " & (1) & (2) & (3) & (4) & (5) & (6)\\\\",
  "\\midrule"
)

latex_rows <- c()

for (scenario_row in seq_len(nrow(scenario_pairs))) {
  amount_id <- scenario_pairs$amount_id[scenario_row]
  bin_id <- scenario_pairs$bin_id[scenario_row]

  amount_data <- results_table %>%
    filter(.data$scenario_id == .env$amount_id) %>%
    transmute(
      audit_type = as.character(.data$audit_type),
      realized_log_mean = .data$realized_log_mean,
      predicted_log_mean = .data$predicted_log_mean,
      amount_gain = .data$revenue_gain,
      amount_overlap = .data$overlap_share
    )

  bin_data <- results_table %>%
    filter(.data$scenario_id == .env$bin_id) %>%
    transmute(
      audit_type = as.character(.data$audit_type),
      bin_gain = .data$revenue_gain,
      bin_overlap = .data$overlap_share
    )

  scenario_data <- amount_data %>%
    left_join(bin_data, by = "audit_type") %>%
    arrange(factor(.data$audit_type, levels = c("Full Audits", "Desk Audits")))

  latex_rows <- c(
    latex_rows,
    "\\addlinespace[0.45em]",
    paste0(
      "\\multicolumn{5}{l}{\\textit{", scenario_pairs$amount_label[scenario_row], "}} & ",
      "\\multicolumn{2}{l}{\\textit{", scenario_pairs$bin_label_text[scenario_row], "}}\\\\"
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
        format_gain(scenario_data$bin_gain[table_row]), " & ",
        format_share(scenario_data$bin_overlap[table_row]), "\\\\"
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

support_latex_header <- c(
  "\\begin{tabular}[t]{lllrrrrrr}",
  "\\toprule",
  "Scenario & Audit type & Target bins & Total lists & Supported lists & Unsupported lists & Min cases/bin & Max cases/bin & High-bin rows\\\\",
  "\\midrule"
)

support_latex_rows <- support_table %>%
  mutate(
    latex_row = paste0(
      as.character(scenario_id), " & ",
      as.character(audit_type), " & ",
      selected_bin_label, " & ",
      format_integer(total_training_lists), " & ",
      format_integer(supportable_training_lists), " & ",
      format_integer(unsupported_training_lists), " & ",
      format_integer(min_cases_per_bin), " & ",
      format_integer(max_cases_per_bin), " & ",
      format_integer(high_bin_rows), "\\\\"
    )
  ) %>%
  pull(latex_row)

support_latex_footer <- c(
  "\\bottomrule",
  "\\end{tabular}"
)

writeLines(
  c(support_latex_header, support_latex_rows, support_latex_footer),
  support_output_file
)

message("Wrote ", table_output_file)
message("Wrote ", diagnostics_output_file)
message("Wrote ", support_output_file)
