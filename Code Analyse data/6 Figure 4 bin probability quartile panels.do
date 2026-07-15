*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         June 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file creates Figure 4-style diagnostics for selected full audits
* using the C1 direct bin-target random forest from Table 49 Panel C.
*
* The x-axis uses quartiles of the predicted probability that an audit case
* belongs to the top half of realized evasion. Quartile 4 is the highest
* predicted high-evasion priority within the bureau_detailed x selectionyear
* list; quartile 1 is the lowest predicted priority.

version 17
set more off
clear all
capture set scheme stcolor
if _rc {
    set scheme s2color
}

global check = 1

*****************
** DIRECTORIES **
*****************
if strpos(lower("`c(username)'"),"49354415") {
    global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
}
if strpos(lower("`c(username)'"),"user") {
    global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}
if strpos(lower("`c(username)'"),"wb648862") {
    global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}
if "$rootdir" == "" {
    global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
}

global output "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
    global output "C:\Users\User\Documents\Projects\Senegal-Tax-Audit\Output"
    if strpos(lower("`c(username)'"),"wb648862") {
        global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
    }
}

local binprob_input "$output\figure4_binprob_decile_fullaudits_c1.dta"

************************************************************
* 1. Load selected non-safety full audits
************************************************************
use "`binprob_input'", clear

foreach var in bin_high_probability ///
    binprob_rank_bureauyear binprob_list_n y2 algorithm dgid selection ///
    safeties controle bureau_detailed selectionyear {
    capture confirm variable `var'
    if _rc {
        di as error "Required variable `var' not found in `binprob_input'."
        exit 111
    }
}

keep if selection == 1
drop if safeties == 1
keep if controle == 2
drop if missing(bin_high_probability)

gen binprob_priority_quartile = .
replace binprob_priority_quartile = 4 if binprob_list_n == 1
replace binprob_priority_quartile = 4 - floor(4 * (binprob_rank_bureauyear - 1) / (binprob_list_n - 1)) ///
    if binprob_list_n > 1
replace binprob_priority_quartile = 1 if binprob_priority_quartile < 1 & binprob_priority_quartile != .
replace binprob_priority_quartile = 4 if binprob_priority_quartile > 4 & binprob_priority_quartile != .

label var binprob_priority_quartile "Predicted high-evasion priority quartile, 4 = highest priority"

assert inrange(binprob_priority_quartile, 1, 4)
assert binprob_priority_quartile == 4 if binprob_rank_bureauyear == 1
assert binprob_priority_quartile == 1 if binprob_list_n > 1 & binprob_rank_bureauyear == binprob_list_n

tempfile fullaudits
save `fullaudits', replace

************************************************************
* 2. Count check: cases by predicted-priority quartile
************************************************************
use `fullaudits', clear

local support_output "$output\figure4_binprob_quartile_fullaudits_support.tex"
capture erase "`support_output'"
file open support using "`support_output'", write replace
file write support "\begin{tabular}[t]{lrrrrr}" _n
file write support "\toprule" _n
file write support "Predicted priority quartile & All cases & Algorithm cases & Inspector cases & Non-missing execution & Execution rate (\%)\\" _n
file write support "\midrule" _n

