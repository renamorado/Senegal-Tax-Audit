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

****************************************************************
*1 Read Dataset of Tax Declarations
****************************************************************
use "$analysisdata\finaldataset", clear 

drop if raisonsociale == "" & ninea == .

****************************************************************
*2 Generate variables about tax center and economic activity 
****************************************************************
*Generate directon 
replace direction = "DGE" if strpos(REP_centre, "DGE") > 0  
replace direction = "DGE" if strpos(SIGTAS_CENTRE, "DIRECTION DES GRANDES ENTREPRISES") > 0 & direction == "" 
replace direction = "DGE" if strpos(SIGTAS_CENTRE, "CGE") > 0 & direction == "" 

replace direction = "DME" if strpos(REP_centre, "DME") > 0 
replace direction = "DME" if strpos(REP_centre, "CPR") > 0  
replace direction = "DME" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES") > 0 & direction == "" 
replace direction = "DME" if strpos(SIGTAS_CENTRE, "CPR") > 0 & direction == "" 
replace direction = "DME" if strpos(SIGTAS_CENTRE, "CME") > 0 & direction == "" 

replace direction = "DSF" if REP_centre != "" & direction == "" 
replace direction = "DSF" if SIGTAS_CENTRE != "" & direction == "" 

replace direction = "UNKNOWN" if direction == "" 

*Generate center
replace center = "CGE" if strpos(REP_centre, "DGE") > 0  
replace center = "CGE" if strpos(SIGTAS_CENTRE, "DIRECTION DES GRANDES ENTREPRISES") > 0 & direction == "" 
replace center = "CGE" if strpos(SIGTAS_CENTRE, "CGE") > 0 & direction == "" 

replace center = "CME 1" if strpos(REP_centre, "DME 1") > 0 
replace center = "CME 1" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 1") > 0 & center == "" 
replace center = "CME 1" if strpos(SIGTAS_CENTRE, "CME") > 0 & center == "" 

replace center = "CME 2" if strpos(REP_centre, "DME 2") > 0 
replace center = "CME 2" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 2") > 0 & center == "" 

replace center = "CPR" if strpos(REP_centre, "CPR") > 0 
replace center = "CPR" if strpos(SIGTAS_CENTRE, "CPR") > 0 & center == "" 

replace center = "DAKAR PLATEAU" if strpos(REP_centre, "PLATEAU") > 0 
replace center = "DAKAR PLATEAU" if strpos(SIGTAS_CENTRE, "DAKAR-PLATEAU") > 0 & center == "" 

replace center = "DAKAR LIBERTE" if strpos(REP_centre, "LIBERTE") > 0 
replace center = "DAKAR LIBERTE" if strpos(SIGTAS_CENTRE, "DAKAR-LIBERTE") > 0 & center == "" 

replace center = "GRAND DAKAR" if strpos(REP_centre, "GRAND") > 0 
replace center = "GRAND DAKAR" if strpos(SIGTAS_CENTRE, "GRAND-DAKAR") > 0 & center == "" 

replace center = "NGOR ALMADIES" if strpos(REP_centre, "NGOR ALMADIES") > 0 
replace center = "NGOR ALMADIES" if strpos(SIGTAS_CENTRE, "NGOR-ALMADIES") > 0 & center == "" 

replace center = "PIKINE GUEDIAWAYE" if strpos(REP_centre, "PIKINE GUEDIAWAYE") > 0 
replace center = "PIKINE GUEDIAWAYE" if strpos(SIGTAS_CENTRE, "PIKINE") > 0 & center == "" 
replace center = "PIKINE GUEDIAWAYE" if strpos(SIGTAS_CENTRE, "GUEDIAWAYE") > 0 & center == "" 

replace center = "RUFISQUE" if strpos(REP_centre, "RUFISQUE") > 0 
replace center = "RUFISQUE" if strpos(SIGTAS_CENTRE, "RUFISQUE") > 0 & center == "" 

replace center = "AUTRES" if direction == "DSF" & center == "" 

replace center = "UNKNOWN" if center == "" 

*Generate bureau
replace bureau = "CGE BCS 1" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "1") > 0
replace bureau = "CGE BCS 2" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "2") > 0
replace bureau = "CGE BCS 3" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "3") > 0
replace bureau = "CGE BCS 4" if strpos(REP_ugf, "BC") > 0 & strpos(REP_ugf, "4") > 0
replace bureau = "CGE UNKNOWN" if bureau == "" &  center == "CGE" 

