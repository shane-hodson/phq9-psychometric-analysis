# Stage 2A: Weighted descriptive analyses
# Project: PHQ-9 psychometric evaluation using NHANES 2017–March 2020

library(dplyr)
library(survey)
library(srvyr)

# Allow survey variance estimation if a domain contains a singleton PSU.
options(survey.lonely.psu = "adjust")

# PHQ-9 item variables
phq9_items <- c(
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

# Load the cleaned Stage 1 dataset
stage2a_data <- readRDS(
  "data/processed/phq9_audit_data.rds"
)

# Confirm that all required variables are available
required_variables <- c(
  "SEQN",
  "WTMECPRP",
  "SDMVSTRA",
  "SDMVPSU",
  phq9_items,
  "DPQ100"
)

missing_variables <- setdiff(
  required_variables,
  names(stage2a_data)
)

if (length(missing_variables) > 0) {
  stop(
    "Required variables are missing: ",
    paste(missing_variables, collapse = ", ")
  )
}

# Create analysis-sample indicators and the PHQ-9 total score
stage2a_data <- stage2a_data |>
  mutate(
    phq9_complete = if_all(
      all_of(phq9_items),
      ~ !is.na(.x)
    ),
    phq9_total = if_else(
      phq9_complete,
      rowSums(across(all_of(phq9_items))),
      NA_real_
    ),
    any_phq9_symptom = (
      phq9_complete &
        phq9_total > 0
    ),
    dpq100_routed_valid = (
      any_phq9_symptom &
        !is.na(DPQ100)
    ),
    dpq100_structural_skip = (
      phq9_complete &
        phq9_total == 0 &
        is.na(DPQ100)
    )
  )

# Validate the Stage 2A sample definitions
sample_validation <- stage2a_data |>
  summarise(
    depression_screener_sample = n(),
    complete_phq9_sample = sum(phq9_complete),
    symptom_positive_complete_phq9 = sum(any_phq9_symptom),
    routed_valid_dpq100_sample = sum(dpq100_routed_valid),
    symptom_free_structural_skip = sum(dpq100_structural_skip)
  )

print(sample_validation)

# Check the number of PSUs represented within each stratum
survey_structure_check <- stage2a_data |>
  distinct(SDMVSTRA, SDMVPSU) |>
  count(
    SDMVSTRA,
    name = "n_psu"
  )

print(survey_structure_check)

if (any(survey_structure_check$n_psu < 2)) {
  warning(
    "At least one survey stratum contains fewer than two observed PSUs."
  )
}

# Create the full NHANES survey-design object
nhanes_design <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~WTMECPRP,
  nest = TRUE,
  data = stage2a_data
)

# Create analysis-specific survey domains
phq9_complete_design <- subset(
  nhanes_design,
  phq9_complete
)

dpq100_routed_design <- subset(
  nhanes_design,
  dpq100_routed_valid
)

# Create srvyr versions for later weighted summaries
nhanes_svy <- as_survey(nhanes_design)

phq9_complete_svy <- as_survey(
  phq9_complete_design
)

dpq100_routed_svy <- as_survey(
  dpq100_routed_design
)

# Display the survey-design object
print(nhanes_design)

# -------------------------------------------------------------------------
# Weighted PHQ-9 item-response proportions
# -------------------------------------------------------------------------

item_labels <- c(
  DPQ010 = "Little interest or pleasure",
  DPQ020 = "Depressed mood or hopelessness",
  DPQ030 = "Sleep disturbance",
  DPQ040 = "Tiredness or low energy",
  DPQ050 = "Appetite disturbance",
  DPQ060 = "Negative self-evaluation",
  DPQ070 = "Concentration difficulties",
  DPQ080 = "Psychomotor slowing or agitation",
  DPQ090 = "Thoughts of death or self-harm"
)

response_labels <- c(
  `0` = "Not at all",
  `1` = "Several days",
  `2` = "More than half the days",
  `3` = "Nearly every day"
)

