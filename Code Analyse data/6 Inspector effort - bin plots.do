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
			local xti "Predicted evasion (log FCFA)"

		}
		else if "`b'" == "turnover_mean" {
			local xti "Firm Size (Mean turnover 2014-2020)"

		}

		********************************************************************************
		** LOOP over bin definition and bin scope
		********************************************************************************
		foreach bin_def in `bin_defs' {
			foreach bin_scope in within_method pooled_sample {

				local tail_cut = 12
				local export_suffix ""
				if "`bin_scope'" == "pooled_sample" local export_suffix "_whole_sample"

				* Clear prior bin vars
				capture drop bin_`b'
				capture drop mid_bin_`b'

				* Bins are computed either within selection method or on the pooled sample.
				* For pooled-sample outputs, the bin thresholds are estimated on executed cases
				* only, then applied back to the full selected sample.
				if "`bin_def'" == "decile" {
					local nq = 10
					if "`bin_scope'" == "within_method" {
						bysort algorithm: egen bin_`b' = xtile(`b'), nq(10)
						bysort algorithm bin_`b': egen mid_bin_`b' = mean(`b')
					}
					else {
						tempvar exec_bin
						egen `exec_bin' = xtile(`b') if y2==1, nq(`nq')
						gen bin_`b' = .
						local last_cut = `nq' - 1
						forvalues q = 1/`last_cut' {
							quietly summarize `b' if `exec_bin'==`q', meanonly
							local cut`q' = r(max)
						}
						replace bin_`b' = 1 if !missing(`b') & `b' <= `cut1'
						forvalues q = 2/`last_cut' {
							local prev = `q' - 1
							replace bin_`b' = `q' if !missing(`b') & `b' > `cut`prev'' & `b' <= `cut`q''
						}
						replace bin_`b' = `nq' if !missing(`b') & `b' > `cut`last_cut''
						bysort bin_`b': egen mid_bin_`b' = mean(`b')
					}
					local bin_family "quantile"
					local bin_tag "decile"
					if "`b'" == "yhatrf" {
						if "`bin_scope'" == "within_method" local xti_bin "Decile of Predicted evasion (log FCFA)"
						else local xti_bin "Executed-case pooled decile of Predicted evasion (log FCFA)"
					}
					else if "`b'" == "turnover_mean" {
						if "`bin_scope'" == "within_method" local xti_bin "Decile of Firm Size (Mean turnover 2014-2020)"
						else local xti_bin "Executed-case pooled decile of Firm Size (Mean turnover 2014-2020)"
					}
				}
				else if "`bin_def'" == "quintile" {
					local nq = 5
					if "`bin_scope'" == "within_method" {
						bysort algorithm: egen bin_`b' = xtile(`b'), nq(5)
						bysort algorithm bin_`b': egen mid_bin_`b' = mean(`b')
					}
					else {
						tempvar exec_bin
						egen `exec_bin' = xtile(`b') if y2==1, nq(`nq')
						gen bin_`b' = .
						local last_cut = `nq' - 1
						forvalues q = 1/`last_cut' {
							quietly summarize `b' if `exec_bin'==`q', meanonly
							local cut`q' = r(max)
						}
						replace bin_`b' = 1 if !missing(`b') & `b' <= `cut1'
						forvalues q = 2/`last_cut' {
							local prev = `q' - 1
							replace bin_`b' = `q' if !missing(`b') & `b' > `cut`prev'' & `b' <= `cut`q''
						}
						replace bin_`b' = `nq' if !missing(`b') & `b' > `cut`last_cut''
						bysort bin_`b': egen mid_bin_`b' = mean(`b')
					}
					local bin_family "quantile"
					local bin_tag "quintile"
					if "`b'" == "yhatrf" {
						if "`bin_scope'" == "within_method" local xti_bin "Quintile of Predicted evasion (log FCFA)"
						else local xti_bin "Executed-case pooled quintile of Predicted evasion (log FCFA)"
					}
					else if "`b'" == "turnover_mean" {
						if "`bin_scope'" == "within_method" local xti_bin "Quintile of Firm Size (Mean turnover 2014-2020)"
						else local xti_bin "Executed-case pooled quintile of Firm Size (Mean turnover 2014-2020)"
					}
				}
				else {
					* --- FIXED-WIDTH BINS ---
					local w = real(substr("`bin_def'",2,.))
					if "`bin_scope'" == "within_method" {
						bysort algorithm: egen min_raw_`b' = min(`b')
						bysort algorithm: egen max_raw_`b' = max(`b')
					}
					else {
						tempvar exec_x
						gen `exec_x' = `b' if y2==1
						egen min_raw_`b' = min(`exec_x')
						egen max_raw_`b' = max(`exec_x')
					}
					gen min_v_`b' = floor(min_raw_`b')
					gen max_v_`b' = ceil(max_raw_`b')
					gen bin_`b' = floor((`b' - min_v_`b')/`w')*`w' + min_v_`b'
					replace bin_`b' = max_v_`b' if bin_`b' > max_v_`b'
					gen mid_bin_`b' = bin_`b' + (`w'/2)
					drop min_raw_`b' max_raw_`b' min_v_`b' max_v_`b'
					local bin_family "fixed"
					local bin_tag "`w'u"
					if "`b'" == "yhatrf" {
						if "`bin_scope'" == "within_method" local xti_bin "Bins of Predicted evasion (log FCFA), width = `w'"
						else local xti_bin "Executed-case pooled bins of Predicted evasion (log FCFA), width = `w'"
					}
					else if "`b'" == "turnover_mean" {
						if "`bin_scope'" == "within_method" local xti_bin "Bins of Firm Size (Mean turnover 2014-2020), width = `w'"
						else local xti_bin "Executed-case pooled bins of Firm Size (Mean turnover 2014-2020), width = `w'"
					}
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

				local xlbl ""
				local xscale_opt ""

				if "`bin_family'" == "quantile" {
					local xvar "bin_`b'"
					if "`bin_def'" == "decile" local xlbl "1(1)10"
					else local xlbl "1(1)5"
					local xscale_opt "xscale(range(1 `nq') noextend)"
					local plot_if_alg "if algorithm==1"
					local plot_if_ins "if algorithm==0"
					local sample_if ""
				}
				else {
					local xvar "mid_bin_`b'"
					if "`b'"=="yhatrf" {
						levelsof bin_`b' if mid_bin_`b' >= `tail_cut', local(bin_levels_exec)
					}
					else {
						levelsof bin_`b', local(bin_levels_exec)
					}
					foreach k of local bin_levels_exec {
						local lower = `k'
						local upper = `k' + `w'
						quietly summarize mid_bin_`b' if bin_`b'==`k', meanonly
						local m = r(mean)
						local lower_lbl = string(`lower',"%9.0f")
						local upper_lbl = string(`upper',"%9.0f")
						local xlbl `"`xlbl' `m' "`lower_lbl'-`upper_lbl'""'
					}

					if "`b'"=="yhatrf" {
						quietly count if `xvar' >= `tail_cut'
						if r(N) == 0 {
							restore
							continue
						}
						local plot_if_alg "if algorithm==1 & `xvar'>=`tail_cut'"
						local plot_if_ins "if algorithm==0 & `xvar'>=`tail_cut'"
						local sample_if "if `xvar'>=`tail_cut'"
					}
					else {
						local plot_if_alg "if algorithm==1"
						local plot_if_ins "if algorithm==0"
						local sample_if ""
					}

					quietly summarize `xvar' `sample_if', meanonly
					local xlo = r(min)
					local xhi = r(max)
					local xscale_opt "xscale(range(`xlo' `xhi') noextend)"
				}


				local col_alg "#0072B2"
				local col_ins "#D55E00"
				local band_a 20
				local bound_a 60
				local pat_alg "solid"
				local pat_ins "dash"

				quietly summarize ci_upper_y2 `sample_if', meanonly
				local y_top_y2 = r(max)
				if missing(`y_top_y2') | `y_top_y2' <= 0 local y_top_y2 = 0.2
				local y_step_y2 = cond(`y_top_y2'<=0.5,0.1,0.2)
				local y_top_y2 = ceil(`y_top_y2'/`y_step_y2')*`y_step_y2'
				if `y_top_y2' > 1 local y_top_y2 = 1
				local y_ticks_y2 "0(`y_step_y2')`y_top_y2'"
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
					xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
					`xscale_opt' ///
					yscale(range(0 `y_top_y2')) ///
					ylabel(`y_ticks_y2', format(%3.1f) angle(horizontal) nogrid) ///
					ytitle("Share of executed cases") xtitle("`xti_bin'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\exec_rate_binplot_`b'_`audit_type'_`bin_tag'`export_suffix'.pdf", replace
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
				local xlbl ""
				local xscale_opt ""

				if "`bin_family'" == "quantile" {
					local xvar "bin_`b'"
					if "`bin_def'" == "decile" local xlbl "1(1)10"
					else local xlbl "1(1)5"
					local xscale_opt "xscale(range(1 `nq') noextend)"
					local plot_if_alg "if algorithm==1"
					local plot_if_ins "if algorithm==0"
					local sample_if ""
				}
				else {
					local xvar "mid_bin_`b'"
					if "`b'"=="yhatrf" {
						levelsof bin_`b' if mid_bin_`b' >= `tail_cut', local(bin_levels)
					}
					else {
						levelsof bin_`b', local(bin_levels)
					}
					foreach k of local bin_levels {
						local lower = `k'
						local upper = `k' + `w'
						quietly summarize mid_bin_`b' if bin_`b'==`k', meanonly
						local m = r(mean)
						local lower_lbl = string(`lower',"%9.0f")
						local upper_lbl = string(`upper',"%9.0f")
						local xlbl `"`xlbl' `m' "`lower_lbl'-`upper_lbl'""'
					}

					if "`b'"=="yhatrf" {
						quietly count if `xvar' >= `tail_cut'
						if r(N) == 0 {
							restore
							continue
						}
						local plot_if_alg "if algorithm==1 & `xvar'>=`tail_cut'"
						local plot_if_ins "if algorithm==0 & `xvar'>=`tail_cut'"
						local sample_if "if `xvar'>=`tail_cut'"
					}
					else {
						local plot_if_alg "if algorithm==1"
						local plot_if_ins "if algorithm==0"
						local sample_if ""
					}

					quietly summarize `xvar' `sample_if', meanonly
					local xlo = r(min)
					local xhi = r(max)
					local xscale_opt "xscale(range(`xlo' `xhi') noextend)"
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
				quietly summarize ci_upper_ninspectors `sample_if', meanonly
				local y_top_ninspectors = r(max)
				if missing(`y_top_ninspectors') | `y_top_ninspectors' <= 0 local y_top_ninspectors = 0.2
				local y_step_ninspectors = cond(`y_top_ninspectors'<=1,0.1,cond(`y_top_ninspectors'<=2,0.2,cond(`y_top_ninspectors'<=4,0.5,1)))
				local y_top_ninspectors = ceil(`y_top_ninspectors'/`y_step_ninspectors')*`y_step_ninspectors'
				local y_ticks_ninspectors "0(`y_step_ninspectors')`y_top_ninspectors'"
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
					xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
					`xscale_opt' ///
					yscale(range(0 `y_top_ninspectors')) ///
					ylabel(`y_ticks_ninspectors', format(%3.1f) angle(horizontal) nogrid) ///
					ytitle("Average number of inspectors") xtitle("`xti_bin'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_ninspectors_binplot_`b'_`audit_type'_`bin_tag'`export_suffix'.pdf", replace

				********************************************************************************
				** (2) Duration (Admin data) y19
				********************************************************************************
				quietly summarize ci_upper_y19 `sample_if', meanonly
				local y_top_y19 = r(max)
				if missing(`y_top_y19') | `y_top_y19' <= 0 local y_top_y19 = 1
				local y_step_y19 = cond(`y_top_y19'<=10,1,cond(`y_top_y19'<=20,2,cond(`y_top_y19'<=50,5,cond(`y_top_y19'<=100,10,20))))
				local y_top_y19 = ceil(`y_top_y19'/`y_step_y19')*`y_step_y19'
				local y_ticks_y19 "0(`y_step_y19')`y_top_y19'"
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
					xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
					`xscale_opt' ///
					yscale(range(0 `y_top_y19')) ///
					ylabel(`y_ticks_y19', angle(horizontal) nogrid) ///
					ytitle("Average duration (days)") xtitle("`xti_bin'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_admin_binplot_`b'_`audit_type'_`bin_tag'`export_suffix'.pdf", replace

				********************************************************************************
				** (3) Duration (Taxpayer survey) q30
				********************************************************************************
				quietly summarize ci_upper_q30 `sample_if', meanonly
				local y_top_q30 = r(max)
				if missing(`y_top_q30') | `y_top_q30' <= 0 local y_top_q30 = 1
				local y_step_q30 = cond(`y_top_q30'<=10,1,cond(`y_top_q30'<=20,2,cond(`y_top_q30'<=50,5,cond(`y_top_q30'<=100,10,20))))
				local y_top_q30 = ceil(`y_top_q30'/`y_step_q30')*`y_step_q30'
				local y_ticks_q30 "0(`y_step_q30')`y_top_q30'"
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
					xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
					`xscale_opt' ///
					yscale(range(0 `y_top_q30')) ///
                    ylabel(`y_ticks_q30', angle(horizontal) nogrid) ///
					ytitle("Average duration (days)") xtitle("`xti_bin'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_tp_binplot_`b'_`audit_type'_`bin_tag'`export_suffix'.pdf", replace

				********************************************************************************
				** (4) Duration (Self-reported) y8
				********************************************************************************
				quietly summarize ci_upper_y8 `sample_if', meanonly
				local y_top_y8 = r(max)
				if missing(`y_top_y8') | `y_top_y8' <= 0 local y_top_y8 = 1
				local y_step_y8 = cond(`y_top_y8'<=10,1,cond(`y_top_y8'<=20,2,cond(`y_top_y8'<=50,5,cond(`y_top_y8'<=100,10,20))))
				local y_top_y8 = ceil(`y_top_y8'/`y_step_y8')*`y_step_y8'
				local y_ticks_y8 "0(`y_step_y8')`y_top_y8'"
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
					xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
					`xscale_opt' ///
					yscale(range(0 `y_top_y8')) ///
                    ylabel(`y_ticks_y8', angle(horizontal) nogrid) ///
					ytitle("Average duration (days)") xtitle("`xti_bin'") ///
					legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
					graphregion(color(white)) plotregion(color(white))

				graph export "$output\avg_duration_self_binplot_`b'_`audit_type'_`bin_tag'`export_suffix'.pdf", replace

			restore
			}
		}
	}
}
