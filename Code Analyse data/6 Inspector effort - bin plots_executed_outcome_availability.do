*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   RA: Roldan Enamorado
**		   March 2026
*****************************************************************************************

*****************
** DESCRIPTION  **
*****************
/*
This code creates executed-case bin plots for inspector effort outcomes.

Compared with the main bin-plot file:
- only executed-case outcomes are plotted
- only quantile bins are used (quintiles and deciles)
- bins are estimated separately for each outcome using the eligible sample
  y2 == 1 and non-missing outcome
- quantile cutoffs are pooled within audit type, then applied to both methods
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

	* firm size proxy
	egen turnover_mean = rowmean(turnover2014 turnover2015 turnover2016 turnover2017 turnover2018 turnover2019 turnover2020)

	********************************************************************************
	** LOOP over x-variable (predicted evasion and firm size)
	********************************************************************************
	foreach b of varlist yhatrf turnover_mean {

		********************************************************************************
		** LOOP over quantile definition
		********************************************************************************
		foreach bin_def in quintile decile {

			if "`bin_def'" == "decile" {
				local nq 10
				local quantile_name "Decile"
				local bin_tag "decile"
			}
			else {
				local nq 5
				local quantile_name "Quintile"
				local bin_tag "quintile"
			}

			********************************************************************************
			** LOOP over outcome: pooled quantiles on executed cases with non-missing outcome
			********************************************************************************
			foreach outcome in ninspectors y19 q30 y8 {

				if "`outcome'" == "ninspectors" {
					local outcome_var "numberagents"
					local export_stub "avg_ninspectors"
					local ytitle "Average number of inspectors"
					local outcome_label "number of inspectors"
				}
				else if "`outcome'" == "y19" {
					local outcome_var "y19"
					local export_stub "avg_duration_admin"
					local ytitle "Average duration (days)"
					local outcome_label "admin duration"
				}
				else if "`outcome'" == "q30" {
					local outcome_var "q30"
					local export_stub "avg_duration_tp"
					local ytitle "Average duration (days)"
					local outcome_label "taxpayer-reported duration"
				}
				else {
					local outcome_var "y8"
					local export_stub "avg_duration_self"
					local ytitle "Average duration (days)"
					local outcome_label "self-reported duration"
				}

				if "`b'" == "yhatrf" {
					local xti_bin "`quantile_name' of Predicted evasion (executed, non-missing `outcome_label')"
				}
				else {
					local xti_bin "`quantile_name' of Firm Size (executed, non-missing `outcome_label')"
				}

				preserve
					keep if y2==1
					keep if !missing(`outcome_var')
					drop if missing(`b')

					quietly count
					if r(N) == 0 {
						restore
						continue
					}

					capture drop bin_`b'
					capture drop mid_bin_`b'

					tempvar pooled_bin
					egen `pooled_bin' = xtile(`b'), nq(`nq')

					gen bin_`b' = .
					local last_cut = `nq' - 1
					forvalues q = 1/`last_cut' {
						quietly summarize `b' if `pooled_bin'==`q', meanonly
						local cut`q' = r(max)
					}

					replace bin_`b' = 1 if !missing(`b') & `b' <= `cut1'
					forvalues q = 2/`last_cut' {
						local prev = `q' - 1
						replace bin_`b' = `q' if !missing(`b') & `b' > `cut`prev'' & `b' <= `cut`q''
					}
					replace bin_`b' = `nq' if !missing(`b') & `b' > `cut`last_cut''
					bysort bin_`b': egen mid_bin_`b' = mean(`b')

					collapse ///
						(mean) avg_outcome=`outcome_var' ///
						(sd)   sd_outcome=`outcome_var' ///
						(count) n_outcome=`outcome_var', ///
						by(algorithm bin_`b' mid_bin_`b')

					replace sd_outcome = 0 if n_outcome==1 & missing(sd_outcome)
					gen se_outcome = .
					replace se_outcome = sd_outcome/sqrt(n_outcome) if n_outcome > 0

					gen ci_lower_outcome = avg_outcome - 1.96*se_outcome
					gen ci_upper_outcome = avg_outcome + 1.96*se_outcome
					replace ci_lower_outcome = 0 if !missing(ci_lower_outcome) & ci_lower_outcome < 0

					local xvar "bin_`b'"
					if "`bin_def'" == "decile" local xlbl "1(1)10"
					else local xlbl "1(1)5"
					local xscale_opt "xscale(range(1 `nq') noextend)"
					local plot_if_alg "if algorithm==1"
					local plot_if_ins "if algorithm==0"

					local col_alg "#0072B2"
					local col_ins "#D55E00"
					local band_a 20
					local bound_a 60
					local pat_alg "solid"
					local pat_ins "dash"

					quietly summarize ci_upper_outcome, meanonly
					local y_top = r(max)

					if "`outcome'" == "ninspectors" {
						if missing(`y_top') | `y_top' <= 0 local y_top = 0.2
						local y_step = cond(`y_top'<=1,0.1,cond(`y_top'<=2,0.2,cond(`y_top'<=4,0.5,1)))
						local y_top = ceil(`y_top'/`y_step')*`y_step'
						local y_ticks "0(`y_step')`y_top'"
						local ylabel_opt "ylabel(`y_ticks', format(%3.1f) angle(horizontal) nogrid)"
					}
					else {
						if missing(`y_top') | `y_top' <= 0 local y_top = 1
						local y_step = cond(`y_top'<=10,1,cond(`y_top'<=20,2,cond(`y_top'<=50,5,cond(`y_top'<=100,10,20))))
						local y_top = ceil(`y_top'/`y_step')*`y_step'
						local y_ticks "0(`y_step')`y_top'"
						local ylabel_opt "ylabel(`y_ticks', angle(horizontal) nogrid)"
					}

					twoway ///
						(rarea ci_upper_outcome ci_lower_outcome `xvar' `plot_if_alg', ///
							sort fcolor("`col_alg'%`band_a'") lcolor("`col_alg'%0")) || ///
						(line  ci_upper_outcome `xvar' `plot_if_alg', ///
							sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
						(line  ci_lower_outcome `xvar' `plot_if_alg', ///
							sort lcolor("`col_alg'%`bound_a'") lpattern(`pat_alg') lwidth(vthin)) || ///
						(connected avg_outcome `xvar' `plot_if_alg', ///
							sort lcolor("`col_alg'") mcolor("`col_alg'") ///
							lpattern(solid) lwidth(medthick) ///
							msymbol(circle) msize(small)) || ///
						(rarea ci_upper_outcome ci_lower_outcome `xvar' `plot_if_ins', ///
							sort fcolor("`col_ins'%`band_a'") lcolor("`col_ins'%0")) || ///
						(line  ci_upper_outcome `xvar' `plot_if_ins', ///
							sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
						(line  ci_lower_outcome `xvar' `plot_if_ins', ///
							sort lcolor("`col_ins'%`bound_a'") lpattern(`pat_ins') lwidth(vthin)) || ///
						(connected avg_outcome `xvar' `plot_if_ins', ///
							sort lcolor("`col_ins'") mcolor("`col_ins'") ///
							lwidth(medthick) ///
							msymbol(diamond) msize(small)), ///
						xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
						`xscale_opt' ///
						yscale(range(0 `y_top')) ///
						`ylabel_opt' ///
						ytitle("`ytitle'") xtitle("`xti_bin'") ///
						legend(order(4 "Algorithm cases" 8 "Inspector cases") pos(6) col(2) ring(1)) ///
						graphregion(color(white)) plotregion(color(white))

					graph export "${output}/`export_stub'_binplot_`b'_`audit_type'_`bin_tag'_outcomeavail.pdf", replace
				restore
			}
		}
	}
}
