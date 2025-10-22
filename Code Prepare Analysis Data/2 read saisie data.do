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
		global rootdir_2 "C:\Users\49354415\Dropbox\Trabalho\2017 WB"
		
	}
	
	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
		global rootdir_2 "C:\Users\User\Dropbox"
		}
		global rawdata "$rootdir"	
		global rawdata2 "$rootdir_2\Infractions-saisie"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		global code "$rootdir\Analysis all data\replication_package\Code Prepare Analysis Data"
		

local date: disp  c(current_date)
di "`date'"
set scheme s1color

********************************************************************************
*Read Saisie Data and store as .dta
********************************************************************************
cd "$rawdata2"

*Three agents: 
global agents "BAMBA CHEIKH SAIDOU"

*Centers: 		
global centers "CME CPR DGE DP NGA PKG GD"

*Name of files 
local BAMBACME "CME\BAMBA_13112020.xlsx"
local BAMBACPR "CPR\BD_19042021.xlsx"
local BAMBADGE	"DGE\BD_DGE.xlsx"
local BAMBADP  "D-P\BD_27072021.xlsx"
local BAMBANGA "NG-A\BD_15-10-2021.xlsx"
local BAMBAPKG "PK-G\BD_08-03-2022.xlsx"
local BAMBAGD "GD\BD_31-05-2022.xlsx"

local CHEIKHCME "CME\CN_22022021_CME2.xlsx CME\CN_13112020_CME1.xlsx"
local CHEIKHCPR "CPR\CN_19042021.xlsx"
local CHEIKHDGE "DGE\CN_DGE.xlsx"
local CHEIKHDP "D-P\CN_27072021.xlsx"
local CHEIKHNGA "NG-A\CN_15-10-2021.xlsx"
local CHEIKHPKG "PK-G\YS_08-03-2022.xlsx"
local CHEIKHGD "GD\YS_31-05-2022.xlsx"

local SAIDOUCME "CME\20102020_CME1_MSB.xlsx CME\11022020_CME2_MSB.xlsx"
local SAIDOUCPR "CPR\MSB_CPR.xlsx"
local SAIDOUDGE "DGE\MSB_DGE.xlsx"
local SAIDOUDP "D-P\MSB_27072021.xlsx"
local SAIDOUNGA "NG-A\MSB_15-10-2021.xlsx"
local SAIDOUPKG "PK-G\CBN_08-03-2022.xlsx"
local SAIDOUGD "GD\CBN_31-05-2022.xlsx"

pause off 
foreach agent in $agents {
	
	di "`agent'"

	foreach center in $centers {
	
		di "`center'"
		local count = 0 
		
		foreach file in ``agent'`center'' {
		
		local ++count
		
		di "`agent'\\`center'\\`file'"	
		
			*Check tabs 
			 import excel using "`agent'\\`file'", describe
			local n_sheets `r(N_worksheet)'
				forvalues i = 1/`n_sheets' {
					local sheet`i' `r(worksheet_`i')'
				}
				
			*Import 
			forvalues i = 1/`n_sheets' {
				
				display "`sheet`i''"
				
				*Only use sheets of Notification or Confirmation
				if strpos("`sheet`i''", "tion") > 0 | strpos("`sheet`i''", "Feuil") > 0 {
					
					import excel "`agent'\\`file'", sheet(`sheet`i'') cellrange(A2) clear firstrow
					
					*Standardize variable names
					qui ds
					qui foreach d in `r(varlist)' {
						
						cap noisily replace `d' = . if `d' == 0
						cap noisily replace `d' = "" if `d' == "DS"
						cap noisily replace `d' = "" if `d' == "PL"
						
						tostring `d', force replace 
						replace `d' = "" if `d' == "."
 						
						local newname = ustrlower( ustrregexra( ustrnormalize( "`d'", "nfd" ) , "\p{Mark}", "" )  )
						rename `d' `newname' 
						
						
					}

					*Drop totally empty rows 	
					dropmiss, obs force
					
					*Generate a variable that reminds where the info comes from 
					gen filename = "`agent'\\`file'"
					
					save "$wastedata\Saisie`agent'_`center'_`count'_`sheet`i''", replace 
					
					cd "$rawdata2"

				}
			}	
		}	
	}
}

********************************************************************************
*Read .dta and clean 
********************************************************************************

