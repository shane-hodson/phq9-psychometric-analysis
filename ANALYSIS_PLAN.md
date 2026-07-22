# Analysis Plan

**Repository:** `phq9-nhanes-psychometrics`  
**Analysis plan version:** 1.3  
**Last updated:** 22 July 2026  
**Current stage:** Stage 2A weighted descriptives complete and approved; Stage 2B reliability and item analysis planned.

## 1. Project title

**Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020**

**Subtitle:** *Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation*

## 2. Dataset and cycle

The project uses the publicly available **National Health and Nutrition Examination Survey 2017–March 2020 pre-pandemic release**.

The primary files are:

- `P_DPQ.xpt`: Mental Health—Depression Screener
- `P_DEMO.xpt`: demographic and survey-design variables

Additional questionnaire files may be imported only after a separate external-variable audit.

The completed 2017–2018 cycle and the partial 2019–March 2020 cycle are treated as one combined pre-pandemic release. The partial 2019–March 2020 data will not be analysed independently.

## 3. Current analytic sample definitions

Stage 1 established the following sample characteristics:

- `P_DPQ` records: 8,965
- `P_DEMO` records: 15,560
- adults aged 18 years or older in `P_DEMO`: 9,693
- `P_DPQ` records successfully linked to `P_DEMO`: 8,965
- duplicate `SEQN` values: 0 in both files
- unmatched `P_DPQ` records: 0

### Complete-PHQ-9 sample

The primary complete-PHQ-9 sample is defined as adults who:

- have valid responses from 0 to 3 on all nine PHQ-9 items;
- are linked to `P_DEMO` using `SEQN`;
- have valid survey-design variables available for weighted analyses.

This sample contains:

- **8,276 adults with complete PHQ-9 data**

This sample is used for:

- weighted PHQ-9 total-score descriptives;
- weighted symptom-severity band estimates;
- reliability and item analysis;
- polychoric correlations;
- later dimensionality analysis.

### Symptom-positive complete-PHQ-9 sample

Among participants with complete PHQ-9 data:

- **5,522 endorsed at least one PHQ-9 symptom**
- **2,754 scored zero on all nine PHQ-9 items**

### Primary functional-difficulty sample

The primary functional-difficulty sample is defined as adults who:

- have complete PHQ-9 data;
- endorsed at least one PHQ-9 symptom;
- have a valid `DPQ100` response.

This sample contains:

- **5,517 adults with complete PHQ-9 data, at least one endorsed symptom and valid `DPQ100`**

Five symptom-positive participants with complete PHQ-9 data did not have a valid `DPQ100` response.

Analysis-specific sample sizes will be reported for:

1. item-level descriptive analyses;
2. complete-PHQ-9 reliability and dimensionality analyses;
3. functional-difficulty analyses;
4. any optional external-variable analyses.

All major exclusions and analysis-specific sample sizes will be reported.

## 4. PHQ-9 variables and items

The nine PHQ-9 symptom items are:

| Variable | Symptom content |
|---|---|
| `DPQ010` | Little interest or pleasure |
| `DPQ020` | Depressed mood or hopelessness |
| `DPQ030` | Sleep disturbance |
| `DPQ040` | Tiredness or low energy |
| `DPQ050` | Appetite disturbance |
| `DPQ060` | Negative self-evaluation |
| `DPQ070` | Concentration difficulties |
| `DPQ080` | Psychomotor slowing or agitation |
| `DPQ090` | Thoughts of death or self-harm |

Responses are scored:

- 0: not at all
- 1: several days
- 2: more than half the days
- 3: nearly every day

A complete PHQ-9 total score ranges from 0 to 27.

`DPQ100` measures reported difficulty with work, home responsibilities and relationships. It is not included in the PHQ-9 total score and is treated as the primary external functional variable.

## 5. DPQ100 routing decision

Stage 1 found that:

- 2,754 participants had valid zero responses on all nine PHQ-9 items;
- all 2,754 had `DPQ100` recorded as system missing;
- 5,522 participants had complete PHQ-9 data and endorsed at least one symptom;
- 5,517 of these participants had a valid `DPQ100` response;
- five symptom-positive participants did not have a valid `DPQ100` response.

The observed pattern is consistent with structural questionnaire routing among participants reporting no PHQ-9 symptoms.

Structurally skipped `DPQ100` values will not be recoded as “not difficult at all.”

The primary functional-difficulty analysis will use participants with:

- complete PHQ-9 data;
- at least one endorsed PHQ-9 symptom;
- valid `DPQ100`.

For extended descriptive tables and figures, structurally skipped responses are shown as a separate category:

> No PHQ-9 symptoms / DPQ100 structurally skipped

The five symptom-positive participants without a valid `DPQ100` response are also shown separately where complete sample accounting is required.

Neither structural skips nor missing responses are treated as observed `DPQ100` response categories.

## 6. External variables

### Required for version 1

- `DPQ100`: functional difficulty

### Secondary candidates

- `HUQ010`: self-rated general health
- `HUQ090`: contact with a mental-health professional during the previous year
- `SLD012`: usual weekday or workday sleep duration
- `SLQ050`: reported trouble sleeping to a health professional
- `SLQ120`: frequency of excessive daytime sleepiness

Only `DPQ100` is required for version 1.

A secondary variable will be included only when:

- its coding and questionnaire routing are sufficiently clear;
- the available sample remains adequate;
- it addresses a defined question about PHQ-9 symptom scores or reported functioning;
- conceptual overlap with PHQ-9 item content is acknowledged.

Sleep variables will be treated as exploratory because sleep disturbance and fatigue are already represented within the PHQ-9.

## 7. Research questions

1. What are the weighted response distributions, endorsement rates and missingness patterns of the nine PHQ-9 items?
2. What is the weighted distribution of PHQ-9 total scores and conventional symptom-severity bands?
3. How consistently do the nine PHQ-9 items measure depressive symptom severity?
4. Are the inter-item relationships compatible with a one-factor representation of depressive symptom severity?
5. How are PHQ-9 scores associated with reported functional difficulty?
6. What conclusions about symptom severity and functioning are supported, and which diagnostic or treatment-related conclusions are not supported?

## 8. Exclusion and missing-data rules

- Restrict the main sample to participants aged 18 years or older.
- Link files using `SEQN`.
- Check for duplicate and unmatched identifiers before analysis.
- Treat refusal, “don’t know” and system-missing responses as missing values.
- Never treat non-substantive response codes such as 7 or 9 as symptom scores.
- Use all available valid responses for item-specific descriptive analyses.
- Calculate the primary PHQ-9 total only when all nine items have valid scores from 0 to 3.
- Do not prorate incomplete PHQ-9 scores.
- Do not impute missing PHQ-9 items in version 1.
- Use complete PHQ-9 cases for reliability, polychoric-correlation and dimensionality analyses.
- Do not recode structurally skipped `DPQ100` values as zero or as “not difficult at all.”
- Use participants with complete PHQ-9 data, at least one endorsed symptom and valid `DPQ100` for the primary functional-difficulty analysis.
- Use analysis-specific complete cases for secondary external variables.
- Report the number and percentage excluded under each major rule.
- Compare the retained complete-PHQ-9 sample with excluded participants on basic demographic variables where feasible.

## 9. Completed Stage 1 analyses

Stage 1 has been completed and approved.

Completed work includes:

- programmatic download of `P_DPQ.xpt` and `P_DEMO.xpt`;
- source-file inspection;
- `SEQN` linkage verification;
- PHQ-9 variable dictionary;
- response-code audit;
- missingness audit;
- `DPQ100` routing audit;
- sample-flow output;
- survey-design variable audit;
- local recoding of non-substantive questionnaire codes as missing.

Stage 1 established that:

- `P_DPQ` contains 8,965 unique respondents;
- all `P_DPQ` respondents link successfully to `P_DEMO`;
- 8,276 respondents have valid responses to all nine PHQ-9 items;
- 5,522 complete-PHQ-9 respondents endorsed at least one symptom;
- 5,517 respondents have complete PHQ-9 data, at least one endorsed symptom and valid `DPQ100`;
- 2,754 symptom-free respondents have structurally skipped `DPQ100`;
- non-substantive questionnaire responses must be treated as missing before analysis;
- all required survey-design variables are available.

## 10. Completed Stage 2A analyses

Stage 2A weighted descriptive analysis has been completed and approved.

### 10.1 Survey design

The NHANES complex survey-design object was created using:

- examination weight: `WTMECPRP`
- masked variance stratum: `SDMVSTRA`
- masked variance primary sampling unit: `SDMVPSU`
- PSU identifiers nested within strata

The design contains 49 nested PSUs across 24 strata.

Analysis-specific samples were defined as survey domains after construction of the full survey-design object.

### 10.2 Completed descriptive outputs

Stage 2A produced:

- weighted PHQ-9 item-response proportions;
- weighted PHQ-9 total-score summaries and distribution;
- weighted conventional symptom-severity band estimates;
- weighted `DPQ100` descriptives among routed respondents;
- an extended functional-difficulty table including structural skips and missing responses as separate categories;
- exported descriptive tables;
- five exported descriptive figures;
- an updated Quarto report.

