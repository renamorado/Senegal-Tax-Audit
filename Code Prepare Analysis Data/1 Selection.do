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


******************************************************************************
*Get the selections of 2018, 2019 and 2020
******************************************************************************

************
*2018
************
use "$rawdata\Analyse des resultats du Programme_2018\Proc_data\selection_final_VG_ninea_ 26 Mar 2018", clear 

egen risk_VAT2018 = rowtotal(totalscoreVAT1 totalscoreVAT2 totalscoreVAT3 totalscoreVAT4 totalscoreVAT5)
egen risk_CIT2018 = rowtotal(totalscoreCIT1 totalscoreCIT2 totalscoreCIT3 totalscoreCIT4 totalscoreCIT5)
egen risk_inconsistency2018 = rowtotal(totalscoreF1 totalscoreF2 totalscoreF3 totalscoreF4 totalscoreF5)
egen risk_anomalies2018 = rowtotal(risk_VAT risk_CIT)

keep ninea methode_de_selection sequence raison_sociale riskscore csf  risk_inconsistency risk_CIT risk_VAT risk_anomalies
clonevar bureau = csf 
rename csf center

replace center = "CGE" if strpos(center, "CGE") > 0
replace center = "CME 1" if strpos(center, "CME DK1") > 0
replace center = "CME 2" if strpos(center, "CME DK2") > 0

rename riskscore riskscore2018
rename sequence sequencing
rename raison_sociale raisonsociale
gen Type_controle = "VG"
gen selectionyear = 2018
gen selection2018 = 1 

gen random 		= strpos(methode_de_selection, "ALEATOIRE") > 0 
gen algorithm 	= strpos(methode_de_selection, "ALGORITHME") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorith*DGID

drop methode_de_selection 
destring ninea, force replace 
sort ninea
replace ninea = -1000*_n if ninea == . 
gen annee = 2018 

sort bureau sequencing raisonsociale
by bureau:  gen seq = _n
replace sequencing = seq

sa "$wastedata/selectionVG2018", replace 

*add safeties
use "$rawdata\Analyse des resultats du Programme_2018\Proc_data\selection_safeties_VG_ninea", clear 

egen risk_VAT2018 = rowtotal(totalscoreVAT1 totalscoreVAT2 totalscoreVAT3 totalscoreVAT4 totalscoreVAT5)
egen risk_CIT2018 = rowtotal(totalscoreCIT1 totalscoreCIT2 totalscoreCIT3 totalscoreCIT4 totalscoreCIT5)
egen risk_inconsistency2018 = rowtotal(totalscoreF1 totalscoreF2 totalscoreF3 totalscoreF4 totalscoreF5)
egen risk_anomalies2018 = rowtotal(risk_VAT risk_CIT)

keep ninea methode_de_selection  raison_sociale riskscore csf  risk_inconsistency risk_CIT risk_VAT risk_anomalies
clonevar bureau = csf 
rename csf center

replace center = "CGE" if strpos(center, "CGE") > 0
replace center = "CME 1" if strpos(center, "CME DK1") > 0
replace center = "CME 2" if strpos(center, "CME DK2") > 0

rename riskscore riskscore2018
rename raison_sociale raisonsociale
gen Type_controle = "VG"
gen selectionyear = 2018
gen selection2018 = 1 

gen random 		= 0
gen algorithm 	= 0 
gen DGID 		= 0 
gen overlap 	= algorith*DGID
gen replacement = 1

drop methode_de_selection 
destring ninea, force replace 

gen annee = 2018 

sort bureau
gen seq = _n 
bys bureau: egen minseq = min(seq)
replace seq = seq + 1 - minseq
drop minseq
append using "$wastedata/selectionVG2018" 

bys bureau: egen maxseq = max(seq)
replace sequencing = seq + maxseq if sequencing == . 
drop seq maxseq 
sa "$wastedata/selectionVG2018", replace 

use "$rawdata/Analyse des resultats du Programme_2018\Proc_data\Selected_CP_Final_ 26 Mar 2018", clear

