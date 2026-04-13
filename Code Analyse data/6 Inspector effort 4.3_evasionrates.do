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

**# Creating null evasion variable (void audit rate)
gen null_evasion = (y4==0)
replace null_evasion=. if y2==0 

****
**# Creating evasion rate (Evasion/sales)
****
*1. estimate meanturnover 
cap drop meanturnover
egen meanturnover = rowmean(turnover*) 

*2. compute shares
*explain evasion value
	gen evasionrate = (evasionvalue)/(meanturnover+evasionvalue) 
*	replace evasionrate = 0 if notification == 0 // discuss this 
	replace evasionrate = . if y2 != 1

gen hasevasionrate=(evasionrate!=. & evasionrate>=0 )

tab y2 hasevasionrate if evasionrate!=0

tab null_evasion hasevasionrate // there's 236 that have evasionrate = 0


**# graph evasionrate by selection year and N 
forval y = 2018/2020 {
    count if selectionyear == `y' & hasevasionrate == 1
    local n`y' = r(N)
}

                       

tab hasevasionrate selectionyear

twoway (kdensity evasionrate if selectionyear==2018) || ///
	(kdensity evasionrate if selectionyear==2019) || /// 
	(kdensity evasionrate if selectionyear==2020), ytitle("K density") xtitle("Evasion Rate") legend(order(1 2 3 4) ///
	label(1 "2018 [N =`n2018']") ///
	label(2 "2019 [N = `n2019']") ///
    label(3 "2020 [N = `n2020']") ///
    pos(6) ring(1) cols(3))
graph export "$output/kdensity_evasionrate_syear.pdf", replace

	
**# 3. tag cases with below median and bottom quartile evasionrate within list 
egen taglist= tag(verificateur1 selectionyear) 

*egen group= group(verificateur1 selectionyear)
count if taglist  ==1 // 272 list



*ssc install egenmore, replace
*generate variable grouping algo + rand cases 
gen alg_rand = (method=="Algorithm" | method=="Random")

*generate variable taging cluster + year + method (alg+rand or inspectors)
egen inspectorclusteryearmethod = group(inspectorclusteryear alg_rand)

egen quartiles_er= xtile(evasionrate), by(inspectorclusteryearmethod)  nq(4)   // or nquantiles(4)

*below median 
gen belowmedian_er = (quartiles_er==1 | quartiles_er==2)
replace belowmedian_er =. if y2==0

gen bottomquartile_er = (quartiles_er==1)
replace bottomquartile_er = . if y2==0

tab null_evasion belowmedian_er 
tab bottomquartile_er




***************
**# Analysis
***************

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


**# loop over samples based on periods 
forval sample = 1/3 {
	preserve	
		*collapse (sum) total_assigned total_executed null_evasion `cond1'
		*collapse (sum) total_assigned total_executed null_evasion `cond`sample''
		*local sample = 3
		collapse (sum) total_assigned total_executed null_evasion belowmedian_er bottomquartile_er `cond`sample'' , by(method groupbureau verificateur1 selectionyear) 
		
		
		*Collapsing at the inspector - bureau - selectionyear level
		*collapse (sum) total_assigned total_executed null_evasion `cond`sample'', ///
		by(method groupbureau verificateur1 selectionyear) 
		
		*reshaping to obtain the audit numbers (method as columns)
		reshape wide total_assigned total_executed null_evasion belowmedian_er bottomquartile_er, ///
		i(verificateur1 groupbureau selectionyear) j(method, string)
		
		*encoding all missings to zero at this stage	
		mvencode _all, mv(0) override
		
		***********
		**# Creating the sample 
		************
		
		*tagging inspectors that changed from bureau
		egen tag_verificateur = tag(verificateur1)
		

		** Tagging inspectors that are observed in the same bureau 
		egen tag_verifbureau = tag(verificateur1 groupbureau)
		bys verificateur1 groupbureau: gen verif_bureau_consecutive = _n

		*check if verificateur didn't changed from office

		bys verificateur1: egen sum_tags = total(tag_verifbureau) // 
		tab sum_tags if tag_verificateur==1  // 95 out of 123  didn't changed from bureau

		gen unchanged_bureau = (sum_tags==1)
		tab unchanged_bureau if tag_verificateur==1
		
		**check if verificateur is observable for two consecutive periods
	* Ensure proper sort
	sort verificateur1 selectionyear groupbureau

	* Mark first observation of each inspector-year
	by verificateur1 selectionyear: gen first_in_year = _n == 1

	* Cumulative sum of "first_in_year" within inspector = year sequence
	by verificateur1: gen year_seq = sum(first_in_year)
	
	*tag inspectors by the max periods they wer observed
	bys verificateur1: egen max_period = max(year_seq)
	
	*Only 20 inspectors were observed in the same 
	tab max_period if tag_verificateur==1 // check this, does it make sense?

	
		
		gen insp_consec = (max_period>1)

		gen final_sample = insp_consec==1  // & unchanged_bureau==1 [new analysis now will distinguish between unchanged and changed bureau]

		
	*Summarry stats of inspector sample 
		* Clear any previous stored estimates
	
			* 1) unchanged == 1 // Inspector remained in the same bureau
			estpost tabstat tag_verificateur insp_consec ///
				if tag_verificateur == 1 & unchanged_bureau == 1, ///
				stat(sum) columns(statistics)
			eststo insp_stats_`sample'_u1

			* 2) unchanged == 0 // Inspector changed bureau
			estpost tabstat tag_verificateur insp_consec ///
				if tag_verificateur == 1 & unchanged_bureau == 0, ///
				stat(sum) columns(statistics)
			eststo insp_stats_`sample'_u0

			* 3) Total 
			estpost tabstat tag_verificateur insp_consec ///
				if  tag_verificateur == 1, ///
				stat(sum) columns(statistics)
			eststo insp_stats_`sample'_total
		
		
