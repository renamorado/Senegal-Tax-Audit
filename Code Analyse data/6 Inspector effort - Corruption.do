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
3) Broad sample + method controls (no ex-ante drop of safety/ad hoc groups)
4) Dispute variables (d1-d21)
5) Survey prep + indexes + W (capped baseline + robustness variants)
6) Regressions with two panels for each W variant:
   A) self-reported recent audit
   B) all surveyed firms
7) Export eight consolidated tables:
   - w_main_table_indices_recent_all.tex
   - w_main_table_questions_recent_all.tex
   - w_robust_nonzero_table_indices_recent_all.tex
   - w_robust_nonzero_table_questions_recent_all.tex
   - w_robust_abovemedian_table_indices_recent_all.tex
   - w_robust_abovemedian_table_questions_recent_all.tex
   - w_robust_topquartile_table_indices_recent_all.tex
   - w_robust_topquartile_table_questions_recent_all.tex
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
* Keep broad sample; method differences are absorbed by controls in regressions.

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

* Capped baseline discrepancy: set negative values to zero.
replace W_main = 0 if W_main < 0 & W_main != .
label var W_main "Downward revision (\% of notification)"

* Robustness discrepancy variants.
gen reg_eligible = q1 != . & W_main < . & algorithm < . & overlap < . & random < . & safeties < . & horsprogramme < .
quietly summarize W_main if reg_eligible, detail
scalar w_median = r(p50)
scalar w_p75 = r(p75)
di as text "Pooled median of W_main in regression-eligible sample: " %9.4f w_median
di as text "Pooled p75 of W_main in regression-eligible sample: " %9.4f w_p75

gen W_nonzero = W_main != 0 if W_main < .
label var W_nonzero "Downward revision (\% of notification) $\neq$ 0"

gen W_abovemed = W_main > w_median if W_main < .
label var W_abovemed "Downward revision (\% of notification) $>$ pooled median"

gen W_topquart = W_main >= w_p75 if W_main < .
label var W_topquart "Downward revision (\% of notification) in top quartile"


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

gen cov_w_elig = 1 if q1 != . & d4 == 1 & d5 == 1 & y2 == 1
label var cov_w_elig "W-eligible by construction (d4=1,d5=1,y2=1)"

gen cov_w = 1 if q1 != . & W_main < .
label var cov_w "Non-missing capped W"

gen cov_rhs = 1 if q1 != . & W_main < . & algorithm < . & overlap < . & random < . & safeties < . & horsprogramme < .
label var cov_rhs "Non-missing capped W + method controls"

gen cov_w_nonzero = 1 if cov_rhs == 1 & W_nonzero == 1
label var cov_w_nonzero "Downward revision (\% of notification) $\neq$ 0"

gen cov_w_abovemed = 1 if cov_rhs == 1 & W_abovemed == 1
label var cov_w_abovemed "Downward revision (\% of notification) $>$ pooled median"

gen cov_w_topquart = 1 if cov_rhs == 1 & W_topquart == 1
label var cov_w_topquart "Downward revision (\% of notification) in top quartile"

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

* Shares (percent of base sample by panel-column cell).
gen shr_base = 100 if cov_base == 1
label var shr_base "Eligible surveyed firms (q1 observed), \% of base"

gen shr_exec = 100 * (cov_exec == 1) if cov_base == 1
label var shr_exec "Executed cases (y2=1), \% of base"

gen shr_w_elig = 100 * (cov_w_elig == 1) if cov_base == 1
label var shr_w_elig "W-eligible by construction, \% of base"

gen shr_w = 100 * (cov_w == 1) if cov_base == 1
label var shr_w "Non-missing capped W, \% of base"

gen shr_rhs = 100 * (cov_rhs == 1) if cov_base == 1
label var shr_rhs "Non-missing capped W + controls, \% of base"

gen shr_w_nonzero = 100 * (cov_w_nonzero == 1) if cov_base == 1
label var shr_w_nonzero "Downward revision (\% of notification) $\neq$ 0, \% of base"

gen shr_w_abovemed = 100 * (cov_w_abovemed == 1) if cov_base == 1
label var shr_w_abovemed "Downward revision (\% of notification) $>$ pooled median, \% of base"

gen shr_w_topquart = 100 * (cov_w_topquart == 1) if cov_base == 1
label var shr_w_topquart "Downward revision (\% of notification) in top quartile, \% of base"

gen shr_idx_eff = 100 * (cov_idx_eff == 1) if cov_base == 1
label var shr_idx_eff "Regression sample: Efficiency index, \% of base"

gen shr_idx_cor = 100 * (cov_idx_cor == 1) if cov_base == 1
label var shr_idx_cor "Regression sample: Corruption index, \% of base"

gen shr_q34 = 100 * (cov_q34 == 1) if cov_base == 1
label var shr_q34 "Regression sample: Corruption in General (q34), \% of base"