cd "$wastedata"

*Locals with variables to be replaced
{
local saisiebamba_cme_1_confirmation q-an
local saisiebamba_cme_1_notification w-ar
local saisiebamba_cpr_1_confirmation q-an
local saisiebamba_cpr_1_notification y-ax
local saisiebamba_dge_1_feuil1       ""
local saisiebamba_dp_1_confirmation  q-an
local saisiebamba_dp_1_notification  y-az
local saisiebamba_nga_1_confirmation s-ap
local saisiebamba_nga_1_notification z-ba
local saisiebamba_pkg_1_confirmation s-ap
local saisiebamba_pkg_1_notification z-ay
local saisiebamba_gd_1_confirmation  s-at
local saisiebamba_gd_1_notification z-ba

local saisiecheikh_cme_1_confirmation q-an
local saisiecheikh_cme_1_notification y-ax
local saisiecheikh_cme_2_confirmation q-an
local saisiecheikh_cme_2_notification y-ap
local saisiecheikh_cpr_1_confirmation q-an
local saisiecheikh_cpr_1_notification y-ax
local saisiecheikh_dge_1_feuil1       ""
local saisiecheikh_dp_1_confirmation  q-ap
local saisiecheikh_dp_1_notification  y-ax
local saisiecheikh_nga_1_confirmation s-ar
local saisiecheikh_nga_1_notification z-ay
local saisiecheikh_pkg_1_confirmation s-ap
local saisiecheikh_pkg_1_notification z-ay
local saisiecheikh_gd_1_confirmation s-at
local saisiecheikh_gd_1_notification z-ba

local saisiesaidou_cme_1_confirmation q-an
local saisiesaidou_cme_1_notification w-av
local saisiesaidou_cme_2_confirmation q-an
local saisiesaidou_cme_2_notification y-ax
local saisiesaidou_cpr_1_confirmation q-an
local saisiesaidou_cpr_1_notification y-ax
local saisiesaidou_dge_1_feuil1       ""
local saisiesaidou_dp_1_confirmation q-an
local saisiesaidou_dp_1_notification y-az
local saisiesaidou_nga_1_confirmation r-ao
local saisiesaidou_nga_1_notification z-ba
local saisiesaidou_pkg_1_confirmation s-ap
local saisiesaidou_pkg_1_notification z-ay
local saisiesaidou_gd_1_confirmation s-at
local saisiesaidou_gd_1_notification z-ba

}

*local f : dir  files "*.dta"
local f : dir "." files "*.dta"
display ""`f'""

foreach ff in `f' {
	
display "`ff'"

if strpos("`ff'", "cheikh") | strpos("`ff'", "saidou") | strpos("`ff'", "bamba")  {

	use "$wastedata\\`ff'", clear
pause
		if strpos("`ff'", "notification") > 0 {
			local type = "notification"
		}

		if strpos("`ff'", "confirmation") > 0 {
			local type = "confirmation"
		}	
		
		local replacevariables = subinstr("`ff'", ".dta", "", . )

		*If there are variables to rename, do it (DGE does not have variables to rename)
		if "``replacevariables''" != "" {
		
			*List variables to replace and loop over them
			ds ``replacevariables''
			foreach d in `r(varlist)' {
					
				display "`d'"
				 
				local yearvariable: var label `d'
				if "`yearvariable'" != "" { 
					local year = `yearvariable'
					destring `d', replace force
					rename `d' ds_`year'_`type'
				}
				if "`yearvariable'" == "" { 
					destring `d', replace force
					rename `d' pl_`year'_`type'
				}		

			}
			
		}
		
		*Overwrite files
		save "$wastedata\\`ff'", replace 
}

}

***********************************************************
*Append files if same center and type 
***********************************************************
cd "$wastedata"

foreach type in notification confirmation dge {

cap noisily erase "`type'_appended.dta"
cap noisily erase "`type'_appended_addednineas.dta"
cap noisily erase "`type'_reshaped.dta"

local f : dir "." files "*.dta"

tempfile drop _all
tempfile `type'_appended

	foreach ff in `f' {
		
	display "`ff'"
		if strpos("`ff'", "`type'") > 0 & strpos("`ff'", "saisie") > 0{
			
			use "`ff'", clear  
			tostring ninea, force replace 
			qui cap noisily append using ``type'_appended', force
			sa ``type'_appended', replace
		sleep 100
		}
	}

