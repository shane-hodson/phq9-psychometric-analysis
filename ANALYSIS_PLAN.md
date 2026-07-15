# Analysis Plan

**Repository:** `phq9-nhanes-psychometrics`
**Analysis plan version:** 1.1
**Analysis plan date:** 15 July 2026
**Current stage:** Stage 1 data audit complete; Stage 2A weighted descriptives planned.

## 1. Project title

**Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020**

**Subtitle:** *Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation*

## 2. Dataset and cycle

The project uses the publicly available **National Health and Nutrition Examination Survey 2017–March 2020 pre-pandemic release**.

The primary files are:

* `P_DPQ.xpt`: Mental Health—Depression Screener
* `P_DEMO.xpt`: demographic and survey-design variables

Additional questionnaire files may be imported only after a separate external-variable audit.

The completed 2017–2018 cycle and the partial 2019–March 2020 cycle are treated as one combined pre-pandemic release. The partial 2019–March 2020 data will not be analysed independently.

## 3. Current analytic sample definitions

Stage 1 established the following sample definitions.

The depression-screener file contains:

* `P_DPQ` records: 8,965
* `P_DEMO` records: 15,560
* adults aged 18 or older in `P_DEMO`: 9,693
* `P_DPQ` records successfully linked to `P_DEMO`: 8,965
* duplicate `SEQN` values: 0 in both files
* unmatched `P_DPQ` records: 0

The primary complete-PHQ-9 sample is defined as:

* adults with valid responses from 0 to 3 on all nine PHQ-9 items;
* linked to `P_DEMO` using `SEQN`;
* with valid survey-design variables available for weighted analyses.

This sample contains:

* **8,276 adults with complete PHQ-9 data**

The primary functional-difficulty sample is defined as:

* adults with complete PHQ-9 data;
* at least one endorsed PHQ-9 symptom;
* a valid `DPQ100` response.

This sample contains:

* **5,517 adults with complete PHQ-9 data and valid `DPQ100`**

Analysis-specific samples will be reported for:

1. item-level descriptive analyses;
2. complete-PHQ-9 reliability and dimensionality analyses;
3. functional-difficulty analyses;
4. any optional external-variable analyses.

All sample sizes will be reported before and after exclusions.

## 4. PHQ-9 variables and items

The nine PHQ-9 symptom items are:

| Variable | Symptom content                  |
| -------- | -------------------------------- |
| `DPQ010` | Little interest or pleasure      |
| `DPQ020` | Depressed mood or hopelessness   |
| `DPQ030` | Sleep disturbance                |
| `DPQ040` | Tiredness or low energy          |
| `DPQ050` | Appetite disturbance             |
| `DPQ060` | Negative self-evaluation         |
| `DPQ070` | Concentration difficulties       |
| `DPQ080` | Psychomotor slowing or agitation |
| `DPQ090` | Thoughts of death or self-harm   |

Responses are scored:

* 0: not at all
* 1: several days
* 2: more than half the days
* 3: nearly every day

A complete PHQ-9 total score ranges from 0 to 27.

`DPQ100` measures reported difficulty with work, home responsibilities and relationships. It is not included in the PHQ-9 total score and will be treated as the primary external functional variable.

## 5. DPQ100 routing decision

Stage 1 found that:

* 2,754 participants had valid zero responses on all nine PHQ-9 items;
* all 2,754 had `DPQ100` recorded as system missing;
* among participants endorsing at least one PHQ-9 symptom, 5,517 had a valid `DPQ100` response;
* among participants endorsing at least one PHQ-9 symptom, only one had system-missing `DPQ100`.

This pattern is consistent with structural questionnaire routing among participants reporting no PHQ-9 symptoms.

Structurally skipped `DPQ100` values will not be recoded as “not at all difficult.”

For the primary functional-difficulty analysis, `DPQ100` analyses will use participants with:

* complete PHQ-9 data;
* at least one endorsed PHQ-9 symptom;
* valid `DPQ100`.

For descriptive sensitivity tables and figures, structurally skipped values may be shown as a separate category:

> No PHQ-9 symptoms / DPQ100 structurally skipped

This category will be treated as an extended descriptive classification, not as an original `DPQ100` response category.

## 6. External variables to audit first

### Required for version 1

* `DPQ100`: functional difficulty

### Secondary candidates

* `HUQ010`: self-rated general health
* `HUQ090`: contact with a mental-health professional during the previous year
* `SLD012`: usual weekday or workday sleep duration
* `SLQ050`: reported trouble sleeping to a health professional
* `SLQ120`: frequency of excessive daytime sleepiness

Only `DPQ100` is required for project completion.

Secondary variables will be included only when:

* their coding and skip patterns are sufficiently clear;
* the available sample size remains adequate;
* the analysis contributes to interpretation of PHQ-9 scores as symptom-severity indicators or functional-impairment indicators;
* conceptual overlap with PHQ-9 items is acknowledged.

