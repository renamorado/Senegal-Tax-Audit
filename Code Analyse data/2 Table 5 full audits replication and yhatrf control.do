*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         March 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the top panels (A1 and B1) of the full-audit
* version of Table 5 from "2 Regressions main results.do" and then
* re-estimates the same table adding predicted evasion (yhatrf) as a
* control and as a quadratic robustness check.

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

global table5_inputdata "$analysisdata\fullaudits_predicted.dta"

************************************************************
* Shared table metadata
************************************************************
local table_replicated "$output\table5_fullaudits_replicated.tex"
local table_yhatrf "$output\table5_fullaudits_yhatrf_control.tex"
local table_yhatrf_quadratic "$output\table5_fullaudits_yhatrf_quadratic_control.tex"

local panel_a_titles `"\multicolumn{1}{l}{} & \shortstack{Number of Agents} & \shortstack{Duration in Days\\(Taxpayer Survey)} & \shortstack{Days from Start to Conf.\\(Admin Data)} & \shortstack{Days Working on Case\\(Self-Reported)} & \shortstack{Evasion/ Number of\\Agents} & \shortstack{Evasion/Duration\\(Taxpayer Survey)} & \shortstack{Evasion/Duration\\(Admin. Data)} & \shortstack{Evasion/Days Working\\(Self-Reported)} \\"'
local panel_numbers `"\multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"'

************************************************************
* 1. Import the data
************************************************************
use "$table5_inputdata", clear

************************************************************
* 2. Prepare the data
************************************************************
* Match the original full-audit Table 5 sample definition.
keep if selection == 1
drop if safeties == 1
keep if x2 == 1

capture confirm variable yhatrf
if _rc {
	di as error "Variable yhatrf not found in $table5_inputdata."
	exit 111
}

* Rebuild the original duration definitions and date-availability
* controls from 2 Regressions main results.do.
capture drop earliestdate
capture drop earliestdate2
capture drop earliestnotification

gen earliestdate = datededemarrage
foreach v in datedemanderenseignement datedavisdatededemandede s_date_demande_information dateavis s_date_avis {
	replace earliestdate = `v' if earliestdate == .
}

egen earliestdate2 = rowmin(datededemarrage datedemanderenseignement datedavisdatededemandede s_date_demande_information dateavis s_date_avis)
egen earliestnotification = rowmin(dateconfirmation datenotification)

forvalues x = 0/9 {
	capture drop time`x'
	capture drop dummy`x'
}

gen time0 = datenotification - earliestdate
replace time0 = dateconfirmation - earliestdate if time0 == .

gen time1 = datenotification - earliestdate2
gen time2 = dateconfirmation - earliestdate2

gen time3 = time1
replace time3 = time2 if time3 == .

gen time4 = datenotification - datededemarrage
replace time4 = datenotification - s_date_de_demarrage if time4 == .

gen time5 = dateconfirmation - datededemarrage
replace time5 = dateconfirmation - s_date_de_demarrage if time5 == .

egen time6 = rowmin(time4 time5)

gen time7 = datenotification - dateavis
replace time7 = datenotification - s_date_avis if time7 == .

gen time8 = dateconfirmation - dateavis
replace time8 = dateconfirmation - s_date_avis if time8 == .

egen time9 = rowmin(time7 time8)

forvalues x = 0/9 {
	replace time`x' = . if time`x' < 0

	quietly summarize time`x' if algorithm == 1, detail
	replace time`x' = `r(p99)' if time`x' > `r(p99)' & time`x' != . & algorithm == 1

	quietly summarize time`x' if algorithm == 0, detail
	replace time`x' = `r(p99)' if time`x' > `r(p99)' & time`x' != . & algorithm == 0

	gen dummy`x' = time`x' != .
}

* Outcome-availability indicators from the original Table 5 block.
foreach v in y16 y8 y19 q30 {
	capture drop available_`v'
	gen available_`v' = `v' != .
}

capture drop evasion_cost1
capture drop evasion_cost2
capture drop evasion_cost3
capture drop evasion_cost4
gen evasion_cost1 = log(evasionvalue / y16)
gen evasion_cost2 = log(evasionvalue / q30)
gen evasion_cost3 = log(evasionvalue / y19)
gen evasion_cost4 = log(evasionvalue / y8)

foreach v in evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
	capture drop available_`v'
	gen available_`v' = `v' != .
}

tempfile table5_prepared
save `table5_prepared', replace

************************************************************
* 3. Export Table 5 top panels: replicated specification
************************************************************
use `table5_prepared', clear
estimates drop _all

local version "replicated"
local base_controls ""
local main_estlist ""
local colindex = 0

