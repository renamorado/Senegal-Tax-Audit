*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   RA: Roldan Enamorado
**		   November 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

/*
This code merges the predicted evasion from the random forest model
with finaldatasetforanalysis.dta to classify cases by evasion risk
and verify whether they appear at the top of the ranking.
*/


*Set-up
set scheme stcolor
set more off
clear all 

global check = 1 // to save outside official replication folder
*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","49354415") { 										// Alipio's computer
		global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}
	
	if strpos("`c(username)'","wb648862") { 										// Roldan's computer
		global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
	}
	
	
	if $check == 1 {
	global output "C:\Users\User\OneDrive\World Bank\Senegal-Tax-Audit\Output"
	}
	di "$output"
	
/*	
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits"				// Insert path to shared Dropbox folder "Senegal Tax Audits"
	}
*/	
	
		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		
		if $check == 1 {
	global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
	}
	di "$output"

********************************************************************************
	
***
**# compare shares of algo + random cases in year 1 versus year 2 
***



*Scatter plot - Inspector level analysis
*** Table with stats on void cases per method 
** Focus on desk audits for now 

*use "$analysisdata/datasetforanalysis.dta", clear

* using dataset with predicted evasion 
* Temp containers for FULL audits exec_rate only (Panel A + Panel B
tempfile EST_full_execA EST_full_execB
* Will hold the protected model lists for FULL audits exec_rate
local PA_exec ""
local PB_exec ""
foreach audtype in 1 0 {
    local audit_type = cond(`audtype'==1, "Full", "Desk")
	local by_collapse = cond(`audtype'==1, "group_first inspectorclusteryear", "group_first inspectorclusteryear")
    di "`audit_type'"
	
	
	* from 07_Optimization_Excercise.R
	use "$analysisdata\audits_predicted_1.dta", clear
	append using "$analysisdata\audits_predicted_2.dta"
	

	* Only wipe estimates at the start of FULL iteration; keep them when moving to DESK
if (`audtype'==1) estimates drop _all
	
**# Select general sample

*Restrict sample to selected cases
*keep if selection == 1  
*drop if safeties == 1

*some quick checks

egen tag_inspectorclusteryear = tag(inspectorclusteryear)
count if tag_inspectorclusteryear==1


********************************************************************************
* Approach 3 (Full and desk audits): list = inspectorclusteryear
* order = sequencing ; alg = algorithm ; exec = y2 ; score = yhatrf
********************************************************************************

*Subsample according to audit type 
	keep if x2==`audtype'
	* Quintiles of yhatrf WITHIN list (among all methods cases)
	*Quintiles for desk audits are estimated within bureau_detailed and selection year 
	*inspectorclusteryear year in full audits = bureau_detailed + year
	if `audtype'==0 {
		egen bureauselectionyear = group(bureau_detailed selectionyear)
		egen yhatrf_q5 = xtile(yhatrf), by(verificateur_selection selectionyear)  nq(5) 
		egen yhatrf_q4 = xtile(yhatrf), by(verificateur_selection selectionyear)  nq(4) 
	}
	*inspectorclusteryear year in desk audits = inspector (verificateur_selection + year)
	*Quantiles for full audits: quantiles are estimated within bureau_detailed - seleciton year 
	
	else {
		egen yhatrf_q5 = xtile(yhatrf), by(bureau_detailed selectionyear)  nq(5)   // or nquantiles(4)
		egen yhatrf_q4 = xtile(yhatrf), by(bureau_detailed selectionyear)  nq(4)   // or nquantiles(4)
	}

		

* Keep only algorithm cases 
*so shares will be now share of execution of total assigned algo
	keep if algorithm==1  

* Sequence within list - 
	bys inspectorclusteryear (sequencing): gen alg_seq = _n
	bys inspectorclusteryear: gen n_alg = _N

* Potential group of the FIRST 10% alg case in the list
	egen seq_q10 = xtile(alg_seq), by(inspectorclusteryear)  nq(10)   // or nquantiles(4)
	gen first_algo10pc = (seq_q10==1)  
	gen first_algo1_2 = (alg_seq<=2)	// alternative definition
	gen first_algo1 = (alg_seq==1)	// alternative definition
	gen first_algo20pc = (seq_q10==1 | seq_q10==2) 
	
	
	*first definition of first in list: first 10% to be executed
	gen temp_group_first10pc = .
	replace temp_group_first10pc = 1 if first_algo10pc==1 & yhatrf_q5==5   // High potential first case (top 20%)
replace temp_group_first10pc = 0 if first_algo10pc==1 & yhatrf_q5==1   // Low potential first case (bottom 20%)

bys inspectorclusteryear: egen group_first10pc = max(temp_group_first10pc)

	*second definition of first in list: first and second to be executed
	gen temp_group_first1_2 = .
	replace temp_group_first1_2 = 1 if first_algo1_2==1 & yhatrf_q5==5   // High potential first case (top 20%)
replace temp_group_first1_2 = 0 if first_algo1_2==1 & yhatrf_q5==1   // Low potential first case (bottom 20%)

bys inspectorclusteryear: egen group_first1_2 = max(temp_group_first1_2)


	*3rd definition of first in list: first to be executed
	gen temp_group_first1 = .
	replace temp_group_first1 = 1 if first_algo1==1 & yhatrf_q5==5   // High potential first case (top 20%)
replace temp_group_first1 = 0 if first_algo1==1 & yhatrf_q5==1   // Low potential first case (bottom 20%)

bys inspectorclusteryear: egen group_first1 = max(temp_group_first1)

	*4th definition continuous measure first 20pc: first to be executed
	gen temp_group_first20pc = .
	replace temp_group_first20pc = 1 if first_algo20pc==1 & yhatrf_q5==5   // High potential first case (top 20%)
replace temp_group_first20pc = 0 if first_algo20pc==1 & yhatrf_q5==1   // Low potential first case (bottom 20%)

bys inspectorclusteryear: egen group_first20pc = max(temp_group_first20pc)

*****
**# Regressions
*****
** additional vars for regression 

label define grp 0 "Low potential first alg case" 1 "High potential first alg case"
label values group_first10pc grp
label values group_first1_2 grp
label values group_first1 grp

*descrete design 1
foreach x in "10pc" "20pc" "1_2" "1" {
	gen good`x' = group_first`x'==1
	gen bad`x'	= group_first`x'==0
	bys inspectorclusteryear: egen total_good_first`x' = total(temp_group_first`x')
	bys inspectorclusteryear:  egen total_first_algo`x' = total(first_algo`x')
	gen share_good`x' = total_good_first`x'/total_first_algo`x'
}



*continuous measure:
 *share of top 20% cases among the top 20% of the sequence 



*keep if inlist(group_first,0,1)

* --- poor-case flags as characteristics (do NOT condition on execution) ---
gen bottom20 = (yhatrf_q5==1) if !missing(yhatrf_q5)
gen bmedian  = (yhatrf_q4<=2) if !missing(yhatrf_q4)

* --- Option B: execution rate among bad assigned
* (mean of y2 within bad subset) -> make y2 missing outside subset
gen y2_bottom20 = y2 if bottom20==1
gen y2_bmedian  = y2 if bmedian==1

* --- Option C: executed bad per assigned (mean of y2*bad over all assigned)
gen exec_bottom20 = y2*bottom20
gen exec_bmedian  = y2*bmedian

* bookkeeping
encode bureau_detailed, gen(bureauid)


**************************************************
* Boxplots: unweighted vs weighted by n_alg
**************************************************
**# Create boxplot with at the list level
gen n = 1
*numeric var  of bureau

collapse ///
    (mean) exec_rate = y2 ///                      baseline: executed / assigned
           b20 = y2_bottom20 ///        Option B: executed / assigned bottom20
           bmedian  = y2_bmedian  ///
           b20t   = exec_bottom20 ///      Option C: executed bottom20 / assigned
           bmediant    = exec_bmedian  ///
    (count) N_alg = n ///
            N_bottom20_assigned = y2_bottom20 ///
            N_bmedian_assigned  = y2_bmedian ///
    , by(group_first* good* bad* share_good* inspectorclusteryear selectionyear bureauid)

**# Regressions  discrete specification
*Dependent var: executed_rate_alg add exec_rate_bmedian and exec_rate_bottom20
local dvlist "exec_rate b20 b20t"

* Nice labels for refcat / filenames
local dvlabel_exec_rate      "Algorithm Execution rate"
local dvlabel_b20  "Execution rate of bottom-20\% cases"
local dvlabel_b20t "Executed bottom-20\% \/ assigned (all)"

*Iterate among differnt RHS variables
	
eststo clear

cap drop good bad
gen good = .
gen bad  = .


* Choose xlist by audit type (you were exporting only Top2/10pc/20pc in full audits)
if (`audtype'==1) local xlist "1_2 10pc 20pc"
else              local xlist "1 1_2 10pc 20pc"

foreach dv of local dvlist {

    eststo clear

    foreach x of local xlist {
        replace good = good`x'
        replace bad  = bad`x'

        if (`audtype' == 1) {
            * -------- No FE (OLS) --------
            eststo `dv'_m`x'_nofe: regress `dv' i.good i.bad, vce(robust)
            estadd local YearFE   "No"
            estadd local BureauFE "No"

            * -------- Selection-year FE --------
            eststo `dv'_m`x'_yr: reghdfe `dv' i.good i.bad, absorb(selectionyear) vce(robust)
            estadd local YearFE   "Yes"
            estadd local BureauFE "No"

            * -------- Bureau FE --------
            eststo `dv'_m`x'_bfe: reghdfe `dv' i.good i.bad, absorb(bureauid) vce(robust)
            estadd local YearFE   "No"
            estadd local BureauFE "Yes"
        }
        else {
            * -------- Desk audits: selectionyear + bureauid FE --------
            eststo `dv'_m`x': reghdfe `dv' i.good i.bad, absorb(selectionyear bureauid) vce(robust)
            estadd local YearFE   "Yes"
            estadd local BureauFE "Yes"
        }
    }

    * ---------------- Export ----------------
    if (`audtype' == 1) {
        local models "`dv'_m1_2_nofe `dv'_m10pc_nofe `dv'_m20pc_nofe"
        local models "`models' `dv'_m1_2_yr `dv'_m10pc_yr `dv'_m20pc_yr"
        local models "`models' `dv'_m1_2_bfe `dv'_m10pc_bfe `dv'_m20pc_bfe"

        esttab `models' using "$output/inspectors_reg_discrete_`audit_type'_`dv'.tex", replace ///
            booktabs ///
            keep(1.good 1.bad) ///
            coeflabels(1.good "High potential evasion case in list =1" ///
                       1.bad  "Low potential evasion case in list =1") ///
            mtitles("Top 2" "First 10\% seq" "First 20\% seq" ///
                    "Top 2" "First 10\% seq" "First 20\% seq" ///
                    "Top 2" "First 10\% seq" "First 20\% seq") ///
            mgroups("No FE" "Selection year FE" "Bureau FE", ///
                pattern(1 0 0 1 0 0 1 0 0) ///
                span prefix(\multicolumn{@span}{c}{) suffix(}) ///
                erepeat(\cmidrule(lr){@span})) ///
            refcat(1.good "\textbf{Dependent variable}: ``dvlabel_`dv''", nolabel) ///
            b(%9.3f) se(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) ///
            stats(YearFE BureauFE N r2, ///
                labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
                fmt(%9s %9s %9.0f %9.3f)) ///
            nonotes
			* Save stored estimates for FULL audits exec_rate (Panel A: discrete)
		* --- Capture Panel A models (FULL audits, exec_rate) into protected names ---
		if (`audtype'==1 & "`dv'"=="exec_rate") {
			local PA_exec ""
			foreach m of local models {
				cap estimates drop A_`m'
				estimates restore `m'
				estimates store A_`m'
				local PA_exec "`PA_exec' A_`m'"
			}
		}
    }
    else {
        local models "`dv'_m1 `dv'_m1_2 `dv'_m10pc `dv'_m20pc"

        esttab `models' using "$output/inspectors_reg_discrete_`audit_type'_`dv'.tex", replace ///
            booktabs ///
            keep(1.good 1.bad) ///
            coeflabels(1.good "High potential evasion case in list =1" ///
                       1.bad  "Low potential evasion case in list =1") ///
            mtitles("Top 1" "Top 2" "First 10\% seq" "First 20\% seq") ///
            refcat(1.good "\textbf{Dependent variable}: ``dvlabel_`dv''", nolabel) ///
            b(%9.3f) se(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) ///
            stats(YearFE BureauFE N r2, ///
                labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
                fmt(%9s %9s %9.0f %9.3f)) ///
            nonotes
    }
}

**# Regressions  continous measure specification
eststo clear

cap drop share_good
gen share_good = .

if (`audtype'==1) local xlist "1_2 10pc 20pc"
else              local xlist "1 1_2 10pc 20pc"

foreach dv of local dvlist {

    eststo clear

    foreach x of local xlist {
        replace share_good = share_good`x'

        if (`audtype' == 1) {
            eststo `dv'_mshare`x'_nofe: regress `dv' share_good, vce(robust)
            estadd local YearFE   "No"
            estadd local BureauFE "No"

            eststo `dv'_mshare`x'_yr: reghdfe `dv' share_good, absorb(selectionyear) vce(robust)
            estadd local YearFE   "Yes"
            estadd local BureauFE "No"

            eststo `dv'_mshare`x'_bfe: reghdfe `dv' share_good, absorb(bureauid) vce(robust)
            estadd local YearFE   "No"
            estadd local BureauFE "Yes"
        }
        else {
            eststo `dv'_mshare`x': reghdfe `dv' share_good, absorb(selectionyear bureauid) vce(robust)
            estadd local YearFE   "Yes"
            estadd local BureauFE "Yes"
        }
    }

    if (`audtype' == 1) {
        local models "`dv'_mshare1_2_nofe `dv'_mshare10pc_nofe `dv'_mshare20pc_nofe"
        local models "`models' `dv'_mshare1_2_yr `dv'_mshare10pc_yr `dv'_mshare20pc_yr"
        local models "`models' `dv'_mshare1_2_bfe `dv'_mshare10pc_bfe `dv'_mshare20pc_bfe"

        esttab `models' using "$output/inspectors_reg_share_`audit_type'_`dv'.tex", replace ///
            booktabs ///
            keep(share_good) ///
            coeflabels(share_good "Share of potential evasion case at the top") ///
            mtitles("Top 2" "First 10\% seq" "First 20\% seq" ///
                    "Top 2" "First 10\% seq" "First 20\% seq" ///
                    "Top 2" "First 10\% seq" "First 20\% seq") ///
            mgroups("No FE" "Selection year FE" "Bureau FE", ///
                pattern(1 0 0 1 0 0 1 0 0) ///
                span prefix(\multicolumn{@span}{c}{) suffix(}) ///
                erepeat(\cmidrule(lr){@span})) ///
            refcat(share_good "\textbf{Dependent variable}: ``dvlabel_`dv''", nolabel) ///
            b(%9.3f) se(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) ///
            stats(YearFE BureauFE N r2, ///
                labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
                fmt(%9s %9s %9.0f %9.3f)) ///
            nonotes
			* Save stored estimates for FULL audits exec_rate (Panel B: continuous)
* --- Capture Panel B models (FULL audits, exec_rate) into protected names ---
* --- Capture Panel B models (FULL audits, exec_rate) into short protected names ---
		if (`audtype'==1 & "`dv'"=="exec_rate") {
			local PB_exec ""
			foreach m of local models {
				cap estimates drop B_`m'
				estimates restore `m'
				estimates store B_`m'
				local PB_exec "`PB_exec' B_`m'"
			}
		}
			
    }
    else {
        local models "`dv'_mshare1 `dv'_mshare1_2 `dv'_mshare10pc `dv'_mshare20pc"

        esttab `models' using "$output/inspectors_reg_share_`audit_type'_`dv'.tex", replace ///
            booktabs ///
            keep(share_good) ///
            coeflabels(share_good "Share of high predicted evasion case at the top") ///
            mtitles("Top 1" "Top 2" "First 10\% seq" "First 20\% seq") ///
            refcat(share_good "\textbf{Dependent variable}: ``dvlabel_`dv''", nolabel) ///
            b(%9.3f) se(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) ///
            stats(YearFE BureauFE N r2, ///
                labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
                fmt(%9s %9s %9.0f %9.3f)) ///
            nonotes
    }
}
* List execution rate among alg cases


tempfile listlevel
save `listlevel', replace


* Unweighted: each list counts equally
graph box exec_rate if inlist(group_first10pc,0,1), over(group_first10pc) name(g_unw, replace) ///
    ytitle("Execution rate of assigned algorithm cases") ///
    title("Unweighted (each list equal)")

* Weighted: each list replicated by # alg cases in list (exact weighting)
preserve
	use `listlevel', clear

	expand N_alg
	graph box exec_rate if inlist(group_first10pc,0,1), over(group_first10pc) name(g_w, replace) ///
		ytitle("") ///
		title("Weighted by # algorithm cases per list")

	graph combine g_unw g_w, cols(2)
	graph export "$output\execution_rate_boxplot_`audit_type'.pdf", replace
restore

}