calculate_item_proportions <- function(item_name) {
  
  # Use all participants with a valid response to the individual item.
  valid_rows <- !is.na(
    nhanes_design$variables[[item_name]]
  )
  
  item_design <- nhanes_design[valid_rows, ]
  
  item_formula <- as.formula(
    paste0(
      "~factor(",
      item_name,
      ", levels = 0:3)"
    )
  )
  
  item_estimate <- svymean(
    item_formula,
    design = item_design,
    na.rm = TRUE
  )
  
  item_ci <- confint(
    item_estimate,
    level = 0.95
  )
  
  unweighted_counts <- as.integer(
    table(
      factor(
        stage2a_data[[item_name]],
        levels = 0:3
      )
    )
  )
  
  tibble(
    item = item_name,
    symptom_content = unname(
      item_labels[item_name]
    ),
    response = 0:3,
    response_label = unname(
      response_labels[as.character(0:3)]
    ),
    unweighted_n_response = unweighted_counts,
    unweighted_n_item = sum(valid_rows),
    weighted_percent = 100 * as.numeric(
      coef(item_estimate)
    ),
    standard_error_percent = 100 * as.numeric(
      SE(item_estimate)
    ),
    ci_lower_percent = 100 * item_ci[, 1],
    ci_upper_percent = 100 * item_ci[, 2]
  )
}

phq9_item_response_proportions <- bind_rows(
  lapply(
    phq9_items,
    calculate_item_proportions
  )
)

# Check that the weighted percentages sum to approximately 100% for each item.
item_response_check <- phq9_item_response_proportions |>
  group_by(item) |>
  summarise(
    unweighted_n_item = first(
      unweighted_n_item
    ),
    weighted_percent_sum = sum(
      weighted_percent
    ),
    .groups = "drop"
  )

print(
  item_response_check,
  n = Inf
)

# Create a clean exported table.
phq9_item_response_export <- phq9_item_response_proportions |>
  mutate(
    weighted_percent = round(
      weighted_percent,
      2
    ),
    standard_error_percent = round(
      standard_error_percent,
      2
    ),
    ci_lower_percent = round(
      ci_lower_percent,
      2
    ),
    ci_upper_percent = round(
      ci_upper_percent,
      2
    )
  )

write.csv(
  phq9_item_response_export,
  "tables/phq9_item_response_proportions.csv",
  row.names = FALSE,
  na = ""
)

print(
  phq9_item_response_export,
  n = Inf
)

# -------------------------------------------------------------------------
# Weighted PHQ-9 total-score distribution
# Complete-PHQ-9 sample: n = 8,276
# -------------------------------------------------------------------------

# Validate the observed total-score range.
phq9_total_range_check <- stage2a_data |>
  filter(phq9_complete) |>
  summarise(
    unweighted_n = n(),
    minimum_score = min(phq9_total),
    maximum_score = max(phq9_total)
  )

print(phq9_total_range_check)

# Weighted mean PHQ-9 total score.
phq9_total_mean_estimate <- svymean(
  ~phq9_total,
  design = phq9_complete_design,
  na.rm = TRUE
)

phq9_total_mean_ci <- confint(
  phq9_total_mean_estimate,
  level = 0.95
)

# Weighted variance and standard deviation.
phq9_total_variance_estimate <- svyvar(
  ~phq9_total,
  design = phq9_complete_design,
  na.rm = TRUE
)

phq9_total_summary <- tibble(
  unweighted_n = sum(
    stage2a_data$phq9_complete
  ),
  weighted_mean = as.numeric(
    coef(phq9_total_mean_estimate)
  ),
  standard_error = as.numeric(
    SE(phq9_total_mean_estimate)
  ),
  ci_lower = as.numeric(
    phq9_total_mean_ci[1, 1]
  ),
  ci_upper = as.numeric(
    phq9_total_mean_ci[1, 2]
  ),
  weighted_standard_deviation = sqrt(
    as.numeric(
      coef(phq9_total_variance_estimate)
    )
  ),
  observed_minimum = min(
    stage2a_data$phq9_total[
      stage2a_data$phq9_complete
    ],
    na.rm = TRUE
  ),
  observed_maximum = max(
    stage2a_data$phq9_total[
      stage2a_data$phq9_complete
    ],
    na.rm = TRUE
  )
)

phq9_total_summary_export <- phq9_total_summary |>
  mutate(
    across(
      c(
        weighted_mean,
        standard_error,
        ci_lower,
        ci_upper,
        weighted_standard_deviation
      ),
      ~ round(.x, 2)
    )
  )

