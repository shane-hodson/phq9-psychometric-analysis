# Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020

**Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation**

## Overview

This repository contains a reproducible psychometric evaluation of the Patient Health Questionnaire-9 using the National Health and Nutrition Examination Survey 2017–March 2020 pre-pandemic release.

The project examines the PHQ-9 as a self-reported indicator of recent depressive symptom severity. It does not treat PHQ-9 scores as psychiatric diagnoses.

## Current project stage

**Stage 1: Repository setup and data audit**

Current tasks include:

- downloading the depression and demographic files;
- inspecting file structure and response codes;
- verifying linkage using `SEQN`;
- documenting missingness;
- auditing the `DPQ100` response and skip pattern;
- producing the initial sample-flow and missingness outputs.

Reliability analysis, factor analysis and clinical interpretation have not yet begun.

## Dataset

The project uses the combined NHANES 2017–March 2020 pre-pandemic release.

Primary files:

- `P_DPQ.xpt`: Mental Health—Depression Screener
- `P_DEMO.xpt`: Demographic and survey-design variables

Participants are linked across files using the respondent identifier `SEQN`.

Raw NHANES files are downloaded programmatically and are not redistributed through this repository.

## Measure

The PHQ-9 contains nine items assessing depressive symptoms experienced during the previous two weeks.

Each item is scored from 0 to 3. A complete total score ranges from 0 to 27.

`DPQ100` assesses reported difficulty with work, home responsibilities and relationships. It is analysed separately and is not included in the PHQ-9 total score.

## Clinical interpretation

PHQ-9 scores are self-reported symptom-severity indicators, not diagnoses.

The available data do not establish whether a participant meets diagnostic criteria for a depressive disorder or requires treatment.

PHQ-9 item 9 concerns thoughts of death or self-harm. Endorsement is clinically important, but item 9 is not a standalone suicide-risk assessment.

## Planned version 1 analyses

Version 1 will include:

- data and codebook audit;
- sample-flow reporting;
- weighted item and total-score descriptives;
- ordinal coefficient alpha;
- McDonald's omega;
- corrected item-total correlations;
- polychoric inter-item correlations;
- one-factor dimensionality analysis;
- association between PHQ-9 scores and functional difficulty;
- clinical interpretation and limitations.

## Not included in version 1

Version 1 will not include:

- diagnostic-accuracy analysis;
- sensitivity or specificity estimates;
- treatment-need claims;
- measurement-invariance testing;
- survey-weighted latent-variable modelling.

## Repository structure

- `PROJECT_PROTOCOL.md`: approved project scope and analysis protocol
- `data/raw/`: downloaded NHANES source files
- `data/processed/`: locally generated analysis datasets
- `scripts/`: numbered R scripts
- `report/`: Quarto research report
- `figures/`: exported figures
- `tables/`: exported audit and analysis tables
- `references.bib`: bibliography
- `session-info.txt`: R session and package information

## Script order

1. `scripts/00_download_data.R`
2. `scripts/01_clean_data.R`
3. `scripts/02_descriptives.R`
4. `scripts/03_reliability.R`
5. `scripts/04_factor_analysis.R`
6. `scripts/05_figures_tables.R`

Only scripts 00 and 01 are active during the initial data-audit stage.

## Project status

- [x] Create GitHub repository
- [x] Create local RStudio project
- [x] Add repository folders and files
- [x] Save approved project protocol
- [x] Create skeleton README
- [x] Create and render minimal Quarto report
- [x] Download the NHANES source files
- [x] Verify `SEQN` linkage
- [x] Create the PHQ-9 variable dictionary
- [x] Audit response codes and missingness
- [x] Audit the `DPQ100` pattern
- [x] Produce initial sample-flow outputs
- [x] Audit survey-design variables
- [x] Save the cleaned data-audit dataset
- [ ] Commit and push the completed data-audit stage