clonevar bureau_saisie = bureau
replace bureau = trim(bureau)
replace bureau = subinstr(bureau, "-", "", .)	
replace bureau = subinstr(bureau, "/", "", .)
replace bureau = subinstr(bureau, "DME", "CME", .)
replace bureau = subinstr(bureau, "CM2", "CME2", .)
replace bureau = subinstr(bureau, "PIKG", "PKG", .)
replace bureau = "DGE" if strpos(filename, "DGE") > 0 
	
	*Original raisonsociale 
	clonevar raisonsociale_original = raisonsociale
	
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
	quietly do "$code/AUX Manually input nineas.do"
	
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
	
	*Clean variables
	replace ninea = upper(ninea)
	replace ninea = trim(ninea)
	replace ninea = "" if strpos(ninea, "PAS")
	
	replace bureau = "CME1" if bureau == "CME"
    replace bureau = "NGA" if strpos(filename, "NG-A") > 0
    replace bureau = "CME2" if strpos(filename, "CME2") > 0
	

	replace typedecontrole  = trim(typedecontrole)
	replace typedecontrole  = "CSP" if typedecontrole == "CPS"
	replace typedecontrole  = "VG" if typedecontrole == "PV"
	replace typedecontrole  = "CSP" if typedecontrole == ""

	gen typesimple = "AUTRES" 

	replace typesimple = "IS" if naturedimpots == "IS"
	replace typesimple = "IS" if strpos(naturedimpots, "IS") > 0 
	replace typesimple = "IS" if strpos(naturedimpots, "SOCIETE") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "ENREGIS") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "DISTRI") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "TERRAINS") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "REINTEGRATIONS") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "RISTOURNES") > 0 
	replace typesimple = "AUTRES" if strpos(naturedimpots, "INSUFFISANCE") > 0 

	replace typesimple = "RAS" if naturedimpots == "RAS"
	replace typesimple = "RAS" if naturedimpots == "IR"
	replace typesimple = "RAS" if strpos(naturedimpots, "RAS") > 0 
	replace typesimple = "RAS" if strpos(naturedimpots, "RETENUES INSUFFISANTES SUR LES SALAIRES") > 0 
	replace typesimple = "RAS" if strpos(naturedimpots, "IR") > 0  & strpos(naturedimpots, "SAL") > 0
	replace typesimple = "RAS" if strpos(naturedimpots, "IR") > 0  & strpos(naturedimpots, "ARRET DEF") > 0

	replace typesimple = "AUTRES" if strpos(naturedimpots, "TIERS") > 0 

	replace typesimple = "TVA" if naturedimpots == "TVA"
	replace typesimple = "TVA" if naturedimpots == "TV A"
	replace typesimple = "TVA" if strpos(naturedimpots, "TVA") > 0 

	*Check
	tab naturedimpots if typesimple == "TVA"
	tab naturedimpots if typesimple == "IS"
	tab naturedimpots if typesimple == "RAS"
	tab naturedimpots if typesimple == "AUTRES", sort
	
save "$wastedata\\`type'_appended", replace 
 
}

*****************************************************************
*ADD THE FIRM IDENTIFIER TO FIRMS THAT DO NOT HAVE AN IDENTIFIER IN THE AUDIT REPORTS
*****************************************************************
******************
*Get missing nineas
******************
cd "$wastedata"

tempfile drop _all
tempfile missingnineas
tempfile withnninea