print(phq9_total_summary_export)

# Calculate the weighted proportion at each possible total score.
calculate_total_score_proportion <- function(score_value) {
  
  unweighted_count <- sum(
    stage2a_data$phq9_complete &
      stage2a_data$phq9_total == score_value,
    na.rm = TRUE
  )
  
  if (unweighted_count == 0) {
    return(
      tibble(
        phq9_total = score_value,
        unweighted_n = 0L,
        weighted_percent = 0,
        standard_error_percent = NA_real_,
        ci_lower_percent = NA_real_,
        ci_upper_percent = NA_real_
      )
    )
  }
  
  score_formula <- as.formula(
    paste0(
      "~I(phq9_total == ",
      score_value,
      ")"
    )
  )
  
  score_estimate <- svyciprop(
    score_formula,
    design = phq9_complete_design,
    method = "logit",
    level = 0.95,
    na.rm = TRUE
  )
  
  score_ci <- confint(
    score_estimate,
  )
  
  tibble(
    phq9_total = score_value,
    unweighted_n = unweighted_count,
    weighted_percent = 100 * as.numeric(
      coef(score_estimate)
    ),
    standard_error_percent = 100 * as.numeric(
      SE(score_estimate)
    ),
    ci_lower_percent = 100 * as.numeric(
      score_ci[1]
    ),
    ci_upper_percent = 100 * as.numeric(
      score_ci[2]
    )
  )
}

phq9_total_distribution <- bind_rows(
  lapply(
    0:27,
    calculate_total_score_proportion
  )
)

# Confirm that the score frequencies and weighted percentages are complete.
phq9_total_distribution_check <- phq9_total_distribution |>
  summarise(
    unweighted_n_sum = sum(
      unweighted_n
    ),
    weighted_percent_sum = sum(
      weighted_percent
    )
  )

print(phq9_total_distribution_check)

phq9_total_distribution_export <- phq9_total_distribution |>
  mutate(
    across(
      c(
        weighted_percent,
        standard_error_percent,
        ci_lower_percent,
        ci_upper_percent
      ),
      ~ round(.x, 2)
    )
  )

print(
  phq9_total_distribution_export,
  n = Inf
)

write.csv(
  phq9_total_summary_export,
  "tables/phq9_total_summary.csv",
  row.names = FALSE,
  na = ""
)

write.csv(
  phq9_total_distribution_export,
  "tables/phq9_total_distribution.csv",
  row.names = FALSE,
  na = ""
)
# -------------------------------------------------------------------------
# Weighted PHQ-9 symptom-severity bands
# Complete-PHQ-9 sample: n = 8,276
# -------------------------------------------------------------------------

severity_labels <- c(
  "Minimal (0–4)",
  "Mild (5–9)",
  "Moderate (10–14)",
  "Moderately severe (15–19)",
  "Severe (20–27)"
)

# Add the conventional severity-band variable to the working dataset.
stage2a_data <- stage2a_data |>
  mutate(
    phq9_severity = cut(
      phq9_total,
      breaks = c(
        -Inf,
        4,
        9,
        14,
        19,
        27
      ),
      labels = severity_labels,
      ordered_result = TRUE
    )
  )

# Add the same variable to the complete-PHQ-9 survey design.
phq9_complete_design <- update(
  phq9_complete_design,
  phq9_severity = cut(
    phq9_total,
    breaks = c(
      -Inf,
      4,
      9,
      14,
      19,
      27
    ),
    labels = severity_labels,
    ordered_result = TRUE
  )
)

calculate_severity_proportion <- function(severity_level) {
  
  severity_formula <- as.formula(
    paste0(
      "~I(phq9_severity == ",
      shQuote(severity_level),
      ")"
    )
  )
  
  severity_estimate <- svyciprop(
    severity_formula,
    design = phq9_complete_design,
    method = "logit",
    level = 0.95,
    na.rm = TRUE
  )
  
  severity_ci <- confint(
    severity_estimate
  )
  
  tibble(
    severity_band = severity_level,
    unweighted_n = sum(
      stage2a_data$phq9_complete &
        stage2a_data$phq9_severity == severity_level,
      na.rm = TRUE
    ),
    weighted_percent = 100 * as.numeric(
      coef(severity_estimate)
    ),
    standard_error_percent = 100 * as.numeric(
      SE(severity_estimate)
    ),
    ci_lower_percent = 100 * as.numeric(
      severity_ci[1]
    ),
    ci_upper_percent = 100 * as.numeric(
      severity_ci[2]
    )
  )
}

