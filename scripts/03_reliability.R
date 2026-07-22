# ==============================================================================
# Stage 2B: Reliability and item analysis
# Project: PHQ-9 psychometric evaluation using NHANES 2017–March 2020
#
# Scope:
#   - item floor effects and response-category sparsity
#   - corrected item-total correlations
#   - polychoric inter-item correlations
#   - ordinal coefficient alpha
#   - McDonald's omega
#   - reliability estimates after removing individual items, where informative
#   - uncertainty intervals where feasible
#
# Excluded from Stage 2B:
#   - factor-structure evaluation
#   - confirmatory factor analysis
#   - measurement invariance
#   - functional-difficulty modelling
#   - diagnostic or clinical interpretation
# ==============================================================================


# 1. Install any missing packages ----------------------------------------------

required_packages <- c(
  "dplyr",
  "tidyr",
  "purrr",
  "readr",
  "ggplot2",
  "here",
  "psych",
  "GPArotation",
  "tibble", 
  "boot"
)

missing_packages <- required_packages[
  !required_packages %in% rownames(installed.packages())
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}


# 2. Load packages --------------------------------------------------------------

library(dplyr)
library(tidyr)
library(purrr)
library(readr)
library(ggplot2)
library(here)
library(psych)
library(GPArotation)
library(tibble)
library(boot)


# 3. Define PHQ-9 items ---------------------------------------------------------

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


# 4. Load the approved Stage 2A data object ------------------------------------

stage2a_data_path <- here(
  "data",
  "processed",
  "phq9_stage2a_data.rds"
)

if (!file.exists(stage2a_data_path)) {
  stop(
    "The Stage 2A processed data file was not found at: ",
    stage2a_data_path
  )
}

phq9_stage2b_data <- readRDS(stage2a_data_path)


# 5. Validate the input object --------------------------------------------------

missing_item_variables <- setdiff(
  phq9_items,
  names(phq9_stage2b_data)
)

if (length(missing_item_variables) > 0) {
  stop(
    "The following PHQ-9 variables are missing: ",
    paste(missing_item_variables, collapse = ", ")
  )
}

phq9_complete <- phq9_stage2b_data |>
  filter(
    if_all(
      all_of(phq9_items),
      ~ !is.na(.x) & .x %in% 0:3
    )
  ) |>
  select(all_of(phq9_items)) |>
  as.data.frame()


# 6. Confirm the Stage 2B sample ------------------------------------------------

cat("\nStage 2B input validation\n")
cat("-------------------------\n")
cat("Complete PHQ-9 participants:", nrow(phq9_complete), "\n")
cat("PHQ-9 items:", ncol(phq9_complete), "\n")
cat(
  "Observed item-value range:",
  min(as.matrix(phq9_complete)),
  "to",
  max(as.matrix(phq9_complete)),
  "\n"
)
cat(
  "Missing values in Stage 2B item matrix:",
  sum(is.na(phq9_complete)),
  "\n"
)


# 7. Record package versions ----------------------------------------------------

cat("\nPackage versions\n")
cat("----------------\n")
cat("psych:", as.character(packageVersion("psych")), "\n")
cat(
  "GPArotation:",
  as.character(packageVersion("GPArotation")),
  "\n"
)

# 8. Item labels ---------------------------------------------------------------

phq9_item_labels <- tibble(
  variable = phq9_items,
  item = c(
    "Little interest or pleasure",
    "Depressed mood or hopelessness",
    "Sleep disturbance",
    "Tiredness or low energy",
    "Appetite disturbance",
    "Negative self-evaluation",
    "Concentration difficulties",
    "Psychomotor slowing or agitation",
    "Thoughts of death or self-harm"
  )
)


# 9. Item response-category distributions -------------------------------------

item_category_distribution <- phq9_complete |>
  pivot_longer(
    cols = all_of(phq9_items),
    names_to = "variable",
    values_to = "response"
  ) |>
  count(variable, response, name = "n") |>
  complete(
    variable = phq9_items,
    response = 0:3,
    fill = list(n = 0)
  ) |>
  group_by(variable) |>
  mutate(
    valid_n = sum(n),
    proportion = n / valid_n,
    percentage = 100 * proportion,
    empty_category = n == 0,
    sparse_category_lt_1pct = percentage < 1
  ) |>
  ungroup() |>
  left_join(
    phq9_item_labels,
    by = "variable"
  ) |>
  mutate(
    variable = factor(
      variable,
      levels = phq9_items
    )
  ) |>
  arrange(variable, response) |>
  select(
    variable,
    item,
    response,
    n,
    valid_n,
    proportion,
    percentage,
    empty_category,
    sparse_category_lt_1pct
  )


# 10. Validate the category distributions -------------------------------------

category_validation <- item_category_distribution |>
  group_by(variable) |>
  summarise(
    total_n = sum(n),
    total_percentage = sum(percentage),
    .groups = "drop"
  )

if (any(category_validation$total_n != nrow(phq9_complete))) {
  stop(
    "At least one item response distribution does not sum to the ",
    "complete PHQ-9 sample size."
  )
}

