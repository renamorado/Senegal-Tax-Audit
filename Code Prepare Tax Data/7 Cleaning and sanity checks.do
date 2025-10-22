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
	
use "Programme_2021\data_proc\fulltaxdataset", clear

*Rename prefixes MANDATS EXPORTATIONS and IMPORTATIONS (to be compatible with the old code)
ds MANDATS* EXPORTATIONS* IMPORTATIONS*
foreach v in `r(varlist)' {
    
	local newname = subinstr("`v'", "MANDATS", "MAN", .)
	local newname = subinstr("`newname'", "IMPORTATIONS", "IMP", .)
	local newname = subinstr("`newname'", "EXPORTATIONS", "EXP", .)
	
	rename `v' `newname'
}

****************************************************************
* 1 Generate variables about tax center and economic activity 
****************************************************************
*Generate center
gen center = ""

replace center = "CGE" if strpos(REP_centre, "DGE") > 0  
replace center = "CGE" if strpos(SIGTAS_CENTRE, "DIRECTION DES GRANDES ENTREPRISES") > 0 
replace center = "CGE" if strpos(SIGTAS_CENTRE, "CGE") > 0 

replace center = "CME 1" if strpos(REP_centre, "DME 1") > 0 
replace center = "CME 1" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 1") > 0 & center == "" 
replace center = "CME 1" if strpos(SIGTAS_CENTRE, "CME") > 0 & center == "" 

replace center = "CME 2" if strpos(REP_centre, "DME 2") > 0 
replace center = "CME 2" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 2") > 0 & center == "" 

replace center = "CPR" if strpos(REP_centre, "CPR") > 0 
replace center = "CPR" if strpos(SIGTAS_CENTRE, "CPR") > 0 & center == "" 

local nPLATEAU 	"DAKAR PLATEAU"
local nLIBERTE 	"DAKAR LIBERTE"
local nGRAND	"GRAND DAKAR"
local nNGOR		"NGOR ALMADIES"
local nPIKINE	"PIKINE GUEDIAWAYE"
local nGUEDIA	"PIKINE GUEDIAWAYE"

foreach c in PLATEAU LIBERTE GRAND NGOR PIKINE GUEDIA {
	replace center = "`n`c''" if strpos(REP_centre, "`c'") > 0 
	replace center = "`n`c''" if strpos(SIGTAS_CENTRE, "`c'") > 0 & center == "" 
	replace center = "`n`c''" if strpos(ANSD_LIBELLE_CENTRE_FISCAL, "`c'") > 0 & center == "" 
}

foreach c in "RUFISQUE" "DIOURBEL" "FATICK" "KAOLACK" "KOLDA" "MATAM" "LOUGA" "MBOUR" "PARCELLES ASSAINIES" "LOUIS" "SEDHIOU" "TAMBACOUNDA" "THIES" "ZIGUINCHOR" {

replace center = "`c'" if strpos(REP_centre, "`c'") > 0 
replace center = "`c'" if strpos(SIGTAS_CENTRE, "`c'") > 0 & center == "" 
replace center = "`c'" if strpos(ANSD_LIBELLE_CENTRE_FISCAL, "`c'") > 0 & center == "" 

}

replace center = "SAINT LOUIS" if center == "LOUIS"
replace center = "UNKNOWN" if center == "" 

*Generate bureau
gen bureau = "" 

replace bureau = "BCS 1" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "1") > 0
replace bureau = "BCS 2" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "2") > 0
replace bureau = "BCS 3" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "3") > 0
replace bureau = "BCS 4" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "4") > 0
replace bureau = "CGE UNKNOWN" if bureau == "" &  center == "CGE" 

replace bureau = "CME 1" if strpos(REP_centre, "DME 1") > 0 
replace bureau = "CME 1" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 1") > 0 & center == "CME" 
replace bureau = "CME 1" if strpos(SIGTAS_CENTRE, "CME") > 0 & bureau == "" 

replace bureau = "CME 2" if strpos(REP_centre, "DME 2") > 0 
replace bureau = "CME 2" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 2") > 0 & center == "CME" 

replace bureau = "CPR" if strpos(REP_centre, "CPR") > 0 
replace bureau = "CPR" if strpos(SIGTAS_CENTRE, "CPR") > 0 & center == "CME" 

replace bureau = "UGF 1" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "1") > 0
replace bureau = "UGF 2" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "2") > 0
replace bureau = "UGF 3" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "3") > 0
replace bureau = "UGF 4" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "4") > 0
replace bureau = "UGF 5" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "5") > 0
replace bureau = "UGF 6" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "6") > 0

foreach bur in PIKINE GUEDIAWAYE {
foreach v in SIGTAS_CENTRE SIGTAS_centre REP_ugf {
	
	replace bureau = "`bur'" if center == "PIKINE GUEDIAWAYE" & `v' == "`bur'"
	
}
} 

foreach dsf in "DAKAR LIBERTE" "GRAND DAKAR" "NGOR ALMADIES" "DAKAR PLATEAU" "NGOR ALMADIES" "RUFISQUE" "PIKINE GUEDIAWAYE"  "RUFISQUE" "DIOURBEL" "MATAM" "FATICK" "KAOLACK" "KOLDA" "LOUGA" "MBOUR" "PARCELLES ASSAINIES" "SAINT LOUIS" "SEDHIOU" "TAMBACOUNDA" "THIES" "ZIGUINCHOR" {

replace bureau = "`dsf' UNKNOWN" if bureau == "" &  center == "`dsf'" 

}

