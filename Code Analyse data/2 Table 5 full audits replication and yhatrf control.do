*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         March 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the full-audit version of Table 5 from
* "2 Regressions main results.do" and then re-estimates the same table
* adding predicted evasion (yhatrf) as a control.

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

global ados "$rootdir\Analysis all data\replication_package\ado"
global rawdata "$rootdir"
global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
global output "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
	global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
}

global table5_inputdata "$analysisdata\fullaudits_predicted.dta"

************************************************************
* Shared table metadata
************************************************************
local main_models "ry16 rq30 ry19 ry8 revasion_cost1 revasion_cost2 revasion_cost3 revasion_cost4"
local avail_models "ravailable_y16 ravailable_q30 ravailable_y19 ravailable_y8 ravailable_evasion_cost1 ravailable_evasion_cost2 ravailable_evasion_cost3 ravailable_evasion_cost4"

local raw_main_replicated "$output\1 regression cost and resources summarized full audits replicated.tex"
local raw_avail_replicated "$output\1 regression cost and resources summarized availability full audits replicated.tex"
local raw_main_yhatrf "$output\1 regression cost and resources summarized full audits yhatrf control.tex"
local raw_avail_yhatrf "$output\1 regression cost and resources summarized availability full audits yhatrf control.tex"

local body_replicated "$output\table5_fullaudits_replicated_body.tex"
local body_yhatrf "$output\table5_fullaudits_yhatrf_control_body.tex"

local snippet_replicated "$output\table5_fullaudits_replicated_snippets.tex"
local snippet_yhatrf "$output\table5_fullaudits_yhatrf_control_snippets.tex"

local panel_a_titles `"\multicolumn{1}{l}{} & \shortstack{Number of Agents} & \shortstack{Duration in Days\\(Taxpayer Survey)} & \shortstack{Days from Start to Conf.\\(Admin Data)} & \shortstack{Days Working on Case\\(Self-Reported)} & \shortstack{Evasion/ Number of\\Agents} & \shortstack{Evasion/Duration\\(Taxpayer Survey)} & \shortstack{Evasion/Duration\\(Admin. Data)} & \shortstack{Evasion/Days Working\\(Self-Reported)} \\"'
local panel_numbers `"\multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"'

************************************************************
* Helper: write manuscript-ready wrapper
************************************************************
capture program drop write_table5_wrapper
program define write_table5_wrapper
	syntax , USING(string) BODY(string) CAPTION(string) LABEL(string) NOTES(string)

	tempname fh
	file open `fh' using `"`using'"', write replace
	file write `fh' "\begin{table}[H]\centering" _n
	file write `fh' "\begin{threeparttable}" _n
	file write `fh' "\caption{`caption'}" _n
	file write `fh' "\label{`label'}" _n
	file write `fh' "" _n
	file write `fh' "\footnotesize" _n
	file write `fh' "\input{Output/`body'}" _n
	file write `fh' "" _n
	file write `fh' "\begin{tablenotes}[flushleft]" _n
	file write `fh' "\footnotesize" _n
	file write `fh' "\item Notes: `notes'" _n
	file write `fh' "\end{tablenotes}" _n
	file write `fh' "\end{threeparttable}" _n
	file write `fh' "\end{table}" _n
	file close `fh'
end