forvalues q = 1/4 {
    quietly count if binprob_priority_quartile == `q'
    local n_all = r(N)

    quietly count if binprob_priority_quartile == `q' & algorithm == 1
    local n_algorithm = r(N)

    quietly count if binprob_priority_quartile == `q' & dgid == 1
    local n_inspector = r(N)

    quietly summarize y2 if binprob_priority_quartile == `q'
    local n_execution = r(N)
    local execution_rate = cond(r(N) > 0, 100 * r(mean), .)
    local execution_display = cond(r(N) > 0, string(`execution_rate', "%9.1f"), "--")

    file write support "`q' & `n_all' & `n_algorithm' & `n_inspector' & `n_execution' & `execution_display'\\" _n
}

file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

************************************************************
* 3. Panel A: Execution rate by predicted-priority quartile
************************************************************
use `fullaudits', clear
keep if !missing(y2)

collapse (mean) execution_rate = y2 (sd) sd_execution = y2 (count) n_execution = y2, ///
    by(binprob_priority_quartile)
replace sd_execution = 0 if missing(sd_execution)
gen se_execution = sd_execution / sqrt(n_execution)
gen execution_lower = max(0, execution_rate - 1.96 * se_execution)
gen execution_upper = min(1, execution_rate + 1.96 * se_execution)
replace execution_rate = 100 * execution_rate
replace execution_lower = 100 * execution_lower
replace execution_upper = 100 * execution_upper

sort binprob_priority_quartile

twoway ///
    (rarea execution_lower execution_upper binprob_priority_quartile, fcolor(red) fintensity(15) lcolor(red) lwidth(vvthin)) || ///
    (connected execution_rate binprob_priority_quartile, lcolor(red) mcolor(red) msymbol(circle) lwidth(medthin)), ///
    ytitle("Execution rate (%)") ///
    xtitle("Predicted high-evasion priority quartile") ///
    ylabel(0(25)100, grid) ///
    xlabel(1(1)4, grid) ///
    xscale(range(1 4)) ///
    legend(order(2 "P(execution | predicted high-evasion priority quartile)") ///
           position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

local panel_a_output "$output\figure4_panel_a_binprob_quartile_fullaudits.pdf"
capture erase "`panel_a_output'"
graph export "`panel_a_output'", replace

************************************************************
* 4. Panel B: Algorithm-selected and inspector-selected cases
************************************************************
use `fullaudits', clear
keep if algorithm == 1 & !missing(y2)
collapse (mean) execution_algorithm = y2 (sd) sd_algorithm = y2 (count) n_algorithm = y2, ///
    by(binprob_priority_quartile)
replace sd_algorithm = 0 if missing(sd_algorithm)
gen se_algorithm = sd_algorithm / sqrt(n_algorithm)
gen execution_algorithm_lower = max(0, execution_algorithm - 1.96 * se_algorithm)
gen execution_algorithm_upper = min(1, execution_algorithm + 1.96 * se_algorithm)
replace execution_algorithm = 100 * execution_algorithm
replace execution_algorithm_lower = 100 * execution_algorithm_lower
replace execution_algorithm_upper = 100 * execution_algorithm_upper
keep binprob_priority_quartile execution_algorithm execution_algorithm_lower execution_algorithm_upper
tempfile panel_b_algorithm
save `panel_b_algorithm', replace

use `fullaudits', clear
keep if dgid == 1 & !missing(y2)
collapse (mean) execution_inspector = y2 (sd) sd_inspector = y2 (count) n_inspector = y2, ///
    by(binprob_priority_quartile)
replace sd_inspector = 0 if missing(sd_inspector)
gen se_inspector = sd_inspector / sqrt(n_inspector)
gen execution_inspector_lower = max(0, execution_inspector - 1.96 * se_inspector)
gen execution_inspector_upper = min(1, execution_inspector + 1.96 * se_inspector)
replace execution_inspector = 100 * execution_inspector
replace execution_inspector_lower = 100 * execution_inspector_lower
replace execution_inspector_upper = 100 * execution_inspector_upper
keep binprob_priority_quartile execution_inspector execution_inspector_lower execution_inspector_upper

merge 1:1 binprob_priority_quartile using `panel_b_algorithm', nogen
sort binprob_priority_quartile

twoway ///
    (rarea execution_algorithm_lower execution_algorithm_upper binprob_priority_quartile, fcolor(maroon) fintensity(10) lcolor(maroon) lwidth(vvthin)) || ///
    (rarea execution_inspector_lower execution_inspector_upper binprob_priority_quartile, fcolor(orange) fintensity(12) lcolor(orange) lwidth(vvthin)) || ///
    (connected execution_algorithm binprob_priority_quartile, lcolor(maroon) mcolor(maroon) msymbol(circle) lwidth(medthin)) || ///
    (connected execution_inspector binprob_priority_quartile, lcolor(orange) mcolor(orange) msymbol(triangle) lwidth(medthin)), ///
    ytitle("Execution rate (%)") ///
    xtitle("Predicted high-evasion priority quartile") ///
    ylabel(0(25)100, grid) ///
    xlabel(1(1)4, grid) ///
    xscale(range(1 4)) ///
    legend(order(3 "Algorithm cases" ///
                 4 "Inspector cases") ///
           rows(1) size(small) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

local panel_b_output "$output\figure4_panel_b_binprob_quartile_fullaudits.pdf"
capture erase "`panel_b_output'"
graph export "`panel_b_output'", replace