********************************************************************************
* FINAL STACKED TABLE (FULL audits exec_rate): Panel A + Panel B from CLONED estimates
********************************************************************************
local outpan "$output/inspectors_reg_panels_Full_exec_rate.tex"
local dvlabel_exec_rate "Algorithm Execution rate"

local ncols : word count `PA_exec'
local span  = `ncols' + 1

********************************************************************************
* FINAL STACKED TABLE (FULL audits exec_rate): Panel A + Panel B from CLONED estimates
********************************************************************************
local outpan "$output/inspectors_reg_panels_Full_exec_rate.tex"

local ncols : word count `PA_exec'
local span  = `ncols' + 1

* Build header rows as locals (avoids unmatched quotes)
local headA "\multicolumn{`span'}{l}{\textbf{Dependent variable}: Algorithm execution rate}\\ \addlinespace \multicolumn{`span'}{l}{\textbf{Panel A: Discrete measures}}\\ \addlinespace \midrule"

* --- Build the custom header row (DV in stub + the 9 column titles) ---
local dvrow "\multicolumn{1}{l}{\textbf{Algorithm execution rate}} & Top 2 & First 10\% seq & First 20\% seq & Top 2 & First 10\% seq & First 20\% seq & Top 2 & First 10\% seq & First 20\% seq \\"
local postA "`dvrow' \midrule \multicolumn{`span'}{l}{\textbf{Panel A: Discrete measures}}\\ \addlinespace"

