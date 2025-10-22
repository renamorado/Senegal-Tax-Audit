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
	if strpos("`c(username)'","User") { 										// Alipio's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}


		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

set excelxlsxlargefile on

**************************************************************
**************************************************************
*First batch (data transmitted in 2019)
**************************************************************
**************************************************************
cd "$rawdata"

set excelxlsxlargefile on

global datadir "Programme_2019\raw_data"
local files: dir "Programme_2019\raw_data" files *

di `"`files'"'

foreach tax in "TAF" "TVA" "RAS_IRPP" "RAS_SVT" "CGU" "IS"  {

clear 
cap noisily erase "Programme_2021\data_waste\\`tax'_firstbatch.dta"

	foreach f in `files' {
	    global filename "`f'"
		di "`f'"
		local min = lower("`tax'")
		
		if strpos("`f'", "declarations_`min'") > 0 {
		    
			if strpos("`f'", "corporate_income_tax") == 0 {
			import excel "$datadir\\`f'", cellrange(A2) firstrow clear
			}
			if strpos("`f'", "corporate_income_tax") > 0 {
			import excel "$datadir\\`f'", cellrange(A4) firstrow clear
			}
			
			local renamefile = subinstr("`f'", ".xlsx", "", .)
			local renamefile = subinstr("`renamefile'", "declarations_", "", .)
			local renamefile = upper("`renamefile'")
			
			do "Programme_2021\dofiles\Renaming dofiles\Rename_`renamefile'_old.do"
			
			*Store file name
			gen filename = "$datadir\\`f'"

			*Store everything (except lines) as strings
			qui ds L*, not
			foreach v in `r(varlist)' {
				tostring `v', force replace
			}				

			cap noisily append using "Programme_2021\data_waste\\`tax'_firstbatch"
			save "Programme_2021\data_waste\\`tax'_firstbatch", replace 
			sleep 500
		}
	}
}

**************************************************************
**************************************************************
*Second batch (data transmittedin 2020)
**************************************************************
**************************************************************

*Batch of 2020 (declarations of 2018 and 2019)
global dir = "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees SIGTAS"

foreach t in RAS_IRPP IS RAS_TIERS CGU  {
	
	cap erase "Programme_2021\data_waste\\`t'_secondbatch.dta"

	forvalues year = 2018/2019 {
	cap import excel "$dir\Dec_`t'_2018_2019.xlsx", sheet("Dec_`t'_`year'") firstrow clear 	
	
	*Rename variables 
	cap noisily do "Programme_2021\dofiles\Renaming dofiles\Rename_`t'_`year'.do"
	
	*Generate variable year to be sure where the data comes from
	gen year = `year'
	gen filename = "$dir\Dec_`t'_2018_2019.xlsx"

	*Store everything (except lines) as strings
	qui ds L*, not
	foreach v in `r(varlist)' {
		tostring `v', force replace
	}		

	*Append
	cap noisily append using "Programme_2021\data_waste\\`t'_secondbatch", force
	
	sa "Programme_2021\data_waste\\`t'_secondbatch", replace 
	}
}

use "Programme_2021\data_waste\RAS_TIERS_secondbatch", clear
sa "Programme_2021\data_waste\RAS_SVT_secondbatch", replace 
erase "Programme_2021\data_waste\RAS_TIERS_secondbatch.dta"


foreach t in TAF {
	
	cap erase "Programme_2021\data_waste\\`t'_secondbatch.dta"

	forvalues year = 2018/2019 {
	import excel "$dir\Dec_`t'_2018_2019.xlsx", sheet("`t'_`year'") firstrow clear 	
	
	*Rename variables 
	cap do "Programme_2021\dofiles\Renaming dofiles\Rename_`t'_`year'.do"
	
	*Generate variable year to be sure where the data comes from
	gen year = `year'
	gen filename = "$dir\Dec_`t'_2018_2019.xlsx"

	*Store everything (except lines) as strings
	qui ds L*, not
	foreach v in `r(varlist)' {
		tostring `v', force replace
	}		

	cap noisily append using "Programme_2021\data_waste\\`t'_secondbatch", force
		
	sa "Programme_2021\data_waste\\`t'_secondbatch", replace 
	
	}
}