foreach type in notification confirmation dge {

	use "`type'_appended", clear
	
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

sa "$wastedata\\missingninea", replace 

use `withnninea', clear 

replace raisonsociale = trim(raisonsociale)

bys raisonsociale: gen n = _n
keep if n == 1 
drop n

sa "$wastedata\\withnninea", replace 

tempfile drop _all

*Direct merge names with observations containing nineas (sometimes they just forgot to include the ninea in the field, but the firm is listed in the dataset) 
use "$wastedata\\missingninea", clear
 
keep raisonsociale bureau filename 
gen idmissing = _n

drop if raisonsociale == ""
rename filename filenamesource
merge 1:1 raisonsociale using "$wastedata\\withnninea", keepusing(ninea raisonsociale filename nineaoriginal)

	preserve
	
	keep if _merge == 3 
	keep raisonsociale ninea idmissing
	sa "$wastedata\directmatch", replace 
	
	restore 

	preserve
	
	keep if _merge == 1 
	keep raisonsociale ninea idmissing bureau
	
	gen bureau2 = bureau
	replace bureau2 = "CME" if strpos(bureau, "CME") > 0
	
	sa "$wastedata\stillmissing", replace 
	
	restore 


*Fuzzy matching with the list of selection 
preserve

	use "$wastedata/selection", clear 
	
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
cd "$wastedata"
cap erase "$wastedata\matchittoken.dta"

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

	use "$wastedata\stillmissing", clear
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
				
				merge m:1 idmissing using "$wastedata\stillmissing", keepusing(raisonsociale bureau)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 
				
				sa "$wastedata\matchittoken_selection", replace 
	

use "$wastedata\matchittoken_selection", clear 

tostring ninea, replace force 

keep raisonsociale idmissing ninea 
merge m:1 idmissing using "$wastedata\stillmissing"

keep if _merge == 2 
drop _merge 

keep bureau2 raisonsociale ninea idmissing

sa "$wastedata\stillmissing", replace 
	
*Fuzzy matching with the firms within the dataset (there might be a typo in the name)
preserve

	use "$rawdata\Programme_2020\data_proc\ListeAndRepertoires", clear 
	
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
cd "$wastedata"
cap erase "$wastedata\matchittoken.dta"

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

	use "$wastedata\stillmissing", clear
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
				
				merge m:1 idmissing using "$wastedata\stillmissing", keepusing(raisonsociale bureau)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 
				
				sa "$wastedata\matchittoken", replace 
	

use "$wastedata\matchittoken", clear 

tostring ninea, replace force 

keep raisonsociale idmissing ninea 
merge m:1 idmissing using "$wastedata\stillmissing"

keep if _merge == 2 
drop _merge 

keep bureau2 raisonsociale ninea idmissing

sa "$wastedata\stillmissing", replace 

*****
*Another round of matchit
*****
*Fuzzy matching with the firms within the dataset (there might be a typo in the name)
cd "$wastedata"
cap erase "$wastedata\matchitbigram.dta"

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

	use "$wastedata\stillmissing", clear
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
				
				merge m:1 idmissing using "$wastedata\stillmissing", keepusing(raisonsociale)
				keep if _merge == 3
				drop _merge 
				
				tostring ninea, replace force 

				cap noisily append using "$wastedata\matchitbigram"
				
				tostring ninea, replace force
				sa "$wastedata\matchitbigram", replace 
				}
}

*Aggregate 
cd "$wastedata"

use "$wastedata\matchittoken_selection", clear 
tostring ninea, replace force 
append using "$wastedata\matchittoken"
append using "$wastedata\matchitbigram"
append using  "$wastedata\directmatch"
compress raisonsociale

cap drop bureau idmissing 
bys raisonsociale: gen n = _n
drop if n > 1 
drop n

rename ninea ninea2 
sa "$wastedata\foundnineas", replace 
 
******************************************************************************
*Make sure firms with same raisonsociale get the same ninea 
******************************************************************************
 clear
 foreach type in notification confirmation dge {
	cap noisily append using "$wastedata\\`type'_appended", force
	cap noisily use using "$wastedata\\`type'_appended"
	
 }

merge m:1 raisonsociale using "$wastedata\foundnineas", replace update

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
	
sa "$wastedata\listnineas", replace 	
 
 ******************************************************************************
 *Add found nineas to dataset 
 ******************************************************************************
cd "$wastedata"

foreach type in notification confirmation dge {

	use "$wastedata\\`type'_appended", clear
	
	replace raisonsociale = trim(raisonsociale)
	merge m:1 raisonsociale using "$wastedata\listnineas", replace update
	
	 
	drop if _merge == 2 
	clonevar oldninea = ninea 
	replace ninea = ninea2 if ninea == ""
	drop ninea2  _merge 	
	
	replace bureau = "CME1" if bureau == "CME"
		
	
	gen missingninea = oldninea == ""
	gen missingninea2 = ninea == ""
 		
	*Some manual imputation of NINEAS (same as in previous dofile, but just to make sure we avoid conflicts)
	quietly do "$code/AUX Manually input nineas.do"

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

	sa "$wastedata\\`type'_appended_addednineas", replace 
}

