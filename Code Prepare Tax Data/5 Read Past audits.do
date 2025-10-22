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
	

**********************************************************************************************
*Program 2018
**********************************************************************************************

	clear 
	import excel "Programme_2019\program_2018_to_control_for\selection_VG_pour_mathiam_sans_details_ 3 Jul 2018.xlsx", firstrow clear 

	*type of audit 
	gen type = "VG" 

	*centre
	gen centre = ""
	replace centre = direction

	*Bureau
	gen bureau = csf

	*Raisonsociale
	gen raisonsociale = raison_sociale

	*Ninea
	cap gen ninea = ninea

	cap keep ninea raisonsociale bureau centre type

	sa "Programme_2021\data_waste\AUD_VG_2018", replace 


	clear 
	import excel "Programme_2019\program_2018_to_control_for\Programme_CSP.xlsx", firstrow clear 

	*type of audit 
	gen type = "CP" 

	*centre
	gen centre = ""
	replace centre = Direction

	*Bureau
	gen bureau = Centre

	*Raisonsociale
	gen raisonsociale = RaisonSociale

	*Ninea
	cap gen ninea = Ninea

	cap keep ninea raisonsociale bureau centre type

	sa "Programme_2021\data_waste\AUD_CP_2018", replace 
	
clear 
use "Programme_2021\data_waste\AUD_CP_2018"
append using "Programme_2021\data_waste\AUD_VG_2018"

qui ds ninea, not 
foreach v in `r(varlist)' { 
label var `v' "From audit selection DGID and algorithm 2018" 
rename `v' AUD2018_`v' 
}

destring ninea, force replace 

replace ninea = -_n if ninea == .

bys ninea: gen dup = cond(_N==1, 0, _n)
drop if dup > 0 & AUD2018_type == "CP" 
drop dup 

bys ninea: gen dup = cond(_N==1, 0, _n)
drop if dup > 1 
drop dup 

isid ninea

sa "Programme_2021\data_waste\AUD_2018.dta", replace 

**********************************************************************************************
*Program 2019
**********************************************************************************************

foreach m in VG CP {
	foreach d in DME DSF DGE  {
	clear 
	cap import excel "Programme_2019\spreadsheets `m'\Liste `m' pour Mathiam approved - `d'.xlsx", firstrow clear 

	*type of audit 
	cap gen type = "`m'" 

	*centre
	cap gen centre = ""
	cap replace centre = Direction

	*Bureau
	cap gen bureau = Centre

	*Raisonsociale
	cap gen raisonsociale = RaisonSociale

	*Ninea
	cap gen ninea = Ninea

	cap keep ninea raisonsociale bureau centre Méthode type

	sa "Programme_2021\data_waste\AUD_`d'_`m'_2019", replace 

	}
}

clear 
foreach m in VG CP {

foreach d in DSF DGE DME {

cap append using "Programme_2021\data_waste\AUD_`d'_`m'_2019"
cap use "Programme_2021\data_waste\AUD_`d'_`m'_2019"

}
}

qui ds ninea, not 
foreach v in `r(varlist)' { 
label var `v' "From audit selection DGID and algorithm 2019" 
rename `v' AUD2019_`v' 
}

replace ninea = -_n if ninea == . 

bys ninea: gen dup = cond(_N==1, 0, _n)
drop if dup > 0 & AUD2019_type == "CP" 
drop dup 

bys ninea: gen dup = cond(_N==1, 0, _n)
drop if dup > 1 
drop dup 

isid ninea

sa "Programme_2021\data_waste\AUD_2019.dta", replace 

**********************************************************************************************
*Program 2020
**********************************************************************************************
*VG
import excel "Programme_2020\data_proc\Liste VG 2020 approuvés", firstrow clear

qui ds
foreach v in `r(varlist)' { 
label var `v' "From audit selection DGID and algorithm 2020" 
local newname = lower("`v'")
cap rename `v' AUD2020_`newname' 
}

gen AUD2020_type = "VG"
 
cap keep AUD2020_ninea AUD2020_raisonsociale AUD2020_bureau AUD2020_centre AUD2020_méthode AUD2020_type

sa "Programme_2021\data_waste\AUD_VG_2020", replace 

*CSP
import excel "Programme_2020\data_proc\Liste Programme CSP 2020", firstrow clear

qui ds
foreach v in `r(varlist)' { 
label var `v' "From audit selection DGID and algorithm 2020" 
local newname = lower("`v'")
cap rename `v' AUD2020_`newname' 
}

gen AUD2020_type = "CP"
 
cap keep AUD2020_ninea AUD2020_raisonsociale AUD2020_bureau AUD2020_centre AUD2020_méthode AUD2020_type

sa "Programme_2021\data_waste\AUD_CP_2020", replace 