egen risk_VAT2018 = rowtotal(totalscoreVAT1 totalscoreVAT2 totalscoreVAT3 totalscoreVAT4 totalscoreVAT5)
egen risk_CIT2018 = rowtotal(totalscoreCIT1 totalscoreCIT2 totalscoreCIT3 totalscoreCIT4 totalscoreCIT5)
egen risk_inconsistency2018 = rowtotal(totalscoreF1 totalscoreF2 totalscoreF3 totalscoreF4 totalscoreF5)
egen risk_anomalies2018 = rowtotal(risk_VAT risk_CIT)

keep ninea methode_de_selection_inclusive sequencing raison_sociale riskgroup Niveaudesuspicion_inputed raison_sociale info_treatment riskscore csf Centrefiscal MatriculeInspecteur risk_inconsistency  risk_CIT risk_VAT risk_anomalies

rename MatriculeInspecteur Vérificateur1
gen center = Centrefiscal
replace center = csf if center == ""
drop csf Centrefiscal

clonevar bureau = center 

replace center = "CGE" if strpos(center, "CGE") > 0
replace center = "CME 1" if strpos(center, "CME DK1") > 0
replace center = "CME 2" if strpos(center, "CME DK2") > 0

rename riskscore riskscore2018
decode methode_de_selection_inclusive, gen(methode_de_selection)
drop methode_de_selection_inclusive
rename raison_sociale raisonsociale
gen Type_controle = "CP"
gen selectionyear = 2018
gen selection2018 = 1 

gen information = 0
replace information = 1 if info_treatment == 2
replace information = 2 if info_treatment == 3
label define j 0 "Nothing" 1 "Indicators" 2 "Indicators + data", replace 
label values  information j 
drop info_treatment

gen random 		= strpos(methode_de_selection, "ALEATOIRE") > 0 
gen algorithm 	= strpos(methode_de_selection, "ALGORITHME") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorith*DGID

drop methode_de_selection 
destring ninea, force replace 
sort ninea
replace ninea = -1000*_n if ninea == . 
gen annee = 2018 

sa "$wastedata/selectionCSP2018", replace 

************
*2019
************
use "$rawdata/Programme_2019/proc/VG_Selection_DGE_Final", clear

egen risk_VAT2019= rowtotal(RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5)
egen risk_CIT2019 = rowtotal(RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5)
egen risk_inconsistency2019 = rowtotal(RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I3 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6)
gen risk_anomalies2019 = RS_FY1417_anomalies

keep ninea selectionmethod sequencing raisonsociale RS_FY1417_TOTAL_LOGAVREV RS_FY1417_TOTAL csfproposition numeric_bureau risk_inconsistency risk_CIT risk_VAT risk_anomalies

decode numeric_bureau, gen(bureau)
rename csfproposition center 

rename RS_FY1417_TOTAL_LOGAVREV riskscore2019 
rename RS_FY1417_TOTAL uw_riskscore2019 

destring ninea, force replace 
decode selectionmethod, gen(methode_de_selection)
drop selectionmethod
gen Type_controle = "VG"
gen selectionyear = 2019
gen selection2019 = 1 

tempfile d2019vg1
sa `d2019vg1'

use "$rawdata/Programme_2019/proc/VG_Selection_DME_Final", clear

gen center = "CME 1" if numeric_bureau == 6
replace center = "CME 2" if numeric_bureau == 7
replace center = "CPR" if numeric_bureau == 9

egen risk_VAT2019 = rowtotal(RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5)
egen risk_CIT2019 = rowtotal(RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5)
egen risk_inconsistency2019 = rowtotal(RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I3 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6)
gen risk_anomalies2019 = RS_FY1417_anomalies

keep ninea selectionmethod sequencing raisonsociale RS_FY1417_TOTAL_LOGAVREV RS_FY1417_TOTAL center  numeric_bureau risk_inconsistency risk_CIT risk_VAT risk_anomalies

decode numeric_bureau, gen(bureau)

rename RS_FY1417_TOTAL_LOGAVREV riskscore2019 
rename RS_FY1417_TOTAL uw_riskscore2019 

destring ninea, force replace 
decode selectionmethod, gen(methode_de_selection)
drop selectionmethod
gen Type_controle = "VG"
gen selectionyear = 2019
gen selection2019 = 1 

tempfile d2019vg2
sa `d2019vg2'

