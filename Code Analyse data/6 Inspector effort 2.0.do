*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   October 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*Goal assess changes in inspector effort once they discover that a bad algorithm selected audit case

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
**# Select general sample
*****************************

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

*defining x2 labels
label define audittype 0 "Desk audits" 1 "Full audits"
label values x2 audittype

**Defining initial and final dates of audit execution
cap drop earliestdate earliestdate2 
cap drop earliestnotification

*********************************************
**# Defining date and void audit variables
*********************************************

** Opening date: start of an audit
gen openingdate = datededemarrage 

foreach v in datedemanderenseignement datedavisdatededemandede ///
s_date_demande_information dateavis s_date_avis  {
	replace openingdate  = `v' if openingdate == . 
}

** Closing date: end of an audit 
egen closingdate = rowmin(datenotification dateconfirmation)
tab closingdate y2

format closingdate openingdate %td

** Data availability on dates
foreach date of varlist openingdate dateconfirmation datenotification ///
duration_investigation closingdate {
	gen	has_`date' = `date'!=.
	}

label define dv 1 "Has only opening date" 2 "Has only closing date" 3 "Has both" 4 "Has neither"
gen date_avail = .
replace date_avail  = 1 if has_openingdate==1 & has_closingdate==0   
replace date_avail  = 2 if has_openingdate==0 & has_closingdate==1
replace date_avail  = 3 if has_openingdate==1 & has_closingdate==1
replace date_avail  = 4 if has_openingdate==0 & has_closingdate==0

label values date_avail dv 

**Generating table with date availability stats	
eststo dateavail: estpost tab date_avail x2  if y2==1

*Exporting table to LaTex
esttab dateavail using "$output\date_avail_by_type",  replace  booktabs ///
nostar unstack nomtitle nonum nonote noobs 

*****
**#  Void audit definition
*****
keep if y2==1 // keeping only executed audits 

**# Void audit var generation
*definitions of void audit 
gen null_evasion = (y4==0)
replace null_evasion=. if y2==0 

*Using notification and confirmation 
foreach audit_outcome of varlist notification confirmation {
	gen no_`audit_outcome' = (`audit_outcome'==0)
}

* was either notified or confirmed? 
gen notconf =. 
replace notconf = 1 if notification ==1 & confirmation==0
replace notconf = 2 if notification ==0 & confirmation==1
replace notconf = 3 if notification ==1 & confirmation==1
replace notconf = 4 if notification ==0 & confirmation==0
label values notconf nc 
label define nc 1 "Only Notified" 2 "Only Confirmed" 3 "Notified and Confirmed" 4 "Neither"

bys x2: tab notconf y3
** Some checks on the evasion values definition
di "Positive evasion cases:"
bys x2: tab notification confirmation if y3==1
di "Null evasion cases:"
bys x2: tab notification confirmation if y3==0
tab notconf null_evasion // audit has null evasion than their shouln't be notification or confirmation.



**# Defining void audit cases 
*Generate void_audit to flag bad cases
gen void_audit =  (y4==0 & y2==1)
replace void_audit=. if y2==0 


label var void_audit "Executed audit without detected evasion"
label define vaudit 0 "Evasion Detected"  1 "No evasion detected"
label values void_audit vaudit

label values null_evasion vaudit 

forval i =0/1 {
	eststo notconf_null_x`i': estpost tab notconf null_evasion if x2==`i' 
}

*Checking if null cases were notified or confirmed 
esttab notconf_null_x0 notconf_null_x1 using "$output\notconf_null_byaudtype", ///
replace booktabs mtitle("Desk audits" "Full audits") unstack nonum nonotes ///



**Some tabs to check if null evasion relationship with notification and confirmation 
bys x2: tab no_notification null_evasion 
bys x2: tab notification null_evasion 
tab notification x2 if null_evasion==0 & confirmation==0 
br if no_notification ==0
bys x2:  tab date_avail notification 

tab date_avail null_evasion

tab y4 if null_evasion==1 & date_avail==4
*check separately to avoid confusion

*******************
**# Date definition
******************

 
**# checking if the selection year = missing start date
preserve 
collapse (sum) y2, by (openingdate selectionyear)
format openingdate %td
format selectionyear %ty

twoway (bar y2 openingdate if selectionyear==2018 & y2<150,  color(eltblue) tline(01jan2018, lc(eltblue)) tline(31dec2018, lc(eltblue))) || ///
(bar y2 openingdate if selectionyear==2019 & y2<150, color(dkorange) tline(01jan2019, lc(dkorange)) tline(31dec2019, lc(dkorange))) || ///
(bar y2 openingdate if selectionyear==2020 & y2<150, color(gray) tline(01jan2020, lc(gray)) tline(31dec2020, lc(gray))), ///
legend(label(1 "2018") label(2 "2019") label(3 "2020") pos(6) row(1) subtitle("Selection year",size(small))) ///
ytitle("Number of executed Audit cases") 
graph export "$output\selection_year_opening_dates.pdf", replace
restore


