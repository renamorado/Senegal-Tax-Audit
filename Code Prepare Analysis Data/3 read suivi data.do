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

**********************************************************************************************************************
*Complement audits data with suivi data
**********************************************************************************************************************

**********************************************************************		
*2018 Suivi Data
**********************************************************************
use "$rawdata\Analyse des resultats du Programme_2018\Alipio\datasetprogramme2018", clear

*Drop cases that are not completed audits 
keep if y2 == 1 

*Clean variables
rename nom_verificateur01 Vérificateur1 
keep if controle != . 

rename selected_algorithme algorithm
rename selected_DGID DGID
rename selected_random random 
gen horsprogramme = engaged_suivi == 1 
replace DGID = 0 if horsprogramme == 1 

gen annee = 2018

drop controle
rename fullaudits controle
replace controle = controle + 1 

rename ds_notification Droitssimples_Notification
rename p_notification Pénalités_Notification
rename ds_confirmation Droitssimples_Confirmation
rename p_confirmation Pénalités_Confirmation

gen center = "CGE" if direction == 1
replace center = "CME 1" if bureau == 5
replace center = "CME 2" if bureau== 6
replace center = "CPR" if bureau== 7

keep ninea raison_sociale riskscore algorithm DGID random horsprogramme Droits* Pénalit* audited2013 audited2014 audited2015 audited2016 center annee controle Vérificateur1 date* information*

replace controle = 1 if controle == . 
isid ninea controle annee

tempfile an2018
sa `an2018', replace 		

**********************************************************************		
*2019 Suivi Data
**********************************************************************
use "$rawdata\Analyse des resultats du Programme_2019\Proc_data\programme2019resultats.dta", clear

rename verificateur01 Vérificateur1

*Drop cases that are not completed audits 
drop if file == ""
egen testmissing = rowtotal(ds* p_*)
drop if testmissing == 0 & Vérificateur1 == ""

gen test = testmissing == 0 

foreach d of varlist date_de_demarrage date_demande_information date_avis date_notification reponses_contribuable dossier_abandonne contribuable_introuvable utilite_information_fournies raison_abandon { 
	
	clonevar `d'2 = `d'
	tostring `d'2, force replace 
 	cap noisily replace test = 0 if `d'2 != "" & `d'2 != "."
	drop `d'2
}

drop if test == 1 
drop test testmissing 

*Clear variable for center
gen center = ""

local l = 0 
foreach c in "CME 1" "CME 2" "CPR" "DAKAR PLATEAU" "GRAND DAKAR" "NGOR ALMADIES" "PIKINE GUEDIAWAYE" {
	local ++l 
	
	replace center = "`c'" if bureau == `l'
	
}

gen annee = 2019

*Variable for method
gen DGID = selectionmethod == 1 | selectionmethod == 3
gen algorithm = selectionmethod == 2 | selectionmethod == 3  | selectionmethod == 5 | selectionmethod == 4
gen random =  selectionmethod == 4
replace algorithm = 0 if random == 1
label var random "Random audits"
gen horsprogramme = numero == "Hors programme" 
replace horsprogramme = 0 if algorithm == 1 

order ninea numero raison_sociale controle bureau

*risk score
rename  RS_FY1417_TOTAL_LOGAVREV riskscore
lab var riskscore "Risk score 2019 (weighted by log av turnover)"

*RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6 RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5 RS_FY1417_ATAF1 RS_FY1417_ATAF2 RS_FY1417_ATAF4 RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5 RS_FY1417_I3 RS_FY1417_inconsistencies RS_FY1417_anomalies

*evasion variable
egen evasion = rowmax(ds_confirmation_somme ds_perception_somme)
lab var evasion "Evasion: max(ds_confirmation_somme, ds_perception_somme)"

gen s = evasion/ds_notification_somme
bys controle bureau: egen deduction_share = mean(s)
replace evasion = deduction_share*ds_notification_somme if evasion == . 
		
gen Droitssimples_ConfirmationTVA = ds_TVA_confirmation
gen Droitssimples_ConfirmationIS = ds_IS_confirmation
gen Droitssimples_ConfirmationRAS = ds_RAS_confirmation
egen Droitssimples_ConfirmationAUTRES = rowtotal(ds_*confirmation)
egen temp = rowtotal(Droitssimples_ConfirmationTVA Droitssimples_ConfirmationIS Droitssimples_ConfirmationRAS) 
replace Droitssimples_ConfirmationAUTRES  = Droitssimples_ConfirmationAUTRES  - temp 
drop temp 