foreach outcome in y16 q30 y19 y8 evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
	local ++colindex
	local rhs_controls "`base_controls'"

	if "`outcome'" != "q30" {
		replace `outcome' = . if y2 == 0
	}
	if "`outcome'" == "y19" {
		local rhs_controls "`rhs_controls' dummy1 dummy2 dummy3"
	}

	eststo m`colindex'_`version': reghdfe `outcome' algorithm overlap random safeties `rhs_controls', ///
		a(inspectorclusteryear) vce(robust)
	local main_estlist "`main_estlist' m`colindex'_`version'"

	quietly summarize `outcome' if e(sample) == 1
	estadd local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome : display %5.2f `meanoutcome'
	estadd local pp `meanoutcome'
	test algorithm == safeties
	local pvalue : display %5.2f `r(p)'
	estadd local pvalue = round(`pvalue', 0.01)
	estadd local N = e(N), replace
}

#delim ;
esttab `main_estlist'
	using `"`table_replicated'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lcccc|cccc} \toprule")
	posthead("`panel_a_titles' `panel_numbers' \midrule")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap)
	keep(algorithm overlap)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm")
	mgroups("A1: Resource Outcomes" "B1: Productivity Outcomes",
		pattern(1 0 0 0 1 0 0 0)
		span prefix(\multicolumn{@span}{c}{\textbf{) suffix(}})
		erepeat(\cmidrule(lr){@span}))
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

************************************************************
* 4. Export Table 5 top panels with yhatrf as a control
************************************************************
use `table5_prepared', clear
estimates drop _all

local version "yhatrf"
local base_controls "yhatrf"
local main_estlist ""
local colindex = 0

foreach outcome in y16 q30 y19 y8 evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
	local ++colindex
	local rhs_controls "`base_controls'"

	if "`outcome'" != "q30" {
		replace `outcome' = . if y2 == 0
	}
	if "`outcome'" == "y19" {
		local rhs_controls "`rhs_controls' dummy1 dummy2 dummy3"
	}

	eststo m`colindex'_`version': reghdfe `outcome' algorithm overlap random safeties `rhs_controls', ///
		a(inspectorclusteryear) vce(robust)
	local main_estlist "`main_estlist' m`colindex'_`version'"

	quietly summarize `outcome' if e(sample) == 1
	estadd local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome : display %5.2f `meanoutcome'
	estadd local pp `meanoutcome'
	test algorithm == safeties
	local pvalue : display %5.2f `r(p)'
	estadd local pvalue = round(`pvalue', 0.01)
	estadd local N = e(N), replace
}

#delim ;
esttab `main_estlist'
	using `"`table_yhatrf'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lcccc|cccc} \toprule")
	posthead("`panel_a_titles' `panel_numbers' \midrule")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap yhatrf)
	keep(algorithm overlap yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" yhatrf "Predicted evasion")
	mgroups("A1: Resource Outcomes" "B1: Productivity Outcomes",
		pattern(1 0 0 0 1 0 0 0)
		span prefix(\multicolumn{@span}{c}{\textbf{) suffix(}})
		erepeat(\cmidrule(lr){@span}))
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr

************************************************************
* 5. Export Table 5 top panels with yhatrf and yhatrf^2
************************************************************
use `table5_prepared', clear
estimates drop _all

local version "yhatrf_quadratic"
local base_controls "c.yhatrf##c.yhatrf"
local main_estlist ""
local colindex = 0

foreach outcome in y16 q30 y19 y8 evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
	local ++colindex
	local rhs_controls "`base_controls'"

	if "`outcome'" != "q30" {
		replace `outcome' = . if y2 == 0
	}
	if "`outcome'" == "y19" {
		local rhs_controls "`rhs_controls' dummy1 dummy2 dummy3"
	}

	eststo m`colindex'_`version': reghdfe `outcome' algorithm overlap random safeties `rhs_controls', ///
		a(inspectorclusteryear) vce(robust)
	local main_estlist "`main_estlist' m`colindex'_`version'"

	quietly summarize `outcome' if e(sample) == 1
	estadd local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome = int(100 * `r(mean)') / 100
	local meanoutcome : display %5.2f `meanoutcome'
	estadd local pp `meanoutcome'
	test algorithm == safeties
	local pvalue : display %5.2f `r(p)'
	estadd local pvalue = round(`pvalue', 0.01)
	estadd local N = e(N), replace
}

#delim ;
esttab `main_estlist'
	using `"`table_yhatrf_quadratic'"',
	replace fragment booktabs
	prehead("\begin{tabular}{lcccc|cccc} \toprule")
	posthead("`panel_a_titles' `panel_numbers' \midrule")
	postfoot("\bottomrule \end{tabular}")
	order(algorithm overlap yhatrf c.yhatrf#c.yhatrf)
	keep(algorithm overlap yhatrf c.yhatrf#c.yhatrf)
	coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" yhatrf "Predicted evasion" c.yhatrf#c.yhatrf "Predicted evasion squared")
	mgroups("A1: Resource Outcomes" "B1: Productivity Outcomes",
		pattern(1 0 0 0 1 0 0 0)
		span prefix(\multicolumn{@span}{c}{\textbf{) suffix(}})
		erepeat(\cmidrule(lr){@span}))
	b(%5.2f) se(%5.2f)
	stats(N r2 pp, labels("N" "R2" "Mean outcome"))
	star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
	nomtitles nonumbers collabels(none) nonotes
	substitute(\_ _)
;
#delim cr
