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

		quietly summarize `b'
		local min_v = floor(r(min))
		local max_v = ceil(r(max))

		********************************************************************************
		** LOOP over bin definition
		********************************************************************************
		foreach bin_def in `bin_defs' {

			* Clear prior bin vars
			capture drop bin_`b'
			capture drop mid_bin_`b'

			* --- QUANTILE BINS (ADDED quintile) ---
			if "`bin_def'" == "decile" {
				xtile bin_`b' = `b', nq(10)
				bysort bin_`b': egen mid_bin_`b' = mean(`b')
				local bin_tag "decile"
			}
			else if "`bin_def'" == "quintile" {
				xtile bin_`b' = `b', nq(5)
				bysort bin_`b': egen mid_bin_`b' = mean(`b')
				local bin_tag "quintile"
			}
			else {
				* --- FIXED-WIDTH BINS ---
				local w = real(substr("`bin_def'",2,.))
				gen bin_`b' = floor((`b' - `min_v')/`w')*`w' + `min_v'
				replace bin_`b' = `max_v' if bin_`b' > `max_v'
				gen mid_bin_`b' = bin_`b' + (`w'/2)
				local bin_tag "`w'u"
			}

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
				local xlbl ""
				local xvar "mid_bin_`b'"

				levelsof bin_`b', local(bin_levels)

				* For quantiles (decile/quintile): plot against bin index (1..K)
				if inlist("`bin_def'","decile","quintile") {
					local xvar "bin_`b'"
					foreach k of local bin_levels {
						local xlbl `"`xlbl' `k' "`k'""'
					}
				}
				else {
					* Fixed-width range labels
					foreach k of local bin_levels {
						local lower = `k'
						local upper = `k' + `w'
						if `upper' > `max_v' local upper = `max_v'

						quietly summarize mid_bin_`b' if bin_`b'==`k', meanonly
						local m = r(mean)

						local lower_lbl = string(`lower',"%9.0f")
						local upper_lbl = string(`upper',"%9.0f")
						local xlbl `"`xlbl' `m' "`lower_lbl'-`upper_lbl'""'
					}
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
					(rarea ci_upper_ninspectors ci_lower_ninspectors `xvar' if algorithm==1, ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_ninspectors `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_ninspectors `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_ninspectors `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_ninspectors ci_lower_ninspectors `xvar' if algorithm==0, ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_ninspectors `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_ninspectors `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_ninspectors `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(`xlbl', angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average number of inspectors") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_ninspectors_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (2) Duration (Admin data) y19
				********************************************************************************
				twoway ///
					(rarea ci_upper_y19 ci_lower_y19 `xvar' if algorithm==1, ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_y19 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_y19 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_y19 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_y19 ci_lower_y19 `xvar' if algorithm==0, ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_y19 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_y19 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_y19 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(`xlbl', angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_admin_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (3) Duration (Taxpayer survey) q30
				********************************************************************************
				twoway ///
					(rarea ci_upper_q30 ci_lower_q30 `xvar' if algorithm==1, ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_q30 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_q30 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_q30 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_q30 ci_lower_q30 `xvar' if algorithm==0, ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_q30 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_q30 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_q30 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(`xlbl', angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_tp_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

				********************************************************************************
				** (4) Duration (Self-reported) y8
				********************************************************************************
				twoway ///
					(rarea ci_upper_y8 ci_lower_y8 `xvar' if algorithm==1, ///
						sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
					(line  ci_upper_y8 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(line  ci_lower_y8 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
					(connected avg_y8 `xvar' if algorithm==1, ///
						sort lcolor("`col_alg'") mcolor("`col_alg'") ///
						lpattern(solid) lwidth(medthick) ///
						msymbol(circle) msize(small)) || ///
					(rarea ci_upper_y8 ci_lower_y8 `xvar' if algorithm==0, ///
						sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
					(line  ci_upper_y8 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(line  ci_lower_y8 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
					(connected avg_y8 `xvar' if algorithm==0, ///
						sort lcolor("`col_ins'") mcolor("`col_ins'") ///
						lwidth(medthick) ///
						msymbol(diamond) msize(small)), ///
					xlabel(`xlbl', angle(45) labsize(vsmall)) ///
					yscale(range(0 .)) ylabel(0, add) ///
					ytitle("Average duration (days)") xtitle("`xti'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_self_binplot_`b'_`audit_type'_`bin_tag'.pdf", replace

			restore
		}
	}
}