use "$rawdata\Programme_2019\proc\VG_Selection_DSF_Final", clear

egen risk_VAT2019 = rowtotal(RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5)
egen risk_CIT2019 = rowtotal(RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5)
egen risk_inconsistency2019 = rowtotal(RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I3 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6) 
gen risk_anomalies2019 = RS_FY1417_anomalies

keep ninea selectionmethod sequencing raisonsociale RS_FY1417_TOTAL_LOGAVREV RS_FY1417_TOTAL centre numeric_bureau risk_inconsistency risk_CIT risk_VAT risk_anomalies

decode numeric_bureau, gen(bureau)

rename centre center
rename RS_FY1417_TOTAL_LOGAVREV riskscore2019 
rename RS_FY1417_TOTAL uw_riskscore2019 

destring ninea, force replace 
decode selectionmethod, gen(methode_de_selection)
drop selectionmethod
gen Type_controle = "VG"
gen selectionyear = 2019
gen selection2019 = 1 

tempfile d2019vg3
sa `d2019vg3'

*Append and save
use `d2019vg1'
append using `d2019vg2'
append using `d2019vg3'

gen random 		= strpos(methode_de_selection, "Random") > 0 
gen algorithm 	= strpos(methode_de_selection, "Algorithm") > 0 | strpos(methode_de_selection, "Safeties") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorithm*DGID
gen replacement = strpos(methode_de_selection, "Safeties") > 0 

drop if raison == "SENERGY 2 SUARL"
destring ninea, force replace 
sort ninea 
replace ninea = -1000*_n if ninea == . 
gen annee = 2019 

sa "$wastedata/selectionVG2019", replace 

use "$rawdata\Programme_2019\proc\CP_Selection_DME_Final", clear

egen risk_VAT2019 = rowtotal(RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5)
egen risk_CIT2019 = rowtotal(RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5)
egen risk_inconsistency2019 = rowtotal(RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I3 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6) 
gen risk_anomalies2019 = RS_FY1417_anomalies

keep ninea selectionmethod sequencing raisonsociale info_treatment RS_FY1417_TOTAL_LOGAVREV RS_FY1417_TOTAL numeric_bureau nameinspector numeric_bureau risk_inconsistency risk_CIT risk_VAT risk_anomalies

gen seq = _n
bys nameinspector numeric_bureau: egen minseq = min(seq)
replace seq = seq + 1 - minseq
replace sequencing = seq 
drop seq minseq

decode numeric_bureau, gen(bureau)

rename nameinspector Vérificateur1

decode numeric_bureau, gen(center)
rename RS_FY1417_TOTAL_LOGAVREV riskscore2019 
rename RS_FY1417_TOTAL uw_riskscore2019 

decode selectionmethod, gen(methode_de_selection)
drop selectionmethod
destring ninea, force replace 
gen Type_controle = "CP"
gen selectionyear = 2019
gen selection2019 = 1 

gen information = 0
replace information = 1 if info_treatment == "Indicateurs de risque"
replace information = 2 if info_treatment == "Indicateurs de risque et données du contribuable (pièce jointe)"
label define j 0 "Nothing" 1 "Indicators" 2 "Indicators + data", replace 
label values  information j 
drop info_treatment

