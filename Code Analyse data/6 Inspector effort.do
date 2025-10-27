*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   October 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*This script creates summary statistics
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
esttab vauds using "$output\void_audit_stats",  replace booktabs cell(b(fmt(%3.0fc))) noobs  unstack nonumber ///
nomtitle collabels(none)  eqlabels(, lhs("Void Audit"))


*** Analisis will focus on executed audits 
** Void audit rate by inspector and method
*preserve
rename n total_assigned


*preserve
collapse (sum) total_assigned has_duration void_audit (sum) total_executed = y2 , by(verificateur1 method)

rename has_duration_investigation has_duration
reshape wide has_duration void_audit total_executed total_assigned, i(verificateur1) j(method, string)


** Generating total
egen total_executed_audits = rowtotal(total_executed*)
egen total_assigned_audits = rowtotal(total_assigned*)
egen total_void_audit = rowtotal(void_audit*)
egen total_has_duration = rowtotal(has_duration*)

** Generating shares of void audits 
foreach met in Algorithm Inspectors Random {
	gen share_v_`met' = (void_audit`met'/total_executed_audits)*100 // void audit rate
	gen share_exec_`met' = (total_executed`met'/total_executed_audits)*100
}

*** Generate some stats
*Number of inspectors with positve N of algo executed algo cases

foreach met in Algorithm Inspectors Random {
	gen has_executed_`met' = (total_executed`met'>0 & total_executed`met'!=.)
	replace share_v_`met' = . if has_executed_`met' == 0
	}

*gen has_executed_algo = (total_executedAlgorithm>0)
*** Kdensity to evaluate distribution of void audit cases by inspector 
foreach met in Algorithm Inspectors Random {
	sum share_v_`met' if has_executed_`met'==1
	local avg_`met' = round(r(mean), 0.01)
	local count_`met' = r(N)
	di `avg_`met''
	di `count_`met''
}

local text_pos = 50