preserve 
collapse (sum) y2, by (openingdate anneeduchrono)
format openingdate %td
format anneeduchrono %ty

twoway (bar y2 openingdate if anneeduchrono==2018 & y2<100,  color(eltblue) tline(01jan2018, lc(eltblue)) tline(31dec2018, lc(eltblue))) || ///
(bar y2 openingdate if anneeduchrono==2019 & y2<100, color(dkorange) tline(01jan2019, lc(dkorange)) tline(31dec2019, lc(dkorange))) || ///
(bar y2 openingdate if anneeduchrono==2020 & y2<100, color(gray) tline(01jan2020, lc(gray)) tline(31dec2020, lc(gray))), ///
legend(label(1 "2018") label(2 "2019") label(3 "2020") pos(6) row(1) subtitle("Annee du chrono year",size(small))) ///
ytitle("Number of executed Audit cases")
restore

**#Imputing missing dates 
* Option 1: Imputing closing date = start date + 1 month 
bys x2: tab date_avail null_evasion // null evasion cases mostly have only opening date available.

*Would imply imputing for 70% of audit cases

clonevar closingdate2 = closingdate
replace closingdate2  = openingdate  + 30 if closingdate2==. 

br openingdate  closingdate2 if closingdate==. 

tab closingdate2
gen has_closingdate2 = (closingdate2!=.)
tab  date_avail x2


clonevar openingdate2 = openingdate
replace openingdate2 = closingdate - 30 if openingdate==. & closingdate!=.

bys x2: ttest duration_investigation, by(null_evasion)


*average evasion 
bys x2: tabstat duration_investigation, by(null_evasion) stat(mean p25  p50 p75 sd N )

*There seems to be positive relationship with evasion size and duration 
*It would make sense to think that void audits would be shorter than non-void audits
scatter duration_investigation y4  if x2==0 & y4>0 || ///
lfit duration_investigation y4 if x2==0 & y4>0,  legend(pos(6))

/*


*Option 2: using the average duration of a void_audit

forval i = 0/1 {
	eststo vaud_dur_x`i': estpost tabstat duration_investigation if x2==`i', ///
	stat(mean min p25 p50 p75 max sd)  by(null_evasion)
}

esttab vaud_dur_x0 , cell(e(fmt(%3.0fc))) noobs  unstack nonumber

s

twoway (kdensity duration_investigation if null_evasion==1 & x2==1)  || ///
(kdensity duration_investigation if null_evasion==0 & x2==1)

*Option 3: average duration of each inspector
bys verificateur1: egen mean()
*/


****#
**# New approaches 1: Scatter plot inspector level analysis 
****
* compare shares of algo + random cases in year 1 versus year 2 

** Desk audits for now


*Scatter plot - Inspector level analysis
*** Table with stats on void cases per method 
** Focus on desk audits for now 

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

**# Select general sample

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

keep if x2==0 // Focus on desk audits 

gen null_evasion = (y4==0)
replace null_evasion=. if y2==0 

*generate start

*generate a count number 
gen n=1 
*collapse data at the inspector - year - bureau - selectionmethod level
* focus on 2018 -2019
rename y2 total_executed
rename n total_assigned

*Create set of conditions 
local cond1 "if selectionyear==2018 | selectionyear==2019"
local cond2 "if selectionyear==2019 | selectionyear==2020"
local cond3 ""