replace bureau = "CME 1" if strpos(REP_centre, "DME 1") > 0 
replace bureau = "CME 1" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 1") > 0 & center == "CME" 
replace bureau = "CME 1" if strpos(SIGTAS_CENTRE, "CME") > 0 & bureau == "" 

replace bureau = "CME 2" if strpos(REP_centre, "DME 2") > 0 
replace bureau = "CME 2" if strpos(SIGTAS_CENTRE, "CENTRE DES MOYENNES ENTREPRISES DAKAR 2") > 0 & center == "CME" 

replace bureau = "CPR" if strpos(REP_centre, "CPR") > 0 
replace bureau = "CPR" if strpos(SIGTAS_CENTRE, "CPR") > 0 & center == "CME" 

replace bureau = center + " UGF 1" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "1") > 0
replace bureau = center + " UGF 2" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "2") > 0
replace bureau = center + " UGF 3" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "3") > 0
replace bureau = center + " UGF 4" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "4") > 0
replace bureau = center + " UGF 5" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "5") > 0
replace bureau = center + " UGF 6" if strpos(REP_ugf, "UG") > 0 & strpos(REP_ugf, "6") > 0

foreach dsf in "DAKAR LIBERTE" "GRAND DAKAR" "NGOR ALMADIES" "DAKAR PLATEAU" "NGOR ALMADIES" "RUFISQUE" "PIKINE GUEDIAWAYE" {

replace bureau = "`dsf' UNKNOWN" if bureau == "" &  center == "`dsf'" 

}

foreach n in 1 2 3 4 {
replace bureau = "CGE BCS`n'" if strpos(bureau, "BCS `n'") > 0 
replace bureau = "CGE BCS`n'" if strpos(bureau, "BCS`n'") > 0
}

foreach b in "GRAND DAKAR" "DAKAR PLATEAU" "NGOR ALMADIES" "PIKINE GUEDIAWAYE" { 
    foreach u in 1 2 3 4 5 {
		replace bureau = "`b' UGF `u'" if center == "`b'" & bureau == "UGF `u'"
	}
}

**************************************************************
*3 Raison sociale and activity
**************************************************************	
*raisonsociale
foreach x of varlist *raisonsociale* {
replace raisonsociale = `x' if raisonsociale == "" 
}

*Define variable for economic activity 
replace activity = REP_activity 
replace activity = SIGTAS_ACTIVITE if activity == "" 
replace activity = upper(activity) 

****************************************************
*9 Change nineas based on names 
****************************************************
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
	tostring ninea, force replace
	quietly do "$code\AUX Manually input nineas.do"
	recast str2045 raisonsociale 
	
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
		compress raisonsociale
		tempfile listmatchit
		sa `listmatchit', replace 
	   
	restore 
	
	merge m:1 raisonsociale using `listmatchit'
	drop if _merge == 2 
	drop _merge
	
	replace ninea = ninea_retrieved if ninea_retrieved != ""
	
	clonevar firmid = ninea
	tostring firmid, force replace

	drop if strpos(firmid, "-") > 0 
	drop if strpos(firmid, ".") > 0 
	
****************************************************
*4 Economic activity
****************************************************
*clean accents 
foreach a in "É" "Ê" "È" {
replace activity = subinstr(activity, "`a'", "a", .)
}
replace activity  = upper(activity)
replace activity = ustrupper( ustrregexra( ustrnormalize(activity, "nfd" ) , "\p{Mark}", "" ) )	
replace activity = subinstr(activity, "@", "a", .)
replace raisonsociale = subinstr(raisonsociale, "@", "a", .)

