# Session Notes

---

Date: 2026-06-23
Task: Convert Senegal conceptual framework tables from PDF to TeX.

## Files edited
- `Code Analyse data/table_senegal_conceptual_framework.tex`
- `Code Analyse data/table_senegal_realized_effects.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added two standalone LaTeX table files corresponding to the two tables in `Code Analyse data/table for senegal.pdf`.
- Used booktabs styling with `adjustbox` and `threeparttable`, matching the table environment conventions already used in the report.
- Preserved the table structure from the PDF/DOCX source while cleaning PDF extraction artifacts such as smart apostrophe encoding and line-break noise.

## Output files affected
- New table file: `Code Analyse data/table_senegal_conceptual_framework.tex`.
- New table file: `Code Analyse data/table_senegal_realized_effects.tex`.

## Validation performed
- Extracted and cross-checked table contents from `Code Analyse data/table for senegal.pdf` and `Code Analyse data/table for senegal.docx`.
- Compiled a disposable LaTeX smoke-test wrapper that inputs both new table files using `pdflatex -interaction=nonstopmode -halt-on-error table_senegal_smoke_test.tex`; validation succeeded after allowing MiKTeX to write its font cache outside the workspace sandbox.
- Removed the disposable smoke-test wrapper and generated aux/log/pdf files after validation.

## Open issues / next steps
- If these are included in the main Overleaf document, ensure the preamble includes `booktabs`, `array`, `adjustbox`, `threeparttable`, and `float`, as in the local report file.

---

Date: 2026-05-25
Task: Revise direct bin-target companion exercise to fixed quartiles.

## Files edited
- `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R`
- `Code Analyse data/Inspector's Effort report.tex`
- `Output/table_opt_full_and_desk_bin_target_panelc.tex`
- `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`
- `Output/table_opt_full_and_desk_bin_target_support.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Changed the companion Panel C target from an automatically selected support-safe bin count to a fixed quartile target.
- Made the realized-bin construction explicit within audit type, detailed tax office, and selection year by grouping on `controle`, `bureau_detailed`, and `selectionyear`.
- Updated the report notes, construction bullets, scenario labels, and support table language to describe direct highest-realized-evasion-quartile prediction.
- Expanded the support table to show total, supported, and unsupported training lists.

## Output files affected
- Regenerated `Output/table_opt_full_and_desk_bin_target_panelc.tex`.
- Regenerated `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`.
- Regenerated `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Regenerated report build artifacts and `Code Analyse data/Inspector's Effort report.pdf` during validation.

## Validation performed
- Ran `08_Optimization_Exercise_Bin_Target_PanelC.R` using Dropbox working data and the project renv package library while writing generated outputs to this repo's `Output/` folder.
- Confirmed the script reports `A1 validation passed: current Table 9 values are reproduced.`
- Confirmed all diagnostics have `rows_2020_in_table = 0`, Panel C rows have `panel_c_uses_amount_yhatrf = TRUE`, and optimized counts equal realized executed counts.
- Confirmed quartile support: Full Audits keep 21 of 28 training lists and exclude 7; Desk Audits keep 23 of 24 and exclude 1. Supported lists have at least two cases per quartile.
- Compiled `Code Analyse data/Inspector's Effort report.tex` with MiKTeX successfully; remaining warnings are existing-style warnings about multiply defined labels, PDF inclusion versions, and overfull boxes.

## Open issues / next steps
- Quartiles are more substantively interpretable than halves but exclude more full-audit training lists; if this version becomes central, consider whether to include an appendix sensitivity comparing automatic support-safe bins and fixed quartiles.

---

Date: 2026-05-25
Task: Implement direct bin-target companion optimization table.

## Files edited
- `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R`
- `Code Analyse data/Inspector's Effort report.tex`
- `Output/table_opt_full_and_desk_bin_target_panelc.tex`
- `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`
- `Output/table_opt_full_and_desk_bin_target_support.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a standalone R companion script for the Table 48 bin-target exercise, leaving `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` unchanged.
- The new script rebuilds the amount-prediction Panel A benchmarks and adds Panel C, where optimized selections are ranked by a one-step random forest classifier predicting high-realized-evasion-bin membership.
- Implemented the support-safe bin rule: check deciles, quintiles, quartiles, terciles, then halves, and choose the finest grouping with at least two executed observed cases per bin in each included detailed-tax-office-by-selection-year training list.
- Added a new report subsection, companion table, support table, construction bullets, and Table 48-style tablenotes explaining the audit-program-case unit, 2018--2019 optimization restriction, matched amount-model valuation, support-safe bin rule, and top-five exclusion rule.

## Output files affected
- New companion table: `Output/table_opt_full_and_desk_bin_target_panelc.tex`.
- New diagnostics CSV: `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`.
- New support table: `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Regenerated report build artifacts and `Code Analyse data/Inspector's Effort report.pdf` during validation.

## Validation performed
- Ran `08_Optimization_Exercise_Bin_Target_PanelC.R` using Dropbox working data and the project renv package library while writing generated outputs to this repo's `Output/` folder.
- Confirmed the script reports `A1 validation passed: current Table 9 values are reproduced.`
- Confirmed C1--C3 rows exist for Full Audits and Desk Audits, all table scenarios have `rows_2020_in_table = 0`, optimized counts equal executed counts, and Panel C diagnostics mark `panel_c_uses_amount_yhatrf = TRUE`.
- Confirmed support diagnostics selected halves for full audits and terciles for desk audits under the minimum-two-cases-per-bin rule.
- Compiled `Code Analyse data/Inspector's Effort report.tex` twice with MiKTeX successfully; the second pass produced `Inspector's Effort report.pdf` with 145 pages. Remaining LaTeX warnings are pre-existing-style warnings about multiply defined labels, PDF inclusion versions, and overfull boxes.

## Open issues / next steps
- Review whether halves for full audits are substantively too coarse despite satisfying the support-safe rule.
- If Panel C is promising, consider later sensitivity outputs for alternative bin definitions or a detection-gated two-step bin classifier.

---

Date: 2026-05-25
Task: Brainstorm direct top-bin prediction as an alternative to predicted-rank diagnostics.

## Files edited
- `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a planning-only brainstorm note discussing Alipio's suggestion to predict high-evasion bin membership directly, such as top 10 percent or top quintile within bureau-year lists, rather than predicting full within-list ranks.
- Distinguished direct bin-target prediction from the existing practice of binning predicted amount or rank scores after prediction.
- Recorded benefits, risks, candidate target definitions, diagnostic steps, interpretation guardrails, and open questions for Anne, Alipio, and Roldan.

## Output files affected
- None. This pass added documentation only.

## Validation performed
- Reviewed the existing rank-prediction plan, Anne task notes, current predicted-rank Figure 4 script, Table 4 predicted-rank control script, and relevant session-note entries before drafting the brainstorm note.
- No Stata or R scripts were run because no analysis code or result outputs were changed.

## Open issues / next steps
- Decide whether the first implementation should estimate both top 10 percent and top quintile targets, or start with one primary bin definition.
- If implementation proceeds, create separate prediction outputs and diagnostics so existing amount- and rank-prediction files remain unchanged.

Update: 2026-05-25 (support-driven bin definition)
- Revised `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md` to incorporate Roldan's point that office-year lists have different numbers of audit cases, so the bin definition should be constrained by the smallest usable list.
- Added quartiles as a candidate target and reframed the recommendation around choosing the finest grouping with acceptable support across all included lists.
- Added proposed report diagnostics for minimum and maximum cases per bin, empty or singleton bins, and lists excluded or pooled because of insufficient support.
- Validation: documentation-only update; no Stata or R code was run.

Update: 2026-05-25 (selected direct bin-target prediction)
- Updated `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md` to record the selected next-pass approach: define the outcome as membership in a high-realized-evasion bin and train a classifier to predict the probability of that membership.
- Narrowed the recommendation and open questions around direct bin-target prediction, leaving support-rule choice as the main remaining design decision.
- Validation: documentation-only update; no Stata or R code was run.

Update: 2026-05-25 (Table 48-style bin-prediction table design)
- Added a Table 48-style optimization-table section to `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md`.
- Recommended adding a single Panel C for direct bin-target optimized selection, ranked by predicted probability of high-bin membership and valued with the matched amount-prediction model from Panel A.
- Flagged that the main table should avoid crossing every candidate bin definition with every amount/rank/bin scenario; alternative bin definitions should first be handled through support diagnostics and, if needed, separate sensitivity tables.
- Validation: documentation-only update; no Stata or R code was run.

Update: 2026-05-25 (one-step versus two-step bin prediction)
- Added a design note to `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md` recommending a one-step direct bin classifier as the baseline for the bin-prediction exercise.
- Clarified that predicting historical execution as a first stage would be conceptually awkward for the Table 48-style optimization because the optimized program fixes the executed audit count within each list and should not import inspector execution behavior into the ranking score.
- Noted that a two-step variant could be considered later as a sensitivity, preferably using a detection or observed-evasion gate rather than an execution gate.
- Validation: documentation-only update; no Stata or R code was run.

Update: 2026-05-25 (selected Panel C one-step design)
- Updated `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md` to record the agreed first implementation design: a Table 48-style Panel C using a one-step direct bin classifier for optimized ranking.
- Clarified that two-step bin prediction is outside the first implementation and only a possible later sensitivity if the one-step Panel C is promising.
- Validation: documentation-only update; no Stata or R code was run.

---

Date: 2026-05-12
Task: Add consolidated Table 4 Column 1 predicted-evasion control comparison.

## Files edited
- `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a standalone Stata workflow that re-estimates full-audit Table 4 Column 1 across eight predicted-evasion control specifications: original, linear `yhatrf`, quadratic `yhatrf`, quintiles, deciles, deciles interacted with `bureau_detailed`, integer rank plus linear `yhatrf`, and integer rank plus quadratic `yhatrf`.
- Constructed quintiles, deciles, and integer ranks within audit type x `bureau_detailed` x selection year, with higher ranks corresponding to higher predicted evasion.
- Added the new consolidated table to the Table 4 predicted-evasion robustness section of `Inspector's Effort report.tex`, with notes explaining the sample, controls, and bin/rank construction.

## Output files affected
- New output fragment: `Output/table4_col1_predicted_evasion_control_comparison.tex`.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully.
- Confirmed the generated TeX fragment has eight columns, displays only `Algorithm`, `Inspectors x Overlap`, and `Algorithm x Random`, includes the requested predicted-evasion control marker rows, and reports populated `N`, `R2`, and mean outcome rows.
- Confirmed `Inspector's Effort report.tex` references `table4_col1_predicted_evasion_control_comparison.tex`.
- Did not recompile the full report in this pass.

## Open issues / next steps
- If the full report PDF is needed, rerun the existing report compilation check after confirming all imported fragments are available.

Update: 2026-05-12 (additional decile interaction columns)
- Extended `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` so the consolidated table now has ten columns, adding decile-by-selection-year controls and a combined decile-by-selection-year plus decile-by-`bureau_detailed` specification.
- Updated the table notes in `Code Analyse data/Inspector's Effort report.tex` to explain Columns 9 and 10.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`; confirmed Columns 9 and 10 are populated, the lower-panel markers identify the new interaction controls, and `N`, `R2`, and mean outcome rows remain populated.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully.

Update: 2026-05-12 (list-specific predicted-evasion slope and rank direction)
- Extended the consolidated table to eleven columns, adding a specification with list-specific linear predicted-evasion controls plus the integer predicted-evasion rank.
- Redefined the integer predicted-evasion rank so rank 1 is the highest-predicted-evasion case within the detailed-tax-office-by-selection-year list; larger ranks correspond to lower predicted evasion.
- Rewrote the consolidated table note in `Code Analyse data/Inspector's Effort report.tex` to avoid dataset variable names and code formatting, and to describe controls in paper-facing terms.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`; confirmed Column 11 is populated, marks both the list-specific predicted-evasion control and rank control, and preserves populated `N`, `R2`, and mean outcome rows.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully.

Update: 2026-05-12 (rank marker cleanup)
- Removed the separate `Rank of predicted evasion, quadratic` marker row from the consolidated table.
- Column 8 is now described by the combination of the `Quadratic predicted evasion` and `Rank of predicted evasion` marker rows, matching the underlying specification more cleanly.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully and confirmed the regenerated table has no separate quadratic-rank row.

Update: 2026-05-12 (top-split column and bin support)
- Extended `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` so the consolidated Table 4 Column 1 comparison now has a twelfth column controlling for top-split predicted-evasion deciles.
- Constructed the top-split bins within the same audit-type x detailed-tax-office x selection-year cells as the existing decile controls, keeping deciles 1--8 and splitting deciles 9 and 10 into lower and upper halves.
- Added a new support-table export, `Output/table4_col1_predicted_evasion_bin_support.tex`, reporting FE-stratum coverage, total support, algorithm/inspector support, executed cases, and execution rates for the ordinary decile and top-split specifications.
- Added the support table to `Code Analyse data/Inspector's Effort report.tex` and updated the comparison-table note to describe Column 12 and the top-split bin construction.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully; confirmed `Output/table4_col1_predicted_evasion_control_comparison.tex` has 12 populated columns and a `Top-split deciles` marker row, and confirmed the support table is populated, including the small top split bin 10b (`31` total observations, `7` algorithm-selected observations).

Update: 2026-05-12 (tax-office-year polynomial predicted-evasion slopes)
- Extended `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` so the consolidated Table 4 Column 1 comparison now has a thirteenth column controlling for a quadratic polynomial in predicted evasion interacted with detailed tax office by selection year.
- Added `table4_col1_bureauyear` and `yhatrf_sq_col1` to support the specification, using tax-office-year-specific linear and squared predicted-evasion slopes while keeping the original full-audit fixed effects.
- Updated the comparison-table note in `Code Analyse data/Inspector's Effort report.tex` to describe Column 13.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`; in Column 13 the Algorithm coefficient is `-0.06` with `**`, with `N = 944` and `R2 = 0.47`.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully; the Stata log reaches `end of do-file`.

Update: 2026-05-12 (rank-by-list column and lower-panel cleanup)
- Added one more consolidated Table 4 Column 1 specification controlling for predicted-evasion rank interacted with the list, so the table now has 14 columns.
- Reworked the lower-panel decile-interaction marker rows so the combined decile-by-selection-year plus decile-by-detailed-tax-office specification is marked once, rather than appearing as duplicate `x` entries in the separate interaction rows.
- Updated the report note in `Code Analyse data/Inspector's Effort report.tex` to describe Column 14 and the mutually exclusive decile-interaction marker rows.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully; confirmed the output has 14 populated columns, a `Rank of predicted evasion x List` marker only in Column 14, and separate rows for decile-by-bureau only, decile-by-selection-year only, and the combined decile interaction.

Update: 2026-05-12 (decile-by-list and top-split-by-list diagnostics)
- Added two fully saturated bin-by-list diagnostics to `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do`: decile-by-list fixed effects and top-split-decile-by-list fixed effects, extending the consolidated comparison to 16 columns.
- Implemented these two specifications as absorbed fixed effects rather than explicit dummy controls, after confirming that explicit dummy controls produced singular robust variance matrices and missing standard errors.
- Updated `Code Analyse data/Inspector's Effort report.tex` to describe Columns 15 and 16 and to note that singleton bin-by-list cells are dropped because they do not contribute identifying variation once those fixed effects are absorbed.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully; confirmed Columns 15 and 16 have usable robust standard errors. Column 15 reports Algorithm `-0.09**` with `N = 912` and `R2 = 0.54`; Column 16 reports Algorithm `-0.09**` with `N = 871` and `R2 = 0.54`.

Update: 2026-05-12 (cubic controls and intuitive column order)
- Reordered the consolidated Table 4 Column 1 comparison so the columns move from simple continuous controls, to rank and bin controls, to list-specific slopes, and then to bin-by-list fixed effects.
- Added a cubic predicted-evasion control, a cubic predicted-evasion polynomial interacted with the list, and quintile-by-list fixed effects.
- Renamed the list-specific polynomial marker row from tax-office-year language to `Quadratic polynomial predicted evasion x List`, matching the detailed-tax-office-by-selection-year list definition used in the table.
- Updated the comparison-table note in `Code Analyse data/Inspector's Effort report.tex` to describe the reordered column groups and the new singleton handling in Columns 14--16.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`; confirmed the table has 16 populated columns, the new cubic and quintile-by-list marker rows, and populated `N`, `R2`, and mean outcome rows.
- Validation: re-ran `stata-mp /e do "Code Analyse data/2 Table 4 column 1 predicted evasion controls.do"` successfully; the Stata log reaches `end of do-file`.

---

Date: 2026-05-11
Task: Switch Table 4 full-audit FE comparison from bureau-detailed to broad bureau-year.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Updated the full-audit Table 4 FE comparison so the second specification uses broad `bureau x selectionyear` fixed effects rather than `bureau_detailed x selectionyear`.
- Kept the original-FE comparison columns, outcomes, sample restrictions, controls, and output filename unchanged.
- Revised the Section 2.1 caption and notes in the report to describe broad bureau-year fixed effects and explicitly say the comparison does not use `bureau_detailed`.

## Output files affected
- Regenerated `Output/table4_fullaudit_fe_comparison.tex`.
- Existing Table 4 fragments were regenerated by the Table 4 workflow.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"` successfully; the Stata log reaches `end of do-file`.
- Confirmed `Output/table4_fullaudit_fe_comparison.tex` labels the comparison columns as `Bureau FE` / `Bureau x Year` and preserves the full-audit sample sizes `944`, `508`, and `457`.

---

Date: 2026-05-11
Task: Extend Table 4 FE comparison to all full-audit columns.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Replaced the earlier Table 4 Column 1-only FE comparison with a six-column full-audit comparison covering Table 4 columns 1, 4, and 7: `P(Execution)`, `P(Detection | Execution)`, and `log(Evasion) | Detection`.
- For each outcome, the table now compares the original `inspectorclusteryear` fixed effects with `bureau_detailed x selectionyear` fixed effects, constructed as `egen table4_fe_bureau_detailed_year = group(bureau_detailed selectionyear), missing`.
- Updated Section 2.1 of `Inspector's Effort report.tex` to import the new full-audit comparison fragment and revise the caption and notes.

## Output files affected
- New output fragment: `Output/table4_fullaudit_fe_comparison.tex`.
- Existing Table 4 fragments were regenerated by the Table 4 workflow.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"` successfully; the Stata log reaches `end of do-file`.
- Confirmed the new comparison table has six columns, with outcome-specific sample sizes matching the full-audit Table 4 columns: `N = 944`, `508`, and `457`.
- Confirmed `Inspector's Effort report.tex` imports `Output/table4_fullaudit_fe_comparison.tex` in Section 2.1.

---

Date: 2026-05-11
Task: Add Table 4 Column 1 FE comparison to the inspector-effort report.

## Files edited
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added Section 2.1, `Testing bureau and bureau detailed FE`, under `Main regression estimates adding predicted evasion controls`.
- Inserted the standalone Table 4 Column 1 full-audit FE comparison fragment, with notes clarifying that the original `inspectorclusteryear` FE corresponds to the detailed-bureau-by-selection-year grouping for full audits and that the comparison column uses broad `bureau x selectionyear`.

## Output files affected
- The report now imports `Output/table4_col1_fullaudit_fe_comparison.tex`.

## Validation performed
- Confirmed the new report subsection, table label, and `\input{\OutPath table4_col1_fullaudit_fe_comparison.tex}` are present.
- Confirmed `Output/table4_col1_fullaudit_fe_comparison.tex` exists.
- Did not recompile the full report in this pass.

---

Date: 2026-05-11
Task: Add Table 4 column 1 fixed-effect comparison for full audits.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a standalone Table 4 column 1 comparison that re-estimates the full-audit `P(Execution)` specification with the original `inspectorclusteryear` fixed effects and with broad `bureau x selectionyear` fixed effects.
- Defined the new comparison fixed effect as `egen table4_fe_bureau_year = group(bureau selectionyear), missing`, explicitly using broad `bureau` rather than `bureau_detailed` or `controlbureauannee`.
- Kept the RHS, sample, and robust VCE aligned with the original column 1 specification: `y2` on `algorithm overlap random safeties`, restricted to `x2 == 1` in the selected non-safety sample.

## Output files affected
- New output fragment: `Output/table4_col1_fullaudit_fe_comparison.tex`.
- Existing Table 4 fragments were regenerated by the Table 4 workflow.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"`. The shell wrapper timed out after the Stata run, but the Stata log reaches `end of do-file`.
- Confirmed `Output/table4_col1_fullaudit_fe_comparison.tex` was written with exactly two model columns, matching `N = 944` and mean outcome `0.53` in both columns.
- Confirmed representative original outputs, including `Output/table4_main_outcomes_replicated.tex` and `Output/table4_main_outcomes_replicated_with_lee.tex`, were regenerated.

---

Date: 2026-05-05
Task: Add Anne-style 15-bin, 20-bin, and top-split predicted-evasion robustness tables.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/2 Table 8 full audits replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added three nonlinear predicted-evasion control variants to Tables 4, 5, 6, and 8: 15 quantile bins, 20 quantile bins, and a top-split decile specification that keeps deciles 1--8 and splits deciles 9 and 10 into two bins each.
- Kept bins defined on `yhatrf`, the Random Forest prediction of log evasion (`y4`), using the same pooled-sample logic as the existing decile and quintile controls.
- Added bin-support TeX fragments for each table family, reporting total, algorithm-selected, and inspector-selected observations by bin and whether each bin contains both methods.
- Added the new regression and support tables to the corresponding Table 4, 5, 6, and 8 sections of `Inspector's Effort report.tex`.

