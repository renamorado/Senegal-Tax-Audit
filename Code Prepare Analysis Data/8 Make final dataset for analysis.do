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

		
	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		global code "$rootdir\Analysis all data\replication_package\Code Prepare Analysis Data"

local date: disp  c(current_date)
di "`date'"
set scheme s1color

*Load data on selection and audits
use "$wastedata/merged_selection_audits", clear 

*Add tax declarations data
merge m:1 firmid using "$wastedata\taxdeclarationswide_allfirms.dta"
gen taxdata = _merge > 1 
drop _merge

*Add the riskscores and clusters of 2019 
preserve 

			use "$rawdata\Programme_2019\proc\ALLDATASETS_riskscore.dta", clear
			
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

			keep ninea cluster RS_FY1417_TOTAL_LOGAVREV
			
			gsort ninea -RS_FY1417_TOTAL_LOGAVREV
			by ninea: gen n = _n
			keep if n == 1 
			drop n
			
			rename RS_FY1417_TOTAL_LOGAVREV riskscoretemp2019
			rename cluster cluster2019
			clonevar firmid = ninea 
			
			tempfile data2019 
			sa `data2019', replace
isid ninea
restore 

merge m:1 firmid using `data2019'
drop _merge 

*Add the riskscores and clusters of 2020 
preserve 

			use "$rawdata\Programme_2020\data_proc\riskscore", clear
			gen riskscoretemp2020 = temp_riskscore*log(turnover + 1) 
			
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

			keep ninea cluster riskscoretemp2020
			
			gsort ninea -riskscoretemp2020
			by ninea: gen n = _n
			keep if n == 1 
			drop n
			
			rename cluster cluster2020

			clonevar firmid = ninea 
			
			tempfile data2020 
			sa `data2020', replace
isid ninea
restore 

merge m:1 firmid using `data2020'
drop _merge 

*Clean some variables
clonevar annee = anneeduchrono
label var annee "Year of audit (notification)"

rename replacement safeties
replace selection = 1 if safeties == 1 
generate horsprogramme = selection == 0 & saisie == 1 
replace algorithm = algorithm == 1
replace safeties = safeties == 1 
replace dgid = dgid == 1 
replace random = random == 1 
replace overlap = algorithm == 1 & dgid == 1 

replace saisie = 0 if saisie == . 
replace selection = 0 if selection == . 

destring controle, replace force
replace controle = 0 if controle == . 

replace selectionyear = 0 if selectionyear == . 
replace controle = 0 if controle == . 

drop if firmid == "" //??

order ninea raisonsociale controle center

replace center = "CGE" if center == "DGE"

replace bureau = "CME1" if center == "CME 1"
replace bureau = "CME2" if center == "CME 2"
replace bureau = "DGE" if center == "DGE"
replace bureau = "DGE" if center == "CGE"
replace bureau = "CPR" if center == "CPR"
replace bureau = "DP" if strpos(center, "PLATEAU") > 0
replace bureau = "NGA" if strpos(center, "NGOR") > 0 | strpos(center, "ALMADIE") > 0 
replace bureau = "PKG" if strpos(center, "PIKIN") > 0 | strpos(center, "GUEDIA") > 0 
replace bureau = "GD" if strpos(center, "GRAND") > 0

*Detailed bureau
gen bureau_detailed = bureau 
replace bureau_detailed = bureau_selection if strpos(bureau_selection, "BCS") > 0 
replace bureau_detailed = "CME1" if strpos(bureau_selection, "CME 1") > 0 
replace bureau_detailed = "CME2" if strpos(bureau_selection, "CME 2") > 0 
replace bureau_detailed = "CPR" if strpos(bureau_selection, "CPR") > 0 

replace bureau_detailed = bureau_selection if strpos(bureau_taxdata, "BCS") > 0 & bureau_selection == ""
replace bureau_detailed = "CME1" if strpos(bureau_taxdata, "CME 1") > 0  & bureau_selection == ""
replace bureau_detailed = "CME2" if strpos(bureau_taxdata, "CME 2") > 0 & bureau_selection == ""
replace bureau_detailed = "CPR" if strpos(bureau_taxdata, "CPR") > 0 & bureau_selection == ""

replace bureau_detailed = bureau_selection if strpos(bureau_saisie, "BCS") > 0 & bureau_selection == ""
replace bureau_detailed = "CME1" if strpos(bureau_saisie, "CME 1") > 0  & bureau_selection == ""
replace bureau_detailed = "CME2" if strpos(bureau_saisie, "CME 2") > 0 & bureau_selection == ""
replace bureau_detailed = "CPR" if strpos(bureau_saisie, "CPR") > 0 & bureau_selection == ""

replace bureau_detailed = "CGE BCS4" if bureau_detailed == "DGE"

*Correct bureau 
replace bureau = "DGE" if strpos(bureau_detailed, "BCS") > 0
replace bureau = "CME1" if strpos(bureau_detailed, "CME1") > 0
replace bureau = "CME2" if strpos(bureau_detailed, "CME2") > 0
replace bureau = "CPR" if strpos(bureau_detailed, "CPR") > 0

replace bureau_detailed = bureau if bureau_detailed == ""

*Create variable for center (more aggregated)
replace center = "CME 1" if bureau == "CME 1" &  center == ""
replace center = "CME 2" if bureau == "CME 2" &  center == ""
replace center = "CGE" if strpos(bureau, "CGE") > 0  &  center == ""
replace center = "CGE" if strpos(bureau, "DGE") > 0  &  center == ""
replace center = "DAKAR PLATEAU" if strpos(bureau, "PLATEAU") > 0  &  center == ""
replace center = "NGOR ALMADIES" if strpos(bureau, "NGOR") > 0  &  center == ""
replace center = "PIKINE GUEDIAWAYE" if strpos(bureau, "PIKINE") > 0  &  center == ""
replace center = "CPR" if bureau == "CPR" &  center == ""