* Keep elegible inspectors (observable in t AND t+1)
		keep if final_sample==1 // sample eligible inspectors 

		
* collapse at the inspector year level		
	collapse (sum) total_assigned* total_executed* null_evasion* bottomquartile_er* belowmedian_er*, by(verificateur1 selectionyear unchanged)
	egen tag_verificateur = tag(verificateur1)
		** Generating total
		*Total execution
		egen total_executed_audits = rowtotal(total_executed*)
		
		egen total_executedALG = rowtotal(total_executedAlgorithm total_executedRandom) // joining algo + random

		egen total_assigned_audits = rowtotal(total_assigned*)
		
		egen total_assignedALG = rowtotal(total_assignedAlgorithm total_assignedRandom) // joining algo + random

		egen total_null_evasion = rowtotal(null_evasion*)
		egen null_evasionALG = rowtotal(null_evasionAlgorithm null_evasionRandom)
		egen total_belowmedian_er = rowtotal(belowmedian_er*)
		egen belowmedian_erALG = rowtotal(belowmedian_erAlgorithm belowmedian_erRandom)
		egen total_bottomquartile_er = rowtotal(bottomquartile_er*)
		egen bottomquartile_erALG = rowtotal(bottomquartile_erAlgorithm bottomquartile_erRandom)

		**# Generating shares 
		*total void 
		gen share_v_all= (total_null_evasion / total_executed_audits) * 100

		*total below median evasion rate
		gen share_med_er_all= (total_belowmedian_er/ total_executed_audits) * 100
		*total bottom quartile audit cases 
		gen share_botq_er_all= (total_bottomquartile_er/ total_executed_audits) * 100
		*total execution
		gen share_exec_all= (total_executed_audits / total_assigned_audits) * 100

		
		
*generating shares among methods
		foreach met in ALG Algorithm Inspectors Random {
			*void audit rate - share wrt total execution by inspector
			gen share_v_`met'_all = (null_evasion`met'/total_executed_audits)*100  if total_executed`met'!=0
			
			* void audit rate - share within selection method
			gen share_v_`met' = (null_evasion`met'/total_executed`met')*100  // it will be undefined when 0
			
			*share of audits below median evasion rate
			gen share_med_er_`met' = (belowmedian_er`met'/total_executed`met')*100  // it will be undefined when 0
			gen share_botq_er_`met' = (bottomquartile_er`met'/total_executed`met')*100  // it will be undefined when 0
			
			* share of total executed x selection method cases with with respect to total assigned cases by inspector
			gen share_exec_`met'_all = (total_executed`met'/total_assigned_audits)*100 
			
			** share of total executed x selection method cases with with respect to total x method assigned cases by inspector
			gen share_exec_`met' = (total_executed`met'/total_assigned`met')*100 
		}



		*make the scatter plot 

		keep verificateur1 selectionyear  unchanged_bureau share_v_ALG_all share_v_ALG ///  
		share_med_er_ALG share_botq_er_ALG share_exec_ALG share_exec_ALG_all ///
		share_v_all share_exec_all share_med_er_all share_botq_er_all ///
		share_v_Inspectors_all share_v_Inspectors share_med_er_Inspectors ///
		share_botq_er_Inspectors share_exec_Inspectors_all share_exec_Inspectors

		reshape wide share_v_ALG_all share_v_ALG ///  
		share_med_er_ALG share_botq_er_ALG share_exec_ALG share_exec_ALG_all ///
		share_v_all share_exec_all share_med_er_all share_botq_er_all ///
		share_v_Inspectors_all share_v_Inspectors share_med_er_Inspectors ///
		share_botq_er_Inspectors share_exec_Inspectors_all share_exec_Inspectors, i(verificateur1 unchanged_bureau) j(selectionyear)


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
				
				foreach share in share_exec_all share_exec_ALG ///
				share_exec_Inspectors share_v_all share_v_ALG ///
				share_v_Inspectors share_med_er_all ///
				share_med_er_ALG share_med_er_Inspectors ///
				share_botq_er_all share_botq_er_ALG share_botq_er_Inspectors {
						egen `share'avg =rowmean(`share'2019 `share'2020)
					}
				
				}
