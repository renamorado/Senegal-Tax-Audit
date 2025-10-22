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

	cd 	"$rawdata"

global datadir "Programme_2021\data_waste"
local files: dir "Programme_2021\data_waste" files * 
di `"`files'"'

cap noisily erase "Programme_2021\data_proc\fulltaxdataset.dta"
cap noisily erase "Programme_2021\data_proc\fulltaxdataset_temp.dta"

foreach f in `files'  {
	
    if strpos("`f'", "appended") > 0 {
	
	*Load data
	use "$datadir\\`f'", clear
	
	*Get tax name
	local tax = upper(subinstr("`f'", "_appended.dta", "", .))
	di "`tax'" 
	gen `tax'_declaration = 1 
	
	*Turn ninea to numerical (redundant in most cases)
	destring ninea, force replace 
	
	*If IS, correct year 
	if "`tax'" == "IS" {
		
		replace annee = annee - 1 
		
	}
	
	*Turn to numerical
	qui ds `tax'*
	foreach c in `r(varlist)' {
	    destring `c', force replace
	}

	*Choose between calculated and submitted
	cap noisily qui ds `tax'*_s 
	foreach c in `r(varlist)' {
		
		local newvar = subinstr("`c'", "_s", "", .)
		
	    destring `c', force replace
	    destring `newvar'_c, force replace

		*Choose the calculated, except when missing
		gen `newvar' = `newvar'_c
		replace `newvar' = `c' if `newvar' == .
		
		*Store labels to be used after collapse
		local l_`newvar': var label `c'
		
		drop `c' `newvar'_c
		
	}
		

	*Collapse 
	collapse (sum) `tax'* (count) `tax'_numberdeclarations = mois (mean) `tax'_filed = `tax'_declaration, by(ninea annee)
	drop `tax'_declaration 
	
	*Relabel
	qui ds `tax'* 
	foreach c in `r(varlist)' {	
		cap label var `c' "`l_`c''"
	}
	
	*Merge 
	cap noisily merge 1:1 ninea annee using "Programme_2021\data_proc\fulltaxdataset_temp.dta"
	cap drop _merge 
		
	*Save
	sa "Programme_2021\data_proc\fulltaxdataset_temp.dta", replace 
	
	}
	
}

*****
*Add repertoires and past audits (stored in Programme 2020)
merge m:1 ninea using "Programme_2020\data_proc\ListeAndRepertoires"
drop if _merge == 2 
drop _merge 

*add past audits
merge m:1 ninea using "Programme_2021\data_waste\PastAudits"
drop _merge

*Add data on fournisseurs/clients (FROM PREVIOUS YEAR: THEY ARE GENERATED IN DOFILES FOR TP DATA)
merge 1:1 ninea annee using Programme_2020\data_waste\clients_collapsed 
drop _merge 

merge 1:1 ninea annee using Programme_2020\data_waste\fournisseurs_collapsed
drop _merge 

*Add TVA Annexes data
merge 1:1 ninea annee using "Programme_2020\data_waste\AnnexesTVA_proc"
drop _merge 

*Add new TVA Annexes data
merge 1:1 ninea annee using "Programme_2021\data_waste\TVAAnnex2021"
drop if _merge == 2 
drop _merge 

sa  "Programme_2021\data_proc\fulltaxdataset", replace
cap noisily erase "Programme_2021\data_proc\fulltaxdataset_temp.dta"
