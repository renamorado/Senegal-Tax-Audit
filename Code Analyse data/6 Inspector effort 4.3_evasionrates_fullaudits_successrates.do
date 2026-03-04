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
	
***
**# compare shares of algo + random cases in year 1 versus year 2 
***



*Scatter plot - Inspector level analysis
*** Table with stats on detected cases per method 
** Focus on desk audits for now 

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

**# Select general sample

*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

**Focus on full audits 
keep if x2==1 // Focus on Full Audits 

**# Creating null/ detected audit variables
gen null_evasion = (y4==0)
replace null_evasion=. if y2==0 
gen detected_audit = 1 - null_evasion
replace detected_audit = . if y2==0

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
graph export "$output/kdensity_evasionrate_syear_fullaudits_success.pdf", replace

	
**# 3. tag cases with above median and top quartile evasionrate within list 
egen taglist= tag(bureau selectionyear) 

*egen group= group(bureau selectionyear)
count if taglist  ==1 // 272 list



*ssc install egenmore, replace
*generate variable grouping algo + rand cases 
gen alg_rand = (method=="Algorithm" | method=="Random") // there are no random cases for inspectors so actually this doesn't matter here

*generate variable taging cluster + year + method (alg+rand or inspectors)
egen selectionyearmethod = group(selectionyear alg_rand)

egen quartiles_er= xtile(evasionrate), by(selectionyearmethod)  nq(4)   // or nquantiles(4)

*above median 
gen abovemedian_er = (quartiles_er==3 | quartiles_er==4)
replace abovemedian_er =. if y2==0

gen topquartile_er = (quartiles_er==4)
replace topquartile_er = . if y2==0

tab null_evasion abovemedian_er 
tab topquartile_er


**# Checking 
* How many unique tax offices per year × group?
preserve
keep inspectorcluster selectionyear alg_rand
duplicates drop
tab selectionyear alg_rand
restore

* Quartiles should vary within each year × group
by selectionyear, sort: tab alg_rand quartiles_er, missing
*tab selectionyear alg_rand quartiles_er, missing


***************
**# Analysis
***************

*generate a count number 
gen n=1 
*collapse data at the inspector - year - bureau - selectionmethod level
* focus on 2018 -2019
rename y2 total_executed
rename n total_assigned


