# Project 1 Protocol

**Repository:** `phq9-psychometric-analysis`  
**Protocol version:** 1.0  
**Protocol date:** 15 July 2026

## 1. Project title

**Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020**

**Subtitle:** *Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation*

## 2. Dataset and cycle

The project will use the publicly available **National Health and Nutrition Examination Survey 2017–March 2020 pre-pandemic release**.

The primary files are:

- `P_DPQ.xpt`: Mental Health—Depression Screener
- `P_DEMO.xpt`: Demographic and survey-design variables

Additional questionnaire files may be imported only after the planned external-variable audit.

The completed 2017–2018 cycle and the partial 2019–March 2020 cycle will be treated as one combined pre-pandemic release. The partial 2019–March 2020 data will not be analysed independently.

## 3. Target analytic sample

The target sample is NHANES participants who:

- are aged 18 years or older;
- appear in the depression screener file;
- can be linked to the demographic file using `SEQN`;
- have valid survey-design variables for weighted analyses.

Separate analysis-specific samples will be reported for:

1. item-level descriptive analyses;
2. complete PHQ-9 reliability and dimensionality analyses;
3. functional-difficulty analyses;
4. any optional external-variable analyses.

The report will include a transparent sample-flow table showing the number of participants retained and excluded at each stage.

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

- 0: not at all;
- 1: several days;
- 2: more than half the days;
- 3: nearly every day.

A complete PHQ-9 total score ranges from 0 to 27.

`DPQ100` measures reported difficulty with work, home responsibilities and relationships. It is not included in the PHQ-9 total and will be treated as the primary external functional variable.

## 5. External validation variables to audit first

### Required for version 1

- `DPQ100`: functional difficulty

### Secondary candidates

- `HUQ010`: self-rated general health
- `HUQ090`: contact with a mental-health professional during the previous year
- `SLD012`: usual weekday or workday sleep duration
- `SLQ050`: reported trouble sleeping to a health professional
- `SLQ120`: frequency of excessive daytime sleepiness

Only `DPQ100` is required for project completion.

Secondary variables will be included only when:

- their coding and skip patterns are sufficiently clear;
- the available sample size remains adequate;
- the analysis adds clinically meaningful evidence;
- conceptual overlap with PHQ-9 items is acknowledged.

Sleep variables will be treated as exploratory because sleep and fatigue are already represented within the PHQ-9.

## 6. Research questions

1. What are the distributions, endorsement rates and missingness patterns of the nine PHQ-9 items?
2. How consistently do the PHQ-9 items measure depressive symptom severity?
3. Are the inter-item relationships compatible with a one-factor representation of depressive symptom severity?
4. How are PHQ-9 scores associated with reported functional difficulty?
5. What clinical interpretations are supported by the findings, and what interpretations are not supported?

## 7. Exclusion and missing-data rules

- Restrict the main sample to participants aged 18 years or older.
- Link files using `SEQN`.
- Check for duplicate or unmatched identifiers before analysis.
- Recode refusal, "don't know" and system-missing values as `NA`.
- Never treat non-substantive response codes such as 7 or 9 as symptom scores.
- Use all available valid responses for item-specific descriptive analyses.
- Calculate the primary PHQ-9 total only when all nine items have valid scores from 0 to 3.
- Do not prorate incomplete PHQ-9 scores in the primary analysis.
- Do not impute missing PHQ-9 items in version 1.
- Use complete PHQ-9 cases for reliability, polychoric-correlation and dimensionality analyses.
- Audit the `DPQ100` skip pattern before defining its analysis sample.
- Do not automatically treat structurally skipped `DPQ100` responses as ordinary missing values.
- Use analysis-specific complete cases for secondary external variables.
- Report the number and percentage excluded under each rule.
- Compare the retained complete-PHQ-9 sample with excluded participants on basic demographic variables where feasible.

## 8. Planned analyses

### 8.1 Data audit and sample flow

- inspect file dimensions and variable labels;
- verify coding ranges;
- verify linkage using `SEQN`;
- identify missing, refused and "don't know" responses;
- inspect the `DPQ100` skip pattern;
- document sample construction;
- produce a sample-flow table.

### 8.2 Weighted descriptive analyses

Using the NHANES complex survey design:

- weighted response proportions for each PHQ-9 item;
- weighted PHQ-9 total-score distribution;
- weighted conventional symptom-severity categories;
- weighted distribution of functional difficulty;
- 95% confidence intervals where appropriate;
- clear reporting of unweighted sample counts alongside weighted estimates.

### 8.3 Reliability and item analysis

- ordinal coefficient alpha;
- McDonald's omega;
- corrected item-total correlations;
- polychoric inter-item correlations;
- inspection of floor effects and sparse response categories;
- cautious examination of reliability if individual items are removed.

Reliability coefficients will not be treated as proof of validity or unidimensionality.

### 8.4 One-factor dimensionality analysis

