# Analysis Plan

**Project:** Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020  
**Repository:** `phq9-psychometric-analysis`  
**Analysis plan version:** 1.1  
**Last updated:** 15 July 2026

## 1. Project title

**Psychometric Evaluation of the PHQ-9 in U.S. Adults Using NHANES 2017–March 2020**

**Subtitle:** *Reliability, Dimensionality, Functional Difficulty, and Clinical Interpretation*

## 2. Dataset and cycle

The project uses the publicly available **National Health and Nutrition Examination Survey 2017–March 2020 pre-pandemic release**.

The primary files are:

- `P_DPQ.xpt`: Mental Health—Depression Screener
- `P_DEMO.xpt`: demographic and survey-design variables

The completed 2017–2018 cycle and the partial 2019–March 2020 cycle are treated as one combined pre-pandemic release. The partial 2019–March 2020 data will not be analysed separately.

Additional questionnaire files will be imported only if they address a defined secondary research question and their coding and routing rules can be documented.

## 3. Analytic samples

The depression-screener file contains 8,965 adults who were successfully linked to the demographic file using `SEQN`.

The following analysis-specific samples will be used.

### PHQ-9 descriptive and psychometric sample

The primary PHQ-9 sample contains **8,276 participants with valid responses to all nine PHQ-9 items**.

This sample will be used for:

- PHQ-9 total-score descriptives;
- severity-band descriptives;
- reliability analysis;
- polychoric correlations;
- one-factor dimensionality analysis.

### Functional-difficulty sample

The primary functional-difficulty sample contains **5,517 participants who:**

- have complete PHQ-9 data;
- endorsed at least one PHQ-9 symptom;
- have a valid `DPQ100` response.

Participants with nine zero-valued PHQ-9 items were not asked, or did not receive, the functional-difficulty question. The observed data pattern is consistent with structural questionnaire routing among participants reporting no PHQ-9 symptoms.

Structurally skipped `DPQ100` values will not be recoded as “not at all difficult.”

For extended descriptive tables and figures, these participants will be shown in a separate category:

> No PHQ-9 symptoms / DPQ100 structurally skipped

### Survey-design variables

The following variables are present for all 8,965 linked depression-screener records:

- `WTMECPRP`: combined-cycle MEC examination weight;
- `SDMVSTRA`: masked variance stratum;
- `SDMVPSU`: masked variance primary sampling unit.

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

`DPQ100` measures reported difficulty with work, home responsibilities and relationships. It is not part of the PHQ-9 total score and will be analysed as the primary functional variable.

## 5. External variables

### Required for version 1

- `DPQ100`: functional difficulty

### Possible secondary variables

- `HUQ010`: self-rated general health
- `HUQ090`: contact with a mental-health professional during the previous year
- `SLD012`: usual weekday or workday sleep duration
- `SLQ050`: reported trouble sleeping to a health professional
- `SLQ120`: frequency of excessive daytime sleepiness

Only `DPQ100` is required for version 1.

A secondary variable will be included only if:

- its coding and questionnaire routing are clear;
- the available sample is adequate;
- it addresses a stated question about the interpretation of PHQ-9 scores;
- overlap with the content of the PHQ-9 is acknowledged.

Sleep variables are exploratory because sleep disturbance and fatigue are already represented within the PHQ-9. Associations with sleep measures may therefore partly reflect item-content overlap.

## 6. Research questions

1. What are the weighted response distributions, endorsement rates and missingness patterns of the nine PHQ-9 items?
2. What is the weighted distribution of PHQ-9 total scores and conventional symptom-severity bands?
3. How consistently do the PHQ-9 items measure depressive symptom severity?
4. Are the item relationships compatible with a one-factor representation of depressive symptom severity?
5. How are PHQ-9 total scores associated with reported functional difficulty?
6. What conclusions about symptom severity are supported, and which diagnostic or treatment-related conclusions are not supported?

## 7. Data handling and missing-data rules

