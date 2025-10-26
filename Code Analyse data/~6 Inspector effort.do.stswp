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

global check  1 // to save outside official replication folder
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
	global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
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
**# Execution rate before and after the algorithm
********************************************************************************
** Identify  and flag bad algo cases 
** Create a post pre bad case panel
*Load dataset for analysis

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

** Focus on desk audits for now 
keep if x2==0

**Defining initial and final dates of audit execution
cap drop earliestdate earliestdate2 
cap drop earliestnotification


** setting earliest date as in 
gen earliestdate = datededemarrage 

foreach v in datedemanderenseignement datedavisdatededemandede ///
s_date_demande_information dateavis s_date_avis  {
	replace earliestdate  = `v' if earliestdate == . 
}

** data availability on dates
foreach date of varlist earliestdate dateconfirmation datenotification ///
duration_investigation  {
	gen	has_`date' = `date'!=.
	*replace has_
	}


	
*Count how many audits have valid duration information
gen has_initfinaldate = has_earliestdate==1  & (has_dateconfirmation==1 ///
| has_datenotification==1)

gen has_confnot = (has_dateconfirmation==1 | has_datenotification==1)
gen has_confnotonly = (has_earliestdate==0) & (has_datenotification==1 ///
| has_dateconfirmation==1)

gen n=1 /// just a count

*labeling variables
label var has_initfinaldate "Initial and final date Avail."
label var has_duration "Valid Duration stat available "
label var has_confnotonly "Has either Conf. or Notif. date"
label var n "Total Executed Cases"

  

* Methods in columns; variables as rows
eststo clear
estpost tabstat n has_initfinaldate has_duration_investigation has_confnotonly if y2==1, by(method) stat(sum) column(stats)

 

* 2) Show methods as columns, variables as rows
*"using "$output\date_availability_stats.tex", replace booktabs"
esttab . using "$output\date_availability_stats",  replace  booktabs ///
    cells("sum(fmt(0))") unstack ///
    collabels(none) /// suppress stat-label row
    noobs nomtitles nonumber label nonotes ///
    eqlabels("Algorithm" "Inspectors" "Random" "Total") ///
    title("Table: stats per method")

* only 282 audits have date and could be in an event study sample?
*Idea, make (january 2, selectionyear) the start date ? 
*for cases with audit with notification but no early (valid) date
*

***
**# Generate inspector level data on n audits 
*** 

*Generate void_audit to flag bad cases
gen void_audit =  (y4==0 & y2==1)
replace void_audit=. if y2==0 

label var void_audit "Executed audit without detected evasion"
label define vaudit 0 "No"  1 "Yes"
label values void_audit vaudit

*** Table with stats on void cases per method 
eststo clear
eststo vauds: estpost tab void_audit method if y2==1, 

* Now export: two columns side-by-side with your headers
esttab vauds,  cell(b(fmt(%3.0fc))) noobs  unstack nonumber ///
nomtitle collabels(none)  eqlabels(, lhs("Void Audit"))




*** Analisis will focus on executed audits 
keep if y2==1 

preserve
collapse (sum) has_duration void_audit (count) total_executed = has_duration , by(verificateur1)

count if (has_duration == total_executed) & void_audit>0 
**Inspector level audit case stats
bys verificateur1: gen case_count = _N
bys verificateur1: egen total_valid_cases = total(has_duration)
s
** Collapse (mean) by inspector, void audit (yes no), 
collapse (sum) n void_audit , by(verificateur1 method y2 )
encode method, gen(method2)
drop method
rename method2 method

reshape wide n void_audit, i(verificateur1 method ) j(y2)

rename n1 n_executed
rename n0 n_notexecuted

mvencode n_executed n_notexecuted void_audit* , mv(0) override

egen total_cases =  rowtotal(n_executed n_notexecuted)
drop n_notexecuted void_audit0

reshape wide total_cases void_audit n_executed, i(verificateur1 ) j(method)
rename verificateur1 verificateur0
rename *1 *_algo
rename *2 *_insp
rename *3 *_random
sort verifi
mvencode _all , mv(0) override
order verificateur total_cases_* n_executed* void_audit*

*** Total assigned cases
egen total_assigned_audits = rowtotal(total_cases*)
egen total_n_executed = rowtotal(n_executed*)
egen total_void_audits = rowtotal(void_audit*)

**Main variable: share of bad algo cases
*Among  total number of executed cases
foreach method in algo insp random{
	gen s_v_`method'_exe = (void_audit1_`method'/total_n_executed)*100
	gen s_v_`method'_assigned = (void_audit1_`method'/total_assigned_audits)*100
}

**Density: Share of void algo cases conditional on  having being an algo case and executed at least one algo case 
twoway(kdensity s_v_algo_exe if n_executed_algo >0) || , xtitle("Share of void algorithm cases") ytitle("Density")

s



** Total cases assigned by inspector 
bys verificateur1: egen total_assigned_audits = total(n) 
*executed cases by inspector
bys verificateur1 : egen total_started_audits = total(n) if y2==1
bys verificateur1 : egen max_total_started_audits = max(total_started_audits)
drop total_started_audits 
rename max_total_started_audits total_started_audits
replace total_started_audits =0 if total_started_audits ==.

*Try with different definitions of bad audit share_void_totalgo
gen share 
reshape wide y2, i(verificateur1 void_audit bad_algo_case n total_assigned_audits total_started_audits) j(n)

*Bad cases by inspector 

tab void_audit






** Verificateur  = Inspector
encode verificateur1, gen(id_verificateur)
gen n=1
collapse (sum) n, by(verificateur1 id_verificateur)

*Duration variables
gen duration_investigation = datenotification - earliestdate 
replace duration_investigation = dateconfirmation - earliestdate if duration_investigation == .
replace duration_investigation = . if duration_investigation < 0
replace duration_investigation = . if duration_investigation > 600
label var duration_investigation "days spent on case"
