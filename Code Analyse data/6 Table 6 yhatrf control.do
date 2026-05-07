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
* evasion (yhatrf) linearly, quadratically, and via grouped-bin controls.

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
local table_yhatrf_deciles "$output\table6_indices_yhatrf_deciles_control.tex"
local table_yhatrf_quintiles "$output\table6_indices_yhatrf_quintiles_control.tex"
local table_yhatrf_bin15 "$output\table6_indices_yhatrf_15bins_control.tex"
local table_yhatrf_bin20 "$output\table6_indices_yhatrf_20bins_control.tex"
local table_yhatrf_bin40 "$output\table6_indices_yhatrf_40bins_control.tex"
local table_yhatrf_bin50 "$output\table6_indices_yhatrf_50bins_control.tex"
local table_yhatrf_topsplit "$output\table6_indices_yhatrf_topsplit_control.tex"
local table_yhatrf_bin_support "$output\table6_indices_yhatrf_bin_support.tex"

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

capture drop yhatrf_decile
capture drop yhatrf_quintile
capture drop yhatrf_bin15
capture drop yhatrf_bin20
capture drop yhatrf_bin40
capture drop yhatrf_bin50
capture drop yhatrf_decile_topsplit
capture drop yhatrf_decile9_half
capture drop yhatrf_decile10_half
capture drop table6_fe_center_year

* Build grouped predicted-evasion controls within the center/year FE used by
* the Table 6 survey regressions.
egen table6_fe_center_year = group(center selectionyear), missing
egen yhatrf_decile = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(10)
egen yhatrf_quintile = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(5)
egen yhatrf_bin15 = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(15)
egen yhatrf_bin20 = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(20)
egen yhatrf_bin40 = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(40)
egen yhatrf_bin50 = xtile(yhatrf) if yhatrf != ., by(table6_fe_center_year) nq(50)

gen yhatrf_decile_topsplit = yhatrf_decile
egen yhatrf_decile9_half = xtile(yhatrf) if yhatrf_decile == 9, by(table6_fe_center_year) nq(2)
egen yhatrf_decile10_half = xtile(yhatrf) if yhatrf_decile == 10, by(table6_fe_center_year) nq(2)
replace yhatrf_decile_topsplit = 9 if yhatrf_decile == 9 & yhatrf_decile9_half == 1
replace yhatrf_decile_topsplit = 10 if yhatrf_decile == 9 & yhatrf_decile9_half == 2
replace yhatrf_decile_topsplit = 11 if yhatrf_decile == 10 & yhatrf_decile10_half == 1
replace yhatrf_decile_topsplit = 12 if yhatrf_decile == 10 & yhatrf_decile10_half == 2
drop yhatrf_decile9_half yhatrf_decile10_half

file open support using `"`table_yhatrf_bin_support'"', write replace
file write support "\begin{tabular}{llrrrrrc}" _n
file write support "\toprule" _n
file write support "Specification & Sample & FE strata & Cells & Total N & Algorithm N & Inspector N & Both methods \\" _n
file write support "\midrule" _n
foreach spec in deciles quintiles bin15 bin20 bin40 bin50 topsplit {
	if "`spec'" == "deciles" {
		local binvar "yhatrf_decile"
		local speclabel "Deciles"
	}
	if "`spec'" == "quintiles" {
		local binvar "yhatrf_quintile"
		local speclabel "Quintiles"
	}
	if "`spec'" == "bin15" {
		local binvar "yhatrf_bin15"
		local speclabel "15 bins"
	}
	if "`spec'" == "bin20" {
		local binvar "yhatrf_bin20"
		local speclabel "20 bins"
	}
	if "`spec'" == "bin40" {
		local binvar "yhatrf_bin40"
		local speclabel "40 bins"
	}
	if "`spec'" == "bin50" {
		local binvar "yhatrf_bin50"
		local speclabel "50 bins"
	}
	if "`spec'" == "topsplit" {
		local binvar "yhatrf_decile_topsplit"
		local speclabel "Top-split deciles"
	}
	forvalues group = 1/6 {
		local sample_if "selfreported_audit == 1 & x2 == 1"
		local sample_label "Panel A full"
		if `group' == 2 {
			local sample_if "selfreported_audit == 1 & x2 == 0"
			local sample_label "Panel A desk"
		}
		if `group' == 3 {
			local sample_if "selfreported_audit == 1"
			local sample_label "Panel A all"
		}
		if `group' == 4 {
			local sample_if "y2 == 1 & x2 == 1"
			local sample_label "Panel B full"
		}
		if `group' == 5 {
			local sample_if "y2 == 1 & x2 == 0"
			local sample_label "Panel B desk"
		}
		if `group' == 6 {
			local sample_if "y2 == 1"
			local sample_label "Panel B all"
		}

		capture drop support_stratum_tag support_cell
		egen support_stratum_tag = tag(table6_fe_center_year) if `sample_if' & `binvar' != .
		egen support_cell = group(table6_fe_center_year `binvar') if `sample_if' & `binvar' != .
		quietly count if support_stratum_tag == 1
		local strata_n = r(N)
		quietly levelsof support_cell if support_cell != ., local(support_cells)
		local cell_n : word count `support_cells'
		quietly count if `sample_if' & `binvar' != .
		local total_n = r(N)
		quietly count if `sample_if' & `binvar' != . & algorithm == 1
		local alg_n = r(N)
		quietly count if `sample_if' & `binvar' != . & algorithm == 0
		local insp_n = r(N)
		local both_methods "No"
		if `alg_n' > 0 & `insp_n' > 0 local both_methods "Yes"
		file write support "`speclabel' & `sample_label' & `strata_n' & `cell_n' & `total_n' & `alg_n' & `insp_n' & `both_methods' \\" _n
		drop support_stratum_tag support_cell
	}
}
file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

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

