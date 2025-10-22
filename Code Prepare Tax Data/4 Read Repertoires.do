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
	
global dir = "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees de la banque de donnees fiscales new"

**********************
*List ANSD 
**********************

/*
import excel "$dir\ANSD Shortened .xlsx", firstrow clear 

	keep NUMERO_NINEA CODE_CENTRE_FISCAL LIBELLE_CENTRE_FISCAL DATE_CREATION_ENTREPRISE RAISON_SOCIALE ADRESSE
	
	gen ninea = NUMERO_NINEA
	ds ninea, not
	foreach v in `r(varlist)' {
	label var `v' "From ANSD List"
	rename `v' ANSD_`v' 
	}
	
	destring ninea, replace force 
	
	bys ninea: gen dup = cond(_N == 1, 0, _n)
	drop if dup > 1 
	drop dup 
	
	drop if ninea == . 
	
sa "Programme_2020\data_waste\ANSD", replace 	
*/

**********************
*List SIGTAS 
**********************

import excel "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Donnees SIGTAS\Liste actualisées des contribuables pour l'année 2020 avec le secteur activité.xlsx", firstrow clear 

keep NINEA CODE_CENTRE CENTRE TYPE_CONTRIBUABLE NOM_OU_RAISONSOCIALE SECTEUR_ACTIVITE ACTIVITE FORME_JURIDIQUE FISCAL_REGIME_NO REGIME_FISCAL ADRESSE TELMOB TELDOM TELTRAVAIL

