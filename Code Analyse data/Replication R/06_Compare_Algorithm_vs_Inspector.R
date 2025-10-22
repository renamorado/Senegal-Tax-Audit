# Descarregar o pacote plyr
if ("package:plyr" %in% search()) {
  detach("package:plyr", unload = TRUE, character.only = TRUE)
}

# Descarregar o pacote dplyr
if ("package:dplyr" %in% search()) {
  detach("package:dplyr", unload = TRUE, character.only = TRUE)
}

library(dplyr)


predict_rf <- function(rf, data){
  
  # Predict values
  predicted_values <- predict(rf, data)
  
  # Create column for predicted errors and estimated values
  data <- data %>% mutate(yhatrf = predicted_values)
  
  return(data)
  
}

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


# Open data
data_audits = read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

fullaudits = data_audits[data_audits$controle == 2,]

fullaudits <- fullaudits %>%
  filter(safeties != 1 & selection == 1)

fullaudits_realized <- fullaudits %>% filter(y2 == 1 & !is.na(y4))

rf <- run_rf(fullaudits_realized)

calc_bin_stats <- function(data, min_v, max_v) {
  data %>%
    mutate(
      bin = cut(
        yhatrf,
        breaks = seq(min_v, max_v + 0.5, by = 1), # bins of width 1
        include.lowest = TRUE,
        right = FALSE
      ),
      mid_bin = as.numeric(sub("\\[(\\d+\\.?\\d*),.*", "\\1", bin)) + 0.5
    ) %>%
    group_by(bin, mid_bin) %>%
    summarise(
      # Mean of y2 (proportion of 1's if y2 is binary)
      prob   = mean(y2, na.rm = TRUE),
      
      # Sample variance of y2 within the bin
      var_y2 = var(y2, na.rm = TRUE),
      
      # Number of observations in this bin
      n = n(),
      .groups = "drop"
    ) %>%
    ungroup() %>%
    # -------------------------------------------------
  # ADD distribution percentage (i.e., how big this bin is 
  # compared to the entire subset 'data')
  mutate(distribution_percent = (n / sum(n)) * 100) %>%
    # -------------------------------------------------
  mutate(
    # Standard error of the mean in the bin
    se = sqrt(var_y2 / n),
    
    # Normal-approx 95% CI
    ci_lower = prob - 1.96 * se,
    ci_upper = prob + 1.96 * se,
    
    # Clamp to [0, 1]
    ci_lower = pmax(ci_lower, 0),
    ci_upper = pmin(ci_upper, 1),
    
    # Convert main stats to percentages for plotting
    prob_percent      = prob      * 100,
    ci_lower_percent = ci_lower * 100,
    ci_upper_percent = ci_upper * 100
  ) %>%
    filter(mid_bin > 12)
}

fullaudits_predicted <- predict_rf(rf, fullaudits)

# 2) Define your overall min_v and max_v from the entire data
min_v <- floor(min(fullaudits_predicted$yhatrf, na.rm = TRUE))
max_v <- ceiling(max(fullaudits_predicted$yhatrf, na.rm = TRUE))

# 3) Apply the function to each subset: algorithm == 1 and dgid == 1
df_algorithm <- calc_bin_stats(
  data  = fullaudits_predicted %>% filter(algorithm == 1),
  min_v = min_v,
  max_v = max_v
) %>%
  mutate(Group = "algorithm")
df_dgid <- calc_bin_stats(
  data  = fullaudits_predicted %>% filter(dgid == 1),
  min_v = min_v,
  max_v = max_v
) %>%
  mutate(Group = "dgid")

final_plot <- ggplot() +
  
  # 1) Shaded area for the ALGORITHM subset
  geom_area(
    data = df_algorithm,
    aes(
      x = mid_bin, 
      y = distribution_percent, 
      fill = "Algorithm Cases Distribution"  # MATCHES scale_fill_manual
    ),
    alpha = 0.4
  ) +
  
  # 2) Shaded area for the DGID subset
  geom_area(
    data = df_dgid,
    aes(
      x = mid_bin, 
      y = distribution_percent, 
      fill = "Inspector Cases Distribution"  # MATCHES scale_fill_manual
    ),
    alpha = 0.7
  ) +
  
  
  
  # 3) Probability line for the ALGORITHM subset
  geom_line(
    data = df_algorithm,
    aes(
      x = mid_bin, 
      y = prob_percent, 
      color = "Algorithm Cases P(execution|predicted evasion)"  # MATCHES scale_color_manual
    ),
    size = 1,
    linetype = "solid"
  ) +
  
  # --- ADD THE CONFIDENCE INTERVAL (CI) BAND ---
  geom_ribbon(
    data = df_algorithm,
    aes(x = mid_bin, ymin = ci_lower_percent, ymax = ci_upper_percent,
        fill = "Algorithm Cases Distribution"),
    alpha = 0.2,       # transparency
    show.legend = FALSE
  ) +
  
  # 4) Probability line for the DGID subset
  geom_line(
    data = df_dgid,
    aes(
      x = mid_bin, 
      y = prob_percent, 
      color = "Inspector Cases P(execution|predicted evasion)"  # MATCHES scale_color_manual
    ),
    size = 1,
    linetype = "solid"
  ) +
  
  geom_ribbon(
    data = df_dgid,
    aes(x = mid_bin, ymin = ci_lower_percent, ymax = ci_upper_percent,
        fill = "Inspector Cases Distribution"),
    alpha = 0.4,       # transparency
    show.legend = FALSE
  ) +
  
  # ----- MANUAL FILL SCALE (for shaded areas) -----
scale_fill_manual(
  name = "",  # legend title (blank)
  values = c(
    # Must match the exact strings used in aes(fill=...)
    "Algorithm Cases Distribution"  = "#9E0142",
    "Inspector Cases Distribution"  = "orange"
  )
) +
  
  # ----- MANUAL COLOR SCALE (for lines) -----
scale_color_manual(
  name = "",  # legend title (blank)
  values = c(
    # Must match the exact strings used in aes(color=...)
    "Algorithm Cases P(execution|predicted evasion)" = "#9E0142",
    "Inspector Cases P(execution|predicted evasion)" = "orange"
  )
) +
  
  labs(
    x = "Evasion (log FCFA)",
    y = "Percentage (%)"
  ) +
  theme_minimal() +
  theme(
    legend.position  = "bottom",
    legend.direction = "horizontal",
    legend.title      = element_text(size = 12),
    legend.text       = element_text(size = 15),
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
    axis.text    = element_text(size = 12),
  ) +
  
  # Organizar a legenda em 2 colunas (opcional)
  guides(
    fill  = guide_legend(nrow = 2),
    color = guide_legend(nrow = 2),
  )

print(final_plot)

# Save graph
ggsave(paste0(output_path, "10 density Algorithm vs Inspector R", ".png"), plot = final_plot, width = 8.8, height = 6.6, dpi = 300, bg = "white")