gen groupbureau = 4 
replace groupbureau = 1 if bureau == "DGE"
replace groupbureau = 2 if bureau == "CME1" | bureau == "CME2"
replace groupbureau = 3 if bureau == "CPR"

label define k 1 "LTU" 2 "Medium" 3 "Liberal" 4 "SME"
label values groupbureau k

*Winsorize continuous variables by center
quietly foreach v of varlist droitssimples_notification* droitssimples_confirmation* penalites_notification*  penalites_confirmation* turnover* payroll* payroll_turnover* nemployees* VAT_credit* VAT_liability* IS_liability* totalcosts* material_inp*  {
	foreach c in "DGE" "CME1" "CME2" "CPR" "DP" "NGA" "PKG" {
		replace `v' = . if `v' < 0 
		qui sum `v' if bureau == "`c'" &  `v' > 0, d
		replace `v' = r(p99)  if `v' >= r(p99) & `v' != . & bureau== "`c'"
		label var `v' "Variable winsorized at top 99th percentile"
	}
}

foreach v of varlist nemployees* {
	replace `v' = . if `v' > 10000
}

*Winsorize profits
quietly foreach v of varlist profit* {
	foreach c in "DGE" "CME1" "CME2" "CPR" "DP" "NGA" "PKG" {
		qui sum `v' if bureau == "`c'", d
		replace `v' = r(p99)  if `v' >= r(p99) & `v' != . & bureau== "`c'"
		replace `v' = r(p1)  if `v' <= r(p1) & `v' != . & bureau== "`c'"
		
		label var `v' "Variable winsorized at top 99th percentile"
	}
}

*****************************************
*Add data on inspectors
*****************************************
clonevar verificateur0 = chefdebureau
replace verificateur1 = verificateur_selection if verificateur_selection != ""  & verificateur1 == ""

quietly do "$code/AUX Clean verificateur names.do"

replace chefdebureau = verificateur0

gen changedverificateur = 1 if controle == 1

forvalues x = 0/8 {
    
	replace changedverificateur = 0 if changedverificateur == 1 & verificateur`x' == verificateur_selection
	
}

preserve 

		drop verificateur_selection

		keep firmid selectionyear selection verificateur*  controle groupbureau
		bys firmid selectionyear controle selection groupbureau: gen n = _n 
		keep if n == 1 
		drop n
		
		reshape long verificateur, i(firmid selectionyear controle selection groupbureau) j(number)
		drop if verificateur == ""
		
		bys firmid selectionyear controle verificateur: gen n = _n
		drop if n > 1 
		drop n  
		
		encode verificateur, gen(codeinspector)

		*sa "$analysisdata/wastedata/inspectors_cases", replace 
		
		drop selection groupbureau codeinspector
		
		merge m:1 verificateur using "$analysisdata/inspectorsurvey"
		drop _merge 

		clonevar yearsexperience = mod1_q3 
		clonevar education = mod2_q1 
		clonevar enthusiasmalgorithm =  mod7_q4_e

		bys firmid selectionyear controle: gen numberagents = _N
		
		gen years_cat = 1 if yearsexperience > 0 & yearsexperience <= 5 
		replace years_cat = 2 if yearsexperience > 5 & yearsexperience <= 10 
		replace years_cat = 3 if yearsexperience > 10 

		gen education_cat = 1 if education == 1 
		replace education_cat = 2 if  education == 6 | education == 2 | education == 3 
		replace education_cat = 3 if education == 4 
		replace education_cat = 4 if education == 5

		gen mastersphd = education_cat == 3 | education_cat == 5 
		replace mastersphd = . if mod7_q4_e == . 

		gen age_cat = .
		replace age_cat = 1 if age <= 30
		replace age_cat = 2 if age > 30 & age <= 40 
		replace age_cat = 3 if age > 40 & age != .

		gen enthusiasm = enthusiasmalgorithm == 3 if enthusiasmalgorithm != .
		gen monthsexperience = 12*mod1_q3 + mod1_q3_b

		collapse (mean) mastersphd age yearsexperience monthsexperience enthusiasm numberagents (median) medianage = age medianyearsexperience = yearsexperience (max) maxyearsexperience = yearsexperience maxage = age maxedu = education_cat, by(firmid selectionyear controle)
		
		ds firmid selectionyear controle, not
		foreach v in `r(varlist)' {
			
			label var `v' "Inspector survey information"
			
		}
		
		tempfile inspectors 
		sa `inspectors', replace 
		
restore 

merge m:1 firmid selectionyear controle using `inspectors'
drop if _merge == 2 
drop _merge 	

*If number of agents is greater than 1 for CP, check if we are counting the "chef de bureau". if year, reduce by 1 the number.
replace numberagents = numberagents - 1 if numberagents  > 1 & typedecontrole_selection == "CP" & chefdebureau != ""

replace confirmation = 0 if confirmation == . 
replace notification = 0 if notification == . 
replace saisie = 0 if saisie == . 
replace suivi = 0 if suivi == . // 
replace selection = 0 if selection == . 

******************************************************
*Generate outcomes
******************************************************

*Create lags in different columns for the variables to be used in prediction (notice that the dataset is identified by audits, so they may happen in different years)
foreach v in y2VG selectionVG y2CP selectionCP decturnover decproductivity decprofitrate turnover productivity profitrate TVA_filed TAF_filed  RAS_IRPP_filed MAN_filed IS_filed IMP_filed EXP_filed CGU_filed TVAAN_filed VAT_liability IS_liability {
	
	*Generate lags
	forvalues l = 0/3 {
		
	gen L`l'`v' = 0
		
		*Check each year corresponds to the lag of the case
		forvalues y = 2018/2020 {
			
			local yearlag = `y' - `l'
			cap noisily replace L`l'`v' =  `v'`yearlag' if selectionyear == `y'
			
		}
	
	}
}

*Drop selection in centers that are not under analysis
drop if bureau == ""

*Dates 
ds *date* 
foreach d in `r(varlist)' {
    
	gen yeartemp = year(`d')
	replace `d' = . if yeartemp < 2017 | yeartemp  > 2021
	drop yeartemp
	
}

replace datededemarrage = s_date_de_demarrage if datededemarrage == . 

gen earliestdate = datededemarrage 
foreach v in  datedemanderenseignement datedavisdatededemandede  s_date_demande_information dateavis s_date_avis {
	replace earliestdate  = `v' if earliestdate == . 
}
format earliestdate %td
label var earliestdate  "datededemarrage datedemanderenseignement datedavisdatededemandede  s_date_demande_information dateavis s_date_avis"

