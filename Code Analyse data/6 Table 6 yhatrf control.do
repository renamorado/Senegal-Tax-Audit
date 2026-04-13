*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         April 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the screenshot-style Table 6 index specifications from
* "3 Analysis taxpayer survey.do" and then re-estimates them adding predicted
* evasion (yhatrf) linearly and quadratically.

version 18
set more off
clear all
set scheme stcolor

global check = 1

*****************
** DIRECTORIES **
*****************
if strpos("`c(username)'","49354415") {
	global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
}
if strpos("`c(username)'","User") {
	global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}
if strpos("`c(username)'","wb648862") {
	global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}

global ados "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\ado"
global rawdata "$rootdir"
global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
global output "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
	global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
}

global table6_full_input "$analysisdata\fullaudits_predicted.dta"
global table6_desk_input "$analysisdata\deskaudits_predicted.dta"

local table_replicated "$output\table6_indices_replicated.tex"
local table_yhatrf "$output\table6_indices_yhatrf_control.tex"
local table_yhatrf_quadratic "$output\table6_indices_yhatrf_quadratic_control.tex"

************************************************************
* Shared table metadata
************************************************************
local panel_a_title `"\multicolumn{7}{l}{\textbf{A: Surveyed Firms (Self-Reporting a Recent Audit)}} \\"'
local panel_b_title `"\multicolumn{7}{l}{\textbf{B: Only Audited Firms (as per Administrative Audit Data)}} \\"'
local panel_outcomes `"\multicolumn{1}{l}{Outcome:} & \multicolumn{3}{c}{Efficiency Index} & \multicolumn{3}{c}{Corruption Index} \\"'
local panel_columns `"\multicolumn{1}{l}{} & Full Audits & Desk Audits & All Audits & Full Audits & Desk Audits & All Audits \\"'
local panel_numbers `"\multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) \\"'

************************************************************
* 1. Import predicted-audit data
************************************************************
use "$table6_full_input", clear
append using "$table6_desk_input"

capture confirm variable yhatrf
if _rc {
	di as error "Variable yhatrf not found after appending predicted-audit files."
	exit 111
}

************************************************************
* 2. Rebuild the original Table 6 survey-analysis sample
************************************************************
keep if selection == 1
drop if safeties == 1
keep if recent == selectionyear
drop recent

replace algorithm = 1 if random == 1

capture drop selfreported_audit
gen selfreported_audit = .
replace selfreported_audit = 0 if q1 != .
replace selfreported_audit = 1 if q28a >= 2018 & q28a <= 2021
replace selfreported_audit = 1 if q29a >= 2018 & q29a <= 2021

* Match the original taxpayer-survey index workflow: keep firms that either
* self-report a recent audit or have missing survey timing information.
drop if selfreported_audit == 0

* The original index construction was restricted to survey respondents.
drop if q1 == .

replace q34 = . if q34 > 0 & q34 < 1

capture drop q34_binary
gen q34_binary = .
replace q34_binary = 0 if q34 < 15
replace q34_binary = 1 if q34 >= 15 & q34 != .

capture drop q32_inverted
gen q32_inverted = .
replace q32_inverted = -1 * (q32 - 10) if q32 != .

capture which swindex
if _rc {
	di as error "swindex is not installed. Please run: ssc install swindex"
	exit 199
}

swindex q32_inverted q42 q34 if q1 != ., generate(index_corruption) fullrescale displayw
swindex q31 q33 q41 if q1 != ., generate(index_efficiency) fullrescale displayw

tempfile table6_prepared
save `table6_prepared', replace

************************************************************
* 3. Export baseline Table 6 replication
************************************************************
use `table6_prepared', clear
capture estimates drop _all

local spec_tag "replicated"
local extra_controls ""
local panel_a_models ""
local panel_b_models ""

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "selfreported_audit == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "r`outtag'A`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_a_models "`panel_a_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "y2 == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "r`outtag'B`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_b_models "`panel_b_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

#delim ;
esttab `panel_a_models'
	using `"`table_replicated'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lccc|ccc} \toprule")
	posthead("`panel_a_title' `panel_outcomes' `panel_columns' `panel_numbers' \midrule")
	postfoot("")
	order(algorithm overlap random)
	keep(algorithm overlap random)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

#delim ;
esttab `panel_b_models'
	using `"`table_replicated'"',
	append fragment booktabs
	prehead("\midrule `panel_b_title' `panel_numbers' \midrule")
	posthead("")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap random)
	keep(algorithm overlap random)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

************************************************************
* 4. Export Table 6 with yhatrf control
************************************************************
use `table6_prepared', clear
capture estimates drop _all

local spec_tag "yhatrf"
local extra_controls "yhatrf"
local panel_a_models ""
local panel_b_models ""

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "selfreported_audit == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "y`outtag'A`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_a_models "`panel_a_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "y2 == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "y`outtag'B`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_b_models "`panel_b_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

#delim ;
esttab `panel_a_models'
	using `"`table_yhatrf'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lccc|ccc} \toprule")
	posthead("`panel_a_title' `panel_outcomes' `panel_columns' `panel_numbers' \midrule")
	postfoot("")
	order(algorithm overlap random yhatrf)
	keep(algorithm overlap random yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" yhatrf "Predicted evasion")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

#delim ;
esttab `panel_b_models'
	using `"`table_yhatrf'"',
	append fragment booktabs
	prehead("\midrule `panel_b_title' `panel_numbers' \midrule")
	posthead("")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap random yhatrf)
	keep(algorithm overlap random yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" yhatrf "Predicted evasion")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

************************************************************
* 5. Export Table 6 with yhatrf and yhatrf^2
************************************************************
use `table6_prepared', clear
capture estimates drop _all

local spec_tag "yhatrf_quadratic"
local extra_controls "c.yhatrf##c.yhatrf"
local panel_a_models ""
local panel_b_models ""

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "selfreported_audit == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "q`outtag'A`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_a_models "`panel_a_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "y2 == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "q`outtag'B`col'"
		eststo `estname': reghdfe `outcome' algorithm overlap random safeties horsprogramme `extra_controls' if `sample_if', ///
			a(selectionyear center) vce(robust)
		local panel_b_models "`panel_b_models' `estname'"

		quietly summarize `outcome' if e(sample) == 1
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		estadd local N = e(N), replace
	}
}

#delim ;
esttab `panel_a_models'
	using `"`table_yhatrf_quadratic'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lccc|ccc} \toprule")
	posthead("`panel_a_title' `panel_outcomes' `panel_columns' `panel_numbers' \midrule")
	postfoot("")
	order(algorithm overlap random yhatrf c.yhatrf#c.yhatrf)
	keep(algorithm overlap random yhatrf c.yhatrf#c.yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" yhatrf "Predicted evasion" c.yhatrf#c.yhatrf "Predicted evasion squared")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

#delim ;
esttab `panel_b_models'
	using `"`table_yhatrf_quadratic'"',
	append fragment booktabs
	prehead("\midrule `panel_b_title' `panel_numbers' \midrule")
	posthead("")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap random yhatrf c.yhatrf#c.yhatrf)
	keep(algorithm overlap random yhatrf c.yhatrf#c.yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" yhatrf "Predicted evasion" c.yhatrf#c.yhatrf "Predicted evasion squared")
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

************************************************************
* 6. Light diagnostics
************************************************************
quietly count if selfreported_audit == 1
local n_panel_a = r(N)
quietly count if y2 == 1
local n_panel_b = r(N)

di as text "Panel A sample after prep: `n_panel_a'"
di as text "Panel B sample after prep: `n_panel_b'"