forval sample = 1/3 {
preserve	
*collapse (sum) total_assigned total_executed null_evasion 
collapse (sum) total_assigned total_executed null_evasion `cond`sample'', by(method groupbureau verificateur1 selectionyear) 
reshape wide total_assigned total_executed null_evasion, i(verificateur1 groupbureau selectionyear) j(method, string)

mvencode _all, mv(0) override
*tagging inspectors
egen tag_verificateur = tag(verificateur1)

** Tagging inspectors that are observed for two or more consecutive years in the same bureau
egen tag_verifbureau = tag(verificateur1 groupbureau)
bys verificateur1 groupbureau: gen verif_bureau_consecutive = _n

*check if verificateur didn't changed from office


bys verificateur1: egen sum_tags = total(tag_verifbureau)
tab sum_tags if tag_verificateur==1  // 92 out of 123 have didn't changed from bureau

gen unchanged_bureau = (sum_tags==1)
tab unchanged_bureau if tag_verificateur==1

*check if verificateur is observable for consecutive years
egen tag_years = tag(selectionyear)


bys verificateur1: gen verif_n = _n
bys verificateur1: egen max_verif_n = max(verif_n) 

*Only 20 inspectors were observed in the same 
tab max_verif_n if tag_verificateur==1 & sum_tags==1 

sum tag_years, d
di "`r(sum)'"
gen insp_consec = (max_verif_n==`r(sum)')

gen final_sample = insp_consec==1 & unchanged_bureau==1 

*save sample stats table for later
eststo tab_sample_`sample': estpost tabstat tag_verificateur unchanged_bureau insp_consec final_sample if tag_verificateur==1, stat(sum) column(statistics) 

keep if final_sample==1

** Generating total
egen total_executed_audits = rowtotal(total_executed*)
egen total_assigned_audits = rowtotal(total_assigned*)
egen total_null_evasion = rowtotal(null_evasion*)

** Generating shares of void audits 
***Revise this!!!!!!!!!!!
foreach met in Algorithm Inspectors Random {
	gen share_v_`met' = (null_evasion`met'/total_executed_audits)*100  if total_executed`met'!=0 // void audit rate
	gen share_exec_`met' = (total_executed`met'/total_executed_audits)*100 if total_executed`met'!=0 // void audit rate
}



*alternative void measure
egen share_v_algorandom =  rowtotal(share_v_Algorithm share_exec_Random), missing

tabstat share_v_Algorithm, by(selectionyear) stat(mean N)

*make the scatter plot 
*keep if sum_tags==1 & max_verif_n==2
count if tag_verificateur==1

* add algo + random
egen s_exec_algorandom = rowtotal(share_exec_Algorithm share_exec_Random)
keep verificateur1 selectionyear share_v_Algorithm share_v_algorandom s_exec_algorandom 
reshape wide share_v_Algorithm share_v_algorandom s_exec_algorandom, i(verificateur1) j(selectionyear)


	if `sample'==1  {
		local vars "share_v_algorandom2018 s_exec_algorandom2019"
		local t_1 "s_exec_algorandom2018"
		local var1 "share_v_algorandom2018"
		local var2 "s_exec_algorandom2019"
	}
	if `sample'==2  {
		local vars "share_v_algorandom2019 s_exec_algorandom2020"
		local t_1 "s_exec_algorandom2019"
		local var1 "share_v_algorandom2019"
		local var2 "s_exec_algorandom2020"
	}
	
	if `sample'==3  {
		egen s_avg_algorand_execution =rowmean(s_exec_algorandom2019 s_exec_algorandom2020)
		local vars "share_v_algorandom2018 s_avg_algorand_execution"
		local t_1 "s_exec_algorandom2018"
		local var1 "share_v_algorandom2018"
		local var2 "s_avg_algorand_execution"
 	}
	
cap label var share_v_algorandom2018 "Share of void evasion Algo + Rand cases 2018"
cap label var s_exec_algorandom2019 "Share of executed Algo + Rand cases 2019"
cap	label var share_v_algorandom2019 "Share of void evasion Algo + Rand cases 2019"
cap	label var s_exec_algorandom2020 "Share of executed Algo + Rand cases 2020"
cap	label var s_avg_algorand_execution "Share of executed Algo + Rand cases 2018"

count if  !missing(`var1', `var2') & `t_1'!=0
local samp = `r(N)' 


twoway (scatter `vars' if `t_1'!=0), legend(off) note("N = `samp'", pos(6)) 


graph export "$output\v_exec_`sample'.pdf", replace
restore
}


*** Generate some stats
*Number of inspectors with positve N of algo executed algo cases

foreach met in Algorithm Inspectors Random {
	gen has_executed_`met' = (total_executed`met'>0 & total_executed`met'!=.)
	replace share_v_`met' = . if has_executed_`met' == 0
	}




order verificateur1 selectionyear, first
reshape wide n, i(verificateur1 groupbureau selectionyear) j(method, string)

eststo clear
eststo vauds: estpost tab void_audit method if y2==1, 

* Now export: two columns side-by-side with your headers
esttab vauds using "$output\void_audit_stats",  replace booktabs cell(b(fmt(%3.0fc))) noobs  unstack nonumber ///
nomtitle collabels(none)  eqlabels(, lhs("Void Audit"))


***** Some other stats

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

**# Select general sample


*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

keep if x2==0 // Focus on desk audits 




*Count how many audits have valid duration information
gen has_initfinaldate = has_openingdate==1  | (has_dateconfirmation==1 ///
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