Stage 2A retained structurally skipped `DPQ100` responses as a separate descriptive category rather than treating them as observed functional-difficulty responses.

### 10.3 Selected Stage 2A results

In the complete-PHQ-9 sample of 8,276 adults:

- weighted mean PHQ-9 total: 3.18
- 95% confidence interval for the weighted mean: 3.06–3.31
- weighted standard deviation: 4.09
- weighted minimal band: 74.92%
- weighted mild band: 16.54%
- weighted moderate band: 5.95%
- weighted moderately severe band: 1.81%
- weighted severe band: 0.78%

Among the 5,517 routed respondents with valid `DPQ100`:

- not difficult at all: 74.64%
- somewhat difficult: 20.79%
- very difficult: 3.40%
- extremely difficult: 1.17%

These results are descriptive. Stage 2A did not estimate reliability, test dimensionality, model the relationship between PHQ-9 scores and functional difficulty, or draw diagnostic conclusions.

## 11. Planned Stage 2B: Reliability and item analysis

Stage 2B will use the complete-PHQ-9 sample of 8,276 participants.

Stage 2B will include:

- item floor effects;
- response-category sparsity;
- corrected item-total correlations;
- polychoric inter-item correlations;
- ordinal coefficient alpha;
- McDonald’s omega;
- reliability estimates after removing individual items where methodologically informative;
- uncertainty intervals where feasible;
- exported reliability and item-analysis tables;
- any figures needed to communicate the results;
- an updated Quarto report section.

The estimation method used for each reliability coefficient will be documented.

Item-removal statistics will be treated as diagnostic information. They will not be used as an automatic basis for recommending deletion of PHQ-9 items.

Reliability coefficients will be reported as evidence of internal consistency, not as evidence that the PHQ-9 is valid or unidimensional.

Stage 2B will not include:

- exploratory or confirmatory factor analysis;
- measurement invariance;
- functional-difficulty regression modelling;
- diagnostic interpretation;
- treatment-need claims;
- substantive clinical interpretation.

## 12. Later planned analyses

### 12.1 Stage 3: One-factor dimensionality analysis

Stage 3 will evaluate whether the PHQ-9 data are compatible with a single general factor.

The planned dimensionality analysis will include:

- review of the polychoric correlation matrix;
- parallel-analysis evidence where appropriate;
- a one-factor ordinal factor model;
- an estimator appropriate for four-category ordered items;
- standardised factor loadings;
- relevant model-fit indices;
- assessment of localised areas of poor fit;
- evaluation of whether a one-factor model provides an adequate summary of the item structure.

A two-factor or bifactor model is not required for version 1. Alternative models may be considered only if the one-factor model shows a clear and theoretically interpretable area of poor fit.

### 12.2 Functional-difficulty association

The relationship between PHQ-9 symptom severity and `DPQ100` will be examined using:

- weighted PHQ-9 estimates across functional-difficulty categories;
- visualisation of the score–difficulty relationship;
- survey-weighted ordinal logistic regression with `DPQ100` as the ordered outcome and PHQ-9 total score as the main predictor;
- assessment of the proportional-odds assumption;
- effect estimates with confidence intervals.

If the proportional-odds assumption is not supported, a less restrictive survey-weighted model will be selected and documented before inferential results are interpreted.

Results will be interpreted as evidence about the relationship between symptom scores and reported functional impairment, rather than evidence of diagnostic accuracy.

### 12.3 Limitations and interpretation

The discussion will address:

- the cross-sectional design;
- self-reported symptoms;
- missingness and complete-case selection;
- the absence of an independent diagnostic interview;
- the use of a population rather than clinical sample;
- limits to generalisation outside the United States;
- the distinction between symptom severity and psychiatric diagnosis;
- limitations of conventional severity thresholds;
- interpretation of PHQ-9 item 9;
- the distinction between statistical associations and clinical decisions.

## 13. Weighted analyses and psychometric modelling

### Weighted analyses

Population-description and functional-association analyses use the NHANES complex survey design:

- weight: `WTMECPRP`
- strata: `SDMVSTRA`
- cluster: `SDMVPSU`

These analyses are implemented using the `survey` and/or `srvyr` packages.

Weighted estimates describe the U.S. civilian non-institutionalised adult population represented by the combined 2017–March 2020 pre-pandemic release.

### Psychometric analyses

Reliability, polychoric correlations and factor analysis will use the complete-PHQ-9 analytic sample.

Unless survey weights are incorporated into a specific psychometric model, resulting parameters will be described as estimates for the analytic sample rather than as nationally representative latent-variable parameters.