## Output files affected
- New Table 4 outputs: `Output/table4_main_outcomes_yhatrf_15bins_control*.tex`, `Output/table4_main_outcomes_yhatrf_20bins_control*.tex`, `Output/table4_main_outcomes_yhatrf_topsplit_control*.tex`, and `Output/table4_main_outcomes_yhatrf_bin_support.tex`.
- New Table 5 outputs: `Output/table5_fullaudits_yhatrf_15bins_control.tex`, `Output/table5_fullaudits_yhatrf_20bins_control.tex`, `Output/table5_fullaudits_yhatrf_topsplit_control.tex`, and `Output/table5_fullaudits_yhatrf_bin_support.tex`.
- New Table 6 outputs: `Output/table6_indices_yhatrf_15bins_control.tex`, `Output/table6_indices_yhatrf_20bins_control.tex`, `Output/table6_indices_yhatrf_topsplit_control.tex`, and `Output/table6_indices_yhatrf_bin_support.tex`.
- New Table 8 outputs: `Output/table8_fullaudits_yhatrf_15bins_control.tex`, `Output/table8_fullaudits_yhatrf_20bins_control.tex`, `Output/table8_fullaudits_yhatrf_topsplit_control.tex`, and `Output/table8_fullaudits_yhatrf_bin_support.tex`.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/2 Table 8 full audits replication and yhatrf control.do"`.
- Confirmed all new report-referenced output fragments exist in `Output/`.
- Inspected representative regression and support fragments, including Table 4 Lee-bounds output, Table 6 sparse-bin support rows, and Table 8 sixth-column bin-control output.

## Open issues / next steps
- Full PDF compilation of `Inspector's Effort report.tex` was not rechecked here because prior validation showed the report stops earlier on a pre-existing missing input before reaching these sections.
- Table 6 support diagnostics intentionally show zero-count and one-method bins where the survey subsamples are sparse.

Update: 2026-05-06 (audit-type-specific binning)
- Corrected the Table 4 and Table 6 grouped-control construction so predicted-evasion quantile bins are formed separately within desk and full audits, pooling algorithm- and inspector-selected cases within each audit type.
- Updated the corresponding report notes for Table 4 and Table 6 to describe within-audit-type binning rather than pooling full and desk audits together.
- Re-ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"` and `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"`.
- Confirmed the regenerated support tables now show audit-type-specific equal-size bins, for example Table 4 15-bin support has roughly 63 full-audit observations per bin and roughly 182--184 desk-audit observations per bin.

Update: 2026-05-06 (regression-FE-stratified binning)
- Replaced the grouped `yhatrf` controls in the standalone Table 4, 5, 6, and 8 workflows so quantile bins are formed within the regression fixed-effect strata rather than within audit type or pooled full-audit samples.
- Table 4 now uses separate grouped-control variables for the full-audit inspector-year columns, desk tax-office-year columns, and desk inspector-year columns; the Lee-bounds re-estimation uses the matching full-audit and desk inspector-year controls.
- Table 5 and Table 8 now form grouped controls within `inspectorclusteryear`; Table 6 forms them within `center` by `selectionyear`.
- Reworked the four bin-support fragments to report compact FE-stratified diagnostics: number of FE strata, nonempty stratum-by-bin cells, total observations, method-specific counts, and whether both methods appear.
- Updated `Code Analyse data/Inspector's Effort report.tex` notes for Tables 4, 5, 6, and 8 so grouped-control descriptions match the new FE-stratified binning.
- Regenerated the existing Table 4, 5, 6, and 8 predicted-evasion `.tex` fragments in `Output/`, keeping filenames unchanged.
- Validation: ran all four narrow do-files successfully with `stata-mp /e do`; inspected representative support fragments and grouped-control regression tables to confirm diagnostics are populated and grouped-control coefficients remain hidden in manuscript-facing outputs.
- Report validation: attempted `pdflatex -interaction=nonstopmode -halt-on-error -output-directory "..\.codex_tmp\report_check" "Inspector's Effort report.tex"` from `Code Analyse data`; compilation still stops before these sections on the pre-existing missing input `Output/inspectors_reg_panels_Full_exec_rate.tex`.

Update: 2026-05-06 (40- and 50-bin FE-stratified controls)
- Added two additional grouped predicted-evasion control variants to the standalone Table 4, 5, 6, and 8 workflows: 40 quantile bins and 50 quantile bins.
- Kept the new controls aligned with the regression fixed-effect strata: Table 4 uses the full-audit inspector-year, desk tax-office-year, and desk inspector-year bin variables as appropriate by column; Tables 5 and 8 use `inspectorclusteryear`; Table 6 uses `center` by `selectionyear`.
- Updated the four bin-support fragments so the FE-stratified diagnostics now include 40-bin and 50-bin rows.
- Added the new 40-bin and 50-bin regression tables to `Code Analyse data/Inspector's Effort report.tex`, preserving the existing report structure and using the same manuscript-facing table conventions.
- New output fragments: `Output/table4_main_outcomes_yhatrf_40bins_control*.tex`, `Output/table4_main_outcomes_yhatrf_50bins_control*.tex`, `Output/table5_fullaudits_yhatrf_40bins_control.tex`, `Output/table5_fullaudits_yhatrf_50bins_control.tex`, `Output/table6_indices_yhatrf_40bins_control.tex`, `Output/table6_indices_yhatrf_50bins_control.tex`, `Output/table8_fullaudits_yhatrf_40bins_control.tex`, and `Output/table8_fullaudits_yhatrf_50bins_control.tex`.
- Validation: re-ran all four narrow do-files successfully with `stata-mp /e do`; confirmed the new `.tex` outputs exist; inspected representative 40-bin and 50-bin regression fragments to confirm visible coefficient rows remain unchanged and grouped-control coefficients stay hidden; inspected support fragments to confirm 40-bin and 50-bin diagnostics are populated.
- Report validation: re-ran the same direct `pdflatex` check; compilation remains blocked before these table sections by the pre-existing missing input `Output/inspectors_reg_panels_Full_exec_rate.tex`.

---

Date: 2026-05-05
Task: Convert Anne's 2026-04-22 regression-table reflections into a review task document.

## Files edited
- `Code Analyse data/Anne_Reflections_To_Dos_2026-04-22.md`
- `SESSION_NOTES.MD`

## Substantive changes
- Created a documentation-only markdown file that breaks Anne's comments into review tasks for flexible predicted-evasion controls, subsample checks, number-of-inspectors diagnostics, interpretation checks, and validation steps.
- Kept the note explicitly scoped as planning/review work; no Stata analysis scripts, regression specifications, or output tables were edited.

## Output files affected
- None. No tables, figures, or Stata outputs were regenerated.

## Validation performed
- Checked existing repository markdown conventions and the active Table 8 do-file context.
- No Stata validation was run because this task only created a planning document.

## Open issues / next steps
- Future work should first map each proposed task to the exact do-file and output table before implementing any robustness checks.

Date: 2026-03-31
Project: Senegal Tax Audit replication / revisions

## 1) Objective
Create a standalone Stata workflow that replicates the full-audit version of Table 5 and then re-estimates the same table adding predicted evasion (`yhatrf`) as a control, with Overleaf-ready exports.

## 2) Files touched
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `SESSION_NOTES.MD`

## 3) Main changes
- Added a new standalone do-file that uses `fullaudits_predicted.dta` as the single input source for both the baseline replication and the `yhatrf`-control version.
- Recreated the Table 5 outcome construction and availability regressions for full audits only, including the original admin-duration dummy controls used for the `y19` specification.
- Restored the original duration-construction block from `2 Regressions main results.do` inside the standalone workflow, rebuilding `time0` to `time9`, winsorizing them, and regenerating `dummy1` to `dummy3` before the Table 5 regressions.
- Exported both raw regression fragments and manuscript-ready `threeparttable` wrappers for the replicated baseline and the `yhatrf` specification.

## 4) Definitions / specification updates
- Sample: `selection == 1`, `safeties == 0`, `x2 == 1` (full audits only).
- Key variable definitions: `available_y16`, `available_q30`, `available_y19`, `available_y8`, `evasion_cost1` to `evasion_cost4`, and corresponding availability indicators are rebuilt inside the new do-file.
- Fixed effects: `a(inspectorclusteryear)`.
- Clustering / VCE: `vce(robust)`.
- Output naming:
- `Output/1 regression cost and resources summarized full audits replicated.tex`
- `Output/1 regression cost and resources summarized availability full audits replicated.tex`
- `Output/1 regression cost and resources summarized full audits yhatrf control.tex`
- `Output/1 regression cost and resources summarized availability full audits yhatrf control.tex`
- `Output/table5_fullaudits_replicated_body.tex`
- `Output/table5_fullaudits_replicated_snippets.tex`
- `Output/table5_fullaudits_yhatrf_control_body.tex`
- `Output/table5_fullaudits_yhatrf_control_snippets.tex`

## 5) Outputs created or updated
- `Output/1 regression cost and resources summarized full audits replicated.tex`
- `Output/1 regression cost and resources summarized availability full audits replicated.tex`
- `Output/1 regression cost and resources summarized full audits yhatrf control.tex`
- `Output/1 regression cost and resources summarized availability full audits yhatrf control.tex`
- `Output/table5_fullaudits_replicated_body.tex`
- `Output/table5_fullaudits_replicated_snippets.tex`
- `Output/table5_fullaudits_yhatrf_control_body.tex`
- `Output/table5_fullaudits_yhatrf_control_snippets.tex`

## 6) Validation
- Command run:
- `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- Key diagnostics:
- The new do-file ran through the baseline and `yhatrf` specifications and wrote all requested `.tex` outputs.
- The baseline wrapper/body reproduce the intended A1/B1 and A2/B2 grouped layout with caption and notes.
- Root cause audit showed that the earlier mismatch was not due to the RF seed. The filtered samples and core Table 5 variables were identical across `datasetforanalysis.dta` and `fullaudits_predicted.dta`; the mismatch came from omitting the original date-based duration block that creates `dummy1` to `dummy3` for the `y19` specification.
- A final column-by-column comparison of the regenerated baseline table against the screenshot confirmed that the visible baseline coefficients, standard errors, `N`, `R2`, and mean outcomes now line up with the screenshot values.
- Whether outputs were successfully regenerated:
- Yes, after clearing locked OneDrive-backed output files and rerunning.

## 7) Remaining issues / next steps
- Baseline full-audit Table 5 now matches the screenshot on the visible numeric cells.
- Next natural extension is to apply the same workflow to desk audits if needed.

---

Date: 2026-03-31
Task: Refactor Table 5 full-audit export flow to an integrated `esttab` body plus a lightweight `threeparttable` wrapper.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `SESSION_NOTES.md`

## Substantive changes
- Removed the raw regression-fragment exports from the standalone Table 5 do-file so the export logic now focuses on the manuscript-facing outputs.
- Kept the regression design unchanged and retained the two-step `esttab` pattern that writes one integrated body file with Panel A and Panel B already combined.
- Updated the wrapper output contract so the final manuscript-ready wrappers are named:
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`
- Kept the wrapper logic minimal: it only adds `table`, `threeparttable`, caption, label, `\input{}` of the body file, and a draft Table 5-style note.

## Output files affected
- `Output/table5_fullaudits_replicated_body.tex`
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control_body.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`

## Validation performed
- Ran:
- `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- Confirmed by file inspection that:
- the body files contain both panels in a single `tabular` block;
- the wrapper files `\input{}` the correct body files and include `threeparttable`, caption, label, and draft notes.
- Validation caveat:
- the batch Stata call returned exit code 0 but did not provide a usable console trace in this environment, so final verification relied on direct inspection of the generated `.tex` files.

## Open issues / next steps
- Legacy `_snippets.tex` wrapper outputs remain in `Output/`; they are now redundant with the new wrapper filenames and can be cleaned up later if nothing else references them.

---

Date: 2026-03-31
Task: Restructure the Table 5 standalone do-file so data import and preparation are explicit top-level steps.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `SESSION_NOTES.md`

## Substantive changes
- Removed the program that combined data loading, sample construction, variable preparation, and table export inside a single helper.
- Reorganized the do-file into a linear Stata workflow:
- import the analysis data;
- prepare the full-audit sample and derived variables once;
- export the baseline Table 5 replication;
- export the corresponding table with `yhatrf` as an additional control.
- Kept the regression specifications and export format unchanged while making the script easier to read and debug in standard Stata order.

## Output files affected
- `Output/table5_fullaudits_replicated_body.tex`
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control_body.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- The do-file completed with exit code 0 after the restructuring.

## Open issues / next steps
- The current output folder still contains legacy `_snippets.tex` files from the earlier export naming scheme.

---

Date: 2026-04-01
Task: Refactor standalone Table 5 full-audit exports to pure `esttab` outputs without `file write`.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `SESSION_NOTES.md`

## Substantive changes
- Removed the helper program that used `file write` to build Table 5 wrappers.
- Changed the standalone Table 5 do-file so each specification writes one complete manuscript-ready `.tex` table directly from `esttab`.
- Kept the replicated full-audit Table 5 sample and regression logic unchanged, then applied the same export pattern to the `yhatrf`-control specification.
- Preserved the explicit duplicated baseline / `yhatrf` export blocks so the original Table 5 replication remains easy to audit against `2 Regressions main results.do`.

## Output files affected
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- Confirmed from the Stata log that the new `esttab` export blocks executed and wrote both final `.tex` files.
- Inspected the regenerated outputs and confirmed that each file now contains the full table environment, `threeparttable`, both panels in one `tabular`, and the corresponding notes.
- Validation required deleting the previously locked generated `.tex` outputs in `Output/` before rerunning, because Stata initially stopped with `r(608)` when those files could not be modified.

## Open issues / next steps
- Legacy `_body.tex` and `_snippets.tex` Table 5 outputs remain in `Output/` from the older export flow; they are now stale and no longer produced by this do-file.

---

Date: 2026-04-01
Task: Clean legacy standalone Table 5 `.tex` outputs from `Output/`.

## Files edited
- `SESSION_NOTES.md`

## Substantive changes
- Removed the stale legacy Table 5 exports left over from the old wrapper-based flow:
- `Output/table5_fullaudits_replicated_body.tex`
- `Output/table5_fullaudits_replicated_snippets.tex`
- `Output/table5_fullaudits_yhatrf_control_body.tex`
- `Output/table5_fullaudits_yhatrf_control_snippets.tex`
- Kept the new final pure-`esttab` outputs only:
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`

## Output files affected
- Deleted the four legacy Table 5 `_body.tex` / `_snippets.tex` files listed above.

## Validation performed
- Listed `Output/table5_fullaudits*.tex` after cleanup and confirmed that only the two final `.tex` tables remain.
- Cleanup required elevated deletion because the OneDrive-backed files were locked for normal removal.

## Open issues / next steps
- None for the Table 5 output contract; `Output/` now matches the new pure-`esttab` workflow.

---

Date: 2026-04-01
Task: Refocus standalone full-audit Table 5 exports on Panels A1/B1 and add nonlinear `yhatrf` robustness.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `SESSION_NOTES.md`

## Substantive changes
- Refactored the standalone Table 5 do-file so the final manuscript-facing exports now include only the top panels of the full-audit table: A1 resource outcomes and B1 productivity outcomes.
- Removed the appended A2/B2 availability-panel export blocks while leaving the sample construction, duration rebuilding, outcome definitions, and original `dummy1 dummy2 dummy3` controls unchanged.
- Updated the baseline replication and linear-`yhatrf` notes and captions so they explicitly describe the top-panels-only export.
- Added a third standalone robustness export that controls for both `yhatrf` and `yhatrf^2` via `c.yhatrf##c.yhatrf`.
- Treated the quadratic specification as supplementary rather than default, matching the diagnostic conclusion that `yhatrf + yhatrf^2` is more defensible than `yhatrf^2` alone.

## Output files affected
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`
- `Output/table5_fullaudits_yhatrf_quadratic_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- Confirmed that the regenerated `.tex` outputs now contain only Panels A1 and B1, keep the intended 8-column layout, and include the revised captions and notes.
- Confirmed that the new quadratic robustness file was generated and that its note states the specification includes both `yhatrf` and `yhatrf^2`.
- Validation initially failed because the old generated `.tex` files were locked and Stata stopped with `r(608)`; after removing those locked outputs, the do-file reran successfully and regenerated all three tables.

## Open issues / next steps
- None for the requested Table 5 top-panel refactor. If needed later, the same pattern can be applied to desk-audit exports or to a separate diagnostic comparison table.

---

Date: 2026-04-01
Task: Move standalone full-audit Table 5 notes out of Stata and into `Inspector's Effort report.tex`.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Changed the standalone Table 5 do-file so the three full-audit outputs now export only the `tabular` fragment used by `\input{...}`, rather than writing full `table` / `threeparttable` wrappers and note text.
- Kept the underlying sample, resource and productivity outcomes, `dummy1` to `dummy3` admin-duration controls, and the three regression specifications unchanged.
- Added a new top-level `\section{Audit productivity}` to the inspector-effort report and inserted three manuscript-facing table wrappers there for:
- `table5_fullaudits_replicated.tex`
- `table5_fullaudits_yhatrf_control.tex`
- `table5_fullaudits_yhatrf_quadratic_control.tex`
- Moved the table notes into the report and tailored them to each variant while keeping the Table 5 language anchored on Panels A1 and B1 only.

## Output files affected
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`
- `Output/table5_fullaudits_yhatrf_quadratic_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- The first rerun failed with `r(608)` because the three generated `.tex` outputs were locked and could not be overwritten.
- Removed the locked generated files and reran the do-file successfully.
- Confirmed by direct inspection that all three regenerated outputs now begin with `\begin{tabular}` and no longer contain `\begin{table}`, `\begin{threeparttable}`, or `tablenotes`.
- Ran:
- `pdflatex -interaction=nonstopmode -halt-on-error "Inspector's Effort report.tex"`
- Full report compilation did not complete because of a pre-existing missing input earlier in the report: `Output/inspectors_reg_panels_Full_exec_rate.tex`. The new Audit productivity section therefore received static verification by file inspection rather than full-PDF confirmation in this run.

## Open issues / next steps
- If desired, the next cleanup step is to restore or regenerate `Output/inspectors_reg_panels_Full_exec_rate.tex` so the full report can compile end to end again.

---

Date: 2026-04-01
Task: Add standalone Table 6 index exports with predicted evasion controls.

## Files edited
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Added a new standalone do-file that appends `fullaudits_predicted.dta` and `deskaudits_predicted.dta`, checks for `yhatrf`, and rebuilds the original taxpayer-survey Table 6 index workflow.
- Recreated the original Table 6 sample preparation used for the survey-index exercise, including `selfreported_audit`, the `drop if selfreported_audit == 0` restriction, the `drop if q1 == .` restriction, the `q34` cleanup, `q32_inverted`, and the `swindex` construction of `index_efficiency` and `index_corruption`.
- Exported three screenshot-style six-column index tables as `esttab` tabular fragments: the baseline replication, a linear `yhatrf` control specification, and a quadratic `yhatrf + yhatrf^2` robustness specification.
- Added manuscript-facing report wrappers for the two new predicted-evasion Table 6 variants so captions and notes now live in LaTeX rather than in the Stata export step.

## Output files affected
- `Output/table6_indices_replicated.tex`
- `Output/table6_indices_yhatrf_control.tex`
- `Output/table6_indices_yhatrf_quadratic_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/6 Table 6 yhatrf control.do"`
- Confirmed from direct diagnostics against `3 Analysis taxpayer survey.do` that the baseline Table 6 sample and regression backbone are reproduced correctly when the standalone workflow applies the same sample restrictions. In particular, the baseline index regressions reproduce the screenshot-style Ns:
- Panel A: 199 / 273 / 472 for `index_efficiency`, and 199 / 272 / 471 for `index_corruption`
- Panel B: 89 / 120 / 211 for `index_efficiency`, and 88 / 122 / 212 for `index_corruption`
- Confirmed by separate diagnostics that the appended predicted-audit inputs (`fullaudits_predicted.dta` plus `deskaudits_predicted.dta`) deliver the same baseline Table 6 counts and `algorithm` coefficients as `datasetforanalysis.dta` once the original `3 Analysis taxpayer survey.do` restrictions are applied.
- Inspected `Inspector's Effort report.tex` and confirmed that the two new report wrappers reference the linear and quadratic Table 6 fragment filenames and distinguish `yhatrf` from `yhatrf + yhatrf^2` in the notes.
- Validation caveat:
- The mismatch observed during inspection came from stale or missing generated `.tex` fragments rather than from the regression sample itself. Stata repeatedly hit `r(608)` when trying to overwrite `Output/table6_indices_*.tex`, so the visible exported files could lag behind the successfully estimated regressions.

## Open issues / next steps
- Resolve the file-lock / overwrite issue affecting `Output/table6_indices_*.tex` so the regenerated fragments reflect the already-matching regression results from the standalone do-file.

---

Date: 2026-04-01
Task: Diagnose and clear the Output-file lock blocking Table 6 regeneration.