foreach t in TVA {
	
	cap erase "Programme_2021\data_waste\\`t'_secondbatch.dta"

	forvalues year = 2018/2019 {
		
	local i = 0 
		foreach y in Dec_TVA_DGE_DME_ Dec_TVA_DP_DL_NGA_ Dec_TVA_GRD_PIK_RUF_ Dec_TVA_MTM_PAS_GUE_ZIG_ Dec_TVA_DBL_STL_KLK_THS_ Dec_TVA_LGA_KLD_FTK_MBR_TA_ {
		local ++i
		import excel "$dir\Dec_`t'_`year'.xlsx", sheet("`y'`year'") firstrow clear 	
		
		*Rename variables 
		cap do "Programme_2021\dofiles\Renaming dofiles\Rename_`t'_`year'_`i'.do"		

		*Generate variable year to be sure where the data comes from
		gen year = `year'
		gen office = "`y'"
		gen filename = "$dir\Dec_`t'_`year'.xlsx"
		
		*Store everything (except lines) as strings
		qui ds L*, not
		foreach v in `r(varlist)' {
			tostring `v', force replace
		}		
		
		*Append
		cap noisily append using "Programme_2021\data_waste\\`t'_secondbatch", force
	
		sa "Programme_2021\data_waste\\`t'_secondbatch", replace 
		
		}
	}
}

**************************************************************
**************************************************************
*Third batch (data transmitted in 2021)
**************************************************************
**************************************************************

global datadir "Programme_2021\data_raw\Extractions 2021"
local files: dir "Programme_2021\data_raw\Extractions 2021" files *

foreach tax in  "IS" "RAS_REDEVANCES_TIERS" {

clear 
cap noisily erase "Programme_2021\data_waste\\`tax'_thirdbatch.dta"

	foreach f in `files' {
	    global filename "`f'"
		di "`f'"
		local min = lower("`tax'")
		
		if strpos("`f'", "cotisations_`min'") > 0 {
			import excel "$datadir\\`f'", cellrange(B3) firstrow clear
			do "Programme_2021\dofiles\Renaming dofiles\Rename `tax' 2021.do"
			
			*Store file name
			gen filename = "$datadir\\`f'"
			
			*Store everything (except lines) as strings
			qui ds L*, not
			foreach v in `r(varlist)' {
				tostring `v', force replace
			}
			
			cap noisily append using "Programme_2021\data_waste\\`tax'_thirdbatch"
			save "Programme_2021\data_waste\\`tax'_thirdbatch", replace 
			sleep 500
		}
	}
}

use "Programme_2021\data_waste\RAS_REDEVANCES_TIERS_thirdbatch", clear
sa "Programme_2021\data_waste\RAS_SVT_thirdbatch", replace 
erase "Programme_2021\data_waste\RAS_REDEVANCES_TIERS_thirdbatch.dta"

**************************************************************
**************************************************************
*Append 
**************************************************************
**************************************************************