gen shr_q35 = 100 * (cov_q35 == 1) if cov_base == 1
label var shr_q35 "Regression sample: Corruption Experience (q35), \% of base"

gen shr_q32 = 100 * (cov_q32 == 1) if cov_base == 1
label var shr_q32 "Regression sample: Grade on Honesty (q32), \% of base"

gen shr_q42 = 100 * (cov_q42 == 1) if cov_base == 1
label var shr_q42 "Regression sample: Friend at tax Auth. (q42), \% of base"

local panel_recent "q1 != . & selfreported_audit == 1"
local panel_all    "q1 != ."
local cov_count_vars "cov_base cov_exec cov_w_elig cov_w cov_rhs cov_w_nonzero cov_w_abovemed cov_w_topquart cov_idx_eff cov_idx_cor cov_q34 cov_q35 cov_q32 cov_q42"
local cov_share_vars "shr_base shr_exec shr_w_elig shr_w shr_rhs shr_w_nonzero shr_w_abovemed shr_w_topquart shr_idx_eff shr_idx_cor shr_q34 shr_q35 shr_q32 shr_q42"

estimates drop _all
quietly estpost summarize `cov_count_vars' if `panel_recent' & x2 == 1
eststo wc_A_full
quietly estpost summarize `cov_count_vars' if `panel_recent' & x2 == 0
eststo wc_A_desk
quietly estpost summarize `cov_count_vars' if `panel_recent'
eststo wc_A_all
quietly estpost summarize `cov_count_vars' if `panel_all' & x2 == 1
eststo wc_B_full
quietly estpost summarize `cov_count_vars' if `panel_all' & x2 == 0
eststo wc_B_desk
quietly estpost summarize `cov_count_vars' if `panel_all'
eststo wc_B_all

quietly estpost summarize `cov_share_vars' if `panel_recent' & x2 == 1
eststo ws_A_full
quietly estpost summarize `cov_share_vars' if `panel_recent' & x2 == 0
eststo ws_A_desk
quietly estpost summarize `cov_share_vars' if `panel_recent'
eststo ws_A_all
quietly estpost summarize `cov_share_vars' if `panel_all' & x2 == 1
eststo ws_B_full
quietly estpost summarize `cov_share_vars' if `panel_all' & x2 == 0
eststo ws_B_desk
quietly estpost summarize `cov_share_vars' if `panel_all'
eststo ws_B_all

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

#delim ;
esttab ws_A_full ws_A_desk ws_A_all ws_B_full ws_B_desk ws_B_all
    using "$output\w_main_coverage_by_method.tex",
    cells("mean(fmt(1))")
    collabels(none)
    nomtitles
    label nonumber noobs
    prehead("\hline")
    posthead("")
    postfoot("\hline")
    append
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
* No explicit W<. filter in panel definitions; missing W is handled at model estimation.
local panel_recent "q1 != . & selfreported_audit == 1"
local panel_all    "q1 != ."

local outcomes_idx "index_efficiency index_corruption"
local outcomes_q   "q34 q35 q32 q42"