replace AUD2021_bureau = "PIKINE GUEDIAWAYE" if strpos(AUD2021_bureau, "PIKINE") > 0 | strpos(AUD2021_bureau, "GUEDIAWAYE") > 0
replace center = "PIKINE GUEDIAWAYE" if strpos(center, "PIKINE") > 0 | strpos(center, "GUEDIAWAYE") > 0

*Correct data on center to make it compatible with selection made by DGID
foreach audit in AUD2020_bureau AUD2021_bureau {

	replace center = `audit' if `audit'  != ""
	replace center = "CGE" if strpos(`audit', "BCS") > 0 | strpos(`audit', "BCG") > 0 

	replace bureau = `audit' if `audit'  != "" & (strpos(`audit', "BCS") > 0 | strpos(`audit', "BCG") > 0)
	replace bureau = `audit' if `audit'  != "" & (strpos(`audit', "CPR") > 0 | strpos(`audit', "CME") > 0)
	replace bureau = "BCS 4" if strpos(`audit', "BCG") > 0 
	replace bureau = `audit' + " UNKNOWN" if `audit'  != "" & strpos(`audit', "CPR") == 0 & strpos(`audit', "CME") == 0 & strpos(`audit', "BCS") == 0  & strpos(`audit', "BCG") == 0  

}

*Generate directon 
gen direction = ""
replace direction = "DGE" if strpos(bureau, "BCS") > 0  | strpos(center, "CGE") > 0
replace direction = "DME" if strpos(center, "CME") > 0  | strpos(center, "CPR") > 0
replace direction = "DSF" if strpos(direction, "DGE") == 0  & strpos(direction, "DME") == 0
replace direction = "UNKNOWN" if center == "UNKNOWN" 

**************************************************************
* 2 Raison sociale and activity
**************************************************************	
*raisonsociale
gen raisonsociale = ""

foreach x in REP_raisonsociale SIGTAS_NOM_OU_RAISONSOCIALE ANSD_RAISON_SOCIALE TVA_RAISON_SOCIALE IS_raison_sociale {
cap noisily replace raisonsociale = `x' if raisonsociale == "" 
}

*Define variable for economic activity 
gen activity = ""
replace activity = REP_activity 
replace activity = SIGTAS_ACTIVITE if activity == "" 
replace activity = upper(activity) 


**************************************************************
* 3 Redefine some bureaus according to the 2020 selection 
**************************************************************	
replace raisonsociale = AUD2021_raisonsociale if raisonsociale == "" 

*Replace year
replace annee = 2018 if annee == . & AUD2020_type == "VG" 
replace annee = 2019 if annee == . & AUD2021_type == "VG" 

****************************************************************
* 4 Clean tax variables: drop unnecessary variables, choose between submitted and calculated 
****************************************************************
*have unique activity, center, direction and bureau for each firm
foreach var in raisonsociale activity bureau center direction SIGTAS_TYPE_CONTRIBUABLE {
preserve

	keep ninea `var'
	gsort ninea - `var'
	
	egen unique = tag(ninea) 
	keep if unique == 1 
	drop unique 

	tempfile t`var'
	sa `t`var'', replace

restore	

drop `var' 
merge n:1 ninea using `t`var'' 
drop _merge

}

*Drop variables
keep ninea annee raisonsociale direction center bureau activity *filed *_L*  MAN* IMP* EXP*  SIGTAS* REP* CLI* FOU* TVAAN* AUD2*
*Order
order ninea annee raisonsociale direction center bureau activity *filed TVA* TVA_L* IS* IS_L* RAS_IRPP* RAS_IRPP_L* TAF_L* AUD2*

****************************************************************
* 6 turn to zero missing variables
****************************************************************

	*Turn to zeros the missing values of filing behavior 
	qui ds *filed
	foreach v in `r(varlist)' { 
		replace `v' = 0 if `v' == . 
	}

	*Assign missing when no declaration has been filed
	*RAS_SVT
	foreach tax in IS TVA RAS_IRPP IMP EXP MAN TAF CLI FOU TVAAN {
	*
		qui ds `tax'_* 
		
		foreach var in `r(varlist)' { 
			if "`var'" != "`tax'_filed" {
			*display "Assign to missing `var'" 
			cap replace `var' = 0 if `tax'_filed == 0 
			}
			cap replace `var' = 0 if `var' == .			
		}
		
	}

****************************************************************
* 7 Generate useful variables 
****************************************************************

egen turnover = rowmax(IS_L5 TVA_L5)

****************************************************************
* 8 Check if data is available for the years of interest
****************************************************************

*Check if we have all the variables that we need across all years

*Check if new nineas appear over four years 
gen newninea = 1 if annee >= 2017 

bys ninea: egen newnineayes = max(newninea) 

bys ninea: egen countnewninea = total(newnineayes)
egen uniqueninearepeat 	= tag(ninea countnewninea) 
egen uniquenewninea		= tag(ninea newnineayes)

mat count = J(6,1,0)
mat rownames count = "Unique firms in 2017 or 2018" "Appearing once" "Appearing twice" "Appearing thrice" "Appearing four times" "Appearing five times"

qui count if uniquenewninea == 1 & newnineayes == 1 
mat count[1,1] = `r(N)'

forvalues r = 1/5 { 
qui count if uniqueninearepeat == 1 & newnineayes == 1 & countnewninea == `r' 
mat count[`r'+1,1] = `r(N)'
}

drop newninea newnineayes uniqueninearepeat uniquenewninea countnewninea

*sa "Programme_2021\data_proc\finaldataset", replace	
sa "$analysisdata\finaldataset", replace	


