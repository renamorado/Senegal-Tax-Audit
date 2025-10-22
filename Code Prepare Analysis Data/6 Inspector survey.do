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
		global code "$rootdir\Analysis all data\replication_package\Code Prepare Analysis Data"

local date: disp  c(current_date)
di "`date'"
set scheme s1color

******************************************************************
*Read matricules of inspectors
******************************************************************
*Sheet of inspectors
import excel "$rawdata\Inspector survey instruments and admin\Sampling frame\DAP PERSONNEL INSP ET CONTROLEURS AVEC DATE DERNIERE AFFECTATION.xlsx", clear cellrange(A4) sheet("INSPECTEURS")

rename A No 
rename B prenom 
rename C nom 
rename D matricule
rename E day
rename F month
rename G year
rename H age
rename I bureau
rename J lastchange

drop K L M N O
drop if matricule == ""
gen  verificateur = prenom + " " + nom 
replace verificateur = ustrupper( ustrregexra( ustrnormalize(verificateur, "nfd" ) , "\p{Mark}", "" ) )	
replace verificateur = subinstr(verificateur, "  ", " ", .)
replace verificateur = subinstr(verificateur, ".", "", .)
replace verificateur = subinstr(verificateur, ",", "", .)

replace matricule = subinstr(matricule, " ", "", .)
replace matricule = subinstr(matricule, ".", "", .)
replace matricule = subinstr(matricule, ",", "", .)
replace matricule = subinstr(matricule, "/", "", .)
replace matricule = upper(matricule)

keep matricule verificateur age
bys matricule: gen  n = _n
keep if n == 1 
drop n

tempfile ver 
sa `ver', replace 

*Sheet of controleurs
import excel "$rawdata\Inspector survey instruments and admin\Sampling frame\DAP PERSONNEL INSP ET CONTROLEURS AVEC DATE DERNIERE AFFECTATION.xlsx", clear cellrange(A4) sheet("CONTROLEURS")

rename A No 
rename B prenom 
rename C nom 
rename D matricule
rename E day
rename F month
rename G year
rename H age
rename I bureau
rename J lastchange

drop if matricule == ""
gen  verificateur = prenom + " " + nom 
replace verificateur = ustrupper( ustrregexra( ustrnormalize(verificateur, "nfd" ) , "\p{Mark}", "" ) )	
replace verificateur = subinstr(verificateur, "  ", " ", .)
replace verificateur = subinstr(verificateur, ".", "", .)
replace verificateur = subinstr(verificateur, ",", "", .)

replace matricule = subinstr(matricule, " ", "", .)
replace matricule = subinstr(matricule, ".", "", .)
replace matricule = subinstr(matricule, ",", "", .)
replace matricule = subinstr(matricule, "/", "", .)
replace matricule = upper(matricule)

keep matricule verificateur age
bys matricule: gen  n = _n
keep if n == 1 
drop n

tempfile cont 
sa `cont', replace 

*Sheet of inspecteurs
import excel "$rawdata\Inspector survey data and analysis\data\Matricules.xlsx", firstrow clear

rename Vérificateur1 matricule 
rename NomVérificateu verificateur

replace verificateur = upper(verificateur)
replace verificateur = trim(verificateur)
replace verificateur = ustrupper( ustrregexra( ustrnormalize(verificateur, "nfd" ) , "\p{Mark}", "" ) )	

*Correct some matricules to maximize match
replace matricule = "611439G" if matricule == "611439D"
replace matricule = "611481I" if matricule == "611481L"
replace matricule = "624460J" if matricule == "624460"
replace matricule = "624517C" if matricule == "624517Z"
replace matricule = "653054E" if matricule == "653054"

tempfile matricule
sa `matricule', replace 

*Put all lists together
use `ver', clear 
append using `cont'
bys matricule: gen  n = _n
keep if n == 1 
drop n

merge 1:1 matricule using `matricule', replace update
drop _merge

tempfile matricule
sa `matricule', replace 

*****************************************
*Read inspector survey
*****************************************
use "$rawdata\Inspector survey data and analysis\data\base_finale2", clear 

replace id_rep = upper(id_rep)

rename id_rep matricule  
merge 1:1 matricule using  `matricule'
drop _merge

*Add some names to matricules (found internally with DGID by Mbacké)
replace verificateur = "IBRAHIMA DIOME" if matricule == "616201H"
replace verificateur = "EL MOMATH SECK" if matricule == "624509G"
replace verificateur = "MADELEINE AWA GUIGNANE DIOP" if matricule == "653054E"
replace verificateur = "ABLAYE LO" if matricule == "661317H"
replace verificateur = "PAPE DIENE NGOM" if matricule == "611439D"
replace verificateur = "OUSSEYNOU DIOUF" if matricule == "611481"
replace verificateur = "DAOUDA THIAM" if matricule == "624460"
replace verificateur = "IBRAHIMA SARR" if matricule == "624517Z"

replace verificateur = ustrtrim(verificateur)
bys verificateur: gen N = _N
drop if N > 1 & id_enq == . 
drop N
bys verificateur: gen n = _n
replace verificateur = matricule if (verificateur == "" | n > 1) & id_enq != .
drop n

clonevar originalname = verificateur

quietly {
	do "$code/AUX Clean verificateur names.do"
}

sa "$analysisdata/inspectorsurvey", replace 
