*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TAX AUDIT SELECTION IN SENEGAL
**         Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**         RA: Roldan Enamorado
**         May 2026
*****************************************************************************************

*****************
** DESCRIPTION **
*****************

* This do-file creates a compact Table 4 Column 1 comparison for full audits.
* It keeps the original P(Execution) specification as Column 1, then adds a
* cleaner grid of controls based on the unweighted Random Forest predicted rank.
* Because inspectorclusteryear is the original full-audit list fixed effect, the
* grid focuses on flexible within-list predicted-priority controls rather than
* adding separate list fixed effects.

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

local table4_rank_input "$analysisdata\fullaudits_predicted_rank_bureauyear.dta"
local table_col1_rank_controls "$output\table4_col1_predicted_rank_control_comparison.tex"
local table_col1_rank_support "$output\table4_col1_predicted_rank_support.tex"

************************************************************
* 1. Import predicted-rank data
************************************************************
use "`table4_rank_input'", clear

foreach var in y2 algorithm overlap random safeties x2 bureau_detailed selectionyear inspectorclusteryear predicted_rank_order_bureauyear {
    capture confirm variable `var'
    if _rc {
        di as error "Required variable `var' not found in `table4_rank_input'."
        exit 111
    }
}

************************************************************
* 2. Prepare selected non-safety full-audit sample
************************************************************
keep if selection == 1
drop if safeties == 1

capture confirm variable controle
if !_rc {
    keep if controle == 2
}

capture drop table4_col1_stratum
egen table4_col1_stratum = group(x2 bureau_detailed selectionyear), missing

capture drop rank_list_n_col1
bysort table4_col1_stratum: egen rank_list_n_col1 = count(predicted_rank_order_bureauyear)

capture drop rank_order_col1
gen rank_order_col1 = predicted_rank_order_bureauyear if predicted_rank_order_bureauyear != .
label var rank_order_col1 "Within-list predicted rank order, rank 1 = highest predicted priority"

capture drop rank_order_sq_col1
gen rank_order_sq_col1 = rank_order_col1^2 if rank_order_col1 != .
label var rank_order_sq_col1 "Squared within-list predicted rank order"

capture drop rank_percentile_col1
gen rank_percentile_col1 = .
replace rank_percentile_col1 = (rank_order_col1 - 1) / (rank_list_n_col1 - 1) ///
    if rank_order_col1 != . & rank_list_n_col1 > 1
replace rank_percentile_col1 = 0 if rank_order_col1 != . & rank_list_n_col1 == 1
label var rank_percentile_col1 "Within-list predicted-rank percentile, 0 = highest predicted priority"

capture drop rank_percentile_sq_col1
gen rank_percentile_sq_col1 = rank_percentile_col1^2 if rank_percentile_col1 != .
label var rank_percentile_sq_col1 "Squared within-list predicted-rank percentile"

capture drop rank_decile_col1
egen rank_decile_col1 = xtile(rank_order_col1) if rank_order_col1 != ., by(table4_col1_stratum) nq(10)
label var rank_decile_col1 "Within-list predicted-rank decile, 1 = highest predicted priority"

capture drop rank_decile_list_fe_col1
egen rank_decile_list_fe_col1 = group(rank_decile_col1 inspectorclusteryear), missing
label var rank_decile_list_fe_col1 "Within-list predicted-rank decile by list fixed effect"

capture drop top10_rank_col1
capture drop topquartile_rank_col1
gen top10_rank_col1 = (rank_order_col1 <= ceil(0.10 * rank_list_n_col1)) if rank_order_col1 != .
gen topquartile_rank_col1 = (rank_order_col1 <= ceil(0.25 * rank_list_n_col1)) if rank_order_col1 != .
label var top10_rank_col1 "Top 10 percent within-list predicted rank"
label var topquartile_rank_col1 "Top quartile within-list predicted rank"

************************************************************
* 3. Export support for predicted-rank controls
************************************************************
file open support using `"`table_col1_rank_support'"', write replace
file write support "\begin{tabular}{lrrrrrr}" _n
file write support "\toprule" _n
file write support "Sample/bin & FE strata & Total N & Algorithm N & Inspector N & Executed N & Execution rate \\" _n
file write support "\midrule" _n