tempfile d2019cp1
sa `d2019cp1'

use "$rawdata\Programme_2019\proc\CP_Selection_DSF_Final", clear

egen risk_VAT2019= rowtotal(RS_FY1417_ATVA1 RS_FY1417_ATVA2 RS_FY1417_ATVA3 RS_FY1417_ATVA4 RS_FY1417_ATVA5)
egen risk_CIT2019 = rowtotal(RS_FY1417_AIS1 RS_FY1417_AIS2 RS_FY1417_AIS3 RS_FY1417_AIS4 RS_FY1417_AIS5)
egen risk_inconsistency2019 = rowtotal(RS_FY1417_I1 RS_FY1417_I2 RS_FY1417_I3 RS_FY1417_I4 RS_FY1417_I5 RS_FY1417_I6)  
gen risk_anomalies2019 = RS_FY1417_anomalies

keep ninea selectionmethod sequencing raisonsociale info_treatment  RS_FY1417_TOTAL_LOGAVREV RS_FY1417_TOTAL centre nameinspector numeric_bureau risk_inconsistency risk_CIT risk_VAT risk_anomalies

gen seq = _n
bys nameinspector centre: egen minseq = min(seq)
replace seq = seq + 1 - minseq
replace sequencing = seq 
drop seq minseq

sort centre nameinspector seq

decode numeric_bureau, gen(bureau)

rename nameinspector Vérificateur1
rename centre center
rename RS_FY1417_TOTAL_LOGAVREV riskscore2019 
rename RS_FY1417_TOTAL uw_riskscore2019 

decode selectionmethod, gen(methode_de_selection)
drop selectionmethod
destring ninea, force replace 
gen Type_controle = "CP"
gen selectionyear = 2019
gen selection2019 = 1 

gen information = 0
replace information = 1 if info_treatment == "Indicateurs de risque"
replace information = 2 if info_treatment == "Indicateurs de risque et données du contribuable (pièce jointe)"
label define j 0 "Nothing" 1 "Indicators" 2 "Indicators + data", replace 
label values  information j 
drop info_treatment

tempfile d2019cp2
sa `d2019cp2'

use `d2019cp1', clear 
append using `d2019cp2'

gen random 		= strpos(methode_de_selection, "Random") > 0 
gen algorithm 	= strpos(methode_de_selection, "Algorithm") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorithm*DGID
gen replacement = strpos(methode_de_selection, "Safeties") > 0 

drop if raison == "SENERGY 2 SUARL"
destring ninea, force replace 
sort ninea 
replace ninea = -1000*_n if ninea == . 
gen annee = 2019 

sa "$wastedata/selectionCSP2019", replace 

******************
*2020
******************
use "$rawdata\Programme_2020\data_proc\selectionCSP", clear

replace ninea = -_n if ninea == . 

merge 1:1 ninea using "$rawdata\Programme_2020\data_proc\riskscore.dta"
drop if _merge == 2 
drop _merge 

egen risk_VAT2020 = rowtotal(w_points_ratioTVA1 w_points_ratioTVA2 )
egen risk_CIT2020 = rowtotal(w_points_ratioIS1 w_points_ratioIS2)
egen risk_inconsistency2020 = rowtotal(w_points_ratio1  w_points_ratio2 w_points_ratio3 w_flag_defaillance)  
egen risk_anomalies2020 = rowtotal(risk_VAT risk_CIT w_points_ratioTP1 w_points_ratioImportations1 w_points_ratioTAF)

rename inspector_name Vérificateur1
keep ninea selection sequencing raisonsociale riskscore information center Vérificateur1 bureau risk_anomalies risk_inconsistency risk_CIT risk_VAT
rename riskscore riskscore2020
decode selection, gen(methode_de_selection)
drop selection
destring ninea, force replace 
gen Type_controle = "CP"
gen selectionyear = 2020
gen selection2020 = 1 

label define j 0 "Nothing" 1 "Indicators" 2 "Indicators + data", replace 

gen random 		= strpos(methode_de_selection, "Random") > 0 
gen algorithm 	= strpos(methode_de_selection, "ALGORITHM") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorithm*DGID
gen replacement = strpos(methode_de_selection, "REPLACEMENT") > 0 

destring ninea, force replace 
sort ninea
replace ninea = -1000*_n if ninea == . 
gen annee = 2020