- Restrict the analysis to participants aged 18 years or older.
- Link files using `SEQN`.
- Check for duplicate and unmatched identifiers before analysis.
- Recode refusal, “don’t know” and system-missing responses as `NA`.
- Do not treat codes 7 or 9 as symptom scores.
- Use all available valid responses for item-specific descriptive analyses.
- Calculate the PHQ-9 total only when all nine items have valid scores from 0 to 3.
- Do not prorate incomplete PHQ-9 scores.
- Do not impute missing PHQ-9 items in version 1.
- Use the 8,276 complete PHQ-9 cases for total-score descriptives and psychometric analyses.
- Use the 5,517 routed respondents with complete PHQ-9 data and valid `DPQ100` for the primary functional-difficulty analysis.
- Do not recode structurally skipped `DPQ100` values as zero.
- Display symptom-free participants with structural `DPQ100` skips as a separate category in extended descriptive outputs.
- Use analysis-specific complete cases for any secondary external variables.
- Report unweighted sample sizes alongside weighted estimates.
- Report exclusions and sample sizes at each main analysis stage.

## 8. Planned analyses

### 8.1 Data audit and sample flow

The completed data audit includes:

- source-file dimensions and variable labels;
- response-code ranges;
- linkage using `SEQN`;
- duplicate-identifier checks;
- refusal, “don’t know” and system-missing responses;
- the relationship between PHQ-9 response patterns and `DPQ100` missingness;
- survey-design variable availability;
- initial sample-flow counts.

### 8.2 Weighted descriptive analyses

Weighted descriptive analyses will use the NHANES complex survey design.

Stage 2A will produce:

- weighted response proportions for each PHQ-9 item;
- 95% confidence intervals for weighted item-response proportions;
- weighted PHQ-9 total-score summaries and distribution;
- weighted PHQ-9 severity-band distribution;
- weighted `DPQ100` distribution among routed respondents;
- an extended functional-difficulty table that includes symptom-free participants as a separate structural-skip category;
- unweighted sample sizes alongside weighted estimates;
- exported tables and figures.

The conventional PHQ-9 severity bands will be:

- 0–4: minimal;
- 5–9: mild;
- 10–14: moderate;
- 15–19: moderately severe;
- 20–27: severe.

### 8.3 Reliability and item analysis

After Stage 2A approval, the project will estimate:

- ordinal coefficient alpha;
- McDonald’s omega;
- corrected item-total correlations;
- polychoric inter-item correlations;
- floor effects and sparse response categories;
- reliability estimates after removing each item, used as a diagnostic check rather than a basis for automatic item deletion.

Reliability coefficients will be reported as evidence of internal consistency, not as evidence that the measure is valid or unidimensional.

### 8.4 One-factor dimensionality analysis

Version 1 will test a one-factor confirmatory factor model using the nine ordered PHQ-9 items.

The planned analysis will use:

- a polychoric correlation matrix;
- an ordinal estimator such as WLSMV;
- standardised factor loadings;
- model-fit indices;
- residual or local-fit information;
- an evaluation of whether the one-factor model provides an adequate summary of the item structure.

A two-factor or bifactor model is not required for version 1. Alternative models will be considered only if the one-factor model shows a clear and theoretically interpretable area of poor fit.

### 8.5 Functional-difficulty association

The primary functional analysis will use participants with complete PHQ-9 data, at least one endorsed symptom and a valid `DPQ100` response.

The analysis will include:

- weighted PHQ-9 estimates across `DPQ100` categories;
- visualisation of PHQ-9 scores by reported functional difficulty;
- survey-weighted ordinal logistic regression with `DPQ100` as the ordered outcome and PHQ-9 total score as the main predictor;
- an assessment of the proportional-odds assumption;
- effect estimates with confidence intervals.

If the proportional-odds assumption is not supported, the model specification will be revised before inferential results are reported.

Results will be interpreted as evidence about the relationship between symptom scores and reported functional impairment, rather than evidence of diagnostic accuracy.

### 8.6 Limitations and interpretation

The discussion will address:

- the cross-sectional design;
- self-reported symptoms;
- missingness and complete-case selection;
- the absence of an independent diagnostic interview;
- the use of a population rather than clinical sample;
- limits to generalisation outside the United States;
- the distinction between symptom severity and psychiatric diagnosis;
- the limitations of conventional severity thresholds;
- the interpretation of PHQ-9 item 9;
- the difference between statistical associations and clinical decisions.

## 9. Weighted descriptive analyses and psychometric modelling

### Weighted analyses

Population descriptives and functional-difficulty analyses will use:

- weight: `WTMECPRP`;
- strata: `SDMVSTRA`;
- cluster: `SDMVPSU`.

These analyses will be implemented using the `survey` and/or `srvyr` packages.

Weighted estimates will describe the U.S. civilian non-institutionalised adult population represented by the combined 2017–March 2020 pre-pandemic release.

### Psychometric modelling

Reliability, polychoric correlations and factor analysis will use the complete-PHQ-9 sample.

Unless survey weights are incorporated into a specific psychometric model, the resulting parameters will be described as estimates for the analytic sample rather than as nationally representative latent-variable parameters.

Survey-weighted latent-variable modelling is outside the version 1 scope.

## 10. Clinical interpretation

PHQ-9 scores will be interpreted as **self-reported indicators of recent depressive symptom severity**. They will not be presented as psychiatric diagnoses.

The dataset does not establish whether a participant met diagnostic criteria for a depressive disorder, required treatment or would benefit from a particular intervention.

`DPQ090`, corresponding to PHQ-9 item 9, concerns thoughts of death or self-harm. Endorsement is clinically important, but item 9 is not a standalone suicide-risk assessment. It does not establish intent, planning, imminence or overall suicide risk.

## 11. Version 1 minimum analysis

Version 1 will contain:

1. a documented data and codebook audit;
2. a sample-flow table;
3. weighted item-response descriptives;
4. weighted PHQ-9 total-score and severity-band descriptives;
5. ordinal coefficient alpha;
6. McDonald’s omega;
7. corrected item-total correlations;
8. a polychoric correlation matrix;
9. a one-factor confirmatory factor analysis;
10. an analysis of PHQ-9 scores in relation to functional difficulty;
11. a discussion of interpretation and limitations.

## 12. Not included in version 1

Version 1 will not include:

- diagnostic-accuracy analysis;
- sensitivity or specificity estimates;
- claims about treatment need;
- claims that PHQ-9 scores establish a depressive disorder;
- measurement-invariance testing;
- survey-weighted latent-variable modelling.

These exclusions reflect the information available in the dataset and the defined scope of the project.

## 13. Optional extensions

Possible extensions after version 1 include:

- comparison of one-factor and theoretically justified two-factor models;
- a PHQ-8 sensitivity analysis excluding item 9;
- subgroup descriptives;
- measurement invariance across sex or broad age groups;
- secondary associations with general health;
- secondary associations with mental-health professional contact;
- exploratory sleep-related analyses;
- survey-weighted reliability estimates;
- survey-weighted latent-variable modelling;
- replication in another NHANES cycle.

Measurement invariance is an extension and is not required for version 1.

## 14. Repository structure

```text
phq9-psychometric-analysis/
├── README.md
├── ANALYSIS_PLAN.md
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

## 15. Current execution status

### Stage 1: data audit

- [x] Create the GitHub repository and local RStudio project.
- [x] Add the repository structure.
- [x] Save the analysis plan.
- [x] Create the initial README.
- [x] Create the six numbered R scripts.
- [x] Create and render the initial Quarto report.
- [x] Download and inspect `P_DPQ.xpt` and `P_DEMO.xpt`.
- [x] Verify `SEQN` linkage.
- [x] Create the PHQ-9 variable dictionary.
- [x] Audit questionnaire response codes and missingness.
- [x] Audit the `DPQ100` response pattern.
- [x] Produce the initial sample-flow table.
- [x] Audit the survey-design variables.
- [x] Save the cleaned data-audit dataset.
- [x] Commit and push Stage 1.

### Stage 2A: weighted descriptives

- [ ] Create the NHANES survey-design object.
- [ ] Calculate weighted PHQ-9 item-response proportions.
- [ ] Describe the weighted PHQ-9 total-score distribution.
- [ ] Calculate the weighted severity-band distribution.
- [ ] Describe `DPQ100` among routed respondents.
- [ ] Create the extended functional-difficulty category including structural skips.
- [ ] Export descriptive tables and figures.
- [ ] Update the Quarto report.
- [ ] Complete the academic-voice and formatting check.
- [ ] Submit Stage 2A for Command Centre review.

Reliability, omega, polychoric correlations, factor analysis and functional-difficulty modelling will not begin until Stage 2A has been reviewed.