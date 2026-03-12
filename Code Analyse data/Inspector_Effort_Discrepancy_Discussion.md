# Inspector Effort Discrepancy Analysis Notes (Compact)

Date: 2026-03-12  
Project: Senegal Tax Audit replication package

## 1) Objective

Assess whether audit-discrepancy measures are associated with taxpayer-reported efficiency and corruption outcomes, using:

- `Code Analyse data/6 Inspector effort - Corruption.do`

## 2) Current data and sample

Source data:

- `datasetforanalysis.dta`

Sample treatment (current spec):

- No ex-ante sample drop of safety/ad hoc groups.
- Estimation identifies method differences by including controls:
  - `algorithm overlap random safeties horsprogramme`

Panel definitions:

- Panel A (recent audit): `q1 != . & selfreported_audit == 1`
- Panel B (all surveyed firms): `q1 != .`

Unit of observation:

- Firm-audit observation in merged administrative and taxpayer-survey data.

## 3) Discrepancy regressors (`W`)

Baseline construction:

- `gen W_main = (notificationvalue - confirmationvalue) / notificationvalue if d5 == 1 & d4 == 1 & y2 == 1`

Capped baseline used in main tables:

- `replace W_main = 0 if W_main < 0 & W_main != .`

Robustness regressors:

- `W_nonzero = 1{W_main != 0}`
- `W_abovemed = 1{W_main > median(W_main)}`
- `W_topquart = 1{W_main >= p75(W_main)}`

Pooled-threshold rule:

- The median and the 75th percentile are single pooled moments of non-missing `W_main` in the regression-eligible sample (not panel-specific).

## 4) Outcomes and specification backbone

Outcomes:

- Index outcomes: `index_efficiency`, `index_corruption`
- Question outcomes: `q34`, `q35`, `q32`, `q42`

Fixed effects:

- Index outcomes: `a(selectionyear center)`
- Question outcomes: `a(inspectorclusteryear)`

Columns per panel:

- Full audits (`x2==1`), Desk audits (`x2==0`), All audits

## 5) Output mapping

Main tables:

- `Output/w_main_table_indices_recent_all.tex`
- `Output/w_main_table_questions_recent_all.tex`

Robustness tables (`W_nonzero`, `W_abovemed`, and `W_topquart`):

- `Output/w_robust_nonzero_table_indices_recent_all.tex`
- `Output/w_robust_nonzero_table_questions_recent_all.tex`
- `Output/w_robust_abovemedian_table_indices_recent_all.tex`
- `Output/w_robust_abovemedian_table_questions_recent_all.tex`
- `Output/w_robust_topquartile_table_indices_recent_all.tex`
- `Output/w_robust_topquartile_table_questions_recent_all.tex`

Coverage and diagnostics:

- `Output/w_main_coverage_by_method.tex` (counts and % of base sample)
- `Output/w_main_scatter_notification.pdf`
- `Output/w_main_density.pdf`

Section write-up:

- `Code Analyse data/Audit_Discrepancy_Taxpayer_Section.tex`

## 6) Latest changes (2026-03-12)

- Updated sample language: method groups are controlled for in regressions, not dropped ex ante.
- Added capped baseline discrepancy definition: `W_main = 0` when `W_main < 0`.
- Documented three robustness W regressors (`W_nonzero`, `W_abovemed`, `W_topquart`) and pooled-threshold rules (median and p75).
- Added documentation for 6 robustness output tables (2 outcome families x 3 W variants).
- Updated coverage-table interpretation to report counts and percentages of the base sample.

## 7) Regression table note standard (Table 6 / D7 style)

Use clear but comprehensive table notes, with the model written explicitly inside each regression-table note:

- Core specification:
  - \(Y_{ipc}=\beta W_{i}+\theta_1 algorithm_i+\theta_2 overlap_i+\theta_3 random_i+\theta_4 safeties_i+\theta_5 horsprogramme_i+\lambda(i)+\varepsilon_{ipc}\)
- Displayed coefficients:
  - Coefficients on \(W\), algorithm, overlap, and random are shown.
- Included but omitted from display:
  - Coefficients on `safeties` and `horsprogramme` are estimated as controls but not listed in the table body.
- Fixed effects:
  - Index tables: selection-year and center fixed effects.
  - Question tables: inspector-cluster-year fixed effects.
- Panels and columns:
  - Panel A: surveyed firms self-reporting a recent audit.
  - Panel B: all surveyed firms.
  - Columns: Full audits (\(x2=1\)), Desk audits (\(x2=0\)), All audits.
- Robustness variants:
  - Replace \(W\) by \(W^{\neq 0}\), \(W^{>\mathrm{med}}\), or \(W^{\ge q75}\), keep the same control set and fixed effects.
- Inference:
  - Robust standard errors in parentheses.
  - Stars: \(^{*}p<0.10\), \(^{**}p<0.05\), \(^{***}p<0.01\).