capture drop support_stratum_tag
egen support_stratum_tag = tag(table4_col1_stratum) if x2 == 1
quietly count if support_stratum_tag == 1
local strata_n = r(N)
quietly count if x2 == 1
local total_n = r(N)
quietly count if x2 == 1 & algorithm == 1
local alg_n = r(N)
quietly count if x2 == 1 & algorithm == 0
local insp_n = r(N)
quietly count if x2 == 1 & y2 == 1
local executed_n = r(N)
quietly summarize y2 if x2 == 1
local execrate : display %5.2f r(mean)
file write support "All selected full audits & `strata_n' & `total_n' & `alg_n' & `insp_n' & `executed_n' & `execrate' \\" _n
drop support_stratum_tag

foreach b in 1 2 3 4 5 6 7 8 9 10 {
    capture drop support_stratum_tag
    egen support_stratum_tag = tag(table4_col1_stratum) if x2 == 1 & rank_decile_col1 == `b'
    quietly count if support_stratum_tag == 1
    local strata_n = r(N)
    quietly count if x2 == 1 & rank_decile_col1 == `b'
    local total_n = r(N)
    quietly count if x2 == 1 & rank_decile_col1 == `b' & algorithm == 1
    local alg_n = r(N)
    quietly count if x2 == 1 & rank_decile_col1 == `b' & algorithm == 0
    local insp_n = r(N)
    quietly count if x2 == 1 & rank_decile_col1 == `b' & y2 == 1
    local executed_n = r(N)
    quietly summarize y2 if x2 == 1 & rank_decile_col1 == `b'
    local execrate : display %5.2f r(mean)
    file write support "Decile `b' & `strata_n' & `total_n' & `alg_n' & `insp_n' & `executed_n' & `execrate' \\" _n
    drop support_stratum_tag
}

foreach label in "Top 10 percent" "Top quartile" {
    local indicator top10_rank_col1
    if "`label'" == "Top quartile" {
        local indicator topquartile_rank_col1
    }

    capture drop support_stratum_tag
    egen support_stratum_tag = tag(table4_col1_stratum) if x2 == 1 & `indicator' == 1
    quietly count if support_stratum_tag == 1
    local strata_n = r(N)
    quietly count if x2 == 1 & `indicator' == 1
    local total_n = r(N)
    quietly count if x2 == 1 & `indicator' == 1 & algorithm == 1
    local alg_n = r(N)
    quietly count if x2 == 1 & `indicator' == 1 & algorithm == 0
    local insp_n = r(N)
    quietly count if x2 == 1 & `indicator' == 1 & y2 == 1
    local executed_n = r(N)
    quietly summarize y2 if x2 == 1 & `indicator' == 1
    local execrate : display %5.2f r(mean)
    file write support "`label' & `strata_n' & `total_n' & `alg_n' & `insp_n' & `executed_n' & `execrate' \\" _n
    drop support_stratum_tag
}

file write support "\bottomrule" _n
file write support "\end{tabular}" _n
file close support

************************************************************
* 4. Estimate compact Table 4 Column 1 rank-control variants
************************************************************
capture estimates drop _all

local specs original raw_add raw_list raw_list_quadratic percentile_add percentile_list percentile_list_quadratic decile_fe decile_list_fe top_priority
local estlist ""
local colindex = 0

