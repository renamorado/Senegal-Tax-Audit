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
* using fixed-width bins of the C1 direct bin-target random forest probability.
*
* The x-axis uses 0.10-wide bins of the predicted probability that an audit
* case belongs to the top half of realized evasion. This mirrors the
* fixed-bin logic of the original Figure 4 while replacing predicted evasion
* amounts with predicted high-bin probabilities.

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
local bin_width 0.10
local bin_count 10

************************************************************
* 1. Load selected non-safety full audits
************************************************************
use "`binprob_input'", clear

foreach var in bin_high_probability high_evasion_bin y2 algorithm dgid ///
    selection safeties controle {
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

gen binprob_fixed_bin = floor(bin_high_probability / `bin_width') + 1
replace binprob_fixed_bin = 1 if binprob_fixed_bin < 1 & binprob_fixed_bin != .
replace binprob_fixed_bin = `bin_count' if binprob_fixed_bin > `bin_count' & binprob_fixed_bin != .
gen binprob_fixed_mid = (binprob_fixed_bin - 0.5) * `bin_width'

label var binprob_fixed_bin "Fixed 0.10 probability bin"
label var binprob_fixed_mid "Predicted high-bin probability bin midpoint"

assert inrange(bin_high_probability, 0, 1)
assert inrange(binprob_fixed_bin, 1, `bin_count')
assert binprob_fixed_mid >= 0 & binprob_fixed_mid <= 1

tempfile fullaudits
save `fullaudits', replace

clear
set obs `bin_count'
gen binprob_fixed_bin = _n
gen binprob_fixed_mid = (binprob_fixed_bin - 0.5) * `bin_width'
tempfile fixed_bins
save `fixed_bins', replace

************************************************************
* 2. Count check: cases by fixed-width probability bin
************************************************************
use `fullaudits', clear

local support_output "$output\figure4_binprob_fixed010_fullaudits_support.tex"
capture erase "`support_output'"
file open support using "`support_output'", write replace
file write support "\begin{tabular}[t]{lrrrrrr}" _n
file write support "\toprule" _n
file write support "Probability bin & All cases & Algorithm cases & Inspector cases & Non-missing execution & Realized high-bin & Execution rate (\%)\\" _n
file write support "\midrule" _n

forvalues b = 1/`bin_count' {
    local lo = (`b' - 1) * `bin_width'
    local hi = `b' * `bin_width'
    local lo_display : display %3.2f `lo'
    local hi_display : display %3.2f `hi'

    quietly count if binprob_fixed_bin == `b'
    local n_all = r(N)

    quietly count if binprob_fixed_bin == `b' & algorithm == 1
    local n_algorithm = r(N)

    quietly count if binprob_fixed_bin == `b' & dgid == 1
    local n_inspector = r(N)

    quietly count if binprob_fixed_bin == `b' & y2 == 1 & high_evasion_bin == 1
    local n_high_bin = r(N)

    quietly summarize y2 if binprob_fixed_bin == `b'
    local n_execution = r(N)
    local execution_rate = cond(r(N) > 0, 100 * r(mean), .)
    local execution_display = cond(r(N) > 0, string(`execution_rate', "%9.1f"), "--")

    file write support "`lo_display'--`hi_display' & `n_all' & `n_algorithm' & `n_inspector' & `n_execution' & `n_high_bin' & `execution_display'\\" _n
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
collapse (sum) n_nonexecuted n_executed, by(binprob_fixed_bin)
egen total_nonexecuted = total(n_nonexecuted)
egen total_executed = total(n_executed)
gen predicted_nonexecuted_percent = 100 * n_nonexecuted / total_nonexecuted
gen predicted_executed_percent = 100 * n_executed / total_executed
keep binprob_fixed_bin predicted_nonexecuted_percent predicted_executed_percent
tempfile panel_a_predicted
save `panel_a_predicted', replace

use `fullaudits', clear
keep if y2 == 1 & high_evasion_bin == 1
collapse (count) n_realized_high_bin = high_evasion_bin, by(binprob_fixed_bin)
egen total_realized_high_bin = total(n_realized_high_bin)
gen realized_high_bin_percent = 100 * n_realized_high_bin / total_realized_high_bin
keep binprob_fixed_bin realized_high_bin_percent
tempfile panel_a_realized
save `panel_a_realized', replace

use `fullaudits', clear
keep if !missing(y2)
collapse (mean) execution_rate = y2 (sd) sd_execution = y2 (count) n_execution = y2, ///
    by(binprob_fixed_bin)
replace sd_execution = 0 if missing(sd_execution)
gen se_execution = sd_execution / sqrt(n_execution)
gen execution_lower = max(0, execution_rate - 1.96 * se_execution)
gen execution_upper = min(1, execution_rate + 1.96 * se_execution)
replace execution_rate = 100 * execution_rate
replace execution_lower = 100 * execution_lower
replace execution_upper = 100 * execution_upper
keep binprob_fixed_bin execution_rate execution_lower execution_upper
tempfile panel_a_execution
save `panel_a_execution', replace

use `fixed_bins', clear
merge 1:1 binprob_fixed_bin using `panel_a_predicted', nogen
merge 1:1 binprob_fixed_bin using `panel_a_realized', nogen
merge 1:1 binprob_fixed_bin using `panel_a_execution', nogen

foreach var in predicted_nonexecuted_percent predicted_executed_percent realized_high_bin_percent {
    replace `var' = 0 if missing(`var')
}