phq9_severity_distribution <- bind_rows(
  lapply(
    severity_labels,
    calculate_severity_proportion
  )
)

# Preserve the intended category order.
phq9_severity_distribution <- phq9_severity_distribution |>
  mutate(
    severity_band = factor(
      severity_band,
      levels = severity_labels,
      ordered = TRUE
    )
  ) |>
  arrange(
    severity_band
  )

severity_distribution_check <- phq9_severity_distribution |>
  summarise(
    unweighted_n_sum = sum(
      unweighted_n
    ),
    weighted_percent_sum = sum(
      weighted_percent
    )
  )

print(severity_distribution_check)

phq9_severity_distribution_export <- phq9_severity_distribution |>
  mutate(
    severity_band = as.character(
      severity_band
    ),
    across(
      c(
        weighted_percent,
        standard_error_percent,
        ci_lower_percent,
        ci_upper_percent
      ),
      ~ round(.x, 2)
    )
  )

print(
  phq9_severity_distribution_export,
  n = Inf
)

write.csv(
  phq9_severity_distribution_export,
  "tables/phq9_severity_distribution.csv",
  row.names = FALSE,
  na = ""
)

# -------------------------------------------------------------------------
# Weighted DPQ100 distribution among routed respondents
# Primary routed sample: n = 5,517
# -------------------------------------------------------------------------

dpq100_labels <- c(
  `0` = "Not difficult at all",
  `1` = "Somewhat difficult",
  `2` = "Very difficult",
  `3` = "Extremely difficult"
)

calculate_dpq100_proportion <- function(response_value) {
  
  response_formula <- as.formula(
    paste0(
      "~I(DPQ100 == ",
      response_value,
      ")"
    )
  )
  
  response_estimate <- svyciprop(
    response_formula,
    design = dpq100_routed_design,
    method = "logit",
    level = 0.95,
    na.rm = TRUE
  )
  
  response_ci <- confint(
    response_estimate
  )
  
  tibble(
    dpq100_response = response_value,
    response_label = unname(
      dpq100_labels[as.character(response_value)]
    ),
    unweighted_n = sum(
      stage2a_data$dpq100_routed_valid &
        stage2a_data$DPQ100 == response_value,
      na.rm = TRUE
    ),
    weighted_percent = 100 * as.numeric(
      coef(response_estimate)
    ),
    standard_error_percent = 100 * as.numeric(
      SE(response_estimate)
    ),
    ci_lower_percent = 100 * as.numeric(
      response_ci[1]
    ),
    ci_upper_percent = 100 * as.numeric(
      response_ci[2]
    )
  )
}

dpq100_routed_distribution <- bind_rows(
  lapply(
    0:3,
    calculate_dpq100_proportion
  )
)

dpq100_routed_check <- dpq100_routed_distribution |>
  summarise(
    unweighted_n_sum = sum(
      unweighted_n
    ),
    weighted_percent_sum = sum(
      weighted_percent
    )
  )

print(dpq100_routed_check)

dpq100_routed_distribution_export <- dpq100_routed_distribution |>
  mutate(
    across(
      c(
        weighted_percent,
        standard_error_percent,
        ci_lower_percent,
        ci_upper_percent
      ),
      ~ round(.x, 2)
    )
  )

print(
  dpq100_routed_distribution_export,
  n = Inf
)

write.csv(
  dpq100_routed_distribution_export,
  "tables/dpq100_routed_distribution.csv",
  row.names = FALSE,
  na = ""
)

# -------------------------------------------------------------------------
# Extended DPQ100 distribution
# Complete-PHQ-9 sample: n = 8,276
# -------------------------------------------------------------------------

dpq100_extended_levels <- c(
  "No PHQ-9 symptoms / DPQ100 structurally skipped",
  "Not difficult at all",
  "Somewhat difficult",
  "Very difficult",
  "Extremely difficult",
  "Symptom-positive / DPQ100 missing"
)