local group1 `""TRANSPORT" "FERROVIAIRE" "ROUTIE" "AEROPOR" "MARITIME" "CARRIERES" "TRANSIT" "LOGISTIQUE" "AERIENNE" "AUTOROUTE" "PEAGE"  "DISTRIBUTION" "TRADING" "TRANSIT" "'
local group2 `""HOTEL" "HÔTEL" "BRASSERIE" "RECREATIVES" "CULTUREL" "FOIRES" "SALONS" "MUSICAL" "PLAGE" "SPORTIVE" "PATRIMOINE" "RACRAATIVE" "RECREATI" "SOUTIEN À LA CULTURE" "CINEMA" "THEATRE"  "RESTAURANT" "ARTIST" "HEBERGE" "HABERGEMENT" "TOURIS" "RESTAURATION""'	
local group3 `""BTP" "BUILDING" "BATIMENT"  "TRAVAUX" "PRAPARATION DES SITES" "CIMENT" "BETON" "TRUCTION" "GENIE CIVIL" "GENIERIE""'	
local group4 `""ALIMENT" "AGRICUL" "PECHE" "VOLAILLES" "CEREAL" "BISCUITS" "BOULANGER" "PAIN" "DENRAE" "SEMENCE" "AVICULTURE" "POISSON" "PACHE ARTISANALE" "PISCICULTURE" "GRAINS" "VIANDE" "SYLVICULTURE" "AGICULTUR" "PÊCHE" "LAIT" "ALAVAGE" "ELEVAGE" "FRUIT" "DENRAES" "TOMATE" "DENREE" "RIZ" "FARINE""'
local group5 `""INDUSTRIE" "INDUTRIE" "INDUSTRIIE" "TEXTIL" "IND" "MANUFAC" "FABICA" "METAUX" "EMBALLAGE" "CHIMI" "EXTRACT" "MINIER" "ACIERIE" "MINNIERE" "FABRICATION" "FABRIQUE" "MINES" "TALLURGI" "TRANSFORMATION" "PLASTIQ" "TANNERI" "'
local group6 `""SANTE" "HOPITAL" "LABORATOIRE" "THERAP" "ORTHO" "ORL" "CHIRURGI" "VATARINAIRE" "GASTRO" "PEDIATRE" "GENERALISTE" "OLOGUE"  "PHARMAC" "HOSPITAL" "CARDIO" "SANITAIRE" "SANTA" "MEDICA" "UROLOGIE" "CLINIQUE" "ANESTHE" "DENTISTE" "OPHTALM" "CANCER" "MEDECIN" "VETERIN" "DENTAL" "DOCTEUR" "'
local group7 `""AVOCAT" "JURIDIQUE" "ECONOMIQUE" "CONSULT" "EXPERT" "HUISSIER" "HUSSIER" "RESSOURCES HUMAINES" "CONSULTANT" "FISCAL" "IMMO" "NOTAIRE" "COMPTAB" "SOUTIEN AUX ENTREPRISES" "CONSEIL" "ARCHITE" "AGENCE" "MAITRE" "'
local group8 `""BANQUE" "FINANC" "MICROCRED" "ASSURANCE" "CREDIT" "FONDS" "ASSURRA" "MONATAIRE" "INVESTISS""'
local group9 `""ENERGIE" "COURANTS FAIBLES" "ENERGY" "CARBUR" "PETROLE" "PETROLIER" "HYDROCARB" "ELECTR" "BUTANE" "GAZ""'
local group10 `""TELECOM" "COMMUNICATION" "RADIO" "MEDIAS" "TALAVISION" "PUBLICITA" "TELE" "INFORMATIQUE" "INFORM" "TECHN" "INNOV" "'
local group11 `""SERVICE" "SEVICES"  "SURVEILL" "MAINTEN" "MANUTENTI""'
local group12 `""COMMERC" "DETAIL""'
local group13 `""ENSEIGN" "EDUCA" "ECOLE" "SCIENTIF" "RECHERCHE""'
local group14 `""AUTOM" "VOITU" "CONCESS" "CAR WASH""'
local group15 `""COMMUNE" "AGENCE" "IMPOTS" "GOUVERNEMENT" "AMBASSADE" "CONSULAT""'

gen activity_group = 0 
label define n 0 "Autres" 1 "Transport" 2 "Tourisme & Restauration" 3 "BTP" 4 "Alimentation" 5 "Industrie et mines" 6 "Santé" 7 "Libéraux" 8 "Finance" 9 "Energie" 10 "Telecommunications, inform. et medias" 11 "Autres services" 12 "Commerce" 13 "Enseignement et recherche" 14 "Automobile" 15 "Secteur public", replace
label values activity_group n 

forvalues i = 1/15 {
	foreach act2 in `group`i'' {
	    display "`act2'"
		replace activity_group = `i' if strpos(activity, "`act2'") > 0  & activity_group == 0
	}
}

forvalues i = 1/15 {
	foreach act2 in `group`i'' {
		replace activity_group = `i' if strpos(raisonsociale, "`act2'") > 0  & activity_group == 0
	}
}

replace activity_group = . if activity_group == 0 & activity == ""

*Groups by risk
label define s 1 "Low risk" 2 "Medium risk" 3 "High risk"

gen risk_group = . 
replace risk_group = 1 if activity_group == 10 | activity_group == 6 |  activity_group == 0
replace risk_group = 2 if activity_group == 1 | activity_group == 3 | activity_group == 4 | activity_group == 5 | activity_group == 7 | activity_group == 8 | activity_group == 9 | activity_group == 13 | activity_group == 14  
replace risk_group = 3 if activity_group == 2 | activity_group == 11 | activity_group == 12  

