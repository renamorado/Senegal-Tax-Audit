---
title: Predicting Tail Bins Instead of Ranks
type: brainstorm
status: draft
date: 2026-05-25
---

# Predicting Tail Bins Instead of Ranks

## Context

Anne and Roldan have been discussing whether the prediction exercise should move from predicted evasion amounts to predicted ranks. The rank framing is attractive because the optimization problem is fundamentally about ordering cases within an audit list, not forecasting the exact FCFA amount of detected evasion.

The current concern is that the rank-based Figure 4 diagnostics are less visually striking than the amount-based Figure 4: execution does not rise as sharply with predicted evasion priority. Alipio suggested a related but distinct framing: instead of predicting the full rank of each case, predict whether a case belongs to a high-evasion bin, such as the top 10 percent of realized evasion within its list.

This note records the conceptual discussion and a possible implementation path. It does not make code changes or change any output.

## Key Distinction

"Predicting bins" can mean two different things:

1. **Post-prediction binning:** predict an amount or rank first, then group the predicted score into deciles, quintiles, top 10 percent, or top quartile indicators.
2. **Direct bin-target prediction:** define the outcome itself as membership in a high-realized-evasion bin, then train the model to predict the probability that a case is in that bin.

The first version is already close to what the current rank-decile Figure 4 and control-table diagnostics do. The second version is the more substantive new idea.

**Selected version for the next pass:** use direct bin-target prediction. The outcome should be a realized high-evasion-bin indicator, and the prediction should be the estimated probability that a selected case belongs to that bin.

## Why Direct Bin Prediction Could Make Sense

Directly predicting a top bin may better match the research question if the relevant administrative margin is not "how precisely can we order all firms?" but "can the algorithm identify the cases most likely to be among the high-evasion cases?"

This framing has several advantages:

- It focuses the prediction target on the tail of the distribution, where the policy value is highest.
- It avoids asking the model to learn fine distinctions among middle- and low-evasion cases that may be noisy or irrelevant for assignment.
- It may be less sensitive to extreme realized `y4` values than amount prediction.
- It gives a probability-like score, such as predicted probability of being in the top 10 percent, which may be easier to interpret than an inverted rank.
- It could restore a sharper Figure 4-style gradient if execution decisions are especially responsive to broad high-risk categories rather than precise rank order.

The strongest narrative version is: "We ask whether inspectors execute cases that the model classifies as likely high-evasion cases." That is cleaner than asking whether execution increases with the model's predicted full rank when full ranks are mechanically list-relative and visually hard to interpret.

## Main Risks

The bin target also has costs, and they are not just technical.

- It discards information below the threshold. A case just below the top 10 percent is coded the same as a case at the bottom.
- The top 10 percent may be thin in small bureau-year lists. Some lists may only contribute one positive case, which makes the target noisy.
- The cutoff can be unstable when realized evasion is bunched or tied.
- A classifier may produce a useful tail probability but still be poorly calibrated.
- If the audited training sample is selected, the same selection problem remains: we only observe realized evasion for executed cases.
- A sharper Figure 4 would not automatically prove better prediction. It could partly reflect a target that is closer to the execution rule or to list construction.

For that reason, the bin exercise should be presented as a robustness and interpretation check, not as an automatic replacement for amount or rank prediction.

## Candidate Target Definitions

The most natural target is list-relative, matching the rank work:

- **Top 10 percent within list:** among executed full audits with nonmissing `y4`, define a case as positive if its realized evasion rank is in the top 10 percent of its `bureau_detailed x selectionyear` list.
- **Top quintile within list:** same idea, but top 20 percent. This is likely more stable in small lists.
- **Top quartile within list:** a still coarser target that may be preferable if some office-year lists are too small to support quintiles cleanly.
- **Hybrid top bin:** define high evasion as top 10 percent where list support is large enough, otherwise top quintile or top 2 cases. This may improve support, but the changing rule is harder to explain.

My recommended first pass is to let support guide the primary bin definition. Because the number of audit cases varies across detailed-tax-office-by-year lists, the bin set should be no finer than what the smallest usable lists can support. Practically, that means checking deciles, quintiles, and quartiles, then choosing the finest grouping that leaves meaningful support in every included list. The top 10 percent may be too thin; quintiles may work; quartiles may be the conservative option if some lists are small.

