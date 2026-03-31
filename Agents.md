Important: after completing any non-trivial edit, update `SESSION_NOTES.md` with a concise record of what changed, why, which outputs were affected, and whether validation succeeded.

# AGENTS.md

## Project scope

This repository supports the Senegal tax audit project and related replication / revision tasks.
Most work is empirical research support in Stata, with LaTeX outputs for tables, notes, and manuscript sections.

The assistant should prioritize:
- clear Stata code that follows standard Stata logic,
- reproducible workflows,
- LaTeX (`.tex`) tables and write-ups rather than CSV/TXT outputs when results are meant for the paper or appendix,
- conservative, transparent edits that preserve the paper’s existing structure and variable logic unless explicitly asked to change them.

## Core principles

1. **Follow Stata logic**
   - Write code in a way that a human RA using Stata can easily read, debug, and extend.
   - Prefer explicit variable creation, clear sample restrictions, and step-by-step transformations.
   - Avoid unnecessarily clever or overly compressed code.
   - Use informative comments to explain the purpose of each block.

2. **Preserve research integrity**
   - Do not silently change sample definitions, treatment definitions, fixed effects, clustering, or outcome construction.
   - If a requested edit changes the estimand or sample, flag it clearly in comments and in the session notes.
   - Keep variable definitions consistent with the current paper and notes unless the task explicitly requires an update.

3. **Prefer minimal, targeted edits**
   - Change only the necessary lines.
   - Reuse existing globals, locals, folder conventions, and table styles when possible.
   - Do not rename files, variables, or outputs unless necessary.

4. **Use LaTeX outputs for results**
   - Prefer `.tex` tables via `esttab`, `estout`, `estpost`, or manually written LaTeX fragments when appropriate.
   - If a result belongs in the manuscript or appendix, export it as `.tex`.
   - Figures should be exported in publication-friendly formats already used in the repo, typically `.pdf`.

5. **Keep a written record of work**
   - After substantial edits, update `SESSION_NOTES.md`.
   - Record what changed, why it changed, key assumptions, output files created/updated, and validation status.

## Stata coding style

### General style
- Use section headers with comments:
  - `*------------------------------------------------------------*`
  - `* 1. Build sample`
  - `*------------------------------------------------------------*`
- Keep one logical task per block:
  - sample construction,
  - variable construction,
  - descriptives,
  - regressions,
  - exports,
  - validation.
- Use readable local macros when they improve clarity.
- Avoid deeply nested code unless required.
- Do not collapse many operations into one line if that hurts readability.

### Variable construction
- Build derived variables explicitly with comments.
- Label newly created variables when useful.
- When replacing an old definition with a new one, keep the old version commented only if it helps trace the change; otherwise remove dead code to avoid confusion.
- If a variable definition is conceptually important, document it both in the do-file comments and in `SESSION_NOTES.md`.

### Regressions
- Keep regression specifications easy to inspect.
- Separate:
  - outcome definition,
  - sample restriction,
  - RHS variable list,
  - absorbed fixed effects,
  - clustering / VCE choice.
- Prefer locals like:
  - `local rhs ...`
  - `local fe ...`
  - `local sample ...`
- Make panel/column loops readable and not overly abstract.

### Output and export
- TeX tables should have stable, descriptive file names.
- Do not overwrite unrelated outputs.
- Keep export paths consistent with the existing repo structure.
- If updating an existing output, preserve its role in the paper unless instructed otherwise.

## LaTeX / table conventions

- Default to `.tex` output for regression tables and summary tables used in the manuscript, appendix, or notes.
- Prefer professional table formatting consistent with the rest of the repo.
- Add or revise table notes when a variable definition, sample, or specification changes.
- If a section write-up exists, keep it synchronized with the active code and exported tables.

## Validation rules

Whenever possible, validate edits by running the narrowest relevant do-file or section of code.

Validation should check:
- code runs without syntax errors,
- expected number of regressions/tables is produced,
- output file names match the intended names,
- key sample counts or diagnostic displays remain sensible,
- notes and labels are consistent with the active variable definitions.

If full validation is not possible, state clearly:
- what was validated,
- what could not be validated,
- what the user should check next.

## Session documentation

Maintain a file named:

- `SESSION_NOTES.md`

Update it after meaningful work. Each entry should include:
- date,
- task,
- files edited,
- substantive changes,
- output files affected,
- validation performed,
- open issues / next steps.

## Preferred behavior for Codex

When editing this repo, Codex should:
- inspect existing do-files before rewriting patterns,
- preserve the current analytical workflow,
- prefer small diffs over broad rewrites,
- explain changes in research terms, not only coding terms,
- keep manuscript-facing outputs in TeX,
- update `SESSION_NOTES.md` after major edits.

## What to avoid

- Do not introduce Python/R workflows unless explicitly requested.
- Do not replace Stata logic with opaque abstractions.
- Do not export manuscript tables as CSV/TXT unless explicitly requested.
- Do not silently alter identification choices or sample restrictions.
- Do not create unnecessary duplicate files.
- Do not leave behind undocumented temporary outputs.

## Example repo-specific expectations

Typical project components may include:
- Stata analysis scripts in folders such as `Code Analyse data/`
- TeX section fragments used by the paper
- Output tables in `Output/`
- Figure exports in `Output/`

When working on tasks similar to discrepancy / inspector-effort analysis, keep code, TeX notes, and exported outputs synchronized.