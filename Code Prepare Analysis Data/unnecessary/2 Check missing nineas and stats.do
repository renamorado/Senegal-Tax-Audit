*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   March 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*This script reads data from digitized audit reports ("saisie data") in Senegal.

set more off
clear all 

*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","alipi") { 										// Alipio's computer
		global rootdir "D:\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits\Analysis all data\replication_package"
	}

		global rawdata "$rootdir\Raw data"
		global analysisdata "$rootdir\Working data"
	
******************
*Get missing nineas
******************
cd "$analysisdata"

tempfile drop _all
tempfile missingnineas
tempfile withnninea

foreach type in notification confirmation dge {

	use "wastedata\\`type'_appended", clear
	
	*Drop three digits at the end of ninea (if they are present)
	clonevar nineaoriginal = ninea
	
	tostring ninea, force replace 
	replace ninea = subinstr(ninea," ","",.)
	replace ninea = subinstr(ninea,".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
			
	gen missingninea = ninea == "" | ninea == "."
	
	keep missingninea bureau raisonsociale ninea filename nineaoriginal
	
	preserve 
	
		keep if missingninea == 1 
		bys raisonsociale bureau: gen n = _n
		keep if n == 1 
		drop n 
		cap noisily append using `missingnineas'
		sa `missingnineas', replace 
		
	restore 
	
	preserve

		keep if missingninea == 0 
		bys raisonsociale bureau: gen n = _n
		keep if n == 1 
		drop n 		
		cap noisily append using `withnninea'
		sa `withnninea', replace 	
		
	restore 

}

*Drop duplicates 
use `missingnineas', clear 

replace raisonsociale = trim(raisonsociale)

bys raisonsociale: gen n = _n
keep if n == 1 
drop n

sa "wastedata\\missingninea", replace 

use `withnninea', clear 

replace raisonsociale = trim(raisonsociale)

bys raisonsociale: gen n = _n
keep if n == 1 
drop n

sa "wastedata\\withnninea", replace 

tempfile drop _all

*Direct merge names with observations containing nineas (sometimes they just forgot to include the ninea in the field, but the firm is listed in the dataset) 
use "wastedata\\missingninea", clear
 
keep raisonsociale bureau filename 
gen idmissing = _n

drop if raisonsociale == ""
rename filename filenamesource
merge 1:1 raisonsociale using "wastedata\\withnninea", keepusing(ninea raisonsociale filename nineaoriginal)

	preserve
	
	keep if _merge == 3 
	keep raisonsociale ninea idmissing
	sa "wastedata\directmatch", replace 
	
	restore 

	preserve
	
	keep if _merge == 1 
	keep raisonsociale ninea idmissing bureau
	
	gen bureau2 = bureau
	replace bureau2 = "CME" if strpos(bureau, "CME") > 0
	
	sa "wastedata\stillmissing", replace 
	
	restore 


*Fuzzy matching with the list of selection 
preserve

	use "$analysisdata/wastedata/selection", clear 
	
	bys raisonsociale: gen n = _n
	keep if n == 1 
	drop n 
	
	keep raisonsociale ninea
	tostring ninea, replace force
		
	gen idlist = _n 
	
	tempfile list
	sa `list', replace 
	
restore 

*Matchit 
cd "$analysisdata"
cap erase "wastedata\matchittoken.dta"

	display "`b' TOKEN"
	
	use `list', clear
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
	
	tempfile listtemp
	sa `listtemp'

	use "wastedata\stillmissing", clear
	clonevar raisonsocialemissing = raisonsociale 
	
			display "*Matchit `dataset'"
				matchit idmissing raisonsocialemissing using `listtemp', idusing(idlist) txtusing(raisonsociale) sim(token) weights(log) override

				gsort idmissing -similscore
				by idmissing: gen n = _n
				keep if n == 1
				drop n 
				keep if similscore > 0.9
				count
				
				display "*Get the best match (using approximation of the max similscore)"
				
				bys idmissing: gen N = _N
				drop if N > 3 
				drop N
				bys raisonsocialemissing : gen n = _n
				keep if n == 1 
				drop n 
				
				keep idmissing idlist
				
				merge m:1 idlist using `listtemp', keepusing(raisonsociale ninea)
				keep if _merge == 3
				drop _merge 
				rename raisonsociale raisonsocialelist 
				
				merge m:1 idmissing using "wastedata\stillmissing", keepusing(raisonsociale bureau)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 
				
				sa "wastedata\matchittoken_selection", replace 
	

use "wastedata\matchittoken_selection", clear 

tostring ninea, replace force 

keep raisonsociale idmissing ninea 
merge m:1 idmissing using "wastedata\stillmissing"

keep if _merge == 2 
drop _merge 

keep bureau2 raisonsociale ninea idmissing

sa "wastedata\stillmissing", replace 
	
*Fuzzy matching with the firms within the dataset (there might be a typo in the name)
preserve

	cd "$rootdir"
	use "Senegal tax audits\Programme_2020\data_proc\ListeAndRepertoires", clear 
	
	gen raisonsociale1 = REP_raisonsociale 
	gen raisonsociale2 = SIGTAS_NOM_OU_RAISONSOCIALE 
	gen raisonsociale3 = ANSD_RAISON_SOCIALE
	
	gen bureau = ""
	foreach c in REP_centre REP_ugf SIGTAS_CENTRE ANSD_LIBELLE_CENTRE_FISCAL {
		
		replace bureau = "DP" if strpos(`c', "PLATEAU") > 0 & bureau == ""
		replace bureau = "PKG" if strpos(`c', "PIKI") > 0 & bureau == ""
		replace bureau = "PKG" if strpos(`c', "GUEDI") > 0 & bureau == ""
		replace bureau = "NGA" if strpos(`c', "NGOR") > 0 & bureau == ""
		replace bureau = "NGA" if strpos(`c', "ALMA") > 0 & bureau == ""
		replace bureau = "CME" if strpos(`c', "DME") > 0 & bureau == ""
		replace bureau = "CME" if strpos(`c', "CME") > 0 & bureau == ""
		replace bureau = "CPR" if strpos(`c', "CPR") > 0 & bureau == ""
		replace bureau = "DGE" if strpos(`c', "DGE") > 0 & bureau == ""
		replace bureau = "DGE" if strpos(`c', "CGE") > 0 & bureau == ""
		replace bureau = "DGE" if strpos(`c', "BCS") > 0 & bureau == ""
		replace bureau = "GD" if strpos(`c', "GRAND") > 0 & bureau == ""
	
	}
	
	keep raisonsociale* ninea bureau 
	
	reshape long raisonsociale, i(ninea bureau) j(i)
	drop if raisonsociale == ""
	drop i
	
	*Drop some observations
	drop if bureau == ""
	
	gen idlist = _n 
	
	tempfile list
	sa `list', replace 
	
restore 

*Matchit 
cd "$analysisdata"
cap erase "wastedata\matchittoken.dta"

	display "`b' TOKEN"
	
	use `list', clear
	rename bureau bureaulist 
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
	
	tempfile listtemp
	sa `listtemp'

	use "wastedata\stillmissing", clear
	clonevar raisonsocialemissing = raisonsociale 
	
			display "*Matchit `dataset'"
				matchit idmissing raisonsocialemissing using `listtemp', idusing(idlist) txtusing(raisonsociale) sim(token) weights(log) override

				gsort -similscore

				keep if similscore > 0.90 
				count
				
				display "*Get the best match (using approximation of the max similscore)"
				
				bys idmissing: gen N = _N
				drop if N > 3 
				drop N
				bys raisonsocialemissing : gen n = _n
				keep if n == 1 
				drop n 
				
				keep idmissing idlist
				
				merge m:1 idlist using `listtemp', keepusing(raisonsociale ninea bureau)
				keep if _merge == 3
				drop _merge 
				rename raisonsociale raisonsocialelist 
				
				merge m:1 idmissing using "wastedata\stillmissing", keepusing(raisonsociale bureau)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 
				
				sa "wastedata\matchittoken", replace 
	

use "wastedata\matchittoken", clear 

tostring ninea, replace force 

keep raisonsociale idmissing ninea 
merge m:1 idmissing using "wastedata\stillmissing"

keep if _merge == 2 
drop _merge 

keep bureau2 raisonsociale ninea idmissing

sa "wastedata\stillmissing", replace 

*****
*Another round of matchit
*****
*Fuzzy matching with the firms within the dataset (there might be a typo in the name)
cd "$analysisdata"
cap erase "wastedata\matchitbigram.dta"

foreach b in DP PKG NGA CME CPR DGE GD {
	
	display "`b' BIGRAM"
	
	use `list', clear
	keep if bureau == "`b'"
	replace raisonsociale = lower(raisonsociale)
	replace raisonsociale = subinstr(raisonsociale, "/", "", .)
	replace raisonsociale = subinstr(raisonsociale, "(", "", .)
	replace raisonsociale = subinstr(raisonsociale, ")", "", .)
	replace raisonsociale = subinstr(raisonsociale, "<", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)

	tempfile listtemp
	sa `listtemp'

	use "wastedata\stillmissing", clear
	keep if bureau2 == "`b'"
	replace raisonsociale = lower(raisonsociale)
	replace raisonsociale = subinstr(raisonsociale, "/", "", .)
	replace raisonsociale = subinstr(raisonsociale, "(", "", .)
	replace raisonsociale = subinstr(raisonsociale, ")", "", .)
	replace raisonsociale = subinstr(raisonsociale, "<", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
	clonevar raisonsocialemissing = raisonsociale 
	
			display "*Matchit `dataset'"
				matchit idmissing raisonsocialemissing using `listtemp', idusing(idlist) txtusing(raisonsociale) sim(bigram) weights(log) override

				gsort -similscore

				keep if similscore > 0.90 
				count
				if `r(N)' > 0 {
								
				display "*Get the best match (using approximation of the max similscore)"
				
				bys raisonsocialemissing : gen N = _N
				drop if N > 3 
				drop N
				bys raisonsocialemissing : gen n = _n
				keep if n == 1 
				drop n 
				
				keep idmissing idlist
				
				merge m:1 idlist using `listtemp', keepusing(raisonsociale ninea)
				keep if _merge == 3
				drop _merge 
				rename raisonsociale raisonsocialelist 
				
				merge m:1 idmissing using "wastedata\stillmissing", keepusing(raisonsociale)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 

				cap noisily append using "wastedata\matchitbigram"
				
				tostring ninea, replace force
				sa "wastedata\matchitbigram", replace 
				}
}

*Aggregate 
cd "$analysisdata"

use "wastedata\matchittoken_selection", clear 
tostring ninea, replace force 
append using "wastedata\matchittoken"
append using "wastedata\matchitbigram"
append using  "wastedata\directmatch"
compress raisonsociale

cap drop bureau idmissing 
bys raisonsociale: gen n = _n
drop if n > 1 
drop n

rename ninea ninea2 
sa "wastedata\foundnineas", replace 
 
******************************************************************************
*Make sure firms with same raisonsociale get the same ninea 
******************************************************************************
 clear
 foreach type in notification confirmation dge {
	cap noisily append using "wastedata\\`type'_appended", force
	cap noisily use using "wastedata\\`type'_appended"
	
 }

merge m:1 raisonsociale using "wastedata\foundnineas", replace update

 *drop if ninea == ""
 keep raisonsociale ninea* 
 bys raisonsociale: gen n = _n
 keep if n == 1 
 drop n 
 	
	*Drop three digits at the end of ninea (if they are present)
	clonevar nineaoriginal = ninea
	
	tostring ninea, force replace 
	replace ninea = subinstr(ninea," ","",.)
	replace ninea = subinstr(ninea,".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}	
	
sa "wastedata\listnineas", replace 	
 
 ******************************************************************************
 *Add found nineas to dataset 
 ******************************************************************************
cd "$analysisdata"

foreach type in notification confirmation dge {

	use "wastedata\\`type'_appended", clear
	
	replace raisonsociale = trim(raisonsociale)
	merge m:1 raisonsociale using "wastedata\listnineas", replace update
	
	 
	drop if _merge == 2 
	clonevar oldninea = ninea 
	replace ninea = ninea2 if ninea == ""
	drop ninea2  _merge 	
	
	replace bureau = "CME1" if bureau == "CME"
		
	
	gen missingninea = oldninea == ""
	gen missingninea2 = ninea == ""
 		
	*Some manual imputation of NINEAS (same as in previous dofile, but just to make sure we avoid conflicts)
	quietly do "dofiles\1 Read data\2.1 Manually input nineas.do"

	replace bureau = "PKG" if strpos(filename, "PK-G") >  0
	replace typedecontrole = trim(typedecontrole)

	drop if anneeduchrono == "==="
	replace anneeduchrono = "2020" if anneeduchrono == "202"
	destring anneeduchrono, replace force
	drop if anneeduchrono == . 
	drop if bureau == ""

	if "`type'" == "notification" {
	clonevar referencenumber = nreference
	replace referencenumber = subinstr(referencenumber, "N°", "", .)
	destring referencenumber, force replace 	
	}
	if "`type'" == "confirmation" {
	clonevar referencenumber = nreferencenotification
	replace referencenumber = subinstr(referencenumber, "N°", "", .)
	destring referencenumber, force replace 	
	}
	
	destring ninea, force gen(nineanumerique)
	clonevar firmid = nineanumerique  
	replace firmid = . if firmid < 0 
	tostring firmid, force replace 
	replace firmid = raisonsociale if firmid == "."

	sa "wastedata\\`type'_appended_addednineas", replace 
}