Sleep variables will be treated as exploratory because sleep and fatigue are already represented within the PHQ-9.

## 7. Research questions

1. What are the distributions, endorsement rates and missingness patterns of the nine PHQ-9 items?
2. How consistently do the PHQ-9 items measure depressive symptom severity?
3. Are the inter-item relationships compatible with a one-factor representation of depressive symptom severity?
4. How are PHQ-9 scores associated with reported functional difficulty?
5. What clinical interpretations are supported by the findings, and what interpretations are not supported?

## 8. Exclusion and missing-data rules

* Restrict the main sample to participants aged 18 years or older.
* Link files using `SEQN`.
* Check for duplicate or unmatched identifiers before analysis.
* Recode refusal, “don’t know” and system-missing values as `NA`.
* Never treat non-substantive response codes such as 7 or 9 as symptom scores.
* Use all available valid responses for item-specific descriptive analyses.
* Calculate the primary PHQ-9 total only when all nine items have valid scores from 0 to 3.
* Do not prorate incomplete PHQ-9 scores in the primary analysis.
* Do not impute missing PHQ-9 items in version 1.
* Use complete PHQ-9 cases for reliability, polychoric-correlation and dimensionality analyses.
* Do not automatically treat structurally skipped `DPQ100` responses as ordinary missing values.
* Use analysis-specific complete cases for secondary external variables.
* Report the number and percentage excluded under each major rule.
* Compare the retained complete-PHQ-9 sample with excluded participants on basic demographic variables where feasible.

## 9. Completed Stage 1 analyses

Stage 1 has been completed.

Completed work includes:

* programmatic download of `P_DPQ.xpt` and `P_DEMO.xpt`;
* source-file inspection;
* `SEQN` linkage verification;
* PHQ-9 variable dictionary;
* response-code audit;
* missingness audit;
* `DPQ100` routing audit;
* sample-flow output;
* survey-design variable audit;
* local recoding of non-substantive questionnaire codes as missing.

Stage 1 established that:

* `P_DPQ` contains 8,965 unique respondents;
* all `P_DPQ` respondents link successfully to `P_DEMO`;
* 8,276 respondents have valid responses to all nine PHQ-9 items;
* 5,517 respondents have both complete PHQ-9 data and valid `DPQ100`;
* non-substantive questionnaire values must be recoded as missing before later analysis;
* `DPQ100` system missingness is strongly associated with reporting zero on all nine symptom items;
* all required survey-design variables are available.

## 10. Planned Stage 2A analyses

Stage 2A will focus on weighted descriptive analyses and sample reporting.

Stage 2A will produce:

* NHANES survey design object;
* weighted PHQ-9 item-response proportions;
* weighted PHQ-9 total-score distribution;
* weighted symptom-severity band estimates;
* weighted `DPQ100` descriptives among routed respondents;
* extended functional-difficulty table including structural skips as a separate category;
* exported descriptive tables;
* exported figures;
* updated Quarto report section.

Stage 2A will not include reliability analysis, omega, polychoric correlations, factor analysis, functional-difficulty modelling or clinical interpretation.

## 11. Later planned analyses

### 11.1 Reliability and item analysis

Later reliability and item analyses will include:

* ordinal coefficient alpha;
* McDonald’s omega;
* corrected item-total correlations;
* polychoric inter-item correlations;
* inspection of floor effects and sparse response categories;
* examination of reliability if individual items are removed.

Reliability coefficients will be reported as evidence of internal consistency, not as evidence that the measure is valid or unidimensional.

### 11.2 One-factor dimensionality analysis

Version 1 will evaluate whether the PHQ-9 data are compatible with a single general factor.

The dimensionality analysis will include:

* polychoric correlation matrix;
* parallel-analysis evidence where appropriate;
* one-factor exploratory or confirmatory ordinal factor analysis;
* ordinal estimation for four-category items;
* standardised factor loadings;
* relevant model-fit indices;
* assessment of localised areas of poor fit;
* interpretation of whether a one-factor summary score is defensible.

A two-factor or bifactor model is not required for version 1. Alternative models may be considered only as extensions where the one-factor analysis indicates a clear and theoretically interpretable problem.

### 11.3 Functional-difficulty association

The relationship between PHQ-9 symptom severity and `DPQ100` will be examined using:

* weighted PHQ-9 estimates across functional-difficulty categories;
* visualisation of the score–difficulty relationship;
* survey-weighted ordinal logistic regression, subject to assumption checks;
* effect estimates with uncertainty intervals;
* interpretation as evidence about the relationship between symptom scores and reported functional impairment.

If ordinal model assumptions are not acceptable, an alternative survey-aware model will be selected and documented before interpretation.

### 11.4 Limitations and clinical interpretation

The discussion will address:

* cross-sectional design;
* self-report measurement;
* missingness and complete-case selection;
* lack of an independent diagnostic interview;
* population rather than clinical sampling;
* limits to generalisation outside the United States;
* differences between symptom measurement and diagnosis;
* limitations of conventional severity thresholds;
* the particular sensitivity and interpretation of item 9.

## 12. Weighted descriptive analyses versus psychometric modelling

### Weighted analyses

Population-description and functional-association analyses will use the NHANES complex survey design:

* weight: `WTMECPRP`
* strata: `SDMVSTRA`
* cluster: `SDMVPSU`

These analyses will be implemented using packages such as `survey` or `srvyr`.

Weighted analyses will support estimates for the U.S. civilian non-institutionalised adult population represented by the combined 2017–March 2020 pre-pandemic release.

### Psychometric modelling

The primary reliability, polychoric-correlation and factor analyses will be conducted in the complete-PHQ-9 psychometric sample.

Version 1 will not claim that unweighted psychometric estimates are nationally representative latent-variable parameters. The report will clearly distinguish:

* survey-weighted population descriptions;
* sample-based psychometric modelling.

Survey-weighted latent-variable modelling is outside the version 1 scope.

## 13. Clinical interpretation note

PHQ-9 scores will be interpreted as self-reported indicators of recent depressive symptom severity. They will not be presented as psychiatric diagnoses.

A high PHQ-9 score may indicate a need for further assessment, but the dataset does not permit claims that a participant met diagnostic criteria, required treatment or would benefit from a particular intervention.

`DPQ090`, corresponding to PHQ-9 item 9, concerns thoughts of death or self-harm. Endorsement is clinically important, but item 9 is not a standalone suicide-risk assessment. It does not establish intent, planning, imminence or overall level of suicide risk.

## 14. Version 1 minimum viable analysis

Project 1 version 1 will be considered analytically complete when it contains:

1. a documented data and codebook audit;
2. a transparent sample-flow table;
3. weighted item-level and total-score descriptives;
4. ordinal coefficient alpha;
5. McDonald’s omega;
6. corrected item-total correlations;
7. a polychoric correlation matrix;
8. a one-factor dimensionality analysis;
9. an analysis of the association between PHQ-9 scores and functional difficulty;
10. a limitations and interpretation section that distinguishes symptom severity, functional impairment and diagnosis.

## 15. Not included in version 1

Version 1 will not include:

* diagnostic-accuracy analysis;
* sensitivity or specificity estimates;
* claims about whether participants need treatment;
* claims that PHQ-9 scores establish a depressive disorder;
* measurement-invariance testing;
* survey-weighted latent-variable modelling.

These exclusions prevent the project from making claims that the available data cannot adequately support and keep the initial project realistic.

## 16. Optional extensions

Potential extensions after version 1 is complete include:

* comparison of one-factor and theoretically justified two-factor models;
* PHQ-8 sensitivity analysis excluding item 9;
* subgroup descriptives;
* measurement invariance across sex or broad age groups;
* secondary associations with general health;
* secondary associations with mental-health professional contact;
* exploratory sleep-related analyses;
* survey-weighted reliability estimates;
* survey-weighted latent-variable modelling;
* replication using another NHANES cycle.

Measurement invariance is an extension and is not required for completion.

## 17. Repository structure

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

## 18. Execution checklist

### Stage 1: data audit

* [x] Create GitHub repository and local RStudio project
* [x] Add the approved directory structure
* [x] Save the analysis plan
* [x] Create a skeleton `README.md`
* [x] Create the six numbered R scripts
* [x] Create and render a minimal `report/report.qmd`
* [x] Download `P_DPQ.xpt` and `P_DEMO.xpt` programmatically
* [x] Import and inspect both files
* [x] Verify file linkage using `SEQN`
* [x] Create a PHQ-9 variable dictionary
* [x] Audit all item response codes
* [x] Audit missingness and the `DPQ100` skip pattern
* [x] Construct and document the eligible analytic samples
* [x] Configure and audit the NHANES survey-design variables
* [x] Produce the first sample-flow and missingness outputs
* [x] Commit the completed data-audit stage before starting reliability analysis

### Stage 2A: weighted descriptives

* [ ] Create the NHANES survey-design object
* [ ] Calculate weighted PHQ-9 item-response proportions
* [ ] Describe the weighted PHQ-9 total-score distribution
* [ ] Calculate the weighted symptom-severity band distribution
* [ ] Describe `DPQ100` among routed respondents
* [ ] Create the extended functional-difficulty category
* [ ] Export descriptive tables and figures
* [ ] Update the Quarto report
* [ ] Complete the academic-voice and formatting check
* [ ] Submit Stage 2A for Command Centre review

Reliability, omega, polychoric correlations, factor analysis and functional-difficulty modelling will not begin until Stage 2A has been reviewed.
