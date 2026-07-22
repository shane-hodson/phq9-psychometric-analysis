# Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020

**Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation**

**Repository:** `phq9-nhanes-psychometrics`

**Current stage:** Stage 2B reliability and item analysis completed and methodologically approved; minor repository refinements in progress before Stage 3

## Overview

This repository documents a reproducible psychometric analysis of the Patient Health Questionnaire-9 (PHQ-9) using the National Health and Nutrition Examination Survey (NHANES) 2017–March 2020 pre-pandemic release.

The project examines the PHQ-9 as a self-report measure of recent depressive symptom severity. PHQ-9 scores are not treated as psychiatric diagnoses.

The analysis plan is documented in [`ANALYSIS_PLAN.md`](ANALYSIS_PLAN.md).

## Current project stage

### Stage 2B: reliability and item analysis

Stage 2B has been completed and submitted for review.

The analytical content has received methodological approval. Minor repository and reporting refinements are being completed before Stage 3 begins.

Stage 2B includes:

- assessment of item floor effects and response-category sparsity;
- corrected item-total correlations;
- estimation and validation of the polychoric correlation matrix;
- ordinal coefficient alpha;
- McDonald’s omega total;
- reliability estimates after removing individual items;
- 2,000 participant-level nonparametric bootstrap resamples;
- bootstrap confidence intervals and computational diagnostics;
- exported reliability tables and figures;
- an updated Quarto report.

The reliability analyses use the complete-PHQ-9 analytic sample and do not incorporate the NHANES survey weights, strata or primary sampling units.

The estimates therefore describe internal consistency and item relationships in the analytic sample rather than nationally representative psychometric parameters.

Reliability estimates are interpreted as evidence about internal consistency. They are not treated as evidence that the PHQ-9 is valid, diagnostically accurate or unidimensional.

Factor analysis, confirmatory modelling, measurement invariance and functional-difficulty regression modelling have not begun.

## Stage 2B headline results

The complete-PHQ-9 psychometric sample contains **8,276 participants**.

Key Stage 2B results include:

- no PHQ-9 item had an empty response category;
- item floor percentages ranged from 50.19% to 96.15%;
- only `DPQ090` had response categories below the predefined 1% sparsity threshold;
- corrected item-total correlations ranged from 0.394 to 0.682;
- polychoric correlations ranged from 0.464 to 0.769;
- the raw polychoric matrix was positive definite;
- ordinal coefficient alpha was 0.923;
- McDonald’s omega total was 0.923;
- removing any individual item lowered both reliability coefficients;
- all 2,000 final bootstrap resamples completed successfully;
- no bootstrap matrix required smoothing;
- no bootstrap replicate produced a computational warning.

Because omega total was estimated from a one-factor congeneric model, its interpretation will be revisited after the Stage 3 dimensionality analysis.

## Dataset

The project uses the combined **NHANES 2017–March 2020 pre-pandemic release**.

Primary files:

- `P_DPQ.xpt`: Mental Health—Depression Screener
- `P_DEMO.xpt`: demographic and survey-design variables

Participants are linked across files using the respondent identifier `SEQN`.

Raw NHANES files are downloaded programmatically and are not redistributed through this repository.

## Analytic samples

The depression-screener file contains 8,965 adults who were successfully linked to the demographic file.

The primary PHQ-9 descriptive and psychometric sample contains:

- **8,276 participants with valid responses to all nine PHQ-9 items**

The primary functional-difficulty sample contains:

- **5,517 participants with complete PHQ-9 data**;
- at least one endorsed PHQ-9 symptom;
- a valid `DPQ100` response.

A further 2,754 participants reported zero on all nine PHQ-9 items and had `DPQ100` recorded as system missing.

This pattern is consistent with structural questionnaire routing among participants reporting no PHQ-9 symptoms.

These structurally skipped values are not recoded as “not difficult at all.” In extended descriptive tables and figures, they are shown as:

> No PHQ-9 symptoms / DPQ100 structurally skipped

## Measure

The PHQ-9 contains nine items assessing depressive symptoms experienced during the previous two weeks.

Each item is scored from 0 to 3. A complete total score ranges from 0 to 27.

`DPQ100` assesses reported difficulty with work, home responsibilities and relationships. It is analysed separately and is not included in the PHQ-9 total score.

## Clinical interpretation

PHQ-9 scores are self-reported indicators of depressive symptom severity, not diagnoses.

The available data do not establish whether a participant:

- meets diagnostic criteria for a depressive disorder;
- requires treatment;
- would benefit from a particular intervention.

PHQ-9 item 9 concerns thoughts of death or self-harm.

Endorsement is clinically important, but item 9 is not a standalone suicide-risk assessment. It does not establish intent, planning, imminence or overall suicide risk.

## Planned version 1 analyses

Version 1 includes or is planned to include:

- data and codebook audit;
- sample-flow reporting;
- weighted item-response descriptives;
- weighted PHQ-9 total-score and severity-band descriptives;
- item floor-effect and response-category analysis;
- corrected item-total correlations;
- polychoric inter-item correlations;
- ordinal coefficient alpha;
- McDonald’s omega total;
- one-factor dimensionality analysis;
- analysis of PHQ-9 scores in relation to functional difficulty;
- discussion of interpretation and limitations.