## Files edited
- `SESSION_NOTES.md`

## Substantive changes
- Confirmed by direct comparison against `3 Analysis taxpayer survey.do` that the standalone Table 6 baseline regressions were already matching the original screenshot specification and sample counts.
- Traced the apparent mismatch to a file-lock problem on `Output/table6_indices_*.tex`: Stata was hitting `r(608)` when trying to overwrite the generated fragments, so the inspected files were stale.
- Temporarily paused OneDrive, reran the standalone Table 6 do-file, and verified that the regenerated exported fragments now reflect the correct baseline regression results.

## Output files affected
- `Output/table6_indices_replicated.tex`
- `Output/table6_indices_yhatrf_control.tex`
- `Output/table6_indices_yhatrf_quadratic_control.tex`

## Validation performed
- Paused the running OneDrive processes temporarily.
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/6 Table 6 yhatrf control.do"`
- Confirmed from the regenerated `Output/table6_indices_replicated.tex` that the baseline export now matches the original Table 6 screenshot on the visible rows, including:
- Panel A Ns `199 / 273 / 472` and `199 / 272 / 471`
- Panel B Ns `89 / 120 / 211` and `88 / 122 / 212`
- Confirmed that the linear and quadratic `yhatrf` variants were also regenerated successfully after the lock was cleared.

## Open issues / next steps
- If OneDrive resumes locking generated `.tex` outputs, reruns may again require pausing sync or writing to temporary filenames before replacing the final files.

---

Date: 2026-04-01
Task: Tighten Table 6 report notes and compile-check the report after regenerating locked outputs.

## Files edited
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Updated the standalone Table 6 subsection in the report so the introductory text and both table notes now explicitly reference the confirmed baseline source file `3 Analysis taxpayer survey.do`.
- Clarified in the notes that the Table 6 variants use the original selected non-safety sample with `recent == selectionyear`, the original survey-index construction, Panel A defined by self-reported recent audits, and Panel B defined by administratively recorded audited firms (`y2 == 1`).
- Temporarily paused OneDrive again to avoid the output-file lock that had been preventing clean regeneration of the standalone Table 6 `.tex` fragments.

## Output files affected
- `Output/table6_indices_replicated.tex`
- `Output/table6_indices_yhatrf_control.tex`
- `Output/table6_indices_yhatrf_quadratic_control.tex`

## Validation performed
- Reran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/6 Table 6 yhatrf control.do"`
- Confirmed by direct inspection that `Output/table6_indices_replicated.tex` now matches the original Table 6 screenshot on the visible baseline rows and sample counts after the lock was cleared.
- Ran:
- `pdflatex -interaction=nonstopmode -halt-on-error "Inspector's Effort report.tex"`
- The full report still does not compile end to end because of a pre-existing missing input earlier in the document:
- `Output/inspectors_reg_panels_Full_exec_rate.tex`
- This failure occurs before the new Table 6 subsection, so the Table 6 integration was verified by static inspection rather than by a complete PDF build.

## Open issues / next steps
- Restart OneDrive when convenient if normal sync behavior is needed again.
- Full report compilation still requires restoring or regenerating `Output/inspectors_reg_panels_Full_exec_rate.tex`.

---

Date: 2026-04-01
Task: Harmonize Table 5/Table 6 predicted-evasion notes and expose predicted-evasion coefficients in the standalone robustness tables.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Updated the standalone Table 5 robustness exports so the linear predicted-evasion variant now displays a `Predicted evasion` row, and the quadratic variant displays both `Predicted evasion` and `Predicted evasion squared`, after the main treatment coefficients and before the summary statistics.
- Updated the standalone Table 6 robustness exports the same way, keeping the original treatment rows first and then showing the predicted-evasion control coefficients in both Panel A and Panel B.
- Rewrote the four new Table 5/Table 6 robustness notes in `Inspector's Effort report.tex` to use manuscript-style language rather than code-facing references, and cleaned the nearby section-intro prose to describe the robustness tables in plain language.
- Kept the underlying regression specifications unchanged; only the displayed coefficient rows and the report prose/notes were revised.

## Output files affected
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`
- `Output/table5_fullaudits_yhatrf_quadratic_control.tex`
- `Output/table6_indices_replicated.tex`
- `Output/table6_indices_yhatrf_control.tex`
- `Output/table6_indices_yhatrf_quadratic_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/6 Table 6 yhatrf control.do"`
- Initial reruns were blocked by `r(608)` because the existing generated `.tex` outputs were locked and could not be overwritten.
- Removed the six affected generated output files and reran both standalone scripts successfully.
- Confirmed by direct inspection that:
- `Output/table5_fullaudits_yhatrf_control.tex` includes `Predicted evasion`;
- `Output/table5_fullaudits_yhatrf_quadratic_control.tex` includes `Predicted evasion` and `Predicted evasion squared`;
- `Output/table6_indices_yhatrf_control.tex` includes `Predicted evasion` in both panels;
- `Output/table6_indices_yhatrf_quadratic_control.tex` includes `Predicted evasion` and `Predicted evasion squared` in both panels.
- Checked the revised Table 5/Table 6 robustness notes in `Inspector's Effort report.tex` and confirmed that the edited notes no longer mention do-files or raw variable names.

## Open issues / next steps
- The baseline replicated Table 5 note in `Inspector's Effort report.tex` still contains older code-facing wording; this was left unchanged because the requested scope was limited to the new robustness-table notes and nearby intro prose.

---

Date: 2026-04-01
Task: Reword the new Table 5 and Table 6 robustness footnotes to track the original manuscript notes more closely.

## Files edited
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Rewrote the four predicted-evasion robustness notes for Table 5 and Table 6 so they now follow the original manuscript note language much more closely.
- Kept the new content limited to the robustness-specific additions that the specifications include predicted evasion, or predicted evasion and its square.
- Preserved the earlier coefficient-row additions in the exported tables; this update only changed the report footnote wording.

## Output files affected
- `Code Analyse data/Inspector's Effort report.tex`

## Validation performed
- Checked the edited note text in `Inspector's Effort report.tex` by direct inspection.
- No Stata rerun was needed because this update only changed LaTeX report text.

## Open issues / next steps
- None for this wording update.

---

Date: 2026-04-01
Task: Add the baseline replicated Table 6 output to the report with the original manuscript footnote.

## Files edited
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Confirmed that `Code Analyse data/6 Table 6 yhatrf control.do` exports the baseline replicated Table 6 fragment in addition to the linear and quadratic predicted-evasion variants.
- Added the baseline replicated Table 6 to `Inspector's Effort report.tex` using `Output/table6_indices_replicated.tex`.
- Inserted the original-style Table 6 manuscript note for the baseline replication and adjusted the subsection intro so it now introduces the baseline table plus the robustness variants.

## Output files affected
- `Code Analyse data/Inspector's Effort report.tex`

## Validation performed
- Confirmed by inspection of `Code Analyse data/6 Table 6 yhatrf control.do` that the do-file exports `table6_indices_replicated.tex` in its baseline block.
- Confirmed that `Output/table6_indices_replicated.tex` exists and is available for inclusion in the report.
- No Stata rerun was needed for this report-integration update.

## Open issues / next steps
- None for this Table 6 report insertion.

---

Date: 2026-04-13
Task: Migrate the active `6*` and `7 Inspector_performance.do` workflows from the OneDrive repo to a local working repo outside OneDrive.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/7 Inspector_performance.do`
- `Code Analyse data/6 Inspector effort - bin plots.do`
- `Code Analyse data/6 Inspector effort - bin plots_executed_outcome_availability.do`
- `Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do`
- `Code Analyse data/6 Inspector effort - Case potential.do`
- `Code Analyse data/6 Inspector effort - Case potential_wDeskaudits.do`
- `Code Analyse data/6 Inspector effort - Case potential_wDeskaudits_v2.do`
- `Code Analyse data/6 Inspector effort - Case potential_wDeskaudits_v3_inspector_exec_rate.do`
- `Code Analyse data/6 Inspector effort - Corruption.do`
- `Code Analyse data/6 Inspector effort 2.0.do`
- `Code Analyse data/6 Inspector effort 3.0.do`
- `Code Analyse data/6 Inspector effort 4.0.do`
- `Code Analyse data/6 Inspector effort 4.2_evasionrates.do`
- `Code Analyse data/6 Inspector effort 4.3_evasionrates.do`
- `Code Analyse data/6 Inspector effort 4.3_evasionrates_fullaudits.do`
- `Code Analyse data/6 Inspector effort 4.3_evasionrates_fullaudits_successrates.do`
- `Code Analyse data/6 Inspector effort 4.3_evasionrates_fullaudits_successrates_selectionyear_algorithm.do`
- `Code Analyse data/6 Inspector effort 4.4_evasionrates.do`
- `SESSION_NOTES.MD`

## Substantive changes
- Preserved the pre-migration OneDrive repo state by committing and pushing the current `inspector_effort` branch before making path changes.
- Updated the active `6*` and `7 Inspector_performance.do` workflows so their `check == 1` output overrides now point to `C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output` instead of the OneDrive-backed repo.
- Updated the active helper scripts that rely on the repo-local `ado` folder so they now point to `C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\ado`.
- Replaced the one direct hardcoded predicted-data load in `6 Inspector effort - Case potential.do` with the existing `$analysisdata` macro so the Dropbox-based input path remains consistent with the rest of the active workflow.
- Created the new local working clone at `C:\Users\wb648862\Documents\Projects\Senegal Tax Audits` on branch `inspector_effort`.

## Output files affected
- Active `6*` workflow outputs now write to `C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output` when `global check = 1`.
- `6 Table 6 yhatrf control.do` regenerated the local `table6_indices_replicated.tex`, `table6_indices_yhatrf_control.tex`, and `table6_indices_yhatrf_quadratic_control.tex` outputs in the new local clone.
- `7 Inspector_performance.do` regenerated the local `w_*` tables and related figure outputs in the new local clone.

## Validation performed
- Verified that the new local clone exists at `C:\Users\wb648862\Documents\Projects\Senegal Tax Audits`, is a Git repository, and is on `inspector_effort` at commit `d2f085e` before this notes update.
- Ran `Code Analyse data\6 Table 6 yhatrf control.do` from the new local clone with Stata batch mode.
- Ran `Code Analyse data\7 Inspector_performance.do` from the new local clone with Stata batch mode.
- Confirmed that the regenerated `table6_*` outputs and `w_*` outputs were written under the new local `Output` folder.
- Confirmed that the local clone remained clean after validation, indicating the checked-in path edits matched the validated run state.

## Open issues / next steps
- The old OneDrive repo remains on disk and still contains the historical working copy; avoid using it for active edits.
- Older non-active Stata scripts outside the `6*` / `7` scope still keep their legacy path logic and may need similar updates if they are brought back into active use.


---

Date: 2026-04-13
Task: Add predicted-evasion decile-control robustness exports to the standalone Table 5 and Table 6 workflows.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a pooled-sample `yhatrf_decile` variable to the shared prep block of each standalone Stata workflow before outcome-specific restrictions are applied.
- Added a fourth robustness export to the standalone full-audit Table 5 workflow that controls for predicted-evasion deciles via `ib1.yhatrf_decile` while keeping the displayed table rows limited to the original treatment coefficients.
- Added a fourth robustness export to the standalone Table 6 workflow that controls for predicted-evasion deciles in both panels, again hiding the decile coefficients from the manuscript-facing table.
- Added matching LaTeX wrappers to `Inspector's Effort report.tex` for the two new decile-control tables, reusing the existing robustness notes and changing only the control description to predicted-evasion deciles.
- Re-saved the two edited `.do` files in plain ASCII after implementation so Stata would read them correctly in batch mode.

## Output files affected
- `Output/table5_fullaudits_replicated.tex`
- `Output/table5_fullaudits_yhatrf_control.tex`
- `Output/table5_fullaudits_yhatrf_quadratic_control.tex`
- `Output/table5_fullaudits_yhatrf_deciles_control.tex`
- `Output/table6_indices_replicated.tex`
- `Output/table6_indices_yhatrf_control.tex`
- `Output/table6_indices_yhatrf_quadratic_control.tex`
- `Output/table6_indices_yhatrf_deciles_control.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/6 Table 6 yhatrf control.do"`
- Confirmed that the new files `Output/table5_fullaudits_yhatrf_deciles_control.tex` and `Output/table6_indices_yhatrf_deciles_control.tex` were generated successfully.
- Confirmed by direct inspection that the new decile-control exports keep the same table layouts as the existing robustness variants, hide the decile coefficients, and preserve the displayed treatment-row ordering.
- Confirmed that the `N` rows in the new decile-control exports match the corresponding linear-`yhatrf` tables for both Table 5 and Table 6.
- Confirmed by inspection that `Code Analyse data/Inspector's Effort report.tex` now includes the new decile-control wrappers, captions, labels, and note text for both tables.

## Open issues / next steps
- Full report compilation was not rerun here; the manuscript integration of the new tables was verified by static inspection of the LaTeX wrappers and successful regeneration of the `.tex` fragments.

---

Date: 2026-04-13
Task: Redefine predicted-evasion deciles on executed cases in the standalone Table 5 and Table 6 robustness workflows.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Changed the shared `yhatrf_decile` construction in the standalone Table 5 workflow so deciles are now pooled over executed cases only (`y2 == 1`) rather than the broader prepared sample.
- Made the same executed-case decile change in the standalone Table 6 workflow, keeping one pooled executed-case decile definition per prepared dataset and reusing it across the decile-control regressions.
- Added short code comments in both do-files documenting that the decile controls now follow the executed-case logic used in the inspector-effort binning workflow.
- Updated the decile-control notes in `Inspector's Effort report.tex` so the manuscript-facing text explicitly states that predicted-evasion deciles are formed among executed cases only.

## Output files affected
- `Output/table5_fullaudits_yhatrf_deciles_control.tex`
- `Output/table6_indices_yhatrf_deciles_control.tex`

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"`.
- Confirmed that `Output/table5_fullaudits_yhatrf_deciles_control.tex` and `Output/table6_indices_yhatrf_deciles_control.tex` were regenerated successfully on 2026-04-13.
- Confirmed by direct inspection that the report notes for the two decile-control tables now describe the executed-case decile rule.
- Compared the current linear-`yhatrf` and decile-control `N` rows: in Table 5, the taxpayer-survey duration column falls from `N = 214` to `N = 105` once deciles are defined on executed cases only; the other Table 5 columns are unchanged. In the current Table 6 outputs, the decile-control `N` rows match the linear-`yhatrf` `N` rows.

## Open issues / next steps
- Full LaTeX compilation of `Inspector's Effort report.tex` was not rerun here; manuscript integration was validated through successful `.tex` regeneration and direct inspection of the updated note text.

---

Date: 2026-04-13
Task: Add an appendix support table for the preferred whole-sample predicted-evasion decile effort plots.

## Files edited
- `Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a support-table export to the whole-sample bin-plot workflow for full audits, predicted evasion, pooled deciles only.
- Reused the same pooled selected-sample decile assignment as the preferred figure, then merged it with executed-case outcome moments so the support table aligns exactly with the plotted means and confidence intervals.
- Exported a new landscape-style LaTeX fragment with selected counts, executed counts, and outcome-specific `N`, mean, SD, SE, and CI bounds for the four effort outcomes.
- Added an appendix table wrapper in the report immediately after the preferred whole-sample predicted-evasion effort figures.
- Made the table note explicit that bins are defined on the pooled selected sample but all effort outcomes are computed for executed cases only (`y2==1`).

## Output files affected
- `Output/bin_support_yhatrf_Full_decile_whole_sample.tex`

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do"` via a logged wrapper and confirmed the do-file completed.
- Confirmed that `Output/bin_support_yhatrf_Full_decile_whole_sample.tex` was generated successfully on 2026-04-13.
- Confirmed that the support table contains exactly 20 method-by-decile rows.
- Cross-checked the support counts against the preferred figure logic: top-decile inspector executed support (`62`) exceeds top-decile algorithm executed support (`17`).
- Confirmed that the `numberagents` moments in the support table match the preferred plot construction, including top-decile means and CI bounds (`Algorithm: mean 3.24, CI [2.84, 3.63]`; `Inspector: mean 3.53, CI [3.31, 3.76]`).

## Open issues / next steps
- Full LaTeX compilation of `Code Analyse data/Inspector's Effort report.tex` was not rerun here; manuscript integration was validated by direct inspection of the new wrapper and successful support-table export.


---

Date: 2026-04-13
Task: Restore pooled regression-sample predicted-evasion deciles in the standalone Table 5 and Table 6 robustness workflows.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Reversed the executed-case-only `yhatrf_decile` construction in the standalone Table 5 workflow and now form deciles on the pooled regression-eligible full-audit sample.
- Reversed the executed-case-only `yhatrf_decile` construction in the standalone Table 6 workflow and now form deciles on the pooled prepared survey-analysis sample.
- Updated the manuscript-facing notes for the two decile-control tables so the text matches the restored pooled-sample decile definition.
- Dropped the planned no-`algorithm` predicted-evasion robustness extension for now, per user direction, and kept this pass focused on correcting the decile-spec sample distortion.

## Output files affected
- `Output/table5_fullaudits_yhatrf_deciles_control.tex`
- `Output/table6_indices_yhatrf_deciles_control.tex`

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"`.
- Confirmed that `Output/table5_fullaudits_yhatrf_deciles_control.tex` now keeps the intended Table 5 decile-spec sample, including `N = 214` in the taxpayer-survey duration column.
- Confirmed that `Output/table6_indices_yhatrf_deciles_control.tex` now preserves the intended Panel A sample and no longer duplicates Panel B counts; Panel A `N` values return to `199 / 273 / 472` and Panel B remains `89 / 120 / 211` for the efficiency index.
- Confirmed by direct inspection that the corresponding report notes now describe pooled regression-eligible deciles rather than executed-case-only deciles.

## Open issues / next steps
- No new no-`algorithm` robustness tables were generated in this pass.
- Full LaTeX compilation of `Code Analyse data/Inspector's Effort report.tex` was not rerun here; manuscript integration was validated through successful `.tex` regeneration and direct inspection of the updated notes.

---

Date: 2026-04-13
Task: Add predicted-evasion quintile-control robustness exports to the standalone Table 5 and Table 6 workflows.

## Files edited
- `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`
- `Code Analyse data/6 Table 6 yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a pooled-sample `yhatrf_quintile` variable to the shared prep block of each standalone Stata workflow alongside the existing decile assignment.
- Added a fifth robustness export to the standalone full-audit Table 5 workflow that controls for predicted-evasion quintiles via `ib1.yhatrf_quintile` while keeping the displayed table rows limited to the original treatment coefficients.
- Added a fifth robustness export to the standalone Table 6 workflow that controls for predicted-evasion quintiles in both panels, again hiding the quintile coefficients from the manuscript-facing table.
- Added matching LaTeX wrappers to `Inspector's Effort report.tex` for the two new quintile-control tables, reusing the existing robustness-note language and updating only the grouped-control description to predicted-evasion quintiles.

## Output files affected
- `Output/table5_fullaudits_yhatrf_quintiles_control.tex`
- `Output/table6_indices_yhatrf_quintiles_control.tex`

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`.
- Ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"`.
- Confirmed that `Output/table5_fullaudits_yhatrf_quintiles_control.tex` and `Output/table6_indices_yhatrf_quintiles_control.tex` were generated successfully on 2026-04-13.
- Confirmed by direct inspection that both new quintile-control exports keep the same visible coefficient rows and table layouts as the corresponding decile-control variants while hiding the grouped-control coefficients.
- Confirmed by inspection that `Code Analyse data/Inspector's Effort report.tex` now includes the two new quintile-control wrappers, captions, labels, and note text.

## Open issues / next steps
- Full LaTeX compilation of `Code Analyse data/Inspector's Effort report.tex` was not rerun here; manuscript integration was validated through successful `.tex` regeneration and direct inspection of the updated wrappers.



---

Date: 2026-04-14
Task: Add a CI-decomposition diagnostic figure for the executed-only whole-sample predicted-evasion decile plot of average inspectors.

## Files edited
- `Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a new diagnostic figure for the preferred full-audit, `yhatrf`, pooled-sample decile specification that decomposes the executed-only `numberagents` CI width into executed-case counts, within-decile SDs, and the implied SEs.
- Reused the same executed-only collapsed dataset already used for the main `avg_ninspectors` bin plot so the diagnostic inherits the exact same sample restriction (`y2==1`), pooled deciles, and algorithm-versus-inspector split.
- Kept the existing appendix support table logic unchanged and exported the new diagnostic as a companion PDF rather than replacing the table.

## Output files affected
- `Output/diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample.pdf`
- `Output/bin_support_yhatrf_Full_decile_whole_sample.tex`

## Validation performed
- Launched `stata-mp /e do "Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do"` and confirmed that the run reached the preferred full-audit whole-sample decile branch before producing the new diagnostic PDF and regenerating the support table.
- Confirmed that `Output/diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample.pdf` and `Output/bin_support_yhatrf_Full_decile_whole_sample.tex` were both written on 2026-04-14 at 11:55:46 AM.
- Stopped the still-running Stata process after those target outputs were generated, since the remaining loops were outside the narrow validation target for this change.

## Open issues / next steps
- I did not wait for the full do-file to finish every other plot/export combination after the target diagnostic output was produced.
- If needed for manuscript integration, the next step would be to decide whether this diagnostic stays as a coauthor note only or also gets a wrapper in `Code Analyse data/Inspector's Effort report.tex`.

