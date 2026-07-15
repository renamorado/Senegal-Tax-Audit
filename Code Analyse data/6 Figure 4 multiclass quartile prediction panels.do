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
* using the C1 multiclass random forest prediction of realized-evasion quartile.
*
* The x-axis is the predicted realized-evasion quartile class, where Q4 is the
* highest predicted realized-evasion quartile and Q1 is the lowest.

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

local multiclass_input "$output\figure4_multiclass_quartile_fullaudits_c1.dta"

************************************************************
* 1. Load selected non-safety full audits
************************************************************
use "`multiclass_input'", clear

foreach var in p_q1 p_q2 p_q3 p_q4 expected_realized_quartile ///
    predicted_realized_quartile y2 algorithm dgid selection safeties controle {
    capture confirm variable `var'
    if _rc {
        di as error "Required variable `var' not found in `multiclass_input'."
        exit 111
    }
}

keep if selection == 1
drop if safeties == 1
keep if controle == 2
drop if missing(predicted_realized_quartile)

capture drop quartile_probability_sum
gen quartile_probability_sum = p_q1 + p_q2 + p_q3 + p_q4
assert abs(quartile_probability_sum - 1) < 1e-8
assert inrange(predicted_realized_quartile, 1, 4)
assert inrange(expected_realized_quartile, 1, 4)

label define predicted_quartile_label ///
    1 "Q1" ///
    2 "Q2" ///
    3 "Q3" ///
    4 "Q4", replace
label values predicted_realized_quartile predicted_quartile_label
label var predicted_realized_quartile "Predicted realized-evasion quartile"

tempfile fullaudits
save `fullaudits', replace

clear
set obs 4
gen predicted_realized_quartile = _n
label values predicted_realized_quartile predicted_quartile_label
tempfile predicted_quartiles
save `predicted_quartiles', replace

************************************************************
* 2. Count check: cases by predicted realized-evasion quartile
************************************************************
use `fullaudits', clear

local support_output "$output\figure4_binprob_multiclass_predquartile_fullaudits_support.tex"
capture erase "`support_output'"
file open support using "`support_output'", write replace
file write support "\begin{tabular}[t]{lrrrrrr}" _n
file write support "\toprule" _n
file write support "Predicted quartile & All cases & Algorithm cases & Inspector cases & Non-missing execution & Realized Q4 executed & Execution rate (\%)\\" _n
file write support "\midrule" _n

forvalues q = 1/4 {
    quietly count if predicted_realized_quartile == `q'
    local n_all = r(N)

    quietly count if predicted_realized_quartile == `q' & algorithm == 1
    local n_algorithm = r(N)

    quietly count if predicted_realized_quartile == `q' & dgid == 1
    local n_inspector = r(N)

    quietly count if predicted_realized_quartile == `q' & y2 == 1 & realized_evasion_quartile == 4
    local n_realized_q4 = r(N)

    quietly summarize y2 if predicted_realized_quartile == `q'
    local n_execution = r(N)
    local execution_rate = cond(r(N) > 0, 100 * r(mean), .)
    local execution_display = cond(r(N) > 0, string(`execution_rate', "%9.1f"), "--")

    file write support "Q`q' & `n_all' & `n_algorithm' & `n_inspector' & `n_execution' & `n_realized_q4' & `execution_display'\\" _n
}

file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

************************************************************
* 3. Panel A: All selected full audits
************************************************************
use `fullaudits', clear
keep if !missing(y2)
gen n_nonexecuted = y2 == 0
gen n_executed = y2 == 1
collapse (sum) n_nonexecuted n_executed, by(predicted_realized_quartile)
egen total_nonexecuted = total(n_nonexecuted)
egen total_executed = total(n_executed)
gen predicted_nonexecuted_percent = 100 * n_nonexecuted / total_nonexecuted
gen predicted_executed_percent = 100 * n_executed / total_executed
keep predicted_realized_quartile predicted_nonexecuted_percent predicted_executed_percent
tempfile panel_a_predicted
save `panel_a_predicted', replace

use `fullaudits', clear
keep if y2 == 1 & realized_evasion_quartile == 4
collapse (count) n_realized_q4 = realized_evasion_quartile, by(predicted_realized_quartile)
egen total_realized_q4 = total(n_realized_q4)
gen realized_q4_percent = 100 * n_realized_q4 / total_realized_q4
keep predicted_realized_quartile realized_q4_percent
tempfile panel_a_realized
save `panel_a_realized', replace

use `fullaudits', clear
keep if !missing(y2)
collapse (mean) execution_rate = y2 (sd) sd_execution = y2 (count) n_execution = y2, ///
    by(predicted_realized_quartile)
replace sd_execution = 0 if missing(sd_execution)
gen se_execution = sd_execution / sqrt(n_execution)
gen execution_lower = max(0, execution_rate - 1.96 * se_execution)
gen execution_upper = min(1, execution_rate + 1.96 * se_execution)
replace execution_rate = 100 * execution_rate
replace execution_lower = 100 * execution_lower
replace execution_upper = 100 * execution_upper
keep predicted_realized_quartile execution_rate execution_lower execution_upper
tempfile panel_a_execution
save `panel_a_execution', replace

use `predicted_quartiles', clear
merge 1:1 predicted_realized_quartile using `panel_a_predicted', nogen
merge 1:1 predicted_realized_quartile using `panel_a_realized', nogen
merge 1:1 predicted_realized_quartile using `panel_a_execution', nogen