stage2a_data <- stage2a_data |>
  mutate(
    dpq100_extended = case_when(
      phq9_complete &
        phq9_total == 0 &
        is.na(DPQ100) ~
        "No PHQ-9 symptoms / DPQ100 structurally skipped",
      
      phq9_complete &
        phq9_total > 0 &
        DPQ100 == 0 ~
        "Not difficult at all",
      
      phq9_complete &
        phq9_total > 0 &
        DPQ100 == 1 ~
        "Somewhat difficult",
      
      phq9_complete &
        phq9_total > 0 &
        DPQ100 == 2 ~
        "Very difficult",
      
      phq9_complete &
        phq9_total > 0 &
        DPQ100 == 3 ~
        "Extremely difficult",
      
      phq9_complete &
        phq9_total > 0 &
        is.na(DPQ100) ~
        "Symptom-positive / DPQ100 missing",
      
      TRUE ~ NA_character_
    ),
    dpq100_extended = factor(
      dpq100_extended,
      levels = dpq100_extended_levels,
      ordered = TRUE
    )
  )

# Check for unexpected valid DPQ100 responses among symptom-free participants.
unexpected_zero_symptom_dpq100 <- stage2a_data |>
  summarise(
    n = sum(
      phq9_complete &
        phq9_total == 0 &
        !is.na(DPQ100)
    )
  )

print(unexpected_zero_symptom_dpq100)

if (unexpected_zero_symptom_dpq100$n > 0) {
  warning(
    "At least one symptom-free participant has a valid DPQ100 response."
  )
}

# Recreate the full survey design so that it contains the extended variable.
nhanes_extended_design <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~WTMECPRP,
  nest = TRUE,
  data = stage2a_data
)

phq9_complete_extended_design <- subset(
  nhanes_extended_design,
  phq9_complete
)

calculate_extended_dpq100_proportion <- function(category_level) {
  
  category_formula <- as.formula(
    paste0(
      "~I(dpq100_extended == ",
      shQuote(category_level),
      ")"
    )
  )
  
  category_estimate <- svyciprop(
    category_formula,
    design = phq9_complete_extended_design,
    method = "logit",
    level = 0.95,
    na.rm = TRUE
  )
  
  category_ci <- confint(
    category_estimate
  )
  
  tibble(
    category = category_level,
    unweighted_n = sum(
      stage2a_data$phq9_complete &
        stage2a_data$dpq100_extended == category_level,
      na.rm = TRUE
    ),
    weighted_percent = 100 * as.numeric(
      coef(category_estimate)
    ),
    standard_error_percent = 100 * as.numeric(
      SE(category_estimate)
    ),
    ci_lower_percent = 100 * as.numeric(
      category_ci[1]
    ),
    ci_upper_percent = 100 * as.numeric(
      category_ci[2]
    )
  )
}

dpq100_extended_distribution <- bind_rows(
  lapply(
    dpq100_extended_levels,
    calculate_extended_dpq100_proportion
  )
)

dpq100_extended_check <- dpq100_extended_distribution |>
  summarise(
    unweighted_n_sum = sum(
      unweighted_n
    ),
    weighted_percent_sum = sum(
      weighted_percent
    )
  )

print(dpq100_extended_check)

dpq100_extended_distribution_export <- dpq100_extended_distribution |>
  mutate(
    across(
      c(
        weighted_percent,
        standard_error_percent,
        ci_lower_percent,
        ci_upper_percent
      ),
      ~ round(.x, 2)
    )
  )

print(
  dpq100_extended_distribution_export,
  n = Inf
)

write.csv(
  dpq100_extended_distribution_export,
  "tables/dpq100_extended_distribution.csv",
  row.names = FALSE,
  na = ""
)
# -------------------------------------------------------------------------
# Save local Stage 2A analysis objects
# These processed files are excluded from Git.
# -------------------------------------------------------------------------

saveRDS(
  stage2a_data,
  "data/processed/phq9_stage2a_data.rds"
)

saveRDS(
  nhanes_extended_design,
  "data/processed/nhanes_design_stage2a.rds"
)

message("Stage 2A data and survey-design objects saved.")