if (any(abs(category_validation$total_percentage - 100) > 1e-8)) {
  stop(
    "At least one item response distribution does not sum to 100%."
  )
}


# 11. Summarise floor effects and category sparsity ----------------------------

item_floor_sparsity_summary <- item_category_distribution |>
  group_by(variable, item) |>
  summarise(
    valid_n = first(valid_n),
    
    floor_n = n[response == 0],
    floor_percentage = percentage[response == 0],
    
    ceiling_n = n[response == 3],
    ceiling_percentage = percentage[response == 3],
    
    smallest_category_n = min(n),
    smallest_category_percentage = min(percentage),
    
    number_empty_categories = sum(empty_category),
    number_sparse_categories_lt_1pct =
      sum(sparse_category_lt_1pct),
    
    sparse_response_categories_lt_1pct = {
      sparse_categories <- response[
        sparse_category_lt_1pct
      ]
      
      if (length(sparse_categories) == 0) {
        "None"
      } else {
        paste(sparse_categories, collapse = ", ")
      }
    },
    
    .groups = "drop"
  ) |>
  mutate(
    variable = factor(
      variable,
      levels = phq9_items
    )
  ) |>
  arrange(variable)


# 12. Print the item-distribution summary --------------------------------------

cat("\nItem floor effects and category sparsity\n")
cat("----------------------------------------\n")

print(
  item_floor_sparsity_summary |>
    mutate(
      floor_percentage = round(floor_percentage, 2),
      ceiling_percentage = round(ceiling_percentage, 2),
      smallest_category_percentage =
        round(smallest_category_percentage, 2)
    ) |>
    select(
      variable,
      floor_percentage,
      ceiling_percentage,
      smallest_category_percentage,
      number_empty_categories,
      sparse_response_categories_lt_1pct
    ),
  n = Inf
)


# 13. Export Stage 2B item-distribution tables ---------------------------------

write_csv(
  item_category_distribution,
  here(
    "tables",
    "phq9_item_category_distribution.csv"
  )
)

write_csv(
  item_floor_sparsity_summary,
  here(
    "tables",
    "phq9_item_floor_sparsity_summary.csv"
  )
)

cat("\nExported Stage 2B item tables:\n")
cat("- tables/phq9_item_category_distribution.csv\n")
cat("- tables/phq9_item_floor_sparsity_summary.csv\n")

# 14. Corrected item-total correlations ----------------------------------------

corrected_item_total_correlations <- map_dfr(
  phq9_items,
  function(item_variable) {
    
    remaining_items <- setdiff(
      phq9_items,
      item_variable
    )
    
    item_values <- phq9_complete[[item_variable]]
    
    rest_score <- rowSums(
      phq9_complete[remaining_items]
    )
    
    correlation_test <- cor.test(
      item_values,
      rest_score,
      method = "pearson",
      conf.level = 0.95
    )
    
    tibble(
      variable = item_variable,
      n = length(item_values),
      corrected_item_total_r =
        unname(correlation_test$estimate),
      confidence_interval_lower =
        unname(correlation_test$conf.int[1]),
      confidence_interval_upper =
        unname(correlation_test$conf.int[2]),
      p_value = correlation_test$p.value
    )
  }
) |>
  left_join(
    phq9_item_labels,
    by = "variable"
  ) |>
  mutate(
    variable = factor(
      variable,
      levels = phq9_items
    )
  ) |>
  arrange(variable) |>
  select(
    variable,
    item,
    n,
    corrected_item_total_r,
    confidence_interval_lower,
    confidence_interval_upper,
    p_value
  )


# 15. Validate against psych::alpha r.drop -------------------------------------

classical_alpha_check <- psych::alpha(
  phq9_complete,
  check.keys = FALSE,
  warnings = FALSE
)

psych_r_drop <- classical_alpha_check$item.stats[
  phq9_items,
  "r.drop"
]

maximum_r_drop_difference <- max(
  abs(
    corrected_item_total_correlations$
      corrected_item_total_r -
      psych_r_drop
  )
)

if (maximum_r_drop_difference > 1e-10) {
  stop(
    "The manually calculated item-rest correlations ",
    "do not match psych::alpha() r.drop."
  )
}


# 16. Print corrected item-total correlations ----------------------------------

cat("\nCorrected item-total correlations\n")
cat("---------------------------------\n")

print(
  corrected_item_total_correlations |>
    mutate(
      corrected_item_total_r =
        round(corrected_item_total_r, 3),
      confidence_interval_lower =
        round(confidence_interval_lower, 3),
      confidence_interval_upper =
        round(confidence_interval_upper, 3),
      p_value = format.pval(
        p_value,
        digits = 3,
        eps = 0.001
      )
    ) |>
    select(
      variable,
      corrected_item_total_r,
      confidence_interval_lower,
      confidence_interval_upper,
      p_value
    ),
  n = Inf
)

