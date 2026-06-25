*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         June 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This wrapper runs the list-level above-median target diagnostic with
* 0.05-wide predicted-probability bins. The list target is type-specific in
* the R export: bureau_detailed x selectionyear for full audits and
* inspectorclusteryear for desk audits. The Figure 4 replicate remains
* full-audit only, matching the existing Figure 4 diagnostics.

version 17
set more off

global figure4_binprob_input "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output\figure4_binprob_decile_fullaudits_c1_listyear.dta"
global figure4_bin_width "0.05"
global figure4_bin_count "20"
global figure4_bin_tag "fixed005"
global figure4_suffix "listyear_target"
global figure4_xtitle "Predicted probability of above-median evasion (list target)"

do "Code Analyse data\6 Figure 4 bin probability fixed010 office-target panels.do"

macro drop figure4_binprob_input
macro drop figure4_bin_width
macro drop figure4_bin_count
macro drop figure4_bin_tag
macro drop figure4_suffix
macro drop figure4_xtitle