*Append
use "Programme_2021\data_waste\AUD_CP_2020", clear
append using "Programme_2021\data_waste\AUD_VG_2020"

rename AUD2020_ninea ninea 

bys ninea: gen n = _n
	replace ninea = . if n > 1 
	drop n 
	
	replace ninea = -_n if ninea == . 
	

sa "Programme_2021\data_waste\AUD_2020.dta", replace 

**********************************************************************************************
*Program 2021
**********************************************************************************************
*DSF
import excel "Programme_2021/selection files/DGID/Programme DSFv2", clear firstrow cellrange(A1)

qui ds
		foreach v in `r(varlist)' { 
        	tostring `v', force replace    
			label var `v' "From audit selection DGID 2021" 
			local newname = lower("`v'")
			cap rename `v' AUD2021_`newname' 
		}

rename AUD2021_centre AUD2021_bureau
rename  AUD2021_raisonsocial  AUD2021_raisonsociale
gen AUD2021_type = "VG"
gen AUD2021_méthode = "DGID"

cap noisily keep AUD2021_ninea AUD2021_raisonsociale AUD2021_bureau  AUD2021_méthode AUD2021_type

tempfile DSF
sa `DSF'

*CME
cap noisily tempfile drop `CME'
tempfile CME 

foreach k in "CME DKR 1" "CME DKR 2" "CPR" {
import excel "Programme_2021/selection files/DGID/PROGRAMME DME CFE", clear firstrow cellrange(A2) sheet(`k')

		qui ds
		foreach v in `r(varlist)' { 
			tostring `v', force replace    
			label var `v' "From audit selection DGID 2021" 
			local newname = lower("`v'")
			cap rename `v' AUD2021_`newname' 
		}


		gen AUD2021_type = "VG"
		gen AUD2021_méthode = "DGID"
		gen AUD2021_bureau = "`k'"

		cap noisily keep AUD2021_ninea AUD2021_raisonsociale AUD2021_bureau  AUD2021_méthode AUD2021_type
	
cap noisily append using `CME', force
sa `CME', replace 	
}

*CGE
import excel "Programme_2021/selection files/DGID/PROGRAMME DGE APPROUVE 2021", clear firstrow cellrange(A2)

		qui ds
		foreach v in `r(varlist)' { 
			tostring `v', force replace    
			label var `v' "From audit selection DGID 2021" 
			local newname = lower("`v'")
			cap rename `v' AUD2021_`newname' 
		}
		
		gen AUD2021_type = "VG"
		gen AUD2021_méthode = "DGID"
		
		cap noisily keep AUD2021_ninea AUD2021_raisonsociale AUD2021_bureau  AUD2021_méthode AUD2021_type
tempfile CGE
sa `CGE'

*Append
use `CGE', clear
append using `CME', force
append using `DSF', force

rename AUD2021_ninea ninea

	tostring ninea, replace force 
	replace ninea = subinstr(ninea," ","",.)
	replace ninea = subinstr(ninea,".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}

	destring ninea , replace force 
	
	bys ninea: gen n = _n
	replace ninea = . if n > 1 
	drop n 
	
	replace ninea = -_n if ninea == . 

*Rename bureaus
replace AUD2021_bureau = "BCS 1" if strpos(AUD2021_bureau, "BCS1") > 0 
replace AUD2021_bureau = "BCS 2" if strpos(AUD2021_bureau, "BCS2") > 0 
replace AUD2021_bureau = "BCS 3" if strpos(AUD2021_bureau, "BCS3") > 0 
replace AUD2021_bureau = "BCS 4" if strpos(AUD2021_bureau, "BCG") > 0 
replace AUD2021_bureau = "BCS 4" if strpos(AUD2021_bureau, "BCS4") > 0 

replace AUD2021_bureau = "CME 1" if strpos(AUD2021_bureau, "CME DKR 1") > 0 
replace AUD2021_bureau = "CME 2" if strpos(AUD2021_bureau, "CME DKR 2") > 0 
replace AUD2021_bureau = subinstr(AUD2021_bureau, "-", " ",. )
	
sa "Programme_2021\data_waste\AUD_2021.dta", replace 

**********************************************************************************************
*Merge
**********************************************************************************************
use "Programme_2021\data_waste\AUD_2021.dta", clear
merge 1:1 ninea using "Programme_2021\data_waste\AUD_2020.dta"
drop _merge
merge 1:1 ninea using "Programme_2021\data_waste\AUD_2019.dta"
drop _merge
merge 1:1 ninea using "Programme_2021\data_waste\AUD_2018.dta"
drop _merge 

keep *type ninea *bureau *raisonsociale
sa "Programme_2021\data_waste\PastAudits.dta", replace