********************************************************
********************************************************
*MERGE DATASETS TO CREATE A CONSOLIDATED DATASET OF AUDITS (SAISIE)
********************************************************
********************************************************

******************************************
*Notification
******************************************	
use "$wastedata\\notification_appended_addednineas", clear

unique firmid

*Drop duplicates of reference number 
replace referencenumber = -_n if referencenumber == . 
egen ID = group(referencenumber firmid typedecontrole anneeduchrono)
egen ID1 = group(referencenumber firmid)
egen ID2 = group(firmid anneeduchrono typedecontrole)

clonevar evasion = ds
destring evasion, replace force

clonevar penalty = pl
destring penalty, replace force

gen penaltyrate = 100*penalty/evasion

tempfile notification
sa `notification'

preserve 
	bys ID1: gen n = _n
	keep if n == 1 
	drop n

	tempfile notification1
	sa `notification1', replace 
restore 

preserve 
	bys ID2: gen n = _n
	keep if n == 1 
	drop n
	
	tempfile notification2
	sa `notification2', replace 
restore 

******************************************
*Confirmation method 1 - merge by reference number, then do second and third rounds
******************************************
use "$wastedata\\confirmation_appended_addednineas", clear

clonevar anneeconf = anneeduchrono 
clonevar nineaconf = ninea
clonevar raisonsocialeconf = raisonsociale
clonevar typedecontroleconf = typedecontrole
clonevar bureauconf = bureau

sort anneeduchrono ninea 
gen IDconfirmation = _n

tempfile confirmation
sa `confirmation'

*Merge 
merge m:1 referencenumber firmid using `notification1'

preserve
	keep if _merge >= 3 
	tempfile firstmatch
	sa `firstmatch'
	
restore 

*Second round of merge using firmid
keep if _merge == 1
drop _merge
merge m:1 firmid anneeduchrono typedecontrole using `notification2', replace update

preserve
	keep if _merge >= 3 
	tempfile secondmatch
	sa `secondmatch'
	
restore 

*Third round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
preserve
	keep if _merge == 1
	drop _merge
	replace anneeduchrono = anneeduchrono - 1
	merge m:1 firmid anneeduchrono typedecontrole using `notification2', replace update
	replace anneeduchrono = anneeduchrono + 1 if _merge == 1 
	tempfile thirdmatch
	sa `thirdmatch'
	
restore 

*Integrate the two rounds 
use `firstmatch', clear
append using `secondmatch', force 
append using `thirdmatch', force 

keep IDconfirmation ID ID1 ID2 typedecontrole* firmid anneeduchrono* anneeconf referencenumber _merge
drop if IDconfirmation == .
drop _merge 

tempfile crosswalk
sa `crosswalk', replace

*****************************************
*****************************************
*Clean data on notification and confirmation
*****************************************
*****************************************	

use `notification', clear

forvalues x = 1/4 {
	
	replace natureinfraction`x' = naturedinfractions`x' if natureinfraction`x' == "" & naturedinfractions`x' != ""
	drop naturedinfractions`x' 
	
}

cap noisily generate abandonabsencederedressement = . 
keep anneeduchrono raisonsociale bureau bureau_saisie typedecontrole typesimple referencenumber abandonabsencederedressement droitssimples penalites naturedimpots natureinfraction* ds_* pl_* chefdebureau verificateur* ninea ds pl filename* date* firmid

*Infractions string 
gen infractions = natureinfraction1 + " " + natureinfraction2 + " " + natureinfraction3 + " " + natureinfraction4
drop natureinfraction* 
replace infractions = trim(infractions)

*Drop duplicates of reference number 
egen ID = group(referencenumber firmid typedecontrole anneeduchrono)
egen ID1 = group(referencenumber firmid)
egen ID2 = group(firmid anneeduchrono typedecontrole)
egen ID3 = group(firmid anneeduchrono)

*Save infractions
preserve

	keep ID2 infractions typesimple

	bys ID2 typesimple: gen n = _n
	keep if n == 1 
	drop n 

	reshape wide infractions, i(ID2) j(typesimple) string
	
	tempfile auditsinfractions 
	sa `auditsinfractions', replace 	

restore

