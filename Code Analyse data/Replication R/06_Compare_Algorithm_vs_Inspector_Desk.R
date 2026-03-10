# Descarregar o pacote plyr
if ("package:plyr" %in% search()) {
  detach("package:plyr", unload = TRUE, character.only = TRUE)
}

# Descarregar o pacote dplyr
#if ("package:dplyr" %in% search()) {
#  detach("package:dplyr", unload = TRUE, character.only = TRUE)
#}

library(dplyr)

# Function to predict values using Random Forest
predict_rf <- function(rf, data) {
  predicted_values <- predict(rf, data)
  data <- data %>% mutate(yhatrf = predicted_values)
  return(data)
}

# Function to process RF
run_rf <- function(df, target_variable = "y4") {
  
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
  
  set.seed(10222024)
  rf <- randomForest(
    formula = formula,
    data = df %>% filter(y2 == 1 & !is.na(y4)),
    keep.inbag = TRUE
  )
  
  return(rf)
}

# Load data
data_audits <- read_dta(
  paste0(data_path, "datasetforanalysis_predictionexercise_for_all_logs_exercise.dta"))

fullaudits <- data_audits %>%
  filter(controle == 1 & safeties != 1 & selection == 1)

fullaudits_realized <- fullaudits %>% filter(y2 == 1 & !is.na(y4))

# Train RF model
rf <- run_rf(fullaudits_realized)


# Apply predictions



fullaudits_predicted2 <- predict_rf(rf, fullaudits) #%>%
write_dta(fullaudits_predicted2, "Working Data/deskaudits_predicted.dta")

fullaudits_predicted <- predict_rf(rf, fullaudits) %>%
  filter(yhatrf > 10)
# Define min and max values
min_v <- floor(min(fullaudits_predicted$yhatrf, na.rm = TRUE))
max_v <- ceiling(max(fullaudits_predicted$yhatrf, na.rm = TRUE))

# Function to calculate bin statistics with quintile-based probability calculation
calc_bin_stats_quintiles <- function(data, min_v, max_v) {
  data <- data %>%
    
    mutate(
      # Binning simples, de 1 em 1
      bin = cut(
        yhatrf,
        breaks = seq(min_v, max_v + 0.5, by = 1),
        include.lowest = TRUE,
        right = FALSE),
      # Extract the lower bound from the factor levels
      bin_low = as.numeric(str_extract(bin, "(?<=\\[|\\().*?(?=,)")),
      # Extract the upper bound from the factor levels
      bin_high = as.numeric(str_extract(bin, "(?<=,).*?(?=\\]|\\))")),
      # Calculate the midpoint of each bin
      mid_bin = (bin_low + bin_high) / 2,
      
      # Binning por quantis (0%, 10%, 20%, ..., 100%)
      bin_quintile = cut(
        yhatrf,
        breaks = unique(quantile(yhatrf, probs = seq(0, 1, by = 0.2))),
        include.lowest = TRUE,
        right = FALSE
      )
    ) %>%
    # Extrair min e max dos intervalos (quintile)
    mutate(
      # Extract the lower bound from the factor levels
      bin_low_quintile = as.numeric(str_extract(bin_quintile, "(?<=\\[|\\().*?(?=,)")),
      # Extract the upper bound from the factor levels
      bin_high_quintile = as.numeric(str_extract(bin_quintile, "(?<=,).*?(?=\\]|\\))")),
      # Calculate the midpoint of each bin
      mid_bin_quintile = (bin_low_quintile + bin_high_quintile) / 2)
  
  
  tab <- data %>% 
    # Calculate distribution statistics
    group_by(bin, mid_bin) %>%
    summarise(
      distribution_percent = (n() / nrow(data)) * 100,
      .groups = "drop"
    ) %>%
    mutate(type = "general")
  
  tab2 <- data %>% 
    # Calculate distribution statistics
        group_by(bin_quintile) %>%
        summarise(
          prob = mean(y2, na.rm = TRUE),
          var_y2 = var(y2, na.rm = TRUE),
          n = n(),
          .groups = "drop"
        ) %>%
        mutate(
          se = sqrt(var_y2 / n),
          ci_lower = pmax(prob - 1.96 * se, 0),
          ci_upper = pmin(prob + 1.96 * se, 1),
          prob_percent = prob * 100,
          ci_lower_percent = ci_lower * 100,
          ci_upper_percent = ci_upper * 100
        ) %>%
    mutate(
      # Extract the lower bound from the factor levels
      bin_low_quintile = as.numeric(str_extract(bin_quintile, "(?<=\\[|\\().*?(?=,)")),
      # Extract the upper bound from the factor levels
      bin_high_quintile = as.numeric(str_extract(bin_quintile, "(?<=,).*?(?=\\]|\\))")),
      # Calculate the midpoint of each bin
      mid_bin_quintile = (bin_low_quintile + bin_high_quintile) / 2,
      type = "quintile"
    )

  
  tab <- bind_rows(tab, tab2)
}

# Apply the function to subsets
df_algorithm <- calc_bin_stats_quintiles(
  data  = fullaudits_predicted %>% filter(algorithm == 1),
  min_v = min_v,
  max_v = max_v
) %>%
  mutate(Group = "algorithm") 

df_dgid <- calc_bin_stats_quintiles(
  data  = fullaudits_predicted %>% filter(dgid == 1),
  min_v = min_v,
  max_v = max_v
) %>%
  mutate(Group = "dgid")

# Plot results
final_plot <- ggplot() +
  
  geom_area(
    data = df_algorithm,
    aes(x = mid_bin, y = distribution_percent, fill = "Algorithm Cases Distribution"),
    alpha = 0.4
  ) +
  
  geom_area(
    data = df_dgid,
    aes(x = mid_bin, y = distribution_percent, fill = "Inspector Cases Distribution"),
    alpha = 0.7
  ) +
  
  geom_line(
    data = df_algorithm,
    aes(x = mid_bin_quintile, y = prob_percent, color = "Algorithm Cases P(execution|predicted evasion)"),
    size = 1,
    linetype = "solid"
  ) +
  
  geom_ribbon(
    data = df_algorithm,
    aes(x = mid_bin_quintile, ymin = ci_lower_percent, ymax = ci_upper_percent,
        fill = "Algorithm Cases Distribution"),
    alpha = 0.2,
    show.legend = FALSE
  ) +
  
  geom_line(
    data = df_dgid,
    aes(x = mid_bin_quintile, y = prob_percent, color = "Inspector Cases P(execution|predicted evasion)"),
    size = 1,
    linetype = "solid"
  ) +
  
  geom_ribbon(
    data = df_dgid,
    aes(x = mid_bin_quintile, ymin = ci_lower_percent, ymax = ci_upper_percent,
        fill = "Inspector Cases Distribution"),
    alpha = 0.4,
    show.legend = FALSE
  ) +
  
  scale_fill_manual(
    name = "",  
    values = c(
      "Algorithm Cases Distribution"  = "#9E0142",
      "Inspector Cases Distribution"  = "orange"
    )
  ) +
  
  scale_color_manual(
    name = "",  
    values = c(
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
  
  guides(
    fill  = guide_legend(nrow = 2),
    color = guide_legend(nrow = 2),
  )

print(final_plot)

# Save graph
ggsave(paste0(output_path, "10 density Algorithm vs Inspector Desk Audits", ".png"), 
       plot = final_plot, width = 8.8, height = 6.6, dpi = 300, bg = "white")