************************************************************
* 4. Export Table 6 with additional grouped controls
************************************************************
foreach spec in yhatrf_bin15 yhatrf_bin20 yhatrf_bin40 yhatrf_bin50 yhatrf_topsplit {
	use `table6_prepared', clear
	capture estimates drop _all

	local extra_controls "ib1.yhatrf_bin15"
	local table_out "`table_yhatrf_bin15'"
	local prefix "f"
	if "`spec'" == "yhatrf_bin20" {
		local extra_controls "ib1.yhatrf_bin20"
		local table_out "`table_yhatrf_bin20'"
		local prefix "w"
	}
	if "`spec'" == "yhatrf_bin40" {
		local extra_controls "ib1.yhatrf_bin40"
		local table_out "`table_yhatrf_bin40'"
		local prefix "r"
	}
	if "`spec'" == "yhatrf_bin50" {
		local extra_controls "ib1.yhatrf_bin50"
		local table_out "`table_yhatrf_bin50'"
		local prefix "n"
	}
	if "`spec'" == "yhatrf_topsplit" {
		local extra_controls "ib1.yhatrf_decile_topsplit"
		local table_out "`table_yhatrf_topsplit'"
		local prefix "s"
	}
	local panel_a_models ""
	local panel_b_models ""

	foreach outcome in index_efficiency index_corruption {
		if "`outcome'" == "index_efficiency" local outtag "eff"
		if "`outcome'" == "index_corruption" local outtag "cor"

		forvalues col = 1/3 {
			local sample_if "selfreported_audit == 1"
			if `col' == 1 local sample_if "`sample_if' & x2 == 1"
			if `col' == 2 local sample_if "`sample_if' & x2 == 0"

			local estname = "`prefix'`outtag'A`col'"
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

			local estname = "`prefix'`outtag'B`col'"
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
		using `"`table_out'"',
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
		using `"`table_out'"',
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
}

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
* 5. Export Table 6 with yhatrf control
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
* 6. Export Table 6 with yhatrf and yhatrf^2
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
* 7. Export Table 6 with yhatrf decile controls
************************************************************
use `table6_prepared', clear
capture estimates drop _all

local spec_tag "yhatrf_deciles"
local extra_controls "ib1.yhatrf_decile"
local panel_a_models ""
local panel_b_models ""

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "selfreported_audit == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "d`outtag'A`col'"
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

		local estname = "d`outtag'B`col'"
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
	using `"`table_yhatrf_deciles'"',
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
	using `"`table_yhatrf_deciles'"',
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
* 8. Light diagnostics
************************************************************
quietly count if selfreported_audit == 1
local n_panel_a = r(N)
quietly count if y2 == 1
local n_panel_b = r(N)

di as text "Panel A sample after prep: `n_panel_a'"
di as text "Panel B sample after prep: `n_panel_b'"




************************************************************
* 9. Export Table 6 with yhatrf quintile controls
************************************************************
use `table6_prepared', clear
capture estimates drop _all

local spec_tag "yhatrf_quintiles"
local extra_controls "ib1.yhatrf_quintile"
local panel_a_models ""
local panel_b_models ""

foreach outcome in index_efficiency index_corruption {
	if "`outcome'" == "index_efficiency" local outtag "eff"
	if "`outcome'" == "index_corruption" local outtag "cor"

	forvalues col = 1/3 {
		local sample_if "selfreported_audit == 1"
		if `col' == 1 local sample_if "`sample_if' & x2 == 1"
		if `col' == 2 local sample_if "`sample_if' & x2 == 0"

		local estname = "v`outtag'A`col'"
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

		local estname = "v`outtag'B`col'"
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
	using `"`table_yhatrf_quintiles'"',
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
	using `"`table_yhatrf_quintiles'"',
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