label values risk_group s 

preserve

	bys firmid: gen n = _n 
	keep if n == 1 
	drop n 
	
	keep firmid activity_group activity raisonsociale center
	sa "$wastedata/act", replace

restore 

****************************************************
*Generate clusters (used to compute the indicators)
****************************************************
replace bureau = "CME 1" if center == "CME 1"
replace bureau = "CME 2" if center == "CME 2"	
replace bureau = "CPR" if center == "CPR"	
replace bureau = "UNKNOWN" if center == "UNKNOWN"	

cap drop cluster

*1 - Commerce de carburants BCS 1 
local cluster1def	`""COMMERCE DE GROS DE CARBURANTS" "COMMERCIALISATION" "STATION SERVICES" "REMPLISSAGE ET DISTR" "DISTRIBUT" "NEGOCE DE PRODUITS PETROLIERS" "VENTE" "TAIL DE CARBURANTS" "DISTRIBUTION DE GAZ" "PRODUCTION ET DISTRIBUTION D" "PETROL" "HYDROCARB" "ACHAT ET VENTE" "COMMERCE""'
local cluster1cond	"BCS 1"

*2 Extraction, recherche et raffinage de pétrole BCS 1 
local cluster2def	`""EXTRACT" "PETROLE BRUT" "RECHERCHE" "MINIER" "BIOGAZ" "RAFFINAGE" "EXPLORATION" "MINES" "CARRIER" "PECHE""'
local cluster2cond	"BCS 1"

*3 Autres industries: BTP, pharma, métallurgie BCS 1
local cluster3def	`""BTP" "GENIE CIVIL" "BATIMENT" "CONSTRUC" "PHARMA" "METAL" "CONCESSIONAIRE" "MICROCRED" "ELECTRICIT" "ENERGIE-LOGISTIQUE" "CIMENT""' 
local cluster3cond	"BCS 1"

*4 Intermédiation financière BCS 2
local cluster4def	`""DIATIONS MON" "BANQUE" "FINANC" "INVESTISSEMENT""'
local cluster4cond	"BCS 2"

*5 Assurance BCS 2 
local cluster5def	`""ASSURANCE""'
local cluster5cond	"BCS 2"

*6 Autres services BCS 2
local cluster6def 	`""AGRICULTURE" "TELECOM" "POST" "TRANSPORT" "SFD" "PRESTATION DE SERVICES" "INTERIM" "IMMOBILI" "INTERNET" "MICROCRED""'
local cluster6cond	"BCS 2"

*7 BTP et Industrie BCS 3 
local cluster7def	`""CONSTRUCTIO" "BTP" "Construction" "TRAVAUX DE G" "INDUSTR" "IMMOBILI" "TALLURGIE" "EXTRACTION" "MINES" "MINIER""'
local cluster7cond	"BCS 3"

*8 Zone franche d'exportations BCS 3 
local cluster8def	
local cluster8cond	"BCS 3"

*9 Peche, agriculture BCS 3
local cluster9def	`""PECHE" "AGRIC" "AVICOLE" "POISSON""'
local cluster9cond	"BCS 3"

*10 Commerce BCS 4
local cluster10def	`""COMMERCE" "Mr" "COMMERCE" "PRODUITS ALIMENTAIRES" "FOOD" "GALERIES" "IMPORT" "EXPORT" "AGENCE" "HOTEL" "ALIMENTAIRE" "BERGEMENT" "RESTAURATION" "VENTE""'
local cluster10cond	"BCS 4"

*11 Services BCS 4 
local cluster11def 	`""CONSULT" "ASSURANCE" "FINANC" "TRANSPORTATION" "BANQUE" "SOUTIEN AUX ENTREPRISES" "COLIS" "CONSEIL" "PRESTATION DE S" "TRANSPORT" "COMMUNICATION""'
local cluster11cond	"BCS 4"

*12 Industrie BCS 4
local cluster12def	`""INDUST" "CONSTRUC" "FABRICATION" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "CONCESSIONNA" "GENIE CIVIL" "HYDROCARB" "HYDRAU" "IMPRIMERIE" "CONFECTION" "REPARATION DE SITES" "BTP" "BATIMENT" "CHIMIE" "SIDÉRURGIE" "INDUSTR" "CONSTRUC" "MINIERE" "PETROL" "FABRICATION" "METAL" "METAUX" "MINERALS"  "OIL COMPANY" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "REPARATION DE SITES" "SIDÉRURGIE""'
local cluster12cond	"BCS 4"

*13 Commerce CME 1
local cluster13def	`""COMMERCE" "Mr" "COMMERCE" "PRODUITS ALIMENTAIRES" "FOOD" "GALERIES" "IMPORT" "EXPORT" "AGENCE" "HOTEL" "ALIMENTAIRE" "BERGEMENT" "RESTAURATION" "VENTE""'
local cluster13cond	"CME 1"