**# Flag tax offices that were observed during the whole period 
*===============================
* Bureau coverage flags (2018–2020) — robust version
*===============================
preserve
    keep bureau_detailed selectionyear
    rename bureau_detailed bureau

    * Normalize bureau strings so merge matches
    replace bureau = strtrim(upper(bureau))

    keep if inrange(selectionyear,2018,2020)
    bys bureau selectionyear: keep if _n==1

    gen byte y18 = (selectionyear==2018)
    gen byte y19 = (selectionyear==2019)
    gen byte y20 = (selectionyear==2020)

    bys bureau: egen obs18 = max(y18)
    bys bureau: egen obs19 = max(y19)
    bys bureau: egen obs20 = max(y20)

    gen byte obs_all3      = (obs18 & obs19 & obs20)
    gen byte obs_1819_only = (obs18 & obs19 & !obs20)
    gen byte obs_1920_only = (!obs18 & obs19 & obs20)

    keep bureau obs18 obs19 obs20 obs_all3 obs_1819_only obs_1920_only
    bys bureau: keep if _n==1

    tempfile bureau_cov
    save `bureau_cov', replace

	restore

*Create set of conditions 
local cond1 "if selectionyear==2018 | selectionyear==2019"
local cond2 "if selectionyear==2019 | selectionyear==2020"
local cond3 ""

drop bureau 
rename bureau_detailed bureau
**# loop over samples based on periods 
forval sample = 1/3 {
	preserve	
		*collapse (sum) total_assigned total_executed null_evasion `cond1'
		*collapse (sum) total_assigned total_executed null_evasion `cond`sample''
		*local sample = 3 `cond`sample'' 
		collapse (sum) total_assigned total_executed detected_audit abovemedian_er topquartile_er `cond`sample'' , by(method groupbureau bureau selectionyear) 
		
		
		*Collapsing at the inspector - bureau - selectionyear level
		*collapse (sum) total_assigned total_executed null_evasion `cond`sample'', ///
		by(method groupbureau bureau selectionyear) 
		
		*reshaping to obtain the audit numbers (method as columns)
		reshape wide total_assigned total_executed detected_audit abovemedian_er topquartile_er, ///
		i(bureau groupbureau selectionyear) j(method, string)
		
		*encoding all missings to zero at this stage	
		mvencode _all, mv(0) override
		
		***********
		**# Creating the sample 
		************
		
		*tagging bureaux
		egen tag_bureau = tag(bureau)
		


		**check if tax office is observable for two consecutive periods
	* Ensure proper sort
	sort bureau selectionyear 

	* Mark first observation of each bureau-year
	by bureau selectionyear: gen first_in_year = _n == 1

	* Cumulative sum of "first_in_year" within inspector = year sequence
	by bureau: gen year_seq = sum(first_in_year)
	
	*tag inspectors by the max periods they wer observed
	bys bureau: egen max_period = max(year_seq)
	
	*Only 4 inspectors were observed in the same time 
	tab max_period if tag_bureau==1 

		gen bureau_consec = (max_period>1)

		gen final_sample = bureau_consec==1  // & unchanged_bureau==1 [new analysis now will distinguish between unchanged and changed bureau]

		
	*Summary stats of inspector sample 
		* Clear any previous stored estimates
			* Total 
			estpost tabstat tag_bureau bureau_consec ///
				if  tag_bureau == 1, ///
				stat(sum) columns(statistics)
			eststo bureau_stats_`sample'
		
		
* Keep elegible inspectors (observable in t AND t+1)
		keep if final_sample==1 // sample eligible inspectors 

		
* collapse at the inspector year level		
	collapse (sum) total_assigned* total_executed* detected_audit* topquartile_er* abovemedian_er*, by(bureau selectionyear)
	egen tag_bureau = tag(bureau)
		** Generating total
		*Total execution
		egen total_executed_audits = rowtotal(total_executed*)
		
		egen total_assigned_audits = rowtotal(total_assigned*)
		


		egen total_detected_audits = rowtotal(detected_audit*)
		egen total_abvmed_er = rowtotal(abovemedian_er*)
		egen total_topq_er = rowtotal(topquartile_er*)

		**# Generating shares 
		*total detected 
		gen share_det_all= (total_detected_audits / total_executed_audits) * 100

		*total above-median evasion rate
		gen share_abvmed_er_all= (total_abvmed_er/ total_executed_audits) * 100
		*total top quartile audit cases 
		gen share_topq_er_all= (total_topq_er/ total_executed_audits) * 100
		*total execution
		gen share_exec_all= (total_executed_audits / total_assigned_audits) * 100

		
		
*generating shares among methods
		foreach met in Algorithm Inspectors  {
			*detection rate - share wrt total execution by inspector
			gen share_det_`met'_all = (detected_audit`met'/total_executed_audits)*100  if total_executed`met'!=0
			
			* detection rate - share within selection method
			gen share_det_`met' = (detected_audit`met'/total_executed`met')*100  // it will be undefined when 0
			
			*share of audits above median evasion rate
			gen share_abvmed_er_`met' = (abovemedian_er`met'/total_executed`met')*100  // it will be undefined when 0
			gen share_topq_er_`met' = (topquartile_er`met'/total_executed`met')*100  // it will be undefined when 0
			
			* share of total executed x selection method cases with with respect to total assigned cases by inspector
			gen share_exec_`met'_all = (total_executed`met'/total_assigned_audits)*100 
			
			** share of total executed x selection method cases with with respect to total x method assigned cases by inspector
			gen share_exec_`met' = (total_executed`met'/total_assigned`met')*100 
		}

		*relIns measures: ratio of algorithm to inspector shares/rates
		gen byte zero_den_exec  = (total_assignedAlgorithm==0 | total_assignedInspectors==0)
		gen byte zero_den_share = (total_executedAlgorithm==0 | total_executedInspectors==0)

		gen byte zero_ins_det    = (share_det_Inspectors==0)
		gen byte zero_ins_abvmed  = (share_abvmed_er_Inspectors==0)
		gen byte zero_ins_topq = (share_topq_er_Inspectors==0)
		gen byte zero_ins_exec = (share_exec_Inspectors==0)

		gen rel_share_det_Algorithm       = share_det_Algorithm / share_det_Inspectors
		replace rel_share_det_Algorithm   = . if zero_ins_det==1 | zero_den_share==1

		gen rel_share_abvmed_Algorithm     = share_abvmed_er_Algorithm / share_abvmed_er_Inspectors
		replace rel_share_abvmed_Algorithm = . if zero_ins_abvmed==1 | zero_den_share==1

		gen rel_share_topq_er_Algorithm     = share_topq_er_Algorithm / share_topq_er_Inspectors
		replace rel_share_topq_er_Algorithm = . if zero_ins_topq==1 | zero_den_share==1

		gen rel_share_exec_Algorithm     = share_exec_Algorithm / share_exec_Inspectors
		replace rel_share_exec_Algorithm = . if zero_ins_exec==1 | zero_den_exec==1

		local N_rel_before = _N
		quietly count if !zero_den_share & !zero_ins_det
		local N_rel_after_det = r(N)
		quietly count if !zero_den_share & !zero_ins_abvmed
		local N_rel_after_abvmed = r(N)
		quietly count if !zero_den_share & !zero_ins_topq
		local N_rel_after_topq = r(N)
		quietly count if !zero_den_exec & !zero_ins_exec
		local N_rel_after_exec = r(N)
		quietly count if zero_ins_det==1
		local N_zero_ins_det = r(N)
		quietly count if zero_ins_abvmed==1
		local N_zero_ins_abvmed = r(N)
		quietly count if zero_ins_topq==1
		local N_zero_ins_topq = r(N)
		quietly count if zero_ins_exec==1
		local N_zero_ins_exec = r(N)

		di as txt "relIns summary (FULL, sample `sample'): unit-years before filters = `N_rel_before'"
		di as txt "  after filters (det/abvmed/topq/exec) = `N_rel_after_det' / `N_rel_after_abvmed' / `N_rel_after_topq' / `N_rel_after_exec'"
		di as txt "  dropped due to zero inspector share (det/abvmed/topq/exec) = `N_zero_ins_det' / `N_zero_ins_abvmed' / `N_zero_ins_topq' / `N_zero_ins_exec'"
		di as txt "  weights used: none"



		*make the scatter plot 

		keep bureau selectionyear  share_det_Algorithm_all share_det_Algorithm ///  
		share_abvmed_er_Algorithm share_topq_er_Algorithm share_exec_Algorithm ///
		share_exec_Algorithm_all  share_det_all share_exec_all share_abvmed_er_all ///
		share_topq_er_all share_det_Inspectors_all share_det_Inspectors ///
		share_abvmed_er_Inspectors share_topq_er_Inspectors ///
		share_exec_Inspectors_all share_exec_Inspectors ///
		rel_share_det_Algorithm rel_share_abvmed_Algorithm rel_share_topq_er_Algorithm ///
		rel_share_exec_Algorithm

		reshape wide share_det_Algorithm_all share_det_Algorithm ///  
		share_abvmed_er_Algorithm share_topq_er_Algorithm share_exec_Algorithm /// 
		share_exec_Algorithm_all share_det_all share_exec_all share_abvmed_er_all ///
		share_topq_er_all share_det_Inspectors_all share_det_Inspectors ///
		share_abvmed_er_Inspectors share_topq_er_Inspectors ///
		share_exec_Inspectors_all share_exec_Inspectors ///
		rel_share_det_Algorithm rel_share_abvmed_Algorithm rel_share_topq_er_Algorithm ///
		rel_share_exec_Algorithm, ///
		i(bureau) j(selectionyear)
		
		* Merge bureau coverage (built from full 2018–2020 sample)
		merge 1:1 bureau using `bureau_cov', nogen keep(match)

		* btype: 2 = observed all 3 years, 1 = not observed all 3 years
		gen byte btype = .
		replace btype = 2 if obs_all3==1
		replace btype = 1 if obs_all3==0 & !missing(obs_all3)

		label define btype ///
			1 "Observed the whole period" ///
			2 "Observed 2019-2020 only", replace
		label values btype btype


*			keep if inlist(btype,1,2)


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
				

				foreach share in share_exec_all share_exec_Algorithm ///
				share_exec_Inspectors share_det_all share_det_Algorithm ///
				share_det_Inspectors share_abvmed_er_all ///
				share_abvmed_er_Algorithm share_abvmed_er_Inspectors ///
				share_topq_er_all share_topq_er_Algorithm share_topq_er_Inspectors ///
				rel_share_exec_Algorithm rel_share_det_Algorithm ///
				rel_share_abvmed_Algorithm rel_share_topq_er_Algorithm {
						egen `share'avg =rowmean(`share'2019 `share'2020)
					}
				
				}
				
				
***cap labelling some vars
	*========================================================
	* 2018
	*========================================================
	cap label var share_det_Algorithm_all2018            "Share of detected audits, Algorithm (all, 2018)"
	cap label var share_det_Algorithm2018                "Share of detected audits, Algorithm (2018)"
	cap label var share_exec_Algorithm2018             "Share of executed cases, Algorithm (2018)"
	cap label var share_exec_Algorithm_all2018         "Share of executed cases, Algorithm (all, 2018)"
	cap label var share_det_all2018                "Share of detected audits, all (2018)"
	cap label var share_exec_all2018             "Share of executed cases, all (2018)"
	cap label var share_det_Inspectors_all2018     "Share of detected audits, Inspectors (all, 2018)"
	cap label var share_det_Inspectors2018         "Share of detected audits, Inspectors (2018)"
	cap label var share_exec_Inspectors_all2018  "Share of executed cases, Inspectors (all, 2018)"
	cap label var share_exec_Inspectors2018      "Share of executed cases, Inspectors (2018)"

	cap label var share_abvmed_er_Algorithm_all2018         "Share of above-median evasion rate cases, Algorithm (all, 2018)"
	cap label var share_abvmed_er_Algorithm2018             "Share of above-median evasion rate cases, Algorithm (2018)"
	cap label var share_abvmed_er_all2018             "Share of above-median evasion rate cases, all (2018)"
	cap label var share_abvmed_er_Inspectors_all2018  "Share of above-median evasion rate cases, Inspectors (all, 2018)"
	cap label var share_abvmed_er_Inspectors2018      "Share of above-median evasion rate cases, Inspectors (2018)"

	cap label var share_topq_er_Algorithm_all2018        "Share of top-quartile evasion rate cases, Algorithm (all, 2018)"
	cap label var share_topq_er_Algorithm2018            "Share of top-quartile evasion rate cases, Algorithm (2018)"
	cap label var share_topq_er_all2018            "Share of top-quartile evasion rate cases, all (2018)"
	cap label var share_topq_er_Inspectors_all2018 "Share of top-quartile evasion rate cases, Inspectors (all, 2018)"
	cap label var share_topq_er_Inspectors2018     "Share of top-quartile evasion rate cases, Inspectors (2018)"


	*========================================================
	* 2019
	*========================================================
	cap label var share_det_Algorithm_all2019            "Share of detected audits, Algorithm (all, 2019)"
	cap label var share_det_Algorithm2019                "Share of detected audits, Algorithm (2019)"
	cap label var share_exec_Algorithm2019             "Share of executed cases, Algorithm (2019)"
	cap label var share_exec_Algorithm_all2019         "Share of executed cases, Algorithm (all, 2019)"
	cap label var share_det_all2019                "Share of detected audits, all (2019)"
	cap label var share_exec_all2019             "Share of executed cases, all (2019)"
	cap label var share_det_Inspectors_all2019     "Share of detected audits, Inspectors (all, 2019)"
	cap label var share_det_Inspectors2019         "Share of detected audits, Inspectors (2019)"
	cap label var share_exec_Inspectors_all2019  "Share of executed cases, Inspectors (all, 2019)"
	cap label var share_exec_Inspectors2019      "Share of executed cases, Inspectors (2019)"

	cap label var share_abvmed_er_Algorithm_all2019         "Share of above-median evasion rate cases, Algorithm (all, 2019)"
	cap label var share_abvmed_er_Algorithm2019             "Share of above-median evasion rate cases, Algorithm (2019)"
	cap label var share_abvmed_er_all2019             "Share of above-median evasion rate cases, all (2019)"
	cap label var share_abvmed_er_Inspectors_all2019  "Share of above-median evasion rate cases, Inspectors (all, 2019)"
	cap label var share_abvmed_er_Inspectors2019      "Share of above-median evasion rate cases, Inspectors (2019)"

	cap label var share_topq_er_Algorithm_all2019        "Share of top-quartile evasion rate cases, Algorithm (all, 2019)"
	cap label var share_topq_er_Algorithm2019            "Share of top-quartile evasion rate cases, Algorithm (2019)"
	cap label var share_topq_er_all2019            "Share of top-quartile evasion rate cases, all (2019)"
	cap label var share_topq_er_Inspectors_all2019 "Share of top-quartile evasion rate cases, Inspectors (all, 2019)"
	cap label var share_topq_er_Inspectors2019     "Share of top-quartile evasion rate cases, Inspectors (2019)"


	*========================================================
	* 2020
	*========================================================
	cap label var share_det_Algorithm_all2020            "Share of detected audits, Algorithm (all, 2020)"
	cap label var share_det_Algorithm2020                "Share of detected audits, Algorithm (2020)"
	cap label var share_exec_Algorithm2020             "Share of executed cases, Algorithm (2020)"
	cap label var share_exec_Algorithm_all2020         "Share of executed cases, Algorithm (all, 2020)"
	cap label var share_det_all2020                "Share of detected audits, all (2020)"
	cap label var share_exec_all2020             "Share of executed cases, all (2020)"
	cap label var share_det_Inspectors_all2020     "Share of detected audits, Inspectors (all, 2020)"
	cap label var share_det_Inspectors2020         "Share of detected audits, Inspectors (2020)"
	cap label var share_exec_Inspectors_all2020  "Share of executed cases, Inspectors (all, 2020)"
	cap label var share_exec_Inspectors2020      "Share of executed cases, Inspectors (2020)"

	cap label var share_abvmed_er_Algorithm_all2020         "Share of above-median evasion rate cases, Algorithm (all, 2020)"
	cap label var share_abvmed_er_Algorithm2020             "Share of above-median evasion rate cases, Algorithm (2020)"
	cap label var share_abvmed_er_all2020             "Share of above-median evasion rate cases, all (2020)"
	cap label var share_abvmed_er_Inspectors_all2020  "Share of above-median evasion rate cases, Inspectors (all, 2020)"
	cap label var share_abvmed_er_Inspectors2020      "Share of above-median evasion rate cases, Inspectors (2020)"

	cap label var share_topq_er_Algorithm_all2020        "Share of top-quartile evasion rate cases, Algorithm (all, 2020)"
	cap label var share_topq_er_Algorithm2020            "Share of top-quartile evasion rate cases, Algorithm (2020)"
	cap label var share_topq_er_all2020            "Share of top-quartile evasion rate cases, all (2020)"
	cap label var share_topq_er_Inspectors_all2020 "Share of top-quartile evasion rate cases, Inspectors (all, 2020)"
	cap label var share_topq_er_Inspectors2020     "Share of top-quartile evasion rate cases, Inspectors (2020)"


	*========================================================
	* AVG (adjust varnames if needed)
	*========================================================
	cap label var share_det_Algorithm_allavg             "Share of detected audits, Algorithm (all,2019-2020)"
	cap label var share_det_Algorithmavg                 "Share of detected audits, Algorithm (2019-2020)"
	cap label var share_exec_Algorithmavg              "Share of executed cases, Algorithm (2019-2020)"
	cap label var share_exec_Algorithm_allavg          "Share of executed cases, Algorithm (all,2019-2020)"
	cap label var share_det_allavg                 "Share of detected audits, all (2019-2020)"
	cap label var share_exec_allavg              "Share of executed cases, all (2019-2020)"
	cap label var share_det_Inspectors_allavg      "Share of detected audits, Inspectors (all,2019-2020)"
	cap label var share_det_Inspectorsavg          "Share of detected audits, Inspectors (2019-2020)"
	cap label var share_exec_Inspectors_allavg   "Share of executed cases, Inspectors (all,2019-2020)"
	cap label var share_exec_Inspectorsavg       "Share of executed cases, Inspectors (2019-2020)"

	cap label var share_abvmed_er_Algorithm_allavg          "Share of above-median evasion rate cases, Algorithm (all,2019-2020)"
	cap label var share_abvmed_er_Algorithmavg              "Share of above-median evasion rate cases, Algorithm (2019-2020)"
	cap label var share_abvmed_er_allavg              "Share of above-median evasion rate cases, all (2019-2020)"
	cap label var share_abvmed_er_Inspectors_allavg   "Share of above-median evasion rate cases, Inspectors (all,2019-2020)"
	cap label var share_abvmed_er_Inspectorsavg       "Share of above-median evasion rate cases, Inspectors (2019-2020)"

	cap label var share_topq_er_Algorithm_allavg         "Share of top-quartile evasion rate cases, Algorithm (all,2019-2020)"
	cap label var share_topq_er_Algorithmavg             "Share of top-quartile evasion rate cases, Algorithm (2019-2020)"
	cap label var share_topq_er_allavg             "Share of top-quartile evasion rate cases, all (2019-2020)"
	cap label var share_topq_er_Inspectors_allavg  "Share of top-quartile evasion rate cases, Inspectors (all,2019-2020)"
	cap label var share_topq_er_Inspectorsavg      "Share of top-quartile evasion rate cases, Inspectors (2019-2020)"






		*------------------------------------------------------------
        * TABLE: mean share execution / detections in t and t+1
        *   - Create generic names for t and t+1 so rows align across samples
        *------------------------------------------------------------

        * --- Year t: copy year-specific variables into generic names ---
        gen share_exec_all_t        = share_exec_all`t'
        gen share_exec_Algorithm_t        = share_exec_Algorithm`t'
        gen share_exec_Inspectors_t = share_exec_Inspectors`t'
        
		gen share_det_all_t           = share_det_all`t'
        gen share_det_Algorithm_t           = share_det_Algorithm`t'
        gen share_det_Inspectors_t    = share_det_Inspectors`t'
		
		gen share_abvmed_er_all_t           = share_abvmed_er_all`t'
        gen share_abvmed_er_Algorithm_t           = share_abvmed_er_Algorithm`t'
        gen share_abvmed_er_Inspectors_t    = share_abvmed_er_Inspectors`t'
		
		gen share_topq_er_all_t           = share_topq_er_all`t'
        gen share_topq_er_Algorithm_t           = share_topq_er_Algorithm`t'
        gen share_topq_er_Inspectors_t    = share_topq_er_Inspectors`t'
		

        * --- Year t+1 ---
        gen share_exec_all_t1        = share_exec_all`t1'
        gen share_exec_Algorithm_t1        = share_exec_Algorithm`t1'
        gen share_exec_Inspectors_t1 = share_exec_Inspectors`t1'
		
        gen share_det_all_t1           = share_det_all`t1'
        gen share_det_Algorithm_t1           = share_det_Algorithm`t1'
        gen share_det_Inspectors_t1    = share_det_Inspectors`t1'

        gen share_abvmed_er_all_t1           = share_abvmed_er_all`t1'
        gen share_abvmed_er_Algorithm_t1           = share_abvmed_er_Algorithm`t1'
        gen share_abvmed_er_Inspectors_t1    = share_abvmed_er_Inspectors`t1'
		
		gen share_topq_er_all_t1           = share_topq_er_all`t1'
        gen share_topq_er_Algorithm_t1           = share_topq_er_Algorithm`t1'
        gen share_topq_er_Inspectors_t1    = share_topq_er_Inspectors`t1'

        *------------------------------------------------------------
        * estpost summarize: one set of estimates per group
        *   (same bureau / changed / total), each with t AND t+1 rows
        *------------------------------------------------------------


        * Total (all inspectors)
        eststo bureau_share_`sample': estpost summarize ///
            share_exec_all_t share_exec_Algorithm_t share_exec_Inspectors_t ///
            share_det_all_t     share_det_Algorithm_t     share_det_Inspectors_t ///
			share_abvmed_er_all_t share_abvmed_er_Algorithm_t share_abvmed_er_Inspectors_t  ///
			share_topq_er_all_t share_topq_er_Algorithm_t share_topq_er_Inspectors_t ///
            share_exec_all_t1 share_exec_Algorithm_t1 share_exec_Inspectors_t1 ///
            share_det_all_t1     share_det_Algorithm_t1     share_det_Inspectors_t1 ///
			share_abvmed_er_all_t1 share_abvmed_er_Algorithm_t1 share_abvmed_er_Inspectors_t1  ///
			share_topq_er_all_t1 share_topq_er_Algorithm_t1 share_topq_er_Inspectors_t1 ///

	
		*------------------------------------------------------------
        * Indicators for descriptive table: t and t+1
        *   (names do NOT contain the actual year, only _t / _t1)
        *------------------------------------------------------------

        * --- Year t ---
        gen has_executed_all_t = (share_exec_all`t' > 0 & share_exec_all`t' != .)
        gen has_detected_all_t     = (share_det_all`t' > 0 & share_det_all`t' != .)
		gen has_abvmed_er_all_t   = (share_abvmed_er_all`t' > 0 & share_abvmed_er_all`t' != .)
		gen has_topq_er_all_t   = (share_topq_er_all`t' > 0 & share_topq_er_all`t' != .)

		
     foreach met in Algorithm Inspectors {
	 	
        gen has_executed_`met'_t = (share_exec_`met'`t' > 0 & share_exec_`met'`t' != .)
        gen has_detected_`met'_t     = (share_det_`met'`t'    > 0 & share_det_`met'`t'    != .)
		gen has_abvmed_er_`met'_t   = (share_abvmed_er_`met'`t' > 0 & share_abvmed_er_`met'`t' != .)
		gen has_topq_er_`met'_t  = (share_topq_er_`met'`t' > 0 & share_topq_er_`met'`t' != .)
			
        }

        * --- Year t+1 ---
        gen has_executed_all_t1 = (share_exec_all`t1' > 0 & share_exec_all`t1' != .)
        gen has_detected_all_t1     = (share_det_all`t1'    > 0 & share_det_all`t1'    != .)
		gen has_abvmed_er_all_t1   = (share_abvmed_er_all`t1' > 0 & share_abvmed_er_all`t1' != .)
		gen has_topq_er_all_t1   = (share_topq_er_all`t1' > 0 & share_topq_er_all`t1' != .)
		

     foreach met in Algorithm Inspectors {
         gen has_executed_`met'_t1 = (share_exec_`met'`t1' > 0 & share_exec_`met'`t1' != .)
         gen has_detected_`met'_t1     = (share_det_`met'`t1'    > 0 & share_det_`met'`t1'    != .)
		 gen has_abvmed_er_`met'_t1   = (share_abvmed_er_`met'`t1' > 0 & share_abvmed_er_`met'`t1' != .)
		 gen has_topq_er_`met'_t1  = (share_topq_er_`met'`t1' > 0 & share_topq_er_`met'`t1' != .)
        }

        *------------------------------------------------------------
        * estpost tabstat: ONE set of estimates per group, containing
        * BOTH t and t+1 variables as rows
        *------------------------------------------------------------


        * Total (all inspectors)
        eststo bureau_has_`sample': estpost tabstat ///
            has_executed_all_t has_executed_Algorithm_t has_executed_Inspectors_t ///
            has_detected_all_t     has_detected_Algorithm_t     has_detected_Inspectors_t ///
			has_abvmed_er_all_t 	has_abvmed_er_Algorithm_t has_abvmed_er_Inspectors_t ///
			has_topq_er_all_t 	has_topq_er_Algorithm_t has_topq_er_Inspectors_t ///
            has_executed_all_t1 has_executed_Algorithm_t1 has_executed_Inspectors_t1 ///
            has_detected_all_t1     has_detected_Algorithm_t1     has_detected_Inspectors_t1 ///
			has_abvmed_er_all_t1 	has_abvmed_er_Algorithm_t1 has_abvmed_er_Inspectors_t1 ///
			has_topq_er_all_t1 	has_topq_er_Algorithm_t1 has_topq_er_Inspectors_t1, ///
            stat(sum) columns(statistics)
		**# Generating graphs 

foreach share in share_exec_all share_exec_Algorithm share_exec_Inspectors ///
                 share_det_all   share_det_Algorithm   share_det_Inspectors ///
                 share_abvmed_er_all share_abvmed_er_Algorithm share_abvmed_er_Inspectors ///
                 share_topq_er_all share_topq_er_Algorithm share_topq_er_Inspectors {

    * x-variable always uses the share at time t
    local xvar "`share'`t'"

    * Defaults
    local y_t     ""
    local y_t1    ""
    local x_title ""
    local y_title ""

    * -----------------------------
    * Map each case to y-variables + titles
    * -----------------------------
    if "`share'" == "share_det_all" {
        local y_t     "share_exec_all`t'"
        local y_t1    "share_exec_all`t1'"
        local x_title "Detection rate, all audits, year t"
        local y_title "Execution rate, all audits, year t+1"
    }
    else if "`share'" == "share_det_Algorithm" {
        local y_t     "share_exec_Algorithm`t'"
        local y_t1    "share_exec_Algorithm`t1'"
        local x_title "Detection rate, algo audits, year t"
        local y_title "Execution rate, algo audits, year t+1"
    }
    else if "`share'" == "share_det_Inspectors" {
        local y_t     "share_exec_Inspectors`t'"
        local y_t1    "share_exec_Inspectors`t1'"
        local x_title "Detection rate, inspector audits, year t"
        local y_title "Execution rate, inspector audits, year t+1"
    }
    else if "`share'" == "share_abvmed_er_all" {
        local y_t     "share_exec_all`t'"
        local y_t1    "share_exec_all`t1'"
        local x_title "% above median evasion rate - all audits, year t"
        local y_title "Execution rate - all audits, year t+1"
    }
    else if "`share'" == "share_abvmed_er_Algorithm" {
        local y_t     "share_exec_Algorithm`t'"
        local y_t1    "share_exec_Algorithm`t1'"
        local x_title "% above median evasion rate - Algo audits, year t"
        local y_title "Execution rate - algo audits, year t+1"
    }
    else if "`share'" == "share_abvmed_er_Inspectors" {
        local y_t     "share_exec_Inspectors`t'"
        local y_t1    "share_exec_Inspectors`t1'"
        local x_title "% above median evasion rate - Inspector audits, year t"
        local y_title "Execution rate - inspector audits, year t+1"
    }
    else if "`share'" == "share_topq_er_all" {
        local y_t     "share_exec_all`t'"
        local y_t1    "share_exec_all`t1'"
        local x_title "% top quartile evasion rate cases - all audits, year t"
        local y_title "Execution rate - all audits, year t+1"
    }
    else if "`share'" == "share_topq_er_Algorithm" {
        local y_t     "share_exec_Algorithm`t'"
        local y_t1    "share_exec_Algorithm`t1'"
        local x_title "% top quartile evasion rate cases - Algo audits, year t"
        local y_title "Execution rate - algo audits, year t+1"
    }
    else if "`share'" == "share_topq_er_Inspectors" {
        local y_t     "share_exec_Inspectors`t'"
        local y_t1    "share_exec_Inspectors`t1'"
        local x_title "% top quartile evasion rate cases - Inspector audits, year t"
        local y_title "Execution rate - inspector audits, year t+1"
    }
    else {
        * Same measure both axes (t vs t+1)
        local y_t     "`share'`t'"
        local y_t1    "`share'`t1'"
        local x_title "Share in year t"
        local y_title "Share in year t+1"
    }

    * Common sample condition (matches your original logic)
    local cond "!missing(`xvar', `y_t', `y_t1') & `y_t' != 0"

 *========================================================
    * Show partial-coverage group ONLY for the 2019–2020 window
    * (avoids legends for a group that cannot appear in 2018-based plots)
    *========================================================
    local show_partial = (`sample'==2)

    * Sample sizes by group
    count if `cond' & btype==2
    local n_all3 = r(N)

    local n_part = 0
    if `show_partial' {
        count if `cond' & btype==1
        local n_part = r(N)
    }

    * Regression + equation text: btype==2
    local eq_all3 "Linear Fit (observed the whole period): N<2"
    if `n_all3' >= 2 {
        quietly reg `y_t1' `xvar' if `cond' & btype==2
        local b0_all3    : display %5.2f _b[_cons]
        local b1abs_all3 : display %5.3f abs(_b[`xvar'])
        local se_all3    : display %5.3f _se[`xvar']
        local sign_all3  = cond(_b[`xvar']>=0, "+", "-")
        local eq_all3    "Linear fit: y = `b0_all3' `sign_all3' `b1abs_all3' x (SE=`se_all3')"
    }

    * Regression + equation text: btype==1 (only if shown AND enough obs)
    local eq_part "Linear fit (partial coverage)"
    if `show_partial' & `n_part' >= 2 {
        quietly reg `y_t1' `xvar' if `cond' & btype==1
        local b0_part    : display %5.2f _b[_cons]
        local b1abs_part : display %5.3f abs(_b[`xvar'])
        local se_part    : display %5.3f _se[`xvar']
        local sign_part  = cond(_b[`xvar']>=0, "+", "-")
        local eq_part    "Linear fit: y = `b0_part' `sign_part' `b1abs_part' x (SE=`se_part')"
    }

*========================================================
* Build plotcmd + legend in PAIRED order:
*   scatter A, fit A, scatter B, fit B
*========================================================
local plotcmd ""
local legorder ""
local leglbls  ""
local p = 0

*-------------------------
* Group A: btype==2
*-------------------------
local plotcmd `"`plotcmd' (scatter `y_t1' `xvar' if `cond' & btype==2, mcolor(dknavy) msymbol(triangle))"'
local p = `p' + 1
local legorder "`legorder' `p'"
local leglbls  `"`leglbls' label(`p' "Tax office observed 2018–2020 [N=`n_all3']")"'

if `n_all3' >= 2 {
    local plotcmd `"`plotcmd' (lfit `y_t1' `xvar' if `cond' & btype==2, lcolor(dknavy) lpattern(solid) lwidth(medthick))"'
    local p = `p' + 1
    local legorder "`legorder' `p'"
    local leglbls  `"`leglbls' label(`p' "`eq_all3'")"'
}

*-------------------------
* Group B: btype==1 (only if shown)
*-------------------------
if `show_partial' & `n_part' > 0 {
    local plotcmd `"`plotcmd' (scatter `y_t1' `xvar' if `cond' & btype==1, mcolor(eltblue) msymbol(circle))"'
    local p = `p' + 1
    local legorder "`legorder' `p'"
    local leglbls  `"`leglbls' label(`p' "Tax office observed 2019-2020 only [N=`n_part']")"'

    if `n_part' >= 2 {
        local plotcmd `"`plotcmd' (lfit `y_t1' `xvar' if `cond' & btype==1, lcolor(eltblue) lpattern(dash) lwidth(medthick))"'
        local p = `p' + 1
        local legorder "`legorder' `p'"
        local leglbls  `"`leglbls' label(`p' "`eq_part'")"'
    }
}

twoway `plotcmd', ///
    legend(order(`legorder') `leglbls' pos(6) ring(1) cols(2) size(vsmall)) ///
    xscale(range(0 100)) xlabel(0(20)100) ///
    yscale(range(0 100)) ylabel(0(20)100) ///
    xtitle("`x_title'") ///
    ytitle("`y_title'")

	graph export "$output/scatter_`share'_`t'_`t1'_full_success.pdf", replace
	}

foreach relshare in rel_share_exec_Algorithm rel_share_det_Algorithm ///
                    rel_share_abvmed_Algorithm rel_share_topq_er_Algorithm {

    local xvar "`relshare'`t'"

    local y_t     ""
    local y_t1    ""
    local x_title ""
    local y_title ""
    local relstub ""

    if "`relshare'" == "rel_share_exec_Algorithm" {
        local y_t     "rel_share_exec_Algorithm`t'"
        local y_t1    "rel_share_exec_Algorithm`t1'"
        local x_title "Execution rate ratio (Algorithm/Inspectors), year t"
        local y_title "Execution rate ratio (Algorithm/Inspectors), year t+1"
        local relstub "share_exec_relIns_Algorithm"
    }
    else if "`relshare'" == "rel_share_det_Algorithm" {
        local y_t     "rel_share_exec_Algorithm`t'"
        local y_t1    "rel_share_exec_Algorithm`t1'"
        local x_title "Detection rate ratio (Algorithm/Inspectors), year t"
        local y_title "Execution rate ratio (Algorithm/Inspectors), year t+1"
        local relstub "share_det_relIns_Algorithm"
    }
    else if "`relshare'" == "rel_share_abvmed_Algorithm" {
        local y_t     "rel_share_exec_Algorithm`t'"
        local y_t1    "rel_share_exec_Algorithm`t1'"
        local x_title "Above-median evasion-rate share ratio (Algorithm/Inspectors), year t"
        local y_title "Execution rate ratio (Algorithm/Inspectors), year t+1"
        local relstub "share_abvmed_er_relIns_Algorithm"
    }
    else if "`relshare'" == "rel_share_topq_er_Algorithm" {
        local y_t     "rel_share_exec_Algorithm`t'"
        local y_t1    "rel_share_exec_Algorithm`t1'"
        local x_title "Top-quartile evasion-rate share ratio (Algorithm/Inspectors), year t"
        local y_title "Execution rate ratio (Algorithm/Inspectors), year t+1"
        local relstub "share_topq_er_relIns_Algorithm"
    }

    local cond "!missing(`xvar', `y_t', `y_t1') & `y_t' != 0"
    local show_partial = (`sample'==2)

    count if `cond' & btype==2
    local n_all3 = r(N)

    local n_part = 0
    if `show_partial' {
        count if `cond' & btype==1
        local n_part = r(N)
    }

    local eq_all3 "Linear Fit (observed the whole period): N<2"
    if `n_all3' >= 2 {
        quietly reg `y_t1' `xvar' if `cond' & btype==2
        local b0_all3    : display %5.2f _b[_cons]
        local b1abs_all3 : display %5.3f abs(_b[`xvar'])
        local se_all3    : display %5.3f _se[`xvar']
        local sign_all3  = cond(_b[`xvar']>=0, "+", "-")
        local eq_all3    "Linear fit: y = `b0_all3' `sign_all3' `b1abs_all3' x (SE=`se_all3')"
    }

    local eq_part "Linear fit (partial coverage)"
    if `show_partial' & `n_part' >= 2 {
        quietly reg `y_t1' `xvar' if `cond' & btype==1
        local b0_part    : display %5.2f _b[_cons]
        local b1abs_part : display %5.3f abs(_b[`xvar'])
        local se_part    : display %5.3f _se[`xvar']
        local sign_part  = cond(_b[`xvar']>=0, "+", "-")
        local eq_part    "Linear fit: y = `b0_part' `sign_part' `b1abs_part' x (SE=`se_part')"
    }

    local plotcmd ""
    local legorder ""
    local leglbls  ""
    local p = 0

    local plotcmd `"`plotcmd' (scatter `y_t1' `xvar' if `cond' & btype==2, mcolor(dknavy) msymbol(triangle))"'
    local p = `p' + 1
    local legorder "`legorder' `p'"
    local leglbls  `"`leglbls' label(`p' "Tax office observed 2018-2020 [N=`n_all3']")"'

    if `n_all3' >= 2 {
        local plotcmd `"`plotcmd' (lfit `y_t1' `xvar' if `cond' & btype==2, lcolor(dknavy) lpattern(solid) lwidth(medthick))"'
        local p = `p' + 1
        local legorder "`legorder' `p'"
        local leglbls  `"`leglbls' label(`p' "`eq_all3'")"'
    }

    if `show_partial' & `n_part' > 0 {
        local plotcmd `"`plotcmd' (scatter `y_t1' `xvar' if `cond' & btype==1, mcolor(eltblue) msymbol(circle))"'
        local p = `p' + 1
        local legorder "`legorder' `p'"
        local leglbls  `"`leglbls' label(`p' "Tax office observed 2019-2020 only [N=`n_part']")"'

        if `n_part' >= 2 {
            local plotcmd `"`plotcmd' (lfit `y_t1' `xvar' if `cond' & btype==1, lcolor(eltblue) lpattern(dash) lwidth(medthick))"'
            local p = `p' + 1
            local legorder "`legorder' `p'"
            local leglbls  `"`leglbls' label(`p' "`eq_part'")"'
        }
    }

    quietly summarize `xvar' if `cond', meanonly
    local xupper = max(1, ceil(2*r(max))/2)

    twoway `plotcmd', ///
        legend(order(`legorder') `leglbls' pos(6) ring(1) cols(2) size(vsmall)) ///
        xscale(range(0 `xupper')) xlabel(0(0.5)`xupper', format(%3.1f)) ///
        yscale(range(0 .)) ylabel(0, add) ///
        xtitle("`x_title'") ///
        ytitle("`y_title'")

	graph export "$output/scatter_`relstub'_`t'_`t1'_full_success.pdf", replace
}
	
	restore			 
}

