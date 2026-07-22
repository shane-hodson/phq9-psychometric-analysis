# Stage 2A: Descriptive figures
# Project: PHQ-9 psychometric evaluation using NHANES 2017–March 2020
#
# This script creates descriptive figures only.
# It does not perform reliability, factor, or functional-association modelling.

library(dplyr)
library(ggplot2)

dir.create(
  "figures",
  showWarnings = FALSE,
  recursive = TRUE
)

required_tables <- c(
  "tables/phq9_item_response_proportions.csv",
  "tables/phq9_total_distribution.csv",
  "tables/phq9_severity_distribution.csv",
  "tables/dpq100_routed_distribution.csv",
  "tables/dpq100_extended_distribution.csv"
)

missing_tables <- required_tables[
  !file.exists(required_tables)
]

if (length(missing_tables) > 0) {
  stop(
    "Required Stage 2A tables are missing: ",
    paste(missing_tables, collapse = ", ")
  )
}

percent_labels <- function(x) {
  paste0(x, "%")
}

survey_caption <- paste(
  "Weighted using WTMECPRP;",
  "variance estimation incorporates SDMVSTRA and SDMVPSU."
)

# -------------------------------------------------------------------------
# Figure 1: Weighted PHQ-9 item-response proportions
# -------------------------------------------------------------------------

