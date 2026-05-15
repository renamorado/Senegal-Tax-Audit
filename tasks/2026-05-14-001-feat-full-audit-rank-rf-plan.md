---
title: Full Audit List-Level Rank RF Prediction
type: feat
status: active
date: 2026-05-14
---

# Full Audit List-Level Rank RF Prediction

## Overview

Create a full-audit-only random forest prediction file that mirrors the current direct unweighted predicted-evasion workflow, but predicts realized evasion rank within each full-audit list instead of the realized evasion amount `y4`.

## Problem Frame

The current unweighted prediction process trains an unweighted random forest on executed audits with observed `y4`, predicts over all selected non-safety cases, and saves a predicted evasion score for downstream optimization and control-table work. The new version should keep that process comparable while changing the target from evasion amount to list-level rank.

## Requirements Trace

- R1. Use full audits only.
- R2. Restrict to selected, non-safety cases for the prediction sample.
- R3. Train only on executed full audits with observed `y4`.
- R4. Define realized rank within `bureau_detailed` by `selectionyear`, using `-y4` so larger evasion receives a better rank.
- R5. Use the same unweighted random forest predictor set as the direct unweighted `yhatrf` process.
- R6. Save a prediction file that can later be used by the consolidated Column 1 Stata tables as a control source.

## Scope Boundaries

- This first implementation creates and validates the rank-prediction file.
- It does not yet change the consolidated Column 1 table scripts.
- It does not alter existing predicted-evasion files or optimization outputs.
- It does not introduce weights, a detection gate, or zero replacement.

## Relevant Code and Patterns

- `Code Analyse data/Replication R/03_Run_RF.R`: direct unweighted predicted-evasion workflow and predictor set.
- `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R`: standalone R script pattern with local library path setup.
- `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do`: existing Column 1 control-source loop for later integration.
- `Code Analyse data/2 Table 5 column 1 predicted evasion controls.do`: existing Column 1 control-source loop for later integration.

## Key Technical Decisions

- Rank target: `rank(-y4, ties.method = "min")` within `bureau_detailed × selectionyear`, among executed full audits with nonmissing `y4`.
- Prediction direction: the direct RF output is a predicted rank outcome, where lower is higher priority. The script then re-ranks those predictions within `bureau_detailed x selectionyear` and saves `yhatrf_rank_score = -predicted_rank_order_bureauyear` plus `yhatrf = yhatrf_rank_score` in this rank-specific file so downstream scripts can preserve the existing convention that larger `yhatrf` means higher predicted priority.
- Output file: save a separate file, `Working Data/fullaudits_predicted_rank_bureauyear.dta`, instead of overwriting existing predicted-evasion files.

## Implementation Units

- [x] **Unit 1: Create rank RF prediction script**

**Goal:** Add a standalone R script that creates list-level realized ranks, trains the unweighted RF, predicts ranks over selected non-safety full audits, and writes a Stata `.dta` output.

**Requirements:** R1, R2, R3, R4, R5, R6

**Files:**
- Create: `Code Analyse data/Replication R/08_Full_Audit_Rank_RF_Unweighted.R`
- Create: `docs/plans/2026-05-14-001-feat-full-audit-rank-rf-plan.md`
- Modify: `SESSION_NOTES.md`

**Approach:**
- Read `datasetforanalysis_predictionexercise_for_all_logs_exercise.dta`.
- Keep `controle == 2`, `selection == 1`, and `safeties != 1`.
- Create `rank_y4_bureauyear` within `bureau_detailed × selectionyear` for `y2 == 1 & !is.na(y4)`.
- Train `randomForest` with the same predictors as `03_Run_RF.R`.
- Predict over the full selected non-safety full-audit sample.
- Save the direct RF predicted rank outcome, the within-list predicted rank order, and a flipped compatibility score.