sa "$wastedata/selectionCSP2020", replace 

import excel "$rawdata\Programme_2020\data_proc\Liste VG 2020 approuvés.xlsx", clear firstrow 

qui ds
foreach v of varlist `r(varlist)' {
	local l = ustrlower( ustrregexra( ustrnormalize( "`v'", "nfd" ) , "\p{Mark}", "" )  )
	rename `v' `l'
}

gen firmid = ninea 
tostring firmid, replace force
replace firmid = raisonsociale if ninea == . 

keep firmid sequence

tempfile sequence
sa `sequence'

***********
*VG 2020
***********
use "$rawdata\Programme_2020\data_proc\selectionVG_secondround", clear

merge 1:1 ninea using "$rawdata\Programme_2020\data_proc\riskscore.dta"
drop if _merge == 2 
drop _merge 

egen risk_VAT2020 = rowtotal(w_points_ratioTVA1 w_points_ratioTVA2 )
egen risk_CIT2020 = rowtotal(w_points_ratioIS1 w_points_ratioIS2)
egen risk_inconsistency2020 = rowtotal(w_points_ratio1  w_points_ratio2 w_points_ratio3 w_flag_defaillance)  
egen risk_anomalies2020 = rowtotal(risk_VAT risk_CIT w_points_ratioTP1 w_points_ratioImportations1 w_points_ratioTAF)

keep ninea selection raisonsociale riskscore center bureau risk_anomalies risk_inconsistency risk_CIT risk_VAT
rename riskscore riskscore2020
decode selection, gen(methode_de_selection)
drop selection
destring ninea, force replace 
gen Type_controle = "VG"
gen selectionyear = 2020
gen selection2020 = 1 

gen random 		= strpos(methode_de_selection, "Random") > 0 
gen algorithm 	= strpos(methode_de_selection, "ALGORITHM") > 0 
gen DGID 		= strpos(methode_de_selection, "DGID") > 0 
gen overlap 	= algorithm*DGID
gen replacement = strpos(methode_de_selection, "REPLACEMENT") > 0 

destring ninea, force replace 
sort ninea
replace ninea = -1000*_n if ninea == . 
gen annee = 2020

gen firmid = ninea 
tostring firmid, replace force
replace firmid = raisonsociale if ninea < 0  

merge 1:1 firmid using `sequence'
drop _merge

drop firmid 
rename sequence sequencing

sa "$wastedata/selectionVG2020", replace 

*************************************
*Append VG and CSP 
*************************************
cd "$wastedata"

use "selectionCSP2020", clear
append using "selectionCSP2019"
append using "selectionCSP2018"
append using "selectionVG2020"
append using "selectionVG2019"
append using "selectionVG2018"

gen controle = Type_controle == "CP"
replace controle = 2 if Type_controle == "VG"

gen selection  = 1

*Standardize variable names and label
	qui ds
	qui foreach d in `r(varlist)' {
		
		label var `d' "From selection files"

		cap noisily replace `d' = . if `d' == 0
		cap noisily replace `d' = "" if `d' == "DS"
		cap noisily replace `d' = "" if `d' == "PL"
		
		tostring `d', force replace 
		replace `d' = "" if `d' == "."
		
		local newname = ustrlower( ustrregexra( ustrnormalize( "`d'", "nfd" ) , "\p{Mark}", "" )  )
		rename `d' `newname' 		
		
	}
	
*Standardize raisonsociale and nineas
clonevar raisonsocialeselection = raisonsociale
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
	
