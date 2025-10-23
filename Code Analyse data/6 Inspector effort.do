*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   October 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*This script creates summary statistics

set more off
clear all 

*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","49354415") { 										// Alipio's computer
		global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}
	
/*	
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits"				// Insert path to shared Dropbox folder "Senegal Tax Audits"
	}
*/	
	
		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

********************************************************************************
**# Implementation rate before and after the algorithm
********************************************************************************
***Implementation rate after a void case 
** Identify  and flag bad algo cases 

*Load dataset for analysis

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

** keep only algorithm cases 
keep if method == "Algorithm"
kdensity y4


ds, has(format %td)
br `r(varlist)' if x2==0 & y2==1
di "`r(varlist)'"

*Identify void selected cases 
gen void_audit =  (y4==0 & y2==1)
replace void_audit=. if y2==0
s
tab void_audit

foreach var of varlist earliestdate dateconfirmation datenotification  {
	has_`earliest_date' = earliestdate !=. 
	
}
s
*Duration variables
gen duration_investigation = datenotification - earliestdate 
replace duration_investigation = dateconfirmation - earliestdate if duration_investigation == .
replace duration_investigation = . if duration_investigation < 0
replace duration_investigation = . if duration_investigation > 600
label var duration_investigation "days spent on case"
