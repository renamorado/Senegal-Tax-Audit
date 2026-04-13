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

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

**# Select general sample

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

***checks
**# checking on notification and confirmation
gen penalites_notification_dum = (penalites_notification>0) 
replace penalites_notification_dum = 0 if y2==1  & penalites_notification==.
gen droitssimples_notification_dum = (droitssimples_notification>0) 
replace droitssimples_notification_dum = 0 if y2==1  & droitssimples_notification==.


tab penalites_notification_dum droitssimples_notification_dum  if y2==1 & notification==1



gen penalite_droit =. 

	replace penalite_droit = 1 if (penalites_notification_dum==1 & droitssimples_notification_dum == 0)  & notification==1 // only penalites
	replace penalite_droit = 2 if penalites_notification_dum==0  & droitssimples_notification_dum == 1  & notification==1 // only droitsimples
	replace penalite_droit = 3 if penalites_notification_dum==1  & droitssimples_notification_dum == 1  & notification==1 // has both
	replace penalite_droit = 4 if penalites_notification_dum==0  & droitssimples_notification_dum == 0 & notification==1 // has neither
	replace penalite_droit = . if y2==0

tab penalite_droit 
label define pd 1 "has penalitÃ©s only" 2 "has droit simples only" 3 "has both" 4 "has neither"
label values penalite_droit pd

eststo desk_pd: estpost tab penalite_droit method if x2==0
eststo full_pd: estpost tab penalite_droit method if x2==1


esttab desk_pd full_pd using "$output\penalite_droit_check", booktabs replace /// 
nostar unstack  nonum nonote noobs mtitle("Desk audits" "Full audits") 

keep if x2==0 // Focus on desk audits 