egen earliestdate2 = rowmin(datededemarrage dateavis s_date_avis datedemanderenseignement datedavisdatededemandede  s_date_demande_information)
format earliestdate2 %td
label var earliestdate2  "rowmin(datededemarrage dateavis s_date_avis datedemanderenseignement datedavisdatededemandede  s_date_demande_information)"

gen earliestdate3 = dateavis 
foreach v in s_date_avis datedemanderenseignement datedavisdatededemandede s_date_demande_information  {
	replace earliestdate3  = `v' if earliestdate3 == . 
}
label var earliestdate3  "dateavis s_date_avis datedemanderenseignement datedavisdatededemandede s_date_demande_information"

replace datenotification = s_date_notification if datenotification  == . 
replace dateconfirmation = s_date_confirmation if dateconfirmation  == . 

*Duration variables
gen duration_investigation = datenotification - earliestdate 
replace duration_investigation = dateconfirmation - earliestdate if duration_investigation == .
replace duration_investigation = . if duration_investigation < 0
replace duration_investigation = . if duration_investigation > 600
label var duration_investigation "days spent on case"

replace confirmation = 0 if confirmation == . 
replace notification = 0 if notification == . 

*Value of notification and confirmation 
egen notificationvalue = rowtotal(droitssimples_notification penalites_notification )
egen confirmationvalue = rowtotal(droitssimples_confirmation penalites_confirmation )

	*Complement notification value with confirmation if notificatio is missing (but flag these cases)
	gen flagnotification = notificationvalue == 0 & confirmationvalue > 0 
	replace notificationvalue  = confirmationvalue if notificationvalue == 0 & confirmationvalue > 0 

	egen notificationvaluesuivi = rowtotal(droitssimples_notification penalites_notification s_droitssimples_notification s_penalites_notification )
	egen confirmationvaluesuivi = rowtotal(s_droitssimples_confirmation s_penalites_confirmation )
	replace notificationvaluesuivi  = confirmationvaluesuivi if notificationvaluesuivi == 0 & confirmationvaluesuivi > 0 

gen evasionvalue = notificationvalue 
replace evasionvalue = confirmationvalue if evasionvalue == 0 | evasionvalue == . 

*outcomes
gen y1 = selection 
label var y1 "probability selected into audit"

gen y2 = saisie == 1
foreach v of varlist *date* {
	
	cap replace y2 = 1 if `v' != . 
	cap replace y2 = 1 if `v' != "" 
	
}
label var y2 "probability of audit being started"

gen y2suivi = 0
foreach v of varlist *date* {
	
	cap replace y2suivi = 1 if `v' != . 
	cap replace y2suivi = 1 if `v' != "" 
	
}

foreach v of varlist *notification* *confirmation*  {
	
	cap replace y2suivi = 1 if `v' != .  & `v'  != 0 
	cap replace y2suivi = 1 if `v' != "" 
	
}
label var y2suivi "probability of audit being started (using suivi data)"

gen y3 = 0 if y2 == 1 
replace y3 = 1 if evasionvalue > 0 &  y2 == 1 
label var y3 "audit ending in positive adjustment"

gen y3suivi = 0 if y2suivi == 1 
replace y3suivi = 1 if notificationvaluesuivi > 0 &  y2suivi == 1 
label var y3suivi "probability of audit ending in positive adjustment"

gen y4 = log(evasionvalue)
replace y4 = . if y2 != 1 
replace y4 = 0 if y4 == . & y2 == 1 
label var y4 "log (evaded tax)"

gen y5 = log(confirmationvalue)
replace y5 = . if y2 != 1 
replace y5 = 0 if y5 == . & y2 == 1 
label var y5 "log (final evaded tax)"

egen totalliability = rowtotal(L1VAT_liability L1IS_liability), missing 
	gen y6 = (evasionvalue)/(totalliability + evasionvalue)
	replace y6 = 0 if notification == 0
	replace y6 = . if y2 != 1 
	drop totalliability
label var y6 "evasion as \% liability"

gen meanturnover = L1turnover
	gen y7 = (evasionvalue)/(meanturnover + evasionvalue)
	replace y7 = 0 if notification == 0
	replace y7 = . if y2 != 1
	drop meanturnover
label var y7 "evasion as \% of mean turnover"

*Duration
gen y8 = moyenne_jour
label var y8 "days spent on case"

gen y19 = duration_investigation
label var y19 "Duration between notification date and start date"

egen y9_temp = rowtotal(droitssimples_confirmationTVA penalites_confirmationTVA), missing 
gen y9 = log(y9_temp + 1)
replace y9 = . if y2 != 1 
label var y9 "log (notification VAT)"
drop y9_temp

egen y10_temp = rowtotal(droitssimples_notificationIS penalites_notificationIS), missing
gen y10 = log(y10_temp + 1)
replace y10 = . if y2 != 1 
label var y10 "log (notification CIT)"
drop y10_temp

gen y11 = y7 > 0.1 if y7 != . 
label var y11 "evasion rate greater than 10\%"

gen y12 = y7 > 0.5 if y7 != . 
label var y12 "evasion rate greater than 50\%"

gen y13 = . 
forvalues y = 2018/2019 {
    
	local y2 = `y' + 1
	replace y13 = log(turnover`y2' + 1) if anneeduchrono == `y' 
	
}

label var y13 "log(turnover following year)"

gen y13flag = y13 != . & y13 != 0 if anneeduchrono < 2020 

gen y14 = penalites_notification/droitssimples_notification
replace y14 = penalites_confirmation/droitssimples_confirmation
replace y14 = 1 if y14 != . & y14  > 1 
label var y14 "penalties/evasion"

*Generate number of agents as outcome
gen y16 = numberagents
label var y16 "number of agents"
replace y16 = . if y2 == 0 | y2 == . 

*Test whether confirmation is notification
gen y17 = confirmationvalue/notificationvalue < 1.05 & confirmationvalue/notificationvalue > 0.95
label var y17 "confirmation is equal notification"
replace y17 = . if y2 == 0 | y2 == . 
replace y17 = . if flagnotification == 1 //Exclude cases in wihch we input the value of the notification as == confirmation 

gen y15 = confirmationvalue/notificationvalue if confirmation == 1 & notification == 1 & y17 == 0 
label var y15 "confirmationvalue/notificationvalue"
replace y15 = . if flagnotification == 1 //Exclude cases in which we input the value of the notification as == confirmation 

*Test whether confirmation is smaller than notification
gen y18 = confirmationvalue < notificationvalue if  y15 != .
label var y18 "confirmation is lower than notification"
replace y18 = . if y2 == 0 | y2 == . 

***************
*controls
***************
label var overlap "Overlap (selected by algorithm and IRS)"

label var safeties "Replacement cases"

egen meanturnover = rowmean(turnover*)
replace meanturnover  = 0 if meanturnover  < 10
replace meanturnover = meanturnover

gen x = log(meanturnover + 1)
lab var x "log Mean turnover 2014-2018"
lab var meanturnover "Mean turnover 2014-2018"

foreach riskscore of varlist riskscore* {
	lab var `riskscore' "Risk score"
}

gen x2 = controle == 2 
replace x2 = . if controle == 0
label var x2 "Full audit"

egen totalliability = rowtotal(VAT_liability* IS_liability*) 
replace totalliability = totalliability
gen x3 = log(totalliability + 1)
lab var x3 "log Total VAT-CIT liability 14-18"
lab var totalliability "Total VAT-CIT liability 14-18"

gen lturnover2018 = log(turnover2018 + 1)
lab var lturnover2018 "log Turnover 2018"

drop profit2020 
egen meanprofit = rowmean(profit*)

egen ISdeclarations = rowmax(IS_filed*)

replace meanprofit = . if meanprofit == 0 & ISdeclarations == 0 
lab var meanprofit "Mean profits 2014-2018"

gen profitrate = meanprofit/meanturnover
replace profitrate = -1 if profitrate < -1 
replace profitrate = 1 if profitrate > 1 & profitrate != .

lab var profitrate "Mean profits rate 2014-2018 (censored at -100%)"

egen meanpayroll = rowmean(payroll*)
lab var meanpayroll "Mean payroll 2014-2018"

*treatment variable
gen T = algorithm == 1 
lab var T "Algorithm selection"

*information treatment
gen T_info = information == "1" | information == "2"
replace T_info = . if y1 == 0
label var T_info "Information treatment"

gen T_info_alg = T_info*algorithm
replace T_info_alg = . if y1 == 0
label var T_info_alg "Info. treatment $ \times$ Algorithm selection"

gen T_info_indicateurs = information == "1" 
label var T_info_indicateurs "Info. treatment (only risk indicators)"

gen T_info_indicateurs_alg = T_info_indicateurs*algorithm
label var T_info_indicateurs_alg "Info. treatment (only risk indicators) $ \times$ Algorithm"

gen T_info_donnees = information == "2" 
label var T_info_donnees "Info. treatment (risk indicators plus data)"

gen T_info_donnees_alg = T_info_donnees*algorithm
label var T_info_donnees_alg "Info. treatment (risk indicators plus data)$ \times$ Algorithm"

*riskscore 
gen riskscore = . 

label var riskscore "Normalized riskscore"

foreach y in 2018 2019 2020 {

	destring riskscore`y', replace force
	cap noisily replace riskscore`y' = riskscoretemp`y' 
	bys bureau: egen sdriskscore`y' = sd(riskscore`y')
	bys bureau: egen meanriskscore`y' = mean(riskscore`y')
	
	replace riskscore`y' = 0 if selection == 1 & riskscore`y' == . 
	
	replace riskscore = (riskscore`y' - meanriskscore`y')/sdriskscore`y' if selectionyear == `y'
	
}	

drop  sdrisk* meanrisk*

*********************************
*Clean
*********************************
*Subsample of firms with third party data 
foreach dataset in IS TVA EXP MAN IMP CGU RAS_IRPP { 
	egen max`dataset' = rowmax(`dataset'_filed*) 
	replace max`dataset'  = 0 if max`dataset'  == . 
}

gen declaresISTVA = maxIS + maxTVA > 1 
gen trades = maxEXP + maxIMP > 0

gen withTP = 0  
forvalues y = 2015/2020 {
	replace withTP = 1 if (EXP_filed`y' + MAN_filed`y' + TVAAN_filed`y' + IMP_filed`y') > 1 & anneeduchrono == `y'
}

egen withANNEXES = rowmax(TVAAN_filed*)

*Reorder
order selectionyear anneeduchrono saisie selection taxdata firmid ninea controle type* raisonsociale activity_group activity date*  filename referencenumber bureau controle  typedecontrole* random algorithm dgid overlap  horsprogramme numberagents chefdebureau changedverificateur verificateur* droitssimples_confirmation penalites_confirmation droitssimples_notification penalites_notification    evasion y1 y2 y2suivi y3 y3suivi y4 y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 meanturnover x x2 totalliability x3 lturnover2018 meanprofit profitrate meanpayroll T T_info T_info_alg T_info_indicateurs T_info_indicateurs_alg T_info_donnees T_info_donnees_alg riskscore groupbureau  maxIS maxTVA maxEXP maxMAN maxIMP maxCGU maxRAS_IRPP declaresISTVA trades withTP  withANNEXES  infractions*

label var controle "Type of audit (in audits data)"
label var taxdata "Observation found in tax data"
label var selection "Observation found in selection data"
label var saisie "Observation found in saisie data"
label var filename "Name of excel spreadsheet of raw data"
label var activity_group "Groups of economic activity based on census data"
label var activity "Groups of economic activity (raw data)"
label var numberagents "Number of agents"

*Drop some variables 
drop  raisonsocialeselection nineanumerique methode_de_selection numeric_bureau annee selectionid pl_dif*  ds_dif*

replace activity_group = . if activity_group == 0 

gen method = ""
replace method = "Algorithm" if algorithm == 1 
replace method = "Inspectors" if dgid == 1 
replace method = "Random" if random == 1

replace typedecontrole_selection = typedecontrole_audit if  typedecontrole_selection == "" & selection == 1 
replace typedecontrole_selection = "CP" if typedecontrole_selection == "CSP"

*If program was programmed as random but done as VG, consider it as chosen by algorithm
replace algorithm = 1 if controle == 2 & random == 1 
replace random = 0 if controle == 2 & random == 1 

*If cluster is missing, replace is by combinations ot activitygroup - bureau 
replace activity_group = -1 if activity_group == . 
egen tempcluster = group(bureau activity_group)
sum cluster, d 
replace cluster = `r(max)' + tempcluster if cluster == .  
drop tempcluster 

***********************************
*Include data on taxpayer survey
***********************************
merge m:1 firmid using "$analysisdata\taxpayersurvey.dta"
drop _merge 

replace bureau = "CPR" if strpos(bureau_survey, "LIBERALES") > 0 & bureau == ""
replace bureau = "DP" if strpos(bureau_survey, "DAKAR PLATEAU") > 0 & bureau == ""
replace bureau = "CME1" if strpos(bureau_survey, "MOYENNE") > 0 & bureau == ""
replace bureau = "PKG" if strpos(bureau_survey, "PIKINE") > 0 & bureau == ""
replace bureau = "NGA" if strpos(bureau_survey, "NGOR ALMADIES") > 0 & bureau == ""
replace bureau = "DGE" if strpos(bureau_survey, "GRANDE ENTRE") > 0 & bureau == ""
replace bureau = "GD" if strpos(bureau_survey, "GRAND DA") > 0 & bureau == ""

replace bureau_detailed = bureau if bureau_detailed == ""

*Create variable for center (more aggregated)
replace center = "CME 1" if bureau == "CME 1"
replace center = "CME 2" if bureau == "CME 2"
replace center = "CGE" if strpos(bureau, "CGE") > 0 
replace center = "CGE" if strpos(bureau, "DGE") > 0 
replace center = "DAKAR PLATEAU" if strpos(bureau, "PLATEAU") > 0 
replace center = "NGOR ALMADIES" if strpos(bureau, "NGOR") > 0 
replace center = "PIKINE GUEDIAWAYE" if strpos(bureau, "PIKINE") > 0 
replace center = "CPR" if bureau == "CPR"
replace center = "GRAND DAKAR" if bureau == "GD"

foreach v in algorithm dgid overlap random {
	replace `v' = 0 if `v' == .
}

*Clean answers
foreach q in q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q27 q28 q28a q29 q29a q30 q31 q32 q33 q34 q35 q36 q37 q38 q39 q40 q41 q42 q43 q44 {

	replace `q' = . if `q' == 99 | `q' == 999 | `q' == 9999 | `q' == 99999 | `q' == 0.999
	count if `q' != . 
}

replace q35 = . if q35  == 0 
replace q35 = 0 if q35 == 1 
replace q35 = 1 if q35 == 2
tab q35 

*Turn IDK answers to missing
foreach q in q40 q41 q42 q43 q44 {
	replace `q' = . if `q' == 1 
}

label  define d 0 "Non" 1 "Oui", replace 
label values q35 d

replace selectionyear = 0 if selectionyear == . 
replace x2 = 0 if x2 == . 
replace selection = 0 if selection == . 

*Register whether they claim to have been audited but the administrative data says otherwise
replace q29a = 0 if q29a == .
replace q28a = 0 if q28a == . 

gen claim = q29a >= 2018 & y2 == 0
gen claim2 = (q29a >= 2018 | q28a >= 2018) & y2 == 0
gen claim3 = (q29a >= 2018 | q28a >= 2018) 

foreach v of varlist claim claim2 claim3 {
	replace `v' = . if realise == 0
}

gen auditstatus = 0 
replace auditstatus = 1 if y2 == 1
replace auditstatus = 2 if claim2 == 1 

egen evaluation = rowmean(q31 q32 q33)

**********************
*Change some variables
**********************
*Create deciles of turnover
xtile dec_x = x if x > 0 , nq(10)
replace dec_x = 0 if x == 0 
replace dec_x = -1 if x == .

replace activity_group = -1 if activity_group == .

replace selectionyear = 2018 if selectionyear < 2018 &  selectionyear > 0 
replace selectionyear = 2020 if selectionyear > 2020

egen notselected = rowtotal(dgid algorithm overlap random safeties horsprogramme)
replace notselected = notselected == 0 

*Correct a few cases that appear to have been carried out but are not registered as horsprogramme
replace horsprogramme = 1 if notselected == 1 & selectionyear > 0 
replace notselected = 0 if horsprogramme == 1 

replace y3suivi = 0 if y3suivi == . 

*Correct the classification of the selection methods 
replace algorithm = 0 if overlap == 1 
replace dgid = 1 if overlap == 1 

*Information treatment
replace T_info_donnees = T_info_indicateurs if selectionyear == 2020
replace T_info_indicateurs = 1 if T_info_donnees  == 1 

*Correct Variable for selection method
replace selectionmethod = 1 if dgid == 1 
replace selectionmethod = 2 if overlap == 1 
replace selectionmethod = 3 if algorithm == 1 
replace selectionmethod = 4 if random == 1 
replace selectionmethod = 5 if horsprogramme == 1 

label define d  1 "Discretionary" 2 "Overlap" 3 "Algorithm" 4 "Random" 5 "Ad hoc", replace
label values selectionmethod d

destring sequencing, replace force

**********************
*Create identifiers for the decision makers (inspectors or bureaus)
**********************
*Clean some names
replace verificateur_selection = "PAPA MALICK DIALLO" if verificateur_selection == "PAPA MALCIK DIALLO"
replace verificateur_selection = "PAPA ALY DIOP" if strpos(verificateur_selection, "PAPA ALY DIOP") > 0
replace verificateur_selection = "MAMADOU MOUTAROU DIALLO" if strpos(verificateur_selection, "MAMADOU MOUTARAOU DIALLO") > 0

*Horsprogramme/Ad hoc cases
replace verificateur_selection = verificateur1 if horsprogramme == 1
replace typedecontrole_selection = typedecontrole_audit if horsprogramme == 1

*Create clusters of bureau and year
egen controlbureau = group(bureau_detailed)
egen controlbureauannee = group(bureau_detailed selectionyear)
egen bureauclusteryear = group(bureau selectionyear x2)

*Inspector clusters
egen inspectorselection = group(verificateur_selection bureau_detailed)

egen chef = group(chefdebureau)
sum inspectorselection
replace chef = chef + `r(max)'

*The cluster is the inspector's name for CP, but the bureau for VG (because they worked in groups)
gen inspectorcluster = inspectorselection

egen inspectorclusterttemp  = group(bureau_detailed) if typedecontrole_selection == "VG" //For VG there was no assignment at the selection stage, so choose the bureau
sum inspectorcluster, d
replace inspectorcluster = `r(max)' + inspectorclusterttemp if typedecontrole_selection == "VG" 

egen inspectorclusteryear = group(inspectorcluster selectionyear x2)

drop inspectorclusterttemp

**********************
*Drop cases
**********************
cap drop N

replace center = "DGE" if center == "CGE" 

#delim;
keep if bureau == "DGE" |
		bureau == "CME1" |
		bureau == "CME2"|
		bureau == "CPR"|
		bureau == "DP"|
		bureau == "NGA"|
		bureau == "PKG"|
		bureau == "GD"
;
#delim cr 

***********
*Add information from ANSD (Census of Firms in Senegal)
***********

*Correct some nineas to maximize merge with ANSD
quietly do "$code/AUX Manually input nineas with ANSD information.do"

merge m:1 firmid using "$analysisdata/ANSD.dta"
drop if _merge == 2 
drop _merge

*Age of firms 
replace ANSD_DATE_CREATION_ENTREPRISE  = "" if ANSD_DATE_CREATION_ENTREPRISE  == "NULL"

gen year_creation = substr(ANSD_DATE_CREATION_ENTREPRISE, length(ANSD_DATE_CREATION_ENTREPRISE) - 3, 4)
destring year_creation, replace force
replace year_creation = . if year_creation > 2019

gen adressbureau = ""
replace adressbureau = "31 Rue de Thiong, Dakar" if bureau == "DGE" | bureau == "DP" | bureau == "CPR"
replace adressbureau = "Avenue Bourguiba, vers la Biscuiterie de Médine, Dakar" if bureau == "GD"
replace adressbureau = "Magasin Central Dakar Dem Dikk" if bureau == "CME1" | bureau == "CME2"
replace adressbureau = "CICES, dakar" if bureau == "NGA" 
replace adressbureau = "Pharmacie Ndingala cité Fadia" if bureau == "PKG" 

gen adressfirm = ANSD_ADRESSE
replace adressfirm = subinstr(adressfirm, "/", " ", .)
replace adressfirm = subinstr(adressfirm, ".", " ", .)
replace adressfirm = subinstr(adressfirm, ", ", " ", .)
replace adressfirm = subinstr(adressfirm, "  ", " ", .)
replace adressfirm = substr(adressfirm, 1, strpos(adressfirm, " x ")) if strpos(adressfirm, " x ") > 0 

replace adressfirm = adressfirm + ", " + ANSD_LIBELLE_LOCALITE

*************************************************************************************************
***********RUN SCRIPT IN PYTHON THAT RUNS GOOGLEMAPS QUERIES AND CREATES output_adressforgoogle.xlsx*************
*************************************************************************************************
*/
***********
*add distances from DGID office to firm 
***********
preserve 

	import excel using "$analysisdata/output_adressforgoogle.xlsx", firstrow clear
	drop if firmid == ""
	bys firmid: gen n = _n
	keep if n == 1 
	drop n
	tempfile distances
	sa `distances', replace
	
restore 

merge m:1 firmid using `distances'
drop _merge 

*Get numeric distance
gen distance = subinstr(Distance, "km", "", .)
replace distance = subinstr(Distance, "m", "", .) if strpos(Distance, "km") == 0 
destring distance, replace force
replace distance = distance*1000 if strpos(Distance, "km") > 0 

*Get numeric duration of car trip
gen hours = substr(Duration, strpos(Duration, "hours") - 3, 3) if strpos(Duration, "hours") > 0 
gen minutes = substr(Duration, strpos(Duration, "min") - 3, 3) if strpos(Duration, "min") > 0 

destring hours, replace force
destring minutes, replace force
replace hours=  60*hours

egen durationcar = rowtotal(hours minutes)
replace durationcar  = . if Duration == "Error"
drop hours minutes

sum durationcar  if durationcar < 200, d

gen logdurationcar = log(durationcar)

la var durationcar "Duration of a car trip (in minutes) from DGID on Monday 3PM (GoogleMaps)"
label var distance "Distance of a car trip (in meters) from DGID (GoogleMaps)"

***********
*Add unweighted risk scores
***********
clonevar ninea_or = ninea 
destring ninea, replace force 

merge m:1 ninea using  "$rawdata\Programme_2020/data_proc/riskscore", keepusing(temp_riskscore)
rename temp_riskscore uw_riskscore2020
drop _merge 

destring uw_riskscore2019, replace force
merge m:1 ninea using   "$wastedata/selectionCSP2019", keepusing(uw_riskscore2019)
drop _merge 
merge m:1 ninea using   "$wastedata/selectionVG2019", keepusing(uw_riskscore2019) replace update
drop _merge 

gen uw_riskscore = . 
gen uw_riskscore2018 = riskscore2018

foreach y in 2018 2019 2020 {

	destring uw_riskscore`y', replace force
	bys bureau: egen sduw_riskscore`y' = sd(uw_riskscore`y')
	bys bureau: egen meanuw_riskscore`y' = mean(uw_riskscore`y')
	
	replace uw_riskscore`y' = 0 if selection == 1 & uw_riskscore`y' == . 
	
	replace uw_riskscore = (uw_riskscore`y' - meanuw_riskscore`y')/sduw_riskscore`y' if selectionyear == `y'
	
}	

*Normalize the components of the risk score
foreach r in risk_vat risk_cit risk_inconsistency risk_anomalies {

gen `r' = .

	foreach y in 2018 2019 2020 {

		destring `r'`y', replace force
		bys bureau: egen sd`r'`y' = sd(`r'`y')
		bys bureau: egen mean`r'`y' = mean(`r'`y')
		
		replace `r'`y' = 0 if selection == 1 & `r'`y' == . 
		
		replace `r' = (`r'`y' - mean`r'`y')/sd`r'`y' if selectionyear == `y'
		
		drop sd`r'`y'  mean`r'`y'
	}	
}

drop if firmid == ""

***********************
*Final adjustments
************************

*Create id for the lists (inspector x year)
egen clusterid = group(inspectorclusteryear)

*Multiply the number of days worked by the number of people in the team 
replace y8 = y8*y16 

*Multiply the number of weeks by seven 
replace q30 = q30 * 7

*Generate a variable that is the difference between a notification and the previous one for the same inspector  
sort clusterid datenotification
gen durationaudit = datenotification - datenotification[_n-1] if clusterid == clusterid[_n-1]

*Productivity variable
forvalues y = 2014/2019 {
	
	gen productivity`y' = 100*turnover`y'/labor_inp`y'
	
}	

*Recreate clusterid (some clusters were dropped when we restricted to selection)
drop clusterid 
egen clusterid = group(inspectorclusteryear)

replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

destring sequencing, replace force

*Create deciles for turnover
xtile decileturnover = x , nq(10)
replace decileturnover  = 0 if x == . 

*Create variable for sequencing 
bys inspectorclusteryear: egen maxsequencing = max(sequencing)
gen norm_sequencing = sequencing/maxsequencing
gen norm_sequencing2 = norm_sequencing^2

gen quartile_sequencing = . 
replace quartile_sequencing = 1 if norm_sequencing <= .25
replace quartile_sequencing = 2 if norm_sequencing <= .5 & norm_sequencing  > 0.25
replace quartile_sequencing = 3 if norm_sequencing <= .75 & norm_sequencing  > 0.5
replace quartile_sequencing = 4 if norm_sequencing <= 1 & norm_sequencing  > 0.75

*Create variable to identify the most recent observation when firms repeat (especially relevant for the survey)
bys firmid: egen recent = max(selectionyear) 

gen y4cond = y4 if y4 > 0 //Conditional on positive value
gen y5cond = y5 if y5 > 0 //Conditional on positive value 
gen y3cond2 = y3 if y17 != . //Conditional on positive value 
gen y4cond2 = y4cond if y17 != . //Conditional on positive value 

*Create lags in different columns for the variables to be used in prediction (notice that the dataset is identified by audits, so they may happen in different years)
foreach v in y2VG selectionVG y2CP selectionCP decturnover decproductivity decprofitrate turnover productivity profitrate TVA_filed TAF_filed  RAS_IRPP_filed MAN_filed IS_filed IMP_filed EXP_filed CGU_filed TVAAN_filed {
	
	*Generate lags
	forvalues l = 0/3 {
		
	cap gen L`l'`v' = 0
		
		*Check each year corresponds to the lag of the case
		forvalues y = 2018/2020 {
			
			local yearlag = `y' - `l'
			cap noisily replace L`l'`v' =  `v'`yearlag' if selectionyear == `y'
			
		}
	
	}
}

*Define firm age
gen firmage = selectionyear - year_creation
replace firmage = log(firmage + 1)
replace firmage = 0 if firmage == . 

replace durationcar = log(durationcar + 1)
replace durationcar  = 0 if durationcar  == .

replace distance = log(durationcar + 1 )
replace durationcar  = 0 if durationcar  == . 

*Replace lagged turnover with earlier year if missing
replace L1turnover = L2turnover if L1turnover == . 
replace L1turnover = L3turnover if L1turnover == . 
replace L1turnover = L0turnover if L1turnover == . 

replace L1turnover = log(L1turnover + 1)
replace L1turnover = 0 if L1turnover == .

replace L1productivity = log(L1productivity + 1)
replace L1productivity = 0 if L1productivity == .

replace L1profitrate = 0 if L1profitrate == . 

gen L1turnoversq = L1turnover^2		
gen L1profitratesq = L1profitrate^2		
gen L1productivitysq = L1productivity^2		
gen L1turnovercu = L1turnover^3		
gen L1profitratecu = L1profitrate^3
gen L1productivitycu = L1productivity^3	

*********************************
*Define variables for scope of audits analysis
********************************

*Infractions variables
foreach tax in TVA IS RAS AUTRES { 

	replace infractions`tax' = subinstr(infractions`tax', "  ", " ", .)

	gen `tax'inf_minoration  	= 0 
	gen `tax'inf_deduction	= 0 
	gen `tax'inf_lackofdec	= 0 
	gen `tax'inf_payment		= 0 
	gen `tax'inf_others  		= 0 

	replace `tax'inf_minoration = 1 if strpos(infractions`tax', "MINORATION") > 0 |  strpos(infractions`tax', "MINORISATION") > 0  |  strpos(infractions`tax', "ECARTS DE CHIFFRE") > 0 |  strpos(infractions`tax', "ECARTS SUR CHIFFRE") > 0  |  strpos(infractions`tax', "ECART SUR CHIFFRE") > 0 |  strpos(infractions`tax', "ECART DE CHIFFRE") > 0 | strpos(infractions`tax', "DEFAUT DE DECLARATION D'OPERATION") > 0 | strpos(infractions`tax', "CHIFFRE D'AFFAIRES NON DECLARE") > 0 | strpos(infractions`tax', "DEFAUT DE DECLARATION") > 0 | strpos(infractions`tax', "NON DECLAREE") > 0 | strpos(infractions`tax', "PRODUITS NON DECLAR") > 0 | strpos(infractions`tax', "PRODUITS NON TAX") > 0 

	replace `tax'inf_deduction = 1 if strpos(infractions`tax', "ABUSIVE") > 0 | strpos(infractions`tax', "CHARGES NON DEDUCTIBLES") > 0  | strpos(infractions`tax', "NON JUSTIFIE") > 0  | strpos(infractions`tax', "NON DEDUCTIBLE") > 0  | strpos(infractions`tax', "DEFAUT D'APPLICATION DU PRORATA DE DEDUCTION") > 0  

	replace `tax'inf_lackofdec = 1 if strpos(infractions`tax', "DEFAUT DE SOUMISSION A LA TVA") > 0  | strpos(infractions`tax', "ABSENCE DE DECLARATION") > 0 | strpos(infractions`tax', "IR NON DECLARE") > 0 

	replace `tax'inf_payment = 1 if strpos(infractions`tax', "DEFAUT DE REVERSEMENT") > 0  | strpos(infractions`tax', "DEFAUT DE VERSEMENT") > 0  | strpos(infractions`tax', "NON VERSEE") > 0 | strpos(infractions`tax', "NON REVERSEE") > 0   | strpos(infractions`tax', "NON COLLECTEE") > 0 |  strpos(infractions`tax', "DEFAUT DE PAIEMENT") > 0  |  strpos(infractions`tax', "DEFAUT DE COLLECTE ET DE REVERSEMENT") > 0 |  strpos(infractions`tax', "RETENUE NON OPERE") > 0 |  strpos(infractions`tax', "RETENUE INSUFFISANTE") > 0
	  
	replace `tax'inf_others = 1 if infractions`tax' != "" & `tax'inf_payment + `tax'inf_lackofdec + `tax'inf_deduction + `tax'inf_minoration == 0 

	egen `tax'ninfractions = rowtotal(`tax'inf_*)
	
}

egen ninfractions = rowtotal(TVAninfractions ISninfractions RASninfractions AUTRESninfractions)
egen inf_minoration = rowmax(*inf_minoration)
egen inf_deduction = rowmax(*inf_deduction)
egen inf_lackofdec = rowmax(*inf_lackofdec)
egen inf_payment = rowmax(*inf_payment)
egen inf_others = rowmax(*inf_others)

replace ninfractions = . if y2 == 0 

*number of years
forvalues y = 2008/2021 {
    
	egen investigated`y' = rowtotal(ds_`y'* pl_`y'*)
	replace investigated`y' = investigated`y' > 0 if investigated`y' != .
	
}