The report should include a small support diagnostic for the chosen binning rule:

- minimum and maximum number of cases per bin across lists;
- minimum and maximum number of executed cases per bin across lists, if the target is defined among executed audits;
- number of lists with empty or singleton bins;
- number of lists excluded or pooled because support is insufficient.

This support table would help justify the bin definition before interpreting any Figure 4-style gradient.

## How It Would Fit With Existing Outputs

This should be kept separate from the existing predicted-amount and predicted-rank files.

Possible new prediction files:

- `Working Data/fullaudits_predicted_top10_bureauyear.dta`
- `Working Data/fullaudits_predicted_topquintile_bureauyear.dta`

Each file should include:

- the realized bin target for executed cases;
- the predicted probability of top-bin membership;
- within-list predicted probability rank or percentile;
- top predicted-probability indicators, such as top 10 percent and top quartile;
- enough variables to reproduce the selected non-safety full-audit sample.

For Figure 4-style diagnostics, the x-axis should probably be predicted probability of top-bin membership or deciles of that probability, not the predicted binary class. The binary class would be too coarse and model-threshold dependent.

For controls, the clean comparison would be:

- original Table 4 Column 1;
- amount-prediction controls;
- rank-prediction controls;
- direct top-bin probability controls;
- direct top-bin decile controls or top-probability indicators.

## Table 48-Style Optimization Table

It makes sense to generate a Table 48-style optimization table with the direct bin-target prediction, but the table should not include every possible variation of bin definition and prediction setup. The current Table 48 structure is already doing something useful: Panel A varies the amount-prediction benchmark, while Panel B changes the optimized ranking rule to predicted rank and keeps amount-based valuation. The bin-prediction version should follow that same logic.

Recommended structure:

- **Panel A:** keep the existing amount-prediction optimized-selection scenarios.
- **Panel B:** keep the existing predicted-rank optimized-selection scenarios.
- **Panel C:** add direct bin-target optimized selection, where cases are ranked by predicted probability of belonging to the high-realized-evasion bin.

**Selected Table 48-style design:** add Panel C and use a one-step direct bin classifier for the optimized ranking. Do not add a two-step bin-prediction version in the first implementation.

Panel C should report the same two columns as Panel B:

- gain in predicted revenue relative to the realized audit program;
- overlap between the bin-probability optimized program and the realized audit program.

The gain should still be valued using the matched amount-prediction model from Panel A. In other words, the bin classifier should determine which cases are selected for the optimized program, but the revenue gain should remain an amount-based quantity. This keeps Panel C comparable to Panel B and avoids interpreting a probability of top-bin membership as revenue.

A clean paired design would be:

- **C1:** direct bin-target selection, valued with A1 amount prediction, all cases.
- **C2:** direct bin-target selection, valued with A2 amount prediction, after the same top-five realized-case exclusion.
- **C3:** direct bin-target selection, valued with A3 amount prediction, after the same top-five realized-case exclusion.

This mirrors the existing B1--B3 design. C2 and C3 may use the same bin-probability ranking if the bin classifier is the same after the top-five exclusion; they would still differ in gains because the valuation model differs. That is acceptable as long as the table note states it clearly.

The main thing to avoid is a full cross of:

- top 10 percent vs quintile vs quartile targets;
- all cases vs top-five-excluded samples;
- weighted vs unweighted amount-prediction valuation;
- full audits vs desk audits;
- amount vs rank vs bin optimized selection.

That would answer too many questions at once and make the table hard to interpret. The better sequence is:

1. Use a support table to select one primary bin target.
2. Build one Panel C using that target.
3. If the choice between quintiles and quartiles is substantively important, put alternative-bin versions in a diagnostic appendix or a separate sensitivity table, not in the main Table 48-style comparison.

## One-Step Versus Two-Step Bin Prediction

The baseline bin-prediction exercise should be a one-step classifier:

- define high-realized-evasion-bin membership among executed audits with observed `y4`;
- train the model to predict that bin indicator directly;
- use the predicted probability of high-bin membership to rank cases for optimized selection.

This is closest to the research question: can the model identify cases likely to be high evasion cases? It also avoids blending the prediction target with inspectors' historical execution choices. In the Table 48-style optimization exercise, the optimized program already fixes the number of executed audits within each tax-office-by-year list to match the realized implementation, so predicting historical execution as a first stage would be conceptually awkward and could mechanically import the behavior we are trying to study.

