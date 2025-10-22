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

use "$wastedata/selectionraw", clear

gen originalbureau = bureau 
gen originalcenter = center

******************************************
*Merge saisie data
******************************************
*Merge same year
merge m:1 firmid anneeduchrono typedecontrole using "$wastedata/datasetsaisiefinal"

gen wrongbureau = 0 
gen wrongyear 	= 0

*Merge allowing for audit to start a year later
preserve
	keep if _merge  >= 3 
	tempfile firstmatch
	sa `firstmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 

*Second round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
keep if _merge == 1
drop _merge
replace anneeduchrono = anneeduchrono + 1
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

preserve
	keep if _merge  >= 3 
	replace wrongyear = 1 
	tempfile secondmatch
	sa `secondmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 


keep if _merge == 1
drop _merge
replace anneeduchrono = anneeduchrono + 2
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace anneeduchrono = anneeduchrono - 2 if _merge == 1 

preserve
	keep if _merge  >= 3 
	replace wrongyear = 1 	
	tempfile thirdmatch
	sa `thirdmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "CSP"
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace typedecontrole = "VG" if type_controle == "VG" & _merge == 1 

preserve
	keep if _merge >= 3 
	replace wrongbureau = 1 	
	tempfile fourthmatch
	sa `fourthmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 


keep if _merge == 1
drop _merge
replace typedecontrole = "CSP"
replace anneeduchrono = anneeduchrono + 1
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace typedecontrole = "VG" if type_controle == "VG" & _merge == 1 
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

preserve
	keep if _merge >= 3 
	replace wrongbureau = 1 	
	replace wrongyear = 1 	
	tempfile fifthmatch
	sa `fifthmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 

keep if _merge == 1
drop _merge
replace typedecontrole = "VG"
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace typedecontrole = "CSP" if type_controle == "CP" & _merge == 1 

preserve
	keep if _merge >= 3 
	replace wrongbureau = 1 		
	tempfile sixthmatch
	sa `sixthmatch'
restore 

preserve
	keep if _merge == 2 
	drop _merge
	tempfile saisie
	sa `saisie', replace 
restore 


keep if _merge == 1
drop _merge
replace typedecontrole = "VG"
replace anneeduchrono = anneeduchrono + 1
merge m:1 firmid anneeduchrono typedecontrole using `saisie', replace update
replace typedecontrole = "CSP" if type_controle == "CP" & _merge == 1 
replace anneeduchrono = anneeduchrono - 1 if _merge == 1 

	replace wrongbureau = 1 	if _merge >= 3
	replace wrongyear = 1 		if _merge >= 3
	
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

replace selection = 0 if selection == . 
replace saisie = 0 if saisie == . 
cap replace suivi = 0 if suivi == . 

bys firmid anneeduchrono typedecontrole: gen N = _N
drop  if N >= 2 & selectionyear == ""
drop N _merge

replace bureau = originalbureau if selection == 1 
replace center = originalcenter if selection == 1 

*Test whether some firms got lost in the way (there should never be a _merge == 2)
merge m:1 selectionid using  "$wastedata/selection", keepusing(selectionid selectionmethod)
drop _merge 
merge m:1 IDaudit using "$wastedata/datasetsaisie", keepusing(firmid anneeduchrono typedecontrole)
drop _merge 

/*
******************************************
*Merge suivi data
******************************************
*Add suivi data
merge 1:1 firmid anneeduchrono typedecontrole using "$wastedata/Suivi.dta"
drop if _merge == 2 
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
*/
******************************************
*Cleaning 
******************************************
*Rename some variables to avoid confusion
clonevar typedecontrole_audit = typedecontrole 
label var typedecontrole_audit "Type of audit in audits data"

clonevar typedecontrole_selection = type_controle 
label var typedecontrole_selection "Type of audit in selection data"

drop controle 

gen controle = 0 

replace controle = 1 if typedecontrole_selection == "CP" 
replace controle = 2 if typedecontrole_selection == "VG" 

replace controle = 1 if typedecontrole_audit == "CSP" & controle == 0
replace controle = 2 if typedecontrole_audit == "VG" & controle == 0

destring selectionyear, force replace
replace selectionyear = anneeduchrono if selectionyear == . 

replace firmid = ninea if firmid == ""
drop if firmid == ""
drop if selectionyear == . 

replace typedecontrole_audit = "CP" if typedecontrole_audit == "CSP"

/*
*Some cases appear twice in the selection in the same year, with different audit types, but they were carried out as a single audit type. To avoid these duplicates, we eliminate the observation with the incompatible selection method. 
bys firmid selectionyear typedecontrole_audit: gen N = _N
drop if N > 1 & typedecontrole_audit != typedecontrole_selection
drop N
*/

cap noisily isid firmid selectionyear controle verificateur_selection, missok

*Inspector information
replace verificateur_selection = subinstr(verificateur_selection, "(INSPECTEUR)", "", .)
replace verificateur_selection = trim( verificateur_selection)
replace verificateur_selection = ustrupper( ustrregexra( ustrnormalize(verificateur_selection, "nfd" ) , "\p{Mark}", "" ) )	
replace verificateur1 = verificateur_selection if verificateur1 == "" & saisie == 1 & verificateur_selection != ""

*Clean bureau selection
clonevar bureau_selection2 = bureau_selection

foreach n in 1 2 3 4 {
replace bureau_selection2 = "CGE BCS`n'" if strpos(bureau_selection2, "BCS `n'") > 0 & strpos(bureau_selection2, "CGE") == 0
}

replace bureau_selection2 = "CME 1" if bureau_selection2 == "CME DK1"
replace bureau_selection2 = "CME 2" if bureau_selection2 == "CME DK2"

replace bureau_selection2 = subinstr(bureau_selection2, "ALL", "UNKNOWN", .)
replace bureau_selection2 = subinstr(bureau_selection2, "AUTRES", "UNKNOWN", .)

foreach b in "GRAND DAKAR" "DAKAR PLATEAU" "NGOR ALMADIES" "PIKINE GUEDIAWAYE" { 
    foreach u in 1 2 3 4 5 {
		replace bureau_selection2 = "`b' UGF `u'" if center == "`b'" & bureau_selection2 == "UGF `u'"
	}
}

drop bureau_selection
rename bureau_selection2 bureau_selection

*Clean bureau saisie
clonevar bureau_saisie2 = bureau_saisie
replace bureau_saisie2 = trim(bureau_saisie2)

foreach n in 1 2 3 4 {
replace bureau_saisie2 = "CGE BCS`n'" if strpos(bureau_saisie2, "BCS`n'") > 0 
}

replace bureau_saisie2 = "CME 2" if bureau_saisie2 == "CM2" | bureau_saisie2 == "CME2"
replace bureau_saisie2 = "CME 1" if bureau_saisie2 == "DME1"

replace bureau_saisie2 = "NGOR ALMADIES" if bureau_saisie2 == "NG-A" | bureau_saisie2 == "NGA"
replace bureau_saisie2 = "PIKINE GUEDIAWAYE" if bureau_saisie2 == "PIK/G" | bureau_saisie2 == "PK-G"
replace bureau_saisie2 = "DAKAR PLATEAU" if bureau_saisie2 == "D-P" | bureau_saisie2 == "DP"

drop bureau_saisie
rename bureau_saisie2 bureau_saisie

replace typedecontrole_selection = "" if selection == 0
replace typedecontrole_audit = "" if saisie == 0

drop typedecontrole type_controle

****************************
*SAVING
****************************
sa "$wastedata/merged_selection_audits", replace
