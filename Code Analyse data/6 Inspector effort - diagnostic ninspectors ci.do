*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         April 2026
*****************************************************************************************

*****************
** DESCRIPTION  **
*****************
/*
This code creates a quick diagnostic figure for the preferred full-audit
predicted-evasion specification used in the executed-only inspector-effort plots.

The figure decomposes the CI width for average number of inspectors into:
- executed-case counts by decile,
- within-decile SD of number of inspectors,
- within-decile SE of the mean number of inspectors.

The preferred specification is:
- full audits only,
- predicted-evasion deciles formed on the pooled selected sample,
- outcome moments computed for executed cases only (y2 == 1).
*/

*------------------------------------------------------------*
* 1. Set-up
*------------------------------------------------------------*
set scheme stcolor
set more off
clear all

global check = 1

*------------------------------------------------------------*
* 2. Directories
*------------------------------------------------------------*
if strpos("`c(username)'","49354415") {
    global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
}
if strpos("`c(username)'","User") {
    global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}
if strpos("`c(username)'","wb648862") {
    global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}

if $check == 1 {
    global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
}

global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global output       "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
    global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
}

*------------------------------------------------------------*
* 3. Build preferred sample and pooled deciles
*------------------------------------------------------------*
use "$analysisdata\fullaudits_predicted.dta", clear
append using "$analysisdata\deskaudits_predicted.dta"

replace y19 = . if y19 == 0
keep if x2 == 1

egen bin_yhatrf = xtile(yhatrf), nq(10)

*------------------------------------------------------------*
* 4. Collapse executed-only moments for number of inspectors
*------------------------------------------------------------*
keep if y2 == 1
drop if missing(bin_yhatrf)

collapse ///
    (sd)    sd_ninspectors = numberagents ///
    (count) n_ninspectors  = numberagents, ///
    by(algorithm bin_yhatrf)

replace sd_ninspectors = 0 if n_ninspectors == 1 & missing(sd_ninspectors)
gen se_ninspectors = .
replace se_ninspectors = sd_ninspectors / sqrt(n_ninspectors) if n_ninspectors > 0

*------------------------------------------------------------*
* 5. Shared plot styling
*------------------------------------------------------------*
local xvar "bin_yhatrf"
local xlbl "1(1)10"
local xscale_opt "xscale(range(1 10) noextend)"
local col_alg "#0072B2"
local col_ins "#D55E00"
local diag_legend "legend(order(1 2) label(1 "Algorithm cases") label(2 "Inspector cases") pos(6) col(2) ring(1) region(lcolor(none)))"

