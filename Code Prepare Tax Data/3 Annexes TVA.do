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

set excelxlsxlargefile on

**************************************************************
**************************************************************
*TVA ANNEXES 2020
**************************************************************
**************************************************************
set excelxlsxlargefile on
foreach dset in "annexe_dec_EXONERATION" "annexe_dec_EXPORTATION" "annexe_dec_IMPORTATION" "annexe_dec_PRECOMPTE" "annexe_dec_SUSPENSION" "Copie de annexe_achlocaux - part1" "Copie de annexe_achlocaux - part2"  {

	import excel "Programme_2019\raw_data\ANNEXES TVA\Annexes TVA Extraction SIGTAS\\`dset'.xlsx",  firstrow clear 
	sa "Programme_2020\data_waste\\`dset'", replace 

} 


****************************************************************
***Exonération
****************************************************************
use "Programme_2020\data_waste\annexe_dec_EXONERATION", clear

	*generate numeric ninea for third party
	gen ninea = NINEA
	
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = 2019
	
	*gen montantfacture 
	gen TVAAN_montant_exoneration = MONTANT_DE_LA_FACTURE

	*Number of clients
	replace IDENTITE_EXACTE_DU_CLIENT = trim(IDENTITE_EXACTE_DU_CLIENT)
	replace IDENTITE_EXACTE_DU_CLIENT = upper(IDENTITE_EXACTE_DU_CLIENT)
	replace IDENTITE_EXACTE_DU_CLIENT = subinstr(IDENTITE_EXACTE_DU_CLIENT," ","",.)
		
	egen TVAAN_exon_uniqueclient = tag(ninea IDENTITE_EXACTE_DU_CLIENT)

	*Collapse 
	collapse (sum) TVAAN_exon_uniqueclient TVAAN_montant_exoneration, by(ninea annee)

	label var TVAAN_exon_uniqueclient "TVA Annexes: number of clients to which NINEA made exempt sales"
	label var TVAAN_montant_exoneration "TVA Annexes: amount of exempt sales by NINEA"

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_exoneration
	sa `TVAAN_exoneration' , replace
	
****************************************************************		
***Exportation
****************************************************************
use "Programme_2020\data_waste\annexe_dec_EXPORTATION", clear

	*generate numeric ninea for third party
	gen ninea = NINEA
	
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force

	*gen year
	gen annee = .
	forvalues y = 6/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	forvalues y = 16/19 {
	replace annee = 2000 + `y' if strpos(DATE_DE_LA_FACTURE, "`y'") > 0 & annee == . 
	}
	
	*gen montantfacture 
	gen TVAAN_montant_exportation = MONTANT_DE_LA_FACTURE
	destring TVAAN_montant_exportation , force replace 
	
	*Number of clients
	replace DENOMINATION_DU_CLIENT = trim(DENOMINATION_DU_CLIENT)
	replace DENOMINATION_DU_CLIENT = upper(DENOMINATION_DU_CLIENT)
	replace DENOMINATION_DU_CLIENT = subinstr(DENOMINATION_DU_CLIENT," ","",.)
		
	egen TVAAN_export_uniqueclient = tag(ninea DENOMINATION_DU_CLIENT)

	*Number of countries
	replace PAYS_DU_CLIENT = trim(PAYS_DU_CLIENT)
	replace PAYS_DU_CLIENT = upper(PAYS_DU_CLIENT)
	replace PAYS_DU_CLIENT = subinstr(PAYS_DU_CLIENT," ","",.)
		
	egen TVAAN_export_uniquecountry = tag(ninea PAYS_DU_CLIENT)
	
	*Collapse 
	collapse (sum) TVAAN_export_uniqueclient TVAAN_export_uniquecountry TVAAN_montant_exportation, by(ninea annee)

	label var TVAAN_export_uniqueclient "TVA Annexes: number of clients to which NINEA made export"
	label var TVAAN_montant_exportation "TVA Annexes: amount of exports by NINEA" 
	label var TVAAN_export_uniquecountry "TVA Annexes: number of countries to which NINEA made export"

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_export
	sa `TVAAN_export' , replace

****************************************************************	
***Importation
****************************************************************
use "Programme_2020\data_waste\annexe_dec_IMPORTATION", clear

	*generate numeric ninea for third party
	gen ninea = FISCAL_NO
	
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = .
	forvalues y = 6/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	forvalues y = 16/19 {
	replace annee = 2000 + `y' if strpos(DATE_DE_DECLARATION_EN_DOUANES, "`y'") > 0 & annee == . 
	}
	
	drop if annee == . 
	
	*gen montantfacture 
	gen TVAAN_montant_importation = PRIX_DACHAT_DOUANES_INCLUS_F
	gen TVAAN_TVA_importation = TVA_ACQUITTEE_EN_DOUANES_F
	gen TVAAN_TVAdeductible_importation = TVA_DEDUCTIBLE_F

	*Number of clients
	replace DENOMINATION_DU_FOURNISSEUR = trim(DENOMINATION_DU_FOURNISSEUR)
	replace DENOMINATION_DU_FOURNISSEUR = upper(DENOMINATION_DU_FOURNISSEUR)
	replace DENOMINATION_DU_FOURNISSEUR = subinstr(DENOMINATION_DU_FOURNISSEUR," ","",.)
		
	egen TVAAN_import_uniquesupplier = tag(ninea DENOMINATION_DU_FOURNISSEUR)

	*Number of countries
	replace PAYS_DORIGINE = trim(PAYS_DORIGINE)
	replace PAYS_DORIGINE = upper(PAYS_DORIGINE)
	replace PAYS_DORIGINE = subinstr(PAYS_DORIGINE," ","",.)
		
	egen TVAAN_import_uniquecountry = tag(ninea PAYS_DORIGINE)
	
	*Collapse 
	collapse (sum) TVAAN_import_uniquesupplier TVAAN_import_uniquecountry TVAAN_TVAdeductible_importation TVAAN_TVA_importation TVAAN_montant_importation, by(ninea annee)

	label var TVAAN_import_uniquesupplier "TVA Annexes: number of suppliers from which NINEA made import"
	label var TVAAN_TVAdeductible_importation "TVA Annexes: Deductible TVA from imports by NINEA"
	label var TVAAN_TVA_importation "TVA Annexes: TVA from imports by NINEA" 
	label var TVAAN_montant_importation "TVA Annexes: imports by NINEA" 
	label var TVAAN_import_uniquecountry "TVA Annexes: number of countries from which NINEA made import"

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_import
	sa `TVAAN_import' , replace	
	
****************************************************************	
***Pre compte
****************************************************************
use "Programme_2020\data_waste\annexe_dec_PRECOMPTE", clear

	*generate numeric ninea for third party
	gen ninea = NINEA_DU_CLIENT
	
	replace ninea = subinstr(ninea,"R18 18","",.)
	replace ninea = subinstr(ninea,"MD18-","",.)
	replace ninea = subinstr(ninea,"18-","",.)
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = .
	forvalues y = 6/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	drop if annee == . 
	
	*gen montantfacture 
	gen TVAAN_montantpurchased_precompte = MONTANT_FACTURE_HTVA 
	destring TVAAN_montantpurchased_precompte , replace force
	gen TVAAN_TVApaid_precompte = MONTANT_TVA_PRECOMPTEE
	destring TVAAN_TVApaid_precompte , replace force
	
	*Number of clients
	replace NINEA = trim(NINEA)
	replace NINEA = upper(NINEA)
	replace NINEA = subinstr(NINEA," ","",.)
	
	replace NINEA = subinstr(NINEA,"R18 18","",.)
	replace NINEA = subinstr(NINEA,"MD18-","",.)
	replace NINEA = subinstr(NINEA,"18-","",.)
	replace NINEA = subinstr(NINEA," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(NINEA,-`h',1)
		destring test, force replace 
		replace NINEA = substr(NINEA,1,length(NINEA)-1-`h') if test == . 
		drop test
	}
	
	destring NINEA, replace force
	
	egen TVAAN_precompte_uniquesupplier = tag(NINEA ninea)
	egen TVAAN_precompte_uniqueclient = tag(NINEA ninea)

	preserve
	
	*Collapse from client's perspective
	collapse (sum) TVAAN_precompte_uniquesupplier TVAAN_TVApaid_precompte TVAAN_montantpurchased_precompte, by(ninea annee)

	label var TVAAN_precompte_uniquesupplier "TVA Annexes: number of suppliers of NINEA with precompte TVA"
	label var TVAAN_TVApaid_precompte "TVA Annexes: TVA paid in precompte by NINEA by suppliers"
	label var TVAAN_montantpurchased_precompte "TVA Annexes: Amount purchased by NINEA (precompte declaration)" 

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_precompteclient
	sa `TVAAN_precompteclient' , replace		
	restore 
	
	preserve
	
	*Collapse from suppliers' perspective
	collapse (sum) TVAAN_precompte_uniqueclient TVAAN_TVApaid_precompte TVAAN_montantpurchased_precompte, by(NINEA annee)

	label var TVAAN_precompte_uniqueclient "TVA Annexes: number of clients of NINEA with precompte TVA"
	label var TVAAN_TVApaid_precompte "TVA Annexes: TVA paid in precompte by NINEA on behalf of client"
	label var TVAAN_montantpurchased_precompte "TVA Annexes: Amount sold by NINEA (precompte declaration)" 
	
	rename NINEA ninea 
	rename TVAAN_TVApaid_precompte TVAAN_TVApaid_presup
	rename TVAAN_montantpurchased_precompte TVAAN_montantpurchased_presup
	
	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_precomptesupplier
	sa `TVAAN_precomptesupplier' , replace		
	restore 
	
****************************************************************	
***Suspension
****************************************************************

use "Programme_2020\data_waste\annexe_dec_SUSPENSION", clear

	*generate numeric ninea for third party
	gen ninea = NINEA_DU_CLIENT
	
	replace ninea = subinstr(ninea,"R18 18","",.)
	replace ninea = subinstr(ninea,"MD18-","",.)
	replace ninea = subinstr(ninea,"18-","",.)
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = .
	forvalues y = 6/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	drop if annee == . 
	
	*gen montantfacture 
	gen TVAAN_montantpurchased_sus = MONTANT_DE_LA_FACTURE_HT 
	destring TVAAN_montantpurchased_sus , replace force
	gen TVAAN_TVAsuspended_sus = MONTANT_DE_LA_TVA_SUSPENDUE
	destring TVAAN_TVAsuspended_sus , replace force
	
	*Number of clients
	replace NINEA = trim(NINEA)
	replace NINEA = upper(NINEA)
	replace NINEA = subinstr(NINEA," ","",.)
	
	replace NINEA = subinstr(NINEA,"R18 18","",.)
	replace NINEA = subinstr(NINEA,"MD18-","",.)
	replace NINEA = subinstr(NINEA,"18-","",.)
	replace NINEA = subinstr(NINEA," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(NINEA,-`h',1)
		destring test, force replace 
		replace NINEA = substr(NINEA,1,length(NINEA)-1-`h') if test == . 
		drop test
	}
	
	destring NINEA, replace force
	
	egen TVAAN_sus_uniquesup = tag(NINEA ninea)
	egen TVAAN_sus_uniquecli = tag(NINEA ninea)

	preserve

	*Collapse from client's perspective
	collapse (sum) TVAAN_montantpurchased_sus TVAAN_TVAsuspended_sus TVAAN_sus_uniquesup, by(ninea annee)

	label var TVAAN_sus_uniquesup "TVA Annexes: number of suppliers of NINEA with suspended TVA"
	label var TVAAN_TVAsuspended_sus "TVA Annexes: TVA suspended by NINEA on behalf of client"
	label var TVAAN_montantpurchased_sus "TVA Annexes: Amount sold by NINEA (suspension declaration)" 

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_suspensionclient
	sa `TVAAN_suspensionclient' , replace		
	restore 
	
	preserve
	
	*Collapse 
	collapse (sum) TVAAN_montantpurchased_sus TVAAN_TVAsuspended_sus  TVAAN_sus_uniquecli, by(NINEA annee)

	label var TVAAN_sus_uniquecli "TVA Annexes: number of clients of NINEA with precompte TVA"
	label var TVAAN_TVAsuspended_sus "TVA Annexes: TVA suspended by NINEA on behalf of client"
	label var TVAAN_montantpurchased_sus "TVA Annexes: Amount sold by NINEA (suspension declaration)" 
	
	rename NINEA ninea
	rename TVAAN_TVAsuspended_sus TVAAN_TVAsuspended_sussup
	rename TVAAN_montantpurchased_sus TVAAN_montantpurchased_sussup

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_suspensionsupplier
	sa `TVAAN_suspensionsupplier' , replace		
	restore 	
	
****************************************************************	
***Achats locaux
****************************************************************
use "Programme_2020\data_waste\Copie de annexe_achlocaux - part1", clear

	*generate numeric ninea for third party
	gen ninea = NINEA_DU_FOURNISSEUR
	
	replace ninea = subinstr(ninea,"R18 18","",.)
	replace ninea = subinstr(ninea,"MD18-","",.)
	replace ninea = subinstr(ninea,"18-","",.)
	replace ninea = subinstr(ninea,"13L","",.)
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = .
	forvalues y = 3/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	drop if annee == . 
	
	*gen montantfacture 
	gen TVAAN_montant_achlocaux = MONTANT_HORS_TVA 
	destring TVAAN_montant_achlocaux , replace force
	
	destring TVA_FACTUREE, force replace 
	destring TVA_DEDUITE, force replace 
	
	egen TVAAN_TVA_achlocaux = rowmax(TVA_FACTUREE TVA_DEDUITE)
	
	*Number of clients
	replace NINEA = trim(NINEA)
	replace NINEA = upper(NINEA)
	replace NINEA = subinstr(NINEA," ","",.)
	
	replace NINEA = subinstr(NINEA,"R18 18","",.)
	replace NINEA = subinstr(NINEA,"MD18-","",.)
	replace NINEA = subinstr(NINEA,"18-","",.)
	replace NINEA = subinstr(NINEA," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(NINEA,-`h',1)
		destring test, force replace 
		replace NINEA = substr(NINEA,1,length(NINEA)-1-`h') if test == . 
		drop test
	}
	
	destring NINEA, replace force
	
	egen TVAAN_achlocaux_uniquesupplier = tag(NINEA ninea)
	egen TVAAN_achlocaux_uniqueclient = tag(NINEA ninea)

	preserve

	*Collapse (from suppliers's perspective)
	collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniqueclient, by(ninea annee)

	label var TVAAN_achlocaux_uniqueclient "TVA Annexes: number of clients of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local sales by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount sold by NINEA in local sales" 

	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_achlocauxsupplier1
	sa `TVAAN_achlocauxsupplier1' , replace		
	restore 
	
	preserve
	
	*Collapse (from client' perspective)
	collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniquesupplier, by(NINEA annee)

	label var TVAAN_achlocaux_uniquesupplier "TVA Annexes: number of suppliers of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local purchases by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount purchased by NINEA in local purchases" 
	
	rename NINEA ninea
	rename TVAAN_TVA_achlocaux TVAAN_TVA_achlocauxcli
	rename TVAAN_montant_achlocaux TVAAN_montant_achlocauxcli
	
	drop if ninea == . 
	drop if annee == . 	
	
	tempfile TVAAN_achlocauxclient1
	sa `TVAAN_achlocauxclient1' , replace		
	restore 		
	
****************************************************************	
***Achats locaux
****************************************************************
use "Programme_2020\data_waste\Copie de annexe_achlocaux - part2", clear

	*generate numeric ninea for third party
	gen ninea = NINEA_DU_FOURNISSEUR
	
	replace ninea = subinstr(ninea,"R18 18","",.)
	replace ninea = subinstr(ninea,"MD18-","",.)
	replace ninea = subinstr(ninea,"18-","",.)
	replace ninea = subinstr(ninea,"13L","",.)
	replace ninea = subinstr(ninea," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
	destring ninea, replace force
	
	*gen year
	gen annee = .
	forvalues y = 3/9 {
	replace annee = 2010 + `y' if strpos(ANNEE_DE_LA_DECLARATION, "`y'") > 0
	}

	drop if annee == . 

	*gen montantfacture 
	gen TVAAN_montant_achlocaux = MONTANT_HORS_TVA 
	destring TVAAN_montant_achlocaux , replace force

	destring TVA_FACTUREE, force replace 
	destring TVA_DEDUITE, force replace 

	egen TVAAN_TVA_achlocaux = rowmax(TVA_FACTUREE TVA_DEDUITE)

	*Number of clients
	replace NINEA = trim(NINEA)
	replace NINEA = upper(NINEA)
	replace NINEA = subinstr(NINEA," ","",.)
	replace NINEA = subinstr(NINEA,".","",.)

	replace NINEA = subinstr(NINEA,"R18 18","",.)
	replace NINEA = subinstr(NINEA,"MD18-","",.)
	replace NINEA = subinstr(NINEA,"18-","",.)
	replace NINEA = subinstr(NINEA," ","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(NINEA,-`h',1)
		destring test, force replace 
		replace NINEA = substr(NINEA,1,length(NINEA)-1-`h') if test == . 
		drop test
	}
	
	destring NINEA, replace force
	
	egen TVAAN_achlocaux_uniquesupplier = tag(NINEA ninea)
	egen TVAAN_achlocaux_uniqueclient = tag(NINEA ninea)

	preserve

	*Collapse (from suppliers' perspective)
	collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniqueclient, by(ninea annee)
	
	label var TVAAN_achlocaux_uniqueclient "TVA Annexes: number of clients of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local sales by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount sold by NINEA in local sales" 
	
	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_achlocauxsupplier2
	sa `TVAAN_achlocauxsupplier2' , replace		
	restore 
	
	preserve
	
	*Collapse (from client's perspective)
	collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniquesupplier, by(NINEA annee)

	label var TVAAN_achlocaux_uniquesupplier "TVA Annexes: number of suppliers of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local purchases by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount purchased by NINEA in local purchases" 
	
	rename NINEA ninea
	rename TVAAN_TVA_achlocaux TVAAN_TVA_achlocauxcli
	rename TVAAN_montant_achlocaux TVAAN_montant_achlocauxcli
	
	drop if ninea == . 
	drop if annee == . 
	
	tempfile TVAAN_achlocauxclient2
	sa `TVAAN_achlocauxclient2' , replace		
	restore 	
	
*******************************************
*Integrate data
*******************************************

use `TVAAN_achlocauxclient1', clear
append using `TVAAN_achlocauxclient2' 


collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniquesupplier, by(ninea annee)

	label var TVAAN_achlocaux_uniquesupplier "TVA Annexes: number of suppliers of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local purchases by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount purchased by NINEA in local purchases" 
	
tempfile TVAAN_achlocauxclient
sa `TVAAN_achlocauxclient', replace 

use `TVAAN_achlocauxsupplier1', clear
append using `TVAAN_achlocauxsupplier2' 

collapse (sum) TVAAN_montant_achlocaux TVAAN_TVA_achlocaux TVAAN_achlocaux_uniqueclient , by(ninea annee)

	label var TVAAN_achlocaux_uniqueclient "TVA Annexes: number of clients of NINEA in local purchases"
	label var TVAAN_TVA_achlocaux "TVA Annexes: TVA in local sales by NINEA"
	label var TVAAN_montant_achlocaux "TVA Annexes: Amount sold by NINEA in local sales" 
	
tempfile TVAAN_achlocauxsupplier
sa `TVAAN_achlocauxsupplier', replace 

display "use TVAAN_achlocauxclient, clear"
use `TVAAN_achlocauxclient', clear

foreach dataset in TVAAN_achlocauxsupplier TVAAN_precomptesupplier TVAAN_precompteclient TVAAN_suspensionsupplier TVAAN_suspensionclient TVAAN_import TVAAN_export TVAAN_exoneration {
display "merge `dataset'"
merge 1:1 ninea annee using ``dataset''
drop _merge 
}

sa "Programme_2020\data_waste\AnnexesTVA_proc", replace 	

**************************************************************
**************************************************************
*First batch (data transmitted in 2019)
**************************************************************
**************************************************************
global datadir "Programme_2021\data_raw\Extractions 2021"

tempfile drop achats
tempfile achats 

forvalues x = 1/6 {
	
		import excel "$datadir/Annexe_TVA_AchatsLocaux/ACHATS_LOCAUX_p`x'_28042021", clear firstrow

		qui ds
		foreach var in `r(varlist)' {
			
			local newname = lower("`var'")
			rename `var' `newname'
			
		}

		gen file = "Annexe_TVA_AchatsLocaux/ACHATS_LOCAUX_p`x'_28042021"
		cap noisily append using `achats'
		sa `achats', replace 
}

*Clean nineas 
foreach ninea in ninea_decl ninea_du_fournisseur {

clonevar `ninea'2 = `ninea'
replace `ninea'= subinstr(`ninea'," ","",.)
replace `ninea' = subinstr(`ninea',".","",.)

	forvalues h = 3(-1)1 {
		gen test = substr(`ninea',-`h',1)
		destring test, force replace 
		replace `ninea'= substr(`ninea', 1, length(`ninea')-1-`h') if test == . 
		drop test
	}
	
destring `ninea', replace force

}

sa "Programme_2021/data_waste/TVAAnnex2021", replace

use "Programme_2021/data_waste/TVAAnnex2021", clear

	destring tva_facturee, replace force
	replace tva_facturee = abs(tva_facturee)
	
	forvalues annee = 2015/2021 {
		
		replace annee = "`annee'" if strpos(annee, "`annee'") > 0  
		
	}
	
	destring annee, force replace
	drop if annee < 2015
	drop if annee == .
	drop if annee > 2021 
	
	preserve

		collapse (sum) tva_facturee, by(annee ninea_decl)
		gen expenses = tva_facturee/0.2
		rename ninea ninea
		tempfile expenses
		sa `expenses', replace 
		
	restore
	
	preserve

		collapse (sum) tva_facturee, by(annee ninea_du_fournisseur)
		gen revenues = tva_facturee/0.2
		rename ninea ninea
		tempfile revenues
		sa `revenues', replace 
		
	restore	
	
*Merge 	
use `revenues', clear
merge 1:1 ninea annee using `expenses'

drop _merge 

rename revenues TVAAN_revenues
rename expenses TVAAN_expenses 
rename annee annee 

sa "Programme_2021/data_waste/TVAAnnex2021", replace