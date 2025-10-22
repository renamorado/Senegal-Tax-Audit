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
		global code "$rootdir\Analysis all data\replication_package\Code Read data"

local date: disp  c(current_date)
di "`date'"
set scheme s1color

cd "$rawdata"
global dir = "$rawdata\Programme_2019\raw_data"

**************************************************************
**************************************************************
*First batch (data transmitted in 2019)
**************************************************************
**************************************************************

*Previous years

*Which years every tax has
local yearsImportations "2014 2015 2016 2017 2018"
local yearsExportations "2014 2015 2016 2017"
local yearsMandats "2014 2015 2016 2017"

foreach t in  "Exportations" "Mandats" "Importations" {

cap erase "Programme_2021\data_waste\\`t'_firstbatch.dta"

	foreach d in `years`t'' {
	
		import delimited "$dir\\`t'_`d'.csv", delimiter(tab) varnames(1) clear 
		
		cap drop annee
		cap drop mois
		
		cap gen annee = "`d'"
		cap tostring annee, replace force
		gen ninea = ninea_beneficiaire
		tostring ninea , replace force 
		cap gen raisonsociale = raison_sociale_beneficiaire
		cap gen valeur = valeur
		cap gen valeur = montant
		destring valeur, replace force 
		
		gen pays = ""
		cap replace pays = pays_de_destination
		cap replace pays = pays_origine
		
		cap noisily gen date_temp = date(date_declaration, "DMY")
		cap noisily gen date_temp = date(date_reception_au_tresor, "DMY")

		gen mois = month(date_temp)
		
		keep annee mois ninea raisonsociale valeur pays
		
		cap noisily append using "Programme_2021\data_waste\\`t'_firstbatch.dta", force
		sa "Programme_2021\data_waste\\`t'_firstbatch.dta", replace
		
	}
}

*Exportations 2018 (there was a problem with the original csv file and I transformed it in a txt file) 
	import delimited "$dir\Exportations_2018.txt", delimiter(tab) varnames(1) clear 
		
		cap drop annee
		cap drop mois
		gen annee = "2018"
		
		cap gen ninea = ninea_beneficiaire
		tostring ninea, replace force 
		cap gen raisonsociale = raison_sociale_beneficiaire
		cap gen valeur = valeur
		cap gen valeur = montant	
		destring valeur, replace force 
		
		gen pays = ""
		cap replace pays = pays_de_destination
		cap replace pays = pays_de_destination
		
		cap noisily gen date_temp = date(date_declaration, "DMY")
		cap noisily gen date_temp = date(date_reception_au_tresor, "DMY")

		gen mois = month(date_temp)
		
		keep annee mois ninea raisonsociale valeur pays
	
	append using "Programme_2021\data_waste\Exportations_firstbatch.dta", force
	sa "Programme_2021\data_waste\Exportations_firstbatch.dta", replace
	
*Mandats 2018
import excel "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees de la banque de donnees fiscales_Old\Détail_des_mandats_2018.xls", cellrange(A2) firstrow clear 
gen annee = "2018"

		cap drop annee
		cap drop mois
		gen annee = "2018"
		
		cap gen ninea = Nineabénéficiaire
		tostring ninea, replace force 
		cap gen raisonsociale = Raisonsocialebénéficiaire
		cap gen valeur = valeur
		cap gen valeur = Montant	
		destring valeur, replace force 
		
		gen pays = ""
		cap replace pays = pays_de_destination
		cap replace pays = pays_de_destination
		
		cap noisily gen date_temp = date(date_declaration, "DMY")
		cap noisily gen date_temp = date(DateRéceptionauTrésor, "DMY")

		gen mois = month(DateRéceptionauTrésor)
		
		keep annee mois ninea raisonsociale valeur pays

	append using "Programme_2021\data_waste\Mandats_firstbatch.dta", force
	sa "Programme_2021\data_waste\Mandats_firstbatch.dta", replace

**************************************************************
**************************************************************
*Second batch (data transmitted in 2020)
**************************************************************
**************************************************************

*Batch of 2020 (declarations of 2018 and 2019)
global dir = "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees de la banque de donnees fiscales new"