foreach var in predicted_nonexecuted_percent predicted_executed_percent realized_q4_percent {
    replace `var' = 0 if missing(`var')
}

sort predicted_realized_quartile

twoway ///
    (bar predicted_nonexecuted_percent predicted_realized_quartile, barwidth(0.75) fcolor(navy%15) lcolor(navy%0)) || ///
    (bar predicted_executed_percent predicted_realized_quartile, barwidth(0.55) fcolor(green%18) lcolor(green%0)) || ///
    (bar realized_q4_percent predicted_realized_quartile, barwidth(0.35) fcolor(gs8%20) lcolor(gs8%0)) || ///
    (rarea execution_lower execution_upper predicted_realized_quartile, fcolor(red%15) lcolor(red%0) lwidth(vvthin)) || ///
    (connected execution_rate predicted_realized_quartile, lcolor(red) mcolor(red) msymbol(circle) lwidth(medthin)), ///
    ytitle("Percentage (%)") ///
    xtitle("Predicted realized-evasion quartile") ///
    ylabel(0(25)100, grid) ///
    xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", grid) ///
    xscale(range(0.5 4.5)) ///
    legend(order(2 "Predicted class, executed" ///
                 1 "Predicted class, non-executed" ///
                 3 "Realized Q4 executed cases" ///
                 5 "P(execution | predicted quartile)") ///
           rows(2) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_a_binprob_multiclass_predquartile_fullaudits.pdf", replace

************************************************************
* 4. Panel B: Algorithm-selected and inspector-selected cases
************************************************************
use `fullaudits', clear
keep if algorithm == 1 & !missing(y2)
collapse (mean) execution_algorithm = y2 (sd) sd_algorithm = y2 (count) n_algorithm = y2, ///
    by(predicted_realized_quartile)
egen total_algorithm = total(n_algorithm)
gen distribution_algorithm = 100 * n_algorithm / total_algorithm
replace sd_algorithm = 0 if missing(sd_algorithm)
gen se_algorithm = sd_algorithm / sqrt(n_algorithm)
gen execution_algorithm_lower = max(0, execution_algorithm - 1.96 * se_algorithm)
gen execution_algorithm_upper = min(1, execution_algorithm + 1.96 * se_algorithm)
replace execution_algorithm = 100 * execution_algorithm
replace execution_algorithm_lower = 100 * execution_algorithm_lower
replace execution_algorithm_upper = 100 * execution_algorithm_upper
keep predicted_realized_quartile distribution_algorithm execution_algorithm execution_algorithm_lower execution_algorithm_upper
tempfile panel_b_algorithm
save `panel_b_algorithm', replace

use `fullaudits', clear
keep if dgid == 1 & !missing(y2)
collapse (mean) execution_inspector = y2 (sd) sd_inspector = y2 (count) n_inspector = y2, ///
    by(predicted_realized_quartile)
egen total_inspector = total(n_inspector)
gen distribution_inspector = 100 * n_inspector / total_inspector
replace sd_inspector = 0 if missing(sd_inspector)
gen se_inspector = sd_inspector / sqrt(n_inspector)
gen execution_inspector_lower = max(0, execution_inspector - 1.96 * se_inspector)
gen execution_inspector_upper = min(1, execution_inspector + 1.96 * se_inspector)
replace execution_inspector = 100 * execution_inspector
replace execution_inspector_lower = 100 * execution_inspector_lower
replace execution_inspector_upper = 100 * execution_inspector_upper
keep predicted_realized_quartile distribution_inspector execution_inspector execution_inspector_lower execution_inspector_upper
tempfile panel_b_inspector
save `panel_b_inspector', replace

use `predicted_quartiles', clear
merge 1:1 predicted_realized_quartile using `panel_b_algorithm', nogen
merge 1:1 predicted_realized_quartile using `panel_b_inspector', nogen

foreach var in distribution_algorithm distribution_inspector {
    replace `var' = 0 if missing(`var')
}

sort predicted_realized_quartile

twoway ///
    (bar distribution_algorithm predicted_realized_quartile, barwidth(0.70) fcolor(maroon%14) lcolor(maroon%0)) || ///
    (bar distribution_inspector predicted_realized_quartile, barwidth(0.45) fcolor(orange%20) lcolor(orange%0)) || ///
    (rarea execution_algorithm_lower execution_algorithm_upper predicted_realized_quartile, fcolor(maroon%10) lcolor(maroon%0) lwidth(vvthin)) || ///
    (rarea execution_inspector_lower execution_inspector_upper predicted_realized_quartile, fcolor(orange%12) lcolor(orange%0) lwidth(vvthin)) || ///
    (connected execution_algorithm predicted_realized_quartile, lcolor(maroon) mcolor(maroon) msymbol(circle) lwidth(medthin)) || ///
    (connected execution_inspector predicted_realized_quartile, lcolor(orange) mcolor(orange) msymbol(triangle) lwidth(medthin)), ///
    ytitle("Percentage (%)") ///
    xtitle("Predicted realized-evasion quartile") ///
    ylabel(0(25)100, grid) ///
    xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", grid) ///
    xscale(range(0.5 4.5)) ///
    legend(order(1 "Algorithm cases distribution" ///
                 2 "Inspector cases distribution" ///
                 5 "Algorithm cases P(execution | predicted quartile)" ///
                 6 "Inspector cases P(execution | predicted quartile)") ///
           rows(2) size(small) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_b_binprob_multiclass_predquartile_fullaudits.pdf", replace