cat(
  "\nMaximum difference from psych::alpha() r.drop:",
  format(
    maximum_r_drop_difference,
    scientific = TRUE
  ),
  "\n"
)


# 17. Export corrected item-total correlations ---------------------------------

write_csv(
  corrected_item_total_correlations,
  here(
    "tables",
    "phq9_corrected_item_total_correlations.csv"
  )
)

cat("\nExported corrected item-total table:\n")
cat(
  "- tables/phq9_corrected_item_total_correlations.csv\n"
)

# 18. Estimate the polychoric correlation matrix -------------------------------

polychoric_result <- psych::polychoric(
  phq9_complete,
  correct = 0.5,
  smooth = FALSE,
  global = TRUE,
  progress = FALSE
)

polychoric_matrix_raw <- polychoric_result$rho

# Restore the approved item order explicitly.
polychoric_matrix_raw <- polychoric_matrix_raw[
  phq9_items,
  phq9_items
]


# 19. Validate the polychoric matrix -------------------------------------------

if (any(!is.finite(polychoric_matrix_raw))) {
  stop(
    "The polychoric correlation matrix contains ",
    "non-finite estimates."
  )
}

if (!isSymmetric(
  polychoric_matrix_raw,
  tol = 1e-10
)) {
  stop(
    "The polychoric correlation matrix is not symmetric."
  )
}

if (any(
  abs(diag(polychoric_matrix_raw) - 1) > 1e-10
)) {
  stop(
    "The diagonal of the polychoric correlation ",
    "matrix does not equal 1."
  )
}

polychoric_eigenvalues_raw <- eigen(
  polychoric_matrix_raw,
  symmetric = TRUE,
  only.values = TRUE
)$values

minimum_polychoric_eigenvalue_raw <- min(
  polychoric_eigenvalues_raw
)

polychoric_matrix_was_positive_definite <-
  minimum_polychoric_eigenvalue_raw > 1e-8


# 20. Smooth only if required --------------------------------------------------

if (polychoric_matrix_was_positive_definite) {
  
  polychoric_matrix <- polychoric_matrix_raw
  polychoric_matrix_smoothed <- FALSE
  
} else {
  
  warning(
    "The raw polychoric matrix was not positive definite. ",
    "psych::cor.smooth() has been applied, and both the raw ",
    "and smoothed matrices will be retained."
  )
  
  polychoric_matrix <- psych::cor.smooth(
    polychoric_matrix_raw
  )
  
  polychoric_matrix_smoothed <- TRUE
}

polychoric_eigenvalues_final <- eigen(
  polychoric_matrix,
  symmetric = TRUE,
  only.values = TRUE
)$values

minimum_polychoric_eigenvalue_final <- min(
  polychoric_eigenvalues_final
)

if (minimum_polychoric_eigenvalue_final <= 0) {
  stop(
    "The final polychoric correlation matrix is ",
    "not positive definite."
  )
}


# 21. Create matrix summaries --------------------------------------------------

polychoric_off_diagonal <- polychoric_matrix[
  lower.tri(polychoric_matrix)
]

polychoric_matrix_summary <- tibble(
  sample_n = nrow(phq9_complete),
  number_of_items = length(phq9_items),
  continuity_correction = 0.5,
  global_thresholds = TRUE,
  raw_matrix_positive_definite =
    polychoric_matrix_was_positive_definite,
  matrix_smoothed = polychoric_matrix_smoothed,
  minimum_raw_eigenvalue =
    minimum_polychoric_eigenvalue_raw,
  minimum_final_eigenvalue =
    minimum_polychoric_eigenvalue_final,
  minimum_off_diagonal_correlation =
    min(polychoric_off_diagonal),
  maximum_off_diagonal_correlation =
    max(polychoric_off_diagonal),
  mean_off_diagonal_correlation =
    mean(polychoric_off_diagonal)
)

polychoric_matrix_long <- as.data.frame(
  as.table(polychoric_matrix)
) |>
  as_tibble() |>
  rename(
    item_1 = Var1,
    item_2 = Var2,
    polychoric_r = Freq
  ) |>
  mutate(
    item_1 = factor(
      item_1,
      levels = phq9_items
    ),
    item_2 = factor(
      item_2,
      levels = phq9_items
    )
  ) |>
  arrange(item_1, item_2)


# 22. Print the polychoric results ---------------------------------------------

cat("\nPolychoric correlation matrix\n")
cat("-----------------------------\n")

print(
  round(
    polychoric_matrix,
    3
  )
)

cat("\nPolychoric matrix diagnostics\n")
cat("-----------------------------\n")

print(
  polychoric_matrix_summary |>
    mutate(
      across(
        c(
          minimum_raw_eigenvalue,
          minimum_final_eigenvalue,
          minimum_off_diagonal_correlation,
          maximum_off_diagonal_correlation,
          mean_off_diagonal_correlation
        ),
        ~ round(.x, 4)
      )
    ),
  width = Inf
)


# 23. Export the polychoric outputs --------------------------------------------

write_csv(
  as.data.frame(polychoric_matrix_raw) |>
    rownames_to_column("variable"),
  here(
    "tables",
    "phq9_polychoric_matrix_raw.csv"
  )
)

write_csv(
  as.data.frame(polychoric_matrix) |>
    rownames_to_column("variable"),
  here(
    "tables",
    "phq9_polychoric_matrix.csv"
  )
)

write_csv(
  polychoric_matrix_long,
  here(
    "tables",
    "phq9_polychoric_matrix_long.csv"
  )
)

write_csv(
  polychoric_matrix_summary,
  here(
    "tables",
    "phq9_polychoric_matrix_summary.csv"
  )
)

cat("\nExported polychoric-correlation tables:\n")
cat("- tables/phq9_polychoric_matrix_raw.csv\n")
cat("- tables/phq9_polychoric_matrix.csv\n")
cat("- tables/phq9_polychoric_matrix_long.csv\n")
cat("- tables/phq9_polychoric_matrix_summary.csv\n")

# 24. Function for ordinal coefficient alpha -----------------------------------

calculate_ordinal_alpha <- function(correlation_matrix) {
  
  number_of_items <- ncol(correlation_matrix)
  
  mean_interitem_correlation <- mean(
    correlation_matrix[
      lower.tri(correlation_matrix)
    ]
  )
  
  ordinal_alpha <- (
    number_of_items *
      mean_interitem_correlation
  ) / (
    1 +
      (number_of_items - 1) *
      mean_interitem_correlation
  )
  
  tibble(
    number_of_items = number_of_items,
    mean_interitem_polychoric_r =
      mean_interitem_correlation,
    ordinal_alpha = ordinal_alpha
  )
}


# 25. Calculate ordinal alpha --------------------------------------------------

ordinal_alpha_summary <- calculate_ordinal_alpha(
  polychoric_matrix
) |>
  mutate(
    sample_n = nrow(phq9_complete),
    matrix_smoothed = polychoric_matrix_smoothed
  ) |>
  select(
    sample_n,
    number_of_items,
    mean_interitem_polychoric_r,
    ordinal_alpha,
    matrix_smoothed
  )


# 26. Validate ordinal alpha against psych::alpha ------------------------------

ordinal_alpha_psych_check <- psych::alpha(
  polychoric_matrix,
  n.obs = nrow(phq9_complete),
  check.keys = FALSE,
  warnings = FALSE
)

psych_standardised_alpha <- unname(
  ordinal_alpha_psych_check$total$std.alpha
)

ordinal_alpha_difference <- abs(
  ordinal_alpha_summary$ordinal_alpha -
    psych_standardised_alpha
)

if (ordinal_alpha_difference > 1e-10) {
  stop(
    "The manually calculated ordinal alpha does not ",
    "match psych::alpha() applied to the polychoric matrix."
  )
}


# 27. Ordinal alpha after removing each item -----------------------------------

ordinal_alpha_if_item_removed <- map_dfr(
  phq9_items,
  function(item_removed) {
    
    retained_items <- setdiff(
      phq9_items,
      item_removed
    )
    
    reduced_matrix <- polychoric_matrix[
      retained_items,
      retained_items
    ]
    
    reduced_alpha <- calculate_ordinal_alpha(
      reduced_matrix
    )
    
    tibble(
      variable = item_removed,
      retained_item_count =
        reduced_alpha$number_of_items,
      mean_interitem_polychoric_r_if_removed =
        reduced_alpha$mean_interitem_polychoric_r,
      ordinal_alpha_if_removed =
        reduced_alpha$ordinal_alpha
    )
  }
) |>
  left_join(
    phq9_item_labels,
    by = "variable"
  ) |>
  mutate(
    ordinal_alpha_change =
      ordinal_alpha_if_removed -
      ordinal_alpha_summary$ordinal_alpha,
    variable = factor(
      variable,
      levels = phq9_items
    )
  ) |>
  arrange(variable) |>
  select(
    variable,
    item,
    retained_item_count,
    mean_interitem_polychoric_r_if_removed,
    ordinal_alpha_if_removed,
    ordinal_alpha_change
  )


# 28. Print ordinal alpha results ----------------------------------------------

cat("\nOrdinal coefficient alpha\n")
cat("-------------------------\n")

print(
  ordinal_alpha_summary |>
    mutate(
      mean_interitem_polychoric_r =
        round(mean_interitem_polychoric_r, 3),
      ordinal_alpha =
        round(ordinal_alpha, 3)
    ),
  width = Inf
)

cat(
  "\nDifference from psych::alpha() standardised alpha:",
  format(
    ordinal_alpha_difference,
    scientific = TRUE
  ),
  "\n"
)

cat("\nOrdinal alpha if item removed\n")
cat("-----------------------------\n")

print(
  ordinal_alpha_if_item_removed |>
    mutate(
      mean_interitem_polychoric_r_if_removed =
        round(
          mean_interitem_polychoric_r_if_removed,
          3
        ),
      ordinal_alpha_if_removed =
        round(ordinal_alpha_if_removed, 3),
      ordinal_alpha_change =
        round(ordinal_alpha_change, 4)
    ) |>
    select(
      variable,
      mean_interitem_polychoric_r_if_removed,
      ordinal_alpha_if_removed,
      ordinal_alpha_change
    ),
  n = Inf
)