gen Pénalités_ConfirmationTVA = p_TVA_confirmation
gen Pénalités_ConfirmationIS = p_IS_confirmation
gen Pénalités_ConfirmationRAS = p_RAS_confirmation
egen Pénalités_ConfirmationAUTRES = rowtotal(p_*confirmation)
egen temp = rowtotal(Pénalités_ConfirmationTVA Pénalités_ConfirmationIS Pénalités_ConfirmationRAS) 
replace Pénalités_ConfirmationAUTRES  = Pénalités_ConfirmationAUTRES  - temp 
drop temp 

gen Droitssimples_NotificationTVA = ds_TVA_notification
gen Droitssimples_NotificationIS = ds_IS_notification
gen Droitssimples_NotificationRAS = ds_RAS_notification
egen Droitssimples_NotificationAUTRES = rowtotal(ds_*notification)
egen temp = rowtotal(Droitssimples_NotificationTVA Droitssimples_NotificationIS Droitssimples_NotificationRAS) 
replace Droitssimples_NotificationAUTRES  = Droitssimples_NotificationAUTRES  - temp 
drop temp 

gen Pénalités_NotificationTVA = p_TVA_notification
gen Pénalités_NotificationIS = p_IS_notification
gen Pénalités_NotificationRAS = p_RAS_notification
egen Pénalités_NotificationAUTRES = rowtotal(p_*notification)
egen temp = rowtotal(Pénalités_NotificationTVA Pénalités_NotificationIS Pénalités_NotificationRAS) 
replace Pénalités_NotificationAUTRES  = Pénalités_NotificationAUTRES  - temp 
drop temp 

egen Droitssimples_Confirmation = rowtotal(Droitssimples_Confirmation*)
egen Droitssimples_Notification = rowtotal(Droitssimples_Notification*)
egen Pénalités_Confirmation = rowtotal(Pénalités_Confirmation*)
egen Pénalités_Notification = rowtotal(Pénalités_Notification*)


drop ds_BNC_confirmation ds_BRS_confirmation ds_CEL_confirmation ds_CFCE_confirmation ds_CFPB_confirmation ds_CFPNB_confirmation ds_DROITS_ENREG_confirmation ds_DROITS_TIMBRE_confirmation ds_IRC_confirmation ds_IRPP_confirmation ds_IRVM_IRCM_confirmation ds_IS_confirmation ds_PATENTE_confirmation ds_RAS_confirmation ds_SURTAX_FONC_confirmation ds_TEOM_confirmation ds_TPT_confirmation ds_TRIMF_confirmation ds_TSVPPM_confirmation ds_TVA_confirmation ds_VRS_confirmation p_BNC_confirmation p_BRS_confirmation p_CEL_confirmation p_CFCE_confirmation p_CFPB_confirmation p_CFPNB_confirmation p_DROITS_ENREG_confirmation p_DROITS_TIMBRE_confirmation p_IRC_confirmation p_IRPP_confirmation p_IRVM_IRCM_confirmation p_IS_confirmation p_PATENTE_confirmation p_RAS_confirmation p_SURTAX_FONC_confirmation p_TEOM_confirmation p_TPT_confirmation p_TRIMF_confirmation p_TSVPPM_confirmation p_TVA_confirmation p_VRS_confirmation ds_confirmation_somme p_confirmation_somme date_perception ds_BNC_perception ds_BRS_perception ds_CEL_perception ds_CFCE_perception ds_CFPB_perception ds_CFPNB_perception ds_DROITS_ENREG_perception ds_DROITS_TIMBRE_perception ds_IRC_perception ds_IRPP_perception ds_IRVM_IRCM_perception ds_IS_perception ds_PATENTE_perception ds_RAS_perception ds_SURTAX_FONC_perception ds_TEOM_perception ds_TPT_perception ds_TRIMF_perception ds_TSVPPM_perception ds_TVA_perception ds_VRS_perception p_BNC_perception p_BRS_perception p_CEL_perception p_CFCE_perception p_CFPB_perception p_CFPNB_perception p_DROITS_ENREG_perception p_DROITS_TIMBRE_perception p_IRC_perception p_IRPP_perception p_IRVM_IRCM_perception p_IS_perception p_PATENTE_perception p_RAS_perception p_SURTAX_FONC_perception p_TEOM_perception p_TPT_perception p_TRIMF_perception p_TSVPPM_perception p_TVA_perception p_VRS_perception ds_perception_somme p_perception_somme		
	
keep ninea raison_sociale riskscore algorithm horsprogramme DGID random Droits* Pénalit* center annee controle  Vérificateur1 degre_de_difficulte activite_complexe manque_cooperation donnees_difficiles_dacces comptabilite_non_adequate contrainte_de_temps moyenne_jour date* info*
 
bys ninea controle annee: gen n = _n
keep if n == 1 
drop n	
	