forvalues s = 1/4 {

    if `s' == 1 {
        local wvar "W_main"
        local wtag "main"
        local wlabel "Downward revision (\% of notification)"
        local out_idx "$output\w_main_table_indices_recent_all.tex"
        local out_q   "$output\w_main_table_questions_recent_all.tex"
    }
    if `s' == 2 {
        local wvar "W_nonzero"
        local wtag "nz"
        local wlabel "Downward revision (\% of notification) $\neq$ 0"
        local out_idx "$output\w_robust_nonzero_table_indices_recent_all.tex"
        local out_q   "$output\w_robust_nonzero_table_questions_recent_all.tex"
    }
    if `s' == 3 {
        local wvar "W_abovemed"
        local wtag "am"
        local wlabel "Downward revision (\% of notification) $>$ median"
        local out_idx "$output\w_robust_abovemedian_table_indices_recent_all.tex"
        local out_q   "$output\w_robust_abovemedian_table_questions_recent_all.tex"
    }
    if `s' == 4 {
        local wvar "W_topquart"
        local wtag "tq"
        local wlabel "Downward revision (\% of notification) in top quartile"
        local out_idx "$output\w_robust_topquartile_table_indices_recent_all.tex"
        local out_q   "$output\w_robust_topquartile_table_questions_recent_all.tex"
    }

    di as text "Running specification for `wvar'"
    di as text "Index output file: `out_idx'"
    di as text "Question output file: `out_q'"

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

        local yi = 0
        foreach y of local outcomes_idx {
            local ++yi
            forvalues col = 1/3 {
                local col_if ""
                if `col' == 1 local col_if "& x2 == 1"
                if `col' == 2 local col_if "& x2 == 0"

                local ename = "i`wtag'`panel'`yi'`col'"
                quietly eststo `ename': reghdfe `y' `wvar' algorithm overlap random safeties horsprogramme if `panel_if' `col_if', a(selectionyear center) vce(robust)
                quietly sum `y' if e(sample) == 1
                local meanoutcome = int(100*`r(mean)')/100
                local meanoutcome : di %5.2f `meanoutcome'
                estadd local pp `meanoutcome'
                estadd local N = e(N), replace

                if "`panel'" == "A" local idx_models_A "`idx_models_A' `ename'"
                if "`panel'" == "B" local idx_models_B "`idx_models_B' `ename'"
                local ++idx_model_count
            }
        }
    }

    * D7-style FE backbone for survey question outcomes: a(inspectorclusteryear)
    foreach panel in A B {
        if "`panel'" == "A" local panel_if "`panel_recent'"
        if "`panel'" == "B" local panel_if "`panel_all'"

        local yq = 0
        foreach y of local outcomes_q {
            local ++yq
            forvalues col = 1/3 {
                local col_if ""
                if `col' == 1 local col_if "& x2 == 1"
                if `col' == 2 local col_if "& x2 == 0"

                local ename = "q`wtag'`panel'`yq'`col'"
                quietly eststo `ename': reghdfe `y' `wvar' algorithm overlap random safeties horsprogramme if `panel_if' `col_if', a(inspectorclusteryear) vce(robust)
                quietly sum `y' if e(sample) == 1
                local meanoutcome = int(100*`r(mean)')/100
                local meanoutcome : di %5.2f `meanoutcome'
                estadd local pp `meanoutcome'
                estadd local N = e(N), replace

                if "`panel'" == "A" local q_models_A "`q_models_A' `ename'"
                if "`panel'" == "B" local q_models_B "`q_models_B' `ename'"
                local ++q_model_count
            }
        }
    }

    **************************************
    * EXPORT 1: INDEX TABLE (2 PANELS)
    **************************************
    #delim ;
    esttab `idx_models_A'
        using "`out_idx'",
        order(`wvar' algorithm overlap random)
        keep(`wvar' algorithm overlap random)
        label se
        mtitles("Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits")
        mgroups("Efficiency Index" "Corruption Index", pattern(1 0 0 1 0 0) ///
            span prefix(\multicolumn{@span}{c}{) suffix(}))
        s(N r2 pp, label("N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        b(%5.2f) se(%5.2f)
        coeflabels(`wvar' "`wlabel'" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
        prehead("\textbf{A: Surveyed Firms (Self-Reporting a Recent Audit)}")
        posthead(\hline) postfoot("\hline")
        replace
        substitute(\_ _)
    ;
    #delim cr

    #delim ;
    esttab `idx_models_B'
        using "`out_idx'",
        order(`wvar' algorithm overlap random)
        keep(`wvar' algorithm overlap random)
        label se
        nomtitles
        s(N r2 pp, label("N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        b(%5.2f) se(%5.2f)
        coeflabels(`wvar' "`wlabel'" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
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
        using "`out_q'",
        order(`wvar' algorithm overlap random)
        keep(`wvar' algorithm overlap random)
        label se
        mtitles("Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits" "Full audits" "Desk audits" "All audits")
        mgroups("Corruption in General" "Corruption Experience" "Grade on Honesty" "Friend at tax Auth.", pattern(1 0 0 1 0 0 1 0 0 1 0 0) ///
            span prefix(\multicolumn{@span}{c}{) suffix(}))
        s(N r2 pp, label("N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        b(%5.3f) se(%5.3f)
        coeflabels(`wvar' "`wlabel'" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
        prehead("\textbf{A: Surveyed Firms (Self-Reporting a Recent Audit)}")
        posthead(\hline) postfoot("\hline")
        replace
        substitute(\_ _)
    ;
    #delim cr

    #delim ;
    esttab `q_models_B'
        using "`out_q'",
        order(`wvar' algorithm overlap random)
        keep(`wvar' algorithm overlap random)
        label se
        nomtitles
        s(N r2 pp, label("N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        b(%5.3f) se(%5.3f)
        coeflabels(`wvar' "`wlabel'" overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacements" horsprogramme "Ad hoc")
        prehead("\textbf{B: All Surveyed Firms}")
        posthead(\hline) postfoot("\hline")
        append
        substitute(\_ _)
    ;
    #delim cr

    di as text "`wvar' index regressions estimated: `idx_model_count' (expected 12)"
    di as text "`wvar' question regressions estimated: `q_model_count' (expected 24)"
}

*****************************
* FINAL LIGHT DIAGNOSTICS
*****************************
quietly count if `panel_recent'
local n_recent = r(N)
quietly count if `panel_all'
local n_all = r(N)

di as text "Panel A sample (recent audit): `n_recent'"
di as text "Panel B sample (all surveyed firms): `n_all'"