Update: 2026-04-14 (diagnostic figure clarification)
- Clarified the CI diagnostic figure legend and SE panel wording in `Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do` so the third panel reads `SE = SD / sqrt(N)` with explicit `Algorithm cases` / `Inspector cases` labels.
- Validated the refreshed wording by exporting `Output/diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample_v2.pdf` from a narrow Stata refresh script.
- The original `Output/diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample.pdf` did not overwrite during validation, likely because the existing PDF was locked by another process; the corrected content is therefore confirmed in the `_v2` export.

Update: 2026-04-14 (standalone diagnostic workflow)
- Moved the CI-decomposition diagnostic for `numberagents` into a new quick-run do-file: `Code Analyse data/6 Inspector effort - diagnostic ninspectors ci.do`.
- Removed the diagnostic-figure generation block from `Code Analyse data/6 Inspector effort - bin plots_whole-sample-selected-cases.do` so the main production script goes back to generating only the main figures and support table.
- The new standalone script reproduces the preferred specification only: full audits, pooled `yhatrf` deciles on the selected sample, and executed-only moments for `numberagents`.
- Validated by running `stata-mp /e do "Code Analyse data/6 Inspector effort - diagnostic ninspectors ci.do"` and confirming that `Output/diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample.pdf` was refreshed successfully with the clarified SE panel wording.

---

Date: 2026-04-14
Task: Add a standalone Table 4 predicted-evasion robustness workflow with Lee-bounds exports and manuscript-style report wrappers.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.md`

## Substantive changes
- Added a new standalone Stata do-file that appends `fullaudits_predicted.dta` and `deskaudits_predicted.dta`, rebuilds the baseline Table 4 sample, and exports five manuscript-facing variants: baseline replication, linear `yhatrf`, quadratic `yhatrf`, pooled-sample `yhatrf` deciles, and pooled-sample `yhatrf` quintiles.
- Kept the main Table 4 regression backbone aligned with `2 Regressions main results.do` for the displayed nine columns (`ry2_1/4/5`, `ry3_1/4/5`, `ry4_1/4/5`), including the same outcome-specific missingness rules, FE indicator rows, and summary-stat rows.
- Rebuilt the Table 4 Lee-bounds row for each variant as a separate `_with_lee` output by re-running the attrition-trimming logic on the corresponding estimation samples and inserting the bracket row ahead of `Inspectors x Overlap`.
- Added a new Table 4 subsection to `Inspector's Effort report.tex` ahead of the existing Table 5/6 robustness section, with five wrappers that use notes closely matching the manuscript Table 4 language plus a one-sentence statement of the predicted-evasion specification used in each variant.
- Simplified the exported table header text to plain `P(Detection | Execution)` and `log(Evasion) | Detection` labels so the standalone Stata export would not lose text through `$...$` parsing.

## Output files affected
- `Output/table4_main_outcomes_replicated.tex`
- `Output/table4_main_outcomes_replicated_with_lee.tex`
- `Output/table4_main_outcomes_yhatrf_control.tex`
- `Output/table4_main_outcomes_yhatrf_control_with_lee.tex`
- `Output/table4_main_outcomes_yhatrf_quadratic_control.tex`
- `Output/table4_main_outcomes_yhatrf_quadratic_control_with_lee.tex`
- `Output/table4_main_outcomes_yhatrf_deciles_control.tex`
- `Output/table4_main_outcomes_yhatrf_deciles_control_with_lee.tex`
- `Output/table4_main_outcomes_yhatrf_quintiles_control.tex`
- `Output/table4_main_outcomes_yhatrf_quintiles_control_with_lee.tex`

## Validation performed
- Ran:
- `C:\Program Files\StataNow19\StataMP-64.exe /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"`
- Confirmed that all ten Table 4 output fragments listed above were written successfully on 2026-04-14.
- Confirmed by direct inspection that the baseline replicated export matches the screenshot-style Table 4 backbone on the visible coefficient rows, statistic rows, and overall 9-column layout.
- Confirmed by direct inspection that the linear and quadratic robustness tables show the `yhatrf` terms explicitly, while the decile and quintile variants keep only the original treatment rows visible.
- Confirmed by direct inspection that the Lee-bounds row is inserted in columns 4, 6, 7, and 9 of the `_with_lee` outputs, consistent with the legacy Table 4 presentation.
- Ran:
- `pdflatex -interaction=nonstopmode -halt-on-error "Inspector's Effort report.tex"`
- The report compile still stops on the pre-existing missing file `Output/inspectors_reg_panels_Full_exec_rate.tex` before reaching the new Table 4 subsection, so report integration was validated by successful `.tex` generation and direct inspection of the inserted LaTeX wrappers rather than full-PDF confirmation.

## Open issues / next steps
- Full PDF validation of `Inspector's Effort report.tex` still requires restoring or regenerating the pre-existing missing input `Output/inspectors_reg_panels_Full_exec_rate.tex`.
- If desired, the next check is a cell-by-cell comparison of the new baseline fragment against a regenerated legacy `1 regression main outcomes with Lee.tex` export from `2 Regressions main results.do`.

---

Date: 2026-04-14
Task: Add a standalone Table 8 predicted-evasion robustness workflow with manuscript-style report wrappers.

## Files edited
- `Code Analyse data/2 Table 8 full audits replication and yhatrf control.do`
- `Code Analyse data/Inspector's Effort report.tex`
- `SESSION_NOTES.MD`

## Substantive changes
- Added a new standalone Stata do-file that uses `fullaudits_predicted.dta` as the single input source, rebuilds the full-audit Table 8 sample, and exports five manuscript-facing variants: the original five-column replication plus linear `yhatrf`, quadratic `yhatrf`, pooled-sample `yhatrf` decile, and pooled-sample `yhatrf` quintile specifications with a sixth robustness column.
- Kept the original Table 8 control ladder unchanged in Columns 1 to 5 and added the predicted-evasion specification only in Column 6 of the robustness exports.
- Preserved the original three-panel layout and visible treatment-coefficient focus by exporting only the `Algorithm` row in Panels A-C, while extending Panel C's control-indicator block with a `Predicted evasion` row to mark the new sixth column.
- Added a new Table 8 subsection to `Code Analyse data/Inspector's Effort report.tex` with one baseline wrapper and four robustness wrappers, using notes closely modeled on the manuscript Table 8 wording and variant-specific sentences for the Column 6 predicted-evasion controls.

## Output files affected
- `Output/table8_fullaudits_replicated.tex`
- `Output/table8_fullaudits_yhatrf_control.tex`
- `Output/table8_fullaudits_yhatrf_quadratic_control.tex`
- `Output/table8_fullaudits_yhatrf_deciles_control.tex`
- `Output/table8_fullaudits_yhatrf_quintiles_control.tex`

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 8 full audits replication and yhatrf control.do"`.
- Confirmed that all five Table 8 output fragments listed above were written successfully on 2026-04-14.
- Confirmed by direct inspection that `Output/table8_fullaudits_replicated.tex` keeps the original three-panel, five-column Table 8 backbone and reproduces the visible `Algorithm`, `N`, `R2`, and mean-outcome rows.
- Confirmed by direct inspection that each robustness export adds a sixth column, keeps grouped-control dummies hidden, and marks the new robustness specification through the `Predicted evasion` indicator row in Panel C.
- Ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory '.codex_tmp\table8_report_check' "Inspector's Effort report.tex"` from `Code Analyse data`.
- The report compile still stops on the pre-existing missing file `Output/inspectors_reg_panels_Full_exec_rate.tex` before reaching the new Table 8 subsection, so report integration was validated by successful `.tex` generation and direct inspection of the inserted LaTeX wrappers rather than full-PDF confirmation.

## Open issues / next steps
- Full PDF validation of `Code Analyse data/Inspector's Effort report.tex` still requires restoring or regenerating the pre-existing missing input `Output/inspectors_reg_panels_Full_exec_rate.tex`.
- If desired, the next check is a side-by-side comparison of the new baseline Table 8 fragment against the legacy `1 regression execution/detection/evasion controls.tex` exports from `2 Regressions main results.do`.

Update: 2026-04-14 (Table 8 baseline correction)
- Switched `Code Analyse data/2 Table 8 full audits replication and yhatrf control.do` to build the baseline from `datasetforanalysis.dta` and then attach `yhatrf` from `fullaudits_predicted.dta` on the verified selected-full-audit row order.
- This correction was necessary because the firm-control variables in `fullaudits_predicted.dta` do not exactly match the legacy Table 8 control values from `datasetforanalysis.dta`, which shifted the original Columns 2 to 5.
- Re-ran `stata-mp /e do "Code Analyse data/2 Table 8 full audits replication and yhatrf control.do"` and confirmed that `Output/table8_fullaudits_replicated.tex` now matches the legacy `1 regression execution controls.tex`, `1 regression detection controls.tex`, and `1 regression evasion controls.tex` backbone for the visible coefficients and summary rows.

---

Date: 2026-05-07
Task: Add restricted-sample versions of the Table 4 and Table 8 predicted-evasion robustness workflows.

## Files edited
- `Code Analyse data/2 Table 4 replication and yhatrf control.do`
- `Code Analyse data/2 Table 8 full audits replication and yhatrf control.do`
- `SESSION_NOTES.md`

## Substantive changes
- Added outer sample-variant loops to the Table 4 and Table 8 workflows so the original full-sample outputs are still regenerated with their existing file names.
- Added restricted-sample exports for `selectionyear` 2018 or 2019, using the suffix `_selectionyear_2018_2019`.
- Added restricted-sample exports for LTU and medium tax centers, implemented as `inlist(groupbureau, 1, 2)` and using the suffix `_ltu_medium`.
- Recomputed the grouped `yhatrf` controls inside each restricted sample so the decile/quintile/bin controls reflect the active estimation sample rather than the unrestricted sample.
- For Table 8, applied each restriction to both the `datasetforanalysis.dta` sample and the `fullaudits_predicted.dta` sample before generating `rowid_table8`, preserving the row-order merge used to attach `yhatrf`.

## Output files affected
- New Table 4 fragments in `Output/` with `_selectionyear_2018_2019` and `_ltu_medium` suffixes, including the `_with_lee` variants and bin-support tables.
- New Table 8 fragments in `Output/` with `_selectionyear_2018_2019` and `_ltu_medium` suffixes, including the bin-support tables.
- Existing full-sample Table 4 and Table 8 outputs are still regenerated under their previous names.

## Validation performed
- Ran `stata-mp /e do "Code Analyse data/2 Table 8 full audits replication and yhatrf control.do"` successfully.
- Confirmed that Table 8 wrote 11 `_selectionyear_2018_2019` fragments and 11 `_ltu_medium` fragments.
- Ran `stata-mp /e do "Code Analyse data/2 Table 4 replication and yhatrf control.do"` successfully.
- Confirmed that Table 4 wrote 21 `_selectionyear_2018_2019` fragments and 21 `_ltu_medium` fragments.
- Checked both Stata log tails and confirmed that each do-file reached `end of do-file`.

## Open issues / next steps
- Interpreted "LTU Medium" as `groupbureau` values 1 and 2, based on the existing summary-statistics legend mapping `1 = LTU` and `2 = MTU/Medium`.

Update: 2026-05-07 (extend restricted samples to recent Table 5 and Table 6 workflows)
- Added the same three-way sample loop to `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do` and `Code Analyse data/6 Table 6 yhatrf control.do`, preserving the original full-sample output names and adding `_selectionyear_2018_2019` and `_ltu_medium` output families.
- For Table 5, the restrictions are applied after the selected full-audit sample is built from `fullaudits_predicted.dta`; duration variables, availability indicators, grouped `yhatrf` bins, and all exported specifications are recomputed inside each active sample.
- For Table 6, the restrictions are applied after the taxpayer-survey sample and SW indices are rebuilt; grouped `yhatrf` bins and both survey/admin-audited panels are recomputed inside each active sample.
- Ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully and confirmed 11 `_selectionyear_2018_2019` fragments and 11 `_ltu_medium` fragments.
- Ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"` successfully and confirmed 11 `_selectionyear_2018_2019` fragments and 11 `_ltu_medium` fragments.
- Together with the earlier Table 4 and Table 8 validation, the recent standalone Table 4, 5, 6, and 8 predicted-evasion workflows now generate the two restricted-sample table families. I did not find a recent standalone Table 7 `yhatrf` workflow in the same table-replication style.

Update: 2026-05-07 (report integration for restricted-sample table families)
- Updated `Code Analyse data/Inspector's Effort report.tex` to add a new restricted-sample predicted-evasion robustness section after the full-sample Table 8 wrappers.
- Added compact LaTeX wrapper macros for the restricted tables and support tables, then included all generated `_selectionyear_2018_2019` and `_ltu_medium` fragments for Tables 4, 5, 6, and 8.
- Included Table 4 `_with_lee` fragments for the restricted samples and the bin-support tables for each table family/sample combination.
- Verified that all newly added restricted-sample `\input{Output/...}` targets exist in `Output/`.
- Attempted `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile" "Inspector's Effort report.tex"` from `Code Analyse data`; compilation still stops before the new section on the pre-existing missing input `Output/inspectors_reg_panels_Full_exec_rate.tex`.

Update: 2026-05-07 (debug Overleaf table imports)
- Added a robust `\OutPath` macro to `Code Analyse data/Inspector's Effort report.tex` and `Code Analyse data/Audit_Discrepancy_Taxpayer_Section.tex` so table and figure imports resolve to `Output/` when compiling from the repository root and to `../Output/` when compiling from `Code Analyse data`.
- Replaced hard-coded `Output/` table and figure imports in those TeX files with `\OutPath`-based paths, fixing the relative-path mismatch that made Overleaf look for `Code Analyse data/Output/...`.
- Added `fontenc` and `lmodern` to the report preamble to avoid bitmap Computer Modern font generation failures in local PDF validation.
- Fixed the Table 6 Stata exporter in `Code Analyse data/6 Table 6 yhatrf control.do`: the baseline Panel B export had drifted into the grouped-control loop, which appended repeated closed tabular blocks to `Output/table6_indices_replicated.tex` and caused a LaTeX `Misplaced \noalign` error at `\midrule`.
- Re-ran `stata-mp /e do "Code Analyse data/6 Table 6 yhatrf control.do"` successfully, regenerating the Table 6 output fragments, including a clean `Output/table6_indices_replicated.tex`.
- Verified no direct `\input{Output/...}` or `\includegraphics{Output/...}` imports remain in `Code Analyse data/*.tex` outside the `\OutPath` existence checks.
- Validated `Code Analyse data/Inspector's Effort report.tex` with `pdflatex -interaction=nonstopmode -halt-on-error` from both `Code Analyse data` and the repository root; both runs completed and produced 189-page PDFs.
- Remaining LaTeX messages are nonfatal warnings: overfull boxes, included PDFs with version 1.6 while the output PDF target is 1.5, and standard rerun-for-cross-reference warnings.

Update: 2026-05-07 (trim restricted-sample report tables to decile specifications)
- Revised `Code Analyse data/Inspector's Effort report.tex` after clarifying that the restricted-sample versions should be added only for the decile-control specifications.
- The restricted-sample section now contains two tables for each of Tables 4, 5, 6, and 8: one restricted to `selectionyear` 2018 or 2019, and one restricted to LTU and medium tax centers (`inlist(groupbureau, 1, 2)`).
- Removed the restricted-sample baseline, linear `yhatrf`, quadratic `yhatrf`, quintile, 15-bin, 20-bin, 40-bin, 50-bin, top-split, and bin-support table imports from the report.
- Left the underlying generated output fragments in `Output/` in place; the report now imports only the restricted decile-control fragments.
- Validated with `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data/Inspector's Effort report.tex"` from the repository root; compilation succeeded and produced a 139-page PDF.
- Remaining LaTeX messages are nonfatal warnings, including pre-existing duplicate labels, overfull boxes, PDF inclusion version warnings, and rerun-for-reference notices.

Update: 2026-05-07 (Table 5 N inspectors residual diagnostic)
- Added a full-sample Table 5 diagnostic block to `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do` for Column 1 (`y16`, number of agents).
- The diagnostic matches the `yhatrf` decile-control specification: it defines the Column 1 estimation sample with `algorithm overlap random safeties ib1.yhatrf_decile` and `inspectorclusteryear` fixed effects, then residualizes `y16` on all non-algorithm controls and the same fixed effects.
- Exported two new kernel-density PDFs: `Output/table5_ninspectors_residual_yhatrf_deciles_kdensity.pdf` and `Output/table5_ninspectors_raw_kdensity.pdf`.
- The residualized plot compares algorithm and inspector cases after controlling for overlap, random, safeties, `yhatrf` deciles, and inspector-year fixed effects; the raw plot compares the unadjusted `y16` distribution with no controls on the selected full-audit, non-safety sample.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully and confirmed both new kernel-density PDFs were written. The earlier non-`kdensity` filenames were not refreshed because Acrobat had the existing PDFs locked during validation.

Update: 2026-05-08 (Table 5 N inspectors legend placement)
- Revised the Table 5 N-inspectors diagnostic figures so the algorithm/inspector legend is placed inside the plot region at the upper right, with smaller legend text and a transparent legend region.
- Refreshed the canonical kernel-density outputs after closing the locked PDF viewer: `Output/table5_ninspectors_residual_yhatrf_deciles_kdensity.pdf` and `Output/table5_ninspectors_raw_kdensity.pdf`.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully and confirmed both `*_kdensity.pdf` files were overwritten.

Update: 2026-05-08 (Table 5 N inspectors plot cleanup)
- Restricted the raw N-inspectors kernel density to executed selected full audits (`y2 == 1`) with nonmissing `y16`, still with no controls.
- Removed visible titles from both the residualized and raw N-inspectors diagnostic figures.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully and confirmed `Output/table5_ninspectors_residual_yhatrf_deciles_kdensity.pdf` and `Output/table5_ninspectors_raw_kdensity.pdf` were refreshed.

Update: 2026-05-08 (Table 5 N inspectors density colors)
- Restyled the raw and residualized N-inspectors kernel densities to use solid `eltblue` lines for algorithm cases and orange short-dashed lines for inspector cases.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully and confirmed `Output/table5_ninspectors_residual_yhatrf_deciles_kdensity.pdf` and `Output/table5_ninspectors_raw_kdensity.pdf` were refreshed.

Update: 2026-05-08 (Table 5 original-controls N inspectors residual diagnostic)
- Added a third N-inspectors diagnostic figure to `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`: `Output/table5_ninspectors_residual_original_controls_kdensity.pdf`.
- This plot residualizes `y16` using the original Table 5 Column 1 non-algorithm controls only: overlap, random, safeties, and inspector-year fixed effects, with no predicted-evasion controls.
- The new figure uses the same styling as the other N-inspectors diagnostics: solid `eltblue` for algorithm cases, orange short-dashed for inspector cases, upper-right inside legend, and no title.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"`; Stata successfully wrote `Output/table5_ninspectors_residual_original_controls_kdensity.pdf`, then stopped when trying to overwrite an already-open existing PDF (`Output/table5_ninspectors_residual_yhatrf_deciles_kdensity.pdf`). Acrobat Reader was still running, so the remaining exports need a rerun after closing the PDF viewer.

Update: 2026-05-08 (Table 5 2018/2019 N inspectors residual diagnostic)
- Added a fourth N-inspectors diagnostic figure to `Code Analyse data/2 Table 5 full audits replication and yhatrf control.do`: `Output/table5_ninspectors_residual_yhatrf_deciles_selectionyear_2018_2019_kdensity.pdf`.
- This plot uses the existing `selectionyear` 2018 or 2019 sample variant and residualizes `y16` with all non-algorithm controls from the decile specification: overlap, random, safeties, `yhatrf` deciles recomputed within the 2018/2019 sample, and inspector-year fixed effects.
- Made diagnostic graph exports tolerant to open-PDF locks: if Stata cannot overwrite one diagnostic PDF, it now prints a warning and continues with the rest of the Table 5 workflow.
- Validation: ran `stata-mp /e do "Code Analyse data/2 Table 5 full audits replication and yhatrf control.do"` successfully through `end of do-file`; confirmed the new 2018/2019 residual PDF was written. Existing full-sample diagnostic PDFs were open in Acrobat and therefore skipped with warnings during this validation run.

Update: 2026-05-07 (move restricted decile tables next to sibling specifications)
- Moved the eight restricted-sample decile-control table imports out of their standalone section in `Code Analyse data/Inspector's Effort report.tex`.
- Inserted the two restricted decile tables immediately after the corresponding full-sample decile-control sibling for each Table 4, 5, 6, and 8 section.
- Kept the shared restricted-table wrapper and notes near the Table 4 robustness notes so all moved imports are defined before use.
- Removed the now-empty standalone restricted-sample section before the inspector-effort analysis.
- Validated with two passes of `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data/Inspector's Effort report.tex"` from the repository root; compilation succeeded and produced a 137-page PDF.
- Remaining LaTeX messages are nonfatal and pre-existing in this report, primarily duplicate labels, overfull boxes, and PDF inclusion version warnings.

