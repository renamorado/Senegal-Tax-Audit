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
		
local date: disp  c(current_date)
di "`date'"
set scheme s1color

***********
*Add information from ANSD (Census of Firms in Senegal)
***********
import excel "$rawdata\Analysis all data\wastedata\Liste des immatriculations ANSD.xlsx", firstrow clear

		keep  NUMERO_NINEA LIBELLE_LOCALITE LIBELLE_REGION LIBELLE_TYPEVOIE LIBELLE_REGIME_JURIDIQUE CODE_ACTIVITE_PRINCIPALE LIBELLE_ACTIVITE_PRINCIPALE LIBELLE_MACROSECTEUR LIBELLE_CENTRE_FISCAL DATE_CREATION_ENTREPRISE ADRESSE NUMERO_VOIE RAISON_SOCIALE TYPE_PERSONNE CAPITAL DATE_CREATION_NINEA

		clonevar firmid = NUMERO_NINEA

		drop if firmid == ""
		bys firmid: gen N = _N
		tab N
		drop if N > 1 
		drop N 
		isid firmid 

		ds firmid, not 
		foreach v in `r(varlist)' {
			label var `v' "ANSD"
			rename `v' ANSD_`v'
		}

sa "$analysisdata/ANSD.dta", replace