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

set graphics off 
*obs: round refers to different versison of the risk score. Default is 1 

*CME2
import excel "Programme_2021/selection files/DGID/PROGRAMME CSP CME 2 21-04-2021.xls", firstrow clear
*obs it is the same file as "PROGRAMME CSP DRSCOF 21-04-2021"

clonevar raisonsociale = RAISONSOCIALE
gen ninea = . 
gen center_csp = "CME 2"
gen verificateur = VERIFICATEURS

replace ninea = 	14861	if strpos(raisonsociale,	"IMPRIMERIE SAINT PAUL"	)>0
replace ninea = 	30594	if strpos(raisonsociale,	"SOCIETE IMPORT EXPORT PIECES AUTOMOBILES"	)>0
replace ninea = 	43521	if strpos(raisonsociale,	"TECHNIQUES INDUSTRIES "	)>0
replace ninea = 	62018	if strpos(raisonsociale,	"WADE TRADING COMPANY"	)>0
replace ninea = 	107385	if strpos(raisonsociale,	"SCI LES ARCADES"	)>0
replace ninea = 	289282	if strpos(raisonsociale,	"HAIF HAKIM"	)>0
replace ninea = 	303933	if strpos(raisonsociale,	"CHEIKH SADIBOU TRAORE"	)>0
replace ninea = 	518748	if strpos(raisonsociale,	"AKACIA SARL"	)>0
replace ninea = 	2100717	if strpos(raisonsociale,	"AFRIQUE ASCENSEUR SARL"	)>0
replace ninea = 	2119940	if strpos(raisonsociale,	"CORFITEX TRADING LIMITED SENEGAL"	)>0
replace ninea = 	2254267	if strpos(raisonsociale,	"TALLA FALL"	)>0
replace ninea = 	2261361	if strpos(raisonsociale,	"TAHSINE SALEH"	)>0
replace ninea = 	2367812	if strpos(raisonsociale,	"FOCUS INDUSTRIES"	)>0
replace ninea = 	2374239	if strpos(raisonsociale,	"VOILE D'OR"	)>0
replace ninea = 	2487454	if strpos(raisonsociale,	"FRATERNITE SA"	)>0
replace ninea = 	2645151	if strpos(raisonsociale,	"KARIMA SUARL"	)>0
replace ninea = 	2696196	if strpos(raisonsociale,	"LE COLLEGE BILINGUE SARL"	)>0
replace ninea = 	3007524	if strpos(raisonsociale,	"PRESTILUX SARL"	)>0
replace ninea = 	4224557	if strpos(raisonsociale,	"TAWATRANS SARL"	)>0
replace ninea = 	4502292	if strpos(raisonsociale,	"GRANDS TRAVAUX ET SERVICES "	)>0
replace ninea = 	4507979	if strpos(raisonsociale,	"ENSUP AFRIQUE"	)>0
replace ninea = 	4590841	if strpos(raisonsociale,	"WEST LIGHT ENERGY SA"	)>0
replace ninea = 	4650059	if strpos(raisonsociale,	"MAXIMIZ SARL"	)>0
replace ninea = 	4675916	if strpos(raisonsociale,	"GUEB SERVICES SARL"	)>0
replace ninea = 	4718922	if strpos(raisonsociale,	"BEAUTIFUL SOUL SARL"	)>0
replace ninea = 	4949379	if strpos(raisonsociale,	"CEFI SARL"	)>0
replace ninea = 	5028338	if strpos(raisonsociale,	"JAPOO SA"	)>0
replace ninea = 	5108635	if strpos(raisonsociale,	"SOTRAVA INTERIM SARL"	)>0
replace ninea = 	5416252	if strpos(raisonsociale,	"PHYMANALU SARL"	)>0
replace ninea = 	5820049	if strpos(raisonsociale,	"TOP WORK SENEGAL"	)>0
replace ninea = 	5836939	if strpos(raisonsociale,	"MFI SENEGAL SARL"	)>0
replace ninea = 	6106266	if strpos(raisonsociale,	"POLYTECH ENTREPRISE "	)>0
replace ninea = 	6285614	if strpos(raisonsociale,	"LIVRAISON EXPRESS SUARL"	)>0
replace ninea = 	6565438	if strpos(raisonsociale,	"SEMER HOLDING SA"	)>0
replace ninea = 	4590297	if strpos(raisonsociale,	"BIJOUTERIE LA SOLUTION"	)>0
replace ninea = 	5240297	if strpos(raisonsociale,	"ADT FACILITY MANAGEMENT"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"SOCADIS"	)>0
replace ninea = 	93609	if strpos(raisonsociale,	"ENTREPRISE SENEGALAISE DE COMMERCE ET D'INDUSTRIE MASSAMBA MBENGUE"	)>0
replace ninea = 	4750180	if strpos(raisonsociale,	"TALENTS SARL"	)>0
replace ninea = 	2678904	if strpos(raisonsociale,	"BAT PRESS SARL"	)>0
replace ninea = 	78198	if strpos(raisonsociale,	"CHAKA COMPUTER"	)>0
replace ninea = 	5030888	if strpos(raisonsociale,	"SEBOIS"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"ENTREPRISE KHALIFA ABABACAR SY"	)>0
replace ninea = 	4188399	if strpos(raisonsociale,	"DIAMALAYE TRANSPORT"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"SATAC"	)>0
replace ninea = 	476152	if strpos(raisonsociale,	"JAMAL SALEH"	)>0
replace ninea = 	65997	if strpos(raisonsociale,	"INTERIM SECURITE"	)>0
replace ninea = 	4673019	if strpos(raisonsociale,	"AFRIMEDIA NEW AGENCY"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"ACE AUDIT CONTRÔLE ET EXPERTISE SA"	)>0
replace ninea = 	2648866	if strpos(raisonsociale,	"SENEGAL SALUBRITÉ SELAL"	)>0
replace ninea = 	1899056	if strpos(raisonsociale,	"BUREAU GAUDILLAT SA"	)>0
replace ninea = 	457970	if strpos(raisonsociale,	"LA BOURSE DE LA VOITURE "	)>0
replace ninea = 	5091252	if strpos(raisonsociale,	"LES BARBUS SN SARL"	)>0
replace ninea = 	4856102	if strpos(raisonsociale,	"SCI SENESP SARL"	)>0
replace ninea = 	5131389	if strpos(raisonsociale,	"FERMES OURNDOU SARL"	)>0
replace ninea = 	5548518	if strpos(raisonsociale,	"SALAM INVESTISSEMENT CORPORATION SARL"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"IMC SARL"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"FLORIDA AFRIQUE"	)>0
replace ninea = 	5881207	if strpos(raisonsociale,	"WEAWE SENEGAL LIMITED"	)>0
replace ninea = 	2543058	if strpos(raisonsociale,	"LES ENTREPÔTS DE HANN"	)>0
replace ninea = 	4691962	if strpos(raisonsociale,	"SERIGNE TOURE"	)>0
replace ninea = 	3046952	if strpos(raisonsociale,	"SOPARTECH DEVELOPPEMENTS SUARL"	)>0
replace ninea = 	2612978	if strpos(raisonsociale,	"SAI ISOCELE"	)>0
replace ninea = 	4478005	if strpos(raisonsociale,	"DISTRIBUTION AGRO ALIMENTAIRE"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"L'ESSENTIEL SUPERMARCHE"	)>0
replace ninea = 	4746999	if strpos(raisonsociale,	"EAS INTERNATIONAL"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"GLOBEX SENEGAL SA"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"AA DAKAR"	)>0
replace ninea = 	12500	if strpos(raisonsociale,	"COMPAGNIE AFRICAINE DE DROGUERIE  "	)>0
replace ninea = 	2835124	if strpos(raisonsociale,	"ENTREPRISE DE FORAGE ET DE MINAGE"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"SAI BASSARI"	)>0
replace ninea = 	2113158	if strpos(raisonsociale,	"SAI LA REPUBLIQUE BLANCHOT SA"	)>0
replace ninea = 	2476176	if strpos(raisonsociale,	"AMFISH EXPORT "	)>0
replace ninea = 	1924944	if strpos(raisonsociale,	"TECHNOPOLIS SARL "	)>0
replace ninea = 	4383353	if strpos(raisonsociale,	"EL FISH"	)>0
replace ninea = 	2803452	if strpos(raisonsociale,	"DYNAMIC SERVICE INTERNATIONAL "	)>0
replace ninea = 	4707785	if strpos(raisonsociale,	"JARDIN DU SAHEL"	)>0
replace ninea = 	2814003	if strpos(raisonsociale,	"RUISE DAKAR IMPORT EXPORT"	)>0
replace ninea = 	2237247	if strpos(raisonsociale,	"COMPAGNIE AFRICAINE DE PESAGE"	)>0
replace ninea = 	6320684	if strpos(raisonsociale,	"OZYX COMPOSIT SARL"	)>0
replace ninea = 	5481007	if strpos(raisonsociale,	"BARA MBOUP ELECTRONIC"	)>0
replace ninea = 	6224050	if strpos(raisonsociale,	"NORVIA WEST AFRICA SA"	)>0
replace ninea = 	4218451	if strpos(raisonsociale,	"DEVERYWARE AFRIQUE SA"	)>0
replace ninea = 	4970431	if strpos(raisonsociale,	"TOP STRUCTURES "	)>0
replace ninea = 	5429429	if strpos(raisonsociale,	"BLACK RHINO SHARED SERVICES SENEGAL"	)>0
replace ninea = 	4873148	if strpos(raisonsociale,	"FOREIGN ASSETS"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"SOCIETE DE CONSTRUCTION IMMOBILIERE "	)>0
replace ninea = 	228313	if strpos(raisonsociale,	"DAKAR CHRONO"	)>0
replace ninea = 	4760212	if strpos(raisonsociale,	"AVANT-GARDE PROPERTIES"	)>0
replace ninea = 	4438124	if strpos(raisonsociale,	"VANILLA DISTRIBUTION"	)>0
replace ninea = 	2926345	if strpos(raisonsociale,	"TIC TAC SARL"	)>0
replace ninea = 	2568022	if strpos(raisonsociale,	"VISIO CONTACT"	)>0
replace ninea = 	5060679	if strpos(raisonsociale,	"WILLIER INGENIEURIE INTERNATIONAL"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"GAYE ET ASSOCIES"	)>0
replace ninea = 	2326157	if strpos(raisonsociale,	"SODEVCO"	)>0
replace ninea = 	5063748	if strpos(raisonsociale,	" GROUP SALL-S"	)>0
replace ninea = 	.	if strpos(raisonsociale,	"STE DE CONSTRUCTION ET DE TRAVAUX MARITIMES"	)>0
replace ninea = 	5051743	if strpos(raisonsociale,	"SANCFIS SENEGAL SARL EX ALINK TELECOM SENEGAL - SARL SA"	)>0
replace ninea = 	2238617	if strpos(raisonsociale,	"SIMON & CHRISTIANSEN AFRIQUE"	)>0

