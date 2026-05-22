# Anne To Dos, 2026-05-19

Project: Senegal tax audit revisions  
Status: Planning document only. No analysis edits have been made from these tasks yet.  
Source: Raw comments from Anne shared by Roldan.

## 1) Core Objective

Anne's comments center on whether rank-based prediction is useful for the optimization and paper tables, and on making the optimization results easier to interpret.

The main analytical questions are:

- Does a rank-based prediction produce Figure 4-style patterns that look similar enough to the current predicted-amount figure to justify further work?
- Are the optimization tables consistently restricted to 2018 and 2019, excluding 2020 because prediction quality is weaker in 2020?
- Can Table 48 be rebuilt so each panel changes only one conceptual feature at a time?
- Are optimization gains small because the optimized program mostly preserves the highest-realized-evasion audit cases?
- How should prediction quality be assessed for amount prediction versus rank prediction?

## 2) Task 1: Figure 4 With Rank-Prediction Quantiles

Motivation:

- Anne wants a version of Figure 4 where the x-axis uses deciles, or another quantile grouping, of the rank of predicted evasion.
- If the figure looks similar to the current Figure 4, rank-based prediction may be worth pursuing after quality checks.
- If it looks very different, Anne suggests not going further down the rank-based path.

Implementation tasks:

- Identify the current Figure 4 code and output files.
- Create a Figure 4-style variant using deciles of the rank-based predicted evasion score on the x-axis.
- If deciles are too noisy or visually awkward, test a smaller number of quantiles, such as quintiles.
- Keep the figure visually comparable to the current Figure 4 wherever possible.
- Export the new figure under a separate descriptive filename so the current manuscript figure is not overwritten.

Review questions:

- Does the rank-quantile figure preserve the same qualitative pattern as the current Figure 4?
- Are differences due to rank prediction itself, binning choices, or sample changes?
- Does the figure support continuing with rank-based optimization checks?

Likely outputs:

- New Figure 4-style PDF using rank-prediction deciles or quantiles.
- Optional short report note comparing it to the current Figure 4.

Validation:

- Confirm the plotted sample matches the intended Figure 4 sample.
- Confirm rank direction is correct: higher-priority rank prediction should appear on the intended side of the x-axis.
- Confirm each x-axis quantile contains enough observations for interpretation.

> [!comment_figure4] Comments on Figure 4
> * I had already generated figure 4 but during the recent meeting we had we discussed that we could do percentile ranks instead of the pure inverted rank. That is, for each case per list we will do this: numerator=rank position / denominator %.
> * We might need to think on if  doing an alternative definition since using the raw rank its weird that large  percentile rank = being at the bottom. So our idea of execution rates   increasing with rank would look opposite if we don't do this adjustment.
> * Also we might need to think if the distributions makes sense using this new indicator?
> 


## 3) Task 2: Verify 2018-2019 Restriction in Table 9, Paper Text, and Table 48

Motivation:

- Anne wants to confirm that Table 9, the paper text, and Table 48 in the new document are based on 2018 and 2019 only.
- The reason is substantive: prediction quality is much lower in 2020, so prior analysis focused on 2018 and 2019, but this restriction may not be prominent enough in the paper.

Implementation tasks:

- Locate the code that generates Table 9.
- Locate the code or TeX fragment that generates Table 48 in the new document.
- Confirm whether each table is restricted to selection years 2018 and 2019 only.
- Check the paper text and table notes for whether the 2018-2019 restriction is clearly stated.
- If any table includes 2020, flag it before changing the code because that would alter the estimand and interpretation.
- If the code is already restricted correctly but the paper text is vague, propose or add clearer table-note wording.

Review questions:

- Are Table 9 and Table 48 using exactly the same year restriction?
- Does any supporting text imply a broader sample than the actual 2018-2019 analysis sample?
- Should the paper explicitly mention that 2020 is excluded because prediction quality is weaker?

Likely outputs:

- Verification note documenting the year restriction for Table 9 and Table 48.
- Possible revised table notes or paper text clarifying the 2018-2019 restriction.

Validation:

- Display or log sample counts by year for each table-generating script.
- Confirm 2020 contributes zero observations to the relevant optimization table outputs.

> [!task2_yearsvalid] 2018-2019 sample: already in place
> We already use this filter.

## 4) Task 3: Rebuild Table 48 as Panel-Based Optimization Table

Motivation:

- Anne says Table 48 is hard to interpret because columns 5 and 6 change multiple things at once.
- The replacement should use panels so that the same column structure is repeated across different versions of the optimization exercise.

Clarification needed before coding:

- Anne refers to "columns 1-3" as the repeated structure, but later says "columns 3 and 4" would change in the B panels. Before implementation, confirm whether the intended repeated structure has 3 columns or 4 columns.
- Confirm whether "top 5 cases" means top five implemented audit cases by realized evasion within audit type overall, within year, or within tax-office-by-year list.
- Confirm whether "realized evasion" means the same outcome used in the current optimization gains table.

Panel design:

- Panel A1: Current version. All cases, random forest predicting amounts with the two-step procedure and weights.
- Panel A2: Same as A1, but remove the top five cases in realized evasion from the start.
- Panel A3: Same as A2, but use the unweighted one-step random forest prediction.
- Panel B1: Use rank prediction to rank cases for optimized selection, but calculate optimization gains using the amount-prediction approach from A1.
- Panel B2: Use rank prediction to rank cases for optimized selection, but calculate optimization gains using the amount-prediction approach from A2.
- Panel B3: Use rank prediction to rank cases for optimized selection, but calculate optimization gains using the amount-prediction approach from A3.