************************************************************
* Helper: build and export one table version
************************************************************
capture program drop build_table5_version
program define build_table5_version
	syntax , VERSION(string) CONTROLS(string) RAWMAIN(string) RAWAVAIL(string) BODYOUT(string)

	local panel_a_titles `"\multicolumn{1}{l}{} & \shortstack{Number of Agents} & \shortstack{Duration in Days\\(Taxpayer Survey)} & \shortstack{Days from Start to Conf.\\(Admin Data)} & \shortstack{Days Working on Case\\(Self-Reported)} & \shortstack{Evasion/ Number of\\Agents} & \shortstack{Evasion/Duration\\(Taxpayer Survey)} & \shortstack{Evasion/Duration\\(Admin. Data)} & \shortstack{Evasion/Days Working\\(Self-Reported)} \\"'
	local panel_numbers `"\multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"'

	use "$table5_inputdata", clear

	* Match the original full-audit Table 5 sample definition.
	keep if selection == 1
	drop if safeties == 1
	keep if x2 == 1

	capture confirm variable yhatrf
	if _rc {
		di as error "Variable yhatrf not found in $table5_inputdata."
		exit 111
	}

	estimates drop _all

	* Rebuild the original duration definitions and date-availability controls
	* from 2 Regressions main results.do before estimating Table 5.
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

	* Outcome-availability indicators from the original table block.
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

	local base_controls "`controls'"
	if "`base_controls'" == "none" {
		local base_controls ""
	}

	local main_estlist ""
	local avail_estlist ""
	local colindex = 0

	foreach outcome in y16 q30 y19 y8 evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
		local ++colindex
		local rhs_controls "`base_controls'"

		replace available_`outcome' = . if y2 == 0

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

		eststo a`colindex'_`version': reghdfe available_`outcome' algorithm overlap random safeties `rhs_controls', ///
			a(inspectorclusteryear) vce(robust)
		local avail_estlist "`avail_estlist' a`colindex'_`version'"

		quietly summarize available_`outcome' if e(sample) == 1
		estadd local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome = int(100 * `r(mean)') / 100
		local meanoutcome : display %5.2f `meanoutcome'
		estadd local pp `meanoutcome'
		test algorithm == safeties
		local pvalue : display %5.2f `r(p)'
		estadd local pvalue = round(`pvalue', 0.01)
		estadd local N = e(N), replace

		* Column 1 availability is mechanically one for executed full audits in the source table.
		if "`outcome'" == "y16" {
			estadd local N "", replace
			estadd local r2 "", replace
		}
	}

	************************************************************
	* Raw fragments
	************************************************************
	#delim ;
	esttab `main_estlist'
		using `"`rawmain'"',
		replace fragment booktabs
		order(algorithm overlap)
		label se keep(algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome"))
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm")
		substitute(\_ _)
	;
	#delim cr

	#delim ;
	esttab `avail_estlist'
		using `"`rawavail'"',
		replace fragment booktabs
		order(algorithm overlap)
		label se keep(algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome"))
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm")
		substitute(\_ _)
	;
	#delim cr

	************************************************************
	* Combined panel fragment for the manuscript wrapper
	************************************************************
	#delim ;
	esttab `main_estlist'
		using `"`bodyout'"',
		replace fragment booktabs
		prehead("\begin{tabular}{lcccc|cccc} \toprule")
		posthead("`panel_a_titles' `panel_numbers' \midrule")
		postfoot("")
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

	#delim ;
	esttab `avail_estlist'
		using `"`bodyout'"',
		append fragment booktabs
		prehead("\midrule")
		posthead("`panel_numbers' \midrule")
		postfoot("\bottomrule \end{tabular}")
		order(algorithm overlap)
		keep(algorithm overlap)
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm")
		mgroups("A2: Data Availability for Resource Outcomes" "B2: Data Availability for Productivity Outcomes",
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
end

************************************************************
* Baseline replication
************************************************************
build_table5_version, ///
	version(replicated) ///
	controls(none) ///
	rawmain(`"`raw_main_replicated'"') ///
	rawavail(`"`raw_avail_replicated'"') ///
	bodyout(`"`body_replicated'"')

local notes_replicated "This table replicates the full-audit version of Table 5 using the source-code specification in 2 Regressions main results.do. Panel A reports resource and productivity outcomes; Panel B reports the corresponding data-availability outcomes. The sample includes selected full audits and excludes safety cases. Column 1 reports the number of agents recorded on the case. Column 2 uses the taxpayer-survey duration measure. Column 3 uses the administrative measure of days from the start of the audit to confirmation and includes the original date-availability controls dummy1 to dummy3. Column 4 uses inspectors' self-reported days worked on the case. Columns 5 to 8 use the log of evasion divided by the corresponding resource measure. All regressions include Algorithm, Inspectors x Overlap, Random, and Replacement indicators and absorb inspectorclusteryear fixed effects. Robust standard errors are shown in parentheses. Stars denote significance at * p<0.10, ** p<0.05, *** p<0.01."

write_table5_wrapper, ///
	using(`"`snippet_replicated'"') ///
	body("table5_fullaudits_replicated_body.tex") ///
	caption("Table 5: Resources Allocated to Audits and Audit Productivity, Full Audits") ///
	label("tab:table5_fullaudits_replicated") ///
	notes(`"`notes_replicated'"')

************************************************************
* Replication with predicted evasion control
************************************************************
build_table5_version, ///
	version(yhatrf) ///
	controls(yhatrf) ///
	rawmain(`"`raw_main_yhatrf'"') ///
	rawavail(`"`raw_avail_yhatrf'"') ///
	bodyout(`"`body_yhatrf'"')

local notes_yhatrf "This table reproduces the full-audit Table 5 specification and additionally controls for predicted evasion measured by yhatrf. Panel A reports resource and productivity outcomes; Panel B reports the corresponding data-availability outcomes. The sample includes selected full audits and excludes safety cases. Column 1 reports the number of agents recorded on the case. Column 2 uses the taxpayer-survey duration measure. Column 3 uses the administrative measure of days from the start of the audit to confirmation and includes the original date-availability controls dummy1 to dummy3. Column 4 uses inspectors' self-reported days worked on the case. Columns 5 to 8 use the log of evasion divided by the corresponding resource measure. All regressions include Algorithm, Inspectors x Overlap, Random, Replacement, and yhatrf and absorb inspectorclusteryear fixed effects. Robust standard errors are shown in parentheses. Stars denote significance at * p<0.10, ** p<0.05, *** p<0.01."

write_table5_wrapper, ///
	using(`"`snippet_yhatrf'"') ///
	body("table5_fullaudits_yhatrf_control_body.tex") ///
	caption("Table 5: Resources Allocated to Audits and Audit Productivity, Full Audits, with Predicted Evasion Control") ///
	label("tab:table5_fullaudits_yhatrf_control") ///
	notes(`"`notes_yhatrf'"')