item_response_data <- read.csv(
  "tables/phq9_item_response_proportions.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

item_order <- item_response_data |>
  distinct(item, symptom_content) |>
  arrange(item) |>
  pull(symptom_content)

response_order <- c(
  "Not at all",
  "Several days",
  "More than half the days",
  "Nearly every day"
)

item_response_data <- item_response_data |>
  mutate(
    symptom_content = factor(
      symptom_content,
      levels = rev(item_order)
    ),
    response_label = factor(
      response_label,
      levels = response_order
    )
  )

item_response_figure <- ggplot(
  item_response_data,
  aes(
    x = symptom_content,
    y = weighted_percent,
    fill = response_label
  )
) +
  geom_col(
    width = 0.75
  ) +
  coord_flip() +
  scale_y_continuous(
    breaks = seq(0, 100, 20),
    labels = percent_labels,
    expand = expansion(
      mult = c(0, 0.01)
    )
  ) +
  labs(
    title = "Weighted PHQ-9 item-response distributions",
    subtitle = "Item-specific estimates use all available valid responses",
    x = NULL,
    y = "Weighted percentage",
    fill = "Response",
    caption = survey_caption
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = "figures/phq9_item_response_proportions.png",
  plot = item_response_figure,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Figure 2: Weighted PHQ-9 total-score distribution
# -------------------------------------------------------------------------

total_distribution_data <- read.csv(
  "tables/phq9_total_distribution.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

# ==============================================================================
# Stage 2B figures: reliability and item analysis
# ==============================================================================


# 1. Load Stage 2B output tables ------------------------------------------------

item_total_table <- readr::read_csv(
  here::here(
    "tables",
    "phq9_corrected_item_total_correlations.csv"
  ),
  show_col_types = FALSE
)

polychoric_long_table <- readr::read_csv(
  here::here(
    "tables",
    "phq9_polychoric_matrix_long.csv"
  ),
  show_col_types = FALSE
)

reliability_ci_table <- readr::read_csv(
  here::here(
    "tables",
    "phq9_reliability_bootstrap_ci.csv"
  ),
  show_col_types = FALSE
)

phq9_item_order <- c(
  "DPQ010",
  "DPQ020",
  "DPQ030",
  "DPQ040",
  "DPQ050",
  "DPQ060",
  "DPQ070",
  "DPQ080",
  "DPQ090"
)


# 2. Corrected item-total correlation figure -----------------------------------

item_total_figure_data <- item_total_table |>
  dplyr::mutate(
    variable = factor(
      variable,
      levels = rev(phq9_item_order)
    ),
    figure_label = paste0(
      variable,
      ": ",
      item
    )
  )

item_total_figure <- ggplot2::ggplot(
  item_total_figure_data,
  ggplot2::aes(
    x = corrected_item_total_r,
    y = reorder(
      figure_label,
      as.numeric(variable)
    )
  )
) +
  ggplot2::geom_errorbar(
    ggplot2::aes(
      xmin = confidence_interval_lower,
      xmax = confidence_interval_upper
    ),
    orientation = "y",
    width = 0.15
  ) +
  ggplot2::geom_point(
    size = 2.5
  ) +
  ggplot2::scale_x_continuous(
    limits = c(0, 0.75),
    breaks = seq(0, 0.7, by = 0.1)
  ) +
  ggplot2::labs(
    title = "Corrected PHQ-9 item–total correlations",
    subtitle = "Pearson correlations between each item and the sum of the remaining eight items",
    x = "Corrected item–total correlation",
    y = NULL,
    caption = "Error bars show 95% confidence intervals."
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    panel.grid.major.y = ggplot2::element_blank(),
    plot.title.position = "plot"
  )

ggplot2::ggsave(
  filename = here::here(
    "figures",
    "phq9_corrected_item_total_correlations.png"
  ),
  plot = item_total_figure,
  width = 9,
  height = 5.5,
  dpi = 300
)


# 3. Polychoric correlation heatmap --------------------------------------------

polychoric_heatmap_data <- polychoric_long_table |>
  dplyr::mutate(
    item_1 = factor(
      item_1,
      levels = phq9_item_order
    ),
    item_2 = factor(
      item_2,
      levels = rev(phq9_item_order)
    ),
    item_1_number = match(
      as.character(item_1),
      phq9_item_order
    ),
    item_2_number = match(
      as.character(item_2),
      phq9_item_order
    )
  ) |>
  dplyr::filter(
    item_1_number <= item_2_number
  )

polychoric_heatmap <- ggplot2::ggplot(
  polychoric_heatmap_data,
  ggplot2::aes(
    x = item_1,
    y = item_2,
    fill = polychoric_r
  )
) +
  ggplot2::geom_tile(
    linewidth = 0.4
  ) +
  ggplot2::geom_text(
    ggplot2::aes(
      label = sprintf("%.2f", polychoric_r)
    ),
    size = 3.1
  ) +
  ggplot2::scale_fill_gradient(
    limits = c(0.45, 1),
    name = "Polychoric\ncorrelation"
  ) +
  ggplot2::coord_fixed() +
  ggplot2::labs(
    title = "PHQ-9 polychoric correlation matrix",
    subtitle = "Complete-PHQ-9 analytic sample, n = 8,276",
    x = NULL,
    y = NULL,
    caption = "The matrix was positive definite and did not require smoothing."
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    panel.grid = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1
    ),
    plot.title.position = "plot"
  )

ggplot2::ggsave(
  filename = here::here(
    "figures",
    "phq9_polychoric_correlation_heatmap.png"
  ),
  plot = polychoric_heatmap,
  width = 8,
  height = 7,
  dpi = 300
)


# 4. Reliability-coefficient figure --------------------------------------------

reliability_figure_data <- reliability_ci_table |>
  dplyr::mutate(
    coefficient = factor(
      coefficient,
      levels = rev(c(
        "Ordinal coefficient alpha",
        "McDonald's omega total"
      ))
    )
  )

reliability_figure <- ggplot2::ggplot(
  reliability_figure_data,
  ggplot2::aes(
    x = point_estimate,
    y = coefficient
  )
) +
  ggplot2::geom_errorbar(
    ggplot2::aes(
      xmin = confidence_interval_lower,
      xmax = confidence_interval_upper
    ),
    orientation = "y",
    width = 0.12
  ) +
  ggplot2::geom_point(
    size = 3
  ) +
  ggplot2::scale_x_continuous(
    limits = c(0.90, 0.94),
    breaks = seq(0.90, 0.94, by = 0.01)
  ) +
  ggplot2::labs(
    title = "PHQ-9 internal-consistency estimates",
    subtitle = "Ordinal reliability coefficients based on the polychoric correlation matrix",
    x = "Reliability coefficient",
    y = NULL,
    caption = "Error bars show 95% nonparametric percentile bootstrap intervals based on 2,000 participant-level resamples."
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    panel.grid.major.y = ggplot2::element_blank(),
    plot.title.position = "plot"
  )

ggplot2::ggsave(
  filename = here::here(
    "figures",
    "phq9_reliability_coefficients.png"
  ),
  plot = reliability_figure,
  width = 8,
  height = 4,
  dpi = 300
)


# 5. Confirm figure export ------------------------------------------------------

cat("\nThree Stage 2B figures exported successfully:\n")
cat("- figures/phq9_corrected_item_total_correlations.png\n")
cat("- figures/phq9_polychoric_correlation_heatmap.png\n")
cat("- figures/phq9_reliability_coefficients.png\n")
total_score_figure <- ggplot(
  total_distribution_data,
  aes(
    x = phq9_total,
    y = weighted_percent
  )
) +
  geom_col(
    width = 0.8
  ) +
  scale_x_continuous(
    breaks = seq(0, 27, 3)
  ) +
  scale_y_continuous(
    labels = percent_labels,
    expand = expansion(
      mult = c(0, 0.05)
    )
  ) +
  labs(
    title = "Weighted distribution of PHQ-9 total scores",
    subtitle = "Complete PHQ-9 sample, unweighted n = 8,276",
    x = "PHQ-9 total score",
    y = "Weighted percentage",
    caption = survey_caption
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.x = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = "figures/phq9_total_score_distribution.png",
  plot = total_score_figure,
  width = 9,
  height = 5.5,
  units = "in",
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Figure 3: Weighted PHQ-9 symptom-severity bands
# -------------------------------------------------------------------------

severity_data <- read.csv(
  "tables/phq9_severity_distribution.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

severity_order <- c(
  "Minimal (0–4)",
  "Mild (5–9)",
  "Moderate (10–14)",
  "Moderately severe (15–19)",
  "Severe (20–27)"
)

severity_data <- severity_data |>
  mutate(
    severity_band = factor(
      severity_band,
      levels = rev(severity_order)
    )
  )

severity_figure <- ggplot(
  severity_data,
  aes(
    x = severity_band,
    y = weighted_percent
  )
) +
  geom_col(
    width = 0.7
  ) +
  geom_errorbar(
    aes(
      ymin = ci_lower_percent,
      ymax = ci_upper_percent
    ),
    width = 0.18
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = percent_labels,
    expand = expansion(
      mult = c(0, 0.06)
    )
  ) +
  labs(
    title = "Weighted PHQ-9 symptom-severity distribution",
    subtitle = "Complete PHQ-9 sample, unweighted n = 8,276",
    x = NULL,
    y = "Weighted percentage",
    caption = paste(
      survey_caption,
      "Error bars show 95% confidence intervals."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = "figures/phq9_severity_distribution.png",
  plot = severity_figure,
  width = 9,
  height = 5.5,
  units = "in",
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Figure 4: DPQ100 among routed respondents
# -------------------------------------------------------------------------

dpq100_routed_data <- read.csv(
  "tables/dpq100_routed_distribution.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

dpq100_order <- c(
  "Not difficult at all",
  "Somewhat difficult",
  "Very difficult",
  "Extremely difficult"
)

dpq100_routed_data <- dpq100_routed_data |>
  mutate(
    response_label = factor(
      response_label,
      levels = rev(dpq100_order)
    )
  )

dpq100_routed_figure <- ggplot(
  dpq100_routed_data,
  aes(
    x = response_label,
    y = weighted_percent
  )
) +
  geom_col(
    width = 0.7
  ) +
  geom_errorbar(
    aes(
      ymin = ci_lower_percent,
      ymax = ci_upper_percent
    ),
    width = 0.18
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = percent_labels,
    expand = expansion(
      mult = c(0, 0.06)
    )
  ) +
  labs(
    title = "Reported functional difficulty among routed respondents",
    subtitle = paste(
      "Complete PHQ-9, at least one symptom endorsed,",
      "and valid DPQ100; unweighted n = 5,517"
    ),
    x = NULL,
    y = "Weighted percentage",
    caption = paste(
      survey_caption,
      "Error bars show 95% confidence intervals."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = "figures/dpq100_routed_distribution.png",
  plot = dpq100_routed_figure,
  width = 9,
  height = 5.5,
  units = "in",
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Figure 5: Extended DPQ100 categories
# -------------------------------------------------------------------------

dpq100_extended_data <- read.csv(
  "tables/dpq100_extended_distribution.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

extended_order <- c(
  "No PHQ-9 symptoms / DPQ100 structurally skipped",
  "Not difficult at all",
  "Somewhat difficult",
  "Very difficult",
  "Extremely difficult",
  "Symptom-positive / DPQ100 missing"
)

dpq100_extended_data <- dpq100_extended_data |>
  mutate(
    category = factor(
      category,
      levels = rev(extended_order)
    )
  )

dpq100_extended_figure <- ggplot(
  dpq100_extended_data,
  aes(
    x = category,
    y = weighted_percent
  )
) +
  geom_col(
    width = 0.7
  ) +
  geom_errorbar(
    aes(
      ymin = ci_lower_percent,
      ymax = ci_upper_percent
    ),
    width = 0.18
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = percent_labels,
    expand = expansion(
      mult = c(0, 0.06)
    )
  ) +
  labs(
    title = "Extended functional-difficulty categories",
    subtitle = "Complete PHQ-9 sample, unweighted n = 8,276",
    x = NULL,
    y = "Weighted percentage",
    caption = paste(
      survey_caption,
      "Structural skips and missing responses are displayed separately.",
      "Error bars show 95% confidence intervals."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot"
  )

ggsave(
  filename = "figures/dpq100_extended_distribution.png",
  plot = dpq100_extended_figure,
  width = 10,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)

message("Five Stage 2A descriptive figures exported successfully.")