foreach t in importations exportations {
	
	cap erase "Programme_2021\data_waste\\`t'_secondbatch.dta"
	
	forvalues y = 2018/2019 {
	cap import excel "$dir\Detail_`t'_douanieres_`y'.xlsx", firstrow clear 
	
	gen str annee = "`y'"
	gen ninea = NINEA_BENEFICIAIRE
	tostring ninea, replace force 
	cap gen raisonsociale = RAISON_SOCIALE_BENEFICIAIRE
	cap gen valeur = VALEUR
	destring valeur, replace force 	
	cap gen pays_origine = PAYS_ORIGINE
	cap tostring pays_origine, replace force 
	cap label var pays_origine "Country where import originated" 
	
	cap noisily append using "Programme_2021\data_waste\\`t'_secondbatch.dta", force
	sa "Programme_2021\data_waste\\`t'_secondbatch.dta", replace

	}
}

**************************************************************
**************************************************************
*Third batch (data transmitted in 2021)
**************************************************************
**************************************************************
global datadir "Programme_2021\data_raw\Extractions 2021"
local files: dir "Programme_2021\data_raw\Extractions 2021" files *

foreach tax in  "Importations" "Exportations" "Mandats" {

clear 
cap noisily erase "Programme_2021\data_waste\\`tax'_thirdbatch.dta"

	foreach f in `files' {
	    global filename "`f'"
		di "`f'"
		local min = lower("`tax'")
		
		if strpos("`f'", "t_`min'_") > 0 {
			import excel "$datadir\\`f'", cellrange(A1) firstrow clear
			
			*key variables
			local year = subinstr("`f'", ".xlsx", "", .)
			gen year = substr("`year'", length("`year'") - 3, length("`year'"))
			
			*Store file name
			gen filename = "$datadir\\`f'"
				
			*date	
			cap noisily gen annee = ANNEE_DEC
			
			*Store everything (except lines) as strings
			qui ds
			foreach v in `r(varlist)' {
				tostring `v', force replace
				local newname = lower("`v'")
				rename `v' `newname'

			}
			
			cap gen ninea = ninea_b
			tostring ninea, replace force 
			cap gen raisonsociale = raison_sociale_beneficiaire
			cap gen valeur = valeur
			cap gen valeur = montant	
			destring valeur, replace force 
			
			gen pays = ""
			cap replace pays = pays_de_destination
			cap replace pays = pays_origine
			
			keep annee ninea raisonsociale valeur pays date*
			
			cap noisily append using "Programme_2021\data_waste\\`tax'_thirdbatch"
			save "Programme_2021\data_waste\\`tax'_thirdbatch", replace 
			sleep 500
		}
	}
}

**************************************************************
**************************************************************
*Append 
**************************************************************
**************************************************************

foreach tax in  "Exportations"  "Importations" "Mandats"  {
	
	*Obs Start with first batch, keep years 2014 qnd 2015, and add third batch, which contains all following years
	use "Programme_2021\data_waste\\`tax'_firstbatch.dta", clear
	keep if annee == "2015" |  annee == "2014"
	append using "Programme_2021\data_waste\\`tax'_thirdbatch.dta", force
	
	if "`tax'" != "Importations" {
	drop pays
	}
	drop date*
	
	if "`tax'" == "Importations" {
	gen faibleimposition = 0 
	label var faibleimposition "Imports coming from countries with low taxes" 

	foreach x in "AD" "AI" "AW"  "AF" "BH" "BS" "BB" "BZ" "VG" "CK" "DM" "GI" "GD" "LR" "LI" "MV" "MH" "MC" "MS" "NR" "AN" "NU" "PA" "WS" "SC" "LC" "KN" "VC" "TO" "VU" "TC" "VI" {
			replace faibleimposition = valeur if strpos(pays, "`x'") > 0 
		}
	}

	*Rename
	local taxname = upper("`tax'")
	rename valeur `taxname'_valeur
	cap rename pays `taxname'_pays
	cap rename faibleimposition  `taxname'_faibleimposition
	destring annee, replace force 
	drop if annee < 2000 | annee > 2021	
		
	sa "Programme_2021\data_waste\\`tax'_appended.dta", replace 

}