Version 1 will evaluate whether the PHQ-9 data are compatible with a single general factor.

The analysis will include:

- polychoric correlation matrix;
- parallel-analysis evidence where appropriate;
- one-factor exploratory or confirmatory ordinal factor analysis;
- ordinal estimation appropriate for four-category items;
- standardised factor loadings;
- relevant model-fit indices;
- assessment of localised areas of poor fit;
- cautious interpretation of whether a one-factor summary score is defensible.

A two-factor or bifactor model is not required for version 1. Alternative models may be considered only as extensions where the one-factor analysis indicates a clear and theoretically interpretable problem.

### 8.5 Functional-difficulty association

The relationship between PHQ-9 symptom severity and `DPQ100` will be examined using:

- weighted PHQ-9 estimates across functional-difficulty categories;
- visualisation of the score-difficulty relationship;
- an appropriate survey-aware association model;
- effect estimates with uncertainty intervals;
- cautious interpretation as functional-validity evidence rather than diagnostic validation.

### 8.6 Limitations and clinical interpretation

The report will address:

- cross-sectional design;
- self-report measurement;
- missingness and complete-case selection;
- lack of an independent diagnostic interview;
- population rather than clinical sampling;
- limits to generalisation outside the United States;
- differences between symptom measurement and diagnosis;
- limitations of conventional severity thresholds;
- the particular sensitivity and interpretation of item 9.

## 9. Weighted descriptive analyses versus psychometric modelling

### Weighted analyses

Population-description and functional-association analyses will use the NHANES complex survey design:

- weight: `WTMECPRP`;
- strata: `SDMVSTRA`;
- cluster: `SDMVPSU`.

These analyses will be implemented using packages such as `survey` or `srvyr`.

Weighted analyses will support estimates for the U.S. civilian non-institutionalised adult population represented by the combined 2017–March 2020 pre-pandemic release.

### Psychometric modelling

The primary reliability, polychoric-correlation and factor analyses will be conducted in the complete-case psychometric sample.

Version 1 will not claim that unweighted psychometric estimates are nationally representative latent-variable parameters. The report will clearly distinguish:

- survey-weighted population descriptions;
- sample-based psychometric modelling.

Survey-weighted latent-variable modelling is outside the version 1 scope.

## 10. Clinical interpretation note

PHQ-9 scores will be interpreted as **self-reported indicators of recent depressive symptom severity**. They will not be presented as psychiatric diagnoses.

A high PHQ-9 score may indicate a need for further assessment, but the dataset does not permit claims that a participant met diagnostic criteria, required treatment or would benefit from a particular intervention.

`DPQ090`, corresponding to PHQ-9 item 9, concerns thoughts of death or self-harm. Endorsement is clinically important, but item 9 is **not a standalone suicide-risk assessment**. It does not establish intent, planning, imminence or overall level of suicide risk.

## 11. Version 1 minimum viable analysis

Project 1 version 1 will be considered analytically complete when it contains:

1. a documented data and codebook audit;
2. a transparent sample-flow table;
3. weighted item-level and total-score descriptives;
4. ordinal coefficient alpha;
5. McDonald's omega;
6. corrected item-total correlations;
7. a polychoric correlation matrix;
8. a one-factor dimensionality analysis;
9. an analysis of the association between PHQ-9 scores and functional difficulty;
10. a clinically cautious limitations and interpretation section.

## 12. Not included in version 1

Version 1 will not include:

- diagnostic-accuracy analysis;
- sensitivity or specificity estimates;
- claims about whether participants need treatment;
- claims that PHQ-9 scores establish a depressive disorder;
- measurement-invariance testing;
- survey-weighted latent-variable modelling.

These exclusions prevent the project from making claims that the available data cannot adequately support and keep the initial project realistic.

## 13. Optional extensions

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

Measurement invariance is an extension and is not required for completion.

## 14. Repository structure

```text
phq9-psychometric-analysis/
├── README.md
├── PROJECT_PROTOCOL.md
├── phq9-psychometric-analysis.Rproj
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

## 15. First execution checklist

- [x] Create the GitHub repository and local RStudio project.
- [x] Add the approved directory structure.
- [x] Save this document as `PROJECT_PROTOCOL.md`.
- [ ] Create a skeleton `README.md`.
- [x] Create the six numbered R scripts.
- [ ] Create and render a minimal `report/report.qmd`.
- [ ] Download `P_DPQ.xpt` and `P_DEMO.xpt` programmatically.
- [ ] Import and inspect both files.
- [ ] Verify file linkage using `SEQN`.
- [ ] Create a PHQ-9 variable dictionary.
- [ ] Audit all item response codes.
- [ ] Audit missingness and the `DPQ100` skip pattern.
- [ ] Construct and document the eligible analytic samples.
- [ ] Configure the NHANES survey design.
- [ ] Produce the first sample-flow and missingness outputs.
- [ ] Commit the completed data-audit stage before starting reliability analysis.