* Panel A (custom header; Panel A title below the line)
esttab `PA_exec' using "`outpan'", replace fragment ///
    prehead("\begin{tabular}{l*{`ncols'}{c}} \toprule") ///
    posthead("`postA'") ///
    postfoot("") ///
    booktabs ///
    nonumbers nomtitles collabels(none) ///
    keep(1.good 1.bad) ///
    coeflabels(1.good "High potential evasion case in list =1" ///
               1.bad  "Low potential evasion case in list =1") ///
    mgroups("No FE" "Selection year FE" "Bureau FE", ///
        pattern(1 0 0 1 0 0 1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}) ///
        erepeat(\cmidrule(lr){@span})) ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(YearFE BureauFE N r2, ///
        labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
        fmt(%9s %9s %9.0f %9.3f)) ///
    nonotes
	
	* ---------------- Panel B (NO DV line) ----------------
esttab `PB_exec' using "`outpan'", append fragment ///
    prehead("\addlinespace \midrule \multicolumn{`span'}{l}{\textbf{Panel B: Continuous measure}}\\ \addlinespace") ///
    posthead("") ///
    postfoot("\bottomrule \end{tabular}") ///
    booktabs ///
    nomtitles nonumbers collabels(none) ///
    keep(share_good) ///
    coeflabels(share_good "Share of high predicted evasion case at the top") ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(YearFE BureauFE N r2, ///
        labels("Selection Year FE" "Bureau FE" "Observations" "R-squared") ///
        fmt(%9s %9s %9.0f %9.3f)) ///
    nonotes
	
