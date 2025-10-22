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

	if strpos("`c(username)'","User") { 										// Roldan's personal computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}

/*
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits" 								// Insert path to shared Dropbox folder "Senegal Tax Audits"	
	}
*/

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

		
local date: disp  c(current_date)
di "`date'"
set scheme s1color

*global rootdir "C:/Users/wb606690/OneDrive - WBG/Senegal_RF"
*global analysisdata "$rootdir\Data"

******************
*Load data on selection and audits
******************
cd "$analysisdata"

local date: disp  c(current_date)
di "`date'"

use "$analysisdata/datasetforanalysis.dta", clear

****************************
*Cleaning and generating variables
****************************

*Generate numeric variable for bureau
gen numeric_bureau = 1 if bureau == "DGE"
replace numeric_bureau = 2 if bureau == "CME1"
replace numeric_bureau = 3 if bureau == "CME2"
replace numeric_bureau = 4 if bureau == "CPR"
replace numeric_bureau = 5 if numeric_bureau  == . 

*Cleaning
replace activity_group = 100 if activity_group == -1
replace algorithm = 1 if random == 1 
replace y11 = 0 if y2 == 1 & y11 == .

*Productivity variable
forvalues y = 2014/2019 {
	
	cap drop productivity`y'
	gen productivity`y' = 100*turnover`y'/labor_inp`y'
	
}	

*Define firm age
cap drop firmage 
gen firmage = selectionyear - year_creation

gen evasion_cost1 = evasionvalue/y16
gen audit_yield = penalites_confirmation/y16 + 1
	replace audit_yield = 0 if y2 == 1 & audit_yield == . 
	

*Transform some variables (positive ones) in logs 
foreach v of varlist productivity* turnover* firmage durationcar distance evasion_cost1 audit_yield {
	replace `v' = log(`v' + 1)
	
}

*Create deciles of economic variables within bureau
forvalues y = 2014/2019 {
		
	foreach j in turnover productivity profitrate   {
	
	gen dec`j'`y' = 0
	
	qui sum numeric_bureau
	forvalues b  = 1/`r(max)' {
		
		xtile dectemp = `j'`y' if `j'`y' > 0 & numeric_bureau == `b' , nq(10)
		replace dec`j'`y' = dectemp if `j'`y' > 0 & numeric_bureau == `b'		
		drop dectemp
	
		}
	}	
}

*For each year, predict whether firm was selected by DGID based on 
	*whether firm was selected 1 year earlier, 2 years earlier (only for 2020)
	*whether firm is in top decile of turnover within tax unit 
	*whether firm presented losses 
	*whether firm declared CIT, VAT, CGU, IMP, EXP
	
drop selection20*
	
foreach y in 2018 2019 2020 {
	
gen y2VG`y' = 0 
replace y2VG`y' = 1 if y2 == 1 & selectionyear == `y' & typedecontrole_selection == "VG"	

gen y2CP`y' = 0 
replace y2CP`y' = 1 if y2 == 1 & selectionyear == `y' & typedecontrole_selection == "CP"
	
gen selectionVG`y' = 0 
replace selectionVG`y' = 1 if selectionyear == `y' & typedecontrole_selection == "VG"	

gen selectionCP`y' = 0 
replace selectionCP`y' = 1 if selectionyear == `y' & typedecontrole_selection == "CP"	
	
gen dgid`y' = 0 
replace dgid`y' = 1 if selectionyear == `y' & dgid == 1 

gen algorithm`y' = 0 
replace algorithm`y' = 1 if selectionyear == `y' & algorithm == 1

gen horsprogramme`y' = 0 
replace horsprogramme`y' = 1 if selectionyear == `y' & horsprogramme == 1 
	
gen audit`y' = 0 
replace audit`y' = 2 if anneeduchrono == `y' & controle == 2
replace audit`y' = 1 if anneeduchrono == `y' & controle == 1

}

*Create lags in different columns for the variables to be used in prediction (notice that the dataset is identified by audits, so they may happen in different years)
foreach v in y2VG selectionVG y2CP selectionCP decturnover decproductivity decprofitrate productivity profitrate TVA_filed TAF_filed  RAS_IRPP_filed MAN_filed IS_filed IMP_filed EXP_filed CGU_filed TVAAN_filed {
	
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

*Replace lagged turnover with earlier year if missing
replace L1turnover = log(L2turnover+1) if L1turnover == 0
replace L1turnover = log(L3turnover+1) if L1turnover == 0 
replace L1turnover = log(L0turnover+1) if L1turnover == 0 
drop L0*

foreach v of varlist L1* L2* L3*  firmage durationcar distance {
	gen miss_`v' = `v' == . 
	replace `v' = 0 if `v' == .
}

replace L1turnover  = . if L1turnover == 0 

foreach v in L1turnover L1profitrate L1productivity firmage durationcar distance {
	replace `v' = 0 if `v' == .
}

sa "$analysisdata/datasetforanalysis_predictionexercise_for_all_logs_exercise.dta", replace 