*********
**# Some tables
*********

*Table: Inspector sample size
esttab bureau_stats_1 ///
       bureau_stats_2 ///
       bureau_stats_3 ///
       using "$output\bureau_sample_stats_success.tex", replace ///
    main(sum) noobs nonote ///
    varlabels( tag_bureau  "Total Bureaux" ///
               bureau_consec       "Inspectors observable two periods" ) ///
        mtitles("2018–2019" "2019–2020" "2018 – avg(2019–2020)") ///
    booktabs 
	
* Table: Inspectors that executed / detected algo vs inspectors / all (t and t+1)
esttab bureau_has_1 ///
       bureau_has_2 ///
       bureau_has_3 ///
       using "$output\bureau_has_exec_detected_t_t1_success.tex", replace ///
    main(sum) noobs nonote ///
    order( ///
        has_executed_all_t has_executed_Algorithm_t has_executed_Inspectors_t ///
        has_detected_all_t     has_detected_Algorithm_t     has_detected_Inspectors_t ///
		has_abvmed_er_all_t   has_abvmed_er_Algorithm_t     has_abvmed_er_Inspectors_t ///
		has_topq_er_all_t   has_topq_er_Algorithm_t     has_topq_er_Inspectors_t ///
        has_executed_all_t1 has_executed_Algorithm_t1 has_executed_Inspectors_t1 ///
        has_detected_all_t1     has_detected_Algorithm_t1     has_detected_Inspectors_t1 ///
		has_abvmed_er_all_t1   has_abvmed_er_Algorithm_t1     has_abvmed_er_Inspectors_t1 ///
		has_topq_er_all_t1   has_topq_er_Algorithm_t1     has_topq_er_Inspectors_t1 ///
    ) ///
    refcat( has_executed_all_t  "Year t"  has_executed_all_t1 "Year t+1" , nolabel) ///
    varlabels( ///
        has_executed_all_t        "Executed any audit" ///
        has_executed_Algorithm_t        "Executed algo-selected audit" ///
        has_executed_Inspectors_t "Executed inspector-selected audit" ///
        has_detected_all_t            "Reported any detected audit" ///
        has_detected_Algorithm_t            "Reported detected algo audit" ///
        has_detected_Inspectors_t     "Reported detected inspector audit" ///
        has_abvmed_er_all_t          "Reported any above-median evasion rate" ///
        has_abvmed_er_Algorithm_t          "Reported above-median evasion rate algo audit" ///
        has_abvmed_er_Inspectors_t   "Reported above-median evasion rate inspector audit" ///
        has_topq_er_all_t          "Reported any top-quartile evasion rate" ///
        has_topq_er_Algorithm_t          "Reported top-quartile  evasion rate algo audit" ///
        has_topq_er_Inspectors_t   "Reported top-quartile  evasion rate  inspector audit" ///
		has_executed_all_t1        "Executed any audit" ///
        has_executed_Algorithm_t1        "Executed algo-selected audit" ///
        has_executed_Inspectors_t1 "Executed inspector-selected audit" ///
        has_detected_all_t1            "Reported any detected audit" ///
        has_detected_Algorithm_t1            "Reported detected algo audit" ///
        has_detected_Inspectors_t1     "Reported detected inspector audit" ///
		has_abvmed_er_all_t1          "Reported any above-median evasion rate" ///
        has_abvmed_er_Algorithm_t1          "Reported above-median evasion rate algo audit" ///
        has_abvmed_er_Inspectors_t1   "Reported above-median evasion rate inspector audit" ///
        has_topq_er_all_t1          "Reported any top-quartile evasion rate" ///
        has_topq_er_Algorithm_t1          "Reported top-quartile  evasion rate algo audit" ///
        has_topq_er_Inspectors_t1   "Reported top-quartile  evasion rate  inspector audit" ///
    ) ///
    mtitles("2018–2019" "2019–2020" "2018 – avg(2019–2020)") ///
    booktabs
	

	* Table: Mean shares of execution / detections in t and t+1 (percent)