# 29. Export ordinal-alpha tables ----------------------------------------------

write_csv(
  ordinal_alpha_summary,
  here(
    "tables",
    "phq9_ordinal_alpha_summary.csv"
  )
)

write_csv(
  ordinal_alpha_if_item_removed,
  here(
    "tables",
    "phq9_ordinal_alpha_if_item_removed.csv"
  )
)

cat("\nExported ordinal-alpha tables:\n")
cat("- tables/phq9_ordinal_alpha_summary.csv\n")
cat("- tables/phq9_ordinal_alpha_if_item_removed.csv\n")

# 30. Function for one-factor McDonald's omega total ---------------------------

calculate_omega_total <- function(
    correlation_matrix,
    sample_n
) {
  
  one_factor_model <- psych::fa(
    r = correlation_matrix,
    nfactors = 1,
    n.obs = sample_n,
    fm = "minres",
    rotate = "none",
    SMC = TRUE,
    residuals = FALSE,
    warnings = FALSE
  )
  
  factor_loadings <- as.numeric(
    one_factor_model$loadings[, 1]
  )
  
  item_uniquenesses <- as.numeric(
    one_factor_model$uniquenesses
  )
  
  if (any(!is.finite(factor_loadings))) {
    stop(
      "The one-factor reliability model produced ",
      "non-finite factor loadings."
    )
  }
  
  if (any(!is.finite(item_uniquenesses))) {
    stop(
      "The one-factor reliability model produced ",
      "non-finite uniqueness estimates."
    )
  }
  
  if (
    any(item_uniquenesses < -1e-8) ||
    any(item_uniquenesses > 1 + 1e-8)
  ) {
    stop(
      "The one-factor reliability model produced an ",
      "improper uniqueness estimate."
    )
  }
  
  # For a unit-weighted total based on standardised items,
  # the observed total-score variance is the sum of all
  # elements in the correlation matrix.
  total_score_variance <- sum(
    correlation_matrix
  )
  
  sum_uniquenesses <- sum(
    item_uniquenesses
  )
  
  # psych's definition of omega total:
  # omega_t = 1 - sum(u^2) / V_x
  omega_total <- 1 - (
    sum_uniquenesses /
      total_score_variance
  )
  
  # Equivalent algebraic form used only as a validation.
  omega_total_algebraic_check <- (
    total_score_variance -
      sum_uniquenesses
  ) / total_score_variance
  
  algebraic_difference <- abs(
    omega_total -
      omega_total_algebraic_check
  )
  
  if (algebraic_difference > 1e-12) {
    stop(
      "The two algebraically equivalent omega-total ",
      "calculations do not match."
    )
  }
  
  list(
    omega_total = omega_total,
    total_score_variance = total_score_variance,
    sum_uniquenesses = sum_uniquenesses,
    factor_loadings = factor_loadings,
    uniquenesses = item_uniquenesses,
    algebraic_difference = algebraic_difference,
    model = one_factor_model
  )
}


# 31. Calculate McDonald's omega total -----------------------------------------

omega_total_result <- calculate_omega_total(
  correlation_matrix = polychoric_matrix,
  sample_n = nrow(phq9_complete)
)

omega_total_summary <- tibble(
  sample_n = nrow(phq9_complete),
  number_of_items = length(phq9_items),
  correlation_type = "Polychoric",
  extraction_method = "Minimum residual",
  reliability_model = "Single-factor congeneric",
  omega_definition =
    "1 - sum(uniquenesses) / observed total-score variance",
  observed_total_score_variance =
    omega_total_result$total_score_variance,
  sum_uniquenesses =
    omega_total_result$sum_uniquenesses,
  omega_total =
    omega_total_result$omega_total,
  matrix_smoothed =
    polychoric_matrix_smoothed
)

# Explicitly document and validate the uniqueness estimates -------------------

omega_uniqueness_diagnostics <- tibble(
  variable = phq9_items,
  item = phq9_item_labels$item[
    match(
      phq9_items,
      phq9_item_labels$variable
    )
  ],
  uniqueness = omega_total_result$uniquenesses
) |>
  mutate(
    uniqueness_is_finite =
      is.finite(uniqueness),
    uniqueness_is_non_negative =
      uniqueness >= 0,
    uniqueness_is_at_most_one =
      uniqueness <= 1,
    uniqueness_is_valid =
      uniqueness_is_finite &
      uniqueness_is_non_negative &
      uniqueness_is_at_most_one
  )

if (!all(omega_uniqueness_diagnostics$uniqueness_is_valid)) {
  stop(
    paste(
      "At least one uniqueness estimate used for omega total",
      "was non-finite or outside the range from 0 to 1."
    )
  )
}