keep ninea raisonsociale center verificateur

tempfile cme2
sa `cme2', replace

*Import CSP for CPR
import excel "Programme_2021/selection files/DGID/PROPOSITIONS CSP 2021CPR 2 with verificateur.xlsx", firstrow cellrange(A3) clear

clonevar raisonsociale = DOSSIERS
clonevar ninea = NINEA 
clonevar verificateur = AGENT

replace ninea = subinstr(ninea," ","",.)
replace ninea = subinstr(ninea,".","",.)
	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
destring ninea, force replace 	
gen center_csp = "CPR"

keep ninea raisonsociale center_csp verificateur

tempfile cpr
sa `cpr', replace

*Import CSP for CME 1
import excel "Programme_2021/selection files/DGID/PROPOSITIONS CSP DRSCF.xlsx", firstrow cellrange(A2) clear

clonevar raisonsociale = NOMOURAISONSOCIALE
clonevar ninea = NINEA 
clonevar verificateur = VERIFICATEURS 

replace ninea = subinstr(ninea," ","",.)
replace ninea = subinstr(ninea,".","",.)
	forvalues h = 3(-1)1 {
		gen test = substr(ninea,-`h',1)
		destring test, force replace 
		replace ninea = substr(ninea,1,length(ninea)-1-`h') if test == . 
		drop test
	}
	
destring ninea, force replace 

replace ninea = 4103868 if ninea == 41038682
gen center_csp = "CME 1"

keep ninea raisonsociale center_csp verificateur

tempfile cme1
sa `cme1', replace

***************
*Append
***************

use `cme1', clear
append using `cme2'
append using `cpr'

sort center raisonsociale
bys ninea: gen  n = _n 
replace ninea = -1000*_n if ninea == . | n > 1 
drop n

*Clean verificateur
replace verificateur = "Mamadou L ET M NDIAYE, Mamadou SAMBA" if strpos(verificateur, "Mamadou L ET M NDIAYE, Mamadou SAMBA") > 0 
replace verificateur = "Ndiaga SOW" if strpos(verificateur, "Ndiaga SOW") > 0
replace verificateur = "Papa Mamadou NDIAYE" if strpos(verificateur, "Papa Mamadou NDIAYE") > 0 
replace verificateur = "SERIGNE SALIOU SEYE" if strpos(verificateur, "SERIGNE SALIOU") > 0 
replace verificateur = "Pape Samba COULIBALY" if strpos(verificateur , "COULIBALY") > 0 
replace verificateur = "Paul Dibocor NDOUR" if strpos(verificateur , "Paul Dibocor NDOUR") > 0

drop if strpos(verificateur, "doublon") > 0
drop if raison == "" 

replace verificateur = upper(verificateur)

sa "Programme_2021/data_waste/CSPselection", replace 

*********************************************************************************
***DSF
*********************************************************************************

import excel "Programme_2021/selection files/DGID/CSP2021 cleaned by Alipio.xlsx", firstrow clear
*obs it is the same file as "PROGRAMME CSP DRSCOF 21-04-2021"

clonevar raisonsociale = RAISONSOCIALE
destring NINEA, gen(ninea)force

replace Centre = upper(Centre)
replace Centre = trim(Centre)

gen verificateur = VERIFICATEUR
replace verificateur = "VERIFICATEUR" if verificateur == ""
rename Centre center_csp 

keep raisonsociale ninea center_csp verificateur 

sort ninea
replace ninea = -1500*_n if ninea == .
 
replace center_csp = "SAINT LOUIS" if  center_csp  == "SAINT-LOUIS"
replace center_csp =  "KEDOUGOU" if center_csp == "KéDOUGOU"
replace center_csp = "KAOLACK-FATICK" if  center_csp  == "FATICK"

bys ninea: gen n = _n
replace ninea = -1500*_n if n > 1 

sa "Programme_2021/data_waste/CSPselectionDSF", replace 

*Dakar Plateau and Guediawaye
import excel "Programme_2021/selection files/DGID/CSP2021 DP Guediawaye cleaned by Alipio.xlsx", firstrow clear
*obs it is the same file as "PROGRAMME CSP DRSCOF 21-04-2021"

clonevar raisonsociale = raison_sociale
clonevar ninea = NINEA

replace bureau = upper(bureau)
replace bureau = trim(bureau)

gen verificateur = Vérificateur
replace verificateur = "VERIFICATEUR" if verificateur == ""
rename bureau center_csp 

keep raisonsociale ninea center_csp verificateur 

sort ninea
replace ninea = -1500*_n if ninea == .
 
bys ninea: gen n = _n
replace ninea = -1500*_n if n > 1 

sa "Programme_2021/data_waste/CSPselectionDSF_round2", replace 