compress raisonsociale	

	*Some manual inputs
	do "$code/AUX Manually input nineas.do"
	
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
	
	merge m:1 raisonsociale using `listmatchit', replace update
	drop if _merge == 2 
	drop _merge	
	
	replace ninea = ninea_retrieved if ninea == "" & ninea_retrieved != ""
		
	replace ninea = upper(ninea)
	replace ninea = trim(ninea)
	replace ninea = "" if strpos(ninea, "PAS")		
	
	*Clean information about vérificateurs
ds verificateur* 
foreach v in `r(varlist)' {
	
	replace `v' = 	"Abdoul SY"	if strpos(`v',	"600100E"	)> 0
	replace `v' = 	"Papa Aly DIOP"	if strpos(`v',	"604583J"	)> 0
	replace `v' = 	"Alpha Ngom"	if strpos(`v',	"608601G"	)> 0
	replace `v' = 	"Ismaila Ben Papa DIEME"	if strpos(`v',	"608603E"	)> 0
	replace `v' = 	"Serigne Saliou SEYE"	if strpos(`v',	"610997B"	)> 0
	replace `v' = 	"Mouhamadou Amadou SECK"	if strpos(`v',	"610998C"	)> 0
	replace `v' = 	"Mamadou SAMBA"	if strpos(`v',	"611002D"	)> 0
	replace `v' = 	"Edouard SENE"	if strpos(`v',	"611457Z"	)> 0
	replace `v' = 	"Boubacar DIALLO"	if strpos(`v',	"611479Z"	)> 0
	replace `v' = 	"Souhaibou DIAGNE"	if strpos(`v',	"616025H"	)> 0
	replace `v' = 	"Alain François FAYE"	if strpos(`v',	"616029D"	)> 0
	replace `v' = 	"Cheikh Tidiane DIAGNE"	if strpos(`v',	"616033K"	)> 0
	replace `v' = 	"Gorgui CISSE"	if strpos(`v',	"616225F"	)> 0
	replace `v' = 	"Baye Souleymane SAMB"	if strpos(`v',	"616276J"	)> 0
	replace `v' = 	"Abdel Kader WADE"	if strpos(`v',	"620715G"	)> 0
	replace `v' = 	"Talla NIANG"	if strpos(`v',	"620719K"	)> 0
	replace `v' = 	"Salimata KOUYATE"	if strpos(`v',	"620724E"	)> 0
	replace `v' = 	"Mountakha SECK"	if strpos(`v',	"624453F"	)> 0
	replace `v' = 	"Samba BA"	if strpos(`v',	"624458A"	)> 0
	replace `v' = 	"Daouda THIAM"	if strpos(`v',	"624460J"	)> 0
	replace `v' = 	"Souleymane TRAORE"	if strpos(`v',	"624472I"	)> 0
	replace `v' = 	"Papa Malick DIALLO"	if strpos(`v',	"624474G"	)> 0
	replace `v' = 	"Mamour DIOP"	if strpos(`v',	"624477D"	)> 0
	replace `v' = 	"Ibrahima SEYE"	if strpos(`v',	"624479B"	)> 0
	replace `v' = 	"Macoumba NIANG"	if strpos(`v',	"624480L"	)> 0
	replace `v' = 	"Allé Madiao Khor DIOP"	if strpos(`v',	"624481K"	)> 0
	replace `v' = 	"Idrissa SAMB"	if strpos(`v',	"624495H"	)> 0
	replace `v' = 	"Al Housseyni KELLY"	if strpos(`v',	"624504A"	)> 0
	replace `v' = 	"Ibrahima SARR"	if strpos(`v',	"624517C"	)> 0
	replace `v' = 	"Abdoul Aziz DIAGNE"	if strpos(`v',	"624935C"	)> 0
	replace `v' = 	"Yatta DIOP"	if strpos(`v',	"624937E"	)> 0
	replace `v' = 	"Serigne Mbacke KA"	if strpos(`v',	"624939G"	)> 0
	replace `v' = 	"Mouhamadou Moustapha NDIAYE"	if strpos(`v',	"624942A"	)> 0
	replace `v' = 	"Mamadou Lamine NDIAYE"	if strpos(`v',	"624943Z"	)> 0
	replace `v' = 	"Abdel Kader SOW"	if strpos(`v',	"624949F"	)> 0
	replace `v' = 	"Aliou SY"	if strpos(`v',	"624950D"	)> 0
	replace `v' = 	"NDIAYE GORA"	if strpos(`v',	"629506B"	)> 0
	replace `v' = 	"Mamadou Moutaraou DIALLO"	if strpos(`v',	"634454D"	)> 0
	replace `v' = 	"Meissa NGOM"	if strpos(`v',	"634455C"	)> 0
	replace `v' = 	"Abdou SAMB"	if strpos(`v',	"634462G"	)> 0
	replace `v' = 	"Oumar DIACK"	if strpos(`v',	"634465D"	)> 0
	replace `v' = 	"GUEYE ABDOUL AZIZ"	if strpos(`v',	"634468A"	)> 0
	replace `v' = 	"DIOP BIRANE"	if strpos(`v',	"634476D"	)> 0
	replace `v' = 	"Gorgui Moussa BA"	if strpos(`v',	"653000D"	)> 0
	replace `v' = 	"Abdou KARIM CAMARA"	if strpos(`v',	"653002B"	)> 0
	replace `v' = 	"Alassane NDIAYE"	if strpos(`v',	"653005A"	)> 0
	replace `v' = 	"Mor Talla KHOUMA"	if strpos(`v',	"653006B"	)> 0
	replace `v' = 	"Mansour MBENGUE"	if strpos(`v',	"653007C"	)> 0
	replace `v' = 	"Amadou LY"	if strpos(`v',	"653009E"	)> 0
	replace `v' = 	"DIOME MAMADOU NDIAYE"	if strpos(`v',	"653056C"	)> 0
	replace `v' = 	"EL ASSANE CISSE MBAYE"	if strpos(`v',	"661316G"	)> 0
	replace `v' = 	"YAYA HANE"	if strpos(`v',	"661326F"	)> 0
	replace `v' = 	"MAMADOU TOURE"	if strpos(`v',	"661327G"	)> 0
	replace `v' = 	"MANSOUR DIAVARA"	if strpos(`v',	"681428K"	)> 0	
}

