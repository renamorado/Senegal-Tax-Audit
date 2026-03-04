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

**# Objective
*  Plot by deciles of evasion the number of inspectors and average duration of cases 


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

*****

	use "$analysisdata\fullaudits_predicted.dta", clear
	append using "$analysisdata\deskaudits_predicted.dta"

	
********	
* Plot by deciles of evasion the number of inspectors and average duration of cases 
*********

** Setting sample for full audits only 
keep if x2 == 1 


** sample 
tab method y2

**# Obtaining bins of predicted evasion within selection method
* Bins are computed within selection method (Algorithm vs Inspectors).
bysort method: egen min_raw = min(yhatrf)
bysort method: egen max_raw = max(yhatrf)
gen min_v = floor(min_raw)
gen max_v = ceil(max_raw)
drop min_raw max_raw

* Create bins (width of 1)
gen bin = floor(yhatrf - min_v) + min_v
replace bin = max_v if bin > max_v


* Calculate mid_bin
gen mid_bin = bin + 0.5


**$ generating bin level dataset for algorithm cases 
*preserve


* Calculate statistics by bin
* obtaining the average number of inspectors per bin, sd per bin, and the number of cases per bin

gen n=1 
keep if y2==1 // conditional on execution 
collapse (mean) avg_y2=y2 avg_ninspectors= numberagents avg_y19 = y19 (sd) sd_y2=y2 ///
sd_ninspectors = numberagents sd_y19 = y19 (sum) n=n, by( method bin mid_bin)

foreach x in y2 ninspectors y19 {
* Calculate variance and standard error
gen var_`x' = sd_`x'^2

gen se_`x' = sqrt(var_`x' / n)

* Calculate confidence intervals
gen ci_lower_`x' = avg_`x' - 1.96 * se_`x'
gen ci_upper_`x' = avg_`x' + 1.96 * se_`x'

replace ci_lower_`x' = 0 if !missing(ci_lower_`x') & ci_lower_`x' < 0
*replace ci_upper_`x' = 1 if !missing(ci_upper_`x') & ci_upper_`x' > 1
}
* Convert to percentages
*replace avg_`x' = avg_`x' * 100 



*replace ci_lower_`x' = ci_lower_`x'*100

*replace ci_upper_`x' = ci_upper_`x'*100

*replicating figure 4 
* Colors (Stata supports hex; best in quotes)
local col_alg "#9E0142"
local col_ins "orange"

twoway ///
    (rarea ci_upper_ninspectors ci_lower_ninspectors mid_bin if method=="Algorithm"  & mid_bin, ///
        sort fcolor(`col_alg') fintensity(inten10) lcolor(`col_alg'%0)) ||  ///
    (line  avg_ninspectors  mid_bin if method=="Algorithm"  & mid_bin, ///
        sort lcolor("`col_alg'"%50) lwidth(medthick)) || ///
    (rarea ci_upper_ninspectors ci_lower_ninspectors mid_bin if method=="Inspectors" ///
	& mid_bin, sort fcolor(`col_ins'%50) fintensity(10) lcolor(`col_ins'%0)) ///
    (line  avg_ninspectors  mid_bin if method=="Inspectors" & mid_bin, ///
        sort lcolor(`col_ins'%50) lwidth(medthick)), ///
    ytitle("Average number of inspectors") xtitle("Evasion (log FCFA)") ///
    legend(order(2 "Algorithm Cases P(Agents assigned | predicted evasion)" ///
                 4 "Inspector Cases P(Agents assigned | predicted evasion)") ///
				 pos(6) col(1) row(2)) graphregion(color(white)) ///
				 plotregion(color(white))  graphregion(color(white)) plotregion(color(white))
				 
				 
				 

twoway ///
    (rarea ci_upper_y19 ci_lower_y19 mid_bin if method=="Algorithm"  & mid_bin, ///
        sort fcolor(`col_alg') fintensity(inten10) lcolor(`col_alg'%0)) ||  ///
    (line  avg_y19  mid_bin if method=="Algorithm"  & mid_bin, ///
        sort lcolor("`col_alg'"%50) lwidth(medthick)) || ///
    (rarea ci_upper_y19 ci_lower_y19 mid_bin if method=="Inspectors" ///
	& mid_bin, sort fcolor(`col_ins'%50) fintensity(10) lcolor(`col_ins'%0)) ///
    (line  avg_y19  mid_bin if method=="Inspectors" & mid_bin, ///
        sort lcolor(`col_ins'%50) lwidth(medthick)), ///
    ytitle("Average duration (days)") xtitle("Evasion (log FCFA)") ///
    legend(order(2 "Algorithm Cases P(Duration from start to Conf | predicted evasion)" ///
                 4 "Inspector Cases P(Duration from start to Conf | predicted evasion)") ///
				 pos(6) col(1) row(2)) graphregion(color(white)) ///
				 plotregion(color(white))  graphregion(color(white)) plotregion(color(white))
