*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         April 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the screenshot-style Table 4 main-outcome specifications
* from "2 Regressions main results.do" and then re-estimates them adding
* predicted evasion (yhatrf) linearly, quadratically, and via pooled grouped
* controls. It also rebuilds the Table 4 Lee-bounds row for each exported
* variant.

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

global table4_full_input "$analysisdata\fullaudits_predicted.dta"
global table4_desk_input "$analysisdata\deskaudits_predicted.dta"

local table_replicated "$output\table4_main_outcomes_replicated.tex"
local table_replicated_lee "$output\table4_main_outcomes_replicated_with_lee.tex"
local table_yhatrf "$output\table4_main_outcomes_yhatrf_control.tex"
local table_yhatrf_lee "$output\table4_main_outcomes_yhatrf_control_with_lee.tex"
local table_yhatrf_quadratic "$output\table4_main_outcomes_yhatrf_quadratic_control.tex"
local table_yhatrf_quadratic_lee "$output\table4_main_outcomes_yhatrf_quadratic_control_with_lee.tex"
local table_yhatrf_deciles "$output\table4_main_outcomes_yhatrf_deciles_control.tex"
local table_yhatrf_deciles_lee "$output\table4_main_outcomes_yhatrf_deciles_control_with_lee.tex"
local table_yhatrf_quintiles "$output\table4_main_outcomes_yhatrf_quintiles_control.tex"
local table_yhatrf_quintiles_lee "$output\table4_main_outcomes_yhatrf_quintiles_control_with_lee.tex"
local table_yhatrf_bin15 "$output\table4_main_outcomes_yhatrf_15bins_control.tex"
local table_yhatrf_bin15_lee "$output\table4_main_outcomes_yhatrf_15bins_control_with_lee.tex"
local table_yhatrf_bin20 "$output\table4_main_outcomes_yhatrf_20bins_control.tex"
local table_yhatrf_bin20_lee "$output\table4_main_outcomes_yhatrf_20bins_control_with_lee.tex"
local table_yhatrf_topsplit "$output\table4_main_outcomes_yhatrf_topsplit_control.tex"
local table_yhatrf_topsplit_lee "$output\table4_main_outcomes_yhatrf_topsplit_control_with_lee.tex"
local table_yhatrf_bin_support "$output\table4_main_outcomes_yhatrf_bin_support.tex"

************************************************************
* Shared table metadata
************************************************************
local header_groups `"\multicolumn{1}{l}{} & \multicolumn{3}{c}{P(Execution)} & \multicolumn{3}{c}{P(Detection | Execution)} & \multicolumn{3}{c}{log(Evasion) | Detection} \\\cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-10}"'
local header_titles `"\multicolumn{1}{l}{} & Full audits & Desk audits & Desk audits & Full audits & Desk audits & Desk audits & Full audits & Desk audits & Desk audits \\"'
local header_numbers `"\multicolumn{1}{l}{} & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) \\"'

************************************************************
* 1. Import the predicted-audit data
************************************************************
use "$table4_full_input", clear
append using "$table4_desk_input"

capture confirm variable yhatrf
if _rc {
    di as error "Variable yhatrf not found after appending predicted-audit files."
    exit 111
}

************************************************************
* 2. Prepare the Table 4 sample once
************************************************************
keep if selection == 1
drop if safeties == 1

capture drop yhatrf_decile
capture drop yhatrf_quintile
capture drop yhatrf_bin15
capture drop yhatrf_bin20
capture drop yhatrf_decile_topsplit
capture drop yhatrf_decile9_half
capture drop yhatrf_decile10_half
* Group predicted-evasion controls within audit type, pooling algorithm and
* inspector-selected cases inside full audits and inside desk audits separately.
gen yhatrf_decile = .
gen yhatrf_quintile = .
gen yhatrf_bin15 = .
gen yhatrf_bin20 = .
gen yhatrf_decile_topsplit = .

forvalues audit_type = 0/1 {
    capture drop yhatrf_tmp
    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf != . , nq(10)
    replace yhatrf_decile = yhatrf_tmp if x2 == `audit_type'
    drop yhatrf_tmp

    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf != . , nq(5)
    replace yhatrf_quintile = yhatrf_tmp if x2 == `audit_type'
    drop yhatrf_tmp

    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf != . , nq(15)
    replace yhatrf_bin15 = yhatrf_tmp if x2 == `audit_type'
    drop yhatrf_tmp

    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf != . , nq(20)
    replace yhatrf_bin20 = yhatrf_tmp if x2 == `audit_type'
    drop yhatrf_tmp

    * Top-tail flexibility check: preserve deciles 1-8 and split deciles 9 and 10.
    replace yhatrf_decile_topsplit = yhatrf_decile if x2 == `audit_type'

    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf_decile == 9, nq(2)
    replace yhatrf_decile_topsplit = 9 if x2 == `audit_type' & yhatrf_decile == 9 & yhatrf_tmp == 1
    replace yhatrf_decile_topsplit = 10 if x2 == `audit_type' & yhatrf_decile == 9 & yhatrf_tmp == 2
    drop yhatrf_tmp

    xtile yhatrf_tmp = yhatrf if x2 == `audit_type' & yhatrf_decile == 10, nq(2)
    replace yhatrf_decile_topsplit = 11 if x2 == `audit_type' & yhatrf_decile == 10 & yhatrf_tmp == 1
    replace yhatrf_decile_topsplit = 12 if x2 == `audit_type' & yhatrf_decile == 10 & yhatrf_tmp == 2
    drop yhatrf_tmp
}

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
    forvalues audit_type = 1/2 {
        local sample_if "x2 == 1"
        local sample_label "Full audits"
        if `audit_type' == 2 {
            local sample_if "x2 == 0"
            local sample_label "Desk audits"
        }
        foreach b of local binlevels {
            quietly count if `sample_if' & `binvar' == `b'
            local total_n = r(N)
            quietly count if `sample_if' & `binvar' == `b' & algorithm == 1
            local alg_n = r(N)
            quietly count if `sample_if' & `binvar' == `b' & algorithm == 0
            local insp_n = r(N)
            local both_methods "No"
            if `alg_n' > 0 & `insp_n' > 0 local both_methods "Yes"
            file write support "`speclabel' & `sample_label' & `b' & `total_n' & `alg_n' & `insp_n' & `both_methods' \\" _n
        }
    }
}
file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

