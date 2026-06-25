*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         June 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file recreates the two Figure 4 panels for selected full audits using
* a two-step Random Forest prediction with the original detection gate and no
* second-stage revenue weights.

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

global rawdata "$rootdir"
global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
global output "$rootdir\Analysis all data\replication_package\Output"

if $check == 1 {
    global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
}

local twostep_unweighted_input "$output\fullaudits_predicted_twostep_unweighted.dta"
local plot_threshold 14.5
local plot_xmax 25

************************************************************
* 1. Load selected non-safety full audits
************************************************************
use "`twostep_unweighted_input'", clear

foreach var in yhatrf y2 y4 algorithm dgid selection safeties controle {
    capture confirm variable `var'
    if _rc {
        di as error "Required variable `var' not found in `twostep_unweighted_input'."
        exit 111
    }
}

keep if selection == 1
drop if safeties == 1
keep if controle == 2
drop if missing(yhatrf)

tempfile fullaudits
save `fullaudits', replace

************************************************************
* 2. Panel A: All selected full audits
************************************************************
use `fullaudits', clear
keep if !missing(y2)
gen mid_bin = floor(yhatrf) + 0.5
keep if mid_bin >= `plot_threshold'

gen n_nonexecuted = y2 == 0
gen n_executed = y2 == 1
collapse (sum) n_nonexecuted n_executed, by(mid_bin)
egen total_nonexecuted = total(n_nonexecuted)
egen total_executed = total(n_executed)
gen predicted_nonexecuted_percent = 100 * n_nonexecuted / total_nonexecuted
gen predicted_executed_percent = 100 * n_executed / total_executed
keep mid_bin predicted_nonexecuted_percent predicted_executed_percent
tempfile panel_a_predicted
save `panel_a_predicted', replace

use `fullaudits', clear
keep if y2 == 1 & !missing(y4)
gen mid_bin = floor(y4) + 0.5
keep if mid_bin >= `plot_threshold'
collapse (count) n_realized = y4, by(mid_bin)
egen total_realized = total(n_realized)
gen realized_evasion_percent = 100 * n_realized / total_realized
keep mid_bin realized_evasion_percent
tempfile panel_a_realized
save `panel_a_realized', replace

use `fullaudits', clear
keep if !missing(y2)
gen mid_bin = floor(yhatrf) + 0.5
keep if mid_bin >= `plot_threshold'
collapse (mean) execution_rate = y2 (sd) sd_execution = y2 (count) n_execution = y2, by(mid_bin)
replace sd_execution = 0 if missing(sd_execution)
gen se_execution = sd_execution / sqrt(n_execution)
gen execution_lower = max(0, execution_rate - 1.96 * se_execution)
gen execution_upper = min(1, execution_rate + 1.96 * se_execution)
replace execution_rate = 100 * execution_rate
replace execution_lower = 100 * execution_lower
replace execution_upper = 100 * execution_upper
keep mid_bin execution_rate execution_lower execution_upper
tempfile panel_a_execution
save `panel_a_execution', replace

use `panel_a_predicted', clear
merge 1:1 mid_bin using `panel_a_realized', nogen
merge 1:1 mid_bin using `panel_a_execution', nogen

foreach var in predicted_nonexecuted_percent predicted_executed_percent realized_evasion_percent {
    replace `var' = 0 if missing(`var')
}

sort mid_bin

