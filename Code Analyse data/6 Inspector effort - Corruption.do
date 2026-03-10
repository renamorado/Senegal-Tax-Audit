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
Case-level sub-analysis:
Discrepancies between notified and confirmed tax amounts vs survey corruption and dissatisfaction outcomes.

Main choices implemented:
- Unit of observation: audit case
- Main sample: selection==1, safeties==0, y2==1
- Main regressor: W_main = (notificationvalue - confirmationvalue) / notificationvalue
- Keep flagged notification imputations (flagnotification==1), as requested
- VCE/FE conventions mimic C5 mix:
    Full (x2==1): absorb(controlbureauannee), vce(cluster controlbureauannee)
    Desk (x2==0): absorb(inspectorclusteryear), vce(robust)
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
di "Output folder: $output"

local outtables "$output\Tables"
cap mkdir "$output"
cap mkdir "`outtables'"

***************************
** LOAD ANALYSIS DATASET **
***************************
local datafile "$analysisdata\datasetforanalysis.dta"
if !fileexists("`datafile'") {
    local datafile "datasetforanalysis.dta"
}
if !fileexists("`datafile'") {
    di as error "Could not find datasetforanalysis.dta in $analysisdata or current folder."
    exit 601
}
use "`datafile'", clear
di "Using data file: `datafile'"

* Required variables check
local must_have "selection safeties y2 x2 firmid notification confirmation notificationvalue confirmationvalue controlbureauannee inspectorclusteryear center selectionyear algorithm overlap random horsprogramme q34 q35 q32 q42 q41 evaluation flagnotification"
local allvars : varlist _all
foreach v of local must_have {
    if strpos(" `allvars' ", " `v' ") == 0 {
        di as error "Missing required variable: `v'"
        exit 111
    }
}

***************************
** SAMPLE + W CONSTRUCTION
***************************
gen byte sample_selected = selection == 1 & safeties == 0
gen byte sample_main     = sample_selected == 1 & y2 == 1

gen double W_main = .
replace W_main = (notificationvalue - confirmationvalue) / notificationvalue if ///
    sample_main == 1 & notification == 1 & confirmation == 1 & ///
    notificationvalue > 0 & notificationvalue < . & confirmationvalue < .

quietly summarize W_main, detail
local w_n   = r(N)
local w_p1  = r(p1)
local w_p99 = r(p99)
local w_p5  = r(p5)
local w_p50 = r(p50)
local w_p95 = r(p95)

gen double W_win = W_main
if `w_n' > 0 {
    replace W_win = `w_p1'  if W_win < `w_p1'  & W_win < .
    replace W_win = `w_p99' if W_win > `w_p99' & W_win < .
}

gen double abs_diff = .
replace abs_diff = notificationvalue - confirmationvalue if ///
    sample_main == 1 & notification == 1 & confirmation == 1 & ///
    notificationvalue > 0 & notificationvalue < . & confirmationvalue < .

gen double abs_diff_mn = abs_diff / 1000000 if abs_diff < .

gen double log_ratio = .
replace log_ratio = log((notificationvalue + 1) / (confirmationvalue + 1)) if ///
    sample_main == 1 & notification == 1 & confirmation == 1 & ///
    notificationvalue >= 0 & confirmationvalue >= 0 & ///
    notificationvalue < . & confirmationvalue < .

gen byte sample_w = W_main < .
gen byte confirmed_gt_notified = confirmationvalue > notificationvalue if sample_w == 1

*********************
** ASSERTIONS/CHECKS
*********************
capture assert W_main == . if sample_main == 1 & notificationvalue <= 0 & notificationvalue < .
if _rc di as error "Warning: W_main nonmissing with nonpositive notificationvalue."

if `w_n' > 0 {
    capture assert W_win >= `w_p1' & W_win <= `w_p99' if W_win < .
    if _rc di as error "Warning: W_win outside expected [p1,p99] bounds."
}

