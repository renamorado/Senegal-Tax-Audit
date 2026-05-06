*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         April 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the full-audit version of Table 8 and then
* re-estimates the same table adding a sixth column with predicted
* evasion controls: linear yhatrf, quadratic yhatrf, and grouped-bin
* robustness controls.

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

global table8_analysisdata "$analysisdata\datasetforanalysis.dta"
global table8_predicted "$analysisdata\fullaudits_predicted.dta"

************************************************************
* Shared table metadata
************************************************************
local table_replicated "$output\table8_fullaudits_replicated.tex"
local table_yhatrf "$output\table8_fullaudits_yhatrf_control.tex"
local table_yhatrf_quadratic "$output\table8_fullaudits_yhatrf_quadratic_control.tex"
local table_yhatrf_deciles "$output\table8_fullaudits_yhatrf_deciles_control.tex"
local table_yhatrf_quintiles "$output\table8_fullaudits_yhatrf_quintiles_control.tex"
local table_yhatrf_bin15 "$output\table8_fullaudits_yhatrf_15bins_control.tex"
local table_yhatrf_bin20 "$output\table8_fullaudits_yhatrf_20bins_control.tex"
local table_yhatrf_topsplit "$output\table8_fullaudits_yhatrf_topsplit_control.tex"
local table_yhatrf_bin_support "$output\table8_fullaudits_yhatrf_bin_support.tex"

local panel_a_header_5 `"\multicolumn{6}{l}{\textbf{A: Outcome P(Execution)}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) \\ \midrule"'
local panel_b_header_5 `"\midrule \multicolumn{6}{l}{\textbf{B: Outcome P(Detection|Execution)}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) \\ \midrule"'
local panel_c_header_5 `"\midrule \multicolumn{6}{l}{\textbf{C: Outcome log(evasion)|Detection}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) \\ \midrule"'

local panel_a_header_6 `"\multicolumn{7}{l}{\textbf{A: Outcome P(Execution)}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule"'
local panel_b_header_6 `"\midrule \multicolumn{7}{l}{\textbf{B: Outcome P(Detection|Execution)}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule"'
local panel_c_header_6 `"\midrule \multicolumn{7}{l}{\textbf{C: Outcome log(evasion)|Detection}} \\ \multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule"'

local stats_panel_ab `"stats(N r2 pp, labels("N" "R2" "Mean outcome"))"'
local stats_panel_c_5 `"stats(turn prof prod char N r2 pp, labels("Turnover" "Profit rate" "Productivity" "Firm char." "N" "R2" "Mean outcome"))"'
local stats_panel_c_6 `"stats(turn prof prod char pred N r2 pp, labels("Turnover" "Profit rate" "Productivity" "Firm char." "Predicted evasion" "N" "R2" "Mean outcome"))"'

local turnover_controls "L1turnover L1turnoversq L1turnovercu"
local profit_controls "L1profitrate L1profitratesq L1profitratecu"
local productivity_controls "L1productivity L1productivitysq L1productivitycu"
local char_controls "distance durationcar firmage"

************************************************************
* 1. Build the full-audit Table 8 sample from datasetforanalysis
************************************************************
use "$table8_analysisdata", clear
keep if selection == 1
 drop if safeties == 1
keep if x2 == 1

gen rowid_table8 = _n

tempfile table8_master table8_yhatrf table8_prepared
save `table8_master', replace

************************************************************
* 2. Attach predicted evasion from fullaudits_predicted
************************************************************
use "$table8_predicted", clear
keep if selection == 1
drop if safeties == 1
keep if x2 == 1