sort binprob_fixed_bin

twoway ///
    (area predicted_nonexecuted_percent binprob_fixed_mid, fcolor(navy%15) lcolor(navy%0) lwidth(vvthin)) || ///
    (area predicted_executed_percent binprob_fixed_mid, fcolor(green%15) lcolor(green%0) lwidth(vvthin)) || ///
    (area realized_high_bin_percent binprob_fixed_mid, fcolor(gs8%15) lcolor(gs8%0) lwidth(vvthin)) || ///
    (rarea execution_lower execution_upper binprob_fixed_mid, fcolor(red%15) lcolor(red%0) lwidth(vvthin)) || ///
    (line execution_rate binprob_fixed_mid, lcolor(red) lwidth(medthin)), ///
    ytitle("Percentage (%)") ///
    xtitle("Predicted probability of above-median evasion") ///
    ylabel(0(25)100, grid) ///
    xlabel(0(.1)1, grid) ///
    xscale(range(0 1)) ///
    legend(order(2 "Predicted probability, executed" ///
                 1 "Predicted probability, non-executed" ///
                 3 "Realized high-bin cases" ///
                 5 "P(execution | predicted probability)") ///
           rows(2) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_a_binprob_fixed010_fullaudits.pdf", replace

************************************************************
* 4. Panel B: Algorithm-selected and inspector-selected cases
************************************************************
use `fullaudits', clear
keep if algorithm == 1 & !missing(y2)
collapse (mean) execution_algorithm = y2 (sd) sd_algorithm = y2 (count) n_algorithm = y2, ///
    by(binprob_fixed_bin)
egen total_algorithm = total(n_algorithm)
gen distribution_algorithm = 100 * n_algorithm / total_algorithm
replace sd_algorithm = 0 if missing(sd_algorithm)
gen se_algorithm = sd_algorithm / sqrt(n_algorithm)
gen execution_algorithm_lower = max(0, execution_algorithm - 1.96 * se_algorithm)
gen execution_algorithm_upper = min(1, execution_algorithm + 1.96 * se_algorithm)
replace execution_algorithm = 100 * execution_algorithm
replace execution_algorithm_lower = 100 * execution_algorithm_lower
replace execution_algorithm_upper = 100 * execution_algorithm_upper
keep binprob_fixed_bin distribution_algorithm execution_algorithm execution_algorithm_lower execution_algorithm_upper
tempfile panel_b_algorithm
save `panel_b_algorithm', replace

use `fullaudits', clear
keep if dgid == 1 & !missing(y2)
collapse (mean) execution_inspector = y2 (sd) sd_inspector = y2 (count) n_inspector = y2, ///
    by(binprob_fixed_bin)
egen total_inspector = total(n_inspector)
gen distribution_inspector = 100 * n_inspector / total_inspector
replace sd_inspector = 0 if missing(sd_inspector)
gen se_inspector = sd_inspector / sqrt(n_inspector)
gen execution_inspector_lower = max(0, execution_inspector - 1.96 * se_inspector)
gen execution_inspector_upper = min(1, execution_inspector + 1.96 * se_inspector)
replace execution_inspector = 100 * execution_inspector
replace execution_inspector_lower = 100 * execution_inspector_lower
replace execution_inspector_upper = 100 * execution_inspector_upper
keep binprob_fixed_bin distribution_inspector execution_inspector execution_inspector_lower execution_inspector_upper
tempfile panel_b_inspector
save `panel_b_inspector', replace

use `fixed_bins', clear
merge 1:1 binprob_fixed_bin using `panel_b_algorithm', nogen
merge 1:1 binprob_fixed_bin using `panel_b_inspector', nogen

foreach var in distribution_algorithm distribution_inspector {
    replace `var' = 0 if missing(`var')
}

sort binprob_fixed_bin

twoway ///
    (area distribution_algorithm binprob_fixed_mid, fcolor(maroon%14) lcolor(maroon%0) lwidth(vvthin)) || ///
    (area distribution_inspector binprob_fixed_mid, fcolor(orange%17) lcolor(orange%0) lwidth(vvthin)) || ///
    (rarea execution_algorithm_lower execution_algorithm_upper binprob_fixed_mid, fcolor(maroon%10) lcolor(maroon%0) lwidth(vvthin)) || ///
    (rarea execution_inspector_lower execution_inspector_upper binprob_fixed_mid, fcolor(orange%12) lcolor(orange%0) lwidth(vvthin)) || ///
    (line execution_algorithm binprob_fixed_mid, lcolor(maroon) lwidth(medthin)) || ///
    (line execution_inspector binprob_fixed_mid, lcolor(orange) lwidth(medthin)) ||, ///
    ytitle("Percentage (%)") ///
    xtitle("Predicted probability of above-median evasion") ///
    ylabel(0(25)100, grid) ///
    xlabel(0(.1)1, grid) ///
    xscale(range(0 1)) ///
    legend(order(1 "Algorithm cases distribution" ///
                 2 "Inspector cases distribution" ///
                 5 "Algorithm cases P(execution | predicted probability)" ///
                 6 "Inspector cases P(execution | predicted probability)") ///
           rows(2) size(small) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_b_binprob_fixed010_fullaudits.pdf", replace