Update: 2026-05-07 (add filtered 40-bin and 50-bin tables to report)
- Updated `Code Analyse data/Inspector's Effort report.tex` to include the already-generated restricted-sample 40-bin and 50-bin predicted-evasion control fragments for Tables 4, 5, 6, and 8.
- Added 16 restricted table imports total: selection years 2018/2019 and LTU/Medium samples for each 40-bin and 50-bin specification.
- Inserted each restricted table immediately after its corresponding full-sample 40-bin or 50-bin sibling, keeping the restricted variants inside the relevant Table 4, 5, 6, and 8 report sections.
- Added shared restricted-bin note macros so the new table notes refer to 40 or 50 predicted-evasion bins rather than decile controls.
- Confirmed all 16 referenced output fragments already existed in `Output/`; no Stata do-file changes or regenerated outputs were needed for this request.
- Validated with two passes of `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data/Inspector's Effort report.tex"` from the repository root; compilation succeeded and produced a 148-page PDF.
- Remaining LaTeX messages are nonfatal and consistent with prior validation, including duplicate-label warnings, overfull boxes, PDF inclusion version warnings, and MiKTeX local log/update notices.

Update: 2026-05-08 (Table 4 full-audits coefficient summary CSV)
- Created `Output/table4_full_audits_summary.csv` as a standalone summary output; no Stata workflow or LaTeX report code was changed.
- Parsed the existing `Output/table4_main_outcomes_*.tex` main-table fragments, excluding `_with_lee` duplicates and bin-support fragments, and kept only the full-audits columns: P(Execution), P(Detection | Execution), and log(Evasion) | Detection.
- The CSV records a compact table abbreviation, full specification label, sample label, outcome, full-audits column number, Algorithm coefficient, significance stars, standard error, N, and source TeX file.
- Validation: confirmed the CSV has 91 lines total, including 90 data rows from 30 distinct Table 4 specification/sample fragments times three full-audit outcome columns; inspected the first and last rows for expected labels and coefficients.

Update: 2026-05-08 (add R2 to Table 4 full-audits summary CSV)
- Refreshed `Output/table4_full_audits_summary.csv` from the same existing Table 4 TeX fragments and added an `r2` column after `n`.
- Kept the same scope: main Table 4 fragments only, excluding `_with_lee` duplicates and bin-support tables, and retaining only the full-audit outcome columns 1, 4, and 7.
- Validation: confirmed the refreshed CSV still has 91 lines total, including 90 data rows, and inspected the header plus first and last rows to verify populated `r2` values.

Update: 2026-05-08 (Table 5, 6, and 8 summary CSVs)
- Created three standalone summary outputs from existing TeX fragments; no Stata workflow or LaTeX report code was changed:
  - `Output/table5_fullaudits_summary.csv`
  - `Output/table6_full_audits_summary.csv`
  - `Output/table8_fullaudits_summary.csv`
- Table 5 summary keeps all eight full-audit outcome columns for each main specification/sample fragment, excluding bin-support tables.
- Table 6 summary keeps the full-audit columns only: Efficiency Index and Corruption Index in both Panel A and Panel B, excluding bin-support tables.
- Table 8 summary keeps the final model column for each outcome and specification/sample fragment: column 5 for baseline replicated tables and column 6 for predicted-evasion robustness tables, avoiding repeated baseline-control columns in every robustness file.
- Each CSV records compact table abbreviation, specification, sample, outcome context, Algorithm coefficient, significance stars, standard error, N, R2, and source TeX file.
- Validation: confirmed line counts of 241, 121, and 91 respectively, corresponding to 240 Table 5 data rows, 120 Table 6 data rows, and 90 Table 8 data rows; inspected headers and representative first rows for expected labels and values.

Update: 2026-05-11 (inspector-effort report bin-table cleanup)
- Created and pushed checkpoint commit `0134631` (`Checkpoint predicted-evasion robustness outputs`) on branch `inspector_effort` before changing the report cleanup.
- Revised `Code Analyse data/Inspector's Effort report.tex` to withdraw the 20-bin, 40-bin, and 50-bin predicted-evasion robustness table blocks for Tables 4, 5, 6, and 8.
- Removed the restricted-sample 40-bin and 50-bin table imports for Tables 4, 5, 6, and 8, along with the now-unused restricted-bin note macros.
- Kept the 15-bin, decile, quintile, quadratic, top-split, and bin-support tables in the report.
- Left all generated `Output/` fragments and PDFs in place for traceability; no Stata generation logic or output files were deleted.
- Validation: confirmed with targeted `rg` searches that the report no longer imports or labels Table 4/5/6/8 `20bins`, `40bins`, or `50bins` variants, while retained robustness imports remain present.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully from the repository root; it produced a 127-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX local log/update notices.

Update: 2026-05-12 (Table 4 Column 1 consolidated table list-level controls)
- Revised `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` to drop the predicted-evasion control specifications based on detailed tax office only, selection year only, and their additive combination.
- Kept the true list-level specifications based on detailed tax office by selection year, including list-specific predicted-evasion slopes, list-specific rank slopes, decile-by-list fixed effects, and top-split-decile-by-list fixed effects.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex`; the table now has 13 columns rather than 16 and no longer contains the rows for `Deciles x Bureau detailed only`, `Deciles x Selection year only`, or `Deciles x Bureau detailed and selection year`.
- Updated the corresponding note in `Code Analyse data/Inspector's Effort report.tex` so the column descriptions match the revised 13-column table and state that the dropped additive bureau/year specifications are omitted.
- Validation: ran `stata-mp /e do "Code Analyse data\2 Table 4 column 1 predicted evasion controls.do"` successfully through `end of do-file`.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 131-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX local log/update notices.

Update: 2026-05-12 (Table 4 Column 1 optimization-weighted yhatrf version)
- Revised `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` to run the consolidated Column 1 specifications twice: once with the current `fullaudits_predicted.dta` / `deskaudits_predicted.dta` inputs, and once with the optimization-exercise weighted RF inputs `audits_predicted_2.dta` / `audits_predicted_1.dta`.
- Added optimization-weighted outputs `Output/table4_col1_predicted_evasion_control_comparison_optimization_weighted.tex` and `Output/table4_col1_predicted_evasion_bin_support_optimization_weighted.tex`; the original output filenames are unchanged.
- Added the optimization-weighted consolidated estimate table to `Code Analyse data/Inspector's Effort report.tex` immediately after the current Table 4 Column 1 consolidated comparison.
- Validation: ran `stata-mp /e do "Code Analyse data\2 Table 4 column 1 predicted evasion controls.do"` successfully through `end of do-file`; confirmed the new optimization-weighted TeX fragments were written.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` twice successfully; it produced a 131-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX local log/update notices.

Update: 2026-05-12 (optimization-weighted Table 4 Column 1 table note)
- Expanded the table note for the optimization-weighted consolidated Table 4 Column 1 comparison in `Code Analyse data/Inspector's Effort report.tex`.
- The note now stands alone, matching the structure of the current-yhatrf comparison note while clarifying that Column 1 keeps the original no-yhatrf specification and Columns 2--16 replace only the predicted-evasion measure with the optimization-weighted RF prediction.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 131-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX local log/update notices.

Update: 2026-05-12 (Table 5 Panel A1 Column 1 consolidated predicted-evasion controls)
- Added `Code Analyse data/2 Table 5 column 1 predicted evasion controls.do`, a standalone Stata workflow for Table 5 Panel A1 Column 1 (`y16`, Number of Agents).
- The new workflow re-estimates the original selected non-safety full-audit Column 1 specification across 16 predicted-evasion control variants, using the current RF prediction from `fullaudits_predicted.dta` and the optimization-weighted RF prediction from `audits_predicted_2.dta`.
- Added four output fragments: `Output/table5_col1_ninspectors_predicted_evasion_control_comparison.tex`, `Output/table5_col1_ninspectors_predicted_evasion_control_comparison_optimization_weighted.tex`, `Output/table5_col1_ninspectors_predicted_evasion_bin_support.tex`, and `Output/table5_col1_ninspectors_predicted_evasion_bin_support_optimization_weighted.tex`.
- Added the two consolidated estimate tables to `Code Analyse data/Inspector's Effort report.tex` at the start of the existing Table 5 predicted-evasion controls section, with notes clarifying that the weighted version changes the RF prediction source and does not use regression weights.
- Validation: ran `stata-mp /e do "Code Analyse data\2 Table 5 column 1 predicted evasion controls.do"` successfully through `end of do-file`; confirmed all four TeX fragments were written and the two estimate tables contain populated coefficient, `N`, `R2`, and mean-outcome rows.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully after rerunning with filesystem escalation for MiKTeX user-log access; it produced a 135-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including multiply-defined labels, overfull boxes, PDF inclusion version warnings, and the MiKTeX update notice.
- Open note: the highest-flexibility stratum-specific slope specifications report missing robust standard errors for some displayed coefficients, but Stata completed the models and populated the requested fit rows.

Update: 2026-05-12 (optimization-weighted Figure 4 panels)
- Added `Code Analyse data/6 Figure 4 weighted yhatrf panels.do`, a standalone Stata generator for the two Figure 4-style full-audit panels using the optimization-weighted RF prediction from `audits_predicted_2.dta` as `yhatrf`.
- Exported `Output/figure4_panel_a_weighted_yhatrf_fullaudits.pdf` and `Output/figure4_panel_b_weighted_yhatrf_fullaudits.pdf`. Panel A reproduces the predicted-evasion, detected-evasion, and execution-rate display; Panel B reproduces the algorithm-versus-inspector distribution and execution-rate display.
- Added both PDFs as separate figure blocks in Section 2 of `Code Analyse data/Inspector's Effort report.tex`, with notes clarifying that the horizontal axis and predicted-evasion distributions use the weighted `yhatrf` while detected evasion remains realized detected evasion among executed audits.
- Validation: ran `stata-mp /e do "Code Analyse data\6 Figure 4 weighted yhatrf panels.do"` successfully through `end of do-file` and confirmed both PDFs were written to `Output/`.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 134-page PDF. Remaining warnings were nonfatal and consistent with prior report builds, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX update notices.

Update: 2026-05-12 (Figure 4 weighted panels rendering fix)
- Diagnosed why the first Stata-generated Figure 4 PDFs showed only execution-rate lines: the binned distribution and confidence-interval variables were populated, but Stata PDF exports using filled `area`/`rarea` layers with transparency did not render the filled polygons reliably after PDF export/inclusion.
- Revised `Code Analyse data/6 Figure 4 weighted yhatrf panels.do` to match the original Figure 4 style more closely: the distributions are shaded `area` layers and the confidence intervals are shaded `rarea` bands, using Stata `color()` plus `fintensity()` fill settings that render reliably in the exported PDFs.
- Regenerated `Output/figure4_panel_a_weighted_yhatrf_fullaudits.pdf` and `Output/figure4_panel_b_weighted_yhatrf_fullaudits.pdf`.
- Validation: ran `stata-mp /e do "Code Analyse data\6 Figure 4 weighted yhatrf panels.do"` successfully through `end of do-file`; rendered PDF previews confirmed the shaded distributions and shaded confidence intervals are visible.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 134-page PDF with the updated figures. Remaining warnings were nonfatal and consistent with prior report builds.

Update: 2026-05-12 (Figure 4 weighted panels manuscript-style notes)
- Revised the two Figure 4 weighted-panel notes in `Code Analyse data/Inspector's Effort report.tex` to follow the manuscript Figure 4 wording while describing the prediction as optimization-weighted predicted evasion in plain research terms.
- Removed dataset and variable names from the figure notes and aligned the color references with the plotted Stata/R-style layers.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 134-page PDF. Remaining warnings were nonfatal and consistent with prior report builds.

Update: 2026-05-12 (Table 5 Column 1 list wording cleanup)
- Revised `Code Analyse data/2 Table 5 column 1 predicted evasion controls.do` so the consolidated Table 5 Column 1 output labels use "List" rather than "FE stratum" for list-specific predicted-evasion controls.
- Refreshed the four `Output/table5_col1_ninspectors_predicted_evasion_*` TeX fragments; the estimate tables now show rows such as `Linear predicted evasion x List`, and the bin-support tables use `Lists` as the count header.
- Updated the two new consolidated Table 5 Column 1 notes in `Code Analyse data/Inspector's Effort report.tex` to describe lists as the inspector-cluster by year groups and to use list/bin-by-list wording.
- Validation: reran `stata-mp /e do "Code Analyse data\2 Table 5 column 1 predicted evasion controls.do"` successfully through `end of do-file`.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully with filesystem escalation for MiKTeX user-log access; it produced a 134-page PDF. Remaining warnings were nonfatal and consistent with prior report builds.

Update: 2026-05-12 (Figure 4 weighted panels lighter distribution fills)
- Revised `Code Analyse data/6 Figure 4 weighted yhatrf panels.do` so the Figure 4 weighted-panel distribution areas and confidence bands render with lighter visual weight.
- Removed outline strokes from the filled distribution and confidence-band layers using `lcolor(none)`, keeping the execution-rate lines as the main visual guide.
- Reduced the Panel B distribution fill intensities from the prior stronger maroon/orange fills to lighter `fintensity()` values.
- Regenerated `Output/figure4_panel_a_weighted_yhatrf_fullaudits.pdf` and `Output/figure4_panel_b_weighted_yhatrf_fullaudits.pdf`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 weighted yhatrf panels.do"` successfully through `end of do-file` after closing the previously open PDF; both canonical PDFs were refreshed in `Output/`.

Update: 2026-05-12 (Figure 4 weighted panels visible light fills)
- Revised `Code Analyse data/6 Figure 4 weighted yhatrf panels.do` again after the no-outline version made the filled distribution and confidence-band areas disappear in the exported PDFs.
- Restored very thin outline strokes using `lwidth(vvthin)` and raised the `fintensity()` values enough for the shaded areas to remain visible while still lighter than the original bold fills.
- Regenerated `Output/figure4_panel_a_weighted_yhatrf_fullaudits.pdf` and `Output/figure4_panel_b_weighted_yhatrf_fullaudits.pdf`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 weighted yhatrf panels.do"` successfully through `end of do-file`; the refreshed PDFs returned to the larger filled-layer file sizes, indicating the shaded distribution and CI layers are included.

Update: 2026-05-12 (Figure 4 weighted panels cropped above log evasion 15)
- Revised `Code Analyse data/6 Figure 4 weighted yhatrf panels.do` to export an additional cropped version of each weighted-yhatrf Figure 4 panel using only plotted bins with `mid_bin > 15`.
- Added `Output/figure4_panel_a_weighted_yhatrf_fullaudits_cropped_gt15.pdf` and `Output/figure4_panel_b_weighted_yhatrf_fullaudits_cropped_gt15.pdf`.
- Kept the original full-range output filenames unchanged; added a visible warning around the pre-existing Panel B full-range export so a locked/open PDF does not prevent the new cropped Panel B export.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 weighted yhatrf panels.do"` successfully through `end of do-file`; both cropped PDFs were written. The existing Panel B full-range PDF was not refreshed during this run because Stata could not replace the locked/open file.

Update: 2026-05-13 (Table 4 Column 1 additional list-specific predicted-evasion controls)
- Revised `Code Analyse data/2 Table 4 column 1 predicted evasion controls.do` to add two consolidated Table 4 Column 1 specifications for both current RF and optimization-weighted RF predictions.
- Added a squared within-list predicted-evasion rank and a new list-specific quadratic rank specification, using within-list rank and rank squared interacted with the full-audit list.
- Added a non-LTU list-specific quadratic predicted-evasion specification, defined as `inlist(groupbureau, 2, 3, 4)` so it excludes only LTU and keeps Medium, Liberal, and SME offices.
- Expanded the consolidated comparison exports from 16 to 18 columns and added table rows for `Quadratic rank polynomial x List` and `Quadratic predicted evasion x List, non-LTU`.
- Regenerated `Output/table4_col1_predicted_evasion_control_comparison.tex` and `Output/table4_col1_predicted_evasion_control_comparison_optimization_weighted.tex`; the unchanged bin-support section of the do-file also rewrote the existing bin-support fragments without adding new bin definitions.
- Updated the two corresponding notes in `Code Analyse data/Inspector's Effort report.tex` to describe Columns 17 and 18 and the non-LTU definition.
- Validation: reran `stata-mp /e do "Code Analyse data\2 Table 4 column 1 predicted evasion controls.do"` successfully through `end of do-file`.
- Validation: confirmed both consolidated output tables use 18-column headers, show the two new control rows, and report `N = 548` for the new non-LTU Column 18 versus `N = 944` for the full-sample list-quadratic Column 17.

Update: 2026-05-13 (weighted vs unweighted yhatrf scatterplots)
- Added `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do`, a standalone Stata workflow comparing current and optimization-weighted RF predicted evasion scores.
- The do-file merges current and weighted predictions by `firmid selectionyear x2 inspectorclusteryear sequencing`, checks the key with `isid`, asserts all merge results are matched, and exports separate full-audit and desk-audit scatterplots with OLS `lfit` lines.
- Added `Output/yhatrf_weighted_vs_unweighted_fullaudits.pdf` and `Output/yhatrf_weighted_vs_unweighted_deskaudits.pdf`; each graph includes the fitted formula in the lower-left plotting area.
- Validation: ran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`. Merge diagnostics were clean, with 944 full-audit matches and 2,731 desk-audit matches and no unmatched rows.
- Validation: extracted text from both PDFs with `pdftotext` and confirmed the formulas render in the exported files: `Weighted = 1.15 + 1.06*Unweighted` for full audits and `Weighted = -0.65 + 1.21*Unweighted` for desk audits.

Update: 2026-05-13 (executed-only weighted vs unweighted yhatrf scatterplots)
- Revised `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do` to make the selected non-safety sample restrictions explicit before plotting: `selection == 1`, drop `safeties == 1`, keep the expected full-audit or desk-audit control type, and drop missing current or weighted predictions.
- Kept the original selected-sample output filenames and added executed-only companion figures: `Output/yhatrf_weighted_vs_unweighted_fullaudits_executed.pdf` and `Output/yhatrf_weighted_vs_unweighted_deskaudits_executed.pdf`.
- Added graph subtitles distinguishing `Selected non-safety sample` from `Executed cases only`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`. The selected samples remained 944 full-audit cases and 2,731 desk-audit cases; the executed-only samples were 508 full-audit cases and 1,011 desk-audit cases.
- Validation: extracted text from all four PDFs with `pdftotext` and confirmed the formula text renders. The executed-only formulas are `Weighted = -9.40 + 1.59*Unweighted` for full audits and `Weighted = -5.20 + 1.43*Unweighted` for desk audits.

Update: 2026-05-13 (weighted-vs-unweighted scatterplot subtitle cleanup and negative check)
- Revised `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do` so the whole selected-sample figures use the subtitle `Selected sample` rather than `Selected non-safety sample`.
- Regenerated the four weighted-vs-unweighted scatterplot PDFs in `Output/`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`; the log now reports `Selected sample` for the whole selected-sample runs.
- Validation: extracted text from the selected-sample PDFs with `pdftotext` and confirmed the updated subtitle is rendered.
- Validation: checked both current and top-quartile-weighted `yhatrf` values in the merged graph samples. There are no negative values in either prediction: full selected minimums are 3.352910 and 0.000000, full executed minimums are 3.352910 and 0.000000, desk selected minimums are 1.238989 and 0.000000, and desk executed minimums are 1.238989 and 0.000000.

Update: 2026-05-13 (weighted-vs-unweighted scatterplot selected-cases wording and zero axes)
- Revised `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do` so the whole selected-sample figures use the subtitle `Selected cases`.
- Cropped all weighted-vs-unweighted scatterplots so both axes start at zero. Because the executed-only OLS fitted line implied negative fitted values near the left edge, the do-file now computes the same OLS fitted line after the regression and omits only fitted-line segments below zero; the coefficient formula remains based on the full regression sample.
- Regenerated `Output/yhatrf_weighted_vs_unweighted_fullaudits.pdf`, `Output/yhatrf_weighted_vs_unweighted_fullaudits_executed.pdf`, `Output/yhatrf_weighted_vs_unweighted_deskaudits.pdf`, and `Output/yhatrf_weighted_vs_unweighted_deskaudits_executed.pdf`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`.
- Validation: extracted text from all four PDFs with `pdftotext`; selected-case figures render `Selected cases`, and executed-only figures no longer display negative y-axis ticks.

