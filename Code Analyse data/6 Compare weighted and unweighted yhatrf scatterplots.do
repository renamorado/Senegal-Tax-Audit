*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         May 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file compares the current RF predicted evasion score with the
* optimization-weighted RF predicted evasion score. It exports separate
* scatterplots for full audits and desk audits, first for the selected
* non-safety sample and then for executed cases only.

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

local key "firmid selectionyear x2 inspectorclusteryear sequencing"

************************************************************
* 1. Load the current RF predictions
************************************************************
use "$analysisdata\fullaudits_predicted.dta", clear
append using "$analysisdata\deskaudits_predicted.dta"

keep `key' yhatrf selection safeties y2 controle
rename yhatrf yhatrf_unweighted
isid `key'

tempfile unweighted_predictions
save `unweighted_predictions', replace

************************************************************
* 2. Load the top-quartile weighted RF predictions
************************************************************
use "$analysisdata\audits_predicted_2.dta", clear
append using "$analysisdata\audits_predicted_1.dta"

keep `key' yhatrf
rename yhatrf yhatrf_weighted
isid `key'

************************************************************
* 3. Merge current and weighted predictions
************************************************************
merge 1:1 `key' using `unweighted_predictions'
assert _merge == 3
drop _merge

************************************************************
* 4. Keep the graph sample
************************************************************
keep if selection == 1
drop if safeties == 1
drop if missing(yhatrf_weighted, yhatrf_unweighted)

count
di as result "Merged selected cases: " r(N)

tempfile merged_predictions
save `merged_predictions', replace

************************************************************
* 5. Loop over audit type and sample
************************************************************
foreach audit_type in full desk {

    use `merged_predictions', clear

    if "`audit_type'" == "full" {
        keep if x2 == 1
        keep if controle == 2
        local audit_title "Full audits"
        local output_stub "$output\yhatrf_weighted_vs_unweighted_fullaudits"
    }
    else {
        keep if x2 == 0
        keep if controle == 1
        local audit_title "Desk audits"
        local output_stub "$output\yhatrf_weighted_vs_unweighted_deskaudits"
    }

    tempfile audit_predictions
    save `audit_predictions', replace

    foreach sample in selected executed {

        use `audit_predictions', clear

        if "`sample'" == "selected" {
            local sample_title "Selected cases"
            local output_file "`output_stub'.pdf"
        }
        else {
            keep if y2 == 1
            local sample_title "Executed cases only"
            local output_file "`output_stub'_executed.pdf"
        }

        count
        assert r(N) > 1
        di as result "`audit_title', `sample_title' rows: " r(N)

        ************************************************************
        * 6. Estimate the comparison line and build graph labels
        ************************************************************
        regress yhatrf_weighted yhatrf_unweighted

        local intercept = _b[_cons]
        local slope = _b[yhatrf_unweighted]
        local intercept_text : display %5.2f `intercept'
        local slope_text : display %5.2f `slope'
        local formula "Weighted = `intercept_text' + `slope_text'*Unweighted"

        tempvar fitted_yhatrf
        gen `fitted_yhatrf' = `intercept' + `slope' * yhatrf_unweighted
        replace `fitted_yhatrf' = . if `fitted_yhatrf' < 0

        quietly summarize yhatrf_unweighted
        local x_max = r(max)
        local x_text = 17

        quietly summarize yhatrf_weighted
        local y_max = r(max)
        local y_text = r(min) + 0.08 * (r(max) - r(min))

        local axis_max = 5 * ceil(max(`x_max', `y_max') / 5)

        ************************************************************
        * 7. Export the scatterplot
        ************************************************************
        twoway ///
            (function y = x, range(0 `axis_max') ///
                lcolor(black) lpattern(dash) lwidth(thin)) ///
            (scatter yhatrf_weighted yhatrf_unweighted, ///
                mcolor(navy%45) msymbol(circle_hollow) msize(small)) ///
            (line `fitted_yhatrf' yhatrf_unweighted, sort ///
                lcolor(maroon) lwidth(medthick)), ///
            title("`audit_title'") ///
            subtitle("`sample_title'") ///
            ytitle("Top quartile weighted predicted evasion (log FCFA)") ///
            xtitle("Unweighted predicted evasion (log FCFA)") ///
            xscale(range(0 `axis_max')) ///
            yscale(range(0 `axis_max')) ///
            xlabel(0(5)`axis_max') ///
            ylabel(0(5)`axis_max') ///
            text(`y_text' `x_text' "`formula'", place(ne) size(small) color(black)) ///
            legend(order(2 "Cases" 3 "OLS fit" 1 "Equivalence") position(6) rows(1) region(lcolor(none))) ///
            graphregion(color(white)) ///
            plotregion(color(white))

        graph export "`output_file'",  replace
    }
}