gen rowid_table8 = _n
keep rowid_table8 yhatrf
save `table8_yhatrf', replace

use `table8_master', clear
merge 1:1 rowid_table8 using `table8_yhatrf'
assert _merge == 3
drop _merge

capture confirm variable yhatrf
if _rc {
    di as error "Variable yhatrf not found after merging full-audit predictions."
    exit 111
}

capture drop yhatrf_decile
capture drop yhatrf_quintile
capture drop yhatrf_bin15
capture drop yhatrf_bin20
capture drop yhatrf_decile_topsplit
capture drop yhatrf_decile9_half
capture drop yhatrf_decile10_half
* The selected full-audit samples align row-for-row across datasetforanalysis
* and fullaudits_predicted; rowid_table8 preserves the legacy Table 8 baseline
* while attaching yhatrf for the sixth-column robustness variants.
xtile yhatrf_decile = yhatrf if yhatrf != . , nq(10)
xtile yhatrf_quintile = yhatrf if yhatrf != . , nq(5)
xtile yhatrf_bin15 = yhatrf if yhatrf != . , nq(15)
xtile yhatrf_bin20 = yhatrf if yhatrf != . , nq(20)

* Top-tail flexibility check: preserve deciles 1-8 and split deciles 9 and 10.
gen yhatrf_decile_topsplit = yhatrf_decile
xtile yhatrf_decile9_half = yhatrf if yhatrf_decile == 9, nq(2)
xtile yhatrf_decile10_half = yhatrf if yhatrf_decile == 10, nq(2)
replace yhatrf_decile_topsplit = 9 if yhatrf_decile == 9 & yhatrf_decile9_half == 1
replace yhatrf_decile_topsplit = 10 if yhatrf_decile == 9 & yhatrf_decile9_half == 2
replace yhatrf_decile_topsplit = 11 if yhatrf_decile == 10 & yhatrf_decile10_half == 1
replace yhatrf_decile_topsplit = 12 if yhatrf_decile == 10 & yhatrf_decile10_half == 2
drop yhatrf_decile9_half yhatrf_decile10_half

file open support using `"`table_yhatrf_bin_support'"', write replace
file write support "\begin{tabular}{llrrrrc}" _n
file write support "\toprule" _n
file write support "Specification & Sample & Bin & Total N & Algorithm N & Inspector N & Both methods \\" _n
file write support "\midrule" _n
foreach spec in bin15 bin20 topsplit {
    if "`spec'" == "bin15" {
        local binvar "yhatrf_bin15"
        local speclabel "15 bins"
    }
    if "`spec'" == "bin20" {
        local binvar "yhatrf_bin20"
        local speclabel "20 bins"
    }
    if "`spec'" == "topsplit" {
        local binvar "yhatrf_decile_topsplit"
        local speclabel "Top-split deciles"
    }
    quietly levelsof `binvar', local(binlevels)
    foreach b of local binlevels {
        quietly count if `binvar' == `b'
        local total_n = r(N)
        quietly count if `binvar' == `b' & algorithm == 1
        local alg_n = r(N)
        quietly count if `binvar' == `b' & algorithm == 0
        local insp_n = r(N)
        local both_methods "No"
        if `alg_n' > 0 & `insp_n' > 0 local both_methods "Yes"
        file write support "`speclabel' & Full audits & `b' & `total_n' & `alg_n' & `insp_n' & `both_methods' \\" _n
    }
}
file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