Update: 2026-05-13 (weighted-vs-unweighted scatterplot equivalence line and matched axes)
- Revised `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do` to add a light gray dotted `y = x` equivalence line starting at zero to each weighted-vs-unweighted scatterplot.
- Updated the graph code so each figure computes a common maximum across current and top-quartile-weighted predictions, rounds it up to the next 5-unit tick, and applies the same 0-based range and tick marks to both axes.
- Added a square plotting aspect and updated the legend to include `Equivalence` alongside `Cases` and `OLS fit`.
- Regenerated the four weighted-vs-unweighted PDFs in `Output/`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`.
- Validation: extracted text from all four PDFs with `pdftotext` and confirmed the matched 0, 5, 10, 15, 20, 25 tick sequence and the `Equivalence` legend entry render in each file.

Update: 2026-05-13 (add weighted-vs-unweighted prediction scatterplots to report)
- Added a four-panel figure to `Code Analyse data/Inspector's Effort report.tex` importing the full-audit and desk-audit weighted-vs-unweighted prediction scatterplots for selected cases and executed cases.
- Added paper-facing figure notes describing the baseline and top-quartile-weighted random-forest predictions, the selected and executed samples, the 45-degree equivalence line, and the unweighted linear fits without using dataset variable names.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` twice successfully; the report compiled to a 138-page PDF and included all four weighted-vs-unweighted scatterplot PDFs.
- Remaining LaTeX messages were nonfatal and consistent with the existing report, including duplicate labels, overfull boxes, PDF inclusion version warnings, and MiKTeX update notices.

Update: 2026-05-13 (weighted-vs-unweighted scatterplot do-file refactor)
- Refactored `Code Analyse data/6 Compare weighted and unweighted yhatrf scatterplots.do` so it first appends the current full- and desk-audit prediction files, appends the weighted full- and desk-audit prediction files, merges the two prediction sources once, and only then starts the plotting loops.
- Simplified the control flow by removing repeated per-audit-type dataset loading and variable-confirmation blocks, while preserving key checks through `isid` and `assert _merge == 3`.
- Added clearer numbered comments for loading current predictions, loading weighted predictions, merging, applying the graph sample, looping over audit type and sample, estimating the comparison line, and exporting graphs.
- Regenerated the four weighted-vs-unweighted PDFs in `Output/`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Compare weighted and unweighted yhatrf scatterplots.do"` successfully through `end of do-file`; sample counts and regression coefficients match the pre-refactor outputs.
- Validation: extracted text from `Output/yhatrf_weighted_vs_unweighted_fullaudits.pdf` with `pdftotext` and confirmed the selected-case subtitle, matched ticks, and `Equivalence` legend entry remain rendered.

Update: 2026-05-13 (revision of optimization gains table)
- Added `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R`, a standalone R script that recreates the optimization-gains table with unweighted random forest predicted evasion and appends aggregate realized and predicted revenue columns excluding the five largest firms within each audit type.
- Connected the new revision script to `Code Analyse data/Replication R/00_Main.R` with an absolute source path, since `00_Main.R` changes the working directory to the Dropbox replication package before sourcing the numbered R scripts.
- Added Section 3, `Revision of optimization gains`, to `Code Analyse data/Inspector's Effort report.tex`, including the new table, near-original table notes updated for the unweighted prediction and two aggregate columns, and a short bullet note explaining the table construction, aggregate calculations, revenue-gain formula, and overlap formula.
- Generated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`. The new table has six columns and reports Full Audits and Desk Audits rows.
- Validation: ran `Rscript --vanilla "C:/Users/wb648862/Documents/Projects/Senegal Tax Audits/Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R"` from the Dropbox replication package working directory. The script completed successfully and wrote the new TeX fragment.
- Validation: confirmed `randomForest` loads from the replication package local R library without activating `renv`, confirmed the new script parses, and inspected the generated TeX fragment for the expected two rows and six columns.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 136-page PDF. Remaining warnings were nonfatal and consistent with the existing report build, including multiply-defined labels, overfull boxes, PDF inclusion version warnings, and a MiKTeX update notice.

Update: 2026-05-13 (optimization gains top-five columns corrected)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so Columns 5 and 6 now replicate the current revenue-gain and overlap columns after dropping the five largest predicted-revenue firms, rather than reporting aggregate revenue totals.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`. The corrected Column 5 reports top-five-excluded revenue gains and Column 6 reports top-five-excluded optimized-program overlap.
- Updated the Section 3 notes and construction bullets in `Code Analyse data/Inspector's Effort report.tex` to describe Columns 5 and 6 as top-five-excluded versions of Columns 3 and 4.
- Validation: reran the standalone R revision script successfully and inspected the generated TeX fragment. The corrected table reports Column 5 as `+ 24.07%` for full audits and `+ 41.42%` for desk audits, and Column 6 as `65%` for full audits and `62%` for desk audits.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 136-page PDF with only the existing nonfatal report warnings.

Update: 2026-05-13 (optimization gains current-table replication)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so Columns 1--4 are taken from the current saved Table 9 fragment, ensuring they exactly reproduce the current table, while Columns 5--6 remain newly computed from the unweighted top-five-excluded exercise.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`; Columns 1--4 now match the snapshot/current table exactly: Full Audits `21.24`, `21.14`, `+ 18.09%`, `65%`; Desk Audits `19.00`, `18.73`, `+ 31.01%`, `61%`.
- Updated the Section 3 caption and notes in `Code Analyse data/Inspector's Effort report.tex` to state that Columns 1--4 reproduce the current table and Columns 5--6 use the unweighted top-five-excluded exercise.
- Validation: reran the standalone R revision script successfully and inspected the generated TeX fragment.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 136-page PDF with only existing nonfatal report warnings.

Update: 2026-05-13 (optimization gains recomputation diagnosis)
- Diagnosed the remaining discrepancy in the recomputed Desk Audits revenue-gain column: the first random forest in the original optimization script uses the predictor order `activity group`, `tax office`, then `audit algorithm`, while the revision script had reused the revenue-model order. With a fixed seed, `randomForest` is still sensitive to this order because candidate variables are sampled by position.
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` to use separate predictor lists for the detection model and the revenue model, matching the original `07_Optimization_Exercise.R`, and removed the saved-table fallback for Columns 1--4.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex` from the R workflow. Columns 1--4 now reproduce the current Table 9 values by recomputation: Full Audits `21.24`, `21.14`, `+ 18.09%`, `65%`; Desk Audits `19.00`, `18.73`, `+ 31.01%`, `61%`.
- The final top-five-excluded unweighted columns report Column 5 as `+ 24.07%` for full audits and `+ 41.56%` for desk audits, and Column 6 as `65%` for full audits and `62%` for desk audits.
- Validation: reran the standalone R revision script from the Dropbox replication package working directory successfully, inspected the six-column TeX fragment, and reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully with only existing nonfatal report warnings.

Update: 2026-05-13 (optimization gains top realized outlier exclusion)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so Columns 5--6 train the unweighted random forest on the full audited sample, then exclude the five actually audited records with the largest realized revenue within each audit type before re-running the unweighted ranking and optimized selection.
- The top-five exclusion is now applied before optimization for Columns 5--6 only; optimized counts are recomputed after the exclusion within each tax-office-by-year list so the optimized program matches the remaining realized audit implementation.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`. Columns 1--4 remain unchanged and match current Table 9; the new top-realized-outlier columns report Column 5 as `+ 23.10%` for full audits and `+ 41.04%` for desk audits, and Column 6 as `65%` for full audits and `62%` for desk audits.
- Updated `Code Analyse data/Inspector's Effort report.tex` table notes and construction bullets to describe the unweighted full-sample training, the pre-ranking exclusion of the five largest realized-revenue audited records, the re-ranking step, and the Column 5 and Column 6 formulas.
- Validation: reran the standalone R revision script from the Dropbox replication package working directory successfully. Warnings were limited to packages built under R 4.5.2 while running R 4.5.1.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 138-page PDF. Remaining warnings were nonfatal and consistent with the existing report build, including duplicate labels, overfull boxes, PDF inclusion version warnings, and a MiKTeX update/log notice.

Update: 2026-05-13 (optimization gains construction-note split)
- Revised the construction note under Section 3 in `Code Analyse data/Inspector's Effort report.tex` to separate the table-building steps into `Weighted method, Columns 1--4` and `Unweighted method excluding top realized outliers, Columns 5--6`.
- The weighted bullets now spell out the selected non-safety sample, audited-case training, high-revenue weighting, prediction over all selected program cases, 2018--2019 restriction, within-list ranking, and Columns 1--4 formulas.
- The unweighted bullets now spell out full-sample unweighted training, prediction over all selected program cases, 2018--2019 restriction, top-five realized-revenue audited-case exclusion, recomputation of remaining realized audit counts, within-list re-ranking, and Columns 5--6 formulas.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 139-page PDF with only existing nonfatal report warnings.

Update: 2026-05-13 (optimization gains direct unweighted prediction)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so Columns 5--6 use the direct unweighted predicted-evasion construction used in the prediction plots: a single unweighted revenue random forest trained on actually audited cases with observed realized revenue, with no detection-model gate and no replacement of predicted values with zero.
- Preserved the original two-stage weighted optimization logic for Columns 1--4, including the detection gate and zero replacement needed to reproduce the current Table 9 values.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`. Columns 1--4 remain unchanged; the direct-unweighted, top-realized-outlier columns now report Column 5 as `+ 8.39%` for full audits and `+ 34.49%` for desk audits, and Column 6 as `78%` for full audits and `72%` for desk audits.
- Updated the Section 3 table note and construction bullets in `Code Analyse data/Inspector's Effort report.tex` to state that the unweighted branch does not apply the detection-model gate and does not replace predicted revenue with zero.
- Validation: reran the standalone R revision script from the Dropbox replication package working directory successfully; the log confirms the unweighted branch trains only the unweighted revenue random forest. Warnings were limited to packages built under R 4.5.2 while running R 4.5.1.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 139-page PDF with only existing nonfatal report warnings.

Update: 2026-05-13 (optimization gains header and formula wording)
- Revised the generated table headers in `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so Columns 5--6 explicitly mention unweighted predicted revenue and the top-five realized-firm exclusion.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex`; values were unchanged from the direct-unweighted top-realized-outlier version.
- Revised the Section 3 construction bullets in `Code Analyse data/Inspector's Effort report.tex` so the Column 3--6 formulas use display math with `$$...$$` and `\frac{...}{...}` for the divisions.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; it produced a 139-page PDF with only existing nonfatal report warnings.

Update: 2026-05-14 (full-audit list-rank RF prediction plan and script)
- Added `docs/plans/2026-05-14-001-feat-full-audit-rank-rf-plan.md`, documenting the first implementation unit for a full-audit-only unweighted random forest that predicts realized evasion rank within `bureau_detailed` by `selectionyear`.
- Added `Code Analyse data/Replication R/08_Full_Audit_Rank_RF_Unweighted.R`, a standalone R script that mirrors the direct unweighted `yhatrf` process: selected non-safety full audits, training on executed full audits with observed `y4`, the same RF predictors, no weights, no detection gate, and prediction over all selected non-safety full-audit cases.
- The realized target is `rank_y4_bureauyear = rank(-y4, ties.method = "min")` within each full-audit list, so the largest realized evasion in each `bureau_detailed` by `selectionyear` list receives rank 1, including tied top cases.
- Generated `Working Data/fullaudits_predicted_rank_bureauyear.dta` in the Dropbox replication package working-data folder. The output includes `rank_y4_bureauyear`, `predicted_rank_y4_bureauyear`, `yhatrf_rank_score`, and a rank-specific compatibility variable `yhatrf = -predicted_rank_y4_bureauyear`.
- Validation: ran `Rscript --vanilla "Code Analyse data/Replication R/08_Full_Audit_Rank_RF_Unweighted.R"` from the Dropbox replication package working directory using the installed R 4.5.1 executable. The script trained on 508 executed full-audit observations and wrote predictions for 944 selected non-safety full-audit rows.
- Validation: inspected the generated `.dta` and confirmed all expected variables are present, `predicted_rank_y4_bureauyear` is nonmissing for all 944 rows, `rank_y4_bureauyear` is nonmissing for the 508 training rows, and every bureau-year list assigns rank 1 to the maximum realized `y4`.
- Open issue: the consolidated Column 1 table scripts have not yet been wired to the rank-prediction source; that remains the next implementation unit.

Update: 2026-05-14 (Figure 4 predicted-rank panels and report section)
- Added `Code Analyse data/6 Figure 4 predicted rank panels.do`, a Figure 4-style Stata do-file that reads `Working Data/fullaudits_predicted_rank_bureauyear.dta`, keeps selected non-safety full audits, and uses `predicted_rank_y4_bureauyear` on the x-axis instead of predicted evasion amount.
- The new do-file exports `Output/figure4_panel_a_predicted_rank_fullaudits.pdf` and `Output/figure4_panel_b_predicted_rank_fullaudits.pdf`. Panel A compares predicted-rank distributions for executed and non-executed cases, adds the realized-rank distribution among executed full audits, and overlays execution rates. Panel B compares algorithm-selected and inspector-selected distributions and execution-rate lines by predicted rank.
- Added Section 4, `Predicting rank`, to `Code Analyse data/Inspector's Effort report.tex`, including both new rank figures and notes explaining the full-audit list-level rank target.
- Updated `tasks/2026-05-14-001-feat-full-audit-rank-rf-plan.md` to mark the Figure 4-style rank diagnostics as a completed implementation unit.
- Validation: ran `stata-mp /e do "Code Analyse data\6 Figure 4 predicted rank panels.do"` successfully and confirmed both rank PDFs were regenerated in `Output/`.
- Validation: extracted text from the new PDFs with `pdftotext` and confirmed the x-axis label `Predicted rank (1 = highest evasion)` and the expected legend entries are rendered.
- Validation: ran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` twice successfully; the compiled report is 140 pages and includes the new `Predicting rank` section. Remaining warnings are nonfatal and consistent with the existing report build, including duplicate labels, PDF inclusion version warnings, overfull boxes, and MiKTeX update notices.

Update: 2026-05-14 (predicting-rank construction bullets)
- Added a `Steps used to predict rank` bullet list to Section 4, `Predicting rank`, in `Code Analyse data/Inspector's Effort report.tex`.
- The bullets document the selected non-safety full-audit sample, realized rank construction within detailed tax office by selection year, use of `-y4` so the largest detected evasion receives rank 1, the unweighted random-forest training sample and predictors, prediction over all selected non-safety full-audit cases, and use of direct predicted rank in the Figure 4-style diagnostics.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; the compiled report is 141 pages. Remaining warnings are nonfatal and consistent with the existing report build.

Update: 2026-05-14 (organize task Markdown files)
- Created a root-level `tasks/` folder to keep planning and task documents together.
- Moved `Code Analyse data/Anne_Reflections_To_Dos_2026-04-22.md` to `tasks/Anne_Reflections_To_Dos_2026-04-22.md`.
- Moved `docs/plans/2026-05-14-001-feat-full-audit-rank-rf-plan.md` to `tasks/2026-05-14-001-feat-full-audit-rank-rf-plan.md`.
- Left `Code Analyse data/Inspector_Effort_Discrepancy_Discussion.md` in place because it is analysis documentation rather than a task list.
- Validation: listed `tasks/` and confirmed both task Markdown files are present.

Update: 2026-05-14 (invert predicted-rank plot axis)
- Revised `Code Analyse data/6 Figure 4 predicted rank panels.do` so the Figure 4-style rank panels use `yhatrf_rank_score = -predicted_rank_y4_bureauyear` on the horizontal axis, making the plots increase with predicted evasion priority.
- Updated Section 4, `Predicting rank`, in `Code Analyse data/Inspector's Effort report.tex` so the text, construction bullets, figure captions, and figure notes describe the inverted rank score used for plotting.
- Updated `tasks/2026-05-14-001-feat-full-audit-rank-rf-plan.md` so the completed diagnostics unit reflects the inverted predicted-rank plotting convention.
- Regenerated `Output/figure4_panel_a_predicted_rank_fullaudits.pdf` and `Output/figure4_panel_b_predicted_rank_fullaudits.pdf`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 predicted rank panels.do"` successfully and confirmed both PDFs were regenerated.
- Validation: extracted text from both PDFs with `pdftotext` and confirmed the horizontal axis now reads `Inverted predicted rank score` with the updated execution-rate legend wording.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; the compiled report is 142 pages. Remaining warnings are nonfatal and consistent with the existing report build.

Update: 2026-05-14 (use within-list predicted rank order)
- Revised `Code Analyse data/Replication R/08_Full_Audit_Rank_RF_Unweighted.R` so the random forest still predicts the realized rank target, but the output then re-ranks those predictions within each `bureau_detailed` by `selectionyear` full-audit list.
- The rank prediction output now includes `predicted_rank_order_bureauyear`; `yhatrf_rank_score` and the rank-specific compatibility variable `yhatrf` are now defined as `-predicted_rank_order_bureauyear`, not the negative raw RF-predicted rank value.
- Updated `Code Analyse data/6 Figure 4 predicted rank panels.do` to require the new within-list predicted-rank-order variable and continue plotting the inverted score.
- Updated Section 4, `Predicting rank`, in `Code Analyse data/Inspector's Effort report.tex` and the task plan to describe the extra within-list re-ranking step after prediction.
- Regenerated `Working Data/fullaudits_predicted_rank_bureauyear.dta` in the Dropbox replication package, plus `Output/figure4_panel_a_predicted_rank_fullaudits.pdf` and `Output/figure4_panel_b_predicted_rank_fullaudits.pdf`.
- Validation: reran the R rank-prediction script successfully. Warnings were limited to packages built under R 4.5.2 while running R 4.5.1.
- Validation: reran rank diagnostics and confirmed the realized-rank target assigns rank 1 to the maximum `y4` in every bureau-year list; among executed cases, the inverted within-list predicted-rank score has a positive correlation with realized rank score and with `y4`, and no top-decile realized-evasion cases fall in the bottom quartile of predicted priority.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 predicted rank panels.do"` successfully and confirmed both PDFs were regenerated.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; the compiled report is 142 pages with only the existing nonfatal warnings.

Update: 2026-05-14 (Table 4 Column 1 predicted-rank controls)
- Added `Code Analyse data/2 Table 4 column 1 predicted rank controls.do`, a compact Table 4 Column 1 exporter that keeps the original probability-of-execution specification as Column 1 and adds predicted-rank controls in Columns 2--10.
- The table groups columns by three rank versions: raw within-list predicted rank order, within-list predicted-rank quintile order, and within-list predicted-rank decile order. For the regression controls, rank is not inverted: rank 1, quintile 1, and decile 1 indicate the highest predicted priority, while larger values indicate lower predicted priority.
- Within each group, the three specifications add the rank measure additively, interact the rank measure with the detailed-tax-office-by-selection-year list, and interact a quadratic polynomial in the rank measure with the list.
- Exported `Output/table4_col1_predicted_rank_control_comparison.tex` and `Output/table4_col1_predicted_rank_support.tex`.
- Added both predicted-rank tables to Section 4, `Predicting rank`, in `Code Analyse data/Inspector's Effort report.tex`.
- Validation: ran `stata-mp /e do "Code Analyse data\2 Table 4 column 1 predicted rank controls.do"` successfully. The regression table has 944 observations in all columns, and the support table shows all 29 full-audit strata represented in each quintile and decile.
- Validation: reran the Stata exporter after removing the inverted rank score from the required regression-table inputs; the table continues to use `predicted_rank_order_bureauyear` directly.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully after switching the regression controls to non-inverted rank; the compiled report is 143 pages with only the existing nonfatal warnings.
- Updated the Section 4 `Steps used to predict rank` bullets to distinguish the non-inverted predicted rank order used in the Table 4 Column 1 controls from the minus-one transformation used only for Figure 4-style plotting.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully after the bullet update; the compiled report remains 143 pages with only the existing nonfatal warnings.

Update: 2026-05-14 (cleaner Table 4 Column 1 predicted-rank grid)
- Revised `Code Analyse data/2 Table 4 column 1 predicted rank controls.do` to replace the raw/quintile/decile three-by-three grid with a cleaner within-list predicted-priority grid: original specification, raw predicted rank, raw rank by list, quadratic raw rank by list, rank percentile, rank percentile by list, quadratic rank percentile by list, rank-decile fixed effects, rank-decile-by-list fixed effects, and top-priority indicators.
- Constructed the rank percentile from the non-inverted within-list predicted rank order, with 0 indicating the highest predicted priority and 1 indicating the lowest predicted priority.
- Constructed top 10 percent and top quartile indicators using within-list rank thresholds.
- Implemented the rank-decile-by-list specification as absorbed fixed effects rather than explicit dummy controls so the robust variance matrix remains usable; singleton decile-by-list cells are dropped by `reghdfe`, leaving 912 observations in that column.
- Regenerated `Output/table4_col1_predicted_rank_control_comparison.tex` and `Output/table4_col1_predicted_rank_support.tex`.
- Updated Section 4 of `Code Analyse data/Inspector's Effort report.tex` so the bullets and table notes describe the new grid and the singleton-cell drop in the decile-by-list fixed-effect column.
- Validation: reran `stata-mp /e do "Code Analyse data\2 Table 4 column 1 predicted rank controls.do"` successfully. The regenerated table has 944 observations in all columns except the rank-decile-by-list fixed-effect column, which has 912 after singleton cells are dropped.
- Validation: reran `pdflatex -interaction=nonstopmode -halt-on-error -output-directory ".codex_tmp\report_compile_root" "Code Analyse data\Inspector's Effort report.tex"` successfully; the compiled report remains 143 pages with only existing nonfatal warnings.

Update: 2026-05-20 (Anne 2026-05-19 task breakdown)
- Added `tasks/Anne_To_Dos_2026-05-19.md`, a planning-only task file dissecting Anne's raw comments into workstreams for Figure 4 rank-quantile diagnostics, 2018-2019 restriction verification, panel-based Table 48 optimization revisions, Table G2 top-five reshuffling metrics, and prediction-quality diagnostics.
- No analysis code, table outputs, figures, or manuscript TeX files were changed.
- Validation: confirmed the new task file was added under the existing `tasks/` folder. No Stata/R validation was needed because this was documentation-only planning work.

