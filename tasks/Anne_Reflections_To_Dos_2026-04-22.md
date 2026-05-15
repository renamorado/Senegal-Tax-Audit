# Anne Reflections and To Dos, 2026-04-22

Project: Senegal tax audit regressions  
Status: Planning document only. No analysis edits have been made from these tasks yet.

## 1) Core Question

Why does controlling for predicted evasion not eliminate the association between algorithm selection and:

- audit outcomes, especially execution;
- audit process measures, especially number of inspectors?

Current interpretation to examine:

- Predicted evasion explains a large share of the algorithm-execution gap, but not all of it.
- Remaining associations may reflect limits of the prediction control, selected training data, model fit, or genuine process/effort differences.

## 2) Flexible Predicted-Evasion Controls

Motivation:

- Decile controls reduce the association more than linear or simpler controls.
- The current controls may still be insufficiently flexible, especially at the top of the predicted-evasion distribution.

Tasks for review:

- Re-estimate the relevant tables using 15 predicted-evasion bins.
- Re-estimate the relevant tables using 20 predicted-evasion bins.
- Test a variant that keeps the baseline decile structure but splits the top two deciles into finer bins.
- Before estimating, verify that each bin contains enough inspector-selected and algorithm-selected observations.
- Record bin counts by selection method, audit type, and year before interpreting coefficients.

Review questions:

- How much more of the algorithm coefficient is absorbed by finer bins?
- Do the finer-bin results look stable, or are they driven by thin cells?
- Is the remaining association concentrated among the highest predicted-evasion firms?

Likely outputs to compare:

- Table 8 full-audit execution and detection specifications.
- Inspector-effort / number-of-inspectors specifications.
- Any existing predicted-evasion-control variants using linear, quadratic, quintile, or decile controls.

## 3) Subsample Checks Where the ML Model May Work Better

Motivation:

- The ML prediction may be more informative in particular periods or taxpayer groups.
- Anne suggested focusing on 2018-2019 and/or LTU/MTO.

Tasks for review:

- Re-estimate the decile-control specification only for 2018-2019.
- Re-estimate the decile-control specification only for LTU/MTO taxpayers.
- If sample sizes permit, estimate the intersection: 2018-2019 and LTU/MTO.
- For each subsample, report sample counts by method and predicted-evasion bin.

Review questions:

- Does predicted evasion absorb more of the algorithm association in these subsamples?
- Are coefficients more consistent with the interpretation that model quality matters?
- Are standard errors too large to support much interpretation?

## 4) Investigate Number of Inspectors

Motivation:

- The conditional association between algorithm selection and number of inspectors remains important.
- Need to understand whether it comes from broad distributional shifts, tails, or particular cells.

Tasks for review:

- Define the exact number-of-inspectors outcome used in the current regression table.
- Residualize number of inspectors on all non-method controls used in that regression.
- Plot the distribution of residualized number of inspectors separately for algorithm-selected and inspector-selected cases.
- Plot the raw distribution of number of inspectors separately for algorithm-selected and inspector-selected cases.
- Compare means, medians, upper tails, and mass points by selection method.
- Check whether the residual gap is concentrated by year, center, audit type, predicted-evasion bin, or LTU/MTO status.

Suggested figures / diagnostics:

- Histogram or density of raw number of inspectors by method.
- Histogram or density of residualized number of inspectors by method.
- Binned residual means by predicted-evasion bin and method.
- Simple balance table showing raw and residualized number of inspectors by method.

Review questions:

- Is the algorithm association with number of inspectors a mean shift or a tail phenomenon?
- Does it survive within predicted-evasion bins?
- Does it reflect specific years, centers, or taxpayer groups?

## 5) Interpretation and Narrative Checks

Anne's draft interpretation:

- "Two thirds of the gap in execution can be explained by predicted evasion."
- The remaining gap could be due to predictive-model specification or possibly lower effort.

Tasks for review:

- Quantify the execution-gap decomposition consistently across specifications.
- Verify whether "two thirds" refers to the drop in the algorithm coefficient, the difference in means, or another comparison.
- Separate language about prediction-control limitations from language about potential effort differences.
- Avoid implying that residual associations are causal without additional evidence.

Technical reasons to document:

- The prediction model may not be flexible enough as currently controlled.
- The training sample is selected.
- Prediction quality may vary across years, taxpayer segments, and the top of the distribution.
- Predicted evasion may be measured with error, leaving residual selection differences.

## 6) Validation Checklist Before Any Future Edits

Before changing analysis outputs:

- Identify the exact do-files and output tables affected.
- Confirm current baseline coefficients and sample sizes.
- Confirm bin definitions and counts before running regressions.
- Keep all new output names descriptive and separate from current manuscript-facing tables unless replacement is intended.
- Update table notes if the control specification or sample changes.
- Update `SESSION_NOTES.MD` after implementation and validation.

## 7) Proposed Task Order

1. Map current predicted-evasion-control tables and inspector-effort tables to their do-files and outputs.
2. Add bin-count diagnostics for 10, 15, 20, and split-top-bin variants.
3. Run flexible-bin robustness tables if bin counts are adequate.
4. Run 2018-2019 and LTU/MTO subsample versions.
5. Build raw and residualized number-of-inspectors distribution diagnostics.
6. Summarize what share of the execution gap is explained under each specification.
7. Decide which results are robust enough for manuscript or appendix use.