foreach spec of local specs {
    local ++colindex

    local extra_controls ""
    local extra_absorb ""
    local ctrl_raw ""
    local ctrl_raw_list ""
    local ctrl_raw_quadratic ""
    local ctrl_percentile ""
    local ctrl_percentile_list ""
    local ctrl_percentile_quadratic ""
    local ctrl_decile_fe ""
    local ctrl_decile_list_fe ""
    local ctrl_top_priority ""

    if "`spec'" == "raw_add" {
        local extra_controls "rank_order_col1"
        local ctrl_raw "x"
    }
    if "`spec'" == "raw_list" {
        local extra_controls "c.rank_order_col1#i.inspectorclusteryear"
        local ctrl_raw_list "x"
    }
    if "`spec'" == "raw_list_quadratic" {
        local extra_controls "c.rank_order_col1#i.inspectorclusteryear c.rank_order_sq_col1#i.inspectorclusteryear"
        local ctrl_raw_quadratic "x"
    }
    if "`spec'" == "percentile_add" {
        local extra_controls "rank_percentile_col1"
        local ctrl_percentile "x"
    }
    if "`spec'" == "percentile_list" {
        local extra_controls "c.rank_percentile_col1#i.inspectorclusteryear"
        local ctrl_percentile_list "x"
    }
    if "`spec'" == "percentile_list_quadratic" {
        local extra_controls "c.rank_percentile_col1#i.inspectorclusteryear c.rank_percentile_sq_col1#i.inspectorclusteryear"
        local ctrl_percentile_quadratic "x"
    }
    if "`spec'" == "decile_fe" {
        local extra_controls "i.rank_decile_col1"
        local ctrl_decile_fe "x"
    }
    if "`spec'" == "decile_list_fe" {
        local extra_absorb "rank_decile_list_fe_col1"
        local ctrl_decile_list_fe "x"
    }
    if "`spec'" == "top_priority" {
        local extra_controls "top10_rank_col1 topquartile_rank_col1"
        local ctrl_top_priority "x"
    }

    eststo m`colindex': reghdfe y2 algorithm overlap random safeties `extra_controls' if x2 == 1, ///
        a(inspectorclusteryear `extra_absorb') vce(robust)

    estadd local ctrl_raw "`ctrl_raw'"
    estadd local ctrl_raw_list "`ctrl_raw_list'"
    estadd local ctrl_raw_quadratic "`ctrl_raw_quadratic'"
    estadd local ctrl_percentile "`ctrl_percentile'"
    estadd local ctrl_percentile_list "`ctrl_percentile_list'"
    estadd local ctrl_percentile_quadratic "`ctrl_percentile_quadratic'"
    estadd local ctrl_decile_fe "`ctrl_decile_fe'"
    estadd local ctrl_decile_list_fe "`ctrl_decile_list_fe'"
    estadd local ctrl_top_priority "`ctrl_top_priority'"

    quietly summarize y2 if e(sample) == 1
    local meanoutcome = int(100 * `r(mean)') / 100
    local meanoutcome : display %5.2f `meanoutcome'
    local nobs = e(N)
    estadd local nobs "`nobs'"
    estadd local pp `meanoutcome'

    local estlist "`estlist' m`colindex'"
}

#delim ;
esttab `estlist'
    using `"`table_col1_rank_controls'"',
    replace fragment booktabs
    prehead("\begin{tabular}{lcccccccccc} \toprule")
    posthead("\multicolumn{1}{l}{} & \multicolumn{10}{c}{P(Execution)} \\\cmidrule(lr){2-11} \multicolumn{1}{l}{} & Original & \multicolumn{3}{c}{Raw rank} & \multicolumn{3}{c}{Rank percentile} & \multicolumn{2}{c}{Rank decile} & Top priority \\\cmidrule(lr){3-5}\cmidrule(lr){6-8}\cmidrule(lr){9-10}\cmidrule(lr){11-11} \multicolumn{1}{l}{} & 1 & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9 & 10 \\ \midrule")
    postfoot("\bottomrule \end{tabular}")
    order(algorithm overlap random)
    keep(algorithm overlap random)
    coeflabels(algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random")
    b(%5.2f) se(%5.2f)
    stats(ctrl_raw ctrl_raw_list ctrl_raw_quadratic ctrl_percentile ctrl_percentile_list ctrl_percentile_quadratic ctrl_decile_fe ctrl_decile_list_fe ctrl_top_priority nobs r2 pp,
        labels("Raw predicted rank" "Raw predicted rank X List" "Quadratic raw predicted rank X List" "Rank percentile" "Rank percentile X List" "Quadratic rank percentile X List" "Rank decile FE" "Rank decile FE X List" "Top 10 pct. and top quartile" "N" "R2" "Mean outcome"))
    star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant
    nomtitles nonumbers collabels(none) nonotes
    substitute(\_ _)
;
#delim cr