*Save audits characteristics
preserve

	keep ID* anneeduchrono raisonsociale bureau referencenumber typedecontrole datedereuniondesynthese date* chefdebureau verificateur* ninea datedavisdatededemandede filename* ninea* firmid bureau_saisie
	
	rename datedenvoi  datenotification

	bys ID2: gen n = _n
	keep if n == 1 
	drop n 

	tempfile auditsinfo 
	sa `auditsinfo', replace 

restore

*Collapse numerical variables by ID2 (ninea type year)
keep ID2 droitssimples penalites typesimple ds_* pl_*  

qui ds typesimple , not
foreach var in `r(varlist)' {
    destring `var', replace force 
}

*Severe infractions 
gen penaltyrate = penalites/droitssimples 

gen mildinfraction = penaltyrate < 0.3 & penaltyrate > 0 
gen mediuminfraction = penaltyrate > 0.3 & penaltyrate < 0.7 
gen severeinfraction = penaltyrate > 0.7 & penaltyrate != .  

drop penaltyrate 

*Count infractions
gen numberinfractions = penalites > 0 & penalites != . 

collapse(sum) droitssimples penalites ds_* pl_* numberinfractions mildinfraction mediuminfraction severeinfraction, by(ID2 typesimple)

rename droitssimples droitssimples_notification
rename penalites penalites_notification

reshape wide droitssimples penalites ds_* pl_* numberinfractions  mildinfraction mediuminfraction severeinfraction, i(ID2) j(typesimple) string

merge 1:1 ID2 using `auditsinfo'
drop _merge 

merge 1:1 ID2 using `auditsinfractions'
drop _merge 

isid firmid anneeduchrono typedecontrole, missok
drop if firmid == ""
drop if anneeduchrono == . 
drop if typedecontrole == ""

tempfile notification
sa "$wastedata\notification_reshaped", replace

******************************************
*Confirmation
*******************************************
use `confirmation', clear

keep anneeduchrono* raisonsociale bureau bureau_saisie typedecontrole typesimple nreference referencenumber nreferencenotification date* datedenvoi droitssimples penalites naturedimpots ds_* pl_* chefdebureau verificateur*  ninea  filename* date* IDconfirmation firmid 
drop ds_dif pl_dif 

replace naturedimpots = trim(naturedimpots)
replace naturedimpots = upper(naturedimpots)
replace typedecontrole = trim(typedecontrole)

merge 1:1 IDconfirmation using `crosswalk'
drop _merge 

egen IDaudit = group(firmid anneeduchrono typedecontrole)
sum ID2 
replace IDaudit = IDaudit + `r(max)'
replace IDaudit = ID2 if ID2 != .

preserve

	keep anneeduchrono* raisonsociale bureau bureau_saisie typedecontrole referencenumber nreferencenotification date* datedenvoi chefdebureau verificateur* ninea datededemarrage datedavisdatededemandede filename ninea* firmid ID*

	ds date* 
	foreach v in `r(varlist)' {
		rename `v' `v'_conf
	}
	
	rename datedenvoi  dateconfirmation
	
	bys IDaudit: gen n = _n
	keep if n == 1 
	drop n 

	tempfile auditsinfo 
	sa `auditsinfo', replace 

restore

keep IDaudit droitssimples penalites typesimple ds_* pl_*

qui ds typesimple, not
foreach var in `r(varlist)' {
    destring `var', replace force 
}

*Severe infractions 
gen penaltyrate = penalites/droitssimples 

gen mildinfraction = penaltyrate < 0.3 & penaltyrate > 0 
gen mediuminfraction = penaltyrate > 0.3 & penaltyrate < 0.7 
gen severeinfraction = penaltyrate > 0.7 & penaltyrate != .  

drop penaltyrate 

*Count infractions
gen numberinfractions = penalites > 0 & penalites != . 

collapse (sum) droitssimples penalites ds_* pl_* numberinfractions  mildinfraction mediuminfraction severeinfraction, by(IDaudit typesimple)

rename droitssimples droitssimples_confirmation
rename penalites penalites_confirmation

reshape wide droitssimples penalites ds_* pl_* numberinfractions  mildinfraction mediuminfraction severeinfraction, i(IDaudit) j(typesimple) string

merge 1:1 IDaudit using `auditsinfo'
drop _merge 

rename typedecontrole typedecontroleconfirmation

isid IDaudit, missok
drop IDaudit 

tempfile confirmation
sa "$wastedata\confirmation_reshaped", replace