foreach tax in  "Exportations"  "Importations" "Mandats"  {
	cap erase "Programme_2021\data_waste\\`tax'_thirdbatch.dta"
	cap erase "Programme_2021\data_waste\\`tax'_secondbatch.dta"
	cap erase "Programme_2021\data_waste\\`tax'_firstbatch.dta"	
}

******************************************************************
******************************************************************
*THIRD PARTY DATA ON REVENUES AND SALES
******************************************************************
******************************************************************

**********************
*Read clients and suppliers
**********************
global dir = "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees de la banque de donnees fiscales new"

*Clients and suppliers 
foreach t in clients fournisseurs {
	import excel "$dir\Total_chiffre_d'affaires_estimé_des_`t'.xls", firstrow clear 
	
	cap gen ninea = NineaBénéficiaire
	cap gen ninea = Ninea
	tostring ninea, replace force 
	cap gen annee = AnnéeRecoupement
	tostring annee, replace force
	cap gen raisonsociale = Dénomination
	
	sa "Programme_2020\data_waste\\`t'", replace 
	
}

**********************
*2 Clean, rename variables and append: Importations, Exportations, Mandats
**********************

local clients "clients"
local fournisseurs "fournisseurs"

foreach dataset in  clients fournisseurs  {
clear

	foreach t in ``dataset'' {

	cap noisily append using "Programme_2020\data_waste\\`t'", force
	cap noisily use "Programme_2020\data_waste\\`t'"

	}

display "Check if `dataset' is fine"
tab annee 
sleep 1000

*Clean nineas 
replace ninea = subinstr(ninea," ","",.)
replace ninea = subinstr(ninea,".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
destring ninea, replace force

*Rename variables
local name = substr("`dataset'", 1, 3)
local name = upper("`name'")

qui ds ninea annee, not

foreach v in `r(varlist)' {
local newname = substr("`name'_`v'", 1, 32)
rename `v' `newname'
}


*Only for imports: get the amount of imports from low tax jurisdictions
	if "`dataset'" == "importations" {
		gen IMP_faibleimposition = 0 
		label var IMP_faibleimposition "Imports coming from countries with low taxes" 

		foreach x in "CN" "AD" "AI" "AF" "BS" "BH" "BB" "BZ" "BM" "VG" "CR" "CY" "DJ" "DM" "GI" "GD" "HK" "IE" "JO" "LB" "LR" "LU" "MV" "MH" "MU" "MS" "NR" "AN" "PA" "WS" "SM" "SG" "CH" "TO" "VU" {
			replace IMP_faibleimposition = IMP_valeur if strpos(IMP_pays_origine, "`x'") > 0 
		}
	}

sa 	"Programme_2020\data_waste\\`dataset'_appended", replace

}

**********************
*3 Collapse 
**********************

foreach dataset in clients fournisseurs  {

use "Programme_2020\data_waste\\`dataset'_appended", clear

	*Keep only necessary variables (this will work only for imports, exports and mandats)
	cap keep ninea annee IMP_raisonsociale IMP_valeur IMP_pays_origine
	cap keep ninea annee EXP_raisonsociale EXP_valeur 
	cap keep ninea annee MAN_raisonsociale MAN_valeur


	qui ds ninea *raisonsociale annee, not 
	foreach v in `r(varlist)' { 
	destring `v', force replace 
	}

	*save raisonsociale 
	preserve

	*Rename variables
	local name = substr("`dataset'", 1, 3)
	local name = upper("`name'")
	
	keep ninea *raisonsociale
	gsort ninea - `name'_raisonsociale
	by ninea: gen dup = cond(_N==1, 0, _n)
	drop if dup > 1
	drop dup 
	
	tempfile raison
	sa `raison', replace
	restore
	
	*save labels 
	qui ds
	foreach v in `r(varlist)' { 
	local label`v': variable label `v'
	}
	
	*destring year
	destring annee, replace force 
	
	*collapse by year
	qui ds ninea *raisonsociale annee, not 
	collapse (sum) `r(varlist)', by (ninea annee)
	
	merge n:1 ninea using `raison'
	drop _merge 
	
	*relabel variables 
	qui ds
	foreach v in `r(varlist)' { 
	label var `v' "`label`v''"
	}

	*filed 
	gen `dataset'_filed = 1 
	
sa 	"Programme_2020\data_waste\\`dataset'_collapsed", replace

}