foreach d of varlist date* {
	
	gen datetemp = date(`d', "DMY")
	drop `d'
	rename datetemp `d'
	format `d' %td
	
}	
	
tempfile an2019
sa `an2019', replace 		
	
*********************************************************************************
*Merge and save dataset
*********************************************************************************

use `an2018', clear 
append using `an2019'

*Standardize variable names
qui ds Droits* Pénali*
qui foreach d in `r(varlist)' {
		
	tostring `d', force replace 
	replace `d' = "" if `d' == "."
	
	local newname = ustrlower( ustrregexra( ustrnormalize( "`d'", "nfd" ) , "\p{Mark}", "" )  )
	local newname = substr("`newname'", 1, 28)
	rename `d' s_`newname'
		
}

preserve 

	drop s_droits* s_penalit* 
	
	bys ninea annee controle: gen n = _n
	keep if n == 1 
	drop n 

	tempfile auditsinfo 
	sa `auditsinfo', replace 	
	
restore 

keep ninea annee s_droits* s_penalit* controle

foreach v of varlist s_droits* s_penalit*  {
    
	destring `v', replace force 
	
}

merge 1:1 ninea annee controle using `auditsinfo', replace update

drop _merge 

gen suivi = 1 

rename raison_sociale raisonsociale 

*Update ninea based on raisonsociale
	*Original raisonsociale 
	clonevar raisonsociale_original = raisonsociale
	tostring ninea, replace force 
	*Cleaned raisonsociale
	replace raisonsociale = ustrupper( ustrregexra( ustrnormalize(raisonsociale, "nfd" ) , "\p{Mark}", "" ) )	
	replace raisonsociale = trim(raisonsociale)
	replace raisonsociale = subinstr(raisonsociale, "<", "", .)
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
	replace raisonsociale = subinstr(raisonsociale, "(", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ")", "", .)		
	replace raisonsociale = subinstr(raisonsociale,`"""', "", .)	
	replace raisonsociale = subinstr(raisonsociale,`"-"', "", .)			
	replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
	replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
	replace raisonsociale = subinstr(raisonsociale, "L' ", "", .)	
	replace raisonsociale = subinstr(raisonsociale, "L'", "", .)			
	replace raisonsociale = subinstr(raisonsociale, "'", "", .)		
	replace raisonsociale = trim(raisonsociale)
	
	*Some manual inputs
	quietly do "$code\AUX Manually input nineas.do"
	
	preserve

	    use "$rawdata/Programme_2019/waste/RetrievedNineaAuditsfinal", clear
		rename Audits_raisonsociale raisonsociale
		replace raisonsociale = ustrupper( ustrregexra( ustrnormalize(raisonsociale, "nfd" ) , "\p{Mark}", "" ) )	
		replace raisonsociale = trim(raisonsociale)
		replace raisonsociale = subinstr(raisonsociale, "<", "", .)
		replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
		replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
		replace raisonsociale = subinstr(raisonsociale, "(", "", .)	
		replace raisonsociale = subinstr(raisonsociale, ")", "", .)		
		replace raisonsociale = subinstr(raisonsociale,`"""', "", .)	
		replace raisonsociale = subinstr(raisonsociale,`"-"', "", .)			
		replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
		replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
		replace raisonsociale = subinstr(raisonsociale, "L' ", "", .)	
		replace raisonsociale = subinstr(raisonsociale, "L'", "", .)			
		replace raisonsociale = subinstr(raisonsociale, "'", "", .)		
		replace raisonsociale = trim(raisonsociale)
		
		bys raisonsociale: gen n = _n
		keep if n == 1
		drop n 
		
		tostring ninea, replace force
		
		tempfile listmatchit
		sa `listmatchit', replace 
	   
	restore 
	
	merge m:1 raisonsociale using `listmatchit'
	drop if _merge == 2 
	drop _merge
	
	replace ninea = ninea_retrieved if ninea == "" & ninea_retrieved != ""
	
tostring ninea, force replace 
destring ninea, force gen(nineanumerique)
clonevar nineatomerge = nineanumerique  
replace nineatomerge = . if nineatomerge < 0 
tostring nineatomerge, force replace 
replace nineatomerge = raisonsociale if nineatomerge == "."

drop algorithm DGID random riskscore horsprogramme
clonevar anneeduchrono = annee

gen days = date_confirmation - date_notification

bys nineatomerge annee controle: gen n = _n
keep if n == 1 
drop n

keep controle s_droitssimples_notification s_droitssimples_confirmation s_penalites_notification s_penalites_confirmation annee date_notification date_confirmation date_perception degre_de_difficulte activite_complexe manque_cooperation donnees_difficiles_dacces comptabilite_non_adequate contrainte_de_temps moyenne_jour information_supplementaire date_de_demarrage date_demande_information date_avis suivi nineatomerge anneeduchrono raisonsociale center


foreach v of varlist date* {
    
	rename `v' s_`v'
	
}

