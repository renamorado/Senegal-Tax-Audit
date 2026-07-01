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

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

local date: disp  c(current_date)
di "`date'"
set scheme s1color

******************************************
******************************************
*1 MAIN RESULTS
******************************************
******************************************
*Load dataset for analysis

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

*****************************
*Run regressions
*****************************
foreach outcome in y2 y3 y4 y6 y7 y8 {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}

*Specification for VG with bureau x year FE
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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

*Specification for VG with bureau x year FE, Deciles of turnover and activity groups
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1, a(controlbureauannee activity_group decileturnover) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "Yes"			
			estadd local activity "Yes"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Specification for VG with bureau x year FE and normalized sequencing
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties norm_sequencing  if x2 == 1, a(controlbureauannee) vce(robust)
			
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

*Specification for CP with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(controlbureauannee) vce(robust)
			
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

*Specification for CP with inspector x year FE 
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

*Specification for CP with inspector x year FE , Deciles of turnover and activity groups			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear activity_group decileturnover) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "Yes"			
			estadd local activity "Yes"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Specification for CP with inspector x year FE , normalized sequencing			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties norm_sequencing   if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

*Specification for CP and VG with inspector x year FE			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome'  algorithm overlap random safeties, a(inspectorclusteryear) vce(robust)
		
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

**********
*Controlling for sequencing
**********
*Specification for VG with bureau x year FE
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties i.quartile_sequencing if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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

*Specification for CP with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties i.quartile_sequencing if x2 == 0, a(controlbureauannee) vce(robust)
			
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

*Specification for CP with inspector x year FE 
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties i.quartile_sequencing if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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
	
	
**********
*Controlling for size of team and years of experience
**********
*Specification for CP with bureau x year FE
local ++spec		

			eststo r`outcome'_1_experience2: reghdfe `outcome' algorithm overlap random safeties y16 yearsexperience if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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
			estadd local N = e(N), replace		
			
local ++spec		
	
			eststo r`outcome'_1_experience: reghdfe `outcome' algorithm overlap random safeties y16 yearsexperience if x2 == 0, a(controlbureauannee) vce(robust)
			
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

*Specification for VG with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_2_experience: reghdfe `outcome' algorithm overlap random safeties y16 yearsexperience if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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

*Summary results
#delim ;
esttab  ry3_2_experience  ry3_1_experience  ry3_1_experience2 ry4_2_experience  ry4_1_experience  ry4_1_experience2
		using "$output\1 regression main outcomes control experience.tex",
		order( algorithm overlap random y16 yearsexperience)
		label se keep( algorithm overlap random y16 yearsexperience)
		mtitles("Full audits"  "Desk audits" "Desk audits" "Full audits"   "Desk audits" "Desk audits" "Full audits" "Desk audits" "Desk audits") 
		s(taxcenteryear inspectoryear  N r2 pp, label("Tax center x Year" "Inspector x Year" "\hline N" "R2" "Mean outcome")) 
		b(%5.2f) se(%5.2f)
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" y16 "Number agents" yearsexperience "Years experience")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Summary results controlling for placement FE
#delim ;
esttab ry2_9 ry2_10 ry2_11 ry3_9 ry3_10 ry3_11 ry4_9 ry4_10 ry4_11 
		using "$output\1 regression main outcomes placement fe.tex",
		order( algorithm overlap random )
		b(%5.2f) se(%5.2f)
		label se keep( algorithm overlap random)
		mtitles("Full audits"  "Desk audits" "Desk audits" "Full audits"   "Desk audits" "Desk audits" "Full audits" "Desk audits" "Desk audits") 
		s(taxcenteryear inspectoryear  N r2 pp, label("Tax center x Year" "Inspector x Year" "\hline N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr


*Summary results without the desk audits with bureau FE specification
#delim ;
esttab ry2_1 ry2_4 ry2_5  ry3_1 ry3_4 ry3_5 ry4_1 ry4_4 ry4_5
		using "$output\1 regression main outcomes summarized.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		b(%5.2f) se(%5.2f)
		mtitles("Full audits"  "Desk audits" "Desk audits" "Full audits"   "Desk audits" "Desk audits" "Full audits" "Desk audits" "Desk audits") 
		s(taxcenteryear inspectoryear  N r2 pp, label("Tax center x Year" "Inspector x Year" "\hline N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr


#delim ;
esttab ry6_1  ry6_4 ry6_5  ry7_1 ry7_4 ry7_5
		using "$output\1 regression evasion rates.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		b(%5.2f) se(%5.2f)
		mtitles("Full audits" "Desk audits"  "Desk audits" "Full audits" "Desk audits"  "Desk audits") 
		s(taxcenteryear inspectoryear  N r2 pp, label("Tax center x Year" "Inspector x Year" "\hline N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

**********************************
*Regression ITT
**********************************
preserve 

foreach k in reghdfe ppmlhdfe {

		foreach outcome in y2 y3 y4  {

		local spec = 0 

		replace `outcome' = 0 if y2 == 0 

		*Specification for CP with bureau x year FE
		local ++spec		

					eststo `k'`outcome'_`spec': `k' `outcome' algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
					
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

		*Specification for CP with bureau x year FE
		local ++spec		

					eststo `k'`outcome'_`spec': `k' `outcome' algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)
				
					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "Yes"
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

}
restore

*Summary results without the desk audits with bureau FE specification
#delim ;
esttab reghdfey2_1 reghdfey2_2 reghdfey3_1 reghdfey3_2 reghdfey4_1 reghdfey4_2
		using "$output\1 regression main outcomes summarized ITT.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		b(%5.2f) se(%5.2f)
mtitles("Full audits" "Desk audits"  "Full audits" "Desk audits"  "Full audits" "Desk audits" ) 
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		fragment booktabs 
		substitute(\_ _)
	;
#delim cr

*Summary results without the desk audits with bureau FE specification
#delim ;
esttab ppmlhdfey2_1 ppmlhdfey2_2 ppmlhdfey3_1 ppmlhdfey3_2 ppmlhdfey4_1 ppmlhdfey4_2
		using "$output\1 regression main outcomes summarized ITT ppml.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		nomtitles nonumber
		b(%5.2f) se(%5.2f)
		s(N r2_p pp, label("N" "Pseudo-R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

******************************
*Robustness adding characteristics of cases and inspectors, including inspector skill
******************************

*Estimate inspector F.E. using desk audits 
eststo r`outcome'_`spec': reghdfe y3 algorithm overlap random safeties if x2 == 0, noconstant a(inspectorclusteryear, savefe) vce(robust)
bys inspectorclusteryear: egen fe_y3 = max(__hdfe1__) if x2 == 0 
bys bureau_detailed: egen meanfe_y3 = mean(fe_y3) if x2 == 0 
replace fe_y3 = fe_y3 - meanfe_y3
drop meanfe_y3

bys verificateur1: egen skill = mean(fe_y3) if x2 == 0 

*Assign skill to case
forvalues x = 1/8 {
	
	gen temp_inspector = verificateur1 if x2 == 0 //Create a variable that reproduces the names of inspectors for desk audits 
	replace temp_inspector = verificateur`x' if x2 == 1 //Complement the variable with the names of the full audits inspectors
	bys temp_inspector: egen maxskill`x' = max(skill) //Obtain the skill corresponding to that agent 
	drop temp_inspector
	
}

egen skill_case = rowmax(maxskill*)
egen skill_case_mean = rowmean(maxskill*)

*Regressions 
foreach outcome in y3 y4 {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}

local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap safeties  L1turnover if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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

*Specification for VG with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap safeties L1turnover y16  if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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
	
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap safeties L1turnover y16 maxyearsexperience if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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
	
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap safeties L1turnover y16 if x2 == 1 & e(sample), a(inspectorclusteryear) vce(robust)
			
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
			
*Specification for VG with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap safeties L1turnover y16 skill_case if x2 == 1, a(inspectorclusteryear) vce(robust)
			
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
			estadd local N = e(N), replace	

}

#delim ;
esttab ry3_1 ry3_2 ry3_4 ry3_3  ry4_1 ry4_2 ry4_4  ry4_3 
		using "$output\1 regression outcomes robust case inspector char.tex",
		order( algorithm overlap )
		label se keep( algorithm overlap L1turnover y16 maxyearsexperience)
		b(%5.2f) se(%5.2f)
		nomtitles 
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" L1turnover "Lagged Log(Turnover)" y16 "N. Agents" maxyearsexperience "Max. Years Experience" skill_case "Max. Ability")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*******************************************************
*******************************************************
*Compute Inspector F.E.
*******************************************************
*******************************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

foreach outcome in y2 y3 y4 {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}

*Specification for CP with bureau x year FE
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, noconstant a(inspectorclusteryear, savefe) vce(robust)
			
			bys inspectorclusteryear: egen fe_`outcome' = max(__hdfe1__) if x2 == 0 
			bys bureau_detailed: egen meanfe_`outcome' = mean(fe_`outcome') if x2 == 0 
			replace fe_`outcome' = fe_`outcome' - meanfe_`outcome'
			drop meanfe_`outcome'
			
			global coef`outcome' = _b[algorithm]
}

bys inspectorclusteryear: gen n = _n

*y2
egen rank = group(fe_y2 inspectorclusteryear)
sum  fe_y2 if n == 1 & fe_y2 != . & x2 == 0, d
	local p25 = r(p25)
	local p50 = r(p50)
	local p75 = r(p75)
	local p25p = r(p25) + 0.05
	local p50p = r(p50) + 0.05
	local p75p = r(p75) + 0.05
	
*Discover the minimum distance in percentiles that corresponds to the algorithm coefficient 
sum rank, d
local max = `r(max)'

matrix dist = J(`max', 2, 0)

forvalues x = 1/`max' {
		
	qui sum fe_y2 if rank == `x' 
	local j = r(mean)

	matrix dist[`x', 1] = `x'

	local dif = 0 
	local y = `x' + 1

		while abs(`dif') < abs($coefy2) {
				
			local y = `y' + 1
			qui sum fe_y2 if rank == `y' 
			local jj = r(mean)
			
			local dif = `j' - `jj'
			
		}
		
	matrix dist[`x', 2] = `y'	
	
}

svmat dist
gen delta = dist2 - dist1
egen mindelta = min(delta)
sum mindelta
gen mindistance = delta == mindelta

tw bar fe_y2 rank if n == 1 & fe_y2 != .,  xlabel("") yline(`p25') yline(`p50') yline(`p75') 
*text(`p75p' 0 "75th percentile", place(a)) text(`p50p' 0 "50th percentile", place(a)) text(`p25p' 0 "25th percentile", place(a)) xtitle("") ytitle("")

graph export "$output\1 fixed effects CP y2.pdf", as(pdf) replace

drop rank

*y3
egen rank = group(fe_y3 inspectorclusteryear)
sum  fe_y3 if n == 1 & fe_y3 != . & x2 == 0, d
	local p25 = r(p25)
	local p50 = r(p50)
	local p75 = r(p75)
	local p25p = r(p25) + 0.05
	local p50p = r(p50) + 0.05
	local p75p = r(p75) + 0.05
	
tw bar fe_y3 rank if n == 1 & fe_y3 != ., xlabel("") yline(`p25') yline(`p50') yline(`p75') xtitle("") ytitle("")

graph export "$output\1 fixed effects CP y3.pdf", as(pdf) replace

drop rank

*y4
egen rank = group(fe_y4 inspectorclusteryear)
sum  fe_y4 if n == 1 & fe_y4 != . & x2 == 0, d
	local p25 = r(p25)
	local p50 = r(p50)
	local p75 = r(p75)
	local p25p = r(p25) + 0.05
	local p50p = r(p50) + 0.05
	local p75p = r(p75) + 0.05
	
	
tw bar fe_y4 rank if n == 1 & fe_y4 != ., xlabel("") yline(`p25') yline(`p50') yline(`p75') xtitle("") ytitle("")

graph export "$output\1 fixed effects CP y4.pdf", as(pdf) replace

drop rank

*******************************************************
*******************************************************
*Lee Bounds
*Obs: the code below implements Lee Bounds computations using the share of missing observations for the algorithm and non algorithm cases. 
*******************************************************
*******************************************************

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

replace y4 = . if y3 == 0
replace q30 = . if y2 == 0

