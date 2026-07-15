*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         June 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This wrapper runs the office-pooled above-median target diagnostic with
* 0.05-wide predicted-probability bins.

version 17
set more off

global figure4_bin_width "0.05"
global figure4_bin_count "20"
global figure4_bin_tag "fixed005"

do "Code Analyse data\6 Figure 4 bin probability fixed010 office-target panels.do"

macro drop figure4_bin_width
macro drop figure4_bin_count
macro drop figure4_bin_tag
