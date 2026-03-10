*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   RA: Roldan Enamorado
**		   November 2025
*****************************************************************************************

*****************
** DESCRIPTION  **
*****************
/*
This code merges predicted evasion from the random forest model with analysis data
to generate bin plots based on predicted evasion and firm size.

MISSING FIX (for CIs):
- collapse (mean)/(sd) ignores missing outcomes, BUT SE/CIs must use outcome-specific n.
- We now compute (count) per outcome and use it for SE/CIs.

CI VISIBILITY FIX (colorblind-friendly without changing colors):
- Keep same colors: col_alg "#9E0142" and col_ins "orange".
- Make CI bands semi-transparent.
- Add semi-transparent CI boundary lines:
    Algorithm: solid boundaries
    Inspector: dashed boundaries
- Inspector AVERAGE line: NO dashed pattern (pattern only for CI boundaries).
*/

*Set-up
set scheme stcolor
set more off
clear all

global check = 1 // to save outside official replication folder

*****************
** DIRECTORIES **
*****************
if strpos("`c(username)'","49354415") { 										// Alipio's computer
	global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
}
if strpos("`c(username)'","User") { 											// Roldan's computer
	global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}
if strpos("`c(username)'","wb648862") { 										// Roldan's computer
	global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}

if $check == 1 {
	global output "C:\Users\User\OneDrive\World Bank\Senegal-Tax-Audit\Output"
}
di "$output"

global rawdata      "$rootdir"
global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global wastedata    "$rootdir\Analysis all data\replication_package\Intermediate data"
global output       "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
	global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
}
di "$output"