foreach y in y3 y4 y16 q30 y19 y8 {
	
	*Generate variable for missing observation
	gen nonmissing`y' = `y' != .
	
	if "`y'" != "y3" &  "`y'" != "y16" {
	replace nonmissing`y' = . if y2 == 0
	} 
	
	*Compute the share of non-missing information by list, type of audit, and selection method
	bys inspectorclusteryear controle algorithm: egen share_data`y' = mean(nonmissing`y') if algorithm == 1 
	bys inspectorclusteryear controle: egen share`y'alg = max(share_data`y')

	bys inspectorclusteryear controle algorithm: egen total_data`y' = sum(nonmissing`y') if algorithm == 1 
	bys inspectorclusteryear controle: egen total_data`y'alg = max(total_data`y')	
	
	drop share_data`y' total_data`y'
	
	bys inspectorclusteryear controle algorithm: egen share_data`y' = mean(nonmissing`y') if algorithm == 0 
	bys inspectorclusteryear controle: egen share`y'insp = max(share_data`y')

	bys inspectorclusteryear controle algorithm: egen total_data`y' = sum(nonmissing`y') if algorithm == 0 
	bys inspectorclusteryear controle: egen total_data`y'insp = max(total_data`y')		
	
	drop share_data`y' total_data`y'
	
	*Compute the difference in attrition (additional inspector cases relative to algorithm cases)
	gen difference`y' = share`y'insp - share`y'alg

	*Check how many variables must be dropped 
	gen drop`y' = round(difference`y'*total_data`y'insp, 1) if difference`y' > 0
	replace drop`y' = -round(difference`y'*total_data`y'alg, 1) if difference`y' < 0 
}

*Generate random variable to resolve ties
set seed 1238945
gen randomvariable = runiform()

*********************
*COMPUTE LEE BOUNDS
*********************

matrix lee = J(12,5,0)
matrix rownames lee  = "y3 desk" "y3 full" "y4 desk" "y4 full"  "y16 desk" "y16 full" "q30 desk" "q30 full"  "y19 desk" "y19 full" "y8 desk" "y8 full"
matrix colnames lee = "lower" "lower t"  "upper" "upper t" "N"

