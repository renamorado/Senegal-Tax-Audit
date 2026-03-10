*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         March 2026
*****************************************************************************************

*****************
** DESCRIPTION  **
*****************
/*
W-main discrepancy analysis:
1) Set globals/directories
2) Load datasetforanalysis.dta
3) Apply sample filters aligned with prior taxpayer-survey analysis
4) Generate C5 dispute variables d1-d21
5) Build W_main and robustness variants
6) Export descriptive stats tables with estpost/esttab (.tex)
7) Export W_main plots (.pdf)
8) Run regressions and export all tables with esttab (.tex)
*/

* Set-up
set more off
clear all
set scheme s1color

global check = 1

*****************
** DIRECTORIES **
*****************
if strpos("`c(username)'","49354415") {  // Alipio's computer
    global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
}
if strpos("`c(username)'","User") {      // Roldan's computer
    global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}
if strpos("`c(username)'","wb648862") {  // Roldan's computer
    global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}

global rawdata      "$rootdir"
global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global wastedata    "$rootdir\Analysis all data\replication_package\Intermediate data"
global output       "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
    global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
}


***************************
** LOAD ANALYSIS DATASET **
***************************
use "datasetforanalysis.dta", clear


*****************************
* APPLY BASELINE PREFILTER
*****************************
keep if selection == 1
drop if safeties == 1
keep if recent == selectionyear
drop recent

