# Project 1: PHQ-9 psychometric analysis
# Script: 00_download_data.R
#
# Purpose:
# Download and inspect the two primary NHANES source files.
#
# Stage:
# Data audit only. No consequential data analysis is performed.

library(haven)
library(dplyr)
library(readr)
library(tibble)
library(here)

# Create required directories
dir.create(
  here("data", "raw"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  here("tables"),
  recursive = TRUE,
  showWarnings = FALSE
)

# Official NHANES file locations
source_files <- tribble(
  ~file_name, ~url,
  "P_DPQ.xpt",
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/P_DPQ.xpt",
  "P_DEMO.xpt",
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/P_DEMO.xpt"
)

# Download files only if they are not already present
for (i in seq_len(nrow(source_files))) {
  
  destination <- here(
    "data",
    "raw",
    source_files$file_name[i]
  )
  
  if (!file.exists(destination)) {
    
    message("Downloading ", source_files$file_name[i])
    
    download.file(
      url = source_files$url[i],
      destfile = destination,
      mode = "wb",
      method = "libcurl"
    )
    
  } else {
    
    message(
      source_files$file_name[i],
      " already exists; download skipped."
    )
  }
}

# Import files
dpq_source <- read_xpt(
  here("data", "raw", "P_DPQ.xpt")
)

demo_source <- read_xpt(
  here("data", "raw", "P_DEMO.xpt")
)

# Create initial file audit
file_audit <- tibble(
  file = c("P_DPQ.xpt", "P_DEMO.xpt"),
  rows = c(
    nrow(dpq_source),
    nrow(demo_source)
  ),
  columns = c(
    ncol(dpq_source),
    ncol(demo_source)
  ),
  unique_seqn = c(
    n_distinct(dpq_source$SEQN),
    n_distinct(demo_source$SEQN)
  ),
  duplicate_seqn = c(
    sum(duplicated(dpq_source$SEQN)),
    sum(duplicated(demo_source$SEQN))
  )
)

write_csv(
  file_audit,
  here("tables", "data_file_audit.csv")
)

# Print inspection results
cat("\nP_DPQ dimensions:\n")
print(dim(dpq_source))

cat("\nP_DPQ variables:\n")
print(names(dpq_source))

cat("\nP_DEMO dimensions:\n")
print(dim(demo_source))

cat("\nSelected P_DEMO variables:\n")
print(
  intersect(
    c(
      "SEQN",
      "SDDSRVYR",
      "RIDSTATR",
      "RIAGENDR",
      "RIDAGEYR",
      "WTMECPRP",
      "SDMVPSU",
      "SDMVSTRA"
    ),
    names(demo_source)
  )
)

cat("\nFile audit:\n")
print(file_audit)

# Save session information
capture.output(
  sessionInfo(),
  file = here("session-info.txt")
)

message("Download and initial file inspection completed.")