***************
**# Scatter plots
*************** 

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1
gen rank_assigned = sequencing/maxsequencing
* (Optional) nice variable labels in the table
label var sequencing       "Rank in list (seq)"
label var algorithm "Algorithm"
label var overlap   "Overlap"
label var random    "Random"
label var safeties  "Safeties"
label var rank_assigned  "Rank / total assigned"

forvalues i = 1/5 {
    gen top_list_`i' = (sequencing <= `i') if !missing(sequencing)
    label var top_list_`i' "Seq \$\le\$ `i'"
}
*Full audits 
eststo ry2_full: reghdfe y2 sequencing algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk1: reghdfe y2 sequencing algorithm overlap random safeties if x2 == 0, a(controlbureauannee) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk2: reghdfe y2 sequencing algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)

qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "Yes"

**# with the rank/totalassigned


*Full audits 
eststo ry2_full_ratio: reghdfe y2 rank_assigned algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk1_ratio: reghdfe y2 rank_assigned algorithm overlap random safeties if x2 == 0, a(controlbureauannee) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk2_ratio: reghdfe y2 rank_assigned algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)

qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "Yes"

**# discrete: top 5 in the list 
*Full audits 
eststo ry2_full_top: reghdfe y2 i.top_list_5 algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk1_top: reghdfe y2 i.top_list_5 algorithm overlap random safeties if x2 == 0, a(controlbureauannee) vce(robust)
qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "No"