quietly {
	do "$code/AUX Clean verificateur names.do"
}

rename verificateur1 verificateur_selection
replace verificateur_selection = center if controle == "2"

order annee selectionyear center type_controle controle raisonsociale* *ninea* information sequencing methode_de_selection  	

destring selection, replace force 

rename annee anneeduchrono
destring anneeduchrono, replace force

gen typedecontrole = "CSP" if type_controle == "CP"
replace typedecontrole = "VG" if type_controle == "VG"

foreach v in random algorithm dgid overlap replacement  {
	
	destring `v', replace force
	replace `v' = 0 if `v' == . 
	
}

*Ninea to merge 
destring ninea, force gen(nineanumerique)
clonevar firmid = nineanumerique  
replace firmid = . if firmid < 0 
tostring firmid, force replace 
replace firmid = raisonsociale if firmid == "."
replace firmid = ninea if firmid == ""

egen selectionid = group(ninea anneeduchrono controle)

clonevar bureau_selection = bureau 

sa "$wastedata/selectionraw", replace 


*Make Uniquely identified dataset
use "$wastedata/selectionraw", clear 
sort ninea anneeduchrono controle
by ninea anneeduchrono controle: gen N = _N

list anneeduchrono ninea raisonsociale dgid algorith verificateur center if N > 1 
drop N 

*Drop Duplicates
sort ninea anneeduchrono controle
by ninea anneeduchrono controle: gen n = _n
keep if n == 1 
drop n 

isid ninea anneeduchrono controle 

drop bureau

gen selectionmethod = .
replace selectionmethod = 1 if algorithm == 1 
replace selectionmethod = 2 if dgid == 1 
replace selectionmethod = 3 if random == 1 
replace selectionmethod = 4 if algorithm == 1 & dgid == 1 
replace selectionmethod = 4 if random == 1 & dgid == 1 
replace selectionmethod = 5 if replacement == 1 

label define f 1 "Algorithm" 2 "Discretion" 3 "Random" 4 "Overlap" 5 "Safeties"
label values selectionmethod f

sa "$wastedata/selection", replace 