egen nyears = rowtotal(investigated*)

foreach tax in TVA IS RAS AUTRES {

	forvalues y = 2008/2021 {
    
	egen investigated`y'_`tax' = rowtotal(ds_`y'*`tax' pl_`y'*`tax')
	replace investigated`y'_`tax' = investigated`y'_`tax' > 0 if investigated`y'_`tax' != .
	}

egen nyears`tax' = rowtotal(investigated*_`tax')

}

*Regressions
replace mildinfraction = numberinfractions - mediuminfraction - severeinfraction 

replace mildinfractionmain = numberinfractionsmain - mediuminfractionmain - severeinfractionmain 

foreach v of varlist mildinfraction* mediuminfraction* severeinfraction* {
	replace `v' = 0 if `v' == . 
	replace `v' = . if y2 == 0 
}

*Any infraction amont main audits 
gen anyinfraction_main = numberinfractionsmain > 0 if numberinfractionsmain != .

gen anysevereinfraction_main = mediuminfractionmain + severeinfractionmain > 0 if mediuminfractionmain + severeinfractionmain != .

*Number of severe + medium infractions
egen mediumseveremain = rowtotal(severeinfractionmain mediuminfractionmain)
egen mediumsevere = rowtotal(severeinfraction mediuminfraction)

*Share of infractions that are severe
gen sharemedium = 100*mediuminfraction/numberinfractions
gen sharemediummain = 100*mediuminfractionmain/numberinfractionsmain

gen sharesevere = 100*severeinfraction/numberinfractions
gen shareseveremain = 100*severeinfractionmain/numberinfractionsmain

gen sharemild = 100*mildinfraction/numberinfractions
gen sharemildmain = 100*mildinfractionmain/numberinfractionsmain

egen test = rowtotal(sharemild sharesevere sharemedium)
replace sharemild = 100 - test if test > 0 & test < 100
drop test 

egen test = rowtotal(sharemildmain shareseveremain sharemediummain)
replace sharemildmain = 100 - test if test > 0 & test < 100
drop test 

egen sharemediumseveremain = rowtotal(shareseveremain sharemediummain)
egen sharemediumsevere = rowtotal(sharesevere sharemedium)

drop y14 
gen y14 = penalites_notification / droitssimples_notification
replace y14 = penalites_confirmation / droitssimples_confirmation if y14 == . 
replace y14 = 1 if y14 > 1 & y14 ! = .

**********************
*SAVING
**********************

sa "$analysisdata/datasetforanalysis.dta", replace