**Test Scenarios:**
- Happy path: the script writes `Working Data/fullaudits_predicted_rank_bureauyear.dta`.
- Data construction: `rank_y4_bureauyear` is nonmissing only for executed full audits with observed `y4`.
- Direction: within a list, the maximum `y4` receives rank 1.
- Integration readiness: output includes `predicted_rank_y4_bureauyear`, `predicted_rank_order_bureauyear`, `yhatrf_rank_score`, and `yhatrf`.

**Verification:**
- Run the R script from the replication-package working directory and inspect the output variables.

- [ ] **Unit 2: Integrate rank prediction into consolidated Column 1 tables**

**Goal:** Add the new rank-prediction source to the existing Table 4 and Table 5 Column 1 control-comparison scripts.

**Requirements:** R6

**Files:**
- Modify: `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do`
- Modify: `Code Analyse data/2 Table 5 column 1 predicted evasion controls.do`

**Approach:**
- Extend the existing `yhatrf_source` loops with a rank-prediction source.
- Point the full-audit input to `fullaudits_predicted_rank_bureauyear.dta`.
- Export separate rank-control TeX fragments so existing predicted-evasion outputs remain unchanged.

**Test Scenarios:**
- Happy path: Table 4 and Table 5 rank-control fragments export without changing current/weighted fragments.
- Sample consistency: full-audit sample size matches the new prediction file after existing Column 1 restrictions.

**Verification:**
- Run the two Stata table scripts and inspect the rank-source TeX outputs.

- [x] **Unit 3: Add Figure 4-style inverted predicted-rank diagnostics**

**Goal:** Replicate the Figure 4 full-audit panels using an inverted predicted-rank score on the x-axis instead of predicted evasion amount, and add the figures to the report. The inversion makes the horizontal axis increase with predicted evasion priority, matching the intuitive direction of the original predicted-evasion plots.

**Requirements:** R1, R2, R6

**Files:**
- Create: `Code Analyse data/6 Figure 4 predicted rank panels.do`
- Modify: `Code Analyse data/Inspector's Effort report.tex`
- Modify: `SESSION_NOTES.md`

**Approach:**
- Read `Working Data/fullaudits_predicted_rank_bureauyear.dta`.
- Keep selected non-safety full audits.
- Use `yhatrf_rank_score = -predicted_rank_order_bureauyear` as the x-axis variable, so higher x-axis values indicate better predicted rank and higher predicted evasion priority within the full-audit list.
- Recreate Panel A for all selected full audits and Panel B for algorithm-selected versus inspector-selected cases.
- Add a new `Predicting rank` section to the report after the optimization-gains revision section.

**Test Scenarios:**
- Happy path: the do-file exports both predicted-rank Figure 4 PDFs.
- Axis check: exported PDFs show `Inverted predicted rank score`.
- Report integration: LaTeX compiles after adding the new section and figure imports.

**Verification:**
- Ran the new Stata do-file successfully.
- Checked the generated PDFs with `pdftotext` for the expected inverted-rank axis and legend text.
- Ran `pdflatex` twice successfully on `Code Analyse data/Inspector's Effort report.tex`.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Predicted rank has the opposite direction from `yhatrf` | Save both direct predicted rank and flipped within-list `yhatrf` compatibility score. |
| Bureau-year lists have different sizes | Keep literal ranks as requested, but document the interpretation. |
| Ties in realized `y4` | Use competition ranks so all tied top cases receive rank 1 without arbitrary order within ties. |
| Downstream scripts assume higher `yhatrf` means higher priority | Use `yhatrf = -predicted_rank_order_bureauyear` only in the rank-specific output file. |

## Open Questions

### Resolved During Planning

- Rank grouping: use full-audit list level, `bureau_detailed × selectionyear`.
- Rank direction: rank `-y4`, so higher realized evasion receives rank 1.
- Prediction process: mirror direct unweighted `yhatrf`, with no weights and no detection gate.

### Deferred to Implementation

- Whether to include this source in all consolidated table variants or only the Column 1 scripts is deferred until the first prediction output is validated.