A two-step version could still be useful, but it should be treated as a sensitivity rather than the baseline. The appropriate first stage would not be "probability of execution" unless the estimand is explicitly about expected implemented revenue under historical execution behavior. More defensible two-step variants would be:

- probability of detecting any evasion, then probability of being in the high-evasion bin conditional on detection;
- probability of being audit-eligible or having nonmissing realized evasion, if missingness/support becomes a concern.

For the current Table 48-style comparison, the cleanest design is therefore:

- one-step bin classifier for optimized ranking;
- amount-prediction model from the matched A scenario for valuing revenue gains;
- optional two-step bin classifier only as a later robustness check if the one-step diagnostics look promising.

**Selected baseline:** one-step bin classifier only. Two-step bin prediction remains outside the first implementation.

## Suggested Diagnostic Sequence

Before changing manuscript-facing outputs, run the idea as a diagnostic package:

1. Define realized top-bin targets within `bureau_detailed x selectionyear` among executed full audits with observed `y4`.
2. Compare candidate bin sets, such as deciles, quintiles, and quartiles, and select the finest grouping with acceptable support in every included list.
3. Report support by list and bin: list size, minimum and maximum cases per bin, number of positive cases, empty or singleton bins, and whether the target is usable.
4. Train a one-step classifier using the same predictor set as the unweighted RF prediction work.
5. Predict top-bin probabilities for all selected non-safety full-audit cases.
6. Plot Figure 4-style execution rates by predicted top-bin probability decile or by the chosen support-safe bin grouping.
7. Compare prediction quality with amount and rank targets using tail-focused metrics:
   - AUC for top-bin membership;
   - average realized `y4` in the top predicted decile;
   - top-decile lift relative to the rest of the sample;
   - execution rate gradient by predicted top-bin probability decile.
8. Build a Table 48-style Panel C only for the selected primary bin target, valuing gains with the matched amount-prediction model.
9. Add a compact Table 4 Column 1 control comparison only if the diagnostics look interpretable.

## Interpretation Guardrails

If the bin target looks better, the interpretation should be narrow:

- Good: "The model is more useful for identifying broad high-evasion groups than for predicting exact amounts or full within-list ranks."
- Good: "Execution appears more closely related to high-risk classification than to precise rank position."
- Risky: "Bin prediction proves the algorithm predicts evasion better."
- Risky: "A sharper Figure 4 means the rank exercise failed."

If the bin target does not look better, that is still informative. It would suggest the weaker rank-based Figure 4 is not just an artifact of plotting ranks; execution may genuinely not be strongly monotone in the model's list-relative predicted priority.

## Recommendation

This makes sense as the next diagnostic because it tests a middle ground between amount prediction and full rank prediction. It preserves the policy-relevant idea of list-relative prioritization while asking a less brittle question than "can the model order every case?"

The best next step is not to replace the current rank exercise immediately. It is to create a small, separate direct bin-target prediction diagnostic, first measuring list-level support for deciles, quintiles, and quartiles, then estimating the finest support-safe high-evasion-bin target and deciding based on prediction quality and Figure 4-style gradients.

## Open Questions

- What support rule should determine the high-evasion-bin target: top 10 percent, top quintile, top quartile, or the finest grouping that clears a pre-specified minimum cases-per-bin threshold?
- What is the finest bin set that guarantees meaningful support in all included office-year lists: deciles, quintiles, quartiles, or something coarser?
- Should bins be defined within `bureau_detailed x selectionyear`, or should the list also include audit type where needed for comparability?
- Should lists with too few executed cases be excluded from classifier training, assigned a fallback top-bin rule, or pooled into a broader office-year group?
- Should the Table 48-style bin-prediction exercise be added as Panel C beside the existing amount and rank panels, or exported as a companion table if the combined table becomes too wide?
- If the one-step Panel C is promising, should a two-step detection-gated bin-prediction version be added later as a sensitivity?
- Should the paper present this as a main prediction framing, an appendix robustness check, or an internal diagnostic only?
- If top-bin prediction produces a sharper Figure 4, what result would be strong enough to justify moving away from the rank framing?