twoway ///
    (area predicted_nonexecuted_percent mid_bin, fcolor(navy%15) lcolor(navy%0) lwidth(vvthin)) || ///
    (area predicted_executed_percent mid_bin, fcolor(green%15) lcolor(green%0) lwidth(vvthin)) || ///
    (area realized_evasion_percent mid_bin, fcolor(gs8%15) lcolor(gs8%0) lwidth(vvthin)) || ///
    (rarea execution_lower execution_upper mid_bin, fcolor(red%15) lcolor(red%0) lwidth(vvthin)) || ///
    (line execution_rate mid_bin, lcolor(red) lwidth(medthin)), ///
    ytitle("Percentage (%)") ///
    xtitle("Evasion (log FCFA)") ///
    ylabel(0(25)100, grid) ///
    xlabel(14.5 17.5 20 22.5 25, grid) ///
    xscale(range(`plot_threshold' `plot_xmax')) ///
    legend(order(2 "Predicted evasion, executed" ///
                 1 "Predicted evasion, non-executed" ///
                 3 "Detected evasion" ///
                 5 "P(execution|predicted evasion)") ///
           rows(2) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_a_twostep_unweighted_yhatrf_fullaudits.pdf", replace

************************************************************
* 3. Panel B: Algorithm-selected and inspector-selected cases
************************************************************
use `fullaudits', clear
keep if algorithm == 1 & !missing(y2)
gen mid_bin = floor(yhatrf) + 0.5
keep if mid_bin >= `plot_threshold'
collapse (mean) execution_algorithm = y2 (sd) sd_algorithm = y2 (count) n_algorithm = y2, by(mid_bin)
egen total_algorithm = total(n_algorithm)
gen distribution_algorithm = 100 * n_algorithm / total_algorithm
replace sd_algorithm = 0 if missing(sd_algorithm)
gen se_algorithm = sd_algorithm / sqrt(n_algorithm)
gen execution_algorithm_lower = max(0, execution_algorithm - 1.96 * se_algorithm)
gen execution_algorithm_upper = min(1, execution_algorithm + 1.96 * se_algorithm)
replace execution_algorithm = 100 * execution_algorithm
replace execution_algorithm_lower = 100 * execution_algorithm_lower
replace execution_algorithm_upper = 100 * execution_algorithm_upper
keep mid_bin distribution_algorithm execution_algorithm execution_algorithm_lower execution_algorithm_upper
tempfile panel_b_algorithm
save `panel_b_algorithm', replace

use `fullaudits', clear
keep if dgid == 1 & !missing(y2)
gen mid_bin = floor(yhatrf) + 0.5
keep if mid_bin >= `plot_threshold'
collapse (mean) execution_inspector = y2 (sd) sd_inspector = y2 (count) n_inspector = y2, by(mid_bin)
egen total_inspector = total(n_inspector)
gen distribution_inspector = 100 * n_inspector / total_inspector
replace sd_inspector = 0 if missing(sd_inspector)
gen se_inspector = sd_inspector / sqrt(n_inspector)
gen execution_inspector_lower = max(0, execution_inspector - 1.96 * se_inspector)
gen execution_inspector_upper = min(1, execution_inspector + 1.96 * se_inspector)
replace execution_inspector = 100 * execution_inspector
replace execution_inspector_lower = 100 * execution_inspector_lower
replace execution_inspector_upper = 100 * execution_inspector_upper
keep mid_bin distribution_inspector execution_inspector execution_inspector_lower execution_inspector_upper

merge 1:1 mid_bin using `panel_b_algorithm', nogen

foreach var in distribution_algorithm distribution_inspector {
    replace `var' = 0 if missing(`var')
}

sort mid_bin

twoway ///
    (area distribution_algorithm mid_bin, fcolor(maroon%14) lcolor(maroon%0) lwidth(vvthin)) || ///
    (area distribution_inspector mid_bin, fcolor(orange%17) lcolor(orange%0) lwidth(vvthin)) || ///
    (rarea execution_algorithm_lower execution_algorithm_upper mid_bin, fcolor(maroon%10) lcolor(maroon%0) lwidth(vvthin)) || ///
    (rarea execution_inspector_lower execution_inspector_upper mid_bin, fcolor(orange%12) lcolor(orange%0) lwidth(vvthin)) || ///
    (line execution_algorithm mid_bin, lcolor(maroon) lwidth(medthin)) || ///
    (line execution_inspector mid_bin, lcolor(orange) lwidth(medthin)) ||, ///
    ytitle("Percentage (%)") ///
    xtitle("Evasion (log FCFA)") ///
    ylabel(0(25)100, grid) ///
    xlabel(14.5 17.5 20 22.5 25, grid) ///
    xscale(range(`plot_threshold' `plot_xmax')) ///
    legend(order(1 "Algorithm Cases Distribution" ///
                 2 "Inspector Cases Distribution" ///
                 5 "Algorithm Cases P(execution|predicted evasion)" ///
                 6 "Inspector Cases P(execution|predicted evasion)") ///
           rows(2) size(small) position(6) region(lcolor(none))) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "$output\figure4_panel_b_twostep_unweighted_yhatrf_fullaudits.pdf", replace
