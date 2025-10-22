**         Project name: Tax audits under weak fiscal capacity - Senegal			  **
*****************************************************************************************

*****************************************************************************************
*****************
** PROGRAMS   **
*****************

set more off
clear all 
*
*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","alipi") { 										// Alipio's computer
		global rootdir "D:\alipi\Dropbox\Trabalho\2017 WB"
	}

		global rawdata "$rootdir\Infractions-saisie"
		global analysisdata "$rootdir\Senegal tax audits\Analysis all data"
	

cd "$analysisdata"

*log using "$analysisdata\wastedata\Test merge.smcl"

matrix test = J(17,3,0)
matrix rownames test  = "\multirow{4}{*}{Notification} & Initial" "& Number of missing identifier" "& Unique combinations" "& Final unique nineas" ///
						"\hline \multirow{4}{*}{Confirmation} & Initial" "& Number of missing identifier" "& Unique combinations" "& Final unique nineas" ///
						"\hline \multirow{5}{*}{Merge} & Merged first round" "& Merged second round" "& Total merged observations" "& Only notification" "& Only confirmation" "& Unique audits" "& Unique merged audits" "& Changed audit type" "& Changed tax office type"

matrix colnames test  = " & Audit number \& ninea" "Ninea \& year \& type" "Ninea \& year"

*******************************************
******************************************
*Merging confirmation and notification using reference number-bureau-year
*******************************************
*******************************************

******************************************
*Notification
******************************************	
use "wastedata\\notification_appended_addednineas", clear

keep typedecontrole raisonsociale ninea  referencenumber anneeduchrono bureau  filename firmid

unique firmid

*Feed matrix
count
matrix test[1,1] = r(N)
matrix test[1,2] = r(N)
matrix test[1,3] = r(N)

count if referencenumber == . | firmid == "" 
matrix test[2,1] = r(N)
count if typedecontrole == "" | firmid == "" | anneeduchrono == . 
matrix test[2,2] = r(N)
count if firmid == "" | anneeduchrono == . 
matrix test[2,3] = r(N)

*Drop duplicates of reference number 
egen ID = group(referencenumber firmid typedecontrole anneeduchrono)
egen ID1 = group(referencenumber firmid)
egen ID2 = group(firmid anneeduchrono typedecontrole)
egen ID3 = group(firmid anneeduchrono)

preserve 
	bys ID1: gen n = _n
	keep if n == 1 
	drop n

	count 
	matrix test[3,1] = r(N)

	unique firmid
	matrix test[4,1] = r(unique)

	tempfile notification1
	sa `notification1', replace 
restore 

preserve 
	bys ID2: gen n = _n
	keep if n == 1 
	drop n

	count 
	matrix test[3,2] = r(N)

	unique firmid
	matrix test[4,2] = r(unique)

	tempfile notification2
	sa `notification2', replace 
restore 

preserve 
	bys ID3: gen n = _n
	keep if n == 1 
	drop n

	count 
	matrix test[3,3] = r(N)

	unique firmid
	matrix test[4,3] = r(unique)

	tempfile notification3
	sa `notification3', replace 
restore 

******************************************
*Confirmation method 1 - merge by reference numbed then do second round
******************************************
use "wastedata\\confirmation_appended_addednineas", clear

keep typedecontrole raisonsociale ninea  referencenumber anneeduchrono bureau firmid

*Feed matrix
count
matrix test[5,1] = r(N)

clonevar anneeconf = anneeduchrono 
clonevar nineaconf = ninea
clonevar raisonsocialeconf = raisonsociale
clonevar typedecontroleconf = typedecontrole
clonevar bureauconf = bureau

egen x = rowmiss(referencenumber firmid)
count if  x > 0 
matrix test[6,1] = r(N)

unique referencenumber firmid
matrix test[7,1] = r(unique)

unique firmid 
matrix test[8,1] = r(unique)

bys referencenumber firmid: gen n = _n
keep if n == 1 
drop n

******************
*Merge 
******************
merge m:1 referencenumber firmid using `notification1'

preserve
	keep if _merge >= 3 
	tempfile firstmatch
	sa `firstmatch'
	
	count 
	matrix test[9,1] = r(N)
	
restore 

*Second round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
keep if _merge == 1
drop _merge
merge m:1 firmid anneeduchrono typedecontrole using `notification2', replace update

preserve
	keep if _merge >= 3 
	tempfile secondmatch
	sa `secondmatch'
	
	count 
	local x = `r(N)'
	
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
	
	count if _merge >= 3 
	local x = `x' + `r(N)'
	
	matrix test[10,1] = `x'
	
restore 

*Integrate the two rounds 
use `firstmatch', clear
append using `secondmatch', force 
append using `thirdmatch', force 

	count if _merge >= 3 
	matrix test[11,1] = r(N)
	
	count if _merge == 2 
	matrix test[12,1] = r(N)
	
	count if _merge == 1 
	matrix test[13,1] = r(N)
	
	unique firmid typedecontrole anneeduchrono
	matrix test[14,1] = r(unique)	

	unique firmid typedecontrole anneeduchrono if _merge >= 3 
	matrix test[15,1] = r(unique)	

	count if _merge >= 3 & typedecontrole != typedecontroleconf
	matrix test[16,1] = r(N)

	count if _merge >= 3 & bureau != bureauconf
	matrix test[17,1] = r(N)	
	