omega_uniqueness_summary <-
  omega_uniqueness_diagnostics |>
  summarise(
    number_of_items = n(),
    all_uniquenesses_finite =
      all(uniqueness_is_finite),
    all_uniquenesses_non_negative =
      all(uniqueness_is_non_negative),
    all_uniquenesses_at_most_one =
      all(uniqueness_is_at_most_one),
    minimum_uniqueness =
      min(uniqueness),
    maximum_uniqueness =
      max(uniqueness)
  )

cat("\nOmega uniqueness diagnostics\n")
cat("----------------------------\n")

print(
  omega_uniqueness_diagnostics |>
    mutate(
      uniqueness = round(
        uniqueness,
        4
      )
    ),
  n = Inf
)

print(
  omega_uniqueness_summary |>
    mutate(
      minimum_uniqueness = round(
        minimum_uniqueness,
        4
      ),
      maximum_uniqueness = round(
        maximum_uniqueness,
        4
      )
    ),
  width = Inf
)

write_csv(
  omega_uniqueness_diagnostics,
  here(
    "tables",
    "phq9_omega_uniqueness_diagnostics.csv"
  )
)

write_csv(
  omega_uniqueness_summary,
  here(
    "tables",
    "phq9_omega_uniqueness_summary.csv"
  )
)

cat("\nExported omega uniqueness diagnostics:\n")
cat(
  "- tables/phq9_omega_uniqueness_diagnostics.csv\n"
)
cat(
  "- tables/phq9_omega_uniqueness_summary.csv\n"
)

# 32. Validate the omega-total estimate ----------------------------------------

if (
  omega_total_summary$omega_total <= 0 ||
  omega_total_summary$omega_total > 1
) {
  stop(
    "The estimated omega total is outside the ",
    "permissible range from 0 to 1."
  )
}


# 33. Omega total after removing each item -------------------------------------

omega_if_item_removed <- map_dfr(
  phq9_items,
  function(item_removed) {
    
    retained_items <- setdiff(
      phq9_items,
      item_removed
    )
    
    reduced_matrix <- polychoric_matrix[
      retained_items,
      retained_items
    ]
    
    reduced_omega_result <- calculate_omega_total(
      correlation_matrix = reduced_matrix,
      sample_n = nrow(phq9_complete)
    )
    
    tibble(
      variable = item_removed,
      retained_item_count = length(retained_items),
      omega_total_if_removed =
        reduced_omega_result$omega_total
    )
  }
) |>
  left_join(
    phq9_item_labels,
    by = "variable"
  ) |>
  mutate(
    omega_total_change =
      omega_total_if_removed -
      omega_total_summary$omega_total,
    variable = factor(
      variable,
      levels = phq9_items
    )
  ) |>
  arrange(variable) |>
  select(
    variable,
    item,
    retained_item_count,
    omega_total_if_removed,
    omega_total_change
  )


# 34. Print omega results -------------------------------------------------------

cat("\nMcDonald's omega total\n")
cat("----------------------\n")

print(
  omega_total_summary |>
    mutate(
      observed_total_score_variance =
        round(observed_total_score_variance, 3),
      sum_uniquenesses =
        round(sum_uniquenesses, 3),
      omega_total =
        round(omega_total, 3)
    ),
  width = Inf
)

cat(
  "\nAlgebraic validation difference:",
  format(
    omega_total_result$algebraic_difference,
    scientific = TRUE
  ),
  "\n"
)

cat("\nOmega total if item removed\n")
cat("---------------------------\n")

print(
  omega_if_item_removed |>
    mutate(
      omega_total_if_removed =
        round(omega_total_if_removed, 3),
      omega_total_change =
        round(omega_total_change, 4)
    ) |>
    select(
      variable,
      omega_total_if_removed,
      omega_total_change
    ),
  n = Inf
)


# 35. Export omega tables -------------------------------------------------------

write_csv(
  omega_total_summary,
  here(
    "tables",
    "phq9_omega_total_summary.csv"
  )
)

write_csv(
  omega_if_item_removed,
  here(
    "tables",
    "phq9_omega_if_item_removed.csv"
  )
)

cat("\nExported omega tables:\n")
cat("- tables/phq9_omega_total_summary.csv\n")
cat("- tables/phq9_omega_if_item_removed.csv\n")

# 36. Bootstrap reliability statistic ------------------------------------------

bootstrap_reliability_statistic <- function(
    data,
    indices
) {
  
  warning_count <- 0L
  
  tryCatch(
    withCallingHandlers(
      {
        
        bootstrap_data <- data[
          indices,
          ,
          drop = FALSE
        ]
        
        bootstrap_polychoric_result <- psych::polychoric(
          bootstrap_data,
          correct = 0.5,
          smooth = FALSE,
          global = TRUE,
          progress = FALSE
        )
        
        bootstrap_matrix_raw <-
          bootstrap_polychoric_result$rho[
            phq9_items,
            phq9_items
          ]
        
        if (any(!is.finite(bootstrap_matrix_raw))) {
          stop(
            "Bootstrap polychoric matrix contains ",
            "non-finite values."
          )
        }
        
        minimum_raw_eigenvalue <- min(
          eigen(
            bootstrap_matrix_raw,
            symmetric = TRUE,
            only.values = TRUE
          )$values
        )
        
        matrix_smoothed <-
          minimum_raw_eigenvalue <= 1e-8
        
        if (matrix_smoothed) {
          bootstrap_matrix <- psych::cor.smooth(
            bootstrap_matrix_raw
          )
        } else {
          bootstrap_matrix <- bootstrap_matrix_raw
        }
        
        bootstrap_alpha <- calculate_ordinal_alpha(
          bootstrap_matrix
        )$ordinal_alpha
        
        bootstrap_omega <- calculate_omega_total(
          correlation_matrix = bootstrap_matrix,
          sample_n = nrow(bootstrap_data)
        )$omega_total
        
        c(
          ordinal_alpha = bootstrap_alpha,
          omega_total = bootstrap_omega,
          matrix_smoothed =
            as.numeric(matrix_smoothed),
          minimum_raw_eigenvalue =
            minimum_raw_eigenvalue,
          warning_count =
            warning_count
        )
      },
      warning = function(warning_condition) {
        
        warning_count <<- warning_count + 1L
        
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error_condition) {
      
      c(
        ordinal_alpha = NA_real_,
        omega_total = NA_real_,
        matrix_smoothed = NA_real_,
        minimum_raw_eigenvalue = NA_real_,
        warning_count = NA_real_
      )
    }
  )
}


# 37. Run a 50-replicate bootstrap pilot ---------------------------------------

set.seed(20260722)

bootstrap_pilot_time <- system.time({
  
  reliability_bootstrap_pilot <- boot::boot(
    data = phq9_complete,
    statistic = bootstrap_reliability_statistic,
    R = 50,
    sim = "ordinary",
    stype = "i",
    parallel = "no"
  )
  
})


# 38. Summarise the bootstrap pilot --------------------------------------------

bootstrap_pilot_results <- as_tibble(
  reliability_bootstrap_pilot$t,
  .name_repair = "minimal"
)

names(bootstrap_pilot_results) <- c(
  "ordinal_alpha",
  "omega_total",
  "matrix_smoothed",
  "minimum_raw_eigenvalue",
  "warning_count"
)

bootstrap_pilot_summary <- tibble(
  requested_replicates = 50L,
  
  successful_replicates = sum(
    complete.cases(
      bootstrap_pilot_results[
        c(
          "ordinal_alpha",
          "omega_total"
        )
      ]
    )
  ),
  
  failed_replicates = sum(
    !complete.cases(
      bootstrap_pilot_results[
        c(
          "ordinal_alpha",
          "omega_total"
        )
      ]
    )
  ),
  
  smoothed_matrices = sum(
    bootstrap_pilot_results$
      matrix_smoothed == 1,
    na.rm = TRUE
  ),
  
  replicates_with_warnings = sum(
    bootstrap_pilot_results$
      warning_count > 0,
    na.rm = TRUE
  ),
  
  minimum_alpha = min(
    bootstrap_pilot_results$ordinal_alpha,
    na.rm = TRUE
  ),
  
  maximum_alpha = max(
    bootstrap_pilot_results$ordinal_alpha,
    na.rm = TRUE
  ),
  
  minimum_omega = min(
    bootstrap_pilot_results$omega_total,
    na.rm = TRUE
  ),
  
  maximum_omega = max(
    bootstrap_pilot_results$omega_total,
    na.rm = TRUE
  ),
  
  elapsed_seconds = unname(
    bootstrap_pilot_time["elapsed"]
  ),
  
  elapsed_minutes = elapsed_seconds / 60
)


# 39. Print the bootstrap pilot results ----------------------------------------

cat("\nBootstrap reliability pilot\n")
cat("---------------------------\n")

print(
  bootstrap_pilot_summary |>
    mutate(
      across(
        c(
          minimum_alpha,
          maximum_alpha,
          minimum_omega,
          maximum_omega
        ),
        ~ round(.x, 4)
      ),
      elapsed_seconds =
        round(elapsed_seconds, 1),
      elapsed_minutes =
        round(elapsed_minutes, 2)
    ),
  width = Inf
)

# 40. Run the final reliability bootstrap --------------------------------------

final_bootstrap_replicates <- 2000L

set.seed(20260722)

reliability_bootstrap_time <- system.time({
  
  reliability_bootstrap <- boot::boot(
    data = phq9_complete,
    statistic = bootstrap_reliability_statistic,
    R = final_bootstrap_replicates,
    sim = "ordinary",
    stype = "i",
    parallel = "no"
  )
  
})


# 41. Prepare the final bootstrap results --------------------------------------

reliability_bootstrap_results <- as_tibble(
  reliability_bootstrap$t,
  .name_repair = "minimal"
)

names(reliability_bootstrap_results) <- c(
  "ordinal_alpha",
  "omega_total",
  "matrix_smoothed",
  "minimum_raw_eigenvalue",
  "warning_count"
)

successful_bootstrap_results <-
  reliability_bootstrap_results |>
  filter(
    is.finite(ordinal_alpha),
    is.finite(omega_total)
  )

successful_bootstrap_replicates <- nrow(
  successful_bootstrap_results
)

failed_bootstrap_replicates <-
  final_bootstrap_replicates -
  successful_bootstrap_replicates

if (
  successful_bootstrap_replicates <
  0.99 * final_bootstrap_replicates
) {
  stop(
    "Fewer than 99% of the final bootstrap ",
    "replicates completed successfully."
  )
}


# 42. Calculate percentile confidence intervals --------------------------------

ordinal_alpha_bootstrap_ci <- quantile(
  successful_bootstrap_results$ordinal_alpha,
  probs = c(0.025, 0.975),
  names = FALSE,
  na.rm = TRUE,
  type = 7
)

omega_total_bootstrap_ci <- quantile(
  successful_bootstrap_results$omega_total,
  probs = c(0.025, 0.975),
  names = FALSE,
  na.rm = TRUE,
  type = 7
)

reliability_bootstrap_ci <- tibble(
  coefficient = c(
    "Ordinal coefficient alpha",
    "McDonald's omega total"
  ),
  
  point_estimate = c(
    ordinal_alpha_summary$ordinal_alpha,
    omega_total_summary$omega_total
  ),
  
  bootstrap_mean = c(
    mean(
      successful_bootstrap_results$ordinal_alpha
    ),
    mean(
      successful_bootstrap_results$omega_total
    )
  ),
  
  bootstrap_standard_error = c(
    sd(
      successful_bootstrap_results$ordinal_alpha
    ),
    sd(
      successful_bootstrap_results$omega_total
    )
  ),
  
  bootstrap_bias = bootstrap_mean - point_estimate,
  
  confidence_level = 0.95,
  
  confidence_interval_method =
    "Nonparametric percentile bootstrap",
  
  confidence_interval_lower = c(
    ordinal_alpha_bootstrap_ci[1],
    omega_total_bootstrap_ci[1]
  ),
  
  confidence_interval_upper = c(
    ordinal_alpha_bootstrap_ci[2],
    omega_total_bootstrap_ci[2]
  ),
  
  requested_replicates =
    final_bootstrap_replicates,
  
  successful_replicates =
    successful_bootstrap_replicates
)


# 43. Create final bootstrap diagnostics ---------------------------------------

reliability_bootstrap_diagnostics <- tibble(
  requested_replicates =
    final_bootstrap_replicates,
  
  successful_replicates =
    successful_bootstrap_replicates,
  
  failed_replicates =
    failed_bootstrap_replicates,
  
  smoothed_matrices = sum(
    successful_bootstrap_results$
      matrix_smoothed == 1,
    na.rm = TRUE
  ),
  
  replicates_with_warnings = sum(
    successful_bootstrap_results$
      warning_count > 0,
    na.rm = TRUE
  ),
  
  minimum_raw_eigenvalue = min(
    successful_bootstrap_results$
      minimum_raw_eigenvalue,
    na.rm = TRUE
  ),
  
  elapsed_seconds = unname(
    reliability_bootstrap_time["elapsed"]
  ),
  
  elapsed_minutes =
    elapsed_seconds / 60
)


# 44. Print final bootstrap results --------------------------------------------

cat("\nFinal bootstrap reliability intervals\n")
cat("-------------------------------------\n")

print(
  reliability_bootstrap_ci |>
    mutate(
      across(
        c(
          point_estimate,
          bootstrap_mean,
          bootstrap_standard_error,
          bootstrap_bias,
          confidence_interval_lower,
          confidence_interval_upper
        ),
        ~ round(.x, 4)
      )
    ),
  width = Inf
)

cat("\nFinal bootstrap diagnostics\n")
cat("---------------------------\n")

print(
  reliability_bootstrap_diagnostics |>
    mutate(
      minimum_raw_eigenvalue =
        round(minimum_raw_eigenvalue, 4),
      elapsed_seconds =
        round(elapsed_seconds, 1),
      elapsed_minutes =
        round(elapsed_minutes, 2)
    ),
  width = Inf
)


# 45. Export final bootstrap outputs -------------------------------------------

write_csv(
  reliability_bootstrap_ci,
  here(
    "tables",
    "phq9_reliability_bootstrap_ci.csv"
  )
)

write_csv(
  reliability_bootstrap_diagnostics,
  here(
    "tables",
    "phq9_reliability_bootstrap_diagnostics.csv"
  )
)

saveRDS(
  reliability_bootstrap,
  here(
    "data",
    "processed",
    "phq9_reliability_bootstrap_stage2b.rds"
  )
)

cat("\nExported final bootstrap outputs:\n")
cat("- tables/phq9_reliability_bootstrap_ci.csv\n")
cat("- tables/phq9_reliability_bootstrap_diagnostics.csv\n")
cat(
  "- data/processed/",
  "phq9_reliability_bootstrap_stage2b.rds ",
  "(local only)\n",
  sep = ""
)