The report will distinguish:

- survey-weighted population descriptions;
- sample-based psychometric estimates.

Survey-weighted latent-variable modelling is outside the version 1 scope.

## 14. Clinical interpretation

PHQ-9 scores will be interpreted as **self-reported indicators of recent depressive symptom severity**. They will not be presented as psychiatric diagnoses.

The dataset does not establish whether a participant met diagnostic criteria for a depressive disorder, required treatment or would benefit from a particular intervention.

`DPQ090`, corresponding to PHQ-9 item 9, concerns thoughts of death or self-harm. Endorsement is clinically important, but item 9 is not a standalone suicide-risk assessment. It does not establish intent, planning, imminence or overall suicide risk.

## 15. Version 1 completion criteria

Version 1 will contain:

1. a documented data and codebook audit;
2. a transparent sample-flow table;
3. weighted item-response descriptives;
4. weighted PHQ-9 total-score and severity-band descriptives;
5. item floor-effect and category-sparsity assessment;
6. corrected item-total correlations;
7. ordinal coefficient alpha;
8. McDonald’s omega;
9. a polychoric correlation matrix;
10. a one-factor dimensionality analysis;
11. an analysis of PHQ-9 scores in relation to functional difficulty;
12. a discussion of interpretation and limitations.

## 16. Not included in version 1

Version 1 will not include:

- diagnostic-accuracy analysis;
- sensitivity or specificity estimates;
- claims about whether participants need treatment;
- claims that PHQ-9 scores establish a depressive disorder;
- measurement-invariance testing;
- survey-weighted latent-variable modelling.

These exclusions reflect the information available in the dataset and the defined scope of the project.

## 17. Optional extensions

Potential extensions after version 1 is complete include:

- comparison of one-factor and theoretically justified two-factor models;
- PHQ-8 sensitivity analysis excluding item 9;
- subgroup descriptives;
- measurement invariance across sex or broad age groups;
- secondary associations with general health;
- secondary associations with mental-health professional contact;
- exploratory sleep-related analyses;
- survey-weighted reliability estimates;
- survey-weighted latent-variable modelling;
- replication using another NHANES cycle.

Measurement invariance is an extension and is not required for version 1.

## 18. Repository structure

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

## 19. Execution checklist

### Stage 1: data audit

- [x] Create the GitHub repository and local RStudio project.
- [x] Add the approved directory structure.
- [x] Save the analysis plan.
- [x] Create the initial `README.md`.
- [x] Create the six numbered R scripts.
- [x] Create and render the initial `report/report.qmd`.
- [x] Download `P_DPQ.xpt` and `P_DEMO.xpt` programmatically.
- [x] Import and inspect both files.
- [x] Verify file linkage using `SEQN`.
- [x] Create a PHQ-9 variable dictionary.
- [x] Audit all item response codes.
- [x] Audit missingness and the `DPQ100` response pattern.
- [x] Construct and document the eligible analytic samples.
- [x] Audit the NHANES survey-design variables.
- [x] Produce the initial sample-flow and missingness outputs.
- [x] Commit and obtain approval for Stage 1.

### Stage 2A: weighted descriptives

- [x] Create the NHANES survey-design object.
- [x] Calculate weighted PHQ-9 item-response proportions.
- [x] Describe the weighted PHQ-9 total-score distribution.
- [x] Calculate the weighted symptom-severity band distribution.
- [x] Describe `DPQ100` among routed respondents.
- [x] Create the extended functional-difficulty category including structural skips.
- [x] Export descriptive tables and figures.
- [x] Update the Quarto report.
- [x] Complete the academic-voice and formatting check.
- [x] Obtain Command Centre approval.

### Stage 2B: reliability and item analysis

- [ ] Assess item floor effects and response-category sparsity.
- [ ] Calculate corrected item-total correlations.
- [ ] Estimate the polychoric correlation matrix.
- [ ] Estimate ordinal coefficient alpha.
- [ ] Estimate McDonald’s omega.
- [ ] Examine reliability estimates after removing individual items where methodologically informative.
- [ ] Calculate uncertainty intervals where feasible.
- [ ] Export Stage 2B tables and any necessary figures.
- [ ] Update the Quarto report.
- [ ] Complete the academic-voice, methodological-language and formatting check.
- [ ] Submit Stage 2B for Command Centre review.

Stage 2A has been approved. Stage 2B is limited to reliability and item analysis. Factor analysis, confirmatory modelling, measurement invariance, functional-difficulty regression modelling and clinical interpretation will not begin until Stage 2B has been reviewed.