***************************
** DIAGNOSTICS: COUNTS
***************************
quietly count
local n_total_cases = r(N)

quietly count if sample_selected == 1
local n_selected_cases = r(N)
tempvar tag_selected
egen `tag_selected' = tag(firmid) if sample_selected == 1
quietly count if `tag_selected' == 1
local n_selected_firms = r(N)
drop `tag_selected'

quietly count if sample_main == 1
local n_main_cases = r(N)
tempvar tag_main
egen `tag_main' = tag(firmid) if sample_main == 1
quietly count if `tag_main' == 1
local n_main_firms = r(N)
drop `tag_main'

quietly count if sample_w == 1
local n_w_cases = r(N)
tempvar tag_w
egen `tag_w' = tag(firmid) if sample_w == 1
quietly count if `tag_w' == 1
local n_w_firms = r(N)
drop `tag_w'

quietly count if sample_selected == 1 & flagnotification == 1
local n_flag_selected = r(N)

quietly count if sample_main == 1 & flagnotification == 1
local n_flag_main = r(N)

tempvar n_case_per_firm_w
bysort firmid: egen `n_case_per_firm_w' = total(sample_w)
quietly count if sample_w == 1 & `n_case_per_firm_w' > 1
local n_w_repeat_cases = r(N)
tempvar tag_w_repeat
egen `tag_w_repeat' = tag(firmid) if sample_w == 1 & `n_case_per_firm_w' > 1
quietly count if `tag_w_repeat' == 1
local n_w_repeat_firms = r(N)
drop `n_case_per_firm_w' `tag_w_repeat'

quietly summarize confirmed_gt_notified if sample_w == 1, meanonly
local share_confirmed_gt_notified = r(mean)

local outcomes_bribe "q34 q35 q32 q42"
local outcomes_dissat "q41 evaluation"
local outcomes_all "`outcomes_bribe' `outcomes_dissat'"