*14 Services CME 1
local cluster14def 	`""CONSULT" "ASSURANCE" "FINANC" "TRANSPORTATION" "BANQUE" "SOUTIEN AUX ENTREPRISES" "COLIS" "CONSEIL" "PRESTATION DE S" "TRANSPORT" "COMMUNICATION""'
local cluster14cond	"CME 1"

*15 Industrie CME 1
local cluster15def	`""INDUST" "CONSTRUC" "FABRICATION" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "CONCESSIONNA" "GENIE CIVIL" "HYDROCARB" "HYDRAU" "IMPRIMERIE" "CONFECTION" "REPARATION DE SITES" "BTP" "BATIMENT" "CHIMIE" "SIDÉRURGIE" "INDUSTR" "CONSTRUC" "MINIERE" "PETROL" "FABRICATION" "METAL" "METAUX" "MINERALS"  "OIL COMPANY" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "REPARATION DE SITES" "SIDÉRURGIE""'
local cluster15cond	"CME 1"

*16 Commerce CME 2
local cluster16def	`""COMMERCE" "Mr " "COMMERCE" "PRODUITS ALIMENTAIRES" "FOOD" "GALERIES" "IMPORT" "EXPORT" "AGENCE" "HOTEL" "ALIMENTAIRE" "BERGEMENT" "RESTAURATION" "VENTE""'
local cluster16cond	"CME 2"

*17 Services CME 2
local cluster17def 	`""CONSULT" "ASSURANCE" "FINANC" "TRANSPORTATION" "BANQUE" "SOUTIEN AUX ENTREPRISES" "COLIS" "CONSEIL" "PRESTATION DE S" "TRANSPORT" "COMMUNICATION""'
local cluster17cond	"CME 2"

*18 Industrie CME 2
local cluster18def	`""INDUST" "CONSTRUC" "FABRICATION" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "CONCESSIONNA" "GENIE CIVIL" "HYDROCARB" "HYDRAU" "IMPRIMERIE" "CONFECTION" "REPARATION DE SITES" "BTP" "BATIMENT" "CHIMIE" "SIDÉRURGIE" "INDUSTR" "CONSTRUC" "MINIERE" "PETROL" "FABRICATION" "METAL" "METAUX" "MINERALS"  "OIL COMPANY" "MANUFACTUR"  "INGÉNIERIE" "Construction" "DÉMOLITION" "REPARATION DE SITES" "SIDÉRURGIE""'
local cluster18cond	"CME 2"

*19 Santé CPR
local cluster19def	`""MÉDICALE" "HOSPITAL" "SANTE" "VETERINAIRE" "RADIO" "ORTHO" "PSYCH" "SANTÉ" "CARDIO" "RHUMAT" "OPHTALMO" "CHIRURGI" "MEDECIN" "KINESI" "MEDICAL" "LABORATOIRE" "NEURO" "VÉTÉRINAIRES"  "PHARMAC" "DENTAIRE""'
local cluster19cond	"CPR" 

*20 Professions libérales CPR
local cluster20def	`""JURIDIQUE" "EXPERT COMMERCIAL" "CONSEIL" "FISCAL" "AUTOMOBILE" "COMPTAB" "ARCHIT" "AVOCAT" "AVOVAT" "NOTAIRE" "IMMOBILI" "INTERMÉDIATIONS MONÉTAIRES" "SERVICES AUX ENTREPRISES"  "ADMINISTRATION GÉNÉRALE" "PRINCIPALEMENT AUX EN" "ACTIVITES FIN" "ADMINISTRATION GENERALE" "FINANCIE" "COMPTABLE""' 
local cluster20cond	"CPR"

*21 Autres CPR	
local cluster21def
local cluster21cond	"CPR"

** Generate clusters 
gen temp_cluster = . 

forvalues d = 1/21 {
foreach act in `cluster`d'def' { 
	*display `"`act'"'
	qui replace temp_cluster = `d' if strpos(activity, "`act'") > 0 			& bureau == "`cluster`d'cond'"
	qui replace temp_cluster = `d' if strpos(raisonsociale, "`act'") > 0 		& bureau == "`cluster`d'cond'"

}
}

*Zone franche d'exportations
replace temp_cluster = 8  if IS_L415 > 0 & IS_L415 != . & IS_filed == 1   & strpos(bureau,"BCS 3")>0
		