*desk audits
eststo ry2_desk2_top: reghdfe y2 i.top_list_5 algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)

qui sum y2 if e(sample)==1 
estadd local meanoutcome = int(100*`r(mean)')/100
local meanoutcome = int(100*`r(mean)')/100
local meanoutcome : di %5.2f `meanoutcome'
estadd local pp `meanoutcome'
test algorithm == safeties
local pvalue : di %5.2f `r(p)'
estadd local pvalue = round(`pvalue', 0.01)
estadd local N = e(N)	, replace
		
estadd local taxcenteryear "Yes"
estadd local inspectoryear "Yes"


*======================================================
* ESTTAB export for: ry2_full ry2_desk1 ry2_desk2
*======================================================



esttab ry2_full ry2_desk1 ry2_desk2 ///
       ry2_full_ratio ry2_desk1_ratio ry2_desk2_ratio /// 
	   ry2_full_top ry2_desk1_top ry2_desk2_top ///
    using "$output/table_exec_seq.tex", replace ///
    label se b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    noomitted nobaselevels ///
    keep(sequencing rank_assigned 1.top_list_5 algorithm overlap random) ///
    order(sequencing rank_assigned 1.top_list_5 algorithm overlap random) ///
    mtitles("Full audits" "Desk audits" "Desk audits" ///
            "Full audits" "Desk audits " "Desk audits" ///
			"Full audits" "Desk audits " "Desk audits") ///
    mgroups("Sequence" "Rank/ Total assigned ratio" "Top 5 in sequence=1", ///
        pattern(1 0 0 1 0 0 1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}) ///
        erepeat(\cmidrule(lr){@span})) ///
    stats(pp N taxcenteryear inspectoryear, ///
        labels("Mean of dep. var." "N" "Tax center × year FE" "Inspector × year FE") ///
        fmt(%9.2f %9.0f %9s %9s)) ///
    booktabs nonotes compress

	/* *Create variable for sequencing 
bys inspectorclusteryear: egen maxsequencing = max(sequencing)
*/