foreach y of local outcomes_all {
    quietly count if sample_main == 1 & `y' < .
    local n_x_case_`y' = r(N)
    tempvar tag_x
    egen `tag_x' = tag(firmid) if sample_main == 1 & `y' < .
    quietly count if `tag_x' == 1
    local n_x_firm_`y' = r(N)
    drop `tag_x'

    quietly count if sample_w == 1 & `y' < .
    local n_xw_case_`y' = r(N)
    tempvar tag_xw
    egen `tag_xw' = tag(firmid) if sample_w == 1 & `y' < .
    quietly count if `tag_xw' == 1
    local n_xw_firm_`y' = r(N)
    drop `tag_xw'
}

***************************
** MAIN REGRESSIONS
***************************
capture which reghdfe
if _rc {
    di as error "reghdfe is required but not installed."
    exit 199
}

local controls "algorithm overlap random horsprogramme"

foreach y of local outcomes_all {
    * Full baseline
    capture noisily reghdfe `y' W_main if sample_main == 1 & x2 == 1, ///
        a(controlbureauannee) vce(cluster controlbureauannee)
    if _rc == 0 {
        local b_`y'_fb  = _b[W_main]
        local se_`y'_fb = _se[W_main]
        local p_`y'_fb  = 2*ttail(e(df_r), abs(`b_`y'_fb'/`se_`y'_fb'))
        quietly count if e(sample)
        local n_`y'_fb = r(N)
        tempvar tag_reg
        egen `tag_reg' = tag(firmid) if e(sample)
        quietly count if `tag_reg' == 1
        local nf_`y'_fb = r(N)
        drop `tag_reg'
    }
    else {
        local b_`y'_fb = .
        local se_`y'_fb = .
        local p_`y'_fb = .
        local n_`y'_fb = .
        local nf_`y'_fb = .
    }

    * Full controls
    capture noisily reghdfe `y' W_main `controls' if sample_main == 1 & x2 == 1, ///
        a(controlbureauannee) vce(cluster controlbureauannee)
    if _rc == 0 {
        local b_`y'_fc  = _b[W_main]
        local se_`y'_fc = _se[W_main]
        local p_`y'_fc  = 2*ttail(e(df_r), abs(`b_`y'_fc'/`se_`y'_fc'))
        quietly count if e(sample)
        local n_`y'_fc = r(N)
        tempvar tag_reg
        egen `tag_reg' = tag(firmid) if e(sample)
        quietly count if `tag_reg' == 1
        local nf_`y'_fc = r(N)
        drop `tag_reg'
    }
    else {
        local b_`y'_fc = .
        local se_`y'_fc = .
        local p_`y'_fc = .
        local n_`y'_fc = .
        local nf_`y'_fc = .
    }

    * Desk baseline
    capture noisily reghdfe `y' W_main if sample_main == 1 & x2 == 0, ///
        a(inspectorclusteryear) vce(robust)
    if _rc == 0 {
        local b_`y'_db  = _b[W_main]
        local se_`y'_db = _se[W_main]
        local p_`y'_db  = 2*ttail(e(df_r), abs(`b_`y'_db'/`se_`y'_db'))
        quietly count if e(sample)
        local n_`y'_db = r(N)
        tempvar tag_reg
        egen `tag_reg' = tag(firmid) if e(sample)
        quietly count if `tag_reg' == 1
        local nf_`y'_db = r(N)
        drop `tag_reg'
    }
    else {
        local b_`y'_db = .
        local se_`y'_db = .
        local p_`y'_db = .
        local n_`y'_db = .
        local nf_`y'_db = .
    }

    * Desk controls
    capture noisily reghdfe `y' W_main `controls' if sample_main == 1 & x2 == 0, ///
        a(inspectorclusteryear) vce(robust)
    if _rc == 0 {
        local b_`y'_dc  = _b[W_main]
        local se_`y'_dc = _se[W_main]
        local p_`y'_dc  = 2*ttail(e(df_r), abs(`b_`y'_dc'/`se_`y'_dc'))
        quietly count if e(sample)
        local n_`y'_dc = r(N)
        tempvar tag_reg
        egen `tag_reg' = tag(firmid) if e(sample)
        quietly count if `tag_reg' == 1
        local nf_`y'_dc = r(N)
        drop `tag_reg'
    }
    else {
        local b_`y'_dc = .
        local se_`y'_dc = .
        local p_`y'_dc = .
        local n_`y'_dc = .
        local nf_`y'_dc = .
    }
}

***************************
** ROBUSTNESS REGRESSIONS
***************************
foreach y of local outcomes_all {
    * Pooled FE controls with alternative discrepancy metrics
    capture noisily reghdfe `y' W_main `controls' i.x2 if sample_main == 1, ///
        a(selectionyear center) vce(robust)
    if _rc == 0 {
        local rb_`y'_m1  = _b[W_main]
        local rse_`y'_m1 = _se[W_main]
        local rp_`y'_m1  = 2*ttail(e(df_r), abs(`rb_`y'_m1'/`rse_`y'_m1'))
        quietly count if e(sample)
        local rn_`y'_m1 = r(N)
    }
    else {
        local rb_`y'_m1 = .
        local rse_`y'_m1 = .
        local rp_`y'_m1 = .
        local rn_`y'_m1 = .
    }

    capture noisily reghdfe `y' W_win `controls' i.x2 if sample_main == 1, ///
        a(selectionyear center) vce(robust)
    if _rc == 0 {
        local rb_`y'_m2  = _b[W_win]
        local rse_`y'_m2 = _se[W_win]
        local rp_`y'_m2  = 2*ttail(e(df_r), abs(`rb_`y'_m2'/`rse_`y'_m2'))
        quietly count if e(sample)
        local rn_`y'_m2 = r(N)
    }
    else {
        local rb_`y'_m2 = .
        local rse_`y'_m2 = .
        local rp_`y'_m2 = .
        local rn_`y'_m2 = .
    }

    capture noisily reghdfe `y' abs_diff_mn `controls' i.x2 if sample_main == 1, ///
        a(selectionyear center) vce(robust)
    if _rc == 0 {
        local rb_`y'_m3  = _b[abs_diff_mn]
        local rse_`y'_m3 = _se[abs_diff_mn]
        local rp_`y'_m3  = 2*ttail(e(df_r), abs(`rb_`y'_m3'/`rse_`y'_m3'))
        quietly count if e(sample)
        local rn_`y'_m3 = r(N)
    }
    else {
        local rb_`y'_m3 = .
        local rse_`y'_m3 = .
        local rp_`y'_m3 = .
        local rn_`y'_m3 = .
    }

    capture noisily reghdfe `y' log_ratio `controls' i.x2 if sample_main == 1, ///
        a(selectionyear center) vce(robust)
    if _rc == 0 {
        local rb_`y'_m4  = _b[log_ratio]
        local rse_`y'_m4 = _se[log_ratio]
        local rp_`y'_m4  = 2*ttail(e(df_r), abs(`rb_`y'_m4'/`rse_`y'_m4'))
        quietly count if e(sample)
        local rn_`y'_m4 = r(N)
    }
    else {
        local rb_`y'_m4 = .
        local rse_`y'_m4 = .
        local rp_`y'_m4 = .
        local rn_`y'_m4 = .
    }

    capture noisily reghdfe `y' c.W_main##i.x2 `controls' if sample_main == 1, ///
        a(selectionyear center) vce(robust)
    if _rc == 0 {
        local rb_`y'_m5_main  = _b[c.W_main]
        local rse_`y'_m5_main = _se[c.W_main]
        local rp_`y'_m5_main  = 2*ttail(e(df_r), abs(`rb_`y'_m5_main'/`rse_`y'_m5_main'))
        local rb_`y'_m5_int   = _b[1.x2#c.W_main]
        local rse_`y'_m5_int  = _se[1.x2#c.W_main]
        local rp_`y'_m5_int   = 2*ttail(e(df_r), abs(`rb_`y'_m5_int'/`rse_`y'_m5_int'))
        quietly count if e(sample)
        local rn_`y'_m5 = r(N)
    }
    else {
        local rb_`y'_m5_main = .
        local rse_`y'_m5_main = .
        local rp_`y'_m5_main = .
        local rb_`y'_m5_int = .
        local rse_`y'_m5_int = .
        local rp_`y'_m5_int = .
        local rn_`y'_m5 = .
    }
}

***************************
** HELPERS FOR FORMATTING
***************************
capture program drop _fmtcoef
program define _fmtcoef, rclass
    args b se p
    if missing(`b') | missing(`se') {
        return local bstr "."
        return local sestr "(.)"
        exit
    }
    local stars ""
    if `p' < 0.10 local stars "*"
    if `p' < 0.05 local stars "**"
    if `p' < 0.01 local stars "***"
    local bstr : display %9.3f `b'
    local sestr : display %9.3f `se'
    return local bstr "`bstr'`stars'"
    return local sestr "(`sestr')"
end

************************************
** EXPORT MAIN LATEX TABLE (PANELS)
************************************
local maintex "`outtables'\6_corruption_discrepancy_main.tex"
cap erase "`maintex'"
file open fmain using "`maintex'", write replace text

file write fmain "\begin{tabular}{lcccc}" _n
file write fmain "\hline" _n
file write fmain " & Full baseline & Full + controls & Desk baseline & Desk + controls \\\\" _n
file write fmain "\hline" _n
file write fmain "\multicolumn{5}{l}{\textit{Panel A: Bribe/corruption outcomes}} \\\\" _n

foreach y in q34 q35 q32 q42 {
    local ylab "`y'"
    if "`y'" == "q34" local ylab "q34: Informal payment share perception"
    if "`y'" == "q35" local ylab "q35: Ever informal payment (binary)"
    if "`y'" == "q32" local ylab "q32: Inspector honesty rating"
    if "`y'" == "q42" local ylab "q42: Agreement with DGID-connection statement"

    quietly _fmtcoef `b_`y'_fb' `se_`y'_fb' `p_`y'_fb'
    local c1 = r(bstr)
    local s1 = r(sestr)
    quietly _fmtcoef `b_`y'_fc' `se_`y'_fc' `p_`y'_fc'
    local c2 = r(bstr)
    local s2 = r(sestr)
    quietly _fmtcoef `b_`y'_db' `se_`y'_db' `p_`y'_db'
    local c3 = r(bstr)
    local s3 = r(sestr)
    quietly _fmtcoef `b_`y'_dc' `se_`y'_dc' `p_`y'_dc'
    local c4 = r(bstr)
    local s4 = r(sestr)

    file write fmain "`ylab' \\\\" _n
    file write fmain "W main & `c1' & `c2' & `c3' & `c4' \\\\" _n
    file write fmain " & `s1' & `s2' & `s3' & `s4' \\\\" _n
    file write fmain "N & `n_`y'_fb' & `n_`y'_fc' & `n_`y'_db' & `n_`y'_dc' \\\\" _n
    file write fmain "Unique firms & `nf_`y'_fb' & `nf_`y'_fc' & `nf_`y'_db' & `nf_`y'_dc' \\\\" _n
    file write fmain "\hline" _n
}

file write fmain "\multicolumn{5}{l}{\textit{Panel B: Dissatisfaction outcomes}} \\\\" _n

foreach y in q41 evaluation {
    local ylab "`y'"
    if "`y'" == "q41" local ylab "q41: Inspectors discover all hidden amounts (agreement)"
    if "`y'" == "evaluation" local ylab "evaluation: mean(q31,q32,q33)"

    quietly _fmtcoef `b_`y'_fb' `se_`y'_fb' `p_`y'_fb'
    local c1 = r(bstr)
    local s1 = r(sestr)
    quietly _fmtcoef `b_`y'_fc' `se_`y'_fc' `p_`y'_fc'
    local c2 = r(bstr)
    local s2 = r(sestr)
    quietly _fmtcoef `b_`y'_db' `se_`y'_db' `p_`y'_db'
    local c3 = r(bstr)
    local s3 = r(sestr)
    quietly _fmtcoef `b_`y'_dc' `se_`y'_dc' `p_`y'_dc'
    local c4 = r(bstr)
    local s4 = r(sestr)

    file write fmain "`ylab' \\\\" _n
    file write fmain "W main & `c1' & `c2' & `c3' & `c4' \\\\" _n
    file write fmain " & `s1' & `s2' & `s3' & `s4' \\\\" _n
    file write fmain "N & `n_`y'_fb' & `n_`y'_fc' & `n_`y'_db' & `n_`y'_dc' \\\\" _n
    file write fmain "Unique firms & `nf_`y'_fb' & `nf_`y'_fc' & `nf_`y'_db' & `nf_`y'_dc' \\\\" _n
    file write fmain "\hline" _n
}

file write fmain "\multicolumn{5}{l}{\footnotesize Notes: W main = (notification - confirmation)/notification. Main sample: selection==1, safeties==0, y2==1. Full specs cluster by controlbureauannee. Desk specs use robust SE.} \\\\" _n
file write fmain "\end{tabular}" _n
file close fmain

*****************************************
** EXPORT ROBUSTNESS LATEX TABLE
*****************************************
local robtex "`outtables'\6_corruption_discrepancy_robustness.tex"
cap erase "`robtex'"
file open frob using "`robtex'", write replace text

file write frob "\begin{tabular}{lccccc}" _n
file write frob "\hline" _n
file write frob " & W main & W winsor(1,99) & Abs diff (M FCFA) & Log ratio & W main + W main x Desk \\\\" _n
file write frob "\hline" _n

foreach y of local outcomes_all {
    local ylab "`y'"
    if "`y'" == "q34" local ylab "q34"
    if "`y'" == "q35" local ylab "q35"
    if "`y'" == "q32" local ylab "q32"
    if "`y'" == "q42" local ylab "q42"
    if "`y'" == "q41" local ylab "q41"
    if "`y'" == "evaluation" local ylab "evaluation"

    quietly _fmtcoef `rb_`y'_m1' `rse_`y'_m1' `rp_`y'_m1'
    local c1 = r(bstr)
    local s1 = r(sestr)
    quietly _fmtcoef `rb_`y'_m2' `rse_`y'_m2' `rp_`y'_m2'
    local c2 = r(bstr)
    local s2 = r(sestr)
    quietly _fmtcoef `rb_`y'_m3' `rse_`y'_m3' `rp_`y'_m3'
    local c3 = r(bstr)
    local s3 = r(sestr)
    quietly _fmtcoef `rb_`y'_m4' `rse_`y'_m4' `rp_`y'_m4'
    local c4 = r(bstr)
    local s4 = r(sestr)
    quietly _fmtcoef `rb_`y'_m5_main' `rse_`y'_m5_main' `rp_`y'_m5_main'
    local c5 = r(bstr)
    local s5 = r(sestr)
    quietly _fmtcoef `rb_`y'_m5_int' `rse_`y'_m5_int' `rp_`y'_m5_int'
    local cint = r(bstr)
    local sint = r(sestr)

    file write frob "`ylab' \\\\" _n
    file write frob "Main coeff & `c1' & `c2' & `c3' & `c4' & `c5' \\\\" _n
    file write frob " & `s1' & `s2' & `s3' & `s4' & `s5' \\\\" _n
    file write frob "Interaction (Desk x W main) &  &  &  &  & `cint' \\\\" _n
    file write frob " &  &  &  &  & `sint' \\\\" _n
    file write frob "N & `rn_`y'_m1' & `rn_`y'_m2' & `rn_`y'_m3' & `rn_`y'_m4' & `rn_`y'_m5' \\\\" _n
    file write frob "\hline" _n
}

file write frob "\multicolumn{6}{l}{\footnotesize Pooled FE specs absorb selectionyear and center, with controls algorithm overlap random horsprogramme and i.x2 where applicable.} \\\\" _n
file write frob "\end{tabular}" _n
file close frob

*****************************************
** EXPORT MERGE/DIAGNOSTIC LATEX TABLE
*****************************************
local diagtex "`outtables'\6_corruption_merge_diagnostics.tex"
cap erase "`diagtex'"
file open fdiag using "`diagtex'", write replace text

file write fdiag "\begin{tabular}{lrr}" _n
file write fdiag "\hline" _n
file write fdiag "Step & Cases & Unique firms \\\\" _n
file write fdiag "\hline" _n
file write fdiag "All observations in datasetforanalysis & `n_total_cases' & . \\\\" _n
file write fdiag "Selected non-safety cases (selection==1, safeties==0) & `n_selected_cases' & `n_selected_firms' \\\\" _n
file write fdiag "Main analysis sample (+ y2==1) & `n_main_cases' & `n_main_firms' \\\\" _n
file write fdiag "W main nonmissing & `n_w_cases' & `n_w_firms' \\\\" _n
file write fdiag "Flag-notification cases in selected sample & `n_flag_selected' & . \\\\" _n
file write fdiag "Flag-notification cases in main sample & `n_flag_main' & . \\\\" _n
file write fdiag "W sample cases in repeated firms & `n_w_repeat_cases' & `n_w_repeat_firms' \\\\" _n
file write fdiag "\hline" _n
file write fdiag "\multicolumn{3}{l}{Outcome availability in main sample and after requiring W main} \\\\" _n
file write fdiag "q34 & `n_x_case_q34' / `n_xw_case_q34' & `n_x_firm_q34' / `n_xw_firm_q34' \\\\" _n
file write fdiag "q35 & `n_x_case_q35' / `n_xw_case_q35' & `n_x_firm_q35' / `n_xw_firm_q35' \\\\" _n
file write fdiag "q32 & `n_x_case_q32' / `n_xw_case_q32' & `n_x_firm_q32' / `n_xw_firm_q32' \\\\" _n
file write fdiag "q42 & `n_x_case_q42' / `n_xw_case_q42' & `n_x_firm_q42' / `n_xw_firm_q42' \\\\" _n
file write fdiag "q41 & `n_x_case_q41' / `n_xw_case_q41' & `n_x_firm_q41' / `n_xw_firm_q41' \\\\" _n
file write fdiag "evaluation & `n_x_case_evaluation' / `n_xw_case_evaluation' & `n_x_firm_evaluation' / `n_xw_firm_evaluation' \\\\" _n
file write fdiag "\hline" _n
file write fdiag "\multicolumn{3}{l}{\footnotesize Entries of the form A/B denote nonmissing outcome counts in main sample / in W-nonmissing sample.} \\\\" _n
file write fdiag "\multicolumn{3}{l}{\footnotesize Share(confirmation > notification) in W sample = `share_confirmed_gt_notified'.} \\\\" _n
file write fdiag "\end{tabular}" _n
file close fdiag

*****************************************
** DATA PROCESSING NOTE (TEXT)
*****************************************
local notefile "`outtables'\6_corruption_data_processing_note.txt"
cap erase "`notefile'"
file open fnote using "`notefile'", write replace text

file write fnote "Data processing note: discrepancy-corruption sub-analysis" _n
file write fnote "Date: `c(current_date)'" _n
file write fnote "" _n
file write fnote "Admin amount variables used for W:" _n
file write fnote "- notificationvalue, confirmationvalue, notification, confirmation, y2, flagnotification." _n
file write fnote "- Upstream cleaning (from dataset construction): negative components set to missing; components winsorized at p99 by bureau; totals built as rowtotals." _n
file write fnote "- Replacement rule retained in main analysis: if notification total is zero and confirmation > 0, notification total is replaced with confirmation total and flagnotification=1." _n
file write fnote "" _n
file write fnote "Survey outcomes used for X:" _n
file write fnote "- Bribe/corruption: q34 q35 q32 q42." _n
file write fnote "- Dissatisfaction/experience: q41 evaluation." _n
file write fnote "- Cleaning inherited from dataset construction: special codes {99,999,9999,99999,0.999} recoded to missing; q35 recoded to binary with 0->missing, 1->0, 2->1; for q40-q44, value 1 ('do not know') recoded to missing." _n
file write fnote "" _n
file write fnote "Current run sample accounting (cases):" _n
file write fnote "- selected non-safety: `n_selected_cases'" _n
file write fnote "- main (conducted) sample: `n_main_cases'" _n
file write fnote "- W nonmissing sample: `n_w_cases'" _n
file write fnote "" _n
file write fnote "W distribution diagnostics (W nonmissing sample):" _n
file write fnote "- N = `w_n'" _n
file write fnote "- p1 = `w_p1', p5 = `w_p5', p50 = `w_p50', p95 = `w_p95', p99 = `w_p99'" _n
file write fnote "- share(confirmation > notification) = `share_confirmed_gt_notified'" _n
file close fnote

*****************************************
** LOG SUMMARY
*****************************************
di "======================================================="
di "Corruption discrepancy analysis completed."
di "Main table: `maintex'"
di "Robustness table: `robtex'"
di "Diagnostics table: `diagtex'"
di "Data processing note: `notefile'"
di "Main sample cases (selection==1 & safeties==0 & y2==1): `n_main_cases'"
di "W nonmissing cases: `n_w_cases'"
di "======================================================="