Interpretation rule for B panels:

- Columns that describe the implemented audit program should not change relative to the corresponding A panel.
- Columns that depend on which cases are selected by optimization may change because rank-based ranking can select a different optimized set.
- Gains in the B panels should still be calculated using RF predicted amounts, not rank-predicted values.

Implementation tasks:

- Map the current Table 48 columns to the intended repeated column structure.
- Build a panel table generator that produces A1-A3 and B1-B3 under a consistent format.
- Keep all output filenames separate from existing manuscript-facing tables unless replacement is explicitly intended.
- Add table notes explaining which prediction is used for ranking and which prediction is used for gain calculation.

Review questions:

- Does the panel structure isolate each change cleanly?
- Do the B panels show whether rank-based selection changes the optimized set materially?
- Are gains still interpretable as amount-based optimization gains?

Likely outputs:

- New panel-based Table 48 TeX fragment.
- Optional comparison note against the current Table 48.

Validation:

- Confirm A1 reproduces the current version.
- Confirm A2 differs from A1 only by excluding the top five realized-evasion cases from the start.
- Confirm A3 differs from A2 only by using the unweighted one-step RF.
- Confirm B1-B3 use rank prediction only for optimized ranking, while gains are calculated with amount-prediction values.
- Confirm sample counts and selected-case counts are logged for every panel.

## 5) Task 4: Add Top-Five Reshuffling Share to Table G2

Motivation:

- Anne wants Table G2 to show more directly whether optimization reshuffles top cases.
- The proposed metric is the share of the top five implemented audit cases, ranked by realized evasion, that are also part of the optimized program.
- This is meant to show that reshuffling among top cases is limited, at least outside small tax offices, so optimization gains are small.

Implementation tasks:

- Locate the code that generates Table G2.
- Define the top five implemented audit cases based on realized evasion.
- For each relevant office, audit type, or table row, calculate the share of those top five cases that also appear in the optimized program.
- Add this as an additional column in Table G2.
- Update the table note so the new column is easy to interpret.

Review questions:

- Should the top five be defined within tax office, within office-year, within audit type, or within the exact Table G2 grouping?
- Should small tax offices be separately flagged or excluded from the main interpretation?
- Does the new column clarify why Table G2 does not show a clear pattern across offices?

Likely outputs:

- Updated Table G2 TeX fragment with the additional reshuffling column.
- Possible short text note interpreting top-case overlap by office size.

Validation:

- Confirm the denominator is five whenever a group has at least five implemented audit cases.
- Define and document behavior for groups with fewer than five implemented audit cases.
- Spot-check several offices manually to verify the overlap calculation.

## 6) Task 5: Prediction-Quality Diagnostics

Motivation:

- Anne wants a systematic assessment of prediction quality for amount prediction and rank prediction.
- The goal is not to assume rank prediction is easier or better; it may help when data are skewed and noisy, but that needs to be checked.

Amount-prediction diagnostics:

- RMSE.
- MAE.
- R-squared.

Rank-prediction diagnostics:

- Spearman correlation.
- Kendall tau.
- Average realized evasion among top-decile firms.
- Top-decile lift: realized evasion in the top predicted decile relative to the rest of the sample.

Implementation tasks:

- Identify the prediction files and samples used for current amount prediction.
- Identify the rank-prediction file and sample.
- Calculate amount-prediction diagnostics on the relevant validation or audited sample.
- Calculate rank-prediction diagnostics on the same comparable sample wherever possible.
- Produce diagnostics separately for 2018-2019 and 2020 if 2020 is available, since Anne flagged lower prediction quality in 2020.
- Consider reporting diagnostics by audit type and possibly by tax-office grouping if sample sizes support it.

Review questions:

- Is rank prediction actually better than amount prediction for selecting high-evasion cases?
- Are quality differences driven by 2020, small offices, or extreme top cases?
- Do the diagnostics support using rank-based optimization in the main text, appendix, or not at all?

Likely outputs:

- Prediction-quality TeX table or compact diagnostics note.
- Optional appendix-ready table comparing amount and rank prediction quality.

Validation:

- Confirm diagnostic samples are clearly defined and comparable.
- Confirm direction conventions for rank prediction before computing correlations and top-decile lift.
- Confirm top-decile lift uses realized evasion, not predicted evasion, in the numerator and comparison group.

## 7) Proposed Task Order

1. Verify the 2018-2019 restriction for Table 9, Table 48, and the paper text.
2. Produce the Figure 4 rank-quantile diagnostic and decide whether rank-based work should continue.
3. Build the amount and rank prediction-quality diagnostics.
4. Clarify the intended Table 48 column structure and top-five exclusion definition.
5. Rebuild Table 48 as A1-A3 and B1-B3 panels.
6. Add the top-five reshuffling share to Table G2.
7. Update paper/table notes only after the code outputs and diagnostics are validated.

## 8) Open Questions for Anne or Roldan

- For Table 48, should the repeated structure have 3 columns or 4 columns?
- For top-five exclusions and reshuffling shares, should "top five" be defined within audit type, year, tax office, office-year, or the exact table grouping?
- Should 2020 be excluded from all optimization outputs, or only from the main paper-facing optimization tables?
- Should prediction-quality diagnostics be reported in the new document, appendix, or only used internally to decide whether rank-based optimization is worth pursuing?
- If the Figure 4 rank-quantile version differs from the current Figure 4, what threshold is enough to stop work on rank-based optimization?