*------------------------------------------------------------*
* 6. Panel A: executed counts
*------------------------------------------------------------*
quietly summarize n_ninspectors, meanonly
local y_top_diag_n = r(max)
if missing(`y_top_diag_n') | `y_top_diag_n' <= 0 local y_top_diag_n = 1
local y_step_diag_n = cond(`y_top_diag_n'<=20,5,cond(`y_top_diag_n'<=50,10,cond(`y_top_diag_n'<=100,20,50)))
local y_top_diag_n = ceil(`y_top_diag_n'/`y_step_diag_n') * `y_step_diag_n'
local y_ticks_diag_n "0(`y_step_diag_n')`y_top_diag_n'"

twoway ///
    (connected n_ninspectors `xvar' if algorithm == 1, ///
        sort lcolor("`col_alg'") mcolor("`col_alg'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(circle) msize(small)) || ///
    (connected n_ninspectors `xvar' if algorithm == 0, ///
        sort lcolor("`col_ins'") mcolor("`col_ins'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(diamond) msize(small)), ///
    xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
    `xscale_opt' ///
    yscale(range(0 `y_top_diag_n')) ///
    ylabel(`y_ticks_diag_n', angle(horizontal) nogrid) ///
    ytitle("Executed N") xtitle("Whole-sample predicted-evasion decile") ///
    title("A. Executed cases") ///
    legend(off) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(diag_ci_n, replace)
graph export "$output\diag_ci_components_ninspectors_executed_counts.png", replace
*------------------------------------------------------------*
* 7. Panel B: within-decile SD
*------------------------------------------------------------*
quietly summarize sd_ninspectors, meanonly
local y_top_diag_sd = r(max)
if missing(`y_top_diag_sd') | `y_top_diag_sd' <= 0 local y_top_diag_sd = 0.2
local y_step_diag_sd = cond(`y_top_diag_sd'<=1,0.1,cond(`y_top_diag_sd'<=2,0.2,cond(`y_top_diag_sd'<=4,0.5,1)))
local y_top_diag_sd = ceil(`y_top_diag_sd'/`y_step_diag_sd') * `y_step_diag_sd'
local y_ticks_diag_sd "0(`y_step_diag_sd')`y_top_diag_sd'"

twoway ///
    (connected sd_ninspectors `xvar' if algorithm == 1, ///
        sort lcolor("`col_alg'") mcolor("`col_alg'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(circle) msize(small)) || ///
    (connected sd_ninspectors `xvar' if algorithm == 0, ///
        sort lcolor("`col_ins'") mcolor("`col_ins'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(diamond) msize(small)), ///
    xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
    `xscale_opt' ///
    yscale(range(0 `y_top_diag_sd')) ///
    ylabel(`y_ticks_diag_sd', format(%3.1f) angle(horizontal) nogrid) ///
    ytitle("SD of inspectors") xtitle("Whole-sample predicted-evasion decile") ///
    title("B. Within-decile dispersion") ///
    legend(off) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(diag_ci_sd, replace)
graph export "$output\diag_ci_components_ninspectors_sd.png", replace
*------------------------------------------------------------*
* 8. Panel C: implied SE of the mean
*------------------------------------------------------------*
quietly summarize se_ninspectors, meanonly
local y_top_diag_se = r(max)
if missing(`y_top_diag_se') | `y_top_diag_se' <= 0 local y_top_diag_se = 0.1
local y_step_diag_se = cond(`y_top_diag_se'<=0.2,0.05,cond(`y_top_diag_se'<=0.5,0.1,cond(`y_top_diag_se'<=1,0.2,0.5)))
local y_top_diag_se = ceil(`y_top_diag_se'/`y_step_diag_se') * `y_step_diag_se'
local y_ticks_diag_se "0(`y_step_diag_se')`y_top_diag_se'"

twoway ///
    (connected se_ninspectors `xvar' if algorithm == 1, ///
        sort lcolor("`col_alg'") mcolor("`col_alg'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(circle) msize(small)) || ///
    (connected se_ninspectors `xvar' if algorithm == 0, ///
        sort lcolor("`col_ins'") mcolor("`col_ins'") ///
        lpattern(solid) lwidth(medthick) ///
        msymbol(diamond) msize(small)), ///
    xlabel(`xlbl', angle(45) labsize(vsmall) nogrid) ///
    `xscale_opt' ///
    yscale(range(0 `y_top_diag_se')) ///
    ylabel(`y_ticks_diag_se', format(%3.2f) angle(horizontal) nogrid) ///
    ytitle("SE = SD / sqrt(N)") xtitle("Whole-sample predicted-evasion decile") ///
    title("C. SE of the mean") ///
    `diag_legend' ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(diag_ci_se, replace)
graph export "$output\diag_ci_components_ninspectors_se.png", replace
*------------------------------------------------------------*
* 9. Combine and export
*------------------------------------------------------------*
graph combine diag_ci_n diag_ci_sd diag_ci_se, ///
    cols(3) xcommon ///
    graphregion(color(white)) plotregion(color(white))
graph export "$output\diag_ci_components_ninspectors_yhatrf_Full_decile_whole_sample.pdf", replace

graph drop diag_ci_n diag_ci_sd diag_ci_se