*******************************************
******************************************
*Merging confirmation and notification using ninea-year  
*******************************************
*******************************************
******************************************
*Confirmation method 1 - merge by reference numbed then do second round
******************************************
use "wastedata\\confirmation_appended_addednineas", clear

keep typedecontrole raisonsociale ninea  referencenumber anneeduchrono bureau firmid

*Feed matrix
count
matrix test[5,2] = r(N)

clonevar anneeconf = anneeduchrono 
clonevar nineaconf = ninea
clonevar raisonsocialeconf = raisonsociale
clonevar typedecontroleconf = typedecontrole
clonevar bureauconf = bureau

egen x = rowmiss(referencenumber firmid)
count if  x > 0 
matrix test[6,2] = r(N)

unique referencenumber firmid
matrix test[7,2] = r(unique)

unique firmid 
matrix test[8,2] = r(unique)

bys firmid anneeduchrono typedecontrole: gen n = _n
keep if n == 1 
drop n

*Merge 
merge m:1 firmid anneeduchrono typedecontrole using `notification2'

preserve
	keep if _merge >= 3 
	tempfile firstmatch
	sa `firstmatch'
	
	count 
	matrix test[9,2] = r(N)
	
restore 

*Second round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
preserve
	keep if _merge == 1
	drop _merge
	replace anneeduchrono = anneeduchrono - 1
	merge m:1 firmid  anneeduchrono typedecontrole using `notification2', replace update
	replace anneeduchrono = anneeduchrono + 1 if _merge == 1 
	tempfile secondmatch
	sa `secondmatch'
	
	count if _merge >=3
	matrix test[10,2] = r(N)	
restore 

*Integrate the two rounds 
use `firstmatch', clear
append using `secondmatch', force 

	count if _merge >= 3 
	matrix test[11,2] = r(N)
	
	count if _merge == 2 
	matrix test[12,2] = r(N)
	
	count if _merge == 1 
	matrix test[13,2] = r(N)

	unique firmid typedecontrole anneeduchrono
	matrix test[14,2] = r(unique)	
	
	unique firmid typedecontrole anneeduchrono if _merge >= 3 
	matrix test[15,2] = r(unique)

	count if _merge >= 3 & typedecontrole != typedecontroleconf
	matrix test[16,2] = r(N)	

	count if _merge >= 3 & bureau != bureauconf
	matrix test[17,2] = r(N)	
*******************************************
******************************************
*Merging confirmation and notification using ninea-year  
*******************************************
*******************************************
******************************************
*Confirmation method 1 - merge by reference numbed then do second round
******************************************
use "wastedata\\confirmation_appended_addednineas", clear

keep typedecontrole raisonsociale ninea  referencenumber anneeduchrono bureau firmid

*Feed matrix
count
matrix test[5,3] = r(N)

clonevar anneeconf = anneeduchrono 
clonevar nineaconf = ninea
clonevar raisonsocialeconf = raisonsociale
clonevar typedecontroleconf = typedecontrole
clonevar bureauconf = bureau

egen x = rowmiss(referencenumber firmid)
count if  x > 0 
matrix test[6,3] = r(N)

unique referencenumber firmid
matrix test[7,3] = r(unique)

unique firmid 
matrix test[8,3] = r(unique)

bys firmid anneeduchrono: gen n = _n
keep if n == 1 
drop n

*Merge 
merge m:1 firmid anneeduchrono using `notification3'

preserve
	keep if _merge >= 3 
	tempfile firstmatch
	sa `firstmatch'
	
	count 
	matrix test[9,3] = r(N)
	
restore 

*Second round of merge allowing for a mismatch in year (only for the ones that did not match, and allowing notification to be one year earlier)
preserve
	keep if _merge == 1
	drop _merge
	replace anneeduchrono = anneeduchrono - 1
	merge m:1 firmid  anneeduchrono using `notification3', replace update
	replace anneeduchrono = anneeduchrono + 1 if _merge == 1 
	tempfile secondmatch
	sa `secondmatch'
	
	count if _merge >=3
	matrix test[10,3] = r(N)	
restore 

*Integrate the two rounds 
use `firstmatch', clear
append using `secondmatch', force 

	count if _merge >= 3 
	matrix test[11,3] = r(N)
	
	count if _merge == 2 
	matrix test[12,3] = r(N)
	
	count if _merge == 1 
	matrix test[13,3] = r(N)

	unique firmid typedecontrole anneeduchrono
	matrix test[14,3] = r(unique)

	unique firmid typedecontrole anneeduchrono if _merge >= 3 
	matrix test[15,3] = r(unique)	

	count if _merge >= 3 & typedecontrole != typedecontroleconf
	matrix test[16,3] = r(N)
	
	count if _merge >= 3 & bureau != bureauconf
	matrix test[17,3] = r(N)	
	
esttab matrix(test)

#delim;
esttab matrix(test) using "$analysisdata/output/3 test how to merge.tex", replace 
nomtitle 
prehead("\begin{tabular}{llrr} \hline \hline ") 
;
#delim cr	