gen TELEPHONE = ""
cap qui ds TELMOB TELDOM TELTRAVAIL
foreach v in `r(varlist)' {
cap tostring `v', force replace 
replace TELEPHONE = TELEPHONE + " ou " + `v' if TELEPHONE != "" & `v' != ""
replace TELEPHONE = `v' if TELEPHONE == ""
drop `v'
} 

	gen ninea = NINEA
	gen centre = CENTRE 

	ds ninea, not
	foreach v in `r(varlist)' {
	rename `v' SIGTAS_`v' 
	label var SIGTAS_`v' "From SIGTAS Liste of Taxpayers"
	}	
	
destring ninea, replace force 
	
	bys ninea: gen dup = cond(_N == 1, 0, _n)
	drop if dup > 1 
	drop dup 
	
	drop if ninea == . 
	
sa "Programme_2020\data_waste\SIGTAS_ListeContribuables", replace 	

**********************
*Repertoires 
**********************
global dir "Programme_2020\data_raw\dossier_DRSCF_13122019\Requetes_18112019\Repertoire des centres"

local DGEfile 	"$dir\Repertoire DGE à jour.xlsx"
local DGEdescription ", cellrange(A2) firstrow clear"
local DME1file 	"$dir\Répertoire du CME 1.xlsx"
local DME1description ", cellrange(A1:K727) firstrow clear"
local DME2file 	"$dir\Répertoire du CME 2.xlsx"
local DME2description ",  firstrow clear"
local CPRfile 	"$dir\REPERTOIRE DU CPR.xlsx"
local CPRdescription ", firstrow clear"
local DPfile 	"$dir\DP_ REPERTOIRE CONSOLIDE.xlsx"
local DPdescription ", firstrow clear"
local FATICKfile "$dir\Fatck_REPERTOIRE GENERAL.xlsx"
local FATICKdescription ", cellrange(A12) firstrow clear"
local RUFfile 	"$dir\Liste_des_contribuables_RUF_actualisée_2020.xls"
local RUFdescription ", cellrange(A2) firstrow clear"
local KOLDAfile "$dir\Kolda_CONTRIBUABLES KOLDA VELINGARA.xls"
local KOLDAdescription ", cellrange(B2) firstrow clear"
local LOUGAfile "$dir\Louga_fichier des contribuables.xlsx"
local LOUGAdescription ", cellrange(A1) firstrow clear"
*local NAfile "$dir\NGA_REPERTOIRE.xlsx"
*local NAdescription ", cellrange(A2) firstrow clear sheet(PERSONNES MORALES)"
local PIKINEfile "$dir\Pikine Guédiawaye_REPERTOIRE.xlsx"
local PIKINEdescription ", cellrange(A4) firstrow clear sheet(PROFESSIONNELS PIKINE)"
local GUEDIAWAYEfile "$dir\Pikine Guédiawaye_REPERTOIRE.xlsx"
local GUEDIAWAYEdescription ", cellrange(A2) firstrow clear sheet(PROFESSIONNELS GUEDIAWAYE)"

*Old repertoires 
local DPoldfile "Programme_2019\repertoires\CSF DE DAKAR PLATEAU REPERTOIRE CONSOLIDEclean.xlsx"
local DPolddescription ", firstrow clear" 
local GD1file "Programme_2019\repertoires\CSFGRAND DAKAR DOSSIER POUR LE CONTROLE.xlsx"
local GD1description ", firstrow sheet(UGF 1) clear" 
local GD2file "Programme_2019\repertoires\CSFGRAND DAKAR DOSSIER POUR LE CONTROLE.xlsx"
local GD2description ", firstrow sheet(UGF 2) clear" 
local GD3file "Programme_2019\repertoires\CSFGRAND DAKAR DOSSIER POUR LE CONTROLE.xlsx"
local GD3description ", firstrow sheet(UGF 3) clear" 
local NAfile "Programme_2019\repertoires\REPERTOIRE NGOR ALMADIES.xlsx"
local NAdescription ", cellrange(A2) firstrow clear sheet(PERSONNES MORALES)"

*Center
local DGEc 		"DGE"
local DME1c 	"DME 1"
local DME2c 	"DME 2"
local CPRc 		"CPR"
local DPc 		"DAKAR PLATEAU"
local FATICKc 	"FATICK"
local RUFc 		"RUFISQUE"
local MATAMc 	"MATAM"
local KOLDAc 	"KOLDA"
local LOUGAc 	"LOUGA" 
local DPoldc	"DAKAR PLATEAU" 
local GD1c		"GRAND DAKAR" 
local GD2c		"GRAND DAKAR" 
local GD3c		"GRAND DAKAR" 
local NAc		"NGOR ALMADIES" 
local PIKINEc	"PIKINE GUEDIAWAYE"
local GUEDIAWAYEc	"PIKINE GUEDIAWAYE"

*
foreach center in DGE DME1 DME2 CPR DP FATICK RUF KOLDA LOUGA DPold GD1 GD2 GD3 NA PIKINE GUEDIAWAYE {

display "`center'" 

import excel "``center'file'" ``center'description'

*Centre 
gen centre = "``center'c'"

*UGF
gen ugf = "" 
if strpos("`center'", "DP") > 0  {
cap replace ugf = SECTEUR
}
else if strpos("`center'", "GD") > 0 {
cap replace ugf = "UGF `center'"
}
else if strpos("`center'", "PIKINE") > 0 {
cap replace ugf = "PIKINE"
}
else if strpos("`center'", "GUEDIAWAYE") > 0 {
cap replace ugf = "GUEDIAWAYE"
}

cap replace ugf = BUREAUCONTRÔLE
cap replace ugf = UGF

*raison sociale
gen raisonsociale = "" 

cap noisily replace raisonsociale = NOMOURAISONSOCIALE
cap noisily replace raisonsociale = RAISONSOCIALE
cap noisily replace raisonsociale = RAISONSSOCIALES
cap noisily replace raisonsociale = Raisonsociale
cap noisily replace raisonsociale = Nom
cap noisily replace raisonsociale = NOMS

*Adresse et téléphones

gen adresse = ""
cap noisily replace adresse = ADRESSE
cap noisily replace adresse = Adresse
cap noisily replace adresse = Adr

