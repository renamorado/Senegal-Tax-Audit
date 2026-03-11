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
Recreate Table 6 / D7-style taxpayer-survey regressions in one main workflow with W:
1) Setup/globals
2) Load datasetforanalysis.dta
3) Baseline sample filters
4) Dispute variables (d1-d21)
5) Survey prep + indexes + W_main
6) Regressions with two panels:
   A) self-reported recent audit
   B) all surveyed firms
7) Export two consolidated tables:
   - w_main_table_indices_recent_all.tex
   - w_main_table_questions_recent_all.tex
*/

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
use "$analysisdata\datasetforanalysis.dta", clear

*****************************
* APPLY BASELINE FILTERS
*****************************
keep if selection == 1
drop if safeties == 1

***********************************************
* RECREATE CLUSTERID
***********************************************
capture confirm variable datenotification
if _rc == 0 {
    sort inspectorclusteryear datenotification
}
else {
    sort inspectorclusteryear
}

capture drop clusterid
egen clusterid = group(inspectorclusteryear)

* Keep consistent selection coding conventions from taxpayer-survey script
replace dgid = 1 if overlap == 1
replace algorithm = 1 if random == 1
replace algorithm = 0 if safeties == 1

****************************************
* SNIPPET 1: DISPUTE VARIABLES (d1-d21)
****************************************
gen d1 = notification if y2 == 1
gen d2 = confirmation if y2 == 1
egen d3 = rowmax(notification confirmation) if y2 == 1
gen d4 = notificationvalue > 0 if d1 == 1 & y2 == 1
gen d5 = confirmationvalue > 0 if d2 == 1 & y2 == 1
egen d6 = rowmax(d4 d5) if y2 == 1
gen d7 = confirmation if d4 == 1 & y2 == 1
gen d8 = d5 if d4 == 1 & y2 == 1
gen d9 = log(confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d9n = log(notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d10 = confirmationvalue/notificationvalue > 0.95 & confirmationvalue/notificationvalue < 1.05 if d2 == 1 & d4 == 1 & y2 == 1
gen d11 = log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d12 = confirmationvalue/notificationvalue if d2 == 1 & d4 == 1 & y2 == 1
gen d13 = log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d14 = log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1 & confirmationvalue/notificationvalue < 0.95
gen d15 = confirmationvalue/notificationvalue if d2 == 1 & d4 == 1 & y2 == 1 & confirmationvalue/notificationvalue < 0.95
gen d16 = log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1 & confirmationvalue/notificationvalue < 0.95
gen d17 = confirmationvalue > notificationvalue & confirmationvalue != . if d2 == 1 & d4 == 1 & y2 == 1
gen d18 = log(confirmationvalue) if d5 == 1 & d4 == 1 & y2 == 1
gen d19 = log(notificationvalue) if d5 == 1 & d4 == 1 & y2 == 1
gen d20 = log(notificationvalue + 1)
replace d20 = log(confirmationvalue + 1) if d20 == .
gen d21 = log(confirmationvalue)

***********************************************
* SNIPPET 2: SURVEY PREP + INDEXES + W VARIABLE
***********************************************
* Recent-audit self-report sample indicator (used only at regression stage)
gen selfreported_audit = .
replace selfreported_audit = 0 if q1 != .
replace selfreported_audit = 1 if q28a >= 2018 & q28a <= 2021
replace selfreported_audit = 1 if q29a >= 2018 & q29a <= 2021

* Index ingredients from taxpayer-survey workflow
replace q34 = . if q34 > 0 & q34 < 1

gen q34_binary = .
replace q34_binary = 0 if q34 < 15
replace q34_binary = 1 if q34 >= 15 & q34 != .

gen q32_inverted = .
replace q32_inverted = -1 * (q32 - 10) if q32 != .

capture which swindex
if _rc {
    di as error "swindex is not installed. Please run: ssc install swindex"
    exit 199
}

swindex q32_inverted q42 q34 if q1 != ., generate(index_corruption) fullrescale displayw
swindex q31 q33 q41 if q1 != ., generate(index_efficiency) fullrescale displayw

* Current discrepancy definition used in regressions

gen W_main = (notificationvalue - confirmationvalue) / notificationvalue /// 
if d5 == 1 & d4 == 1 & y2 == 1 

label var W_main "((Notification - Confirmation ) / Notification)"


/*
gen W_main = log(notificationvalue) - log(confirmationvalue) /// 
if d5 == 1 & d4 == 1 & y2 == 1 

label var W_main "W = log(Notification / Confirmation)"
*/
**************************************
* W COVERAGE TABLE
**************************************
gen cov_base = 1 if q1 != .
label var cov_base "Eligible surveyed firms (q1 observed)"

gen cov_exec = 1 if q1 != . & y2 == 1
label var cov_exec "Executed cases (y2=1)"

gen cov_w = 1 if q1 != . & W_main < .
label var cov_w "Non-missing W"

gen cov_rhs = 1 if q1 != . & W_main < . & algorithm < . & overlap < . & random < . & safeties < . & horsprogramme < .
label var cov_rhs "Non-missing W + method controls"

gen cov_idx_eff = 1 if cov_rhs == 1 & index_efficiency < .
label var cov_idx_eff "Regression sample: Efficiency index"

gen cov_idx_cor = 1 if cov_rhs == 1 & index_corruption < .
label var cov_idx_cor "Regression sample: Corruption index"

gen cov_q34 = 1 if cov_rhs == 1 & q34 < .
label var cov_q34 "Regression sample: Corruption in General (q34)"

gen cov_q35 = 1 if cov_rhs == 1 & q35 < .
label var cov_q35 "Regression sample: Corruption Experience (q35)"

gen cov_q32 = 1 if cov_rhs == 1 & q32 < .
label var cov_q32 "Regression sample: Grade on Honesty (q32)"

gen cov_q42 = 1 if cov_rhs == 1 & q42 < .
label var cov_q42 "Regression sample: Friend at tax Auth. (q42)"

local panel_recent "q1 != . & selfreported_audit == 1"
local panel_all    "q1 != ."

estimates drop _all
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_recent' & x2 == 1
eststo wc_A_full
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_recent' & x2 == 0
eststo wc_A_desk
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_recent'
eststo wc_A_all
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_all' & x2 == 1
eststo wc_B_full
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_all' & x2 == 0
eststo wc_B_desk
quietly estpost summarize cov_base cov_exec cov_w cov_rhs cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42 if `panel_all'
eststo wc_B_all

#delim ;
esttab wc_A_full wc_A_desk wc_A_all wc_B_full wc_B_desk wc_B_all
    using "$output\w_main_coverage_by_method.tex",
    cells("count(fmt(0))")
    collabels(none)
    mtitles("Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits")
    mgroups("Panel A: Recent audit" "Panel B: All surveyed", pattern(1 0 0 1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}))
    label nonumber noobs
    prehead("") posthead(\hline) postfoot("\hline")
    replace
    substitute(\_ _)
;
#delim cr

**************************************
* W SCATTER + DENSITY
**************************************
preserve
keep if q1 != . & W_main < . & notificationvalue < .
twoway ///
    (scatter W_main notificationvalue, mcolor(navy%25) msymbol(o) msize(vsmall)) ///
    (lfit W_main notificationvalue, lcolor(cranberry) lwidth(medthick)), ///
    xtitle("Notification value") ///
    ytitle("W = (Notification - Confirmation) / Notification") ///
    title("W and notification value") ///
    graphregion(color(white))
graph export "$output\w_main_scatter_notification.pdf", as(pdf) replace
restore

preserve
keep if q1 != . & W_main < .
twoway ///
    (kdensity W_main, lcolor(navy) lwidth(medthick)), ///
    xtitle("W = (Notification - Confirmation) / Notification") ///
    ytitle("Density") ///
    title("Distribution of W") ///
    graphregion(color(white))
graph export "$output\w_main_density.pdf", as(pdf) replace
restore

**********************************************
* SNIPPET 3: REGRESSIONS + CONSOLIDATED TABLES
**********************************************
* No explicit W_main<. filter in panel definitions; missing W is handled at model estimation.
local panel_recent "q1 != . & selfreported_audit == 1"
local panel_all    "q1 != ."

local outcomes_idx "index_efficiency index_corruption"
local outcomes_q   "q34 q35 q32 q42"

estimates drop _all

local idx_models_A ""
local idx_models_B ""
local q_models_A   ""
local q_models_B   ""

local idx_model_count = 0
local q_model_count = 0

* Table 6-style FE backbone for index outcomes: a(selectionyear center)
foreach panel in A B {
    if "`panel'" == "A" local panel_if "`panel_recent'"
    if "`panel'" == "B" local panel_if "`panel_all'"

    foreach y of local outcomes_idx {
        forvalues col = 1/3 {
            local col_if ""
            if `col' == 1 local col_if "& x2 == 1"
            if `col' == 2 local col_if "& x2 == 0"

            quietly eststo ri`panel'_`y'_`col': reghdfe `y' W_main algorithm overlap random safeties horsprogramme if `panel_if' `col_if', a(selectionyear center) vce(robust)
            quietly sum `y' if e(sample) == 1
            local meanoutcome = int(100*`r(mean)')/100
            local meanoutcome : di %5.2f `meanoutcome'
            estadd local pp `meanoutcome'
            estadd local N = e(N), replace

            if "`panel'" == "A" local idx_models_A "`idx_models_A' ri`panel'_`y'_`col'"
            if "`panel'" == "B" local idx_models_B "`idx_models_B' ri`panel'_`y'_`col'"
            local ++idx_model_count
        }
    }
}

* D7-style FE backbone for survey question outcomes: a(inspectorclusteryear)
foreach panel in A B {
    if "`panel'" == "A" local panel_if "`panel_recent'"
    if "`panel'" == "B" local panel_if "`panel_all'"

    foreach y of local outcomes_q {
        forvalues col = 1/3 {
            local col_if ""
            if `col' == 1 local col_if "& x2 == 1"
            if `col' == 2 local col_if "& x2 == 0"

            quietly eststo rq`panel'_`y'_`col': reghdfe `y' W_main algorithm overlap random safeties horsprogramme if `panel_if' `col_if', a(inspectorclusteryear) vce(robust)
            quietly sum `y' if e(sample) == 1
            local meanoutcome = int(100*`r(mean)')/100
            local meanoutcome : di %5.2f `meanoutcome'
            estadd local pp `meanoutcome'
            estadd local N = e(N), replace

            if "`panel'" == "A" local q_models_A "`q_models_A' rq`panel'_`y'_`col'"
            if "`panel'" == "B" local q_models_B "`q_models_B' rq`panel'_`y'_`col'"
            local ++q_model_count
        }
    }
}

**************************************
* EXPORT 1: INDEX TABLE (2 PANELS)
**************************************
#delim ;
esttab `idx_models_A'
    using "$output\w_main_table_indices_recent_all.tex",
    order(W_main algorithm overlap random)
    keep(W_main algorithm overlap random)
    label se
    mtitles("Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits")
    mgroups("Efficiency Index" "Corruption Index", pattern(1 0 0 1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}))
    s(N r2 pp, label("N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    b(%5.2f) se(%5.2f)
    coeflabels(W_main "W" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
    prehead("\textbf{A: Surveyed Firms (Self-Reporting a Recent Audit)}")
    posthead(\hline) postfoot("\hline")
    replace
    substitute(\_ _)
;
#delim cr

#delim ;
esttab `idx_models_B'
    using "$output\w_main_table_indices_recent_all.tex",
    order(W_main algorithm overlap random)
    keep(W_main algorithm overlap random)
    label se
    nomtitles
    s(N r2 pp, label("N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    b(%5.2f) se(%5.2f)
    coeflabels(W_main "W" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
    prehead("\textbf{B: All Surveyed Firms}")
    posthead(\hline) postfoot("\hline")
    append
    substitute(\_ _)
;
#delim cr

*****************************************
* EXPORT 2: QUESTION TABLE (2 PANELS)
*****************************************
#delim ;
esttab `q_models_A'
    using "$output\w_main_table_questions_recent_all.tex",
    order(W_main algorithm overlap random)
    keep(W_main algorithm overlap random)
    label se
    mtitles("Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits")
    mgroups("Corruption in General" "Corruption Experience" "Grade on Honesty" "Friend at tax Auth.", pattern(1 0 0 1 0 0 1 0 0 1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}))
    s(N r2 pp, label("N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    b(%5.3f) se(%5.3f)
    coeflabels(W_main "W" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
    prehead("\textbf{A: Surveyed Firms (Self-Reporting a Recent Audit)}")
    posthead(\hline) postfoot("\hline")
    replace
    substitute(\_ _)
;
#delim cr

#delim ;
esttab `q_models_B'
    using "$output\w_main_table_questions_recent_all.tex",
    order(W_main algorithm overlap random)
    keep(W_main algorithm overlap random)
    label se
    nomtitles
    s(N r2 pp, label("N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    b(%5.3f) se(%5.3f)
    coeflabels(W_main "W" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
    prehead("\textbf{B: All Surveyed Firms}")
    posthead(\hline) postfoot("\hline")
    append
    substitute(\_ _)
;
#delim cr

*****************************
* FINAL LIGHT DIAGNOSTICS
*****************************
quietly count if `panel_recent'
local n_recent = r(N)
quietly count if `panel_all'
local n_all = r(N)

di as text "Panel A sample (recent audit): `n_recent'"
di as text "Panel B sample (all surveyed firms): `n_all'"
di as text "Index regressions estimated: `idx_model_count' (expected 12)"
di as text "Question regressions estimated: `q_model_count' (expected 24)"
