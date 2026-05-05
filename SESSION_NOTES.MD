# Session Notes

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