drop rowid_table8
save `table8_prepared', replace

************************************************************
* 3. Export Table 8 variants
************************************************************
foreach spec in replicated yhatrf yhatrf_quadratic yhatrf_deciles yhatrf_quintiles yhatrf_bin15 yhatrf_bin20 yhatrf_topsplit {
    local table_out "`table_replicated'"
    local extra_controls ""
    local maxcol 5
    local prehead "\begin{tabular}{lccccc} \toprule"
    local panel_a_header "`panel_a_header_5'"
    local panel_b_header "`panel_b_header_5'"
    local panel_c_header "`panel_c_header_5'"
    local stats_panel_c "`stats_panel_c_5'"

    if "`spec'" == "yhatrf" {
        local table_out "`table_yhatrf'"
        local extra_controls "yhatrf"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_quadratic" {
        local table_out "`table_yhatrf_quadratic'"
        local extra_controls "c.yhatrf##c.yhatrf"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_deciles" {
        local table_out "`table_yhatrf_deciles'"
        local extra_controls "ib1.yhatrf_decile"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_quintiles" {
        local table_out "`table_yhatrf_quintiles'"
        local extra_controls "ib1.yhatrf_quintile"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_bin15" {
        local table_out "`table_yhatrf_bin15'"
        local extra_controls "ib1.yhatrf_bin15"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_bin20" {
        local table_out "`table_yhatrf_bin20'"
        local extra_controls "ib1.yhatrf_bin20"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }
    if "`spec'" == "yhatrf_topsplit" {
        local table_out "`table_yhatrf_topsplit'"
        local extra_controls "ib1.yhatrf_decile_topsplit"
        local maxcol 6
        local prehead "\begin{tabular}{lcccccc} \toprule"
        local panel_a_header "`panel_a_header_6'"
        local panel_b_header "`panel_b_header_6'"
        local panel_c_header "`panel_c_header_6'"
        local stats_panel_c "`stats_panel_c_6'"
    }

    ************************************************
    * Panel A: P(Execution)
    ************************************************
    use `table8_prepared', clear
    estimates drop _all
    local estlist ""

    forvalues col = 1/`maxcol' {
        local rhs_controls ""
        local turn "No"
        local prof "No"
        local prod "No"
        local char "No"
        local pred "No"

        if `col' >= 2 {
            local rhs_controls "`rhs_controls' `turnover_controls'"
            local turn "Yes"
        }
        if `col' >= 3 {
            local rhs_controls "`rhs_controls' `profit_controls'"
            local prof "Yes"
        }
        if `col' >= 4 {
            local rhs_controls "`rhs_controls' `productivity_controls'"
            local prod "Yes"
        }
        if `col' >= 5 {
            local rhs_controls "`rhs_controls' `char_controls'"
            local char "Yes"
        }
        if `col' == 6 {
            local rhs_controls "`rhs_controls' `extra_controls'"
            local pred "Yes"
        }

        eststo panela_`col'_`spec': reghdfe y2 algorithm overlap random safeties `rhs_controls', ///
            a(inspectorclusteryear) vce(robust)

        estadd local turn "`turn'"
        estadd local prof "`prof'"
        estadd local prod "`prod'"
        estadd local char "`char'"
        estadd local pred "`pred'"

        quietly summarize y2 if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' panela_`col'_`spec'"
    }

    #delim ;
    esttab `estlist'
        using `"`table_out'"',
        replace fragment booktabs
        prehead("`prehead'")
        posthead("`panel_a_header'")
        postfoot("")
        order(algorithm)
        keep(algorithm)
        coeflabels(algorithm "Algorithm")
        b(%5.3f) se(%5.3f)
        `stats_panel_ab'
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        nomtitles nonumbers collabels(none) nonotes
        substitute(\_ _)
    ;
    #delim cr

    ************************************************
    * Panel B: P(Detection|Execution)
    ************************************************
    use `table8_prepared', clear
    estimates drop _all
    local estlist ""
    gen y3_dep = y3
    replace y3_dep = . if y2 == 0

    forvalues col = 1/`maxcol' {
        local rhs_controls ""
        local turn "No"
        local prof "No"
        local prod "No"
        local char "No"
        local pred "No"

        if `col' >= 2 {
            local rhs_controls "`rhs_controls' `turnover_controls'"
            local turn "Yes"
        }
        if `col' >= 3 {
            local rhs_controls "`rhs_controls' `profit_controls'"
            local prof "Yes"
        }
        if `col' >= 4 {
            local rhs_controls "`rhs_controls' `productivity_controls'"
            local prod "Yes"
        }
        if `col' >= 5 {
            local rhs_controls "`rhs_controls' `char_controls'"
            local char "Yes"
        }
        if `col' == 6 {
            local rhs_controls "`rhs_controls' `extra_controls'"
            local pred "Yes"
        }

        eststo panelb_`col'_`spec': reghdfe y3_dep algorithm overlap random safeties `rhs_controls', ///
            a(inspectorclusteryear) vce(robust)

        estadd local turn "`turn'"
        estadd local prof "`prof'"
        estadd local prod "`prod'"
        estadd local char "`char'"
        estadd local pred "`pred'"

        quietly summarize y3_dep if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' panelb_`col'_`spec'"
    }

    #delim ;
    esttab `estlist'
        using `"`table_out'"',
        append fragment booktabs
        posthead("`panel_b_header'")
        postfoot("")
        order(algorithm)
        keep(algorithm)
        coeflabels(algorithm "Algorithm")
        b(%5.3f) se(%5.3f)
        `stats_panel_ab'
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        nomtitles nonumbers collabels(none) nonotes
        substitute(\_ _)
    ;
    #delim cr

    ************************************************
    * Panel C: log(evasion)|Detection
    ************************************************
    use `table8_prepared', clear
    estimates drop _all
    local estlist ""
    gen y4_dep = y4
    replace y4_dep = . if y2 == 0
    replace y4_dep = . if y4_dep == 0
    replace y4_dep = . if y3 == 0

    forvalues col = 1/`maxcol' {
        local rhs_controls ""
        local turn "No"
        local prof "No"
        local prod "No"
        local char "No"
        local pred "No"

        if `col' >= 2 {
            local rhs_controls "`rhs_controls' `turnover_controls'"
            local turn "Yes"
        }
        if `col' >= 3 {
            local rhs_controls "`rhs_controls' `profit_controls'"
            local prof "Yes"
        }
        if `col' >= 4 {
            local rhs_controls "`rhs_controls' `productivity_controls'"
            local prod "Yes"
        }
        if `col' >= 5 {
            local rhs_controls "`rhs_controls' `char_controls'"
            local char "Yes"
        }
        if `col' == 6 {
            local rhs_controls "`rhs_controls' `extra_controls'"
            local pred "Yes"
        }

        eststo panelc_`col'_`spec': reghdfe y4_dep algorithm overlap random safeties `rhs_controls', ///
            a(inspectorclusteryear) vce(robust)

        estadd local turn "`turn'"
        estadd local prof "`prof'"
        estadd local prod "`prod'"
        estadd local char "`char'"
        estadd local pred "`pred'"

        quietly summarize y4_dep if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' panelc_`col'_`spec'"
    }

    #delim ;
    esttab `estlist'
        using `"`table_out'"',
        append fragment booktabs
        posthead("`panel_c_header'")
        postfoot("\bottomrule \end{tabular}")
        order(algorithm)
        keep(algorithm)
        coeflabels(algorithm "Algorithm")
        b(%5.3f) se(%5.3f)
        `stats_panel_c'
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        nomtitles nonumbers collabels(none) nonotes
        substitute(\_ _)
    ;
    #delim cr
}