Reliability coefficients are reported as evidence of internal consistency, not as evidence that the measure is valid or unidimensional.

## Not included in version 1

Version 1 will not include:

- diagnostic-accuracy analysis;
- sensitivity or specificity estimates;
- claims about treatment need;
- claims that PHQ-9 scores establish a depressive disorder;
- measurement-invariance testing;
- survey-weighted latent-variable modelling.

## Survey weighting and psychometric analysis

Weighted descriptive and functional-difficulty analyses use:

- `WTMECPRP`: combined-cycle examination weight;
- `SDMVSTRA`: masked variance stratum;
- `SDMVPSU`: masked variance primary sampling unit.

Weighted estimates describe the U.S. civilian non-institutionalised adult population represented by the combined pre-pandemic release.

Reliability and dimensionality analyses use the complete-PHQ-9 sample.

Unless survey weights are incorporated into a specific psychometric model, these estimates are described as results for the analytic sample rather than nationally representative latent-variable parameters.

## Repository structure

```text
phq9-nhanes-psychometrics/
├── README.md
├── ANALYSIS_PLAN.md
├── phq9-nhanes-psychometrics.Rproj
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
│   ├── 00_download_data.R
│   ├── 01_clean_data.R
│   ├── 02_descriptives.R
│   ├── 03_reliability.R
│   ├── 04_factor_analysis.R
│   └── 05_figures_tables.R
├── report/
│   ├── report.qmd
│   └── report.html
├── figures/
├── tables/
├── references.bib
├── session-info.txt
├── .gitignore
└── LICENSE
```

## Script order

1. `scripts/00_download_data.R`
2. `scripts/01_clean_data.R`
3. `scripts/02_descriptives.R`
4. `scripts/03_reliability.R`
5. `scripts/04_factor_analysis.R`
6. `scripts/05_figures_tables.R`

Scripts 00 and 01 contain the completed download, linkage, cleaning and data-audit workflow.

Script 02 contains the completed Stage 2A weighted descriptive analyses.

Script 03 contains the completed Stage 2B reliability and item analyses.

Script 04 is reserved for the Stage 3 dimensionality analysis and has not yet been used for substantive analysis.

Script 05 contains the approved Stage 2A and Stage 2B figure-export workflow.

## Project status

### Stage 1: data audit

- [x] Create GitHub repository
- [x] Create local RStudio project
- [x] Add repository folders and files
- [x] Save the analysis plan
- [x] Create the initial README
- [x] Create and render the initial Quarto report
- [x] Download the NHANES source files
- [x] Verify `SEQN` linkage
- [x] Create the PHQ-9 variable dictionary
- [x] Audit response codes and missingness
- [x] Audit the `DPQ100` response pattern
- [x] Produce the initial sample-flow outputs
- [x] Audit survey-design variables
- [x] Save the cleaned data-audit dataset
- [x] Commit and push Stage 1

### Stage 2A: weighted descriptives

- [x] Create the NHANES survey-design object
- [x] Calculate weighted PHQ-9 item-response proportions
- [x] Describe the weighted PHQ-9 total-score distribution
- [x] Calculate the weighted severity-band distribution
- [x] Describe `DPQ100` among routed respondents
- [x] Create the extended functional-difficulty category
- [x] Export descriptive tables and figures
- [x] Update the Quarto report
- [x] Complete the academic-voice and formatting check
- [x] Complete Stage 2A review and validation

### Stage 2B: reliability and item analysis

- [x] Assess item floor effects and category sparsity
- [x] Calculate corrected item-total correlations
- [x] Estimate the polychoric correlation matrix
- [x] Estimate ordinal coefficient alpha
- [x] Estimate McDonald’s omega total
- [x] Examine reliability estimates after removing individual items
- [x] Calculate participant-level bootstrap confidence intervals
- [x] Export Stage 2B tables and figures
- [x] Update the Quarto report
- [x] Complete the academic-voice and formatting check
- [x] Complete Stage 2B review and validation

### Stage 3: dimensionality analysis

- [ ] Lock the Stage 3 analysis plan
- [ ] Create a fixed-seed development and validation split
- [ ] Conduct ordinal parallel analysis
- [ ] Conduct limited exploratory factor analysis
- [ ] Fit the prespecified one-factor ordinal CFA
- [ ] Evaluate global and local model fit
- [ ] Document convergence, thresholds and residual diagnostics
- [ ] Export Stage 3 tables and figures
- [ ] Update the Quarto report
- [ ] Complete Stage 3 review and validation

Stage 3 will not begin until the remaining Stage 2B repository refinements have been completed and verified.

## Application relevance

This project is part of a clinically focused psychology research portfolio.

It is intended to demonstrate skills in:

- psychological assessment;
- reproducible research;
- survey-data handling;
- psychometric analysis;
- statistical programming;
- clinically responsible interpretation.