*****************************************
*DGE
*******************************************
use "$wastedata\\dge_appended_addednineas", clear

keep anneeduchrono raisonsociale bureau bureau_saisie typesimple abandonabsencederedressement typedecontrole droitssimples* penalites* naturedimpots ds_* pl_* chefdebureau verificateur* ninea  filename date* naturedinfraction* feuille
cap drop ds_dif pl_dif  

*Infractions string 
gen infractions = naturedinfraction1 + " " + naturedinfraction2 + " " + naturedinfraction3 + " " + naturedinfraction4 + " " + naturedinfraction5
drop naturedinfraction* 
replace infractions = trim(infractions)

*Identifier of the audit 
destring ninea, force gen(nineanumerique)

clonevar firmid = nineanumerique  
replace firmid = . if firmid < 0 
tostring firmid, force replace 
replace firmid = raisonsociale if firmid == "."

sort ninea raisonsociale
replace nineanumerique = -_n if nineanumerique == .
bys raisonsociale: egen nineatemp = min(nineanumerique) 
replace nineanumerique = nineatemp if nineanumerique < 0 
drop nineatemp 

replace typedecontrole = trim(typedecontrole)

egen IDdge = group(anneeduchrono firmid typedecontrole)

preserve

	keep IDdge infractions typesimple

	bys IDdge typesimple: gen n = _n
	keep if n == 1 
	drop n 

	reshape wide infractions, i(IDdge) j(typesimple) string
	
	tempfile auditsinfractions 
	sa `auditsinfractions', replace 	

restore

preserve

	keep anneeduchrono raisonsociale bureau bureau_saisie typedecontrole chefdebureau verificateur* ninea datededemarrage date* filename* ninea* abandonabsencederedressement typesimple firmid IDdge feuille
	
	bys IDdge: gen n = _n
	keep if n == 1 
	drop n 

	tempfile auditsinfo 
	sa `auditsinfo', replace 	

restore

keep IDdge droitssimples* penalites* typesimple ds_* pl_*

qui ds typesimple, not
foreach var in `r(varlist)' {
    destring `var', replace force 
}

*Severe infractions 
gen penaltyrate = penalites_confirmation/droitssimples_confirmation
replace penaltyrate = penalites_notification/droitssimples_notification if penaltyrate == . 

gen mildinfraction = penaltyrate < 0.3 & penaltyrate > 0 
gen mediuminfraction = penaltyrate > 0.3 & penaltyrate < 0.7 
gen severeinfraction = penaltyrate > 0.7 & penaltyrate != .  

drop penaltyrate 

*Count infractions
gen numberinfractions = (penalites_confirmation > 0 & penalites_confirmation != .) |   (penalites_notification > 0 & penalites_notification != .)

collapse(sum) droitssimples* penalites* ds_* pl_* numberinfractions mildinfraction mediuminfraction severeinfraction, by(IDdge typesimple)

reshape wide droitssimples* penalites* ds_* pl_* numberinfractions mildinfraction mediuminfraction severeinfraction, i(IDdge) j(typesimple) string

merge 1:1 IDdge using `auditsinfo'
drop _merge 

merge 1:1 IDdge using `auditsinfractions'
drop _merge 

destring anneeduchrono, replace force 

tempfile dge
sa "$wastedata\dge_reshaped", replace

*******************************************
*Put all data together 
*******************************************

use "$wastedata\confirmation_reshaped", clear 

rename filename filename_confirmation
clonevar raisonsocialeconf = raisonsociale 
clonevar nineaconf = ninea
clonevar typedecontroleconf = typedecontrole
clonevar referencenumberconf = referencenumber

*merge 1:1 anneeduchrono firmid using "wastedata\notification_reshaped", replace update
merge m:1 ID2 using "$wastedata\notification_reshaped", replace update
gen confirmation = _merge == 1 | _merge >= 3 
gen notification = _merge == 2 | _merge >= 3
drop _merge 

append using "$wastedata\dge_reshaped", force 

replace typedecontrole = typedecontroleconf if typedecontrole == ""

egen IDaudit = group(firmid anneeduchrono typedecontrole)