***cap labelling some vars
	*========================================================
	* 2018
	*========================================================
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

	cap label var share_med_er_ALG_all2018         "Share of below-median evasion rate cases, Algorithm (all, 2018)"
	cap label var share_med_er_ALG2018             "Share of below-median evasion rate cases, Algorithm (2018)"
	cap label var share_med_er_all2018             "Share of below-median evasion rate cases, all (2018)"
	cap label var share_med_er_Inspectors_all2018  "Share of below-median evasion rate cases, Inspectors (all, 2018)"
	cap label var share_med_er_Inspectors2018      "Share of below-median evasion rate cases, Inspectors (2018)"

	cap label var share_botq_er_ALG_all2018        "Share of bot-quartile evasion rate cases, Algorithm (all, 2018)"
	cap label var share_botq_er_ALG2018            "Share of bot-quartile evasion rate cases, Algorithm (2018)"
	cap label var share_botq_er_all2018            "Share of bot-quartile evasion rate cases, all (2018)"
	cap label var share_botq_er_Inspectors_all2018 "Share of bot-quartile evasion rate cases, Inspectors (all, 2018)"
	cap label var share_botq_er_Inspectors2018     "Share of bot-quartile evasion rate cases, Inspectors (2018)"


	*========================================================
	* 2019
	*========================================================
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

	cap label var share_med_er_ALG_all2019         "Share of below-median evasion rate cases, Algorithm (all, 2019)"
	cap label var share_med_er_ALG2019             "Share of below-median evasion rate cases, Algorithm (2019)"
	cap label var share_med_er_all2019             "Share of below-median evasion rate cases, all (2019)"
	cap label var share_med_er_Inspectors_all2019  "Share of below-median evasion rate cases, Inspectors (all, 2019)"
	cap label var share_med_er_Inspectors2019      "Share of below-median evasion rate cases, Inspectors (2019)"

	cap label var share_botq_er_ALG_all2019        "Share of bot-quartile evasion rate cases, Algorithm (all, 2019)"
	cap label var share_botq_er_ALG2019            "Share of bot-quartile evasion rate cases, Algorithm (2019)"
	cap label var share_botq_er_all2019            "Share of bot-quartile evasion rate cases, all (2019)"
	cap label var share_botq_er_Inspectors_all2019 "Share of bot-quartile evasion rate cases, Inspectors (all, 2019)"
	cap label var share_botq_er_Inspectors2019     "Share of bot-quartile evasion rate cases, Inspectors (2019)"


	*========================================================
	* 2020
	*========================================================
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

	cap label var share_med_er_ALG_all2020         "Share of below-median evasion rate cases, Algorithm (all, 2020)"
	cap label var share_med_er_ALG2020             "Share of below-median evasion rate cases, Algorithm (2020)"
	cap label var share_med_er_all2020             "Share of below-median evasion rate cases, all (2020)"
	cap label var share_med_er_Inspectors_all2020  "Share of below-median evasion rate cases, Inspectors (all, 2020)"
	cap label var share_med_er_Inspectors2020      "Share of below-median evasion rate cases, Inspectors (2020)"

	cap label var share_botq_er_ALG_all2020        "Share of bot-quartile evasion rate cases, Algorithm (all, 2020)"
	cap label var share_botq_er_ALG2020            "Share of bot-quartile evasion rate cases, Algorithm (2020)"
	cap label var share_botq_er_all2020            "Share of bot-quartile evasion rate cases, all (2020)"
	cap label var share_botq_er_Inspectors_all2020 "Share of bot-quartile evasion rate cases, Inspectors (all, 2020)"
	cap label var share_botq_er_Inspectors2020     "Share of bot-quartile evasion rate cases, Inspectors (2020)"


	*========================================================
	* AVG (adjust varnames if needed)
	*========================================================
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

	cap label var share_med_er_ALG_allavg          "Share of below-median evasion rate cases, Algorithm (all,2019-2020)"
	cap label var share_med_er_ALGavg              "Share of below-median evasion rate cases, Algorithm (2019-2020)"
	cap label var share_med_er_allavg              "Share of below-median evasion rate cases, all (2019-2020)"
	cap label var share_med_er_Inspectors_allavg   "Share of below-median evasion rate cases, Inspectors (all,2019-2020)"
	cap label var share_med_er_Inspectorsavg       "Share of below-median evasion rate cases, Inspectors (2019-2020)"

	cap label var share_botq_er_ALG_allavg         "Share of bot-quartile evasion rate cases, Algorithm (all,2019-2020)"
	cap label var share_botq_er_ALGavg             "Share of bot-quartile evasion rate cases, Algorithm (2019-2020)"
	cap label var share_botq_er_allavg             "Share of bot-quartile evasion rate cases, all (2019-2020)"
	cap label var share_botq_er_Inspectors_allavg  "Share of bot-quartile evasion rate cases, Inspectors (all,2019-2020)"
	cap label var share_botq_er_Inspectorsavg      "Share of bot-quartile evasion rate cases, Inspectors (2019-2020)"






		*------------------------------------------------------------
        * TABLE: mean share execution / voids in t and t+1
        *   - Create generic names for t and t+1 so rows align across samples
        *------------------------------------------------------------

        * --- Year t: copy year-specific variables into generic names ---
        gen share_exec_all_t        = share_exec_all`t'
        gen share_exec_ALG_t        = share_exec_ALG`t'
        gen share_exec_Inspectors_t = share_exec_Inspectors`t'
        
		gen share_v_all_t           = share_v_all`t'
        gen share_v_ALG_t           = share_v_ALG`t'
        gen share_v_Inspectors_t    = share_v_Inspectors`t'
		
		gen share_med_er_all_t           = share_med_er_all`t'
        gen share_med_er_ALG_t           = share_med_er_ALG`t'
        gen share_med_er_Inspectors_t    = share_med_er_Inspectors`t'
		
		gen share_botq_er_all_t           = share_botq_er_all`t'
        gen share_botq_er_ALG_t           = share_botq_er_ALG`t'
        gen share_botq_er_Inspectors_t    = share_botq_er_Inspectors`t'
		

        * --- Year t+1 ---
        gen share_exec_all_t1        = share_exec_all`t1'
        gen share_exec_ALG_t1        = share_exec_ALG`t1'
        gen share_exec_Inspectors_t1 = share_exec_Inspectors`t1'
		
        gen share_v_all_t1           = share_v_all`t1'
        gen share_v_ALG_t1           = share_v_ALG`t1'
        gen share_v_Inspectors_t1    = share_v_Inspectors`t1'

        gen share_med_er_all_t1           = share_med_er_all`t1'
        gen share_med_er_ALG_t1           = share_med_er_ALG`t1'
        gen share_med_er_Inspectors_t1    = share_med_er_Inspectors`t1'
		
		gen share_botq_er_all_t1           = share_botq_er_all`t1'
        gen share_botq_er_ALG_t1           = share_botq_er_ALG`t1'
        gen share_botq_er_Inspectors_t1    = share_botq_er_Inspectors`t1'

        *------------------------------------------------------------
        * estpost summarize: one set of estimates per group
        *   (same bureau / changed / total), each with t AND t+1 rows
        *------------------------------------------------------------

        * Same bureau (unchanged_bureau == 1)
        eststo insp_share_`sample'_u1: estpost summarize ///
            share_exec_all_t share_exec_ALG_t share_exec_Inspectors_t ///
            share_v_all_t     share_v_ALG_t     share_v_Inspectors_t ///
			share_med_er_all_t share_med_er_ALG_t share_med_er_Inspectors_t  ///
			share_botq_er_all_t share_botq_er_ALG_t share_botq_er_Inspectors_t ///
            share_exec_all_t1 share_exec_ALG_t1 share_exec_Inspectors_t1 ///
            share_v_all_t1     share_v_ALG_t1     share_v_Inspectors_t1 ///
			share_med_er_all_t1 share_med_er_ALG_t1 share_med_er_Inspectors_t1  ///
			share_botq_er_all_t1 share_botq_er_ALG_t1 share_botq_er_Inspectors_t1 ///
            if unchanged_bureau == 1

        * Changed bureau (unchanged_bureau == 0)
        eststo insp_share_`sample'_u0: estpost summarize ///
            share_exec_all_t share_exec_ALG_t share_exec_Inspectors_t ///
            share_v_all_t     share_v_ALG_t     share_v_Inspectors_t ///
			share_med_er_all_t share_med_er_ALG_t share_med_er_Inspectors_t  ///
			share_botq_er_all_t share_botq_er_ALG_t share_botq_er_Inspectors_t ///
            share_exec_all_t1 share_exec_ALG_t1 share_exec_Inspectors_t1 ///
            share_v_all_t1     share_v_ALG_t1     share_v_Inspectors_t1 ///
			share_med_er_all_t1 share_med_er_ALG_t1 share_med_er_Inspectors_t1  ///
			share_botq_er_all_t1 share_botq_er_ALG_t1 share_botq_er_Inspectors_t1 ///
            if unchanged_bureau == 0

        * Total (all inspectors)
        eststo insp_share_`sample'_tot: estpost summarize ///
            share_exec_all_t share_exec_ALG_t share_exec_Inspectors_t ///
            share_v_all_t     share_v_ALG_t     share_v_Inspectors_t ///
			share_med_er_all_t share_med_er_ALG_t share_med_er_Inspectors_t  ///
			share_botq_er_all_t share_botq_er_ALG_t share_botq_er_Inspectors_t ///
            share_exec_all_t1 share_exec_ALG_t1 share_exec_Inspectors_t1 ///
            share_v_all_t1     share_v_ALG_t1     share_v_Inspectors_t1 ///
			share_med_er_all_t1 share_med_er_ALG_t1 share_med_er_Inspectors_t1  ///
			share_botq_er_all_t1 share_botq_er_ALG_t1 share_botq_er_Inspectors_t1 ///

	
		*------------------------------------------------------------
        * Indicators for descriptive table: t and t+1
        *   (names do NOT contain the actual year, only _t / _t1)
        *------------------------------------------------------------

        * --- Year t ---
        gen has_executed_all_t = (share_exec_all`t' > 0 & share_exec_all`t' != .)
        gen has_void_all_t     = (share_v_all`t' > 0 & share_v_all`t' != .)
		gen has_med_er_all_t   = (share_med_er_all`t' > 0 & share_med_er_all`t' != .)
		gen has_botq_er_all_t   = (share_botq_er_all`t' > 0 & share_botq_er_all`t' != .)

		
     foreach met in ALG Inspectors {
	 	
        gen has_executed_`met'_t = (share_exec_`met'`t' > 0 & share_exec_`met'`t' != .)
        gen has_void_`met'_t     = (share_v_`met'`t'    > 0 & share_v_`met'`t'    != .)
		gen has_med_er_`met'_t   = (share_med_er_`met'`t' > 0 & share_med_er_`met'`t' != .)
		gen has_botq_er_`met'_t  = (share_botq_er_`met'`t' > 0 & share_botq_er_`met'`t' != .)
			
        }

        * --- Year t+1 ---
        gen has_executed_all_t1 = (share_exec_all`t1' > 0 & share_exec_all`t1' != .)
        gen has_void_all_t1     = (share_v_all`t1'    > 0 & share_v_all`t1'    != .)
		gen has_med_er_all_t1   = (share_med_er_all`t1' > 0 & share_med_er_all`t1' != .)
		gen has_botq_er_all_t1   = (share_botq_er_all`t1' > 0 & share_botq_er_all`t1' != .)
		

     foreach met in ALG Inspectors {
         gen has_executed_`met'_t1 = (share_exec_`met'`t1' > 0 & share_exec_`met'`t1' != .)
         gen has_void_`met'_t1     = (share_v_`met'`t1'    > 0 & share_v_`met'`t1'    != .)
		 gen has_med_er_`met'_t1   = (share_med_er_`met'`t1' > 0 & share_med_er_`met'`t1' != .)
		 gen has_botq_er_`met'_t1  = (share_botq_er_`met'`t1' > 0 & share_botq_er_`met'`t1' != .)
        }

        *------------------------------------------------------------
        * estpost tabstat: ONE set of estimates per group, containing
        * BOTH t and t+1 variables as rows
        *------------------------------------------------------------

        * Same bureau (unchanged == 1)
        eststo insp_has_`sample'_u1: estpost tabstat ///
            has_executed_all_t has_executed_ALG_t has_executed_Inspectors_t ///
            has_void_all_t     has_void_ALG_t     has_void_Inspectors_t ///
			has_med_er_all_t 	has_med_er_ALG_t has_med_er_Inspectors_t ///
			has_botq_er_all_t 	has_botq_er_ALG_t has_botq_er_Inspectors_t ///
            has_executed_all_t1 has_executed_ALG_t1 has_executed_Inspectors_t1 ///
            has_void_all_t1     has_void_ALG_t1     has_void_Inspectors_t1 ///
			has_med_er_all_t1 	has_med_er_ALG_t1 has_med_er_Inspectors_t1 ///
			has_botq_er_all_t1 	has_botq_er_ALG_t1 has_botq_er_Inspectors_t1 ///
            if unchanged==1, stat(sum) columns(statistics)

        * Changed bureau (unchanged == 0)
        eststo insp_has_`sample'_u0: estpost tabstat ///
            has_executed_all_t has_executed_ALG_t has_executed_Inspectors_t ///
            has_void_all_t     has_void_ALG_t     has_void_Inspectors_t ///
			has_med_er_all_t 	has_med_er_ALG_t has_med_er_Inspectors_t ///
			has_botq_er_all_t 	has_botq_er_ALG_t has_botq_er_Inspectors_t ///
            has_executed_all_t1 has_executed_ALG_t1 has_executed_Inspectors_t1 ///
            has_void_all_t1     has_void_ALG_t1     has_void_Inspectors_t1 ///
			has_med_er_all_t1 	has_med_er_ALG_t1 has_med_er_Inspectors_t1 ///
			has_botq_er_all_t1 	has_botq_er_ALG_t1 has_botq_er_Inspectors_t1 ///
            if unchanged==0, stat(sum) columns(statistics)

        * Total (all inspectors)
        eststo insp_has_`sample'_tot: estpost tabstat ///
            has_executed_all_t has_executed_ALG_t has_executed_Inspectors_t ///
            has_void_all_t     has_void_ALG_t     has_void_Inspectors_t ///
			has_med_er_all_t 	has_med_er_ALG_t has_med_er_Inspectors_t ///
			has_botq_er_all_t 	has_botq_er_ALG_t has_botq_er_Inspectors_t ///
            has_executed_all_t1 has_executed_ALG_t1 has_executed_Inspectors_t1 ///
            has_void_all_t1     has_void_ALG_t1     has_void_Inspectors_t1 ///
			has_med_er_all_t1 	has_med_er_ALG_t1 has_med_er_Inspectors_t1 ///
			has_botq_er_all_t1 	has_botq_er_ALG_t1 has_botq_er_Inspectors_t1, ///
            stat(sum) columns(statistics)
		**# Generating graphs 

foreach share in share_exec_all share_exec_ALG share_exec_Inspectors ///
                 share_v_all   share_v_ALG   share_v_Inspectors ///
				 share_med_er_all share_med_er_ALG share_med_er_Inspectors ///
				 share_botq_er_all share_botq_er_ALG share_botq_er_Inspectors {

* ==========================================================
* ALL CASES (1â€“10) with SE + sign + lfitci band
* ==========================================================

* x-variable always uses the share at time t
local xvar "`share'`t'"

* Defaults
local y_t   ""
local y_t1  ""
local xtit  ""
local ytit  ""

* -----------------------------
* Map each case to y-variables + titles
* -----------------------------
if "`share'" == "share_v_all" {
    local y_t  "share_exec_all`t'"
    local y_t1 "share_exec_all`t1'"
    local xtit "Void rate, all audits, year t"
    local ytit "Execution rate, all audits, year t+1"
}
else if "`share'" == "share_v_ALG" {
    local y_t  "share_exec_ALG`t'"
    local y_t1 "share_exec_ALG`t1'"
    local xtit "Void rate, algo audits, year t"
    local ytit "Execution rate, algo audits, year t+1"
}
else if "`share'" == "share_v_Inspectors" {
    local y_t  "share_exec_Inspectors`t'"
    local y_t1 "share_exec_Inspectors`t1'"
    local xtit "Void rate, inspector audits, year t"
    local ytit "Execution rate, inspector audits, year t+1"
}
else if "`share'" == "share_med_er_all" {
    local y_t  "share_exec_all`t'"
    local y_t1 "share_exec_all`t1'"
    local xtit "% below median evasion rate - all audits, year t"
    local ytit "Execution rate - all audits, year t+1"
}
else if "`share'" == "share_med_er_ALG" {
    local y_t  "share_exec_ALG`t'"
    local y_t1 "share_exec_ALG`t1'"
    local xtit "% below median evasion rate - Algo audits, year t"
    local ytit "Execution rate - all audits, year t+1"   // keeping your original text
}
else if "`share'" == "share_med_er_Inspectors" {
    local y_t  "share_exec_Inspectors`t'"
    local y_t1 "share_exec_Inspectors`t1'"
    local xtit "% below median evasion rate - Inspector audits, year t"
    local ytit "Execution rate - all audits, year t+1"
}
else if "`share'" == "share_botq_er_all" {
    local y_t  "share_exec_all`t'"
    local y_t1 "share_exec_all`t1'"
    local xtit "% bottom quartile evasion rate cases- all audits, year t"
    local ytit "Execution rate - all audits, year t+1"
}
else if "`share'" == "share_botq_er_ALG" {
    local y_t  "share_exec_ALG`t'"
    local y_t1 "share_exec_ALG`t1'"
    local xtit "% bottom quartile evasion rate cases - Algo audits, year t"
    local ytit "Execution rate - all audits, year t+1"
}
else if "`share'" == "share_botq_er_Inspectors" {
    local y_t  "share_exec_Inspectors`t'"
    local y_t1 "share_exec_Inspectors`t1'"
    local xtit "% bottom quartile evasion rate cases - Inspector audits, year t"
    local ytit "Execution rate - all audits, year t+1"
}
else {
    * Case 10: same measure both axes (t vs t+1)
    local y_t  "`share'`t'"
    local y_t1 "`share'`t1'"
    local xtit "Share in year t"
    local ytit "Share in year t+1"
}

* Common sample condition:
* - not missing x, y_t, y_t1
* - baseline (y_t) not zero (matches your original logic)
local cond "!missing(`xvar', `y_t', `y_t1') & `y_t' != 0"

* Sample size by unchanged_bureau
forvalues b = 0/1 {
    count if `cond' & unchanged_bureau == `b'
    local samp_`b' = r(N)
}

* -----------------------------
* Regression + equation text (group 1)
* -----------------------------
quietly reg `y_t1' `xvar' if `cond' & unchanged_bureau == 1
local b0_1    : display %5.2f _b[_cons]
local b1abs_1 : display %5.3f abs(_b[`xvar'])
local se1_1   : display %5.3f _se[`xvar']
local sign1   = cond(_b[`xvar']>=0, "+", "-")
local eq1     "linear fit: y = `b0_1' `sign1' `b1abs_1' x (SE=`se1_1')"

* -----------------------------
* Regression + equation text (group 0)
* -----------------------------
quietly reg `y_t1' `xvar' if `cond' & unchanged_bureau == 0
local b0_0    : display %5.2f _b[_cons]
local b1abs_0 : display %5.3f abs(_b[`xvar'])
local se1_0   : display %5.3f _se[`xvar']
local sign0   = cond(_b[`xvar']>=0, "+", "-")
local eq0     "linear fit: y = `b0_0' `sign0' `b1abs_0' x (SE=`se1_0')"

* -----------------------------
* Plot: scatter + CI band + fit line (legend clean)
* -----------------------------
twoway ///
    (scatter `y_t1' `xvar' if `cond' & unchanged_bureau==1, ///
        mcolor(dknavy) msymbol(triangle)) ///
    (lfit    `y_t1' `xvar' if `cond' & unchanged_bureau==1, ///
        lcolor(dknavy) lpattern(solid) lwidth(medthick)) ///
    (scatter `y_t1' `xvar' if `cond' & unchanged_bureau==0, ///
        mcolor(eltblue) msymbol(circle)) ///
    (lfit    `y_t1' `xvar' if `cond' & unchanged_bureau==0, ///
        lcolor(eltblue) lpattern(dash) lwidth(medthick)), ///
    legend( ///
        order(1 2 3 4) ///
        label(1 "Remained tax office [N = `samp_1']") ///
		label(2 "`eq1'") ///
        label(3 "Changed tax office [N = `samp_0']") ///
		label(4 "`eq0'")  ///
        pos(6) ring(1) cols(2) size(small) ///
    ) ///
    xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100) ///
    xtitle("`xtit'") ///
    ytitle("`ytit'")

graph export "$output/scatter_`share'_`t'_`t1'.pdf", replace

				 }
				 restore
}
*********
**# Some tables
*********

*Table: Inspector sample size
esttab insp_stats_1_u1 insp_stats_1_u0 insp_stats_1_total ///
       insp_stats_2_u1 insp_stats_2_u0 insp_stats_2_total ///
       insp_stats_3_u1 insp_stats_3_u0 insp_stats_3_total ///
       using "$output\inspector_sample_stats.tex", replace ///
    main(sum) noobs nonote ///
    varlabels( tag_verificateur  "Total Inspectors" ///
               insp_consec       "Inspectors observable two periods" ) ///
    mtitles("Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total") ///
    mgroups("2018â€“2019" "2019â€“2020" "2018 â€“ avg(2019â€“2020)", ///
            pattern(1 0 0 1 0 0 1 0 0) ///
            span ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            erepeat(\cmidrule(lr){@span})) ///
    booktabs 
	
* Table: Inspectors that executed / voided algo vs inspectors / all (t and t+1)
esttab insp_has_1_u1 insp_has_1_u0 insp_has_1_tot ///
       insp_has_2_u1 insp_has_2_u0 insp_has_2_tot ///
       insp_has_3_u1 insp_has_3_u0 insp_has_3_tot ///
       using "$output\inspector_has_exec_void_t_t1.tex", replace ///
    main(sum) noobs nonote ///
    order( ///
        has_executed_all_t has_executed_ALG_t has_executed_Inspectors_t ///
        has_void_all_t     has_void_ALG_t     has_void_Inspectors_t ///
		has_med_er_all_t   has_med_er_ALG_t     has_med_er_Inspectors_t ///
		has_botq_er_all_t   has_botq_er_ALG_t     has_botq_er_Inspectors_t ///
        has_executed_all_t1 has_executed_ALG_t1 has_executed_Inspectors_t1 ///
        has_void_all_t1     has_void_ALG_t1     has_void_Inspectors_t1 ///
		has_med_er_all_t1   has_med_er_ALG_t1     has_med_er_Inspectors_t1 ///
		has_botq_er_all_t1   has_botq_er_ALG_t1     has_botq_er_Inspectors_t1 ///
    ) ///
    refcat( has_executed_all_t  "Year t"  has_executed_all_t1 "Year t+1" , nolabel) ///
    varlabels( ///
        has_executed_all_t        "Executed any audit" ///
        has_executed_ALG_t        "Executed algo-selected audit" ///
        has_executed_Inspectors_t "Executed inspector-selected audit" ///
        has_void_all_t            "Reported any void audit" ///
        has_void_ALG_t            "Reported void algo audit" ///
        has_void_Inspectors_t     "Reported void inspector audit" ///
        has_med_er_all_t          "Reported any below-median evasion rate" ///
        has_med_er_ALG_t          "Reported below-median evasion rate algo audit" ///
        has_med_er_Inspectors_t   "Reported below-median evasion rate  inspector audit" ///
        has_botq_er_all_t          "Reported any bot-quartile evasion rate" ///
        has_botq_er_ALG_t          "Reported bot-quartile  evasion rate algo audit" ///
        has_botq_er_Inspectors_t   "Reported bot-quartile  evasion rate  inspector audit" ///
		has_executed_all_t1        "Executed any audit" ///
        has_executed_ALG_t1        "Executed algo-selected audit" ///
        has_executed_Inspectors_t1 "Executed inspector-selected audit" ///
        has_void_all_t1            "Reported any void audit" ///
        has_void_ALG_t1            "Reported void algo audit" ///
        has_void_Inspectors_t1     "Reported void inspector audit" ///
		has_med_er_all_t1          "Reported any below-median evasion rate" ///
        has_med_er_ALG_t1          "Reported below-median evasion rate algo audit" ///
        has_med_er_Inspectors_t1   "Reported below-median evasion rate  inspector audit" ///
        has_botq_er_all_t1          "Reported any bot-quartile evasion rate" ///
        has_botq_er_ALG_t1          "Reported bot-quartile  evasion rate algo audit" ///
        has_botq_er_Inspectors_t1   "Reported bot-quartile  evasion rate  inspector audit" ///
    ) ///
    mtitles("Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total") ///
    mgroups("2018â€“2019" "2019â€“2020" "2018 â€“ avg(2019â€“2020)", ///
            pattern(1 0 0 1 0 0 1 0 0) ///
            span ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            erepeat(\cmidrule(lr){@span})) ///
    booktabs
	

	* Table: Mean shares of execution / voids in t and t+1 (percent)
esttab insp_share_1_u1 insp_share_1_u0 insp_share_1_tot ///
       insp_share_2_u1 insp_share_2_u0 insp_share_2_tot ///
       insp_share_3_u1 insp_share_3_u0 insp_share_3_tot ///
       using "$output\inspector_share_exec_void_t_t1.tex", replace ///
    noobs nonote  ///
    main(mean ) ///
    aux(sd) ///
    order( ///
        share_exec_all_t share_exec_ALG_t share_exec_Inspectors_t ///
        share_v_all_t     share_v_ALG_t     share_v_Inspectors_t ///
		share_med_er_all_t     share_med_er_ALG_t     share_med_er_Inspectors_t ///
		share_botq_er_all_t     share_botq_er_ALG_t     share_botq_er_Inspectors_t ///
        share_exec_all_t1 share_exec_ALG_t1 share_exec_Inspectors_t1 ///
        share_v_all_t1     share_v_ALG_t1     share_v_Inspectors_t1 ///
		share_med_er_all_t1     share_med_er_ALG_t1     share_med_er_Inspectors_t1 ///
		share_botq_er_all_t1     share_botq_er_ALG_t1     share_botq_er_Inspectors_t1 ///
    ) ///
	 refcat( share_exec_all_t  "Year t"  share_exec_all_t1 "Year t+1" , nolabel) ///
    varlabels( ///
        share_exec_all_t        "Exec rate, all audits" ///
        share_exec_ALG_t        "Exec rate, algo audits" ///
        share_exec_Inspectors_t "Exec rate, inspector audits" ///
        share_v_all_t           "Void rate, all audits" ///
        share_v_ALG_t           "Void rate, algo audits" ///
        share_v_Inspectors_t    "Void rate, inspector audits" ///
        share_med_er_all_t      "Share of below median ev. rate, all audits" ///
        share_med_er_ALG_t      "Share of below median ev. rate, algo audits" ///
        share_med_er_Inspectors_t "Share of below median ev. rate, inspector audits" ///
		share_botq_er_all_t      "Share of bottom quartile ev. rate, all audits" ///
        share_botq_er_ALG_t      "Share of bottom quartile ev. rate, algo audits" ///
        share_botq_er_Inspectors_t "Share of bottom quartile ev. rate, inspector audits" ///
        share_exec_all_t1        "Exec rate, all audits" ///
        share_exec_ALG_t1        "Exec rate, algo audits" ///
        share_exec_Inspectors_t1 "Exec rate, inspector audits" ///
        share_v_all_t1           "Void rate, all audits" ///
        share_v_ALG_t1           "Void rate, algo audits" ///
        share_v_Inspectors_t1    "Void rate, inspector audits" ///
        share_med_er_all_t1      "Share of below median ev. rate, all audits" ///
        share_med_er_ALG_t1      "Share of below median ev. rate, algo audits" ///
        share_med_er_Inspectors_t1 "Share of below median ev. rate, inspector audits" ///
		share_botq_er_all_t1      "Share of bottom quartile ev. rate, all audits" ///
        share_botq_er_ALG_t1     "Share of bottom quartile ev. rate, algo audits" ///
        share_botq_er_Inspectors_t1 "Share of bottom quartile ev. rate, inspector audits" ///
    ) ///
    mtitles("Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total" ///
            "Same bureau" "Changed bureau" "Total") ///
    mgroups("2018â€“2019" "2019â€“2020" "2018 â€“ avg(2019â€“2020)", ///
            pattern(1 0 0 1 0 0 1 0 0) ///
            span ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            erepeat(\cmidrule(lr){@span})) ///
    booktabs