twoway (kdensity share_v_Algorithm if has_executed_Algorithm==1 , lc(eltblue)) || ///
(kdensity share_v_Inspectors if has_executed_Inspectors==1, lc(dkorange)) || ///
(kdensity share_v_Random if has_executed_Random==1, lc(gray)),  ///
xline(`avg_Algorithm', lc(eltblue) lp(-)) ///
xline(`avg_Inspectors', lc(dkorange) lp(-))  ///
xline(`avg_Random',  lc(gray) lp(-))  ///
	text(0.05 `text_pos'  "{bf:Algorithm}-selected average void audit rate: `avg_Algorithm'%, N inspectors: `count_Algorithm'", ///
	just(left) place(e) size(vsmall) color(eltblue)) ///
	text(0.045 `text_pos'  "{bf:Inspector}-selected average void audit rate: `avg_Inspectors'%, N inspectors: `count_Inspectors'", ///
	just(left) place(e) size(vsmall) color(dkorange)) ///
	text(0.04 `text_pos'  "{bf:Randomly}-selected average void audit rate: `avg_Random'%, N inspectors: `count_Random'", ///
	just(left) place(e) size(vsmall) color(gray)) ///
xtitle("Share of void audits over total execution") ///
ytitle("Density") legend(off)
graph export "$output\kdensity_void_audit_rate.pdf", replace




**Statistics on inspectors
eststo tab_assigned: estpost tabstat total_assignedAlgorithm total_assignedInspectors total_assignedRandom total_assigned_audits, stat(mean sd N) column(variables)

eststo tab_executed: estpost tabstat total_executedAlgorithm total_executedInspectors total_executedRandom total_executed_audits, stat(mean sd N) columns(variables)

eststo tab_share_execution: estpost tabstat share_exec_Algorithm share_exec_Inspectors share_exec_Random, stat(mean sd N) columns(variables)

eststo tab_share_vauds: estpost tabstat share_v_Algorithm share_v_Inspectors share_v_Random, stat(mean sd N) columns(variables)

*Assigned panel
esttab tab_assigned using "$output\inspector_stats", replace fragment booktabs cell("total_assignedAlgorithm total_assignedInspectors total_assignedRandom total_assigned_audits") unstack nostar nomtitle nonum  noobs nonote  ///
collabels("Algorithm" ///
        "Inspectors" ///
        "Random" ///
		"Total") ///
		prehead("\begin{tabular}{l*{4}{c}} \hline")  ///
		posthead("\hline \multicolumn{@span}{l}{\textbf{Panel A: No. assigned cases}} \\") ///
		postfoot("\hline")


*Execution panel
esttab tab_executed using  "$output\inspector_stats", fragment booktabs append cell("total_executedAlgorithm total_executedInspectors total_executedRandom total_executed_audits") unstack nostar nomtitle noobs nonum nonote ///
collabels("Algorithm" ///
        "Inspectors" ///
        "Random" ///
		"Total") ///
		posthead("\hline \multicolumn{@span}{l}{\textbf{Panel B: No. executed cases}} \\") ///
		postfoot("\hline \end{tabular}")

		
		


*Share Execution panel
esttab tab_share_execution using  "$output\inspector_shares_stats", replace fragment booktabs cell("share_exec_Algorithm share_exec_Inspectors share_exec_Random") unstack nostar nomtitle noobs  nonum nonote  ///
collabels("Algorithm" ///
        "Inspectors" ///
        "Random") ///
		prehead("\begin{tabular}{l*{4}{c}} \hline") ///
		posthead("\hline \multicolumn{@span}{l}{\textbf{Panel A: Share Execution  over implementation}} \\") ///
		postfoot("\hline") 

*Share Execution panel

esttab tab_share_vauds using  "$output\inspector_shares_stats", booktabs fragment append cell("share_v_Algorithm share_v_Inspectors share_v_Random") unstack nostar nomtitle nonum nonote noobs onecell ///
collabels("Algorithm" ///
        "Inspectors" ///
        "Random") ///
		posthead("\hline \multicolumn{@span}{l}{\textbf{Panel B: Share void audit over implementation}} \\") ///
		postfoot("\hline \end{tabular}") 

s

*Valid sample?
*Number of inspectors that have duration stats for all executed audit

*Stats on inspector average number of cases 

	
gen has_dates_audits = (total_has_duration>=total_executed_audits )
gen has_valgos = (void_auditAlgorithm!=. & void_auditAlgorithm!=0 )

gen has_dates_valgos = (has_dates_audits==1 & has_valgos==1)



*+ number of inspectors that have void_audit_algorithm + duration_stats


tabstat  total_executed* , stat( min mean max )

eststo share_v_stats: estpost tabstat  share_v_Algorithm share_v_Inspectors share_v_Random, ///
stat( min mean  max  sd N) col(stats) 	
count 
local count_insp = r(N)
esttab share_v_stats using "$output/stats_insp_vaudits", replace  booktabs /// 
cells("min(fmt(a3)) mean(fmt(a3)) max(fmt(a3)) sd(fmt(a3)) count(fmt(a3))") ///
varlabels(share_v_Algorithm  "Algorithm" ///
        share_v_Inspectors "Inspectors" ///
        share_v_Random     "Random") ///
		nomtitle nonumber noobs note("Total number of Inspectors: `count_insp'")
		

tab has_audits

****
s

*restore
********************************************************************************
**# Pre post bad audit analysis 
*preserve 

*generate list of verificateur that have al their executed audits with date

keep if total_has_duration>=total_executed_audits 
keep if void_auditAlgorithm!=. & void_auditAlgorithm!=0

keep verificateur1 has_*
merge 1:m verificateur1  using "$analysisdata/datasetforanalysis.dta" 
keep if _merge==3
keep if selection == 1  
drop if safeties == 1
keep if y2==1 & x2==0

*Restrict sample to selected cases


*Only inspectors that have executed algorithm selected audits

clonevar open =  earliestdate
clonevar close =  dateconfirmation 
replace close = datenotification if dateconfirmation==. & datenotification!=.


sort verificateur1 (open)

*Generate void_audit to flag bad cases
gen void_audit =  (y4==0 & y2==1)


label var void_audit "Executed audit without detected evasion"
label define vaudit 0 "No"  1 "Yes"
label values void_audit vaudit

gen void_algo_audit =  (y4==0 & method=="Algorithm")


gen date_valgo = close if void_algo_audit==1
bys verificateur1: egen t_0  = min(date_valgo)
format date_valgo t_0 %td
format date_valgo %td

keep if has_executed_Algorithm==1

bys verificateur1 (open): gen audit_execution_order = _n

** creating t variable
bys verificateur1 (open): gen t_aux = open -  t_0

drop if t_aux==.

bys verificateur1 (open): egen first_valgo_audit: min() 
gen t=0 if t_0 
bys gen pre  = open <  t_0
gen post = `openvar' >= t_cut


label var void_audit "Executed audit without detected evasion"
label define vaudit 0 "No"  1 "Yes"
label values void_audit vaudit


* count the total executed cases by inspector
bys verificateur1: gen total_exec = _N
s
keep if total_has_duration>=total_executed_audits 
s

keep verificateur1  