tempfile table4_prepared
save `table4_prepared', replace

************************************************************
* 3. Export Table 4 variants
************************************************************
foreach spec in replicated yhatrf yhatrf_quadratic yhatrf_deciles yhatrf_quintiles yhatrf_bin15 yhatrf_bin20 yhatrf_topsplit {
    use `table4_prepared', clear
    capture estimates drop _all

    local extra_controls ""
    local order_vars "algorithm overlap random"
    local keep_vars "algorithm overlap random"
    local coeflabels `"algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random""'
    local table_out "`table_replicated'"
    local table_out_lee "`table_replicated_lee'"

    if "`spec'" == "yhatrf" {
        local extra_controls "yhatrf"
        local order_vars "algorithm overlap random yhatrf"
        local keep_vars "algorithm overlap random yhatrf"
        local coeflabels `"algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random" yhatrf "Predicted evasion""'
        local table_out "`table_yhatrf'"
        local table_out_lee "`table_yhatrf_lee'"
    }
    if "`spec'" == "yhatrf_quadratic" {
        local extra_controls "c.yhatrf##c.yhatrf"
        local order_vars "algorithm overlap random yhatrf c.yhatrf#c.yhatrf"
        local keep_vars "algorithm overlap random yhatrf c.yhatrf#c.yhatrf"
        local coeflabels `"algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random" yhatrf "Predicted evasion" c.yhatrf#c.yhatrf "Predicted evasion squared""'
        local table_out "`table_yhatrf_quadratic'"
        local table_out_lee "`table_yhatrf_quadratic_lee'"
    }
    if "`spec'" == "yhatrf_deciles" {
        local extra_controls "ib1.yhatrf_decile"
        local table_out "`table_yhatrf_deciles'"
        local table_out_lee "`table_yhatrf_deciles_lee'"
    }
    if "`spec'" == "yhatrf_quintiles" {
        local extra_controls "ib1.yhatrf_quintile"
        local table_out "`table_yhatrf_quintiles'"
        local table_out_lee "`table_yhatrf_quintiles_lee'"
    }
    if "`spec'" == "yhatrf_bin15" {
        local extra_controls "ib1.yhatrf_bin15"
        local table_out "`table_yhatrf_bin15'"
        local table_out_lee "`table_yhatrf_bin15_lee'"
    }
    if "`spec'" == "yhatrf_bin20" {
        local extra_controls "ib1.yhatrf_bin20"
        local table_out "`table_yhatrf_bin20'"
        local table_out_lee "`table_yhatrf_bin20_lee'"
    }
    if "`spec'" == "yhatrf_topsplit" {
        local extra_controls "ib1.yhatrf_decile_topsplit"
        local table_out "`table_yhatrf_topsplit'"
        local table_out_lee "`table_yhatrf_topsplit_lee'"
    }

    local estlist ""
    local colindex = 0

    foreach outcome in y2 y3 y4 {
        if "`outcome'" != "y2" {
            replace `outcome' = . if y2 == 0
        }
        if "`outcome'" == "y4" {
            replace `outcome' = . if `outcome' == 0
        }

        local ++colindex
        eststo m`colindex': reghdfe `outcome' algorithm overlap random safeties `extra_controls' if x2 == 1, ///
            a(inspectorclusteryear) vce(robust)
        estadd local taxcenteryear "Yes"
        estadd local inspectoryear "No"
        quietly summarize `outcome' if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' m`colindex'"

        local ++colindex
        eststo m`colindex': reghdfe `outcome' algorithm overlap random safeties `extra_controls' if x2 == 0, ///
            a(controlbureauannee) vce(robust)
        estadd local taxcenteryear "Yes"
        estadd local inspectoryear "No"
        quietly summarize `outcome' if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' m`colindex'"

        local ++colindex
        eststo m`colindex': reghdfe `outcome' algorithm overlap random safeties `extra_controls' if x2 == 0, ///
            a(inspectorclusteryear) vce(robust)
        estadd local taxcenteryear "Yes"
        estadd local inspectoryear "Yes"
        quietly summarize `outcome' if e(sample) == 1
        local meanoutcome = int(100 * `r(mean)') / 100
        local meanoutcome : display %5.2f `meanoutcome'
        estadd local pp `meanoutcome'
        estadd local N = e(N), replace
        local estlist "`estlist' m`colindex'"
    }

    #delim ;
    esttab `estlist'
        using `"`table_out'"',
        replace fragment booktabs
        prehead("\begin{tabular}{lccc|ccc|ccc} \toprule")
        posthead("`header_groups' `header_titles' `header_numbers' \midrule")
        postfoot("\bottomrule \end{tabular}")
        order(`order_vars')
        keep(`keep_vars')
        coeflabels(`coeflabels')
        b(%5.2f) se(%5.2f)
        stats(taxcenteryear inspectoryear N r2 pp,
            labels("Tax center x Year" "Inspector x Year" "N" "R2" "Mean outcome"))
        star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
        nomtitles nonumbers collabels(none) nonotes
        substitute(\_ _)
    ;
    #delim cr

    ********************************************************
    * 4. Rebuild the Lee-bounds row for this variant
    ********************************************************
    use `table4_prepared', clear

    replace y4 = . if y3 == 0

    foreach y in y3 y4 {
        capture drop nonmissing`y'
        capture drop share`y'alg
        capture drop share`y'insp
        capture drop total_data`y'alg
        capture drop total_data`y'insp
        capture drop difference`y'
        capture drop drop`y'

        gen nonmissing`y' = `y' != .
        if "`y'" != "y3" {
            replace nonmissing`y' = . if y2 == 0
        }

        bys inspectorclusteryear controle algorithm: egen share_data`y' = mean(nonmissing`y') if algorithm == 1
        bys inspectorclusteryear controle: egen share`y'alg = max(share_data`y')
        bys inspectorclusteryear controle algorithm: egen total_data`y' = sum(nonmissing`y') if algorithm == 1
        bys inspectorclusteryear controle: egen total_data`y'alg = max(total_data`y')
        drop share_data`y' total_data`y'

        bys inspectorclusteryear controle algorithm: egen share_data`y' = mean(nonmissing`y') if algorithm == 0
        bys inspectorclusteryear controle: egen share`y'insp = max(share_data`y')
        bys inspectorclusteryear controle algorithm: egen total_data`y' = sum(nonmissing`y') if algorithm == 0
        bys inspectorclusteryear controle: egen total_data`y'insp = max(total_data`y')
        drop share_data`y' total_data`y'

        gen difference`y' = share`y'insp - share`y'alg
        gen drop`y' = round(difference`y' * total_data`y'insp, 1) if difference`y' > 0
        replace drop`y' = -round(difference`y' * total_data`y'alg, 1) if difference`y' < 0
    }

    set seed 1238945
    capture drop randomvariable
    gen randomvariable = runiform()

    matrix lee = J(4, 5, 0)
    matrix rownames lee = "y3 desk" "y3 full" "y4 desk" "y4 full"
    matrix colnames lee = "lower" "lower t" "upper" "upper t" "N"

    local r = 0
    foreach y in y3 y4 {
        capture drop sample_upper
        capture drop sample_lower
        capture drop n

        gen sample_upper = 1

        gsort inspectorclusteryear -`y' randomvariable
        by inspectorclusteryear: gen n = _n
        replace sample_upper = 0 if algorithm == 0 & difference`y' > 0 & drop`y' >= n
        drop n

        gsort inspectorclusteryear `y' randomvariable
        by inspectorclusteryear: gen n = _n
        replace sample_upper = 0 if algorithm == 1 & difference`y' < 0 & drop`y' >= n
        drop n

        gen sample_lower = 1

        gsort inspectorclusteryear `y' randomvariable
        by inspectorclusteryear: gen n = _n
        replace sample_lower = 0 if algorithm == 0 & difference`y' > 0 & drop`y' >= n
        drop n

        gsort inspectorclusteryear -`y' randomvariable
        by inspectorclusteryear: gen n = _n
        replace sample_lower = 0 if algorithm == 1 & difference`y' < 0 & drop`y' >= n
        drop n

        local ++r
        quietly reghdfe `y' algorithm overlap random `extra_controls' if x2 == 0 & sample_lower == 1, ///
            a(inspectorclusteryear) vce(robust)
        matrix lee[`r', 1] = _b[algorithm]
        matrix lee[`r', 2] = _b[algorithm] / _se[algorithm]

        quietly reghdfe `y' algorithm overlap random `extra_controls' if x2 == 0 & sample_upper == 1, ///
            a(inspectorclusteryear) vce(robust)
        matrix lee[`r', 3] = _b[algorithm]
        matrix lee[`r', 4] = _b[algorithm] / _se[algorithm]
        matrix lee[`r', 5] = e(N)

        local ++r
        quietly reghdfe `y' algorithm overlap random `extra_controls' if x2 == 1 & sample_lower == 1, ///
            a(inspectorclusteryear) vce(robust)
        matrix lee[`r', 1] = _b[algorithm]
        matrix lee[`r', 2] = _b[algorithm] / _se[algorithm]

        quietly reghdfe `y' algorithm overlap random `extra_controls' if x2 == 1 & sample_upper == 1, ///
            a(inspectorclusteryear) vce(robust)
        matrix lee[`r', 3] = _b[algorithm]
        matrix lee[`r', 4] = _b[algorithm] / _se[algorithm]
        matrix lee[`r', 5] = e(N)

        drop sample_lower sample_upper
    }

    forvalues x = 1/4 {
        local lowlee`x' = lee[`x', 1]
        local lowlee`x' : display %3.2f `lowlee`x''

        local highlee`x' = lee[`x', 3]
        local highlee`x' : display %3.2f `highlee`x''

        local lowt`x' = lee[`x', 2]
        local low`x' = cond(abs(`lowt`x'') < 1.28, "", ///
            cond(abs(`lowt`x'') > 1.28 & abs(`lowt`x'') < 1.96, "*", ///
            cond(abs(`lowt`x'') > 1.96 & abs(`lowt`x'') < 2.33, "**", ///
            cond(abs(`lowt`x'') > 2.33, "***", ""))))

        local hight`x' = lee[`x', 4]
        local high`x' = cond(abs(`hight`x'') < 1.28, "", ///
            cond(abs(`hight`x'') > 1.28 & abs(`hight`x'') < 1.96, "*", ///
            cond(abs(`hight`x'') > 1.96 & abs(`hight`x'') < 2.33, "**", ///
            cond(abs(`hight`x'') > 2.33, "***", ""))))
    }

    * The displayed Table 4 order is Full, Desk (tax-office FE), Desk (inspector FE)
    * for each outcome, so the Lee row fills columns 4, 6, 7, and 9 only.
    local newline " & & & & [`lowlee2' `low2',`highlee2'`high2'] & & [`lowlee1'`low1',`highlee1'`high1'] & [`lowlee4'`low4',`highlee4'`high4'] & & [`lowlee3'`low3',`highlee3'`high3'] \BS\BS "

    filefilter `"`table_out'"' `"`table_out_lee'"', from("Inspectors x Overlap") to("`newline' Inspectors x Overlap") replace
}