local r = 0 
foreach y in y3 y4 y16 q30 y19 y8 {
*Create samples for upper and lower bounds   

	*Upper bound: remove the high values of the inspector group 
	gen sample_upper = 1
	
	gsort inspectorclusteryear -`y' randomvariable 
	by inspectorclusteryear: gen n = _n 

	replace sample_upper = 0 if algorithm == 0 & difference`y' > 0 & drop`y' >= n //When more inspector cases were done, exclude the higher cases of the inspector
	
	drop n 
	
	gsort inspectorclusteryear `y' randomvariable 
	by inspectorclusteryear: gen n = _n 
	
	replace sample_upper = 0 if algorithm == 1 & difference`y' < 0 & drop`y' >= n //When more algorithm cases were done, exclude the lower cases of the algorithm

	drop n
	
	*Lower bound: remove the low values of the inspector group 
	gen sample_lower = 1 
	
	gsort inspectorclusteryear `y' randomvariable 
	by inspectorclusteryear: gen n = _n 

	replace sample_lower = 0 if algorithm == 0 & difference`y' > 0 & drop`y' >= n //When more inspector cases were done eliminate the bottom

	drop n
	
	gsort inspectorclusteryear -`y' randomvariable 
	by inspectorclusteryear: gen n = _n 

	replace sample_lower = 0 if algorithm == 1 & difference`y' < 0 & drop`y' >= n //When more alg cases were done eliminate the top
	
	drop n
	
	*Re run regressions and store estimates
	local ++r
	eststo `outcome'_`spec': reghdfe `y' algorithm overlap random if x2 == 0 & sample_lower == 1, a(inspectorclusteryear) vce(robust)
		matrix lee[`r', 1] = _b[algorithm]
		matrix lee[`r', 2] = _b[algorithm]/_se[algorithm]
		
	eststo `outcome'_`spec': reghdfe `y' algorithm overlap random  if x2 == 0 & sample_upper  == 1, a(inspectorclusteryear) vce(robust)
		matrix lee[`r', 3] = _b[algorithm]
		matrix lee[`r', 4] = _b[algorithm]/_se[algorithm]
		
	matrix lee[`r', 5] = e(N)

	local ++r
	eststo `outcome'_`spec': reghdfe `y' algorithm overlap random if x2 == 1 &  sample_lower  == 1, a(inspectorclusteryear) vce(robust)
		matrix lee[`r', 1] = _b[algorithm]
		matrix lee[`r', 2] = _b[algorithm]/_se[algorithm]
		
	eststo `outcome'_`spec': reghdfe `y' algorithm overlap random  if x2 == 1 & sample_upper == 1, a(inspectorclusteryear) vce(robust)
		matrix lee[`r', 3] = _b[algorithm]
		matrix lee[`r', 4] = _b[algorithm]/_se[algorithm]
		
		matrix lee[`r', 5] = e(N)

		
	*Re run regressions
	drop sample_lower sample_upper
	
}
	
esttab matrix(lee)

*Edit the tex file to add the row with Lee Bounds 

	*Add the stars referring to the significance of the results
	forvalues x = 1/4 {
		
		local lowlee`x' = lee[`x',1]
		local lowlee`x': display %3.2f 	 `lowlee`x'' 

		local highlee`x' = lee[`x',3]
		local highlee`x': display %3.2f `highlee`x'' 		
		
		local lowt`x' = lee[`x',2]
		local low`x' = ""
		
		local low`x' = cond(abs(`lowt`x'')<1.28, "", cond(abs(`lowt`x'')>1.28 & abs(`lowt`x'') < 1.96, "*", cond(abs(`lowt`x'')>1.96 & abs(`lowt`x'') < 2.33, "**", cond(abs(`lowt`x'')>2.33, "***", "")	)))

		local hight`x' = lee[`x',4]
		local high`x' = ""
		
		local high`x' = cond(abs(`hight`x'')<1.28, "", cond(abs(`hight`x'')>1.28 & abs(`hight`x'') < 1.96, "*", cond(abs(`hight`x'')>1.96 & abs(`hight`x'') < 2.33, "**", cond(abs(`hight`x'')>2.33, "***", "")	)))

	display "Significance of lower bound is `low`x''"
	display "Significance of higher bound is `high`x''"	
	display "lower bound is `lowlee`x''"
	display "higher bound is `highlee`x''"
	
	}

*Create line to be added to latex (notice that the order of the table is Full Audits first then Desk Audits, )
local newline " & & & & [`lowlee2' `low2',`highlee2'`high2'] & & [`lowlee1'`low1',`highlee1'`high1'] & [`lowlee4'`low4',`highlee4'`high4'] & & [`lowlee3'`low3',`highlee3'`high3'] \BS\BS "

display "`newline'"

*** INCLUDE THE LEE BOUNDS IN THE LATEX FILE
filefilter "$output\1 regression main outcomes summarized.tex" "$output\1 regression main outcomes with Lee.tex", from("Inspectors x Overlap") to("`newline' Inspectors x Overlap")	replace

*******************************************************
*******************************************************
*Robustness checks as we add controls
*******************************************************
*******************************************************

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

*Specification for VG with bureau x year FE
local outcome y2
local spec = 0 

foreach outcome in y2 y3 y4  {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
	replace `outcome' = . if y3 == 0 
}

		local spec = 0 
		
		local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "No"
			estadd local prof "No"
			estadd local prod "No"			
			estadd local exp "No"	
			estadd local char "No"	
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "Yes"
			estadd local prof "No"
			estadd local prod "No"			
			estadd local char "No"	
			estadd local exp "No"	
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "Yes"
			estadd local prof "Yes"
			estadd local prod "No"			
			estadd local char "No"	
			estadd local exp "No"	
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

local ++spec					
			
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "Yes"
			estadd local prof "Yes"
			estadd local prod "Yes"			
			estadd local char "No"	
			estadd local exp "No"	
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
			
local ++spec		
			
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "Yes"
			estadd local prof "Yes"
			estadd local prod "Yes"			
			estadd local char "Yes"	
			estadd local exp "No"	
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
			
local ++spec		
			
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage y16 yearsexperience if x2 == 1, a(inspectorclusteryear) vce(robust)
			
			estadd local turn "Yes"
			estadd local prof "Yes"
			estadd local prod "Yes"			
			estadd local char "Yes"	
			estadd local exp "Yes"	
			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace				

}

#delim ;
esttab ry2_1 ry2_2 ry2_3 ry2_4 ry2_5
		using "$output\1 regression execution controls.tex",
		order( algorithm)
		label se keep( algorithm)
		nomtitles
		b(%5.3f) se(%5.3f)
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr		

#delim ;
esttab ry3_1 ry3_2 ry3_3 ry3_4 ry3_5 
		using "$output\1 regression detection controls.tex",
		order( algorithm)
		label se keep( algorithm)
		nomtitles
		b(%5.3f) se(%5.3f)		
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr	

#delim ;
esttab ry4_1 ry4_2 ry4_3 ry4_4 ry4_5 
		using "$output\1 regression evasion controls.tex",
		order( algorithm)
		label se keep( algorithm)
		b(%5.3f) se(%5.3f)
		nomtitles
		s(turn prof prod char  N r2 pp, label("Turnover" "Profit rate" "Productivity" "Firm char." "\hline N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr		
	
	eststo rcoefficientsalg: reghdfe y2 algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage if x2 == 1 & algorithm == 1, a(inspectorclusteryear) vce(robust)	
	eststo rcoefficientsins: reghdfe y2 algorithm overlap random safeties L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage if x2 == 1 & algorithm == 0, a(inspectorclusteryear) vce(robust)	

#delim ;
esttab rcoefficientsalg rcoefficientsins
		using "$output\1 regression execution controls coefficients.tex",
		order( L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage)
		label se keep( L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu distance durationcar firmage)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2, label("N" "R2")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(L1turnover "L1 turnover" L1turnoversq "L1 turnover sq."L1turnovercu "L1 turnover cu." L1profitrate "L1 profit rate" L1profitratesq "L1 profit rate sq" L1profitratecu "L1 profit rate cu" L1productivity "L1 productivity" L1productivitysq "L1 productivity sq" L1productivitycu "L1 productivity cu" distance "Distance km" durationcar "Distance min" firmage "Firm's age")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*******************************************************
*******************************************************
*Robustness checks and figures
*******************************************************
*******************************************************

use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1


*Define robustness checks

	*i) lists with equal number of algorithm and discretionary cases
	bys inspectorclusteryear: egen totalalg = total(algorithm)
	bys inspectorclusteryear: egen totaldisc = total(dgid)
	bys inspectorclusteryear: egen totalover = total(overlap)

	gen equalnumber = totalalg == totaldisc
	replace equalnumber = 1 if totalalg == totaldisc - totalover
	
	gen equalnumberstrict = totalalg == totaldisc
	gen equalnumberadvantage = totalalg <= totaldisc

	*ii) drop LTU
	
	*iii) keep only 2019
	
	*iv) cluster s.e. at bureau level

	*v) drop overlap cases for each cluster (only for 2019 and 2020)
	gen equalnumberstrictest = .
	
	bys cluster2019 inspectorclusteryear: egen totaloverlap2019 = total(overlap) if selectionyear == 2019
	bys cluster2020 inspectorclusteryear: egen totaloverlap2020 = total(overlap) if selectionyear == 2020

	cap drop n
	sort cluster2019 inspectorclusteryear riskscore2019
	by cluster2019 inspectorclusteryear: gen n = _n
	
	replace equalnumberstrictest = 1 if n > totaloverlap2019 & n != . & selectionyear == 2019
	
	cap drop n
	sort cluster2020 inspectorclusteryear riskscore2020
	by cluster2020 inspectorclusteryear: gen n = _n	
	
	replace equalnumberstrictest = 1 if n > totaloverlap2020 & n != . & selectionyear == 2020

	replace equalnumberstrictest = 1 if selectionyear == 2018 & overlap == 0 & (dgid == 1 | algorithm == 1) & random == 0 
	
	bys inspectorclusteryear: egen totalalgstr = total(algorithm) if equalnumberstrictest == 1
	bys inspectorclusteryear: egen totaldiscstr = total(dgid) if equalnumberstrictest == 1

	replace equalnumberstrictest = 0 if totalalgstr != totaldiscstr & equalnumberstrictest == 1 
	drop totaldiscstr totalalgstr
	
*Matrix of results (for figure)
matrix resultsVG = J(21, 5, 0)
matrix colnames resultsVG = "coef" "lb" "ub" "iteration" "x"

matrix resultsCP = J(21, 5, 0)
matrix colnames resultsCP = "coef" "lb" "ub" "iteration" "x"

*Specifications
local subsample0 ""	
local se0 "robust"	

local subsample1 ""	
local se1 "cluster bureau"

local subsample2 "& equalnumberstrictest == 1"	
local se2 "robust"	

local subsample3 "& equalnumberstrict == 1"	
local se3 "robust"

local subsample4 "& equalnumberadvantage == 1"	
local se4 "robust"	

local subsample5 `"& bureau != "DGE""'	
local se5 "robust"

local subsample6 "& selectionyear == 2019"	
local se6 "robust"

local row = 0 
local robustness = -1 

*Loop for specifications
forvalues r = 0/6 {	

local x = 0
local ++robustness 

estimates drop _all

	*Loop for outcomes
	foreach outcome in y2 y3 y4  {

	local ++row 
	local ++x
	local spec = 0 

	if "`outcome'" != "y2" {
		replace `outcome' = . if y2 == 0 
		drop if safeties == 1
	}
	if "`outcome'" == "y4" {
		replace `outcome' = . if `outcome' == 0 
	}

	*Specification for VG with bureau x year FE
	local ++spec		

				eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1 `subsample`r'', a(controlbureauannee) vce(`se`r'')
				
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

				*Populate matrix with main results
				matrix resultsVG[`row', 1] = _b[algorithm]
				matrix resultsVG[`row', 2] = _b[algorithm] - invttail(e(df_r),0.025)*_se[algorithm] 
				matrix resultsVG[`row', 3] = _b[algorithm] + invttail(e(df_r),0.025)*_se[algorithm]
				matrix resultsVG[`row', 4] = `robustness'
				matrix resultsVG[`row', 5] = `x'
				
	*Specification for CP with bureau x year FE 
	local ++spec		
		
				eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0 `subsample`r'', a(controlbureauannee) vce(`se`r'')
				
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

	*Specification for CP with inspector x year FE 
	local ++spec		

				eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0 `subsample`r'', a(inspectorclusteryear) vce(`se`r'')
				
				estadd local taxcenteryear "Yes"
				estadd local inspectoryear "Yes"
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
			
				*Populate matrix with main results
				matrix resultsCP[`row', 1] = _b[algorithm]
				matrix resultsCP[`row', 2] = _b[algorithm] - invttail(e(df_r),0.025)*_se[algorithm] 
				matrix resultsCP[`row', 3] = _b[algorithm] + invttail(e(df_r),0.025)*_se[algorithm]
				matrix resultsCP[`row', 4] = `robustness'
				matrix resultsCP[`row', 5] = `x'
		
	}

*Output table
#delim ;
esttab ry2*  ry3* ry4*
		using "$output\1 regression robustness `r'.tex",
		order( algorithm overlap random )
		b(%5.2f) se(%5.2f)
		label se keep( algorithm overlap random)
		mtitles("Full audits" "Desk audits"  "Desk audits" "Full audits" "Desk audits"  "Desk audits" "Full audits" "Desk audits"  "Desk audits") 
		s(taxcenteryear inspectoryear  N r2 pp, label("Tax center x Year" "Inspector x Year" "\hline N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

}

*Figure with all results for VG
cap drop resultsVG*
svmat resultsVG
cap drop counter
sort resultsVG5 resultsVG4
bys resultsVG5: gen counter = _n 
replace counter = counter + 8 if resultsVG5 == 2
replace counter = counter + 16 if resultsVG5 == 3
replace counter = counter + 1 if resultsVG4 == 0
replace counter = . if resultsVG5 == .

set scheme s1color

#delim; 
tw 
(scatter resultsVG1 counter if resultsVG4 == 0 & counter < 17, mcolor(black) msymbol(circle) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 1 & counter < 17, mcolor(black) msymbol(diamond) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 2 & counter < 17, mcolor(black) msymbol(triangle) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 3 & counter < 17, mcolor(black) msymbol(square) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 4 & counter < 17, mcolor(black) msymbol(plus) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 5 & counter < 17, mcolor(black) msymbol(X) yaxis(1))
(scatter resultsVG1 counter if resultsVG4 == 6 & counter < 17, mcolor(black) msymbol(circle_hollow) yaxis(1))
(rcap resultsVG2 resultsVG3 counter  if counter < 17, lwidth(thin) lcolor(black) yaxis(1))

(scatter resultsVG1 counter if resultsVG4 == 0 & counter > 17, mcolor(black) msymbol(circle) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 1 & counter > 17, mcolor(black) msymbol(diamond) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 2 & counter > 17, mcolor(black) msymbol(triangle) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 3 & counter > 17, mcolor(black) msymbol(square) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 4 & counter > 17, mcolor(black) msymbol(plus) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 5 & counter > 17, mcolor(black) msymbol(X) yaxis(2))
(scatter resultsVG1 counter if resultsVG4 == 6 & counter > 17, mcolor(black) msymbol(circle_hollow) yaxis(2))
(rcap resultsVG2 resultsVG3 counter  if counter > 17, lwidth(thin) lcolor(black) yaxis(2))

,
legend(off)
xlabel(4 `" "{bf:P(execution)}" "{it:(left axis)}" "'  12  `" "{bf:P(detection)}" "{it:(left axis)}" "'  20  `" "{bf:log(evasion)}" "{it:(right axis)}" "' )
xtitle("")
title("A: Full Audits")
legend(order(2  "Baseline (SEs clustered by tax office, SEs robust)" 3 "Equal number of inspector and algorithm cases (definition 1)" 4 "Equal number of inspector and algorithm cases (definition 2)" 5 "Equal or lower number of algorithm cases" 6 "Excluding LTU" 7  "Only 2019 selection") c(1))
ylabel(-0.3 (0.1) 0.3, axis(1)) ylabel(-2 (0.5) 2, axis(2))
yline(0, lcolor(gray%50))
xline(8.5, lcolor(gray%50) lwidth(thin)) xline(16.5, lcolor(gray%50) lwidth(thin))
saving("VG.gph", replace) 
;
#delim cr

*graph export "$output\1 summary results VG.pdf", as(pdf) replace	

*Figure with all results for CP
cap drop resultsCP*
svmat resultsCP
cap drop counter
sort resultsCP5 resultsCP4
bys resultsCP5: gen counter = _n 
replace counter = counter + 8 if resultsCP5 == 2
replace counter = counter + 16 if resultsCP5 == 3
replace counter = counter + 1 if resultsCP4 == 0
replace counter = . if resultsCP5 == .

set scheme s1color

#delim; 
tw 
(scatter resultsCP1 counter if resultsCP4 == 0 & counter < 17, mcolor(black) msymbol(circle) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 1 & counter < 17, mcolor(black) msymbol(diamond) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 2 & counter < 17, mcolor(black) msymbol(triangle) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 3 & counter < 17, mcolor(black) msymbol(square) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 4 & counter < 17, mcolor(black) msymbol(plus) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 5 & counter < 17, mcolor(black) msymbol(X) yaxis(1))
(scatter resultsCP1 counter if resultsCP4 == 6 & counter < 17, mcolor(black) msymbol(circle_hollow) yaxis(1))
(rcap resultsCP2 resultsCP3 counter  if counter < 17, lwidth(thin) lcolor(black) yaxis(1))

(scatter resultsCP1 counter if resultsCP4 == 0 & counter > 17, mcolor(black) msymbol(circle) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 1 & counter > 17, mcolor(black) msymbol(diamond) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 2 & counter > 17, mcolor(black) msymbol(triangle) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 3 & counter > 17, mcolor(black) msymbol(square) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 4 & counter > 17, mcolor(black) msymbol(plus) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 5 & counter > 17, mcolor(black) msymbol(X) yaxis(2))
(scatter resultsCP1 counter if resultsCP4 == 6 & counter > 17, mcolor(black) msymbol(circle_hollow) yaxis(2))
(rcap resultsCP2 resultsCP3 counter  if counter > 17, lwidth(thin) lcolor(black) yaxis(2))

,
legend(order(2  "Baseline (SEs clustered by tax office, SEs robust)" 3 "Equal number of inspector and algorithm cases (definition 1)" 4 "Equal number of inspector and algorithm cases (definition 2)" 5 "Equal or lower number of algorithm cases" 6 "Excluding LTU" 7  "Only 2019 selection") c(1))
xlabel(4 `" "{bf:P(execution)}" "{it:(left axis)}" "'  12  `" "{bf:P(detection)}" "{it:(left axis)}" "'  20  `" "{bf:log(evasion)}" "{it:(right axis)}" "' )
xtitle("")
title("B: Desk Audits")
yline(0, lcolor(gray%50))
xline(8.5, lcolor(gray%50) lwidth(thin)) xline(16.5, lcolor(gray%50) lwidth(thin))
ylabel(-0.3 (0.1) 0.3, axis(1)) ylabel(-2 (0.5) 2, axis(2))
saving("CP.gph", replace) 
;
#delim cr

graph export "$output\1 summary results CP.pdf", as(pdf) replace

grc1leg2 VG.gph CP.gph, legendfrom(CP.gph)  c(1) ysize(9) xsize(6.5)
graph export "$output\1 summary results CP and VG.pdf", as(pdf) replace	

erase VG.gph
erase CP.gph

*******************************************************
*******************************************************
*Analyse Characteristics of Selected firms 
*******************************************************
*******************************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************

*Generate a variable that is the difference between a notification and the previous one for the same inspector  
replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

**********************************
*List of outcomes to be investigated
**********************************
foreach v of varlist *filed* {
	replace `v' = 0 if `v' == .
}

*Turn to missing if no filing 
forvalues y = 2014/2020 {
	egen filesomething = rowmax(*filed`y')
	replace turnover`y' = . if filesomething == 0
	drop filesomething
	
	replace profitrate`y' = . if IS_filed`y' == 0
	replace payroll`y' = . if RAS_IRPP_filed`y' == 0 
}

*Turnover one year before audit 
gen turnover_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace turnover_L1 = turnover`L1' if selectionyear == `y'
	
}

*Profit one year before audit
gen profitrate_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace profitrate_L1 = profitrate`L1' if selectionyear == `y'
	
}

*Payroll one year before audit
gen payroll_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace payroll_L1 = payroll`L1' if selectionyear == `y'
	replace payroll_L1 = . if RAS_IRPP_filed`L1' == 0 & selectionyear == `y'	
	
}

*Firm traded with foreign countries one year before audit
gen trade_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	egen TRADE`L1' = rowmax(IMP_filed`L1' EXP_filed`L1')
	replace trade_L1 = TRADE`L1' if selectionyear == `y'
	
}

*Firm received money from governoment one year before audit
gen procurement_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace procurement_L1 = MAN_filed`L1' if selectionyear == `y'
	
}

*Material costs
gen materialcosts_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace materialcosts_L1 = material_inp`L1' if selectionyear == `y'
	
}

*Drop outliers
sum distance, d 
replace distance = . if distance >= `r(p99)' & distance != . 
gen logdistance  = log(distance)

sum materialcosts_L1, d 
replace materialcosts_L1 = `r(p99)' if materialcosts_L1 >= `r(p99)' & materialcosts_L1 != . 
gen logmaterialcosts_L1 = log(materialcosts_L1 + 1)

sum durationcar, d 
replace durationcar = . if durationcar >= `r(p99)' & durationcar != . 
cap drop logdurationcar
gen logdurationcar = log(durationcar)

sum durationcar, d 
gen longduration = durationcar >= `r(p50)' & durationcar != . 

sum payroll_L1, d 
replace payroll_L1 = `r(p99)' if payroll_L1 >= `r(p99)' & payroll_L1 != . 
gen logpayroll_L1 = log(payroll_L1 + 1)

sum turnover_L1, d 
replace turnover_L1 =  `r(p99)' if turnover_L1 >= `r(p99)' & turnover_L1 != . 
gen logturnover_L1 = log(turnover_L1 + 1)

sum profitrate_L1, d 
replace profitrate_L1 = `r(p99)' if profitrate_L1 >= `r(p99)' &  profitrate_L1 != .
replace profitrate_L1 = `r(p1)' if  profitrate_L1 < `r(p1)'
 
gen logturnover2017 = log(turnover2017 + 1)
replace logturnover2017 = log(turnover2016 + 1) if logturnover2017 == . | logturnover2017 == 0 
replace logturnover2017 = log(turnover2015 + 1) if logturnover2017 == . | logturnover2017 == 0 
replace logturnover2017 = log(turnover2014 + 1) if logturnover2017 == . | logturnover2017 == 0 

gen logpayroll2017 = log(payroll2017 + 1)
replace logpayroll2017 = log(payroll2016 + 1) if logpayroll2017 == . | logpayroll2017 == 0 
replace logpayroll2017 = log(payroll2015 + 1) if logpayroll2017 == . | logpayroll2017 == 0 
replace logpayroll2017 = log(payroll2014 + 1) if logpayroll2017 == . | logpayroll2017 == 0 

gen profitrate_2017 = profitrate2017
replace profitrate_2017 = log(profitrate2016 + 1) if profitrate_2017 == . | profitrate_2017 == 0 
replace profitrate_2017 = log(profitrate2015 + 1) if profitrate_2017 == . | profitrate_2017 == 0 
replace profitrate_2017 = log(profitrate2014 + 1) if profitrate_2017 == . | profitrate_2017 == 0 

egen trade2017 = rowmax(IMP_filed2017 IMP_filed2016 IMP_filed2015 IMP_filed2014 EXP_filed2017 EXP_filed2016 EXP_filed2015 EXP_filed2014)

**********************************
*Regression table
**********************************
global characteristic "logturnover_L1 logpayroll_L1 profitrate_L1 trade_L1 durationcar firmage  q3 q5 q15"

clonevar originalselection = selection
drop selection

local c = 0 
estimates drop _all

forvalues controltype = 1/2 {

	gen selection = controle == `controltype'

		foreach outcome of varlist $characteristic {

		local ++c

		*Specification for CP with inspector x year FE 
					eststo r`c': reghdfe `outcome' algorithm overlap random safeties if selection == 1, a(inspectorclusteryear) vce(robust)
					
					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "Yes"
					estadd local turnoverdeciles "No"			
					estadd local activity "No"			
					
					qui sum `outcome' if e(sample)==1 
					estadd local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome : di %5.2f `meanoutcome'
					estadd local pp `meanoutcome'
					test algorithm == random
					local pvalue : di %5.2f `r(p)'
					estadd local pvalue = round(`pvalue', 0.01)
					qui unique firmid if e(sample)==1 
					estadd local uniquefirms = 	r(unique) 		
			estadd local N = e(N)	, replace					

		} 

		
		local keepvar1 "algorithm overlap random"
		local keepvar2 "algorithm overlap"
		
		*Summary results for selected firms 
		#delim ;
		esttab r*
				using "$output\13 characteristics of selection `controltype'.tex",
				order( algorithm overlap random )
				label se keep(`keepvar`controltype'')
				nomtitles nonumber 
				s(N r2 pp, label("N"  "R2" "Mean outcome")) 
				star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
				b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
				prehead("") 
				posthead("") postfoot("\bottomrule")
				replace
				substitute(\_ _)
			;
		#delim cr

		
	preserve 
	
		bys firmid: egen selection_years = max(selection)

		*Drop duplicates 
		bys firmid: gen n = _n
		keep if n == 1 
		drop n
				
		drop firmage 
		gen firmage = 2017 - year_creation	
				
		local c = 0 
		estimates drop _all
		
		foreach outcome in logturnover2017 logpayroll2017 profitrate_2017 trade2017  durationcar firmage q3 q5 q15 {
			
			*Specification for CP with inspector x year FE 
			eststo s`outcome': reghdfe `outcome' selection_years, a(bureau) vce(cluster bureau)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			qui unique firmid if e(sample)==1 
			estadd local uniquefirms = 	r(unique) 
			estadd local N = e(N)	, replace					
			
		}
		
		*Summary results for whole sample
		#delim ;
		esttab slogturnover2017 slogpayroll2017 sprofitrate_2017 strade2017 sdurationcar sfirmage sq3 sq5 sq15
			using "$output\13 characteristics of selection inspector whole sample `controltype'.tex",
			order(selection_years)
			label se keep(selection_years)
			nomtitles nonumber 
			s(N r2 pp, label("N" "R2" "Mean outcome")) 
			star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
			b(%5.2f) se(%5.2f) coeflabels(selection_years "Inspectors' Selection")
			prehead("") 
			posthead("") postfoot("\bottomrule")
			replace
			substitute(\_ _)
			;
		#delim cr

		restore 
		
	drop selection	
}


******************************************
******************************************
*Analysis of alternative outcomes
******************************************
******************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
*Restrict sample to selected cases
keep if selection == 1  
drop if safeties == 1

****************************
*Different definitions of duration
****************************
cap drop earliestdate earliestdate2 
cap drop earliestnotification
gen earliestdate = datededemarrage 
foreach v in datedemanderenseignement datedavisdatededemandede  s_date_demande_information dateavis s_date_avis  {
	replace earliestdate  = `v' if earliestdate == . 
}

egen earliestdate2 = rowmin(datededemarrage datedemanderenseignement datedavisdatededemandede  s_date_demande_information dateavis s_date_avis )
format earliestdate %td
label var earliestdate  "datededemarrage datedemanderenseignement datedavisdatededemandede  s_date_demande_information dateavis s_date_avis"

egen earliestnotification = rowmin(dateconfirmation datenotification)

gen time0 = datenotification - earliestdate
replace time0 = dateconfirmation - earliestdate if time0 == .

*min (date de demarrage, avis de verification, date demande de renseignment) until (date of notification) 
gen time1 = datenotification - earliestdate2

*date(of confirmation) 
gen time2 = dateconfirmation - earliestdate2

*min(date of notification or confirmation)
gen time3 = time1
replace time3 = time2 if time3 == . 

*Use current measure, but add dummies for whether or not observations has one of the above mentioned dates 

*Differnt ways of of defining the outcome, could be with/without the dummies indicating whether date var exists:
gen time4 = datenotification - datededemarrage
replace time4 = datenotification - s_date_de_demarrage if time4 == . 

gen time5 = dateconfirmation - datededemarrage
replace time5 = dateconfirmation - s_date_de_demarrage if time5 == . 

egen time6 = rowmin(time4 time5)

*Or the 3 lines above, but using date d'avis de verification instead of date de demarrage 
gen time7 = datenotification - dateavis
replace time7 = datenotification - s_date_avis if time7 == . 

gen time8 = dateconfirmation - dateavis
replace time8 = dateconfirmation - s_date_avis if time8 == . 

egen time9 = rowmin(time7 time8)

*Winsorize at top 1% and exclude negative values
forvalues x = 0/9 {
	replace time`x' = . if time`x' < 0
	
	sum time`x' if algorithm == 1, d
	replace time`x' = `r(p99)' if time`x' > `r(p99)' &  time`x' != . & algorithm == 1
	sum time`x' if algorithm == 0, d
	replace time`x' = `r(p99)' if time`x' > `r(p99)' &  time`x' != . & algorithm == 0

}

forvalues x = 0/9 {
	gen dummy`x' = time`x' != .
}

*Table on data availability 
foreach v in y16 y8 y19 q30 {
	
	gen available_`v' = `v' != . 
	
}

*Generate lags
forvalues l = 0/3 {
	
cap drop L`l'`v' 
gen L`l'`v' = 0
	
	*Check each year corresponds to the lag of the case
	forvalues y = 2018/2020 {
		
		local yearlag = `y' - `l'
		cap noisily replace L`l'`v' =  `v'`yearlag' if selectionyear == `y'
		
	}

}

replace L1turnover = log(L2turnover+1) if L1turnover == 0
replace L1turnover = log(L3turnover+1) if L1turnover == 0 
replace L1turnover = log(L0turnover+1) if L1turnover == 0 

gen evasion_cost1 = log(evasionvalue/y16)
gen evasion_cost2 = log(evasionvalue/q30)
gen evasion_cost3 = log(evasionvalue/y19)
gen evasion_cost4 = log(evasionvalue/y8)

gen evasion_cost5 = log(evasionvalue + 1) / log(y16)
gen evasion_cost6 = log(evasionvalue + 1) / log(q30)
gen evasion_cost7 = log(evasionvalue + 1) / log(y19)
gen evasion_cost8 = log(evasionvalue + 1) / log(y8)

*Table on data availability 
foreach v in evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {
	
	gen available_`v' = `v' != . 
	
}

****************************************
*GENERATE DISPUTE VARIABLES
****************************************
*Generate dispute variables
gen d1 = notification if y2 == 1 
gen d2 = confirmation  if y2 == 1 
egen d3 = rowmax(notification confirmation) if y2 == 1 
gen d4 = notificationvalue > 0 if d1 == 1  & y2 == 1 
gen d5 = confirmationvalue > 0 if d2 == 1 & y2 == 1 
egen d6 = rowmax(d4 d5) if y2 == 1 
gen d7 = confirmation if d4 == 1 & y2 == 1 
gen d8 = d5 if d4 == 1  & y2 == 1 
gen d9 = log(confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d9n = log(notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d10 =  confirmationvalue/notificationvalue > 0.95 & confirmationvalue/notificationvalue < 1.05 if d2 == 1 & d4 == 1 & y2 == 1
gen d11 =  log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d12 =  confirmationvalue/notificationvalue if d2 == 1 & d4 == 1 & y2 == 1
gen d13 =  log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1 & y2 == 1
gen d14 =  log(confirmationvalue/notificationvalue) if d2 == 1 & d4 == 1  & y2 == 1 & confirmationvalue/notificationvalue < 0.95
gen d15 =  confirmationvalue/notificationvalue if d2 == 1 & d4 == 1  & y2 == 1  & confirmationvalue/notificationvalue < 0.95
gen d16 =  log(notificationvalue - confirmationvalue) if d2 == 1 & d4 == 1  & y2 == 1  & confirmationvalue/notificationvalue < 0.95

*For presentation
gen d17 =  confirmationvalue > notificationvalue & confirmationvalue != . if d2 == 1 & d4 == 1 & y2 == 1
gen d18 = log(confirmationvalue) if d5 == 1 & d4 == 1 & y2 == 1
gen d19 = log(notificationvalue) if d5 == 1 & d4 == 1 & y2 == 1

gen d20 = log(notificationvalue + 1)
replace d20 = log(confirmationvalue + 1) if d20 == .

gen d21 = log(confirmationvalue)

****************************************
*Years investigated and infractions
*****************************************

*penalites_notification penalites_confirmation droitssimples_confirmation droitssimples_notification

foreach outcome in nyears numberinfractions y14 sharemediumseveremain sharemediumsevere anyinfraction_main anysevereinfraction_main {
*Specification for CP and VG with inspector x year FE			
local spec = 0

replace `outcome' = . if y3 == 0

local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome'  algorithm overlap random safeties if x2 == 1 & y3 == 1 , a(inspectorclusteryear) vce(robust)
		
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

local ++spec				
			
			eststo r`outcome'_`spec': reghdfe `outcome'  algorithm overlap random safeties if x2 == 0  & y3 == 1, a(inspectorclusteryear) vce(robust)
		
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

*Summary results
#delim ;
esttab  rnumberinfractions_1 rnumberinfractions_2 rnyears_1 rnyears_2 ry14_1 ry14_2
		using "$output\1 regression infractions and years.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		mtitles("Full audits" "Desk audits"  "Full audits" "Desk audits"  "Full audits"   "Desk audits") 
		b(%5.2f) se(%5.2f)
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr


*Summary results - Alternative outcomes
#delim ;
esttab rsharemediumseveremain_1 rsharemediumseveremain_2 rsharemediumsevere_1 rsharemediumsevere_2 ranyinfraction_main_1 ranyinfraction_main_2 ranysevereinfraction_main_1 ranysevereinfraction_main_2
		using "$output\1 regression infractions and years alternative outcomes.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		mtitles("Full audits" "Desk audits"  "Full audits" "Desk audits"  "Full audits"   "Desk audits" "Full audits"   "Desk audits") 
		b(%5.2f) se(%5.2f)
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

************************************
*Duration of audits and resources (number of agents)
************************************
estimates drop _all
cap drop n

foreach outcome in y16 y8 y19 q30 evasion_cost1 evasion_cost2 evasion_cost3 evasion_cost4 {

		local controls = ""

		replace available_`outcome' = . if y2 == 0

		if "`outcome'" != "q30" {
			replace `outcome' = . if y2 == 0 
		}
		if "`outcome'" == "y19" {
			local controls = "dummy1 dummy2 dummy3"
		}

		local spec = 0 

		local ++spec		

					*FULL AUDITS
					eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties `controls' if x2 == 1, a(inspectorclusteryear) vce(robust)

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
					
					eststo ravailable_`outcome'_`spec': reghdfe available_`outcome' algorithm overlap random safeties `controls' if x2 == 1, a(inspectorclusteryear) vce(robust)

					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "No"
					estadd local turnoverdeciles "No"			
					estadd local activity "No"			
					
					qui sum available_`outcome' if e(sample)==1 
					estadd local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome : di %5.2f `meanoutcome'
					estadd local pp `meanoutcome'
					test algorithm == safeties
					local pvalue : di %5.2f `r(p)'
					estadd local pvalue = round(`pvalue', 0.01)			
					estadd local N = e(N)	, replace					

					*Exclude the characteristics of available_y16 (it is always available so there is no point in reporting anything)
					if "`outcome'" == "y16" {
						estadd local meanoutcome = "", replace
						estadd local N = "", replace
						estadd local r2 = "", replace
					}
		 
					
		local ++spec		

					*DESK AUDITS
					eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties `controls' if x2 == 0, a(inspectorclusteryear) vce(robust)
					
					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "Yes"
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
			
					eststo ravailable_`outcome'_`spec': reghdfe available_`outcome' algorithm overlap random safeties `controls' if x2 == 0, a(inspectorclusteryear) vce(robust)
					
					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "Yes"
					estadd local turnoverdeciles "No"			
					estadd local activity "No"			
					
					qui sum available_`outcome' if e(sample)==1 
					estadd local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome : di %5.2f `meanoutcome'
					estadd local pp `meanoutcome'
					test algorithm == safeties
					local pvalue : di %5.2f `r(p)'
					estadd local pvalue = round(`pvalue', 0.01)		
					estadd local N = e(N)	, replace					
}

*EXPORT TABLES

*****************
*TABLE FULL AUDITS
*****************
*Summary results including resources 
#delim ;
esttab ry16_1 rq30_1 ry19_1 ry8_1 revasion_cost1_1 revasion_cost2_1 revasion_cost3_1 revasion_cost4_1
		using "$output\1 regression cost and resources summarized.tex",
		order( algorithm overlap )
		label se keep( algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Availability
#delim ;
esttab ravailable_y16_1 ravailable_q30_1 ravailable_y19_1 ravailable_y8_1 ravailable_evasion_cost1_1 ravailable_evasion_cost2_1 ravailable_evasion_cost3_1 ravailable_evasion_cost4_1
		using "$output\1 regression cost and resources summarized availability.tex",
		order( algorithm overlap )
		label se keep( algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr	

*****************
*TABLE DESK AUDITS
*****************
*Summary results including resources 
#delim ;
esttab  rq30_2 ry19_2 ry8_2 revasion_cost2_2 revasion_cost3_2 revasion_cost4_2
		using "$output\1 regression cost and resources summarized desk.tex",
		order( algorithm overlap )
		label se keep( algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Availability
#delim ;
esttab  ravailable_q30_2 ravailable_y19_2 ravailable_y8_2 ravailable_evasion_cost2_2 ravailable_evasion_cost3_2 ravailable_evasion_cost4_2
		using "$output\1 regression cost and resources summarized availability desk.tex",
		order( algorithm overlap )
		label se keep( algorithm overlap)
		b(%5.2f) se(%5.2f)
		nomtitles
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr	

**********************************************
*GRAPHS OF PRODUCIVITY PER SIZE
**********************************************

foreach v in y16 q30 y19 y8 {

	gen definition1 = log(evasionvalue/`v')
	gen definition2 = log(evasionvalue/`v' + 1)
	gen definition3 = log(evasionvalue)/`v'
	gen definition4 = log(evasionvalue +1)/`v'
	gen definition5 = evasionvalu/`v'
	sum definition5, d 
	replace definition5  = r(p99) if definition5  > r(p99) & definition5  != .
	gen definition6 = log((evasionvalue +1)/`v')

		
	forvalues x = 1/6 {
	quietly eststo r`x': reghdfe definition`x' algorithm overlap random safeties if x2 == 1, a(inspectorclusteryear) vce(robust)
	}

	esttab r1 r2 r3 r4 r5 r6, keep(algorithm) se

	drop definition1 definition2 definition3 definition4 definition5 definition6
 
}
 
 preserve 

	*Standardize variables
	foreach v of varlist evasion_cost* L1turnover { 
	bys inspectorclusteryear: egen mean = mean(`v')
	replace `v' = `v' - mean 
	drop mean
	}

	local l1 "A: number of agents"
	local l2 "B: duration of audit (taxpayer survey)"
	local l3 "C: days from notification to confirmation"
	local l4 "D: duration of audit (self-reported)"

	qui foreach c in 1 2 3 4 5 6 7 8 {

	 qui reg evasion_cost`c' L1turnover if controle == 2 & abs(L1turnover) < 3
	 
	 // find the dependent variable
	 local eq `"log(evasion/cost) ="'
	 
	 // choose a nice display format for the constant
	 local eq "`eq'`: di %7.2f _b[_cons]'"
	 
	 // should we add or subtract
	 local eq `"`eq' `=cond(_b[L1turnover]>0, "+", "-")'"'
	 
	 // we already chose the plus or minus sign
	 // so we need to strip a minus sign when it is there
	 local eq `"`eq'`:di %6.2f abs(_b[L1turnover])' log(turnover t-1)"'
	 
	 // add the error term
	 local eq `"`eq' + {&epsilon}"'
	 
		local t = _b[L1turnover]/_se[L1turnover]
		local p =round(2*ttail(e(df_r),abs(`t')), 0.001)

	 local eq `"`eq' ,  p-value = `p' "'
		
		#delimit ;
		tw
		(scatter evasion_cost`c' L1turnover if controle == 2 & dgid == 1 & abs(L1turnover) < 3, color(navy%50))

		(scatter evasion_cost`c' L1turnover if controle == 2 & dgid == 0 & abs(L1turnover) < 3, color(orange%50))
		
		(lfit evasion_cost`c' L1turnover if controle == 2 & abs(L1turnover) < 3, lcolor(black) lwidth(vthick)), 
		xlabel(-3(1)3)
		graphregion(color(white))
		xtitle("demeaned log(turnover t-1)")
		ytitle("demeaned log(Evasion/Cost)")
		legend(pos(7) ring(0) r(1) order(1 "Inspectors" 2 "Algorithm" ))
		saving("g`c'.gph", replace)
		note("`eq'")
		;
		#delimit cr 

		graph export "$output\1 plot evasion per cost `c'.pdf", as(pdf) replace	
		
	}

		erase g1.gph
		erase g2.gph
		erase g3.gph
		erase g4.gph
		erase g5.gph
		erase g6.gph
		erase g7.gph
		erase g8.gph
		drop evasion_cost* L1turnover

restore 

**********************************
*Graphs Execution and overall execution rate
**********************************
gen y2algorithm = y2 if algorithm == 1 
gen y2dgid = y2 if dgid == 1 

bys inspectorclusteryear: egen meany2 = mean(y2)
bys inspectorclusteryear: egen meany2algorithm = mean(y2algorithm)
bys inspectorclusteryear: egen meany2dgid = mean(y2dgid)
gen difference_execution = meany2algorithm - meany2dgid

bys inspectorclusteryear: gen n = _n

forvalues x = 0/1  {

local l0 "CP"
local l1 "VG"

	 qui reg difference_execution meany2 if n == 1 & x2 == `x'
	 
	 local r2: di %7.3f e(r2)

	 // find the dependent variable
	 local eq `"Y ="'
	 
	 // choose a nice display format for the constant
	 local eq "`eq'`: di %7.2f _b[_cons]'"
	 
	 // should we add or subtract
	 local eq `"`eq' `=cond(_b[meany2]>0, "+", "-")'"'
	 
	 // we already chose the plus or minus sign
	 // so we need to strip a minus sign when it is there
	 local eq `"`eq'`:di %6.2f abs(_b[meany2])' X"'
	 
	 // add the error term
	 local eq `"`eq' + {&epsilon}"'
	 
		local t = _b[meany2]/_se[meany2]
		local p =round(2*ttail(e(df_r),abs(`t')), 0.001)

	 local eq `"`eq' ,  p-value = `p', R2 =`r2' "'

#delim ;
tw 
(scatter difference_execution meany2 if n == 1 & x2 == `x', col(navy))
(lfit difference_execution meany2 if n == 1 & x2 == `x', lcol(black))
, 
legend(off)
xtitle("Overall execution rate")
ytitle("Alg. execution - Insp. execution")
note("`eq'")
;
#delim cr 

graph export "$output\2 algorithm effect and overall execution `l`x''.pdf", as(pdf) replace 

}

**********************************
*Distribution of outcomes as connected graphs
**********************************
cap drop n 

*Standardize variables

	*Standardize variables
	foreach v of varlist evasion_cost1 evasion_cost2 evasion_cost3 { 
		bys inspectorclusteryear: egen mean = mean(`v')
		
		replace `v' = (`v' - mean) 
		drop mean 
	}

	
	foreach v of varlist y4 y7 evasion_cost1 evasion_cost2 evasion_cost3 { 
		
		sum `v', d
		local max = `r(max)'
		local min = `r(min)'
		local bin = (`max' - `min')/10
		
		gen bin = ceil((`v' - `min')/`bin')
		replace bin = 1 if bin == 0 
		
		bys x2 algorithm bin: gen n = _n
		bys x2 algorithm bin: egen countvar = count(`v') if `v' != .
		bys x2 algorithm: egen counttotal = count(`v') if `v' != .
		
		replace countvar  = countvar / counttotal
		
		*Kolmogorov-Smirnov test for equality of distributions
		ksmirnov `v' if x2 == 1 , by(algorithm)
		local pvalue = round(r(p), 0.01)
		
		#delim ;
		tw 
		(scatter countvar bin if algorithm == 1 & x2 == 1,  msymbol(T) color(ebblue*1.75))		(line countvar bin if algorithm == 1 & x2 == 1, lcolor(ebblue*1.75))
		(scatter countvar bin if algorithm == 0 & x2 == 1, color(dkgreen))		(line countvar bin if algorithm == 0 & x2 == 1, lcolor(dkgreen*1.75))
		,
		legend(order(1 "Algorithm" 3 "Inspectors"))
		xlabel("")
		ytitle("density")
		xtitle("")
		note("Kolmogorov-Smirnov p-value: `pvalue'")
		;
		#delim cr
			
		graph export "$output\1 distribution evasion VG `v'.pdf", as(pdf) replace	

		*Kolmogorov-Smirnov test for equality of distributions
		ksmirnov `v' if x2 == 0, by(algorithm)
		local pvalue = round(r(p), 0.01)	
		
		#delim ;
		tw 
		(scatter countvar bin if algorithm == 1 & x2 == 0,  msymbol(T) color(ebblue*1.75))		(line countvar bin if algorithm == 1 & x2 == 0, lcolor(ebblue*1.75))
		(scatter countvar bin if algorithm == 0 & x2 == 0, color(dkgreen))		(line countvar bin if algorithm == 0 & x2 == 0, lcolor(dkgreen*1.75))
		,
		legend(order(1 "Algorithm" 3 "Inspectors"))
		xlabel("")
		ytitle("density")
		xtitle("")
		note("Kolmogorov-Smirnov p-value: `pvalue'")
		;
		#delim cr
			
		graph export "$output\1 distribution evasion CP `v'.pdf", as(pdf) replace			
		
		cap drop counttotal 
		cap drop countvar 
		cap drop n 
		cap drop bin 	
	}
	
**********************************
*Dispute results
*********************************

foreach outcome in d1 d2 d3 d4 d5 d6 d7 d8 d9 d9n d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 {

local spec = 0 

*Specification for VG with bureau x year FE
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1, a(controlbureauannee) vce(cluster controlbureauannee)
			
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

*Specification for VG with bureau x year FE, Deciles of turnover and activity groups
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1, a(controlbureauannee activity_group decileturnover) vce(cluster controlbureauannee)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "Yes"			
			estadd local activity "Yes"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Specification for VG with bureau x year FE and normalized sequencing
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties norm_sequencing  if x2 == 1, a(controlbureauannee) vce(cluster controlbureauannee)
			
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

			
*Specification for CP with bureau x year FE 
local ++spec		
	
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(controlbureauannee) vce(cluster controlbureauannee)
			
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

*Specification for CP with inspector x year FE 
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

*Specification for CP with inspector x year FE , Deciles of turnover and activity groups			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0, a(inspectorclusteryear activity_group decileturnover) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "Yes"			
			estadd local activity "Yes"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					

*Specification for CP with inspector x year FE , normalized sequencing			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties norm_sequencing   if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

*Specification for CP and VG with inspector x year FE			
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome'  algorithm overlap random safeties, a(inspectorclusteryear) vce(robust)
		
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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
			
/*
*Export table

#delim ;
esttab r`outcome'_1  r`outcome'_5  r`outcome'_8
		using "$output\1 regression `outcome'.tex",
		order( algorithm overlap random )
		label se keep( algorithm overlap random)
		mtitles("Full audits" "Desk audits" "All") 
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*/

*Specification for VG with bureau x year FE controlling for turnover
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover if x2 == 1, a(controlbureauannee) vce(cluster controlbureauannee)
			
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
	
*Specification for CP with bureau x year FE controlling for turnover
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties L1turnover if x2 == 0, a(controlbureauannee) vce(cluster controlbureauannee)
			
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


*Export table

#delim ;
esttab rd10_1 rd10_5 rd19_1 rd19_5 rd18_1 rd18_5 
		using "$output\1 dispute summary.tex",
		order( norm_sequencing algorithm safeties)
		label se keep( algorithm random overlap)
		mtitles("Full audits" "Desk audits" "Full audits" "Desk audits" "Full audits" "Desk audits" "Full audits" "Desk audits" "Full audits" "Desk audits") 
		b(%5.2f) se(%5.2f)
		s(N r2 pp, label( "N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(algorithm "Algorithm" overlap "Inspectors x Overlap" random "Algorithm x Random")
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Export table with controls
#delim cr

forvalues x = 1/21 {
	cap drop d`x'
}

*************************************
*Distribution of confirmation/notification
*************************************
set scheme s1color 

*Generate deciles (bins)
cap drop d17
gen d17 = confirmationvalue/notificationvalue
gen deciles = 0 if d17 != . 
replace deciles = 0 if d17 <= 0.05 & y2 == 1
replace deciles = 1 if d17 > 0.05 & d17 <= 0.15 & y2 == 1
replace deciles = 2 if d17 > 0.15 & d17 <= 0.25 & y2 == 1
replace deciles = 3 if d17 > 0.25 & d17 <= 0.35 & y2 == 1
replace deciles = 4 if d17 > 0.35 & d17 <= 0.45 & y2 == 1
replace deciles = 5 if d17 > 0.45 & d17 <= 0.55 & y2 == 1
replace deciles = 6 if d17 > 0.55 & d17 <= 0.65 & y2 == 1
replace deciles = 7 if d17 > 0.65 & d17 <= 0.75 & y2 == 1
replace deciles = 8 if d17 > 0.75 & d17 <= 0.85 & y2 == 1
replace deciles = 9 if d17 > 0.85 & d17 <= 0.95 & y2 == 1
replace deciles = 10 if d17 > 0.95 & d17 <= 1.05 & y2 == 1
replace deciles = 11 if d17 > 1.05 & d17 <= 1.15 & y2 == 1
replace deciles = 12 if d17 > 1.15 & d17 <= 1.25 & y2 == 1
replace deciles = 13 if d17 > 1.25 & d17 <= 1.35 & y2 == 1
replace deciles = 14 if d17 > 1.35 & d17 <= 1.45 & y2 == 1
replace deciles = 15 if d17 > 1.45 & d17 <= 1.55 & y2 == 1
replace deciles = 16 if d17 > 1.55 & d17 <= 1.65 & y2 == 1
replace deciles = 17 if d17 > 1.65 & d17 <= 1.75 & y2 == 1
replace deciles = 18 if d17 > 1.75 & d17 <= 1.85 & y2 == 1
replace deciles = 19 if d17 > 1.85 & d17 <= 1.95 & y2 == 1
replace deciles = 20 if d17 > 1.95 & d17 != . & y2 == 1

replace deciles = . if confirmation == 0 | notification == 0 
replace d17 = . if confirmation == 0 | notification == 0 

preserve 

	keep if dgid == 1 | algorithm == 1
	
	*Count how many cases there are in each bin for each selection method and audit type
	cap drop id 
	gen id = 1 
	collapse (sum) id, by(deciles algorithm x2)  

	drop if deciles == . 
	
	*Count the total number of cases by method
	bys algorithm x2: egen total = total(id)
	
	*Transform id into a percentage share
	replace id = 100*id/total
	
	*For the figure, make sure that we have all the bins for every method and audit type
	fillin deciles algorithm x2
	replace id = 0 if id ==.

	*Create a new category of bins that lumps all cases above 105% 
	clonevar deciles2 = deciles
	replace deciles2 = 11 if deciles2 > 11 & deciles2 != .
	bys deciles2 algorithm x2: egen id2 = total(id)
	
	sort algorithm x2 deciles
/*
	*Figures with all bins
	#delim ;
	tw (scatter id deciles if algorithm == 1 & x2 == 1, color("150 182 89") msize(large)) 
	(line id deciles if algorithm == 1 & x2 == 1, lcolor("150 182 89") lwidth(vthick))
	(scatter id deciles if algorithm == 0 & x2 == 1, color("0 192 195") msize(large) msymbol(T)) 
	(line id deciles if algorithm == 0 & x2 == 1, lcolor("0 192 195") lwidth(vthick) lpattern(-))
	, legend(order(1 "Algorithm" 3 "Inspectors"))
	ytitle("Density (%)")
	xtitle("Confirmation/Notification")
	xlabel(0 "0%" 1 "10%" 2 "20%" 3 "30%" 4 "40%" 5 "50%" 6 "60%" 7 "70%" 8 "80%" 9 "90%" 10 "100%" 11 "110%" 12 "120%" 13 "130%" 14 "140%" 15 "150%" 16 "160%" 17 "170%" 18 "180%" 19 "190%" 20 ">200%", labsize(vsmall))
	plotregion(color(white))	
	;
	#delim cr 

	graph export "$output\1 densityconfirmationnotificationfullaudits.pdf", as(pdf) replace	

	#delim ;
	tw (scatter id deciles if algorithm == 1 & x2 == 0, color("150 182 89") msize(large)) 
	(line id deciles if algorithm == 1 & x2 == 0, lcolor("150 182 89") lwidth(vthick))
	(scatter id deciles if algorithm == 0 & x2 == 0, color("0 192 195") msize(large) msymbol(T)) 
	(line id deciles if algorithm == 0 & x2 == 0, lcolor("0 192 195") lwidth(vthick)  lpattern(-))
	, legend(order(1 "Algorithm" 3 "Inspectors"))
	ytitle("Density (%)")
	xtitle("Confirmation/Notification")
	xlabel(0 "0%" 1 "10%" 2 "20%" 3 "30%" 4 "40%" 5 "50%" 6 "60%" 7 "70%" 8 "80%" 9 "90%" 10 "100%" 11 "110%" 12 "120%" 13 "130%" 14 "140%" 15 "150%" 16 "160%" 17 "170%" 18 "180%" 19 "190%" 20 ">200%", labsize(vsmall))
	plotregion(color(white))	

	;
	#delim cr 

	graph export "$output\1 densityconfirmationnotificationdeskaudits.pdf", as(pdf) replace	
*/	
	*Figures lumping the upper bins
	sort algorithm x2 deciles
	
	#delim ;
	tw (scatter id2 deciles2 if algorithm == 1 & x2 == 1, color("150 182 89") msize(large)) 
	(line id2 deciles2 if algorithm == 1 & x2 == 1, lcolor("150 182 89") lwidth(vthick))
	(scatter id2 deciles2 if algorithm == 0 & x2 == 1, color("0 192 195") msize(large) msymbol(T)) 
	(line id2 deciles2 if algorithm == 0 & x2 == 1, lcolor("0 192 195") lwidth(vthick)  lpattern(-))
	, legend(order(1 "Algorithm" 3 "Inspectors"))
	ytitle("Density (%)")
	ylabel(0(5)25)
	xtitle("Confirmation/Notification")
	xlabel(0 "0%" 1 "10%" 2 "20%" 3 "30%" 4 "40%" 5 "50%" 6 "60%" 7 "70%" 8 "80%" 9 "90%" 10 "100%" 11 ">105%", labsize(vsmall))
	plotregion(color(white))	

	;
	#delim cr 

	graph export "$output\1 densityconfirmationnotificationfullauditslump.pdf", as(pdf) replace	
/*	
	#delim ;
	tw 
	(scatter id2 deciles2 if algorithm == 0 & x2 == 1, color("0 192 195") msize(large)) 
	(line id2 deciles2 if algorithm == 0 & x2 == 1, lcolor("0 192 195") lwidth(vthick))
	, legend(order(1 "Inspectors"))
	ytitle("Density (%)")
	ylabel(0(5)25)
	xtitle("Confirmation/Notification")
	xlabel(0 "0%" 1 "10%" 2 "20%" 3 "30%" 4 "40%" 5 "50%" 6 "60%" 7 "70%" 8 "80%" 9 "90%" 10 "100%" 11 ">105%", labsize(vsmall))
	plotregion(color(white))	

	;
	#delim cr 	
	
	graph export "$output\1 densityconfirmationnotificationfullauditslump_onlydiscretion.pdf", as(pdf) replace	
*/
	
	#delim ;
	tw (scatter id2 deciles2 if algorithm == 1 & x2 == 0, color("150 182 89") msize(large)) 
	(line id2 deciles2 if algorithm == 1 & x2 == 0, lcolor("150 182 89") lwidth(vthick))
	(scatter id2 deciles2 if algorithm == 0 & x2 == 0, color("0 192 195") msize(large) msymbol(T)) 
	(line id2 deciles2 if algorithm == 0 & x2 == 0, lcolor("0 192 195") lwidth(vthick) lpattern(-))
	, legend(order(1 "Algorithm" 3 "Inspectors"))
	ytitle("Density (%)")
	ylabel(0(5)25)
	xtitle("Confirmation/Notification")
	xlabel(0 "0%" 1 "10%" 2 "20%" 3 "30%" 4 "40%" 5 "50%" 6 "60%" 7 "70%" 8 "80%" 9 "90%" 10 "100%" 11 ">105%", labsize(vsmall))
	plotregion(color(white))	

	;
	#delim cr 
	
	graph export "$output\1 densityconfirmationnotificationdeskauditslump.pdf", as(pdf) replace	

restore	


******************************************
******************************************
*2 ANALYZE INSPECTOR CHARACTERISTICS 
******************************************
******************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
keep if selection == 1  
drop if safeties == 1

******************
*Add appropriate information about inspectors
******************

*Add information on the inspectors that carried out the case
preserve 
		
*		replace verificateur1 = verificateur_selection if typedecontrole_selection == "CP"
		
*		drop verificateur_selection
		
		keep firmid selectionyear selection verificateur*  controle groupbureau
		bys firmid selectionyear controle selection groupbureau: gen n = _n 
		keep if n == 1 
		drop n
		
		reshape long verificateur, i(firmid selectionyear controle selection groupbureau) j(number)
		drop if verificateur == ""
		
		bys firmid selectionyear controle verificateur: gen n = _n
		drop if n > 1 
		drop n  
		
		encode verificateur, gen(codeinspector)
		
		drop selection groupbureau codeinspector
		
		*Add data on inspector characteristics
		merge m:1 verificateur using "$analysisdata/inspectorsurvey"
		
		*Create variables 
		gen answeredsurvey = _merge == 3
		drop _merge 
		
		clonevar yearsexperience = mod1_q3 
		clonevar education = mod2_q1 
		clonevar enthusiasmalgorithm =  mod7_q4_e

		bys firmid selectionyear controle: gen numberagents = _N
		
		gen years_cat = 1 if yearsexperience > 0 & yearsexperience <= 5 
		replace years_cat = 2 if yearsexperience > 5 & yearsexperience <= 10 
		replace years_cat = 3 if yearsexperience > 10 

		gen education_cat1 = mod2_q1 == 1  if mod2_q1 != . 
		gen education_cat2 = education == 7 | education == 2 | education == 3  if mod2_q1 != . 
		gen education_cat3 = education == 4  if mod2_q1 != . 
		gen education_cat4 = education == 5 if mod2_q1 != . 

		gen education_cat = . 
		forvalues x = 1/4 {
			replace education_cat = `x' if education_cat`x' == 1 
		}
		
		gen mastersphd = education_cat3 == 1 | education_cat4 == 1
		replace mastersphd = . if mod2_q1 == . 

		gen age_cat = .
		replace age_cat = 1 if age <= 30
		replace age_cat = 2 if age > 30 & age <= 40 
		replace age_cat = 3 if age > 40 & age != .

		gen enthusiasm = enthusiasmalgorithm == 3 if enthusiasmalgorithm != .
		gen monthsexperience = 12*mod1_q3 + mod1_q3_b

		bys verificateur: gen n = _n
		sum monthsexperience if n == 1, d
		gen highexperience = monthsexperience > r(p50) if monthsexperience != .
		drop n
		
		gen agevariable = age != . 
		
		collapse (count) answered_education = education_cat answered_enthusiasm = enthusiasmalgorithm answered_experience = monthsexperience (sum) answeredsurvey agevariable (mean)  mastersphd meanage = age yearsexperience monthsexperience highexperience enthusiasm numberagents education_cat* (median) medianage = age medianyearsexperience = yearsexperience (max) maxyearsexperience = yearsexperience maxage = age maxedu = education_cat, by(firmid selectionyear controle)
		
		ds firmid selectionyear controle, not
		foreach v in `r(varlist)' {
			
			label var `v' "Inspector survey information"
			
		}
		
		tempfile inspectors 
		sa `inspectors', replace 
		
restore 

cap noisily drop mastersphd age yearsexperience monthsexperience enthusiasm numberagents medianage medianyearsexperience maxyearsexperience maxage maxedu

merge m:1 firmid selectionyear controle using `inspectors'
drop if _merge == 2 
drop _merge 

*Add information on the inspectors within the tax office (for selection of full audits)
preserve
	
	keep if x2 == 1
	drop verificateur_selection

	keep bureauclusteryear verificateur*
	
	egen group = group(verificateur*), missing
	bys bureauclusteryear group: gen n = _n 
	keep if n == 1 
	drop n	
	
	reshape long verificateur, i(bureauclusteryear group) j(number)
	drop if verificateur == ""
	drop number 	
	drop group
	
	*Add data on inspector characteristics
	merge m:1 verificateur using "$analysisdata/inspectorsurvey"	
	drop _merge 
	
	bys bureauclusteryear: gen numberagents_bureau = _N

	gen education_cat1 = mod2_q1 == 1  if mod2_q1 != . 
	gen education_cat2 = mod2_q1 == 7 | mod2_q1 == 2 | mod2_q1 == 3  if mod2_q1 != . 
	gen education_cat3 = mod2_q1 == 4  if mod2_q1 != . 
	gen education_cat4 = mod2_q1 == 5 if mod2_q1 != . 

	gen mastersphd_bureau = education_cat3 == 1 | education_cat4 == 1
	replace mastersphd_bureau = . if mod2_q1 == . 

	gen enthusiasm_bureau = mod7_q4_e == 3 if mod7_q4_e != .
	gen monthsexperience_bureau = 12*mod1_q3 + mod1_q3_b

	bys verificateur: gen n = _n
	sum monthsexperience_bureau if n == 1, d
	gen highexperience_bureau = monthsexperience_bureau > r(p50) if monthsexperience_bureau != .
	drop n
	
	collapse (mean) highexperience_bureau monthsexperience_bureau mastersphd_bureau enthusiasm_bureau age, by(bureauclusteryear)

	tempfile inspectors 
	sa `inspectors', replace 

restore 

merge m:1 bureauclusteryear using `inspectors'
drop if _merge == 2 
drop _merge 

*Add information on the inspectors that selected/were assigned the case (for desk audits)

*Merge with only the inspector of the selection 
clonevar verificateur = verificateur_selection
merge m:1 verificateur using "$analysisdata/inspectorsurvey", update replace 
drop if _merge == 2 

gen answeredsurvey_selection = _merge >= 3
drop _merge 

clonevar yearsexperience_selection = mod1_q3 
clonevar education_selection = mod2_q1 
clonevar enthusiasmalgorithm_selection =  mod7_q4_e

gen years_cat_selection = 1 if yearsexperience_selection > 0 & yearsexperience_selection <= 5 
replace years_cat = 2 if yearsexperience_selection > 5 & yearsexperience_selection <= 10 
replace years_cat = 3 if yearsexperience > 10 

gen education_cat1_selection  = mod2_q1 == 1  if mod2_q1 != . 
gen education_cat2_selection  = mod2_q1 == 7 | mod2_q1 == 2 | mod2_q1 == 3  if mod2_q1 != . 
gen education_cat3_selection  = mod2_q1 == 4  if mod2_q1 != . 
gen education_cat4_selection  = mod2_q1 == 5 if mod2_q1 != . 

gen mastersphd_selection = education_cat3_selection ==1 | education_cat3_selection == 1 
replace mastersphd_selection = . if mod2_q1 == . 

gen age_cat_selection = .
replace age_cat_selection = 1 if age <= 30
replace age_cat_selection = 2 if age > 30 & age <= 40 
replace age_cat_selection = 3 if age > 40 & age != .

gen enthusiasm_selection = enthusiasmalgorithm_selection == 3 if enthusiasmalgorithm != .
gen monthsexperience_selection = 12*mod1_q3 + mod1_q3_b

bys verificateur: gen n = _n

sum age if x2 == 0 & n == 1, d
gen highage_selection = age > r(p50) if x2 == 0

sum monthsexperience if n == 1, d
gen highexperience_selection = monthsexperience_selection > r(p50) & monthsexperience_selection != .
replace highexperience_selection  = . if monthsexperience_selection  == . 
drop n

bys verificateur: gen n = _n
sum age if n == 1, d
gen old_selection = age > r(p50) & age != .
replace old_selection  = . if age  == . 
drop n

clonevar meanage_selection = age
replace  meanage_selection  = . if answeredsurvey_selection == 0

drop verificateur 

drop if safeties == 1

gen all_answeredsurvey = y16 == answeredsurvey & y16  > 0 & y16 != .
gen all_meanage = y16 == agevariable & y16  > 0 & y16 != .
gen all_maxage = y16 == agevariable & y16  > 0 & y16 != .
gen all_mastersphd = y16 == answered_education & y16  > 0 & y16 != .
gen all_enthusiasm = y16 == answered_enthusiasm & y16  > 0 & y16 != .
gen all_highexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_yearsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_monthsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_maxyearsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_maxedu = y16 == answered_education & y16  > 0 & y16 != .

**********************************
*Regression to predict characteristics of inspectors among conducted cases
**********************************
estimates drop _all

foreach outcome in meanage maxage mastersphd enthusiasm highexperience yearsexperience monthsexperience maxyearsexperience maxedu {

local spec = 0 

*Specification for VG with bureau x year FE
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1 & y2 == 1, a(controlbureauannee) vce(robust)
			
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


*Specification for CP with inspector x year FE 
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 0 & y2 == 1, a(bureauclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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

local ++spec		

*Robustness Specification for VG with bureau x year FE only for groups in which ALL inspectors answered the survey question
			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random safeties if x2 == 1 & y2 == 1 & all_`outcome' == 1, a(controlbureauannee) vce(robust)
			
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

local ++spec		

*Data availability (Panel B)
			eststo r`outcome'_`spec': reghdfe all_`outcome' algorithm overlap random safeties if x2 == 1 & y2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum all_`outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			test algorithm == safeties
			local pvalue : di %5.2f `r(p)'
			estadd local pvalue = round(`pvalue', 0.01)
			estadd local N = e(N)	, replace					


}

/*
*Summary results table
#delim ;
esttab rmeanage_1 rmeanage_2  rmastersphd_1 rmastersphd_2  renthusiasm_1 renthusiasm_2  rhighexperience_1 rhighexperience_2 
		using "$output\2 regression inspector characteristics.tex",
		order( algorithm)
		nomtitles nonumbers
		label se keep( algorithm overlap )
		b(%5.2f) se(%5.2f)
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr
*/

*Panel A of table in paper
#delim ;
esttab rmeanage_1 rmaxage_1 ryearsexperience_1 rmaxyearsexperience_1 rmastersphd_1 rmaxedu_1 renthusiasm_1 
		using "$output\2 regression inspector characteristics VG.tex",
		order(algorithm)
		nomtitles nonumbers
		label se keep( algorithm)
		b(%5.2f) se(%5.2f)		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Robustness (all inspectors answered survey question)
#delim ;
esttab rmeanage_3 rmaxage_3 ryearsexperience_3 rmaxyearsexperience_3 rmastersphd_3 rmaxedu_3 renthusiasm_3
		using "$output\2 regression inspector characteristics VG robustness.tex",
		order(algorithm overlap random)
		nomtitles nonumbers
		b(%5.2f) se(%5.2f)		label se keep( algorithm )
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr


*Data availability 
#delim ;
esttab rmeanage_4 rmaxage_4 ryearsexperience_4 rmaxyearsexperience_4 rmastersphd_4 rmaxedu_4 renthusiasm_4
		using "$output\2 regression inspector characteristics VG robustness data availability.tex",
		order(algorithm)
		nomtitles nonumbers
		b(%5.2f) se(%5.2f)		label se keep( algorithm)
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

/*
*Only for characteristics of selection (desk audits)
foreach outcome in meanage mastersphd enthusiasm highexperience {

local spec = 0 

			eststo r`outcome'_`spec': reghdfe `outcome'_selection algorithm overlap random safeties if x2 == 0, a(bureauclusteryear) vce(cluster bureauclusteryear)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
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
esttab rmeanage_1 rmastersphd_1 renthusiasm_1 rhighexperience_1 
		using "$output\2 regression inspector characteristics selection.tex",
		order( algorithm overlap random)
		nomtitles nonumbers
		b(%5.2f) se(%5.2f)		label se keep( algorithm overlap )
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(overlap "Inspectors x Overlap &" algorithm "Algorithm &" random "Algorithm x Random &" safeties "Replacement &" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr
*/
**********************************
*Desk audits
**********************************
preserve 

keep if x2 == 0  //Only keep desk audits

gen startedalgorithm = algorithm*y2 

collapse (count) count = algorithm (mean) y2 y3 y4 enthusiasm_selection highexperience_selection highage_selection mastersphd_selection (sum) algorithm startedalgorithm started = y2, by(inspectorclusteryear verificateur_selection bureauclusteryear selectionyear)

gen sharestartedalgorithm = startedalgorithm/algorithm
gen morealgorithm = startedalgorithm > 0.5*started //More than 50% of started cases are algorithm cases

*Only for characteristics of selection (desk audits)
foreach outcome in started y2 y3 y4 startedalgorithm sharestartedalgorithm morealgorithm enthusiasm_selection {

			eststo r`outcome': reghdfe `outcome' mastersphd_selection highage_selection highexperience_selection, a(bureauclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

}			
			
#delim ;
esttab rstarted ry2 ry3 ry4 rstartedalgorithm rsharestartedalgorithm rmorealgorithm renthusiasm_selection
		using "$output\2 regression inspector characteristics selection desk audits.tex",
		order( mastersphd_selection highage_selection highexperience_selection)
		nomtitles nonumbers
		b(%5.2f) se(%5.2f)
		label se keep( mastersphd_selection highage_selection highexperience_selection )
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels( mastersphd_selection "Masters/PhD" highage_selection "Above median age" highexperience_selection "Above median experience")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

restore 

******************************************
******************************************
*3 RISK SCORE QUALITY
******************************************
******************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
drop if safeties == 1
keep if selection == 1 

replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

destring sequencing, replace force

*Replace log turnover=0 if missing 
replace x = 0 if x == .

*Define the unweighted riskscore
gen unw_riskscore = riskscore/x
replace unw_riskscore  = 0 if unw_riskscore  == . 

*Check each year corresponds to the lag of the case
*Create lags in different columns for the variables to be used in prediction (notice that the dataset is identified by audits, so they may happen in different years)
foreach v in y2VG selectionVG y2CP selectionCP decturnover decproductivity decprofitrate turnover productivity profitrate TVA_filed TAF_filed  RAS_IRPP_filed MAN_filed IS_filed IMP_filed EXP_filed CGU_filed TVAAN_filed {
	
	*Generate lags
	forvalues l = 0/3 {
		
	cap gen L`l'`v' = 0
		
		*Check each year corresponds to the lag of the case
		forvalues y = 2018/2020 {
			
			local yearlag = `y' - `l'
			cap noisily replace L`l'`v' =  `v'`yearlag' if selectionyear == `y'
			
		}
	
	}
}

replace L1turnover = log(L1turnover + 1)
replace L1turnover = 0 if L1turnover == . 

replace durationcar = log(durationcar + 1)
replace durationcar  = 0 if durationcar  == .

replace distance = log(durationcar + 1 )
replace durationcar  = 0 if durationcar  == . 

*******************************
*Assess quality of the algorithm risk score 
********************************
foreach outcome in y2 y3 y4 y6 {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
	drop if safeties == 1
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}

*VG
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random riskscore 1.algorithm#c.riskscore if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

			
*CP
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random riskscore 1.algorithm#c.riskscore if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
		
*VG with control for turnover
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random riskscore 1.algorithm#c.riskscore L1turnover if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

			
*CP with control for turnover
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random riskscore 1.algorithm#c.riskscore L1turnover if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'	
			estadd local N = e(N)	, replace					
	
*VG with control for unweighted riskscore
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random uw_riskscore 1.algorithm#c.uw_riskscore  if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

			
*CP with control for unweighted riskscore
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm overlap random uw_riskscore 1.algorithm#c.uw_riskscore  if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'	
			estadd local N = e(N)	, replace					
			
}

*Summary results
#delim ;
esttab ry2_1 ry2_2 ry3_1 ry3_2 ry4_1 ry4_2  
		using "$output\3 regression main outcomes riskscore.tex",
		order( algorithm overlap random riskscore 1.algorithm#c.riskscore )
		nomtitles nonumbers fragment
		label se keep( algorithm  riskscore 1.algorithm#c.riskscore)
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" riskscore "Risk score" 1.algorithm#c.riskscore "Alg. x Risk score")
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Summary results with controls
#delim ;
esttab ry2_3 ry2_4 ry3_3 ry3_4 ry4_3 ry4_4 
		using "$output\3 regression main outcomes riskscore control.tex",
		order( algorithm overlap random riskscore 1.algorithm#c.riskscore L1turnover )
		nomtitles nonumbers fragment
		label se keep( algorithm  riskscore 1.algorithm#c.riskscore L1turnover)
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" riskscore "Risk score" 1.algorithm#c.riskscore "Alg. x Risk score" L1turnover "Lagged log(turnover)")
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Summary results with unweighted riskscore
#delim ;
esttab ry2_5 ry2_6 ry3_5 ry3_6 ry4_5 ry4_6 
		using "$output\3 regression main outcomes riskscore unweighted.tex",
		order( algorithm overlap random uw_riskscore 1.algorithm#c.uw_riskscore)
		nomtitles nonumbers fragment
		label se keep( algorithm  uw_riskscore 1.algorithm#c.uw_riskscore)
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" uw_riskscore "Unw. Risk score" 1.algorithm#c.uw_riskscore "Alg. x Unw. Risk score" L1turnover "Lagged log(turnover)")
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Strip the leading blank line from the three body-only fragments
shell powershell -Command "Set-Content -LiteralPath '$output\3 regression main outcomes riskscore.tex' -Value ((Get-Content -Raw -LiteralPath '$output\3 regression main outcomes riskscore.tex') -replace '^(\r\n)+','') -NoNewline"
shell powershell -Command "Set-Content -LiteralPath '$output\3 regression main outcomes riskscore control.tex' -Value ((Get-Content -Raw -LiteralPath '$output\3 regression main outcomes riskscore control.tex') -replace '^(\r\n)+','') -NoNewline"
shell powershell -Command "Set-Content -LiteralPath '$output\3 regression main outcomes riskscore unweighted.tex' -Value ((Get-Content -Raw -LiteralPath '$output\3 regression main outcomes riskscore unweighted.tex') -replace '^(\r\n)+','') -NoNewline"


*******************************
*Algorithm components
********************************
foreach r in risk_vat risk_cit risk_inconsistency risk_anomalies {
	replace `r' = 0 if `r' == .
}

foreach outcome in y2 y3 y4 y6 {

local spec = 0 

if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
	drop if safeties == 1
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}

*VG
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm risk_vat risk_cit risk_inconsistency risk_anomalies if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm  risk_inconsistency risk_anomalies c.risk_inconsistency#1.algorithm c.risk_anomalies#1.algorithm if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'			
			estadd local N = e(N)	, replace					

local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm risk_vat risk_cit risk_inconsistency risk_anomalies c.risk_vat#1.algorithm c.risk_cit#1.algorithm c.risk_inconsistency#1.algorithm c.risk_anomalies#1.algorithm if x2 == 1, a(controlbureauannee) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "No"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'				
			estadd local N = e(N)	, replace					
			
*CP
local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm risk_vat risk_cit risk_inconsistency risk_anomalies if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm risk_inconsistency risk_anomalies c.risk_inconsistency#1.algorithm c.risk_anomalies#1.algorithm if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

local ++spec		

			eststo r`outcome'_`spec': reghdfe `outcome' algorithm risk_vat risk_cit risk_inconsistency risk_anomalies c.risk_vat#1.algorithm c.risk_cit#1.algorithm c.risk_inconsistency#1.algorithm c.risk_anomalies#1.algorithm if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'			
			estadd local N = e(N)	, replace					
			
}

*Summary results
#delim ;
esttab ry2_2 ry2_3 ry2_5 ry2_6 ry3_2 ry3_3 ry3_5 ry3_6 ry4_2 ry4_3 ry4_5 ry4_6
		using "$output\3 regression main outcomes riskscore components.tex",
		order(algorithm risk_vat risk_cit risk_inconsistency risk_anomalies)
		label se 
		mtitles("Full audits" "Full audits" "Desk audits" "Desk audits" "Full audits" "Full audits" "Desk audits" "Desk audits"   "Full audits" "Full audits" "Desk audits" "Desk audits"  ) 
		s( N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(algorithm "Algorithm" risk_vat "VAT anomalies risk score" risk_cit "CIT anomalies risk score" risk_inconsistency "Inconsistencies risk score" risk_anomalies "Anomalies risk score" 1.algorithm#c.risk_vat "Algorithm x VAT anomalies" 1.algorithm#c.risk_cit "Algorithm x CIT anomalies" 1.algorithm#c.risk_inconsistency "Algorithm x Inconsistencies" 1.algorithm#c.risk_anomalies "Algorithm x Anomalies")
		prehead("") posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

******************************************
******************************************
*4 INFORMATION TREATMENT
******************************************
******************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
drop if safeties == 1
keep if selection == 1 

replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

destring sequencing, replace force

keep if typedecontrole_selection == "CP"

drop if algorithm == 0 & selectionyear == 2020

*******************************
*Information treatment T. effect
*******************************

*Generate lags
*Check each year corresponds to the lag of the case
forvalues y = 2014/2020 {
			
		cap noisily replace turnover`y' = . if TVA_filed`y' == 0  & IS_filed`y' == 0 
		cap noisily replace profitrate`y' = . if TVA_filed`y' == 0  & IS_filed`y' == 0 
		cap noisily replace profitrate`y' = . if IS_filed`y' == 0 
		cap noisily replace payroll`y' = . if RAS_IRPP_filed`y' == 0  
		cap noisily replace nemployees`y' = . if RAS_IRPP_filed`y' == 0  
		cap noisily replace totalexports`y' = . if EXP_filed`y' == 0  
		cap noisily replace gross_tax_base`y' = . if TVA_filed`y' == 0  & IS_filed`y' == 0 

}

foreach v in payroll nemployees totalexports gross_tax_base  {

	*Generate lags
	forvalues l = 1/3 {

	gen L`l'`v' = 0

		*Check each year corresponds to the lag of the case
		forvalues y = 2018/2020 {

			local yearlag = `y' - `l'
			cap noisily replace L`l'`v' =  `v'`yearlag' if selectionyear == `y'

		}

	}
}

replace L1turnover = . if L1TVA_filed == 0  & L1IS_filed == 0 
replace L1profitrate = . if  L1IS_filed == 0 	
replace firmage = selectionyear - year_creation
replace distance = . if distance == 0 

replace T_info_indicateurs  = 0 if  T_info_donnees == 1

*Log transformation
foreach v in L1turnover L1payroll L1nemployees L1totalexports L1gross_tax_base firmage distance {
	replace `v' = log(`v' + 0.001)
}

*Balancing tests
foreach outcome in  L1profitrate L1turnover L1payroll L1nemployees L1totalexports L1gross_tax_base firmage distance {
		
	eststo r`outcome': reghdfe `outcome' T_info T_info_donnees, a(inspectorclusteryear) vce(robust)

			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
			
*Missingness
gen missing = `outcome' != . 

	eststo r`outcome'_missing: reghdfe missing T_info T_info_donnees, a(inspectorclusteryear) vce(robust)

			qui sum missing if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'			
			estadd local N = e(N)	, replace					

drop missing 		

}

#delim ;
esttab  rL1profitrate rL1turnover rL1payroll rL1nemployees rL1totalexports rL1gross_tax_base  rfirmage rdistance
		using "$output\4 information treatment balancing tests.tex",
		order(T_info T_info_donnees)
		label se keep(T_info T_info_donnees)
		b(%5.2f) se(%5.2f) coeflabels(T_info "Indicators" T_info_donnees "+ data spreadsheets")
nomtitles nonumber
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		prehead("")	posthead("") prefoot(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

#delim ;
esttab  rL1profitrate_missing rL1turnover_missing rL1payroll_missing rL1nemployees_missing rL1totalexports_missing rL1gross_tax_base_missing rfirmage_missing rdistance_missing
		using "$output\4 information treatment balancing tests missing.tex",
		order(T_info T_info_donnees)
		label se keep(T_info T_info_donnees)
		b(%5.2f) se(%5.2f) coeflabels(T_info "Indicators" T_info_donnees "+ data spreadsheets")
nomtitles nonumber
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		prehead("")	posthead("") prefoot(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

******************************
*Regressions
******************************

*Outcomes
foreach outcome in y2 y3 y4 {		
	
if "`outcome'" != "y2" {
	replace `outcome' = . if y2 == 0 
	drop if safeties == 1
}
if "`outcome'" == "y4" {
	replace `outcome' = . if `outcome' == 0 
}	
	
	eststo r`outcome': reghdfe `outcome' T_info algorithm random 1.algorithm#1.T_info if x2 == 0, a(inspectorclusteryear) vce(robust)

			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					

		
	eststo r`outcome'_detail: reghdfe `outcome' T_info_indicateurs T_info_donnees algorithm random  1.algorithm#1.T_info_indicateurs 1.algorithm#1.T_info_donnees if x2 == 0, a(inspectorclusteryear) vce(robust)
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			estadd local N = e(N)	, replace					
		
}

#delim ;
esttab ry2 ry3 ry4 ry2_detail ry3_detail ry4_detail
		using "$output\1 information treatment interact.tex",
		order(algorithm random T_info 1.algorithm#1.T_info T_info_indicateurs T_info_donnees)
		label se keep(algorithm random T_info T_info_indicateurs T_info_donnees 1.algorithm#1.T_info_indicateurs 1.algorithm#1.T_info_donnees 1.algorithm#1.T_info)
		nomtitles	nonumber
		s(N r2 pp, label("N" "R2" "Mean outcome")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		b(%5.2f) se(%5.2f) coeflabels(algorithm "Algorithm" random "Algorithm x Random" T_info "Information" T_info_indicateurs "Info. (indicators)" T_info_donnees "Info. (indicators+data)"  1.algorithm#1.T_info_indicateurs "Alg. x Info. (Indicators)" 1.algorithm#1.T_info_donnees "Alg. x Info. (Indicators+data)"  1.algorithm#1.T_info "Algorithm x Information" )
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr
