# Codex Handoff - 2026-05-25

## Current branch

- Branch: `inspector_effort`
- Remote: `origin` at `https://github.com/renamorado/Senegal-Tax-Audit.git`
- Last checked state before this handoff: branch was tracking `origin/inspector_effort`.

## Current task context

The recent discussion focused on whether the prediction/optimization exercise should move beyond predicted evasion amounts and predicted ranks toward a direct high-evasion-bin target. The motivating issue was that rank-based Figure 4 diagnostics looked less visually sharp than amount-based diagnostics, and Alipio suggested predicting membership in a high-evasion bin instead of predicting the full rank.

The selected implementation path was:

- Treat bin prediction as a companion diagnostic, not a replacement for amount or rank prediction.
- Use direct bin-target prediction rather than post-prediction binning.
- Define the high-bin target within audit-type-by-detailed-tax-office-by-selection-year lists.
- Use quartiles as the first implemented target because they satisfy a minimum support rule more conservatively than finer bins.
- Train a one-step random forest classifier for high-realized-evasion-quartile membership.
- Use predicted high-bin probability only to rank cases for optimized selection.
- Continue valuing gains with the matched amount-prediction model so Panel C remains comparable with Panel A.

## Files changed in the current work

- `tasks/2026-05-25-001-predicted-evasion-bin-target-brainstorm.md`
  - Records the conceptual discussion, design choices, risks, and open questions for direct high-evasion-bin prediction.
- `Code Analyse data/Replication R/08_Optimization_Exercise_Bin_Target_PanelC.R`
  - New standalone companion R script.
  - Rebuilds Panel A amount-prediction benchmarks and adds Panel C direct quartile-target optimized selection.
  - Writes the Panel C companion table, diagnostics CSV, and support table.
- `Output/table_opt_full_and_desk_bin_target_panelc.tex`
  - Main TeX fragment for the Panel A/Panel C companion table.
- `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`
  - Diagnostics for training rows, selected/executed/optimized counts, overlap, 2020 exclusion, and bin-support metadata.
- `Output/table_opt_full_and_desk_bin_target_support.tex`
  - Support diagnostic table for the quartile target.
- `Code Analyse data/Inspector's Effort report.tex`
  - Adds a `Predicting high-evasion bins` subsection under the optimization/rank section.
  - Inputs the new Panel C companion table and the support table.
  - Adds notes explaining the quartile target, support rule, top-five exclusion timing, and amount-model valuation of Panel C gains.
- `Code Analyse data/Inspector's Effort report.pdf` and LaTeX auxiliary files
  - Generated report artifacts from compiling the updated report.
- `SESSION_NOTES.MD`
  - Updated with the recent work record.

## Key output values to know

Panel C companion table:

- C1 full audits: `+ 12.66%` gain, `62%` overlap.
- C1 desk audits: `+ 18.09%` gain, `54%` overlap.
- C2 full audits: `+ 12.61%` gain, `60%` overlap.
- C2 desk audits: `+ 18.02%` gain, `55%` overlap.
- C3 full audits: `- 7.10%` gain, `60%` overlap.
- C3 desk audits: `- 2.53%` gain, `55%` overlap.

Support table:

- Full audits: 28 total training lists; 21 supported; 7 unsupported.
- Desk audits: 24 total training lists; 23 supported; 1 unsupported.
- Minimum cases per realized quartile among supported lists is 2.
- Singleton and empty supported bins are both 0.

Diagnostics:

- All table rows exclude 2020 (`rows_2020_in_table = 0`).
- Optimized counts match executed counts within scenario and audit type.
- A1 validation reproduced current Table 9 values exactly:
  - Full audits: `21.24`, `21.14`, `+ 18.09%`, `65%`.
  - Desk audits: `19.00`, `18.73`, `+ 31.01%`, `61%`.

## Validation already performed

- Ran `08_Optimization_Exercise_Bin_Target_PanelC.R` with `data_path` pointing to the Dropbox working-data folder and `output_path` pointing to this repo's `Output/` folder.
- Confirmed the R script reported the A1 validation pass against current Table 9 values.
- Inspected `Output/table_opt_full_and_desk_bin_target_panelc.tex`.
- Inspected `Output/table_opt_full_and_desk_bin_target_support.tex`.
- Inspected `Output/table_opt_full_and_desk_bin_target_panelc_diagnostics.csv`.
- Compiled `Code Analyse data/Inspector's Effort report.tex`; the resulting report artifacts are present in `Code Analyse data/`.

## Open issues and suggested next checks

- Decide whether the bin-target companion should stay as a separate companion table or eventually merge into the broader Table 48 amount/rank table.
- Review whether unsupported lists should remain excluded from bin-target training only, as currently implemented, or whether a pooling/fallback rule is preferable.
- If Anne/Roldan want a Figure 4-style bin-probability diagnostic, the next natural output is execution rate by predicted high-bin-probability decile.
- If Panel C is manuscript-facing, review the table notes for length; the current notes are intentionally explicit but may be too long for final paper style.
- The generated LaTeX auxiliary files and PDF were included because the current workflow already tracks report artifacts in this branch. If the team wants source-only commits, remove those artifacts in a follow-up cleanup commit rather than silently mixing that policy change into this work.

