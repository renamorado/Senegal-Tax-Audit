*----------------------------------------------
*SENEGAL TAX AUDITS PROJECT
*Anne Brockmeyer, Pierre Bachas, Bassirou Sarr
*Round 2018-2019
*----------------------------------------------

*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","Alipio") { 										// Alipio's computer
		cd "C:\Users\Alipio Ferreira\Dropbox\Trabalho\2017 WB\Senegal tax audits"

	}
	else if c(username)=="WB382635" {
		cd `""C:\Users\wb382635\Dropbox\Senegal tax audits"'
	}
	else if "`c(username)'"=="pierrebachas" { 									// Pierre's laptop
		cd `""/Users/pierrebachas/Dropbox/Senegal tax audits"' 
	}
	else if "`c(username)'"=="alipi" { 									// Alipio's second laptop
		cd "D:\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits"                     
	}
	
*This dofile puts together the audits that were actually carried out (not only those selected)

*2018
use "Analyse des resultats du Programme_2018\Alipio\datasetprogramme2018", clear 

keep if fullaudits == 1	

keep ninea 
tempfile a2018
sa `a2018', replace

*2019
*CME1
use "Saisie des données du contrôle\Données saisies\Data Controle\CME1\Data_Control_CME1", clear
clonevar ninea = NINEA
destring ninea, force replace
bys ninea: gen n = _n
keep if n == 1

keep if Annee > 2017

keep if Type_controle == 2

keep ninea 
tempfile a20191
sa `a20191', replace

*CME2
use "Saisie des données du contrôle\Données saisies\Data Controle\CME2\Data_Control_CME2", clear
clonevar ninea = NINEA
destring ninea, force replace
bys ninea: gen n = _n
keep if n == 1

keep if Annéeduchrono > 2017

keep if Typedecontrôle == "VG"

keep ninea 
tempfile a20192
sa `a20192', replace

*DGE
import excel  "Saisie des données du contrôle\Données saisies\Data Controle\DGE\BASE_FINALE.xlsx", firstrow clear

clonevar ninea = NINEA
destring ninea, force replace
bys ninea: gen n = _n
keep if n == 1

keep if Annéeduchrono > 2017

keep if Typedecontrôle == "VG"

keep ninea 
tempfile a20193
sa `a20193', replace

*Suivi data
use "Analyse des resultats du Programme_2019\Proc_data\programme2019resultats.dta" , clear

bys ninea: gen n = _n
keep if n == 1

keep if controle == 2

keep ninea 
tempfile a20194
sa `a20194', replace


***************
*Append
***************

use `a2018', clear 
append using `a20191'
append using `a20192'
append using `a20193'
append using `a20194'

bys ninea: gen n = _n
keep if n == 1
drop if ninea == .
drop if ninea < 0 

sa "Programme_2021\data_waste\PastActualAudits.dta", replace