********************************************************************************
** MAIN LOOP: Full vs Desk
********************************************************************************
foreach audtype in 1 0 {

	local audit_type = cond(`audtype'==1, "Full", "Desk")
	di "=================================================="
	di "Audit type: `audit_type'"
	di "=================================================="

	use "$analysisdata\fullaudits_predicted.dta", clear
	append using "$analysisdata\deskaudits_predicted.dta"

	* adjustment of admin duration data: don't consider duration = 0
	replace y19 = . if y19==0

	* restrict to audit type subsample
	keep if x2==`audtype'

	tab method y2

	* Firm size proxy
	egen turnover_mean = rowmean(turnover2014 turnover2015 turnover2016 turnover2017 turnover2018 turnover2019 turnover2020)

	* Binning definitions (ADDED quintile)
	local bin_defs "quintile decile w1 w2 w4 w5"

	********************************************************************************
	** LOOP over x-variable (predicted evasion and firm size)
	********************************************************************************
	foreach b of varlist yhatrf turnover_mean {

		* x-axis title
		if "`b'" == "yhatrf" {
			local xti "Evasion (log FCFA)"
		}
		else if "`b'" == "turnover_mean" {
			local xti "Firm Size (Mean turnover 2014-2020)"
		}

		********************************************************************************
		** LOOP over bin definition
		********************************************************************************
		foreach bin_def in `bin_defs' {

			local tail_cut = 12

			* Clear prior bin vars
			capture drop bin_`b'
			capture drop mid_bin_`b'

			* Bins are computed within selection method (Algorithm vs Inspectors).
			* --- QUANTILE BINS (ADDED quintile) ---
			if "`bin_def'" == "decile" {
				bysort algorithm: egen bin_`b' = xtile(`b'), nq(10)
				bysort algorithm bin_`b': egen mid_bin_`b' = mean(`b')
				local bin_tag "decile"
			}
			else if "`bin_def'" == "quintile" {
				bysort algorithm: egen bin_`b' = xtile(`b'), nq(5)
				bysort algorithm bin_`b': egen mid_bin_`b' = mean(`b')
				local bin_tag "quintile"
			}
			else {
				* --- FIXED-WIDTH BINS ---
				local w = real(substr("`bin_def'",2,.))
				bysort algorithm: egen min_raw_`b' = min(`b')
				bysort algorithm: egen max_raw_`b' = max(`b')
				gen min_v_`b' = floor(min_raw_`b')
				gen max_v_`b' = ceil(max_raw_`b')
				gen bin_`b' = floor((`b' - min_v_`b')/`w')*`w' + min_v_`b'
				replace bin_`b' = max_v_`b' if bin_`b' > max_v_`b'
				gen mid_bin_`b' = bin_`b' + (`w'/2)
				drop min_raw_`b' max_raw_`b' min_v_`b' max_v_`b'
				local bin_tag "`w'u"
			}

			********************************************************************************
			** EXECUTION RATE (all selected cases; not conditional on execution)
			********************************************************************************
			preserve
				gen n_total_exec = 1
				drop if missing(bin_`b')

				collapse ///
					(mean)  avg_y2=y2 ///
					(sd)    sd_y2=y2 ///
					(count) n_y2=y2 ///
					(sum)   n_total_exec=n_total_exec, ///
					by(algorithm bin_`b' mid_bin_`b')

				replace sd_y2 = 0 if n_y2==1 & missing(sd_y2)
				gen se_y2 = .
				replace se_y2 = sd_y2/sqrt(n_y2) if n_y2 > 0

				gen ci_lower_y2 = avg_y2 - 1.96*se_y2
				gen ci_upper_y2 = avg_y2 + 1.96*se_y2
				replace ci_lower_y2 = 0 if !missing(ci_lower_y2) & ci_lower_y2 < 0
				replace ci_upper_y2 = 1 if !missing(ci_upper_y2) & ci_upper_y2 > 1

				local xvar "mid_bin_`b'"
				if inlist("`bin_def'","decile","quintile") {
					local xvar "bin_`b'"
				}

				if "`b'"=="yhatrf" & !inlist("`bin_def'","decile","quintile") {
					quietly count if `xvar' >= `tail_cut'
					if r(N) == 0 {
						restore
						continue
					}
					local plot_if_alg "if algorithm==1 & `xvar'>=`tail_cut'"
					local plot_if_ins "if algorithm==0 & `xvar'>=`tail_cut'"
				}
				else {
					local plot_if_alg "if algorithm==1"
					local plot_if_ins "if algorithm==0"
				}

				local col_alg "#0072B2"
				local col_ins "#D55E00"
				local band_a 20
				local bound_a 60
				local pat_alg "solid"
				local pat_ins "dash"

				twoway ///
					(rarea ci_upper_y2 ci_lower_y2 `xvar' `plot_if_alg', ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_y2 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_y2 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_y2 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_y2 ci_lower_y2 `xvar' `plot_if_ins', ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_y2 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_y2 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_y2 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(, angle(45) labsize(vsmall)) ///
					yscale(range(0 1)) ///
					ylabel(0(0.2)1, format(%3.1f) angle(horizontal)) ///
					ytitle("Share of executed cases") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\exec_rate_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace
			restore

			********************************************************************************
			** BIN-LEVEL DATASET (executed only) + FIXED CIs WITH OUTCOME-SPECIFIC n
			********************************************************************************
			preserve
				gen n_total = 1
				keep if y2==1

				* drop missing x so they don't form an unplotted group
				drop if missing(bin_`b')

				collapse ///
					(mean)  avg_y2=y2 avg_ninspectors=numberagents avg_y19=y19 avg_q30=q30 avg_y8=y8 ///
					(sd)    sd_y2=y2  sd_ninspectors=numberagents sd_y19=y19  sd_q30=q30  sd_y8=y8 ///
					(count) n_y2=y2 n_ninspectors=numberagents n_y19=y19 n_q30=q30 n_y8=y8 ///
					(sum)   n_total=n_total, ///
					by(algorithm bin_`b' mid_bin_`b')

				* Build CIs using correct n for each outcome
				foreach x in y2 ninspectors y19 q30 y8 {
					replace sd_`x' = 0 if n_`x'==1 & missing(sd_`x')
					gen se_`x' = .
					replace se_`x' = sd_`x'/sqrt(n_`x') if n_`x' > 0

					gen ci_lower_`x' = avg_`x' - 1.96*se_`x'
					gen ci_upper_`x' = avg_`x' + 1.96*se_`x'
					replace ci_lower_`x' = 0 if !missing(ci_lower_`x') & ci_lower_`x' < 0
				}

				********************************************************************************
				** X labels
				********************************************************************************
				local xvar "mid_bin_`b'"

				* For quantiles (decile/quintile): plot against bin index (1..K)
				if inlist("`bin_def'","decile","quintile") {
					local xvar "bin_`b'"
				}

				if "`b'"=="yhatrf" & !inlist("`bin_def'","decile","quintile") {
					quietly count if `xvar' >= `tail_cut'
					if r(N) == 0 {
						restore
						continue
					}
					local plot_if_alg "if algorithm==1 & `xvar'>=`tail_cut'"
					local plot_if_ins "if algorithm==0 & `xvar'>=`tail_cut'"
				}
				else {
					local plot_if_alg "if algorithm==1"
					local plot_if_ins "if algorithm==0"
				}

				********************************************************************************
				** PLOT STYLE (keep same colors, improve CI visibility)
				********************************************************************************
				local col_alg "#0072B2"
				local col_ins "#D55E00"

				* transparency for bands and boundaries
				local band_a 20   // CI band opacity (%)
				local bound_a 60  // CI boundary opacity (%)

				* patterns ONLY for CI boundaries
				local pat_alg "solid"
				local pat_ins "dash"

				********************************************************************************
				** (1) Avg number of inspectors
				********************************************************************************
				twoway ///
					(rarea ci_upper_ninspectors ci_lower_ninspectors `xvar' `plot_if_alg', ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_ninspectors `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_ninspectors `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_ninspectors `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_ninspectors ci_lower_ninspectors `xvar' `plot_if_ins', ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_ninspectors `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_ninspectors `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_ninspectors `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(, angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ///
					ylabel(, angle(horizontal)) ///
					ytitle("Average number of inspectors") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_ninspectors_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (2) Duration (Admin data) y19
				********************************************************************************
				twoway ///
					(rarea ci_upper_y19 ci_lower_y19 `xvar' `plot_if_alg', ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_y19 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_y19 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_y19 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_y19 ci_lower_y19 `xvar' `plot_if_ins', ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_y19 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_y19 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_y19 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(, angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_admin_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (3) Duration (Taxpayer survey) q30
				********************************************************************************
				twoway ///
					(rarea ci_upper_q30 ci_lower_q30 `xvar' `plot_if_alg', ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_q30 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_q30 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_q30 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_q30 ci_lower_q30 `xvar' `plot_if_ins', ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_q30 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_q30 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_q30 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(, angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_tp_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (4) Duration (Self-reported) y8
				********************************************************************************
				twoway ///
					(rarea ci_upper_y8 ci_lower_y8 `xvar' `plot_if_alg', ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_y8 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_y8 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_y8 `xvar' `plot_if_alg', ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_y8 ci_lower_y8 `xvar' `plot_if_ins', ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_y8 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_y8 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_y8 `xvar' `plot_if_ins', ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(, angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_self_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

			restore
		}
	}
}
