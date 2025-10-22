predict_rf <- function(rf, data){
  
  # Predict values
  predicted_values <- predict(rf, data)
  
  # Create column for predicted errors and estimated values
  data <- data %>% mutate(yhatrf = predicted_values)
  
  return(data)
  
}

fullaudits_predicted <- predict_rf(rf, fullaudits_realized_test)

# Define the minimum and maximum values for the bins                                                                                                                                                                                                                                                                                                   
min_v <- floor(min(fullaudits_predicted$yhatrf, na.rm = TRUE))
max_v <- ceiling(max(fullaudits_predicted$yhatrf, na.rm = TRUE))


# Prepare the data for probability of execution
prob_execution <- fullaudits_predicted %>%
  mutate(
    bin = cut(
      yhatrf,
      breaks = seq(min_v, max_v + 0.5, by = 1), # Define breaks with a width of 0.5
      include.lowest = TRUE,
      right = FALSE                            # Left-closed intervals [x, x+0.5)
    ),
    mid_bin = as.numeric(sub("\\[(\\d+\\.?\\d*),.*", "\\1", bin)) + 0.5 # Calculate the midpoint
  ) %>%
  group_by(bin, mid_bin) %>%
  summarise(
    # Mean of y2 in this bin (proportion of 1's, but purely an average of 0/1)
    prob   = mean(y2, na.rm = TRUE),
    
    # Sample variance of y2 within this bin (empirical variance)
    var_y2 = var(y2, na.rm = TRUE),
    
    # How many observations in this bin
    n = n(),
  ) %>%
  ungroup() 

prob_execution_ci <- prob_execution %>%
  mutate(
    # Standard error of the mean in that bin = sqrt( within-bin variance / n )
    se = sqrt(var_y2 / n),
    
    # Normal-approx 95% CI around the bin's mean
    ci_lower = prob - 1.96 * se,
    ci_upper = prob + 1.96 * se,
    
    # Clamp to [0, 1] if desired to avoid negative or >1 probabilities
    ci_lower = pmax(ci_lower, 0),
    ci_upper = pmin(ci_upper, 1),
    
    # Convert to percentages for plotting
    prob_percent      = prob      * 100,
    ci_lower_percent = ci_lower * 100,
    ci_upper_percent = ci_upper * 100
  )


# Define Bin Parameters
bin_width <- 1
bins <- seq(min_v, max_v, by = bin_width)
min_v_real <- floor(min(fullaudits_predicted$y4, na.rm = TRUE))
max_v_real <- ceiling(max(fullaudits_predicted$y4, na.rm = TRUE))
bins_real <- seq(min_v_real, max_v_real, by = bin_width)


# 1. Calculate Percentages for Predicted Evasion by Group (y2)
predicted_percent <- fullaudits_predicted %>%
  mutate(bin = cut(yhatrf, breaks = bins, include.lowest = TRUE, right = FALSE)) %>%
  group_by(y2, bin) %>%
  summarise(count = n(), .groups = 'drop') %>%
  group_by(y2) %>%
  mutate(percent = (count / sum(count)) * 100) %>%
  mutate(mid_bin = as.numeric(sub("\\[(\\d+),.*", "\\1", bin)) + bin_width / 2) %>%
  ungroup() %>%
  # Assign Descriptive Labels to Groups
  mutate(Group = factor(y2, levels = c("0", "1"), labels = c("Not Executed", "Executed"))) %>%
  filter(mid_bin > 12)

# 2. Calculate Percentages for Real Evasion (y4)
real_percent <- fullaudits_predicted %>%
  mutate(bin = cut(y4, breaks = bins_real, include.lowest = TRUE, right = FALSE)) %>%
  filter(y2 == 1) %>%
  group_by(bin) %>%
  summarise(count = n(), .groups = 'drop') %>%
  mutate(percent = (count / sum(count)) * 100) %>%
  mutate(mid_bin = as.numeric(sub("\\[(\\d+),.*", "\\1", bin)) + bin_width / 2) %>%
  mutate(Group = "Real Evasion")  %>% # Label for Real Evasion
  filter(mid_bin > 12)

# 3. Prepare Probability Execution Data
prob_execution_ci <- prob_execution_ci %>%
  filter(mid_bin > 12)


# 4. Create the Plot

# Keep only greater than 10
predicted_percent <- predicted_percent %>% filter(mid_bin > 12)

final_plot <- ggplot() +
  
  # -------------------------------------------------------------------
# 1) Geoms de "Not Executed", "Executed", "Real Evasion"
# -------------------------------------------------------------------
geom_area(
  data = filter(predicted_percent, Group == "Not Executed"), 
  aes(x = mid_bin, y = percent, fill = "Not Executed"),
  alpha = 0.3
) +
  geom_area(
    data = filter(predicted_percent, Group == "Executed"), 
    aes(x = mid_bin, y = percent, fill = "Executed"),
    alpha = 0.3
  ) +
  geom_area(
    data = real_percent,
    aes(x = mid_bin, y = percent, fill = "Real Evasion"),
    alpha = 0.2
  ) +
  
  # -------------------------------------------------------------------
# 2) Ribbon (intervalo de confiança) - OCULTAR na legenda
# -------------------------------------------------------------------
geom_ribbon(
  data = prob_execution_ci,
  aes(
    x    = mid_bin, 
    ymin = ci_lower_percent, 
    ymax = ci_upper_percent     # Cor vermelha
  ),
  fill = "red",
  alpha       = 0.2,
  show.legend = FALSE          # <-- Não mostrar na legenda
) +
  
  # -------------------------------------------------------------------
# 3) Linha "Probability" - MOSTRAR na legenda
# -------------------------------------------------------------------
geom_line(
  data = prob_execution_ci,
  aes(
    x     = mid_bin, 
    y     = prob_percent,
    color = "Probability"      # Cor vermelha
  ),
  size = 1
) +
  
  
  # -------------------------------------------------------------------
# Escala para Preenchimento (fill)
# Inclui 4 chaves (3 para áreas e 1 para Probability)
# mas a Probability será "silenciosa" (pois show.legend=FALSE no ribbon)
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Escala para Cor (color)
# Aqui só temos "Probability", que de fato aparecerá na legenda
# -------------------------------------------------------------------
scale_color_manual(
  name   = "",
  values = c("Probability" = "red"),
  labels = c("Probability" = "P(execution|predicted evasion)")
) +
  
scale_fill_manual(
  name = "",
  values = c(
    "Not Executed" = "navy",
    "Executed"     = "darkgreen",
    "Real Evasion" = "black"
  ),
  labels = c(
    "Not Executed" = "Predicted evasion, non-executed",
    "Executed"     = "Predicted evasion, executed",
    "Real Evasion" = "Detected evasion"
  )
) +
  

  # -------------------------------------------------------------------
# Layout do gráfico
# -------------------------------------------------------------------
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
    fill  = guide_legend(ncol = 1),
    color = guide_legend(ncol = 1),
  )

# Save graph
ggsave(paste0(output_path, plot_name, ".png"), plot = final_plot, width = 8, height = 6, dpi = 300, bg = "white")
print(final_plot)