foreach x in TELEPHONE NO_DE_TELEPHONE NODETELEPHONE Téléphone NUMTELSOCIETE POINTFOCAL{
cap tostring `x', force replace 
}

cap gen TELEPHONE = ""
cap noisily replace TELEPHONE = TELEPHONE 
cap noisily replace TELEPHONE = NO_DE_TELEPHONE
cap noisily replace TELEPHONE = NUMERO_TELEPHONE
cap noisily replace TELEPHONE = NUMEROTELEPHONE
cap noisily replace TELEPHONE = NODETELEPHONE 
cap noisily replace TELEPHONE = Téléphone 
cap noisily replace TELEPHONE = NUMTELSOCIETE 
cap noisily replace TELEPHONE = POINTFOCAL

local x ""
cap qui ds Téléphone*
local x "`r(varlist)'"
if "`x'" != "" {
foreach v in `x' {
cap tostring `v', force replace 
replace TELEPHONE = TELEPHONE + " ou " + `v' if TELEPHONE != "" & `v' != ""
replace TELEPHONE = `v' if TELEPHONE == ""
} 
}

local x ""
cap qui ds NUMEROTELEPHONE*
local x "`r(varlist)'"
if "`x'" != "" {
foreach v in `x' {
cap tostring `v', force replace 
replace TELEPHONE = TELEPHONE + " ou " + `v' if TELEPHONE != "" & `v' != ""
replace TELEPHONE = `v' if TELEPHONE == ""
} 
}

*Clean nineas 
gen ninea = NINEA
replace ninea = subinstr(ninea," ","",.)
replace ninea = subinstr(ninea,".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
destring ninea, replace force

*Economic activity 
gen activity = ""
cap noisily replace activity = ACTIVITE 
cap noisily replace activity = SECTEURSDACTIVITES 
cap noisily replace activity = SecteurActivité 

keep ninea raisonsociale centre ugf activity  TELEPHONE adresse

sort ninea raisonsociale centre ugf activity  

by ninea: gen dup = cond(_N == 1, 0, _n)
drop if dup > 1 
drop dup 

sa "Programme_2020\data_waste\Repertoire_`center'.dta", replace 

}

**********************
*Append 
**********************
*Dakar Plateau 
use "Programme_2020\data_waste\Repertoire_DP.dta", clear
merge 1:1 ninea using "Programme_2020\data_waste\Repertoire_DPold.dta", update replace 
drop _merge 
sa "Programme_2020\data_waste\Repertoire_DPmerge.dta", replace

*We append and exclude duplicated, giving preference to what appeared first. 

local i = 0 
clear 
foreach center in DGE DME1 DME2 CPR DPmerge FATICK RUF KOLDA LOUGA GD1 GD2 GD3 NA  PIKINE GUEDIAWAYE {

local ++i 

cap noisily append using "Programme_2020\data_waste\Repertoire_`center'.dta"

cap replace order = `i'
cap sort ninea order 

cap by ninea: gen dup = cond(_N == 1, 0, _n)
cap drop if dup > 1 
cap drop dup 

cap noisily use "Programme_2020\data_waste\Repertoire_`center'.dta"

cap gen order = `i'
}

qui ds ninea, not 
foreach v in `r(varlist)' { 
label var `v' "From repertoires" 
rename `v' REP_`v' 
}

cap destring ninea, replace force 
	
	bys ninea: gen dup = cond(_N == 1, 0, _n)
	drop if dup > 1 
	drop dup 
	
	drop if ninea == . 

sa "Programme_2020\data_waste\Repertoires.dta", replace 

**********************
*Merge all 
**********************
use "Programme_2020\data_waste\Repertoires.dta", clear
merge 1:1 ninea using  "Programme_2020\data_waste\SIGTAS_ListeContribuables"
drop _merge 
merge 1:1 ninea using  "Programme_2020\data_waste\ANSD"
drop _merge 

sa "Programme_2020\data_proc\ListeAndRepertoires.dta", replace 

	