gen null_evasion = (y4==0)
replace null_evasion=. if y2==0 



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
		*collapse (sum) total_assigned total_executed null_evasion `cond1'
		*collapse (sum) total_assigned total_executed null_evasion `cond`sample''
		*local sample = 1
		*collapse (sum) total_assigned total_executed null_evasion `cond1', by(method groupbureau verificateur1 selectionyear) 
		
		*Collapsing at the inspector - bureau - selectionyear level
		collapse (sum) total_assigned total_executed null_evasion `cond`sample'', ///
		by(method groupbureau verificateur1 selectionyear) 
		
		*reshaping to obtain the audit numbers (method as columns)
		reshape wide total_assigned total_executed null_evasion, ///
		i(verificateur1 groupbureau selectionyear) j(method, string)
		
		*encoding all missings to zero at this stage	
		mvencode _all, mv(0) override
		
		**# Creating the sample 
		*tagging inspectors
		egen tag_verificateur = tag(verificateur1)

		** Tagging inspectors that are observed for two or more consecutive years in the same bureau
		egen tag_verifbureau = tag(verificateur1 groupbureau)
		bys verificateur1 groupbureau: gen verif_bureau_consecutive = _n

		*check if verificateur didn't changed from office

		bys verificateur1: egen sum_tags = total(tag_verifbureau)
		tab sum_tags if tag_verificateur==1  // 92 out of 123  didn't changed from bureau

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
		*Total execution
		egen total_executed_audits = rowtotal(total_executed*)
		
		egen total_executedALG = rowtotal(total_executedAlgorithm total_executedRandom) // joining algo + random

		egen total_assigned_audits = rowtotal(total_assigned*)
		
		egen total_assignedALG = rowtotal(total_assignedAlgorithm total_assignedRandom) // joining algo + random

		egen total_null_evasion = rowtotal(null_evasion*)
		egen null_evasionALG = rowtotal(null_evasionAlgorithm null_evasionRandom)

		**# Generating shares of void audits 
		*total void 
		gen share_v_all= (total_null_evasion / total_executed_audits) * 100
		gen share_exec_all= (total_executed_audits / total_assigned_audits) * 100

		foreach met in ALG Algorithm Inspectors Random {
			*void audit rate - share wrt total execution by inspector
			gen share_v_`met'_all = (null_evasion`met'/total_executed_audits)*100  if total_executed`met'!=0
			
			* void audit rate - share within selection method
			gen share_v_`met' = (null_evasion`met'/total_executed`met')*100  // it will be undefined when 0
			
			* share of total executed x selection method cases with with respect to total assigned cases by inspector
			gen share_exec_`met'_all = (total_executed`met'/total_assigned_audits)*100 
			
			** share of total executed x selection method cases with with respect to total x method assigned cases by inspector
			gen share_exec_`met' = (total_executed`met'/total_assigned`met')*100 
		}

		* save as tempfile
		* append obs and create one dataset
		* do as many figures as you want?

		*make the scatter plot 

		count if tag_verificateur==1
		cap label var share_v_algorandom2018 "Share of void evasion Algo + Rand cases 2018"
		cap label var s_exec_algorandom2019 "Share of executed Algo + Rand cases 2019"
		cap	label var share_v_algorandom2019 "Share of void evasion Algo + Rand cases 2019"
		cap	label var s_exec_algorandom2020 "Share of executed Algo + Rand cases 2020"
		cap	label var s_avg_algorand_execution "Share of executed Algo + Rand cases 2018"
		* add algo + random
		keep verificateur1 selectionyear share_v_ALG_all share_v_ALG ///  
		share_exec_ALG share_exec_ALG_all share_v_all share_exec_all ///
		share_v_Inspectors_all share_v_Inspectors share_exec_Inspectors_all share_exec_Inspectors

		reshape wide share_v_ALG_all share_v_ALG ///  
		share_exec_ALG share_exec_ALG_all share_v_all share_exec_all share_v_Inspectors_all  ///
		share_v_Inspectors share_exec_Inspectors_all share_exec_Inspectors, i(verificateur1) j(selectionyear)



				
			if `sample'==1  {
				local t "2018"
				local t1 "2019"
			}
			
				
			
			if `sample'==2  {
				local t "2019"
				local t1 "2020"
			}
			
			if `sample'==3  {
				local t "2018"
				local t1 "avg"
				
				foreach share in share_exec_all share_exec_ALG share_exec_Inspectors share_v_all share_v_ALG share_v_Inspectors{
					egen `share'avg =rowmean(`share'2019 `share'2020)
				}
				
				}
	***cap labelling some vars
		*-----------------
		* 2018
		*-----------------
		cap label var share_v_ALG_all2018            "Share of void cases, Algorithm (all, 2018)"
		cap label var share_v_ALG2018                "Share of void cases, Algorithm (2018)"
		cap label var share_exec_ALG2018             "Share of executed cases, Algorithm (2018)"
		cap label var share_exec_ALG_all2018         "Share of executed cases, Algorithm (all, 2018)"
		cap label var share_v_all2018                "Share of void cases, all (2018)"
		cap label var share_exec_all2018             "Share of executed cases, all (2018)"
		cap label var share_v_Inspectors_all2018     "Share of void cases, Inspectors (all, 2018)"
		cap label var share_v_Inspectors2018         "Share of void cases, Inspectors (2018)"
		cap label var share_exec_Inspectors_all2018  "Share of executed cases, Inspectors (all, 2018)"
		cap label var share_exec_Inspectors2018      "Share of executed cases, Inspectors (2018)"

		*-----------------
		* 2019
		*-----------------
		cap label var share_v_ALG_all2019            "Share of void cases, Algorithm (all, 2019)"
		cap label var share_v_ALG2019                "Share of void cases, Algorithm (2019)"
		cap label var share_exec_ALG2019             "Share of executed cases, Algorithm (2019)"
		cap label var share_exec_ALG_all2019         "Share of executed cases, Algorithm (all, 2019)"
		cap label var share_v_all2019                "Share of void cases, all (2019)"
		cap label var share_exec_all2019             "Share of executed cases, all (2019)"
		cap label var share_v_Inspectors_all2019     "Share of void cases, Inspectors (all, 2019)"
		cap label var share_v_Inspectors2019         "Share of void cases, Inspectors (2019)"
		cap label var share_exec_Inspectors_all2019  "Share of executed cases, Inspectors (all, 2019)"
		cap label var share_exec_Inspectors2019      "Share of executed cases, Inspectors (2019)"
		
		*-----------------
		* 2020
		*-----------------
		cap label var share_v_ALG_all2020            "Share of void cases, Algorithm (all, 2020)"
		cap label var share_v_ALG2020                "Share of void cases, Algorithm (2020)"
		cap label var share_exec_ALG2020             "Share of executed cases, Algorithm (2020)"
		cap label var share_exec_ALG_all2020         "Share of executed cases, Algorithm (all, 2020)"
		cap label var share_v_all2020                "Share of void cases, all (2020)"
		cap label var share_exec_all2020             "Share of executed cases, all (2020)"
		cap label var share_v_Inspectors_all2020     "Share of void cases, Inspectors (all, 2020)"
		cap label var share_v_Inspectors2020         "Share of void cases, Inspectors (2020)"
		cap label var share_exec_Inspectors_all2020  "Share of executed cases, Inspectors (all, 2020)"
		cap label var share_exec_Inspectors2020      "Share of executed cases, Inspectors (2020)"

		*-----------------
		*(adjust varnames if needed)
		*-----------------
		cap label var share_v_ALG_allavg             "Share of void cases, Algorithm (all,2019-2020)"
		cap label var share_v_ALGavg                 "Share of void cases, Algorithm (2019-2020)"
		cap label var share_exec_ALGavg              "Share of executed cases, Algorithm (2019-2020)"
		cap label var share_exec_ALG_allavg          "Share of executed cases, Algorithm (all,2019-2020)"
		cap label var share_v_allavg                 "Share of void cases, all (2019-2020)"
		cap label var share_exec_allavg              "Share of executed cases, all (2019-2020)"
		cap label var share_v_Inspectors_allavg      "Share of void cases, Inspectors (all,2019-2020)"
		cap label var share_v_Inspectorsavg          "Share of void cases, Inspectors (2019-2020)"
		cap label var share_exec_Inspectors_allavg   "Share of executed cases, Inspectors (all,2019-2020)"
		cap label var share_exec_Inspectorsavg       "Share of executed cases, Inspectors (2019-2020)"
			
			
			
		**# Generating graphs 

		foreach share in share_exec_all share_exec_ALG share_exec_Inspectors ///
						 share_v_all   share_v_ALG   share_v_Inspectors {

						 
		
			** Only do the plot for the "v" shares vrs execution rates in t+1
		*All void cases
			if "`share'"=="share_v_all" {
			
				count if !missing(`share'`t', share_exec_all`t1', share_exec_all`t') & share_exec_all`t' != 0
				local samp = r(N)

				*scatter plot
				twoway (scatter share_exec_all`t1' `share'`t'  if share_exec_all`t' != 0 & share_exec_all`t' != .), ///
					legend(off) note("N = `samp'", pos(6)) xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100)
					graph export "$output\scatter_`share'_`t'_`t1'.pdf", replace
			}
			
		*Void algo cases
			else if "`share'"=="share_v_ALG" {

				count if !missing(share_exec_ALG`t1', `share'`t', share_exec_ALG`t') & share_exec_ALG`t' != 0
				local samp = r(N)

				*scatter plot
				twoway (scatter share_exec_ALG`t1'  `share'`t' if share_exec_ALG`t' != 0 & share_exec_ALG`t'!=.), ///
					legend(off) note("N = `samp'", pos(6))  xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100)
					graph export "$output\scatter_`share'_`t'_`t1'.pdf", replace
			
			}
			
		*Void inspector cases
			else if "`share'"=="share_v_Inspectors" {
				count if !missing(`share'`t', share_exec_Inspectors`t1', share_exec_Inspectors`t') & share_exec_Inspectors`t' != 0
				local samp = r(N)

				*scatter plot
				twoway (scatter share_exec_Inspectors`t1' `share'`t'  if share_exec_Inspectors`t' != 0 & share_exec_Inspectors`t'!=.), ///
					legend(off) note("N = `samp'", pos(6))  xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100)
					graph export "$output\scatter_`share'_`t'_`t1'.pdf", replace
			}
			
		
		*Execution rates t vrs t+1
			else {
				count if !missing(`share'`t', `share'`t1') 
				local samp = r(N)

				*scatter plot
				twoway (scatter `share'`t1' `share'`t' ), ///
					legend(off) note("N = `samp'", pos(6))  xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100)
					graph export "$output\scatter_`share'_`t'_`t1'.pdf", replace
				}
			}
	restore
}