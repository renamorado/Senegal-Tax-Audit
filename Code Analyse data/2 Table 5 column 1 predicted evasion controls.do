*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         May 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file consolidates variants of Table 5 Panel A1 Column 1 for full audits.
* It re-estimates Number of Agents while varying the predicted-evasion control
* specification, and exports screenshot-style LaTeX fragments using the current
* RF prediction and the optimization-weighted RF prediction.

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

local table5_full_input_current "$analysisdata\fullaudits_predicted.dta"
local table5_full_input_optweighted "$analysisdata\audits_predicted_2.dta"

foreach yhatrf_source in current optweighted {
    if "`yhatrf_source'" == "current" {
        local table5_full_input "`table5_full_input_current'"
        local table_col1_controls "$output\table5_col1_ninspectors_predicted_evasion_control_comparison.tex"
        local table_col1_bin_support "$output\table5_col1_ninspectors_predicted_evasion_bin_support.tex"
    }
    if "`yhatrf_source'" == "optweighted" {
        local table5_full_input "`table5_full_input_optweighted'"
        local table_col1_controls "$output\table5_col1_ninspectors_predicted_evasion_control_comparison_optimization_weighted.tex"
        local table_col1_bin_support "$output\table5_col1_ninspectors_predicted_evasion_bin_support_optimization_weighted.tex"
    }

************************************************************
* 1. Import the predicted full-audit data
************************************************************
use "`table5_full_input'", clear

capture confirm variable yhatrf
if _rc {
    di as error "Variable yhatrf not found in `table5_full_input'."
    exit 111
}

************************************************************
* 2. Prepare Table 5 Panel A1 Column 1 sample
************************************************************
keep if selection == 1
drop if safeties == 1
keep if x2 == 1

* Match the Table 5 exporter: Number of Agents is observed only for
* cases executed by inspectors.
replace y16 = . if y2 == 0

capture drop table5_col1_stratum
egen table5_col1_stratum = group(inspectorclusteryear), missing

capture drop table5_col1_decile_list
capture drop table5_col1_quintile_list
capture drop table5_col1_topsplit_list

capture drop yhatrf_quintile_col1
capture drop yhatrf_decile_col1
capture drop yhatrf_decile_topsplit_col1
capture drop yhatrf_decile9_half_col1
capture drop yhatrf_decile10_half_col1
capture drop yhatrf_sq_col1
capture drop yhatrf_cu_col1
capture drop yhatrf_rank_col1
capture drop yhatrf_nonmissing_col1

egen yhatrf_quintile_col1 = xtile(yhatrf) if yhatrf != ., by(table5_col1_stratum) nq(5)
egen yhatrf_decile_col1 = xtile(yhatrf) if yhatrf != ., by(table5_col1_stratum) nq(10)

gen yhatrf_sq_col1 = yhatrf^2 if yhatrf != .
gen yhatrf_cu_col1 = yhatrf^3 if yhatrf != .

gen yhatrf_decile_topsplit_col1 = yhatrf_decile_col1
egen yhatrf_decile9_half_col1 = xtile(yhatrf) if yhatrf_decile_col1 == 9, by(table5_col1_stratum) nq(2)
egen yhatrf_decile10_half_col1 = xtile(yhatrf) if yhatrf_decile_col1 == 10, by(table5_col1_stratum) nq(2)
replace yhatrf_decile_topsplit_col1 = 9 if yhatrf_decile_col1 == 9 & yhatrf_decile9_half_col1 == 1
replace yhatrf_decile_topsplit_col1 = 10 if yhatrf_decile_col1 == 9 & yhatrf_decile9_half_col1 == 2
replace yhatrf_decile_topsplit_col1 = 11 if yhatrf_decile_col1 == 10 & yhatrf_decile10_half_col1 == 1
replace yhatrf_decile_topsplit_col1 = 12 if yhatrf_decile_col1 == 10 & yhatrf_decile10_half_col1 == 2
drop yhatrf_decile9_half_col1 yhatrf_decile10_half_col1

gen yhatrf_nonmissing_col1 = yhatrf != .
gsort table5_col1_stratum -yhatrf_nonmissing_col1 -yhatrf
by table5_col1_stratum: gen yhatrf_rank_col1 = sum(yhatrf != .)
replace yhatrf_rank_col1 = . if yhatrf == .
label var yhatrf_rank_col1 "Integer rank of predicted evasion within inspector-year FE, highest predicted evasion = 1"
drop yhatrf_nonmissing_col1

egen table5_col1_quintile_list = group(table5_col1_stratum yhatrf_quintile_col1) if yhatrf_quintile_col1 != ., missing
egen table5_col1_decile_list = group(table5_col1_stratum yhatrf_decile_col1) if yhatrf_decile_col1 != ., missing
egen table5_col1_topsplit_list = group(table5_col1_stratum yhatrf_decile_topsplit_col1) if yhatrf_decile_topsplit_col1 != ., missing

************************************************************
* 3. Export bin support for the Column 1 sample
************************************************************
file open support using `"`table_col1_bin_support'"', write replace
file write support "\begin{tabular}{llrrrrrr}" _n
file write support "\toprule" _n
file write support "Binning & Bin & Lists & Total N & Algorithm N & Inspector N & Outcome N & Mean agents \\" _n
file write support "\midrule" _n
foreach spec in deciles topsplit {
    local binvar "yhatrf_decile_col1"
    local speclabel "Deciles"
    if "`spec'" == "topsplit" {
        local binvar "yhatrf_decile_topsplit_col1"
        local speclabel "Top-split deciles"
    }

    quietly levelsof `binvar' if `binvar' != ., local(binlevels)
    foreach b of local binlevels {
        local binlabel "`b'"
        if "`spec'" == "topsplit" & `b' == 9 local binlabel "9a"
        if "`spec'" == "topsplit" & `b' == 10 local binlabel "9b"
        if "`spec'" == "topsplit" & `b' == 11 local binlabel "10a"
        if "`spec'" == "topsplit" & `b' == 12 local binlabel "10b"

        capture drop support_stratum_tag
        egen support_stratum_tag = tag(table5_col1_stratum) if `binvar' == `b'
        quietly count if support_stratum_tag == 1
        local strata_n = r(N)
        quietly count if `binvar' == `b'
        local total_n = r(N)
        quietly count if `binvar' == `b' & algorithm == 1
        local alg_n = r(N)
        quietly count if `binvar' == `b' & algorithm == 0
        local insp_n = r(N)
        quietly count if `binvar' == `b' & y16 != .
        local outcome_n = r(N)
        quietly summarize y16 if `binvar' == `b'
        local meanagents = r(mean)
        local meanagents : display %5.2f `meanagents'

        file write support "`speclabel' & `binlabel' & `strata_n' & `total_n' & `alg_n' & `insp_n' & `outcome_n' & `meanagents' \\" _n
        drop support_stratum_tag
    }
}
file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

************************************************************
* 4. Estimate consolidated Table 5 Panel A1 Column 1 variants
************************************************************
capture estimates drop _all

local specs original linear quadratic cubic rank_linear rank_quadratic quintiles deciles topsplit_deciles linear_list_rank poly_list_quadratic poly_list_cubic rank_list quintiles_list deciles_list topsplit_deciles_list
local estlist ""
local colindex = 0

foreach spec of local specs {
    local ++colindex

    local extra_controls ""
    local extra_absorb ""
    local ctrl_linear ""
    local ctrl_quadratic ""
    local ctrl_cubic ""
    local ctrl_quintiles ""
    local ctrl_deciles ""
    local ctrl_topsplit_deciles ""
    local ctrl_linear_list ""
    local ctrl_poly_list_quadratic ""
    local ctrl_poly_list_cubic ""
    local ctrl_rank_linear ""
    local ctrl_rank_list ""
    local ctrl_quintiles_list ""
    local ctrl_deciles_list ""
    local ctrl_topsplit_deciles_list ""

    if "`spec'" == "linear" {
        local extra_controls "yhatrf"
        local ctrl_linear "x"
    }
    if "`spec'" == "quadratic" {
        local extra_controls "c.yhatrf##c.yhatrf"
        local ctrl_quadratic "x"
    }
    if "`spec'" == "cubic" {
        local extra_controls "yhatrf yhatrf_sq_col1 yhatrf_cu_col1"
        local ctrl_cubic "x"
    }
    if "`spec'" == "quintiles" {
        local extra_controls "ib1.yhatrf_quintile_col1"
        local ctrl_quintiles "x"
    }
    if "`spec'" == "deciles" {
        local extra_controls "ib1.yhatrf_decile_col1"
        local ctrl_deciles "x"
    }
    if "`spec'" == "topsplit_deciles" {
        local extra_controls "ib1.yhatrf_decile_topsplit_col1"
        local ctrl_topsplit_deciles "x"
    }
    if "`spec'" == "rank_linear" {
        local extra_controls "yhatrf_rank_col1 yhatrf"
        local ctrl_linear "x"
        local ctrl_rank_linear "x"
    }
    if "`spec'" == "rank_quadratic" {
        local extra_controls "yhatrf_rank_col1 c.yhatrf##c.yhatrf"
        local ctrl_quadratic "x"
        local ctrl_rank_linear "x"
    }
    if "`spec'" == "linear_list_rank" {
        local extra_controls "c.yhatrf#i.table5_col1_stratum yhatrf_rank_col1"
        local ctrl_linear_list "x"
        local ctrl_rank_linear "x"
    }
    if "`spec'" == "poly_list_quadratic" {
        local extra_controls "ibn.table5_col1_stratum#c.yhatrf ibn.table5_col1_stratum#c.yhatrf_sq_col1"
        local ctrl_poly_list_quadratic "x"
    }
    if "`spec'" == "poly_list_cubic" {
        local extra_controls "ibn.table5_col1_stratum#c.yhatrf ibn.table5_col1_stratum#c.yhatrf_sq_col1 ibn.table5_col1_stratum#c.yhatrf_cu_col1"
        local ctrl_poly_list_cubic "x"
    }
    if "`spec'" == "rank_list" {
        local extra_controls "c.yhatrf_rank_col1#i.table5_col1_stratum"
        local ctrl_rank_list "x"
    }
    if "`spec'" == "quintiles_list" {
        local extra_absorb "table5_col1_quintile_list"
        local ctrl_quintiles_list "x"
    }
    if "`spec'" == "deciles_list" {
        local extra_absorb "table5_col1_decile_list"
        local ctrl_deciles_list "x"
    }
    if "`spec'" == "topsplit_deciles_list" {
        local extra_absorb "table5_col1_topsplit_list"
        local ctrl_topsplit_deciles_list "x"
    }

    eststo m`colindex': reghdfe y16 algorithm overlap random safeties `extra_controls', ///
        a(inspectorclusteryear `extra_absorb') vce(robust)

    estadd local ctrl_header ""
    estadd local ctrl_linear "`ctrl_linear'"
    estadd local ctrl_quadratic "`ctrl_quadratic'"
    estadd local ctrl_cubic "`ctrl_cubic'"
    estadd local ctrl_quintiles "`ctrl_quintiles'"
    estadd local ctrl_deciles "`ctrl_deciles'"
    estadd local ctrl_topsplit_deciles "`ctrl_topsplit_deciles'"
    estadd local ctrl_linear_list "`ctrl_linear_list'"
    estadd local ctrl_poly_list_quadratic "`ctrl_poly_list_quadratic'"
    estadd local ctrl_poly_list_cubic "`ctrl_poly_list_cubic'"
    estadd local ctrl_rank_linear "`ctrl_rank_linear'"
    estadd local ctrl_rank_list "`ctrl_rank_list'"
    estadd local ctrl_quintiles_list "`ctrl_quintiles_list'"
    estadd local ctrl_deciles_list "`ctrl_deciles_list'"
    estadd local ctrl_topsplit_deciles_list "`ctrl_topsplit_deciles_list'"

    quietly summarize y16 if e(sample) == 1
    local meanoutcome = int(100 * `r(mean)') / 100
    local meanoutcome : display %5.2f `meanoutcome'
    local nobs = e(N)
    estadd local nobs "`nobs'"
    estadd local pp `meanoutcome'

    local estlist "`estlist' m`colindex'"
}

#delim ;
esttab `estlist'
    using `"`table_col1_controls'"',
    replace fragment booktabs
    prehead("\begin{tabular}{lcccccccccccccccc} \toprule")
    posthead("\multicolumn{1}{l}{} & \multicolumn{16}{c}{Number of Agents} \\\cmidrule(lr){2-17} \multicolumn{1}{l}{} & 1 (original) & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9 & 10 & 11 & 12 & 13 & 14 & 15 & 16 \\ \midrule")
    postfoot("\bottomrule \end{tabular}")
    order(algorithm overlap random)
    keep(algorithm overlap random)
    coeflabels(algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random")
    b(%5.2f) se(%5.2f)
    stats(ctrl_header ctrl_linear ctrl_quadratic ctrl_cubic ctrl_rank_linear ctrl_quintiles ctrl_deciles ctrl_topsplit_deciles ctrl_linear_list ctrl_poly_list_quadratic ctrl_poly_list_cubic ctrl_rank_list ctrl_quintiles_list ctrl_deciles_list ctrl_topsplit_deciles_list nobs r2 pp,
        labels("Type of predicted evasion control" "Linear predicted evasion" "Quadratic predicted evasion" "Cubic predicted evasion" "Rank of predicted evasion" "Quintiles" "Deciles" "Top-split deciles" "Linear predicted evasion x List" "Quadratic polynomial predicted evasion x List" "Cubic polynomial predicted evasion x List" "Rank of predicted evasion x List" "Quintiles x List" "Deciles x List" "Top-split deciles x List" "N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    nomtitles nonumbers collabels(none) nonotes
    substitute(\_ _)
;
#delim cr
}