foreach tax in "TAF" "TVA" "RAS_IRPP" "RAS_SVT" "CGU"  "IS" {
	
	*Obs: start with third batch because variables are correctly labelled and labels do not get overwritten by append 
	use "Programme_2021\data_waste\\`tax'_thirdbatch.dta", clear
	append using "Programme_2021\data_waste\\`tax'_secondbatch.dta", force
	append using "Programme_2021\data_waste\\`tax'_firstbatch.dta", force

	*Clean and drop duplicates 
	cap tostring annee, replace force
	cap gen annee = ""
	cap noisily replace annee = Année if annee == ""
	cap noisily replace annee = ANNEE if annee == ""
	cap noisily replace annee = year if annee == ""
	cap noisily replace annee = substr(Période, length(Période) - 3, length(Période)) if annee == ""
	destring annee, replace force	
		
	cap tostring mois, replace force
	cap gen mois = ""	
	cap noisily replace mois = Mois if mois == ""
	cap noisily replace mois = MOIS if mois == ""
	cap noisily replace mois = substr(Période, 1 , strpos(Période, "-") - 1) if mois == ""
	replace mois = "" if mois == "."
	replace mois = "0" if mois == ""
	destring mois, replace force

	cap tostring bureau, replace force
	cap gen bureau = ""
	cap noisily replace bureau = CSF_COTIS  if bureau == ""
	cap noisily replace bureau = CSF_CONTRIB if bureau == ""
	cap noisily replace bureau = Centredecotisation if bureau == ""
	cap noisily replace bureau = CSF_COT if bureau == ""
	cap noisily replace bureau = Centre if bureau == ""

	cap tostring raisonsociale, replace force
	cap gen raisonsociale = ""
	replace raisonsociale = Raisonsociale if raisonsociale == ""
	replace raisonsociale = RAISON_SOCIALE if raisonsociale == ""

	cap tostring ninea, replace force
	cap gen ninea = ""
	replace ninea = NINEA if ninea == ""
	destring ninea, replace force

	drop if ninea == . & raisonsociale == ""

	cap noisily gen mont_a_payer = ""
	foreach c in Montantàpayer MontantApayer MONT_A_PAYER {
		cap tostring `c', force replace
		cap replace mont_a_payer = `c' if mont_a_payer == ""	
		cap drop `c'
	}

	cap noisily gen mont_paye = ""
	foreach c in Montantpayé Montantpayé MONT_PAYE {
		cap tostring `c', force replace
		cap replace mont_paye = `c' if mont_paye == ""	
		cap drop `c'
	}

	cap noisily gen mont_credit = ""
	foreach c in Montantcrédit  Crédit CREDIT {
		cap tostring `c', force replace
		cap replace mont_credit = `c' if mont_credit == ""	
		cap drop `c'
	}

	cap noisily gen mont_paye_sur_period = ""
	foreach c in Montantpayésurpériode PAYE_SUR_PERIOD MONT_PAYE_SUR_PERIOD {
		cap tostring `c', force replace
		cap replace mont_paye_sur_period = `c' if mont_paye_sur_period == ""	
		cap drop `c'
	}

	*Correct variables for SVT
	cap replace L10_s = L10_MONTBRUTRES_SENEGAL_S if L10_s == . & L10_MONTBRUTRES_SENEGAL_S != .
	cap replace L10_c = L10_MONTBRUTRES_SENEGAL_C if L10_c == . & L10_MONTBRUTRES_SENEGAL_C != .
	cap replace L20_s = L20_MONTBRUTRES_LOYER_S if L20_s == . & L20_MONTBRUTRES_LOYER_S != .
	cap replace L20_c = L20_MONTBRUTRES_LOYER_C if L20_c == . & L20_MONTBRUTRES_LOYER_C != .
	cap replace L30_s = L30_TOTALSOMMESVERSEES_S if L30_s == . & L30_TOTALSOMMESVERSEES_S != .
	cap replace L30_c = L30_TOTALSOMMESVERSEES_C if L30_c == . & L30_TOTALSOMMESVERSEES_C != .
	
	*Duplicates drop
		*Drop if there is more recent data
		cap drop N
		bys ninea annee mois: gen N = _N
		gen data2021 = strpos(filename, "rogramme_2021") > 0 
		bys ninea annee mois: egen data2021check = max(data2021)
		drop if data2021check == 1 & N > 1 & strpos(filename, "rogramme_2021") == 0 
		
		drop N data2021check data2021
		
		bys ninea annee mois: gen N = _N
		gen data2020 = strpos(filename, "rogramme_2020") > 0 
		bys ninea annee mois: egen data2020check = max(data2020)
		drop if data2020check == 1 & N > 1 & strpos(filename, "rogramme_2020") == 0 

		drop N data2020check data2020
		
		*Drop duplicates (wherever possible, keep declaration with higher turnover, L5_c)
		sort ninea annee mois
		cap gsort ninea annee mois -L5_c
		by ninea annee mois: gen n = _n

		drop if n > 1 
		
	*Label variables (only part of the lines are labelled)
	qui ds L*_s 
	foreach c in `r(varlist)' {
		
		local l: var label `c'
		local newvar = subinstr("`c'", "_s", "_c", .)
		label var `newvar' "`l' calculated"
		
	} 

	qui ds L* mont* 
	foreach c in `r(varlist)' {
		destring `c', replace force
		cap noisily rename `c' `tax'_`c'
	
	} 
	
	*Keep only relevant variables
	keep annee mois bureau ninea raisonsociale  filename `tax'_*	
	order annee mois bureau ninea raisonsociale  filename `tax'_* 

	sa "Programme_2021\data_waste\\`tax'_appended.dta", replace 
	
}