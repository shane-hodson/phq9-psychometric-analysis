# Project 1: PHQ-9 psychometric analysis
# Script: 01_clean_data.R
#
# Purpose:
# Verify linkage between the NHANES depression and demographic files.
#
# Stage:
# Data audit only.

library(tidyverse)
library(haven)
library(here)

# Import source files
dpq_source <- read_xpt(
  here("data", "raw", "P_DPQ.xpt")
)

demo_source <- read_xpt(
  here("data", "raw", "P_DEMO.xpt")
)

# Check for duplicate identifiers
dpq_duplicate_seqn <- sum(
  duplicated(dpq_source$SEQN)
)

demo_duplicate_seqn <- sum(
  duplicated(demo_source$SEQN)
)

# Identify depression records not found in demographics
dpq_not_in_demo <- anti_join(
  dpq_source,
  demo_source,
  by = "SEQN"
)

# Identify adults in demographics not found in depression data
adult_demo_not_in_dpq <- demo_source |>
  filter(RIDAGEYR >= 18) |>
  anti_join(
    dpq_source,
    by = "SEQN"
  )

# Create linkage audit table
linkage_audit <- tibble(
  check = c(
    "Rows in P_DPQ",
    "Unique SEQN in P_DPQ",
    "Duplicated SEQN in P_DPQ",
    "Rows in P_DEMO",
    "Unique SEQN in P_DEMO",
    "Duplicated SEQN in P_DEMO",
    "P_DPQ records not found in P_DEMO",
    "P_DEMO adults not found in P_DPQ"
  ),
  n = c(
    nrow(dpq_source),
    n_distinct(dpq_source$SEQN),
    dpq_duplicate_seqn,
    nrow(demo_source),
    n_distinct(demo_source$SEQN),
    demo_duplicate_seqn,
    nrow(dpq_not_in_demo),
    nrow(adult_demo_not_in_dpq)
  )
)

# Save the audit table
write_csv(
  linkage_audit,
  here("tables", "seqn_linkage_audit.csv")
)

# Print results
cat("\nSEQN linkage audit:\n")
print(linkage_audit)

message("SEQN linkage audit completed.")
# -------------------------------------------------------------------
# Create the PHQ-9 variable dictionary
# -------------------------------------------------------------------

phq_items <- c(
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

questionnaire_variables <- c(
  phq_items,
  "DPQ100"
)

get_variable_label <- function(variable_name) {
  
  variable_label <- attr(
    dpq_source[[variable_name]],
    "label"
  )
  
  if (is.null(variable_label)) {
    return(NA_character_)
  }
  
  as.character(variable_label)
}

variable_dictionary <- tibble(
  variable = questionnaire_variables,
  nhanes_label = map_chr(
    questionnaire_variables,
    get_variable_label
  ),
  item_number = c(
    1:9,
    NA_integer_
  ),
  content = c(
    "Little interest or pleasure",
    "Depressed mood or hopelessness",
    "Sleep disturbance",
    "Tiredness or low energy",
    "Appetite disturbance",
    "Negative self-evaluation",
    "Concentration difficulties",
    "Psychomotor slowing or agitation",
    "Thoughts of death or self-harm",
    "Functional difficulty"
  ),
  role = c(
    rep("PHQ-9 symptom item", 9),
    "External functional-difficulty item"
  ),
  valid_codes = c(
    rep("0, 1, 2, 3", 9),
    "0, 1, 2, 3"
  ),
  non_substantive_codes = rep(
    "7 = Refused; 9 = Don't know; blank = system missing",
    10
  ),
  included_in_phq9_total = c(
    rep("Yes", 9),
    "No"
  )
)

write_csv(
  variable_dictionary,
  here("tables", "phq9_variable_dictionary.csv")
)

# -------------------------------------------------------------------
# Audit observed questionnaire response codes
# -------------------------------------------------------------------

response_code_audit <- dpq_source |>
  select(
    SEQN,
    all_of(questionnaire_variables)
  ) |>
  mutate(
    across(
      all_of(questionnaire_variables),
      as.numeric
    )
  ) |>
  pivot_longer(
    cols = all_of(questionnaire_variables),
    names_to = "variable",
    values_to = "raw_value"
  ) |>
  mutate(
    response_status = case_when(
      is.na(raw_value) ~ "System missing",
      raw_value %in% 0:3 ~ paste0("Valid response: ", raw_value),
      raw_value == 7 ~ "Refused",
      raw_value == 9 ~ "Don't know",
      TRUE ~ "Unexpected code"
    )
  ) |>
  count(
    variable,
    response_status,
    raw_value,
    name = "n"
  ) |>
  group_by(variable) |>
  mutate(
    percent = 100 * n / sum(n)
  ) |>
  ungroup() |>
  arrange(
    variable,
    response_status,
    raw_value
  )

write_csv(
  response_code_audit,
  here("tables", "response_code_audit.csv")
)

cat("\nPHQ-9 variable dictionary:\n")
print(variable_dictionary)

cat("\nObserved response-code audit:\n")
print(response_code_audit, n = Inf)

message("Variable dictionary and response-code audit completed.")
# -------------------------------------------------------------------
# Link questionnaire and demographic data for the adult audit sample
# -------------------------------------------------------------------

demographic_variables <- c(
  "SEQN",
  "SDDSRVYR",
  "RIDSTATR",
  "RIAGENDR",
  "RIDAGEYR",
  "WTMECPRP",
  "SDMVPSU",
  "SDMVSTRA"
)

dpq_audit <- dpq_source |>
  select(
    SEQN,
    all_of(questionnaire_variables)
  ) |>
  mutate(
    across(
      all_of(questionnaire_variables),
      as.numeric
    )
  )

demo_audit <- demo_source |>
  select(
    all_of(demographic_variables)
  ) |>
  mutate(
    across(
      everything(),
      as.numeric
    )
  )

linked_audit <- dpq_audit |>
  left_join(
    demo_audit,
    by = "SEQN"
  ) |>
  filter(
    RIDAGEYR >= 18
  )

# -------------------------------------------------------------------
# Create questionnaire missingness audit
# -------------------------------------------------------------------

missingness_audit <- map_dfr(
  questionnaire_variables,
  function(variable_name) {
    
    x <- linked_audit[[variable_name]]
    
    tibble(
      variable = variable_name,
      total_n = length(x),
      valid_0_to_3 = sum(x %in% 0:3),
      refused_code_7 = sum(x == 7, na.rm = TRUE),
      dont_know_code_9 = sum(x == 9, na.rm = TRUE),
      system_missing = sum(is.na(x)),
      unexpected_code = sum(
        !is.na(x) &
          !(x %in% c(0:3, 7, 9))
      )
    )
  }
) |>
  mutate(
    valid_percent = 100 * valid_0_to_3 / total_n,
    unavailable_percent = 100 *
      (
        refused_code_7 +
          dont_know_code_9 +
          system_missing +
          unexpected_code
      ) /
      total_n
  )

write_csv(
  missingness_audit,
  here("tables", "missingness_audit.csv")
)

# -------------------------------------------------------------------
# Create PHQ-9 response-pattern flags
# -------------------------------------------------------------------

item_valid_matrix <- sapply(
  linked_audit[phq_items],
  function(x) x %in% 0:3
)

item_zero_matrix <- sapply(
  linked_audit[phq_items],
  function(x) x == 0
)

item_positive_matrix <- sapply(
  linked_audit[phq_items],
  function(x) x %in% 1:3
)

linked_audit <- linked_audit |>
  mutate(
    n_valid_phq_items = rowSums(
      item_valid_matrix
    ),
    
    complete_phq9 =
      n_valid_phq_items == 9,
    
    all_phq_items_zero =
      complete_phq9 &
      rowSums(
        item_zero_matrix,
        na.rm = TRUE
      ) == 9,
    
    any_phq_item_positive =
      complete_phq9 &
      rowSums(
        item_positive_matrix
      ) >= 1,
    
    phq_response_pattern = case_when(
      !complete_phq9 ~
        "Incomplete PHQ-9",
      
      all_phq_items_zero ~
        "All nine PHQ-9 items equal 0",
      
      any_phq_item_positive ~
        "At least one PHQ-9 item above 0",
      
      TRUE ~
        "Other pattern"
    ),
    
    dpq100_status = case_when(
      DPQ100 %in% 0:3 ~
        "Valid DPQ100 response",
      
      DPQ100 == 7 ~
        "DPQ100 refused",
      
      DPQ100 == 9 ~
        "DPQ100 don't know",
      
      is.na(DPQ100) ~
        "DPQ100 system missing",
      
      TRUE ~
        "DPQ100 unexpected code"
    )
  )

# -------------------------------------------------------------------
# Audit the DPQ100 response and skip pattern
# -------------------------------------------------------------------

dpq100_skip_audit <- linked_audit |>
  count(
    phq_response_pattern,
    dpq100_status,
    name = "n"
  ) |>
  group_by(
    phq_response_pattern
  ) |>
  mutate(
    row_percent = 100 * n / sum(n)
  ) |>
  ungroup() |>
  arrange(
    phq_response_pattern,
    dpq100_status
  )

write_csv(
  dpq100_skip_audit,
  here("tables", "dpq100_skip_audit.csv")
)

# -------------------------------------------------------------------
# Produce the initial sample-flow table
# -------------------------------------------------------------------

sample_flow <- tibble(
  stage = c(
    "All records in P_DEMO",
    "Adults aged 18 or older in P_DEMO",
    "All records in P_DPQ",
    "P_DPQ records linked to P_DEMO",
    "Linked records aged 18 or older",
    "Adults with all nine PHQ-9 items valid",
    "Adults with valid DPQ100",
    "Adults with complete PHQ-9 and valid DPQ100"
  ),
  
  n = c(
    nrow(demo_source),
    
    sum(
      demo_source$RIDAGEYR >= 18,
      na.rm = TRUE
    ),
    
    nrow(dpq_source),
    
    sum(
      dpq_source$SEQN %in%
        demo_source$SEQN
    ),
    
    nrow(linked_audit),
    
    sum(
      linked_audit$complete_phq9
    ),
    
    sum(
      linked_audit$DPQ100 %in% 0:3
    ),
    
    sum(
      linked_audit$complete_phq9 &
        linked_audit$DPQ100 %in% 0:3
    )
  )
)

write_csv(
  sample_flow,
  here("tables", "sample_flow.csv")
)

# -------------------------------------------------------------------
# Print the audit outputs
# -------------------------------------------------------------------

cat("\nMissingness audit:\n")
print(
  missingness_audit,
  n = Inf
)

cat("\nDPQ100 skip-pattern audit:\n")
print(
  dpq100_skip_audit,
  n = Inf
)

cat("\nInitial sample flow:\n")
print(
  sample_flow,
  n = Inf
)

message(
  "Missingness, DPQ100, and sample-flow audits completed."
)
# -------------------------------------------------------------------
# Audit NHANES survey-design variables
# -------------------------------------------------------------------

survey_design_audit <- tibble(
  variable = c(
    "WTMECPRP",
    "SDMVPSU",
    "SDMVSTRA"
  ),
  
  description = c(
    "Combined 2017-March 2020 MEC examination weight",
    "Masked variance primary sampling unit",
    "Masked variance stratum"
  ),
  
  total_n = nrow(linked_audit),
  
  missing_n = c(
    sum(is.na(linked_audit$WTMECPRP)),
    sum(is.na(linked_audit$SDMVPSU)),
    sum(is.na(linked_audit$SDMVSTRA))
  ),
  
  valid_n = c(
    sum(!is.na(linked_audit$WTMECPRP)),
    sum(!is.na(linked_audit$SDMVPSU)),
    sum(!is.na(linked_audit$SDMVSTRA))
  ),
  
  distinct_values = c(
    n_distinct(
      linked_audit$WTMECPRP,
      na.rm = TRUE
    ),
    n_distinct(
      linked_audit$SDMVPSU,
      na.rm = TRUE
    ),
    n_distinct(
      linked_audit$SDMVSTRA,
      na.rm = TRUE
    )
  )
)

write_csv(
  survey_design_audit,
  here("tables", "survey_design_audit.csv")
)

cat("\nSurvey-design variable audit:\n")

print(
  survey_design_audit,
  n = Inf
)

message(
  "Survey-design variable audit completed."
)
# -------------------------------------------------------------------
# Create and save the cleaned data-audit dataset
# -------------------------------------------------------------------

clean_audit_data <- linked_audit |>
  mutate(
    across(
      all_of(questionnaire_variables),
      ~ case_when(
        .x %in% 0:3 ~ .x,
        TRUE ~ NA_real_
      )
    )
  )

# Confirm that questionnaire variables now contain only 0-3 or NA
clean_code_check <- map_dfr(
  questionnaire_variables,
  function(variable_name) {
    
    x <- clean_audit_data[[variable_name]]
    
    tibble(
      variable = variable_name,
      minimum = ifelse(
        all(is.na(x)),
        NA_real_,
        min(x, na.rm = TRUE)
      ),
      maximum = ifelse(
        all(is.na(x)),
        NA_real_,
        max(x, na.rm = TRUE)
      ),
      missing_n = sum(is.na(x)),
      unexpected_after_cleaning = sum(
        !is.na(x) & !(x %in% 0:3)
      )
    )
  }
)

write_csv(
  clean_code_check,
  here("tables", "clean_code_check.csv")
)

write_rds(
  clean_audit_data,
  here(
    "data",
    "processed",
    "phq9_audit_data.rds"
  )
)

cat("\nCleaned questionnaire-code check:\n")

print(
  clean_code_check,
  n = Inf
)

message(
  "Cleaned audit dataset saved to data/processed/phq9_audit_data.rds."
)