Update: 2026-05-20 (Table 48 panel optimization revision)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` to generate a four-column panel version of the optimization gains table. Panel A ranks optimized selections by predicted amount; Panel B ranks optimized selections by predicted rank while keeping amount-prediction values for revenue calculations.
- Implemented A1/B1 as the current weighted two-step amount-prediction setup with all cases, A2/B2 as the weighted two-step setup after removing the five largest realized-revenue audited cases within each audit type before training and optimization, and A3/B3 as the one-step unweighted amount-prediction setup after the same exclusion.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex` and added `Output/table_opt_full_and_desk_unweighted_top5_revision_diagnostics.csv`, which records selected, executed, optimized, overlap, and 2020 table-row counts for each scenario and audit type.
- Updated `Code Analyse data/Inspector's Effort report.tex` so the caption, table note, and construction explanation describe the new Panel A/Panel B design, the 2018--2019 restriction, the top-five exclusion timing, and the fact that Panel B uses rank predictions only for optimized selection.
- Validation: ran the revised R script from the Dropbox replication package using the local R 4.4 renv library and wrote outputs to this repo's `Output/` folder. The script reported that A1 reproduces current Table 9 values exactly: full audits `21.24`, `21.14`, `+ 18.09%`, `65%`; desk audits `19.00`, `18.73`, `+ 31.01%`, `61%`.
- Validation: inspected the diagnostics CSV and confirmed every scenario has `rows_2020_in_table = 0`; optimized counts equal executed counts within each scenario and audit type.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` twice with MiKTeX `pdflatex`; the second run produced a 143-page PDF in `.codex_tmp/report_compile_root/` with only the existing nonfatal report warnings, mainly duplicate labels, overfull boxes, and PDF-version inclusion warnings.

Update: 2026-05-20 (group optimization and rank sections)
- Revised `Code Analyse data/Inspector's Effort report.tex` so the optimization-gains revision and predicting-rank material are part of the same top-level section, now titled `Revision of optimization gains and predicting rank`.
- Demoted `Predicting rank` from a separate top-level section to a subsection under the shared optimization/rank section and adjusted the opening sentence from "section" to "subsection".
- Validation: reran MiKTeX `pdflatex` twice after the hierarchy change. The final build produced a 143-page PDF in `.codex_tmp/report_compile_root/`; remaining warnings are the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (Table 48 side-by-side panel layout)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so the Table 48 TeX fragment displays paired A/B scenarios side by side: Panel A keeps realized revenue, predicted revenue, amount-selection gain, and overlap in Columns 1--4; Panel B reports only predicted-rank-selection gain and overlap in Columns 5--6.
- Regenerated `Output/table_opt_full_and_desk_unweighted_top5_revision.tex` with paired A1/B1, A2/B2, and A3/B3 row groups, while leaving the underlying optimization calculations unchanged.
- Updated `Code Analyse data/Inspector's Effort report.tex` table notes and construction bullets to state that Columns 1 and 2 are shared within each A/B scenario pair, and that Panel B revenue gains are valued with the matched Panel A amount-prediction model.
- Validation: reran the R script from the Dropbox replication package and confirmed A1 still reproduces the current Table 9 values exactly for full and desk audits.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` with MiKTeX `pdflatex`; the 143-page PDF in `.codex_tmp/report_compile_root/` includes the new six-column Table 48 layout on page 57. Remaining warnings are the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (deduplicate rank-prediction explanation)
- Removed the duplicated `Steps used to predict rank` block from the `Predicting rank` subsection in `Code Analyse data/Inspector's Effort report.tex`.
- Kept the rank-prediction process documented with the Table 48 construction notes, and replaced the subsection opening with a short pointer back to those notes plus the distinction between non-inverted rank controls and inverted Figure 4-style diagnostics.
- Validation: reran MiKTeX `pdflatex` twice into `.codex_tmp/report_compile_rank_dedup/` because the prior temporary PDF was open and locked. The final build produced a 142-page PDF with only the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (clarify Table 48 case-level unit)
- Revised the Table 48 note and construction bullets in `Code Analyse data/Inspector's Effort report.tex` to clarify that the optimization unit is an audit-program case, not a unique firm.
- Replaced remaining firm-level phrasing in the Table 48 explanation with case-level wording, including the top-five exclusion, realized/predicted revenue means, overlap formula, and recomputed audit-case counts.
- Validation: reran MiKTeX `pdflatex` into `.codex_tmp/report_compile_root/`; the report built successfully as a 142-page PDF with only the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (clarify predicted-rank list construction)
- Revised the Table 48 Panel B construction notes in `Code Analyse data/Inspector's Effort report.tex` to narrate predicted-rank selection as steps.
- Clarified that the realized-rank target is constructed within each detailed tax office by selection year list, with rank 1 assigned to the largest realized-evasion case, and that predicted ranks are sorted again within the same list structure for optimization.
- Validation: reran MiKTeX `pdflatex` into `.codex_tmp/report_compile_root/`; the report built successfully as a 142-page PDF with only the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (clarify optimized count after top-five exclusion)
- Revised the Table 48 note and construction bullets in `Code Analyse data/Inspector's Effort report.tex` to explain that, after top-five exclusion, the optimized selection is rebuilt within each tax-office-by-year list using the remaining realized audit count in that list.
- Validation: reran MiKTeX `pdflatex` into `.codex_tmp/report_compile_root/`; the report built successfully as a 142-page PDF with only the existing nonfatal duplicate-label, overfull-box, and PDF-version inclusion warnings.

Update: 2026-05-20 (Figure 4 rank-percent inputs from 07 optimization script)
- Revised `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R` so the same predicted-rank objects used for B-scenario optimization are exported for Figure 4 diagnostics.
- Added two Dropbox working-data exports: `fullaudits_predicted_rank_bureauyear_07_b1_allcases.dta` for the B1 all-cases rank scenario, and `fullaudits_predicted_rank_bureauyear_07_b2b3_top5excluded.dta` for the shared B2/B3 top-five-excluded rank scenario.
- Reworked `Code Analyse data/6 Figure 4 predicted rank panels.do` to read those two `07` exports and generate both canonical B1/all-cases PDFs and top-five-excluded diagnostic PDFs. The x-axis now uses `100 * (N - rank + 1) / N`, so rank 1 maps to 100 and lower-priority ranks move left according to their list denominator.
- Updated the Figure 4 predicted-rank captions and notes in `Code Analyse data/Inspector's Effort report.tex` to describe the B1 all-cases `07` export and the inverted within-list rank-percentile axis; the top-five-excluded versions are documented as diagnostic outputs not included in the report section.
- Output files affected: `Output/figure4_panel_a_predicted_rank_fullaudits.pdf`, `Output/figure4_panel_b_predicted_rank_fullaudits.pdf`, `Output/figure4_panel_a_predicted_rank_fullaudits_top5excluded.pdf`, and `Output/figure4_panel_b_predicted_rank_fullaudits_top5excluded.pdf`.
- Validation: reran `07_Optimization_Exercise_Unweighted_Top5_Revision.R` with `data_path` pointing to the Dropbox working-data folder and `output_path` pointing to this repo's `Output/`; the script wrote both rank exports and again reported that A1 reproduces current Table 9 values exactly.
- Validation: reran Stata 17 batch mode for `Code Analyse data/6 Figure 4 predicted rank panels.do` successfully. The do-file asserts the top predicted and realized ranks map to 100, and all four Figure 4 predicted-rank PDFs were regenerated.
- Validation: ran an additional Stata spot check on the B1 all-cases export confirming that rank 1 maps to 100 and that two 30-case-list observations with rank 30 map to `100/30`.

Update: 2026-05-21 (Figure 4 predicted-rank decile execution-rate plots)
- Revised `Code Analyse data/6 Figure 4 predicted rank panels.do` to replace the rank-percentile distribution plots with execution-rate plots by within-list predicted-priority decile.
- Constructed predicted-priority deciles within audit type, detailed tax office, and selection year when `controle` is available; decile 10 is the highest predicted priority and decile 1 is the lowest predicted priority.
- Panel A now plots the overall execution rate by predicted-priority decile with a 95 percent confidence band. Panel B now plots algorithm-case and inspector-case execution rates by predicted-priority decile with separate 95 percent confidence bands.
- Removed the predicted-rank and realized-rank distribution layers from the rank version because those distributions are mechanically induced by within-list ranking.
- Updated `Code Analyse data/Inspector's Effort report.tex` so the predicted-rank figure captions and notes describe predicted-priority deciles rather than inverted rank percentiles or rank distributions.
- Output files affected: `Output/figure4_panel_a_predicted_rank_fullaudits.pdf`, `Output/figure4_panel_b_predicted_rank_fullaudits.pdf`, `Output/figure4_panel_a_predicted_rank_fullaudits_top5excluded.pdf`, and `Output/figure4_panel_b_predicted_rank_fullaudits_top5excluded.pdf`.
- Validation: reran Stata 17 batch mode for `Code Analyse data/6 Figure 4 predicted rank panels.do` successfully. The do-file asserts deciles are between 1 and 10, top predicted rank maps to decile 10, and the lowest predicted rank in each multi-case list maps to decile 1; all four PDFs were regenerated with 10 matched deciles in Panel B.

Update: 2026-05-25 (direct high-evasion-bin optimization companion and Codex handoff)
- Added `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md` to record the discussion about predicting high-evasion bins instead of full ranks, including the distinction between post-prediction binning and direct bin-target prediction.
- Added `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R`, a standalone companion script that rebuilds Panel A amount-prediction benchmarks and adds Panel C direct high-evasion-quartile optimized selection.
- The implemented Panel C uses a one-step random forest classifier for high-realized-evasion-quartile membership within audit-type-by-detailed-tax-office-by-selection-year lists. The predicted high-bin probability ranks optimized selections, while revenue gains are valued with the matched Panel A amount-prediction model.
- Regenerated `Output/table_opt_full_and_desk_bin_target_panelc.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`, and `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Updated `Code Analyse data/Inspector's Effort report.tex` to add the `Predicting high-evasion bins` subsection, include the companion table and support table, and explain the quartile support rule and top-five exclusion timing.
- Added `CODEX_HANDOFF.md` as a root-level handoff note for resuming work from another computer.
- Output files affected: the bin-target companion TeX table, diagnostics CSV, support TeX table, and compiled `Code Analyse data/Inspector's Effort report.pdf` plus report auxiliary files.
- Validation: the R companion script was run with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`; it reported that A1 reproduced current Table 9 values exactly for full and desk audits.
- Validation: inspected the generated Panel C companion table, support table, and diagnostics CSV. The diagnostics confirm `rows_2020_in_table = 0` for all scenarios, optimized counts match executed counts, and the quartile support rule leaves no singleton or empty supported bins.
- Validation: compiled the updated Inspector's Effort report and produced the report PDF artifacts now present under `Code Analyse data/`.
- Open issue: decide whether the bin-target companion should remain a separate companion table, be folded into the main Table 48-style optimization table, or be extended with Figure 4-style bin-probability diagnostics.

Update: 2026-06-02 (Figure 4 bin-probability decile diagnostics for Table 49 Panel C)
- Extended `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` to export `Output/figure4_binprob_decile_fullaudits_c1.dta` for C1 selected non-safety full-audit cases. The export includes `bin_high_probability`, Stata-safe `binprob_priority_decile`, list/rank variables, audit identifiers, `y2`, `algorithm`, `dgid`, `selection`, `safeties`, and `controle`.
- Added `Code Analyse data/6 Figure 4 bin probability decile panels.do` to collapse execution rates by predicted high-evasion priority decile and export the Figure 4-style diagnostics for full audits.
- Output files affected: `Output/figure4_panel_a_binprob_decile_fullaudits.pdf`, `Output/figure4_panel_b_binprob_decile_fullaudits.pdf`, `Output/figure4_binprob_decile_fullaudits_support.tex`, and `Output/figure4_binprob_decile_fullaudits_c1.dta`. Rerunning the Panel C script also regenerated the existing Table 49 companion outputs: `Output/table_opt_full_and_desk_bin_target_panelc.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`, and `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Validation: reran `08_Optimization_Exercise_Bin_Target_PanelC.R` with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`; A1 again reproduced the current Table 9 values and the C1 full-audit prediction export was written.
- Validation: reran Stata batch mode for `Code Analyse data/6 Figure 4 bin probability decile panels.do`; both PDF panels and the support table were written successfully. The do-file asserts deciles are in 1--10, rank 1 maps to decile 10, and the lowest-priority case in each multi-case list maps to decile 1.
- Support check: the C1 full-audit export has 944 selected non-safety full-audit cases, all with non-missing `y2`. Decile counts range from 89 to 105 cases overall; algorithm/inspector counts are thinner in some cells, with the smallest algorithm cell at 19 cases in decile 10.
- Report update: inserted the two bin-probability Figure 4 panels into `Code Analyse data/Inspector's Effort report.tex` under the `Predicting high-evasion bins` subsection, immediately before `Predicting rank`.

Update: 2026-06-02 (replace bin-probability Figure 4 deciles with quartiles)
- Replaced the report-facing bin-probability Figure 4 diagnostic with quartile versions. The Stata script is now `Code Analyse data/6 Figure 4 bin probability quartile panels.do`; it groups C1 full-audit cases into predicted high-evasion priority quartiles within `bureau_detailed x selectionyear`, where quartile 4 is highest predicted priority and quartile 1 is lowest.
- Updated `Code Analyse data/Inspector's Effort report.tex` so the `Predicting high-evasion bins` subsection includes the quartile PDFs rather than the decile PDFs.
- Output files affected: `Output/figure4_panel_a_binprob_quartile_fullaudits.pdf`, `Output/figure4_panel_b_binprob_quartile_fullaudits.pdf`, and `Output/figure4_binprob_quartile_fullaudits_support.tex`.
- Validation: reran Stata batch mode for the quartile figure script successfully. The support table reports 246, 231, 227, and 240 selected full-audit cases across quartiles 1--4, and Panel B has all 4 quartiles matched between algorithm and inspector cases.

Update: 2026-06-02 (fixed-width bin-probability Figure 4 diagnostic)
- Added `Code Analyse data/6 Figure 4 bin probability fixed005 panels.do`, a fixed-bin Figure 4-style diagnostic that uses the C1 predicted probability of top-realized-quartile membership instead of predicted evasion amounts.
- The script bins `bin_high_probability` into 0.05-wide probability intervals over 0--1 and plots original Figure 4-style distribution areas plus execution-rate lines for selected non-safety full audits.
- Added the two fixed-width panels to `Code Analyse data/Inspector's Effort report.tex` under `Predicting high-evasion bins`, after the quartile diagnostic.
- Output files affected: `Output/figure4_panel_a_binprob_fixed005_fullaudits.pdf`, `Output/figure4_panel_b_binprob_fixed005_fullaudits.pdf`, and `Output/figure4_binprob_fixed005_fullaudits_support.tex`.
- Validation: reran Stata batch mode for the fixed-width script successfully. The support table reports all 20 bins, with bins 19 and 20 empty and bin 18 containing one selected full-audit case.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` twice to `.codex_tmp/report_compile_fixedbin/Inspector's Effort report.pdf`; the temporary PDF built successfully and includes the new figures. The in-place `Code Analyse data/Inspector's Effort report.pdf` could not be overwritten because the file was locked/open during `pdflatex`.

Update: 2026-06-02 (relaxed top-quartile target for bin-probability Figure 4)
- Updated `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` so the direct high-evasion-bin target is still top realized quartile, but now uses all executed observed training lists instead of dropping short lists. The realized-bin assignment now puts the highest-realized case in the top bin for every list, including lists with fewer than four executed observed cases.
- Revised the Table 49 Panel C target-summary output and report prose to remove the old minimum-list-size language. The report now describes the target as being defined over all executed observed cases with non-missing realized revenue and summarizes thin/empty realized-quartile cells.
- Regenerated the C1 full-audit prediction export and the report-facing Figure 4 probability diagnostics: `Output/figure4_binprob_decile_fullaudits_c1.dta`, `Output/figure4_panel_a_binprob_quartile_fullaudits.pdf`, `Output/figure4_panel_b_binprob_quartile_fullaudits.pdf`, `Output/figure4_panel_a_binprob_fixed005_fullaudits.pdf`, `Output/figure4_panel_b_binprob_fixed005_fullaudits.pdf`, `Output/figure4_binprob_quartile_fullaudits_support.tex`, and `Output/figure4_binprob_fixed005_fullaudits_support.tex`.
- Rerunning the Panel C script also regenerated `Output/table_opt_full_and_desk_bin_target_panelc.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`, and `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Validation: reran the R Panel C script successfully; A1 reproduced the current Table 9 values. The C1 full-audit target now uses 28 training lists, 508 training rows, and 138 high-bin rows; the target-summary table reports 19 singleton realized-quartile cells and 7 empty realized-quartile cells for C1 full audits.
- Validation: reran the quartile and fixed-width Stata figure scripts successfully. The fixed-width count table still has empty 0.90--1.00 bins and a thin upper tail, with three cases in 0.85--0.90.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place; `Code Analyse data/Inspector's Effort report.pdf` was rewritten successfully. The compile still reports pre-existing multiply defined labels and PDF-version warnings.

Update: 2026-06-02 (coarser fixed-width bin-probability Figure 4 grouping)
- Replaced the report-facing fixed-width probability grouping from 0.05-wide bins to 0.10-wide bins to reduce thin-bin noise while keeping an equal-width probability axis.
- Renamed the Stata script to `Code Analyse data/6 Figure 4 bin probability fixed010 panels.do` and updated `Code Analyse data/Inspector's Effort report.tex` to include `Output/figure4_panel_a_binprob_fixed010_fullaudits.pdf` and `Output/figure4_panel_b_binprob_fixed010_fullaudits.pdf`.
- Added `Output/figure4_binprob_fixed010_fullaudits_support.tex` with counts by the ten fixed probability bins.
- Validation: reran the fixed010 Stata script successfully. The 0.10 bins reduce some tail sparsity but the uppermost 0.90--1.00 bin remains empty; execution rates remain high in the lowest bins and rise again above 0.60.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place; `Code Analyse data/Inspector's Effort report.pdf` was rewritten successfully. The compile still reports pre-existing multiply defined labels and PDF-version warnings.

Update: 2026-06-02 (top-half direct probability target trial)
- Changed `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` from a top-quartile target to a top-half target by setting `target_bin_count <- 2`. The direct classifier now predicts whether an executed observed case belongs to the top half of realized evasion within its audit-type-by-detailed-tax-office-by-selection-year list.
- Updated the report notes and figure notes in `Code Analyse data/Inspector's Effort report.tex` to describe above-median realized-evasion membership rather than highest-quartile membership.
- Updated `Code Analyse data/6 Figure 4 bin probability fixed010 panels.do` and `Code Analyse data/6 Figure 4 bin probability quartile panels.do` labels/comments so the probability target is described as above-median realized evasion.
- Regenerated `Output/figure4_binprob_decile_fullaudits_c1.dta`, `Output/table_opt_full_and_desk_bin_target_panelc.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`, `Output/table_opt_full_and_desk_bin_target_support.tex`, `Output/figure4_panel_a_binprob_fixed010_fullaudits.pdf`, `Output/figure4_panel_b_binprob_fixed010_fullaudits.pdf`, `Output/figure4_panel_a_binprob_quartile_fullaudits.pdf`, `Output/figure4_panel_b_binprob_quartile_fullaudits.pdf`, `Output/figure4_binprob_fixed010_fullaudits_support.tex`, and `Output/figure4_binprob_quartile_fullaudits_support.tex`.
- Validation: reran the R Panel C script. The shell timed out after the script printed its completion messages, but the output timestamps confirm the DTA, diagnostics, and TeX files were written; A1 validation passed before the timeout. C1 full audits now have 28 training lists, 508 training rows, 261 high-bin rows, 7 singleton realized-half cells, and 0 empty realized-half cells.
- Validation: reran the quartile-priority and fixed010 Stata figure scripts successfully. The fixed010 support table now populates all probability bins; execution remains high in the lowest bins, falls near zero in the middle, and rises again in the highest bins.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place; `Code Analyse data/Inspector's Effort report.pdf` was rewritten successfully. The compile still reports pre-existing multiply defined labels and PDF-version warnings.

Update: 2026-06-02 (multiclass predicted-quartile Figure 4 diagnostic)
- Extended `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` with a separate multiclass realized-quartile diagnostic export for C1 selected non-safety full audits. The new branch assigns realized-evasion quartiles Q1--Q4 within `controle x bureau_detailed x selectionyear`, trains a multiclass random forest on executed observed cases with non-missing realized revenue, and exports quartile probabilities, expected quartile score, predicted quartile class, realized quartile, identifiers, `y2`, `algorithm`, `dgid`, `selection`, `safeties`, and `controle`.
- Kept the existing binary/top-half Panel C optimization ranking and report-facing table logic unchanged; the multiclass model is only used for the added Figure 4-style diagnostic.
- Added `Code Analyse data/6 Figure 4 multiclass quartile prediction panels.do` to build the selected non-safety full-audit sample, validate the multiclass probabilities, collapse distributions and execution rates by predicted quartile class, and write a support table.
- Added the two multiclass predicted-quartile figures to `Code Analyse data/Inspector's Effort report.tex` under `Predicting high-evasion bins`, immediately after the current top-half fixed010 figures and before the predicted-rank subsection.
- Output files affected: `Output/figure4_multiclass_quartile_fullaudits_c1.dta`, `Output/figure4_panel_a_binprob_multiclass_predquartile_fullaudits.pdf`, `Output/figure4_panel_b_binprob_multiclass_predquartile_fullaudits.pdf`, and `Output/figure4_binprob_multiclass_predquartile_fullaudits_support.tex`. Rerunning the Panel C script also regenerated the existing Panel C table/support outputs without changing their binary/top-half logic.
- Validation: reran the updated R Panel C script successfully with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`; A1 validation passed and the multiclass C1 full-audit export was written.
- Validation: checked the multiclass export has 944 selected non-safety full-audit rows, `predicted_realized_quartile` in 1--4, probability sums equal to one up to numerical tolerance, and `expected_realized_quartile` between 1.15 and 3.748.
- Validation: reran Stata batch mode for `Code Analyse data/6 Figure 4 multiclass quartile prediction panels.do` successfully. The support table reports predicted-class counts of 233, 232, 220, and 259 for Q1--Q4, with execution rates of 50.6, 55.6, 55.9, and 53.3 percent.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place. Both passes wrote `Code Analyse data/Inspector's Effort report.pdf` with the new figures included, but `pdflatex` returned a nonzero shell status because MiKTeX could not write `C:\Users\wb648862\AppData\Local\MiKTeX\miktex\log\pdflatex.log`; the compile still reports the pre-existing multiply defined labels and PDF-version warnings.

Update: 2026-06-02 (office-pooled above-median target diagnostic)
- Added a robustness export to `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` that rebuilds the binary above-median/top-half target within `controle x bureau_detailed`, pooling selection years within detailed tax office, while leaving the existing C1 year-specific target and report-facing outputs intact.
- Added `Code Analyse data/6 Figure 4 bin probability fixed010 office-target panels.do` to read the new office-pooled prediction export and generate fixed 0.10 probability-bin diagnostics with `_office_target` suffixed output names.
- Output files affected: `Output/figure4_binprob_decile_fullaudits_c1_office.dta`, `Output/figure4_panel_a_binprob_fixed010_fullaudits_office_target.pdf`, `Output/figure4_panel_b_binprob_fixed010_fullaudits_office_target.pdf`, and `Output/figure4_binprob_fixed010_fullaudits_office_target_support.tex`. Rerunning the R companion also refreshed the existing Panel C table/support outputs and current C1 diagnostic exports.
- Validation: reran the R Panel C companion successfully with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`; A1 validation passed and the new office-pooled prediction export was written.
- Validation: reran Stata batch mode for the office-target fixed010 script successfully. The support table reports 944 selected non-safety full-audit rows across all probability bins. The middle-bin execution dip persists under the office-pooled target: 0.30--0.40 is 3.8%, 0.40--0.50 is 0.0%, and 0.50--0.60 is 0.9%, so the sharp middle drop is not resolved by pooling the target within detailed tax office.

Update: 2026-06-03 (0.05 office-pooled probability-bin diagnostic)
- Parameterized `Code Analyse data/6 Figure 4 bin probability fixed010 office-target panels.do` so the office-pooled target diagnostic can be rerun with configurable fixed probability-bin widths while preserving the existing 0.10 output names by default.
- Added `Code Analyse data/6 Figure 4 bin probability fixed005 office-target panels.do`, a wrapper that runs the same office-pooled above-median target diagnostic with 0.05-wide predicted-probability bins.
- Output files affected: `Output/figure4_panel_a_binprob_fixed005_fullaudits_office_target.pdf`, `Output/figure4_panel_b_binprob_fixed005_fullaudits_office_target.pdf`, and `Output/figure4_binprob_fixed005_fullaudits_office_target_support.tex`.
- Validation: reran Stata batch mode for the 0.05 office-target wrapper successfully. The support table reports 944 selected non-safety full-audit rows. The finer bins preserve the same broad pattern: execution is high below 0.30, falls to 0--1.9% from 0.35--0.60, remains 0% at 0.60--0.65, and rises sharply after 0.70. The 0.95--1.00 bin is empty and the 0.00--0.05 bin has only 6 cases, so the 0.05 version is more granular but thinner in the tails.

Update: 2026-06-03 (office-pooled top-10 probability-bin diagnostic)
- Extended `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` so the direct high-evasion-bin target builder can use a requested number of realized-evasion bins instead of only the project default `target_bin_count <- 2`.
- Added a new diagnostic export where the target is top-10% realized-evasion membership within `controle x bureau_detailed`, pooling selection years within detailed tax office. The export leaves the current top-half C1 outputs unchanged and writes `Output/figure4_binprob_decile_fullaudits_c1_office_top10.dta`.
- Parameterized `Code Analyse data/6 Figure 4 bin probability fixed010 office-target panels.do` so wrappers can override the input `.dta`, output suffix, bin width, and x-axis title.
- Added `Code Analyse data/6 Figure 4 bin probability fixed005 office-top10 panels.do` to generate 0.05-wide fixed probability-bin diagnostics for the office-pooled top-10 target.
- Output files affected: `Output/figure4_binprob_decile_fullaudits_c1_office_top10.dta`, `Output/figure4_panel_a_binprob_fixed005_fullaudits_office_top10.pdf`, `Output/figure4_panel_b_binprob_fixed005_fullaudits_office_top10.pdf`, and `Output/figure4_binprob_fixed005_fullaudits_office_top10_support.tex`. Rerunning the R companion also refreshed existing Panel C table/support outputs and C1 diagnostic exports.
- Validation: reran the R Panel C companion successfully with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`; A1 validation passed and the new office-top10 prediction export was written.
- Validation: reran Stata batch mode for the 0.05 office-top10 wrapper successfully. The support table reports 944 selected non-safety full-audit rows, but the top-10 target creates sparse upper probability support: bins 0.50--0.60 and 0.85--1.00 are empty, and bins 0.35--0.50 and 0.75--0.85 contain between 1 and 5 cases each. The high realized top-10 cases concentrate in predicted probability bins 0.60--0.85, all with 100% execution in the observed support.

Update: 2026-06-03 (final Table 49 above-median probability specification)
- Finalized the report-facing split between Table 48 and Table 49. Table 48 remains the original predicted-rank optimization table from `Code Analyse data/Replication R/07_Optimization_Exercise_Unweighted_Top5_Revision.R`; Table 49 now uses the direct above-median/top-half probability target.
- Updated `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` so Panel C trains the binary target within `controle x bureau_detailed`, pooling selection years within detailed tax office, with `target_bin_count <- 2`. Panel C ranks optimized selections by predicted above-median realized-evasion probability while keeping the paired A1/C1, A2/C2, and A3/C3 valuation logic unchanged.
- Made the support-table exporter TeX-safe for grouping labels such as `bureau_detailed`, and regenerated `Output/table_opt_full_and_desk_bin_target_panelc.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`, and `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Updated `Code Analyse data/Inspector's Effort report.tex` so the Table 49 notes and support notes describe above-median realized-evasion membership, target grouping within audit type by detailed tax office, the 2018--2019 optimization exercise, and Panel C's predicted-probability ranking.
- Reduced the `Predicting high-evasion bins` report subsection to only the final 0.05 fixed-bin office-pooled figures: `Output/figure4_panel_a_binprob_fixed005_fullaudits_office_target.pdf` and `Output/figure4_panel_b_binprob_fixed005_fullaudits_office_target.pdf`.
- Validation: reran the R Panel C companion with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`. A1 validation passed and all expected Table 49/support/diagnostic outputs were written; the shell reported a timeout after the script had printed all completion messages, so output timestamps were checked directly.
- Validation: reran Stata batch mode for `Code Analyse data/6 Figure 4 bin probability fixed005 office-target panels.do` successfully. The support table reports 944 selected non-safety full-audit rows across 20 fixed 0.05 bins, with target grouping from the office-pooled above-median export.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` twice in place. Both passes wrote `Code Analyse data/Inspector's Effort report.pdf` and the second pass cleared undefined references. `pdflatex` still returned a nonzero shell status because MiKTeX could not write `C:\Users\wb648862\AppData\Local\MiKTeX\miktex\log\pdflatex.log`; the remaining TeX warnings are the pre-existing multiply defined labels, overfull boxes, and PDF-version warnings.

Update: 2026-06-03 (Table 49 wording cleanup)
- Edited `Code Analyse data/Inspector's Effort report.tex` to replace "bin-target companion" wording with "predicted above-median evasion" wording in the subsection title, Table 49 caption, support-table caption, figure notes, and step-by-step explanation.
- Clarified that "C-panel specification" refers to the sample/valuation pair: C1 keeps all cases, while C2 and C3 use the same pre-training top-five exclusion as A2 and A3.
- Reworded the target construction as an above-/below-median realized-evasion class rather than "halves" or "high-bin" language.
- Added a bullet explaining that the prediction target is pooled within audit type by detailed tax office, but Panel C optimized selections still follow the pre-existing list-level rules: rebuild selections within tax-office-by-selection-year lists and match the realized executed-audit count in each list.
- Added a bullet explaining why overlap can remain unchanged across C subpanels: overlap depends on the optimized set rather than the amount-prediction valuation model; C2 and C3 share the same top-five-excluded probability-ranking sample.
- Updated the report-input TeX fragments `Output/table_opt_full_and_desk_bin_target_panelc.tex` and `Output/table_opt_full_and_desk_bin_target_support.tex` so embedded headers and row labels use "predicted above-median" and "above/below median" language. Updated the R exporter labels in `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` so future regeneration preserves this wording.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` twice in place. Both passes wrote `Code Analyse data/Inspector's Effort report.pdf`; the second pass did not request another rerun. `pdflatex` still returned nonzero because MiKTeX could not write its AppData log file, with the same pre-existing multiply defined label, overfull box, and PDF-version warnings.

Update: 2026-06-03 (Table 48 optimization variants and list-level above-median target)
- Reorganized `Code Analyse data/Inspector's Effort report.tex` so the optimization section now has three subsections: 3.1 predicting ranking, 3.2 predicting above-median evasion in a tax office, and 3.3 predicting above-median evasion in a list. The current predicted-rank table, support table, Figure 4-style diagnostics, and step explanation now sit under 3.1; the current office-pooled above-median version sits under 3.2; the new list-level version sits under 3.3.
- Updated `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R` with a type-specific target-grouping helper for the new list-level above-median export. Full-audit targets are defined within `bureau_detailed x selectionyear`; desk-audit targets are defined within `inspectorclusteryear`. Optimized selections and executed-count constraints continue to be rebuilt within `inspectorclusteryear`, matching the existing Table 48 optimization scripts.
- Added `Code Analyse data/6 Figure 4 bin probability fixed005 listyear-target panels.do`, a wrapper around the fixed 0.05 probability-bin Figure 4 diagnostic that reads the list-level C1 full-audit prediction export and writes `_listyear_target` outputs.
- New output files: `Output/table_opt_full_and_desk_bin_target_panelc_listyear.tex`, `Output/table_opt_full_and_desk_bin_target_panelc_listyear_diagnostics.csv`, `Output/table_opt_full_and_desk_bin_target_listyear_support.tex`, `Output/figure4_binprob_decile_fullaudits_c1_listyear.dta`, `Output/figure4_binprob_fixed005_fullaudits_listyear_target_support.tex`, `Output/figure4_panel_a_binprob_fixed005_fullaudits_listyear_target.pdf`, and `Output/figure4_panel_b_binprob_fixed005_fullaudits_listyear_target.pdf`. Rerunning the R companion also refreshed the existing office-pooled Panel C table, diagnostics, and support outputs.
- Validation: parsed the updated R script successfully, reran the Panel C companion with the Dropbox working-data folder as `data_path` and this repo's `Output/` folder as `output_path`, and A1 benchmark validation passed. The run wrote all existing and new list-level outputs; package-version warnings were the only R warnings.
- Validation: checked the new list-level support table. Full audits have 28 target groups, 508 C1 training rows, 7 singleton classes, and 0 empty classes. Desk audits use `inspectorclusteryear` as the list identifier and are thin in places: 147 target groups, 1011 C1 training rows, 78 singleton classes, and 19 empty classes; C2/C3 have 81 singleton classes and 19 empty classes.
- Validation: reran Stata batch mode for the new list-level Figure 4 wrapper successfully. The support table reports 944 selected non-safety full-audit rows across 0.05 probability bins; the 0.95--1.00 bin is empty.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` twice in place. The second pass wrote `Code Analyse data/Inspector's Effort report.pdf` and cleared unresolved references; the compile still reports the pre-existing multiply defined labels, overfull boxes, PDF-version warnings, and MiKTeX AppData log warning.

Update: 2026-06-05 (optimization table-note wording cleanup)
- Edited the table notes for Tables 48, 51, and 53 in `Code Analyse data/Inspector's Effort report.tex`.
- Recast the notes to mirror the original Table 9 tone: realized audit results train random forest models, the 2018--2019 audit program is optimized, Columns 1--2 report realized and predicted revenue, and the optimization columns report revenue gains and overlap.
- Removed raw variable names from these table notes and replaced them with readable labels such as detailed tax office, implementation list, and inspector assignment list.
- Clarified the difference between the above-median exercises: Table 51 defines the target within audit type and detailed tax office while pooling years; Table 53 defines it within the operational list relevant to each audit type.
- Output files affected: `Code Analyse data/Inspector's Effort report.pdf`.
- Validation: recompiled `Code Analyse data/Inspector's Effort report.tex` once with `pdflatex`. The compile succeeded and wrote a 150-page PDF; the log still reports the pre-existing multiply defined labels, overfull boxes, PDF-version warnings, and MiKTeX AppData log warning.

Update: 2026-06-16 (Figure 4 with unweighted two-step amount predictions)
- Added `Code Analyse data/Replication R/09_Figure4_TwoStep_Unweighted_Amount_Prediction.R`, a standalone R export that keeps the original optimization-style detection/evasion gate (`y4 > 1`) but removes the top-quartile second-stage revenue weights from the amount Random Forest.
- Added `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do`, a standalone Stata workflow that reads the exported full-audit predictions and generates Figure 4-style Panel A and Panel B diagnostics.
- Added a new subsection to Section 3 of `Code Analyse data/Inspector's Effort report.tex` titled `Figure 4 with unweighted two-step amount predictions`, with the two new plots included as subfigures in one figure environment and a single combined notes block.
- New output files: `Output/fullaudits_predicted_twostep_unweighted.dta`, `Output/figure4_panel_a_twostep_unweighted_yhatrf_fullaudits.pdf`, and `Output/figure4_panel_b_twostep_unweighted_yhatrf_fullaudits.pdf`.
- Validation: ran the R export successfully with R 4.5.1. It wrote 944 selected non-safety full-audit rows and trained the amount RF on 457 positive-evasion rows; package-version warnings were the only R warnings.
- Validation: checked the exported DTA contains `yhatrf`, `y2`, `y4`, `algorithm`, `dgid`, `selection`, `safeties`, and `controle`, with nonmissing `yhatrf` for all 944 rows.
- Validation: ran `stata-mp /e do "Code Analyse data\6 Figure 4 two-step unweighted yhatrf panels.do"` successfully through `end of do-file`; both new PDFs were written to `Output/`.
- Validation: compiled `Code Analyse data/Inspector's Effort report.tex` into `.codex_tmp/report_compile_twostep_unweighted/`. The compile succeeded after rerunning with filesystem escalation for MiKTeX user-log access and produced a 151-page PDF; remaining warnings are the pre-existing multiply defined labels, overfull boxes, PDF-version inclusion warnings, and MiKTeX update notice.

Update: 2026-06-16 (Figure 4 unweighted two-step color sync)
- Updated `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do` so the unweighted two-step Figure 4 replication uses the same palette as the existing Figure 4-style plots: navy/green/gray/red in Panel A and maroon/orange in Panel B.
- Updated the combined figure notes in `Code Analyse data/Inspector's Effort report.tex` so the color references match the regenerated plots.
- Outputs refreshed: `Output/figure4_panel_a_twostep_unweighted_yhatrf_fullaudits.pdf`, `Output/figure4_panel_b_twostep_unweighted_yhatrf_fullaudits.pdf`, and `Code Analyse data/Inspector's Effort report.pdf`.
- Validation: reran `stata-mp /e do "Code Analyse data\6 Figure 4 two-step unweighted yhatrf panels.do"` successfully through `end of do-file`, then recompiled the report with MiKTeX `pdflatex`; the compile wrote a 151-page PDF with only the existing nonfatal warnings.

Update: 2026-06-16 (Figure 4 unweighted two-step paper-style support)
- Revised `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do` so both panels use the original Figure 4-style one-log-point bins while restricting plotted series to bins with midpoint above 12.5.
- The support restriction removes the mechanical zero-gate mass point from the plotted execution lines: 53 cases with `mid_bin <= 12.5` are excluded from the plotted construction, leaving 891 selected non-safety full-audit cases across one-log-point bins in Panel A.
- Checked that the restricted Panel A support is not capped at 22: the regenerated bin table includes `mid_bin == 22.5` with 25 cases and `mid_bin == 23.5` with 3 cases.
- Updated the combined figure notes in `Code Analyse data/Inspector's Effort report.tex` to document the one-log-point-bin construction and `mid_bin > 12.5` restriction.
- Outputs refreshed: `Output/figure4_panel_a_twostep_unweighted_yhatrf_fullaudits.pdf`, `Output/figure4_panel_b_twostep_unweighted_yhatrf_fullaudits.pdf`, and `Code Analyse data/Inspector's Effort report.pdf`.
- Validation: reran the Stata figure script successfully, checked the cropped one-log-point support for Panels A and B, and recompiled the report with MiKTeX `pdflatex`; the compile wrote a 151-page PDF with only the existing nonfatal warnings.

Update: 2026-06-16 (Figure 4 unweighted two-step x-axis lower bound)
- Updated `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do` so both Panel A and Panel B explicitly start the x-axis at 12.5 while preserving the observed right tail in each panel.
- Outputs refreshed: `Output/figure4_panel_a_twostep_unweighted_yhatrf_fullaudits.pdf` and `Output/figure4_panel_b_twostep_unweighted_yhatrf_fullaudits.pdf`.
- Validation: reran the Stata figure script successfully. An in-place report compile could not overwrite `Code Analyse data/Inspector's Effort report.pdf` because that PDF was locked by another process, so the report was compiled twice to `.codex_tmp/report_compile_xaxis/`; the second pass produced a 151-page PDF with only the existing nonfatal warnings.

Update: 2026-06-16 (Figure 4 unweighted two-step inclusive 12.5 bin)
- Revised `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do` so both panels keep one-log-point bins with `mid_bin >= 12.5`, allowing the 12.5 bin to appear.
- Matched the original Figure 4-style x-axis more closely by using ticks from 12.5 to 25 in 2.5-log-point increments for both panels.
- Updated `Code Analyse data/Inspector's Effort report.tex` notes to describe the inclusive support restriction.
- Validation: reran the Stata figure generator successfully and confirmed both panel PDFs were regenerated. Recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place; the second pass wrote a 151-page PDF with only the existing nonfatal warnings.

Update: 2026-06-16 (Figure 4 unweighted two-step 14.5 start)
- Revised `Code Analyse data/6 Figure 4 two-step unweighted yhatrf panels.do` so both panels start at `mid_bin >= 14.5`, the first observed post-gate predicted-evasion bin.
- Updated the x-axis ticks to begin at 14.5 and updated the combined figure notes in `Code Analyse data/Inspector's Effort report.tex`.
- Validation: reran the Stata figure generator successfully and confirmed both panel PDFs were regenerated. Recompiled `Code Analyse data/Inspector's Effort report.tex` twice in place; the second pass wrote a 151-page PDF with only the existing nonfatal warnings.


Update: 2026-06-24 (realized-effects table merged cells)
- Updated `Code Analyse data/table_senegal_realized_effects.tex` so the Corruption and Inspector bias entries are merged across the three audit-process rows using `\multirow`, matching the source PDF table structure.
- Added a file-level comment noting the `multirow` package requirement and increased row spacing in the realized-effects table so the merged cells fit without overfull multirow boxes.
- Validation: compiled a disposable smoke-test wrapper with `booktabs`, `array`, `adjustbox`, `threeparttable`, `float`, and `multirow`; both Senegal table files compiled successfully. Removed the temporary wrapper and generated aux/log/pdf files afterward.

Update: 2026-06-24 (realized-effects merged-cell vertical alignment)
- Changed the two merged cells in `Code Analyse data/table_senegal_realized_effects.tex` from top-aligned `\multirow[t]` to centered `\multirow[c]`, so the shared Corruption and Inspector bias text visually sits across all three audit-process rows rather than reading as part of the first row.
- Validation: reran the disposable LaTeX smoke test with `multirow`; both Senegal table files compiled successfully, then temporary compile files were removed.

Update: 2026-06-24 (realized-effects merged-cell vertical offset)
- Adjusted the two centered `\multirow` cells in `Code Analyse data/table_senegal_realized_effects.tex` with a negative vertical move (`[-2.2cm]`) so the shared Corruption and Inspector bias text sits visually around the middle of the three audit-process rows. This compensates for `multirow` not knowing the true height of wrapped `p{}` rows.
- Validation: reran the disposable LaTeX smoke test with `multirow`, rendered the test PDF to PNG, and checked the rendered right-column text bands were concentrated around the middle body rows rather than the first row. Removed all temporary compile/render files afterward.