esttab bureau_share_1 ///
       bureau_share_2 ///
       bureau_share_3 ///
       using "$output\bureau_share_exec_success_t_t1_success.tex", replace ///
    noobs nonote  ///
    main(mean ) ///
    aux(sd) ///
    order( ///
        share_exec_all_t share_exec_Algorithm_t share_exec_Inspectors_t ///
        share_det_all_t     share_det_Algorithm_t     share_det_Inspectors_t ///
		share_abvmed_er_all_t     share_abvmed_er_Algorithm_t     share_abvmed_er_Inspectors_t ///
		share_topq_er_all_t     share_topq_er_Algorithm_t     share_topq_er_Inspectors_t ///
        share_exec_all_t1 share_exec_Algorithm_t1 share_exec_Inspectors_t1 ///
        share_det_all_t1     share_det_Algorithm_t1     share_det_Inspectors_t1 ///
		share_abvmed_er_all_t1     share_abvmed_er_Algorithm_t1     share_abvmed_er_Inspectors_t1 ///
		share_topq_er_all_t1     share_topq_er_Algorithm_t1     share_topq_er_Inspectors_t1 ///
    ) ///
	 refcat( share_exec_all_t  "Year t"  share_exec_all_t1 "Year t+1" , nolabel) ///
    varlabels( ///
        share_exec_all_t        "Exec rate, all audits" ///
        share_exec_Algorithm_t        "Exec rate, algo audits" ///
        share_exec_Inspectors_t "Exec rate, inspector audits" ///
        share_det_all_t           "Detection rate, all audits" ///
        share_det_Algorithm_t           "Detection rate, algo audits" ///
        share_det_Inspectors_t    "Detection rate, inspector audits" ///
        share_abvmed_er_all_t      "Share of above median ev. rate, all audits" ///
        share_abvmed_er_Algorithm_t      "Share of above median ev. rate, algo audits" ///
        share_abvmed_er_Inspectors_t "Share of above median ev. rate, inspector audits" ///
		share_topq_er_all_t      "Share of top quartile ev. rate, all audits" ///
        share_topq_er_Algorithm_t      "Share of top quartile ev. rate, algo audits" ///
        share_topq_er_Inspectors_t "Share of top quartile ev. rate, inspector audits" ///
        share_exec_all_t1        "Exec rate, all audits" ///
        share_exec_Algorithm_t1        "Exec rate, algo audits" ///
        share_exec_Inspectors_t1 "Exec rate, inspector audits" ///
        share_det_all_t1           "Detection rate, all audits" ///
        share_det_Algorithm_t1           "Detection rate, algo audits" ///
        share_det_Inspectors_t1    "Detection rate, inspector audits" ///
        share_abvmed_er_all_t1      "Share of above median ev. rate, all audits" ///
        share_abvmed_er_Algorithm_t1      "Share of above median ev. rate, algo audits" ///
        share_abvmed_er_Inspectors_t1 "Share of above median ev. rate, inspector audits" ///
		share_topq_er_all_t1      "Share of top quartile ev. rate, all audits" ///
        share_topq_er_Algorithm_t1     "Share of top quartile ev. rate, algo audits" ///
        share_topq_er_Inspectors_t1 "Share of top quartile ev. rate, inspector audits" ///
    ) ///
    mtitles("2018–2019" "2019–2020" "2018 – avg(2019–2020)") ///
    booktabs