*Define rest: 
replace temp_cluster = 3 if temp_cluster == . & bureau == "BCS 1"
replace temp_cluster = 6 if temp_cluster == . & bureau == "BCS 2"
replace temp_cluster = 9 if temp_cluster == . & bureau == "BCS 3"
replace temp_cluster = 10 if temp_cluster == . & bureau == "BCS 4"
replace temp_cluster = 13 if temp_cluster == . & bureau == "CME 1"
replace temp_cluster = 16 if temp_cluster == . & bureau == "CME 2"
replace temp_cluster = 21 if temp_cluster == . & bureau == "CPS"

*For the remaining we will follow the UGF classification
replace temp_cluster = 1 if temp_cluster == . 


*3 	Make cluster uniform across nineas by choosing most recent cluster 
preserve 

	keep ninea raisonsociale annee center bureau temp_cluster 

	gsort ninea -annee 
	by ninea: gen dup = cond(_N==1,0,_n) 
	drop if dup > 1 
	drop dup annee

	tempfile clusterinfo
	sa `clusterinfo', replace 

restore 

drop raisonsociale center bureau temp_cluster

merge m:1 ninea using `clusterinfo'
drop _merge 

egen cluster = group(temp_cluster bureau center)
drop temp_cluster

****************************************************
*4 Generate algorithm indicators
****************************************************
	*	2 Inconsistencies indicators
	replace TVAAN_revenues = TVAAN_revenues/5
	replace TVAAN_expenses = TVAAN_expenses/5
	
	*Generate variable from TVA annexes
	egen TVAAN_turnover = rowmax(TVAAN_montant_achlocaux TVAAN_revenues)
	egen TVAAN_costs = rowmax(TVAAN_montant_achlocauxcli TVAAN_expenses)
	
	*Indicators of inconsistencies 
	gen domsales = cond(TVAAN_turnover > FOU_MontantRecoupement, TVAAN_turnover, FOU_MontantRecoupement) 
	egen num1 = rowtotal(EXP_valeur MAN_valeur domsales)
	drop domsales
	egen den1 = rowmax(TVA_L5 IS_L5) 

	gen num2 = TVA_L5
	gen den2 = IS_L5
	gen num3 = TVA_L80
	gen den3 = IMP_valeur

	*	3 Anomalies indicators
	
	gen numTVA1 = TVA_L5																					if TVA_filed == 1
	gen denTVA1 = cond(TVA_L110, TVA_L110 != 0, -abs(TVA_L115))												if TVA_filed == 1
	gen numTVA2 = TVA_L5																			 		if TVA_filed == 1
	gen denTVA2 = TVA_L60									 												if TVA_filed == 1
	
	gen numIS1 = IS_L5 																						if IS_filed == 1 
	replace IS_L450 = 0.3*IS_L400																if IS_L450 == 0 | IS_L450 == . 
	gen denIS1 = cond(IS_L460 > IS_L450, IS_L460 , IS_L450)  												if IS_filed == 1 
	gen numIS2 = cond(IS_L5 - IS_L400 > 0, IS_L5 - IS_L400, 0)												if IS_filed == 1 
	gen denIS2 = IS_L5 																						if IS_filed == 1 
	
	gen numTAF1 = TAF_L10 																					if TAF_filed == 1 
	gen denTAF1 = TAF_L110																					if TAF_filed == 1 
	
	gen dompurchases = cond(TVAAN_costs + TVAAN_montantpurchased_sus > CLI_MontantRecoupement, TVAAN_costs + TVAAN_montantpurchased_sus, CLI_MontantRecoupement) 
	egen numTP1 = rowtotal(dompurchases IMP_valeur RAS_IRPP_L60)
	drop dompurchases
	egen denTP1 = rowmax(TVA_L5 IS_L5)

	gen numImportations1 = IMP_faibleimposition																 
	egen denImportations1 = rowmax(IS_L5 TVA_L5)															if TVA_filed == 1 | IS_filed == 1 
	
	* Generate ratios
	
	foreach type in "" "TVA" "IS" "TP" "Importations" {

		forvalues number = 1/3 { 

		cap noisily gen ratio`type'`number' = num`type'`number'/den`type'`number'
		cap noisily label var ratio`type'`number' `label`type'`number''
		cap noisily replace ratio`type'`number' = 999999999 					if (den`type'`number' == 0)  
		cap noisily replace ratio`type'`number' = 999999999 					if ratio`type'`number' < 0  	//We top code the negative values too (they mean that the taxpayer is a creditor)
		cap noisily replace ratio`type'`number' = 0 							if num`type'`number' == 0  
		cap noisily replace ratio`type'`number' = . 							if den`type'`number' == . & num`type'`number' == .  //We set to missing if the indicator is not relevant for this firm, otherwise the firm interferes in the calculation of percentiles
		}

	}

	*Generate binary indicator 
	*Défaillance déclarative : declares CIT but not VAT but has declared VAT in the past OR declares VAT but not CIT, but declared CIT in the past
	sort ninea annee
	gen flag_defaillanceCITVAT = 0 
	
	forvalues y = 2015/2020 {
	
		*Generate indicator to see if firm declared tax in a particular year 
		foreach t in TVA IS {
		gen `t'`y' = `t'_filed
		replace `t'`y' = 0 if annee != `y'
		bys ninea: egen `t'`y'max = max(`t'`y')
		drop `t'`y'
		}
	}
	
	forvalues y = 2015/2020 {

		*Flag if declared TVA but not IS, but has declared it in the past, or vice versa. 
		forvalues year = 2015/`y' {
		replace flag_defaillanceCITVAT = 1 if TVA_filed == 1 & IS_filed == 0 & annee == `y' & IS`year'max == 1
		replace flag_defaillanceCITVAT = 1 if TVA_filed == 0 & IS_filed == 1 & annee == `y' & TVA`year'max == 1
		}
	
	}
	
	drop *max
	
	*We don't want the same firm to be flagged twice
	bys ninea: egen flag_defaillance = max(flag_defaillanceCITVAT)
	replace flag_defaillance = 0 if annee != 2020 
	drop flag_defaillanceCITVAT
	
	*Attribute values based on indicators 
	*For inconsistencies, only flag if ratio is above 105%
	foreach type in "" { 

		forvalues number = 1/3 { 	
	
		replace ratio`type'`number' = . if ratio`type'`number' < 1.05 
		
		}
	}
	
	*Normalized Ranks (continuous values from 0 to 10 ranking values)
	qui ds ratio*
	
	foreach var in `r(varlist)' {

		gsort annee cluster `var' 
		bys annee cluster: egen rank = rank(`var') 
		qui replace rank = 0 if `var' == 0 
		bys cluster annee: egen maxrank = max(rank) 
		qui gen points_`var' = rank/maxrank 
							
	drop rank maxrank  
	}
	
	*For anomalies, give 1 point to top decile
	foreach type in "TVA" "IS" "TP" "Importations" "TAF"{ 

		forvalues number = 1/3 {
		cap replace points_ratio`type'`number' = 0 if points_ratio`type'`number' == . 
		cap replace points_ratio`type'`number' = 1 if points_ratio`type'`number' >= 0.9 & points_ratio`type'`number' != . 
		cap replace points_ratio`type'`number' = 0 if points_ratio`type'`number' < 0.9
	
		}
		
	}
	
	replace points_ratioImportations1 = 1 if ratioImportations > 0 & ratioImportations != . 
	
	replace points_ratioTVA1 = 0 if strpos(SIGTAS_REGIME_FISCAL, "NON ASSUJETTI A LA TVA") > 0 
	replace points_ratioTVA2 = 0 if strpos(SIGTAS_REGIME_FISCAL, "NON ASSUJETTI A LA TVA") > 0 	
	replace points_ratioTP1 = 0 if strpos(SIGTAS_REGIME_FISCAL, "NON ASSUJETTI A LA TVA") > 0 
	
drop num* den*

****************************************************
*5 Generate useful variables
****************************************************
cap drop turnover
egen turnover = rowmax(TVA_L5 IS_L5 CGU_L70) 
gen payroll = RAS_IRPP_L60
replace CGU_L80 = . if CGU_L80 > 100 
egen nemployees = rowmax(RAS_IRPP_L30 CGU_L80)
gen payroll_turnover = payroll/turnover 
gen VAT_credit = -abs(TVA_L85) - abs(TVA_L90)
gen VAT_liability = TVA_L60 + VAT_credit
egen IS_liability = rowmax(IS_L460 IS_L450)
gen CGU_liability =  CGU_L180
gen PAYE_liability = RAS_IRPP_L70

*Turnover already exists 
gen year = annee 
gen labor_inp = 	RAS_IRPP_L60
gen gross_tax_base = cond(abs(IS_L10) > 0,  IS_L10, -abs(IS_L200))
replace gross_tax_base  = IS_L323 if gross_tax_base  == .
gen profit = gross_tax_base 
label var profit "Equal to gross_tax_base"

*Material input
	*Compute implicit VAT tax rate for each sector 
	bys activity_group: egen totalsales = total(TVA_L5)
	bys activity_group: egen totalexports = total(TVA_L10)
	bys activity_group: egen totalVAT = total(TVA_L60)
	gen VATrate = totalVAT / (totalsales - totalexports)
	
	gen material_inp = TVA_L80 + (TVA_L90/VATrate)
	
gen totalcosts = turnover - gross_tax_base	
*gen profitrate = gross_tax_base/turnover
gen profitrate = turnover/totalcosts - 1 

*Flag for whether there was data on VAT annexes
gen TVAAN_filed = 0

foreach v in TVAAN_montant_achlocauxcli TVAAN_TVA_achlocauxcli TVAAN_achlocaux_uniquesupplier TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniqueclient TVAAN_precompte_uniqueclient TVAAN_TVApaid_presup TVAAN_montantpurchased_presup TVAAN_precompte_uniquesupplier TVAAN_TVApaid_precompte TVAAN_montantpurchased_precompte TVAAN_montantpurchased_sussup TVAAN_TVAsuspended_sussup TVAAN_sus_uniquecli TVAAN_montantpurchased_sus TVAAN_TVAsuspended_sus TVAAN_sus_uniquesup TVAAN_import_uniquesupplier TVAAN_import_uniquecountry TVAAN_TVAdeductible_importation TVAAN_TVA_importation TVAAN_montant_importation TVAAN_export_uniqueclient TVAAN_export_uniquecountry TVAAN_montant_exportation TVAAN_exon_uniqueclient TVAAN_montant_exoneration {
    
	replace TVAAN_filed = 1 if `v' > 0 & `v' != . 
	
}
	
sa "$wastedata\taxdeclarations_allfirms.dta", replace 
	
****************************************************
*8 restrict dataset, reshape and save
****************************************************
keep firmid annee bureau TVAAN_filed TVA_filed IS_filed RAS_IRPP_filed CGU_filed TAF_filed IMP_filed EXP_filed MAN_filed  activity_group risk_group turnover payroll  nemployees payroll_turnover VAT_credit VAT_liability IS_liability CGU_liability PAYE_liability year labor_inp gross_tax_base profit totalsales totalexports totalVAT VATrate material_inp totalcosts profitrate flag* *ratio* cluster

keep if annee > 2013 & annee < 2021 
bys firmid annee: gen n = _n
keep if n == 1
drop n

reshape wide TVAAN_filed TVA_filed IS_filed RAS_IRPP_filed CGU_filed TAF_filed IMP_filed EXP_filed MAN_filed   activity_group risk_group turnover payroll nemployees payroll_turnover VAT_credit VAT_liability IS_liability CGU_liability PAYE_liability year labor_inp gross_tax_base profit totalsales totalexports totalVAT VATrate material_inp totalcosts profitrate flag* *ratio*, i(firmid cluster bureau) j(annee)

	local label1 = "Inconsistence 1: Domestic Sales (Purchases Third Party) + Tresor + Exports vs CA"			
	local label2 = "Inconsistence 2: CA IS vs CA TVA"
	local label3 = "Inconsistence 3: TVA importations - TVA declarations vs Douanes"
	local labelTVA1 = "Anomalie TVA 1: CA/ net liability"	
	local labelTVA2 = "Anomalie TVA 2: CA / TVA brut"
	local labelIS1 = "Anomalie IS 1: CA/net tax liability"
	local labelIS2 "Anomalie IS 2: (turnover - taxable profits)/turnover" 
	local labelTAF "Anomalie TAF 1: CA/net tax liability"
	local labelTP1 = "Anomalie Third Party 1: Domestic purchases + Suspended TVA purchases + Masse salariale + Importations vs CA"
	local labelImportations1 "Anomalie Douanes: Importations from Low tax countries/chiffre d'affaires" 
	
	
*Label the ratios 

	foreach type in "1" "2" "3" "TVA1" "TVA2" "IS1" "IS2" "TP1" "Importations1" {
			
			foreach v of varlist ratio`type'* {
				display "`v'"
					cap noisily label var `v' "`label`type''"
					
				}
		
		}

merge 1:1 firmid using "$wastedata/act"
drop _merge 

ds *filed*
foreach v in `r(varlist)'  {
    
	replace `v' = 0 if `v' == . 
	
}

	bys firmid: gen n = _n
	bys firmid: gen N = _N
	
	keep if n== 1
	drop n N
	
	
drop points*

rename bureau bureau_taxdata
	
******************	
*SAVING
******************
	
sa "$wastedata\taxdeclarationswide_allfirms.dta" , replace 