****************************************
* GENERATE C5 DISPUTE VARIABLES (d1-d21)
****************************************
*Generate dispute variables
gen d1 = notification if y2 == 1
gen d2 = confirmation  if y2 == 1 
egen d3 = rowmax(notification confirmation) if y2 == 1
gen d4 = notificationvalue > 0 if d1 == 1  & y2 == 1 
gen d5 = confirmationvalue > 0 if d2 == 1 & y2 == 1
egen d6 = rowmax(d4 d5) if y2 == 1
gen d7 = confirmation if d4 == 1 & y2 == 1
gen d8 = d5 if d4 == 1  & y2 == 1 
gen d9 = log(confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d9n = log(notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d10 =  confirmationvalue/notificationvalue > 0.95 & confirmationvalue/notificationvalue < 1.05 if d2 == 1 & d4 == 1 & y2 == 1
gen d11 =  log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d12 =  confirmationvalue/notificationvalue if d2 == 1 & d4 == 1 & y2 == 1
gen d13 = log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d14 =  log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1  & y2 == 1 & confirmationvalue/notificationvalue < 0.95
gen d15 =  confirmationvalue/notificationvalue if d2 == 1 & d4 == 1  & y2 == 1  & confirmationvalue/notificationvalue < 0.95
gen d16 =  log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1  & y2 == 1  & confirmationvalue/notificationvalue < 0.95
 
*For presentation
gen d17 = confirmationvalue > notificationvalue & confirmationvalue != . if d2 == 1 & d4 == 1 & y2 == 1
gen d18 = log(confirmationvalue) if d5 == 1 & d4 == 1 & y2 == 1
gen d19 = log(notificationvalue) if d5 == 1 & d4 == 1 & y2 == 1
gen d20 = log(notificationvalue + 1)
replace d20 = log(confirmationvalue + 1) if d20 == .
gen d21 = log(confirmationvalue)

************************************
* W-MAIN CONSTRUCTION + SANITY CHECKS
************************************
gen W_main = (notificationvalue - confirmationvalue) / notificationvalue ///
    if y2 == 1 & notification == 1 & confirmation == 1 & notificationvalue > 0
label var W_main "W_main = (notification-confirmation)/notification"

gen W_neg = W_main < 0 if W_main < .
label var W_neg "Share W_main < 0"

gen W_in_unit = W_main >= 0 & W_main <= 1 if W_main < .
label var W_in_unit "Share 0 <= W_main <= 1"

gen q32_bad = 10 - q32 if q32 < .
label var q32_bad "Perceived dishonesty (10-q32)"

local w_sample "q1 != . & W_main < ."

quietly summarize W_main if `w_sample', detail
local w_p1 = r(p1)
local w_p95 = r(p95)
local w_p99 = r(p99)
local w_median = r(p50)
local w_mean = r(mean)
local w_n = r(N)

gen W_winsor = W_main
replace W_winsor = `w_p1' if W_winsor < `w_p1' & W_winsor < .
replace W_winsor = `w_p99' if W_winsor > `w_p99' & W_winsor < .
label var W_winsor "W_main winsorized at p1/p99"

di as text "W_main estimation sample (q1!=. & W_main!=.): `w_n'"
di as text "W_main mean: `w_mean'"
di as text "W_main median (p50): `w_median'"
di as text "W_main p95: `w_p95'"

************************************
* DESCRIPTIVE TABLES (ESTTAB TO TEX)
************************************
estimates drop _all

* Main descriptive moments for W_main by pooled/full/desk
quietly estpost summarize W_main if `w_sample', detail
eststo w_all
quietly estpost summarize W_main if `w_sample' & x2 == 1, detail
eststo w_full
quietly estpost summarize W_main if `w_sample' & x2 == 0, detail
eststo w_desk

#delim ;
esttab w_all w_full w_desk
    using "$output\w_main_descriptive_stats.tex",
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p1(fmt(3)) p5(fmt(3)) p10(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3)) p90(fmt(3)) p95(fmt(3)) p99(fmt(3)) max(fmt(3))")
    mtitles("All audited survey firms" "Full audits" "Desk audits")
    label nonumber noobs
    prehead("") posthead(\hline) postfoot("\hline")
    replace
    substitute(\_ _)
;
#delim cr

* Shares table for W_main tail sanity checks
estimates drop _all
quietly estpost summarize W_neg W_in_unit if `w_sample'
eststo ws_all
quietly estpost summarize W_neg W_in_unit if `w_sample' & x2 == 1
eststo ws_full
quietly estpost summarize W_neg W_in_unit if `w_sample' & x2 == 0
eststo ws_desk

#delim ;
esttab ws_all ws_full ws_desk
    using "$output\w_main_share_stats.tex",
    cells("mean(fmt(3)) count(fmt(0))")
    mtitles("All audited survey firms" "Full audits" "Desk audits")
    label nonumber noobs
    prehead("") posthead(\hline) postfoot("\hline")
    replace
    substitute(\_ _)
;
#delim cr

* W_main moments by selection method groups
estimates drop _all
local method_models ""
local method_titles ""
foreach m in dgid overlap algorithm random horsprogramme {
    quietly count if `w_sample' & `m' == 1
    if r(N) > 0 {
        quietly estpost summarize W_main if `w_sample' & `m' == 1, detail
        eststo wm_`m'
        local method_models "`method_models' wm_`m'"
        if "`m'" == "dgid" local method_titles `"`method_titles' "Inspectors""'
        if "`m'" == "overlap" local method_titles `"`method_titles' "Overlap""'
        if "`m'" == "algorithm" local method_titles `"`method_titles' "Algorithm""'
        if "`m'" == "random" local method_titles `"`method_titles' "Random""'
        if "`m'" == "horsprogramme" local method_titles `"`method_titles' "Ad hoc""'
    }
}

if "`method_models'" != "" {
    #delim ;
    esttab `method_models'
        using "$output\w_main_descriptive_by_method.tex",
        cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3)) p95(fmt(3))")
        mtitles(`method_titles')
        label nonumber noobs
        prehead("") posthead(\hline) postfoot("\hline")
        replace
        substitute(\_ _)
    ;
    #delim cr
}

******************
* W-MAIN PLOTS
******************
preserve
keep if `w_sample'

histogram W_main, fraction color(navy%35) lcolor(navy) ///
    xtitle("W_main = (notification - confirmation) / notification") ///
    ytitle("Fraction") ///
    title("Distribution of W_main") ///
    graphregion(color(white))
graph export "$output\w_main_histogram.pdf", as(pdf) replace

twoway ///
    (kdensity W_main if x2 == 1, lcolor(navy) lwidth(medthick)) ///
    (kdensity W_main if x2 == 0, lcolor(orange_red) lpattern(dash) lwidth(medthick)), ///
    legend(order(1 "Full audits" 2 "Desk audits") pos(6) ring(0) rows(1)) ///
    xtitle("W_main = (notification - confirmation) / notification") ///
    ytitle("Density") ///
    title("W_main density by audit type") ///
    graphregion(color(white))
graph export "$output\w_main_density_by_x2.pdf", as(pdf) replace

restore

**************************************
* REGRESSIONS (ALL TABLES VIA ESTTAB)
**************************************
local outcomes "q35 q34 q32_bad q41 evaluation"
local reg_sample "q1 != . & W_main < ."

foreach y of local outcomes {
    estimates drop _all
    local spec = 0

    * Baseline pooled (parsimonious)
    local ++spec
    quietly eststo r`spec': reghdfe `y' W_main i.x2 if `reg_sample', vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * Controlled pooled
    local ++spec
    quietly eststo r`spec': reghdfe `y' W_main algorithm overlap random horsprogramme i.x2 ///
        if `reg_sample', a(selectionyear center) vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * Full audits only
    local ++spec
    quietly eststo r`spec': reghdfe `y' W_main if `reg_sample' & x2 == 1, vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * Desk audits only
    local ++spec
    quietly eststo r`spec': reghdfe `y' W_main if `reg_sample' & x2 == 0, vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * W robustness: winsorized W
    local ++spec
    quietly eststo r`spec': reghdfe `y' W_winsor i.x2 if `reg_sample', vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * C5 robustness: ratio d12
    local ++spec
    quietly eststo r`spec': reghdfe `y' d12 i.x2 if q1 != . & d12 < ., vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    * C5 robustness: log-ratio d11
    local ++spec
    quietly eststo r`spec': reghdfe `y' d11 i.x2 if q1 != . & d11 < ., vce(robust)
    quietly summarize `y' if e(sample) == 1
    estadd scalar meanout = r(mean)

    #delim ;
    esttab r1 r2 r3 r4 r5 r6 r7
        using "$output\w_main_reg_`y'.tex",
        order(W_main W_winsor d12 d11 1.x2 algorithm overlap random horsprogramme)
        keep(W_main W_winsor d12 d11 1.x2 algorithm overlap random horsprogramme)
        label se
        mtitles("Baseline pooled" "Controlled pooled" "Full only" "Desk only" "Winsor W" "Ratio d12" "Log-ratio d11")
        s(N r2 meanout, label("N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        b(%5.3f) se(%5.3f)
        coeflabels(W_main "W_main" W_winsor "W_main (winsor)" d12 "Confirmation/notification" d11 "log(confirmation/notification)" 1.x2 "Full audit (x2=1)" algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random" horsprogramme "Ad hoc")
        prehead("") posthead(\hline) postfoot("\hline")
        replace
        substitute(\_ _)
    ;
    #delim cr

    quietly count if e(sample) == 1
    di as text "Outcome `y': N in last spec = " r(N)
}

*****************************
* FINAL LIGHT DIAGNOSTICS
*****************************
quietly count
local n_after_filter = r(N)
quietly count if `reg_sample'
local n_reg_sample = r(N)
quietly count if `reg_sample' & W_main < 0
local n_wneg = r(N)

di as text "N after base + recent filters: `n_after_filter'"
di as text "N regression sample (q1!=. & W_main!=.): `n_reg_sample'"
di as text "N with W_main < 0 in regression sample: `n_wneg'"