*Save audits info
preserve

	keep anneeduchrono* raisonsociale bureau bureau_saisie typedecontrole referencenumber nreferencenotification datedereuniondesynthese date* chefdebureau verificateur* datededemarrage datedavisdatededemandede filename* ninea*  infractions* firmid ID* notification confirmation feuille
	
	bys IDaudit: gen n = _n
	keep if n == 1 
	drop n 

	tempfile auditsinfo 
	sa `auditsinfo', replace 

restore

keep firmid anneeduchrono droitssimples* penalites* ds_* pl_*  IDaudit numberinfractions* mildinfraction* mediuminfraction* severeinfraction*

collapse(sum) droitssimples* penalites* ds_* pl_* numberinfractions* mildinfraction* mediuminfraction* severeinfraction*, by(IDaudit)

merge 1:1 IDaudit using `auditsinfo'
drop _merge 

*Generate useful variables
order annee* ID* firmid raisonsociale ninea* bureau typedecontrole
drop IDconfirmation ID ID1 ID2 ID3 IDdge

egen droitssimples_confirmation = rowtotal(droitssimples_confirmation*)
egen penalites_confirmation = rowtotal(penalites_confirmation*)

egen droitssimples_notification = rowtotal(droitssimples_notification*)
egen penalites_notification = rowtotal(penalites_notification*)

egen numberinfractions = rowtotal(numberinfractions*)
egen mildinfraction = rowtotal(mildinfraction*)
egen mediuminfraction = rowtotal(mediuminfraction*)
egen severeinfraction = rowtotal(severeinfraction*)

gen numberinfractionsmain = numberinfractions - numberinfractionsAUTRES
gen mildinfractionmain = mildinfraction - mildinfractionAUTRES
gen mediuminfractionmain = mediuminfraction - mediuminfractionAUTRES
gen severeinfractionmain = severeinfraction - severeinfractionAUTRES

la var numberinfractions "Number of infractions"
la var numberinfractionsmain "Number of infractions (main taxes)"
la var mildinfraction "Number of mild infractions"
la var mildinfractionmain "Number of mild infractions (main taxes)"
la var mediuminfraction "Number of medium infractions"
la var mediuminfractionmain "Number of medium infractions (main taxes)"
la var severeinfraction "Number of severe infractions"
la var severeinfractionmain "Number of severe infractions (main taxes)"

drop nineanumerique nineaconf

gen saisie = 1 
label var saisie "Observation in saisie data"

rename datedavisdatededemandede_conf datedavisdemande_conf
rename datedereponseducontribuable_conf datedereponseducont_conf

*Treat dates 
ds date*, varwidth(32) 
foreach v in `r(varlist)' {

	if (strpos("`v'", "xxx") == 0) {
	gen temp`v' = `v' if strpos(`v', "/") > 0
	gen month = substr(temp`v' , 1, strpos(temp`v' , "/") - 1)
	gen day = substr(temp`v' , strpos(temp`v' , "/") + 1, length(temp`v' ) - strpos(temp`v' , "/") - 5)
	gen year = substr(temp`v' , length(temp`v' ) - 3, 4)

	destring month, replace force
	destring day, replace force
	destring year, replace force

	gen `v'date  = mdy(month, day, year)
	format `v'date %td
	drop month day year

	drop temp`v'
	gen temp`v' = `v' if strpos(`v', "/") == 0
	replace temp`v' = "" if strpos(temp`v', "N°") > 0  
	destring temp`v' , force replace
	format temp`v' %td

	replace `v'date = temp`v' if temp`v' != .
	drop temp`v'
	
	drop `v'
	rename `v'date `v'
	}
}

*Clean infractions
foreach v of varlist infractions* {
    
	replace `v' = ustrupper( ustrregexra( ustrnormalize(`v', "nfd" ) , "\p{Mark}", "" ) )	
	
}

gen infractions = ""
replace infractions = "TVA - " + infractionsTVA if infractionsTVA != ""
replace infractions = infractions + ", IS - " + infractionsIS if infractionsIS != ""
replace infractions = infractions + ", RAS - " + infractionsRAS if infractionsRAS != ""
replace infractions = infractions + ", AUTRES - " + infractionsAUTRES if infractionsAUTRES != ""
replace infractions = trim(infractions)
replace infractions = subinstr(infractions, ",", "", 1) if strpos(infractions, ",") == 1 

replace bureau_saisie = bureau if bureau_saisie == ""

label var IDaudit "Unique identifier: firmid anneeduchrono typedecontrole"

sa "$wastedata\\datasetsaisie_temp", replace