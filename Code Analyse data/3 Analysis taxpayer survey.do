*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   March 2025
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
	if strpos("`c(username)'","alipi") { 										// Alipio's computer
		global rootdir "C:\Users\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}	
	if strpos("`c(username)'","User") {
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

	if strpos("`c(username)'","User") {
		global output "C:\Users\User\Documents\Projects\Senegal-Tax-Audit\Output"
	}

local date: disp  c(current_date)
di "`date'"
set scheme s1color

**********************************
** CONTROL CENTER  				**
**********************************	
	
local data_prep_general = 1 	
local reg_variables = 0
local data_prep_index = 1
local reg_index = 1
local share_cash = 0	

*****************************************************************************************
* 1. Load data and prepare variables	
*****************************************************************************************	

	if `data_prep_general' ==1 { 
	
******************
*Comparable groups
******************
cd "$analysisdata"

*Load data on selection and audits
local date: disp  c(current_date)
di "`date'"

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1
*Drop safety/replacement cases (this is done in all the other estimates)
drop if safeties == 1

*************************
*Exclude firms that appear several times
***********************************
keep if recent == selectionyear 
drop recent


*Generate a variable that is the difference between a notification and the previous one for the same inspector  
sort clusterid datenotification

*Recreate clusterid (some clusters were dropped when we restricted to selection)
drop clusterid 
egen clusterid = group(inspectorclusteryear)

replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

destring sequencing, replace force

***********************************
*Define variables from survey 
***********************************
replace  q24 = . if  q24 == 0

foreach v in q41 q34 q35 q32 q42  {
	
	gen `v'_answered = `v' != . if realise == 1 
	
}

order * , sequential

*************************************** END OF CLEANING **********************************

*************************************
** SURVEY ANALYSIS				   **
*************************************

	**************************************************************
	**** Numbers to Potentially Cite in the paper ****
	**************************************************************
	** Firm characteristics 
	tab q1
	coun if q1 != .		// 669 firms 
	tab q2				// Note on sectors: many firms in "consulting" (same word in French), a bit strange 
	
	** Gen a variable called sectors, that regroups a few subsectors
	gen sector = .
	replace sector = 1 if inlist(q2,0,1,2)
	replace sector = 2 if inlist(q2,3,4,5) 
	replace sector = 3 if inlist(q2,6)
	replace sector = 4 if inlist(q2,7)
	replace sector = 5 if inlist(q2,8)	
	replace sector = 6 if inlist(q2,9)
	replace sector = 7 if inlist(q2,11)	
	replace sector = 8 if inlist(q2,12)		
	replace sector = 9 if inlist(q2,10,13)
	
	label define sectors_label 1 "Primary" 2 "Legal and Financial" 3 "Consulting" 4 "Construction" 5 "Health" 6 "Industry" 7 "Retail" 8 "transport" 9 "Others"	
	
	label variable sector "Consolidated sectors, based on subsectors (question q2)"
	label values sector sectors_label
	
	
	sum q3, d 		// Our median surveyed firm has 11 employees, strange that there is already some attrition (627)
	sum q5, d		// Cash usage: median is 50%, nicely balanced sample if want to use
	
	** Audit frequency
	sum q15, d		// Firms think that full audits happen every 2.7 years and desk audits every 1.5 years
	sum q16, d
	
	** Risk factors perceived by firms 
	foreach v in q18 q19 q20 q21 q22  {
		replace `v' = . if `v' == 0 
		}

	sum q18-q22 
	tab q19
	tab q21
	
	/* (1) Firms clearly think that larger firms are more likely to be audited
			Stats 60% says it increases audit probability, and only 13% says it reduces it (with 26% saying it doesnt matter)
	   (2) Similarly (and different from algorithm) , a small majority of firms think that more profitable firms are more likely to be audited. Stats: 51% more likely, 38% doesnt matter, 11% reduces. 
	   (3) Firms think that exporters are more likely to be audited
	
																	*/
	** Other firm perceptions
	tab q24 		// 73% of those responding think DGIG is already using sophisticated algorithms 
	
	foreach v in q25 q26 q27  {
		replace `v' = . if `v' == 0 
		replace `v' = . if `v' == 3 
		}
		
	sum q25-q27
	
	/* Very similar perceptions for own risk of audit when other firms are audited, based on 
	sector, size, geography -->  around 70% think that it increases their audit risk. 
	Most important factor if  rank is sector > size > geography
																								*/
	******** Last audit	********
	
	tab q30		 // Lenght
	* Question: q30 Lenght of audit --> questions asks about weeks, but all values multiple of 7 
	
	* Inspector performance/characteristics 
	sum q31-q33
	

	******** Corruption pointers and numbers that can be cited ********
	sum q32 // 	Average grade for honesty is 6.4, a point lower than for efficiency
	sum q34, d  // Informal payments perception, mean is 16% of cases, median is zero (and about 25-30% attrition). 
	sum q35   // But only 6% report that it has happened to them
	
	tab q42  // 50% disagree with the statement that knowing people at DGID implies less audits (and 26% agree, 24% neutral)
	
	/* Note: So corruption index, presumably based on the mix of q32 q34 and q42 ? With q32 the most 	direct, followed by q34, last q42									*/ 
	
	
	******** Last questions on agreeing with statements ********
	
	tab q44 // A majority 57% agree that algorithmic selection would be fairer, and only 26% disagree (17% are neutral/no opinion)
	
	** Good number to show that overall DGID is feared and respected, but selection actually lags audits in ratings!
	tab q41 // About efficiency of inspectors (during audits): 65% think they discover all evasion, 27% disagree
	tab q40 // About efficiency of selection: 58% think that more evasion leads to more audits, 37% disagree	
	tab q43 // About efficiency of selection + audit?: 62% think its hard to cheat, 28% disagree
	
	sum q41 q40 q43
	
} 
	
																
	**************************************************************
	**** 2. TABLES	: SET OF REGRESSIONS RUN BY ALIPIO		  ****
	**************************************************************

	if `reg_variables' ==1 {	

	
foreach outcome of varlist evaluation q41 q34 q35 q32 q42 *_answered q24 {

local spec = 0 

*********
*All interviewed firms
*********
*Selected VG cases 	
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Selected CP cases 				
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Selected cases			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*****************************			
*Only conducted audits 
*****************************
*Executed VG cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 1 & y2 == 1, a(inspectorclusteryear) vce(cluster inspectorclusteryear)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed CP cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 0 & y2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if  y2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					
			
}

*Corruption - probability of answering
		
*Corruption measures
#delim ;
esttab rq34_answered_1 rq34_answered_2 rq34_answered_3 rq35_answered_1 rq35_answered_2 rq35_answered_3 rq32_answered_1 rq32_answered_2 rq32_answered_3 rq42_answered_1 rq42_answered_2 rq42_answered_3 
		using "$output\7 regression survey corruption all probability answer.tex",
		order( algorithm overlap random)
		label se keep( algorithm overlap random)
		mtitles("Full audits" "Desk audits" "All"  "Full audits" "Desk audits" "All" "Full audits" "Desk audits" "All"  "Full audits" "Desk audits" "All" ) 
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.3f) se(%5.3f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" horsprogramme "Ad hoc")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr		
	
#delim ;
esttab rq34_answered_4 rq34_answered_5 rq34_answered_6 rq35_answered_4 rq35_answered_5 rq35_answered_6 rq32_answered_4 rq32_answered_5 rq32_answered_6 rq42_answered_4 rq42_answered_5 rq42_answered_6
		using "$output\7 regression survey corruption conducted probability answer.tex",
		order( algorithm overlap random)
		label se keep( algorithm overlap random)
		nomtitles
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.3f) se(%5.3f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" horsprogramme "Ad hoc")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

}

	********************************************************************
	**** 3. TABLES	: SET OF REGRESSIONS RUN BY PIERRE with INDEXES	  ****
	********************************************************************

	if `data_prep_index' ==1 {
	
	*** Gen self-reported went through an audit in three years when program was in place
	 gen selfreported_audit = .
	 replace selfreported_audit = 0 if q1 != .  // firms responding to survey
	 replace selfreported_audit = 1 if q28a >= 2018 & q28a<= 2021 	// CP conducted between 2018 and 2020 
	 replace selfreported_audit = 1 if q29a >= 2018 & q29a<= 2021 	// VG conducted between 2018 and 2020  	 
	 
	*** Only keep the sample of either audited firms from admin data or selfreporting a recent audit
	*** If not it is unclear what we might be capturing with the indexes if there hasnt been a recent audit
	
	** Two options: either we drop anytime selfreported_audit == 0 or we drop only if selfreported_audit = 0 and no audit started
	tab y2 selfreported_audit
	tab y2 selfreported_audit if x2==1	
	drop if selfreported_audit == 0 
	
	/* Goal: build two indexes linked to efficiency and corruption 
	 relative symmetry, each will be based on 3 questions. We will look also at invidiual scores
	 How to build the indexes --> Follow what Anne sent (Anderson 2008)
	
	Note: Alpio had already created an index of "evaluation" (in previous dofile I think)
	
	We want to create two indexes (1) linked to "efficiency" (2) linked to "corruption"
	
	(1) Efficiency: --> quite easy to create index
	
	q31: connaissances techniques ? 0-10. (512 respondants)
	q33: rapidité/efficacité ? 0-10 	(519 respondants)
	
	q41: if agree, from 1-5 			(606 respondants)
	 "Lors d'une vérification générale, les inspecteurs réussissent à découvrir tout le montant dissimulé par l'entreprise contrôlée."
	
	(2) Corruption: attrition well correlated to senstitivity of questions 
	
	q32: honnêteté ? 0-10
	q34: informal payments perception: continuous 0-100, median at 0. (503 respondants)
	Here maybe option to make it more binary we still have 30% who thinks happen in more than 15% of cases (above mean)
		--> also here attrition issue (416 respondants)
	q42: knowing people at DGID means you dont get audited: For index keep 0-5, could make it in a regression binary (584 respondants)
	
	How to deal with differential attrition? Require at least 2 answers? see if anything is being said about this
	
																												*/ 
	** Corruption questions correlations
	 corr q32 q42 // Should be negative 
	 
	 tab q34
	 replace q34 = . if q34 >0 & q34 <1  // Why: one observation is 0.999 meant I dont know wrongly coded
	 
	 gen q34_binary = . 
	 replace q34_binary = 0 if q34 < 15
	 replace q34_binary = 1 if q34 >= 15 & q34 != . 
	 tab q34_binary
	 
	 corr q32 q42 q34_binary		// Ok so table of correlations makes sense 
	 
	 ** For simplicity invert q32 --> becomes degree of disonhesty
	 gen q32_inverted = . 
	 replace q32_inverted = -1*(q32 - 10) if q32 != . 

	corr q32_inverted q42 q34_binary 																							

	** Efficiency questions correlations
	 corr q31 q33 q41		// Ok so table of correlations makes sense 
	 
	 ****************** INDEX CREATION  ******************
	 * Use stata add on SWINDEX: https://ideas.repec.org/c/boc/bocode/s458912.html
	 * Based on Anderson (2008 JASA) 
	 ssc install swindex
	 
	 ** swindex varlist [if] [in], generate(varname) [options]
	 /* Out of safety I will drop the firms not part of survey because I get this warning message
	 Warning: Your index is normalized to the full sample even though the weighting procedure standardized
	the outcomes based on a subsample.				*/ 

	 drop if q1 == . 
	  
	 swindex q32_inverted q42 q34  if q1!=. , generate(index_corruption) fullrescale  displayw 
	 swindex q31 q33 q41 if q1!=. , generate(index_efficiency) fullrescale  displayw 
	 	 
// 	 twoway (scatter index_corruption index_efficiency) /// 
// 	 (lfit index_corruption index_efficiency)
	 
	 corr index_corruption index_efficiency
	 corr q31 q33 q41 q32_inverted q42 q34_binary
	 
	 *** For fun: test cash_intensity and measure of corruption 
	 corr q5 index_corruption
	 reg q5 index_corruption
	 gen ln_employees = ln(1+q3)
	 
	 reg q5 index_corruption ln_employees i.q2	 	// Control for firm size and sector --> Similar strong association  
 }
	 
	**************************************************************
	**** 3.2 REGRESSIONS INDEXES	  						  ****
	**************************************************************
	
	if `reg_index' == 1 {
	
foreach outcome of varlist index_corruption index_efficiency {

local spec = 0 

***************************
*All interviewed firms
***************************
*Selected VG cases 	
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Selected CP cases 				
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 0, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Selected cases			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*****************************			
*Only conducted audits 
*****************************
*Executed VG cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 1 & y2 == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed CP cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 0 & y2 == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if  y2 == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)	
				estadd local N = e(N)	, replace					
		
************************************************			
* Self Reported firms that were audited
************************************************
*Executed VG cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 1 & selfreported_audit == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed CP cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if x2 == 0 & selfreported_audit == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Executed cases
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties horsprogramme if  selfreported_audit == 1, a(selectionyear center) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)					
			estadd local N = e(N)	, replace					

}

 
#delim ;
esttab 	rindex_efficiency_7 rindex_efficiency_8 rindex_efficiency_9 rindex_corruption_7 rindex_corruption_8 rindex_corruption_9 
		using "$output/9_regression_survey_report_audit_new.tex",
		order(algorithm overlap random)
		label se keep( algorithm overlap random)
		nomtitles
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" horsprogramme "Ad hoc")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr	 

			
#delim ;
esttab 	rindex_efficiency_4 rindex_efficiency_5 rindex_efficiency_6 rindex_corruption_4 rindex_corruption_5 rindex_corruption_6 
		using "$output/9_regression_survey_conducted_new.tex",
		order(algorithm overlap random)
		label se keep( algorithm overlap random)
		nomtitles
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" horsprogramme "Ad hoc")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr		


*** Numbers cited in the paper (Section 6.3)
	count 
	local count = `r(N)'
	
foreach outcome in q34 q42 {	
	sum `outcome'
	local resp_rate	= `r(N)'/`count'		// Response rate
	display `resp_rate'
}

	sum q31 q32 q33	
	
}	









