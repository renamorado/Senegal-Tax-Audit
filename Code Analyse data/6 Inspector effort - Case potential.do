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



*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   October 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*Goal assess changes in inspector effort once they discover that a bad algorithm selected audit case

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
	global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
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
	global output "C:\Users\wb648862\Documents\Projects\Senegal Tax Audits\Output"
	}
	di "$output"

*****
	
***
**# compare shares of algo + random cases in year 1 versus year 2 
***



*Scatter plot - Inspector level analysis
*** Table with stats on void cases per method 
** Focus on desk audits for now 

*use "$analysisdata/datasetforanalysis.dta", clear

* using dataset with predicted evasion 
use "$analysisdata\fullaudits_predicted.dta"

estimates drop  _all


**# Select general sample

*Restrict sample to selected cases
*keep if selection == 1  
*drop if safeties == 1

*some quick checks

egen tag_inspectorclusteryear = tag(inspectorclusteryear)
count if tag_inspectorclusteryear==1


** Idea of non-parametric test

************************************************************
* Approach 3 (FULL audits): list = inspectorclusteryear
* order = sequencing ; alg = algorithm ; exec = y2 ; score = yhatrf
************************************************************

* Quintiles of yhatrf WITHIN list (among alg cases)
egen yhatrf_q5 = xtile(yhatrf), by(inspectorclusteryear)  nq(5)   // or nquantiles(4)
* Keep only algorithm cases 
*so shares will be now share of execution of total assigned algo
keep if algorithm==1

* Sequence within list - 
bys inspectorclusteryear (sequencing): gen alg_seq = _n
bys inspectorclusteryear: gen n_alg = _N

* Potential group of the FIRST 10% alg case in the list
egen seq_q10 = xtile(alg_seq), by(inspectorclusteryear)  nq(10)   // or nquantiles(4)
gen first_algo = seq_q10==1



s

gen temp_group_first = .
replace temp_group_first = 1 if first_algo==1 & yhatrf_q5==5   // High potential first case (top 20%)
replace temp_group_first = 0 if first_algo==1 & yhatrf_q5==1   // Low potential first case (bottom 20%)

bys inspectorclusteryear: egen group_first = max(temp_group_first)

keep if inlist(group_first,0,1)

label define grp 0 "Low potential first alg case" 1 "High potential first alg case"
label values group_first grp

gen n = 1
collapse (mean) exec_rate_alg = y2 (sum) N_alg  = n, by(group_first inspectorclusteryear)

* List execution rate among alg cases


tempfile listlevel
save `listlevel', replace

**************************************************
* Boxplots: unweighted vs weighted by n_alg
**************************************************
* Unweighted: each list counts equally
graph box exec_rate_alg, over(group_first) name(g_unw, replace) ///
    ytitle("Execution rate of assigned algorithm cases") ///
    title("Unweighted (each list equal)")

* Weighted: each list replicated by # alg cases in list (exact weighting)
preserve
use `listlevel', clear

expand N_alg
graph box exec_rate_alg, over(group_first) name(g_w, replace) ///
    ytitle("") ///
    title("Weighted by # algorithm cases per list")
restore

graph combine g_unw g_w, cols(2)
graph export "$output\execution_rate_fullaudtis_boxplot.pdf", replace 