rename nineatomerge firmid 

gen typedecontrole = "CSP" if controle == 1
replace typedecontrole = "VG" if controle == 2 

rename raisonsociale raisonsociale_suivi
rename center center_suivi

******************************************
*Merge saisie data
******************************************
clonevar type_controle = typedecontrole

*Merge same year
merge 1:1 firmid anneeduchrono typedecontrole using  "$wastedata/datasetsaisie", keepusing(firmid anneeduchrono typedecontrole)

gen s_wrongbureau = 0 
gen s_wrongyear 	= 0

*Merge allowing for audit to start a year later
preserve
	keep if _merge  >= 3 
	tempfile firstmatch
	sa `firstmatch'
restore 

*Second round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
keep if _merge == 1
drop _merge
replace anneeduchrono = anneeduchrono + 1
merge 1:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

preserve
	keep if _merge  >= 3 
	replace s_wrongyear = 1 
	tempfile secondmatch
	sa `secondmatch'
restore 

keep if _merge == 1
drop _merge
replace anneeduchrono = anneeduchrono - 1
merge 1:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace anneeduchrono = anneeduchrono + 1 if _merge == 1 

preserve
	keep if _merge  >= 3 
	replace s_wrongyear = 1 	
	tempfile thirdmatch
	sa `thirdmatch'
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "CSP"
merge m:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace typedecontrole = "VG" if type_controle == "VG" & _merge == 1 

preserve
	keep if _merge >= 3 
	replace s_wrongbureau = 1 	
	tempfile fourthmatch
	sa `fourthmatch'
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "CSP"
replace anneeduchrono = anneeduchrono + 1
merge m:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace typedecontrole = "VG" if type_controle == "VG" & _merge == 1 
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

preserve
	keep if _merge >= 3 
	replace s_wrongbureau = 1 	
	replace s_wrongyear = 1 	
	tempfile fifthmatch
	sa `fifthmatch'
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "VG"
merge m:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace typedecontrole = "CSP" if type_controle == "CP" & _merge == 1 

preserve
	keep if _merge >= 3 
	replace s_wrongbureau = 1 		
	tempfile sixthmatch
	sa `sixthmatch'
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "VG"
replace anneeduchrono = anneeduchrono + 1
merge m:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisie", replace update keepusing(firmid anneeduchrono typedecontrole)
replace typedecontrole = "CSP" if type_controle == "CP" & _merge == 1 
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

	replace s_wrongbureau = 1 	if _merge >= 3
	replace s_wrongyear = 1 		if _merge >= 3
	
	drop if _merge == 2 
	tempfile seventhmatch
	sa `seventhmatch'
	
*Integrate the two rounds 
use `firstmatch', clear
count if _merge >= 3 
count
append using `secondmatch', force 
count if _merge >= 3 
count
append using `thirdmatch', force 
count if _merge >= 3 
count
append using `fourthmatch', force 
count if _merge >= 3 
count
append using `fifthmatch', force 
count if _merge >= 3 
count
append using `sixthmatch', force 
count if _merge >= 3 
count
append using `seventhmatch', force 
count if _merge >= 3 
count

replace suivi = 0 if suivi== . 

bys firmid anneeduchrono typedecontrole: gen n = _n
keep if n == 1 
drop n _merge

drop annee controle information
drop s_wrongbureau s_wrongyear
drop type_controle

sa "$wastedata/Suivi.dta", replace

*****************************************
*MERGE SUIVI AND SAISIE
*****************************************
use "$wastedata\\datasetsaisie", clear 
*Add suivi data
merge 1:1 firmid anneeduchrono typedecontrole using "$wastedata/Suivi.dta"
drop _merge
replace suivi = 0 if suivi == . 
replace saisie = 0 if saisie == . 

drop IDaudit 
egen IDaudit = group(firmid anneeduchrono typedecontrole)

replace confirmation = 1 if strpos(feuille, "confirmation") > 0
replace confirmation = 1 if strpos(feuille, "Confirmation") > 0
replace notification = 1 if strpos(feuille, "otification") > 0
replace notification = 0 if notification == . & confirmation == 1 
replace confirmation = 0 if confirmation == . & notification == 1 

replace notification = 1 if droitssimples_notification > 0 & droitssimples_notification  != .
replace notification = 1 if penalites_notification > 0 & penalites_notification  != .
replace confirmation = 1 if droitssimples_confirmation > 0 & droitssimples_confirmation  != .
replace confirmation = 1 if penalites_confirmation > 0 & penalites_confirmation  != .

sa "$wastedata\\datasetsaisiefinal", replace

