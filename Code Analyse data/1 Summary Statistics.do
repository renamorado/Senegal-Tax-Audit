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

if strpos("`c(username)'","wb648862") { 										// World Bank local machine
	global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
}

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"

	* Temporary local-output override: source data paths remain in Dropbox.
	local localproject "C:/Users/`c(username)'/Documents/Projects/Senegal Tax Audits"
	capture confirm file "`localproject'/Agents.md"
	if !_rc {
		capture mkdir "`localproject'/output"
		capture mkdir "`localproject'/output/tables"
		global output "`localproject'/output/tables"
		adopath ++ "`localproject'/ado"
	}

local date: disp  c(current_date)
di "`date'"
set scheme s1color

******************************
******************************
*12 SUMMARY STATISTICS
******************************
******************************

**********
*IMPORT 2020 CIT DATA
**********
import excel "$rawdata/Programme_2021\data_raw\Extractions 2021\Cotisations_IS_2020.xls", cellrange(B3)  firstrow clear


keep if Centredecotisation == "CENTRE DES MOYENNES ENTREPRISES DAKAR 1" | ///
		Centredecotisation == "CENTRE DES MOYENNES ENTREPRISES DAKAR 2" | ///
		Centredecotisation == "CME" | ///
		Centredecotisation == "CPR" | ///
		Centredecotisation == "DAKAR-LIBERTE" | ///
		Centredecotisation == "DAKAR-PLATEAU" | ///
		Centredecotisation == "DIRECTION DES GRANDES ENTREPRISES" | ///
		Centredecotisation == "GRAND-DAKAR" | ///
		Centredecotisation == "GUEDIAWAYE" | ///
		Centredecotisation == "NGOR-ALMADIES" | ///
		Centredecotisation == "PIKINE"

gen IS_filed2020 = 1 

tempfile CIT2020
sa `CIT2020', replace 

use "$analysisdata/datasetforanalysis.dta", clear

append using `CIT2020', force
*Three types of data

	*Self reported
		*VAT declarations
		*CIT declarations
		*CGU declarations
		*WIT declarations
		*TAF declarations 
	
	*Third party
		*Imports
		*Exports
		*Treasury Payments
		*VAT annexes
	
	*Audits 
		*Fiches de Suivi
		*Saisie
		
gen audits_filed2014 = 	0
gen audits_filed2015 = 	0
gen audits_filed2016 = 	0
gen audits_filed2017 = 	0
gen audits_filed2018 = 	0
gen audits_filed2019 = 	0
gen audits_filed2020 = 	0

gen auditss_filed2014 = 	0
gen auditss_filed2015 = 	0
gen auditss_filed2016 = 	0
gen auditss_filed2017 = 	0
gen auditss_filed2018 = 	0
gen auditss_filed2019 = 	0
gen auditss_filed2020 = 	0	
	
forvalues y = 2014/2020 {
	replace audits_filed`y' = 1 if suivi == 1 & anneeduchrono == `y'
	replace auditss_filed`y' = 1 if saisie == 1 & anneeduchrono == `y'
	
}	
	
matrix describe = J(11,7,0)
matrix rownames describe = "\multirow{5}{*}{A Self reported} & CIT" " & VAT" "& PAYE" "& CGU" "& TAF" "\hline \multirow{4}{*}{B Third party} & Imports" "& Exports" "& Procurement" "& VAT annexes"  "\hline  \multirow{2}{*}{C Audits data} & Digitized" "& Self-reported (Excel)"
matrix colnames describe = "& 2014" "2015" "2016" "2017" "2018" "2019" "2020"

local r = 0 
foreach variable in "IS" "TVA" "RAS_IRPP" "CGU"  "TAF" "IMP" "EXP" "MAN" "TVAAN" "auditss" "audits" {
	local ++r 
	
	local c = 0 
	forvalues y = 2014/2020 {
		
		local ++c

			capture confirm variable `variable'_filed`y'
			if !_rc {
					qui capture count if `variable'_filed`y' ==  1
					local n = `r(N)'	               
			}
		   else {
				   local n = 0
		   }
		
		matrix describe[`r', `c'] = `n' 
	}
	
}

	#delim ;
	esttab matrix(describe) using "$output\12 count observations by data source temp.tex", 
	nomtitle
	prehead("") 
	posthead(\hline) postfoot("")
	replace
	;
	#delim cr	
	
	filefilter "$output\12 count observations by data source temp.tex" "$output\12 count observations by data source.tex", from(" 0") to(" NA")	replace
	
	erase "$output\12 count observations by data source temp.tex"	
	
*********************************************************************************
*count cases in the selection with details
*********************************************************************************		
matrix count = J(5, 7, 0)
matrix rownames count = "Large Taxpayer Unit" "Medium Taxpayer Unit" "Liberal Professions" "SME (Regional)" "\hline Total"
matrix colnames count = "Inspectors" "Algorithm" "Total" "Inspectors" "Algorithm" "Random" "Total"

local r = 0 
forvalues b = 1/4  {
	local ++r 
	
	count if groupbureau == `b' & dgid == 1 & x2 == 1
	matrix count[`r', 1] = `r(N)'
	
	count if groupbureau == `b' & algorithm == 1 & x2 == 1
	matrix count[`r', 2] = `r(N)'

	count if groupbureau == `b' & (dgid == 1 | algorithm == 1) & x2 == 1
	matrix count[`r', 3] = `r(N)'
	
	count if groupbureau == `b' & dgid == 1 & x2 == 0
	matrix count[`r', 4] = `r(N)'	

	count if groupbureau == `b' & algorithm == 1 & x2 == 0 & random == 0
	matrix count[`r', 5] = `r(N)'

	count if groupbureau == `b' & random == 1 & x2 == 0
	matrix count[`r', 6] = `r(N)'
	
	count if groupbureau == `b' & (dgid == 1 | algorithm == 1) & x2 == 0
	matrix count[`r', 7] = `r(N)'	
	
}

	local ++r 
	
	count if dgid == 1 & x2 == 1
	matrix count[`r', 1] = `r(N)'
	
	count if algorithm == 1 & x2 == 1
	matrix count[`r', 2] = `r(N)'

	count if (dgid == 1 | algorithm == 1) & x2 == 1
	matrix count[`r', 3] = `r(N)'
	
	count if dgid == 1 & x2 == 0
	matrix count[`r', 4] = `r(N)'	

	count if algorithm == 1 & x2 == 0 & random == 0
	matrix count[`r', 5] = `r(N)'

	count if random == 1 & x2 == 0
	matrix count[`r', 6] = `r(N)'
	
	count if (dgid == 1 | algorithm == 1) & x2 == 0
	matrix count[`r', 7] = `r(N)'	

	#delim ;
	esttab matrix(count) using "$output\12 count cases.tex", 
	nomtitle
	prehead("") 
	posthead(\hline) postfoot("")
	replace
	;
	#delim cr		

******************************************************************************
******************************************************************************
*Get the selections of 2018, 2019 and 2020
******************************************************************************
******************************************************************************

use "$wastedata/selectionraw", clear 

gen selectionmethod = .
replace selectionmethod = 1 if algorithm == 1 
replace selectionmethod = 2 if dgid == 1 
replace selectionmethod = 3 if random == 1 
replace selectionmethod = 4 if algorithm == 1 & dgid == 1 
replace selectionmethod = 4 if random == 1 & dgid == 1 
replace selectionmethod = 5 if replacement == 1 

label define f 1 "Algorithm" 2 "Discretion" 3 "Random" 4 "Overlap" 5 "Safeties"
label values selectionmethod f

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

destring selectionyear, replace force
destring controle, replace force

replace algorithm = 0 if overlap == 1

******************************
*Make complete tables
******************************
matrix countVG = J(28, 4, 0)
matrix colnames countVG = "& Algorithm" "Discretion" "Overlap"  "Total"
matrix rownames countVG = "\multirow{3}{*}{DGE} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CME 1} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CME 2} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CPR} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Dakar P.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Ngor A.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Pikine G.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{G. Dakar} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{All} & 2018" "& 2019" "& 2020" "\hline Total & "

local r = 0 
foreach b in "DGE" "CME1" "CME2" "CPR" "DP" "NGA" "PKG" "GD" {
	
	foreach y in 2018 2019 2020 {
		
		local ++r 
		local c = 0
		foreach method in algorithm dgid  overlap {
			
			local ++c 
			count if bureau == "`b'" & selectionyear == `y' & `method' == 1 & controle == 2
			matrix countVG[`r', `c'] = `r(N)'
			
		}
			
			*Total
			local ++c 
			count if bureau == "`b'" & selectionyear == `y' &  controle == 2
			matrix countVG[`r', `c'] = `r(N)'
	}
}

*All offices
foreach y in 2018 2019 2020 {
	
	local ++r 
	local c = 0
	foreach method in algorithm dgid  overlap {
		
		local ++c 
		count if selectionyear == `y' & `method' == 1 & controle == 2
		matrix countVG[`r', `c'] = `r(N)'
		
	}
		
		*Total
		local ++c 
		count if selectionyear == `y' &  controle == 2
		matrix countVG[`r', `c'] = `r(N)'
}

*All offices and years
local ++r 
	local c = 0
	foreach method in algorithm dgid  overlap {
		
		local ++c 
		count if `method' == 1 & controle == 2
		matrix countVG[`r', `c'] = `r(N)'
		
	}
		
local ++c 
count if  controle == 2
matrix countVG[`r', `c'] = `r(N)'

#delim ;
esttab matrix(countVG) using "$output\11 balance VG.tex", 
nomtitle
prehead(\begin{tabular}{llcccc})
postfoot(\hline \end{tabular}) 
replace
;
#delim cr

*Make complete tables
matrix countCP = J(28, 6, 0)
matrix colnames countCP = "& Random" "Algorithm" "Discretion" "Overlap" "Replacement" "Total"
matrix rownames countCP = "\multirow{3}{*}{DGE} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CME 1} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CME 2} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{CPR} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Dakar P.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Ngor A.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{Pikine G.} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{G. Dakar} & 2018" "& 2019" "& 2020" "\hline \multirow{3}{*}{All} & 2018" "& 2019" "& 2020" "\hline Total & "

local r = 0 
foreach b in "DGE" "CME1" "CME2" "CPR" "DP" "NGA" "PKG" "GD" {
	
	foreach y in 2018 2019 2020 {
		
		local ++r 
		local c = 0
		foreach method in random algorithm dgid overlap replacement {
			
			local ++c 
			count if bureau == "`b'" & selectionyear == `y' & `method' == 1 & controle == 1
			matrix countCP[`r', `c'] = `r(N)'
			
		}
			
			*Total
			local ++c 
			count if bureau == "`b'" & selectionyear == `y' &  controle == 1
			matrix countCP[`r', `c'] = `r(N)'
	}
}


*All offices
foreach y in 2018 2019 2020 {
	
	local ++r 
	local c = 0
		foreach method in random algorithm dgid overlap replacement {
		
		local ++c 
		count if selectionyear == `y' & `method' == 1 & controle == 1
		matrix countCP[`r', `c'] = `r(N)'
		
	}
		
		*Total
		local ++c 
		count if selectionyear == `y' &  controle == 1
		matrix countCP[`r', `c'] = `r(N)'
}

*All offices and years
local ++r 
	local c = 0
		foreach method in random algorithm dgid overlap replacement {
		
		local ++c 
		count if `method' == 1 & controle == 1
		matrix countCP[`r', `c'] = `r(N)'
		
	}
		
local ++c 
count if  controle == 1
matrix countCP[`r', `c'] = `r(N)'

#delim ;
esttab matrix(countCP) using "$output\11 balance CP.tex", 
nomtitle
prehead(\begin{tabular}{llcccccc})
postfoot(\hline \end{tabular}) 
replace
;
#delim cr

matrix countCP_reorder = J(28, 6, 0)
forvalues i = 1/28 {
	matrix countCP_reorder[`i', 1] = countCP[`i', 2]
	matrix countCP_reorder[`i', 2] = countCP[`i', 1]
	matrix countCP_reorder[`i', 3] = countCP[`i', 3]
	matrix countCP_reorder[`i', 4] = countCP[`i', 4]
	matrix countCP_reorder[`i', 5] = countCP[`i', 5]
	matrix countCP_reorder[`i', 6] = countCP[`i', 6]
}
matrix countVGCP = countVG, countCP_reorder
matrix colnames countVGCP = "& Algorithm" "Discretion" "Overlap" "Total" "Algorithm" "Random" "Discretion" "Overlap" "Replacement" "Total"

#delim ;
esttab matrix(countVGCP) using "$output\11 balance VG CP.tex", 
nomtitle
prehead(\begin{tabular}{llcccccccccc} \hline & & \multicolumn{4}{c}{Full audits} & \multicolumn{6}{c}{Desk audits} \\ \cline{3-6} \cline{7-12})
postfoot(\hline \end{tabular}) 
replace
;
#delim cr

**********************************************************
**********************************************************
*AUDIT PROBABILITIES
**********************************************************
**********************************************************

use "$analysisdata/datasetforanalysis.dta", clear

cap drop meanturnover 
egen meanturnover = rowmean(turnover2017 turnover2018 turnover2019 turnover2020)
sum meanturnover if meanturnover  >0, d 

egen meanliability = rowmean(CGU_liability* IS_liability* VAT_liability* PAYE_liability*)
sum meanliability if meanliability  > 0, d 

bys firmid typedecontrole_selection: gen n = _n
keep if n == 1  
drop n 

*****************************
*Selection of Audits graphs 
*****************************
preserve 

	set scheme tab1 

	gen decile_turnover = . 
	forvalues b = 1/4 {
		xtile tempdec = meanturnover if meanturnover > 0 & groupbureau == `b' , nq(10)
		replace decile_turnover = tempdec if groupbureau == `b'
		drop tempdec 
	}

	gen decile_liability = . 
	forvalues b = 1/4 {
		xtile tempdec = meanliability if meanliability > 0 & groupbureau == `b' , nq(10)
		replace decile_liability = tempdec if groupbureau == `b'
		drop tempdec 
	}

	br if meanturnover == 0 
	br groupbureau

	gen selectedforVG = typedecontrole_selection == "VG" & selection == 1
	gen selectedforCP = typedecontrole_selection == "CP" & selection == 1

	bys firmid: egen selectVG = max(selectedforVG)
	bys firmid: egen selectCP = max(selectedforCP)

	bys firmid: gen n = _n 
	keep if n == 1
	drop n 

	*****************************
	*Select sample
	*****************************
	replace decile_turnover = 0 if decile_turnover == . 
	collapse (mean) selectVG selectCP meanturnover (count) count = selectionyear, by(decile_turnover groupbureau)

	replace meanturnover = log(meanturnover)

	replace selectVG = 100*selectVG
	replace selectCP = 100*selectCP


	#delim ;
	tw
	(scatter selectVG meanturnover if groupbureau == 4, msize(large)) (line selectVG meanturnover if groupbureau == 4, lwidth(thick)) 
	(scatter selectVG meanturnover if groupbureau == 3, msize(large)) (line selectVG meanturnover if groupbureau == 3, lwidth(thick)) 
	(scatter selectVG meanturnover if groupbureau == 2, msize(large)) (line selectVG meanturnover if groupbureau == 2, lwidth(thick)) 
	(scatter selectVG meanturnover if groupbureau == 1, msize(large)) (line selectVG meanturnover if groupbureau == 1, lwidth(thick)) 
	,
	xtitle(log(turnover))
	legend(order(1 "SME" 3 "Liberal" 5 "MTU" 7 "LTU") size(medium))
	ytitle(%)
	title("")
	;
	#delim cr

	graph export "$output/14 descriptive VG selection.pdf", as(pdf) replace

	#delim ;
	tw
	(scatter selectCP meanturnover if groupbureau == 4, msize(large)) (line selectCP meanturnover if groupbureau == 4, lwidth(thick)) 
	(scatter selectCP meanturnover if groupbureau == 3, msize(large)) (line selectCP meanturnover if groupbureau == 3, lwidth(thick)) 
	(scatter selectCP meanturnover if groupbureau == 2, msize(large)) (line selectCP meanturnover if groupbureau == 2, lwidth(thick)) 
	(scatter selectCP meanturnover if groupbureau == 1, msize(large)) (line selectCP meanturnover if groupbureau == 1, lwidth(thick)) 
	,
	xtitle(log(turnover))
	legend(order(1 "SME" 3 "Liberal" 5 "MTU" 7 "LTU") size(medium))
	ytitle(%)
	title("")
	;
	#delim cr

	graph export "$output/14 descriptive CP selection.pdf", as(pdf) replace

restore 


*********************
*Implementation Audits 
*********************
preserve 
	
	keep if selection == 1 
	set scheme tab1 

	gen decile_turnover = . 
	forvalues b = 1/4 {
		xtile tempdec = meanturnover if meanturnover > 0 & groupbureau == `b' , nq(10)
		replace decile_turnover = tempdec if groupbureau == `b'
		drop tempdec 
	}

	gen decile_liability = . 
	forvalues b = 1/4 {
		xtile tempdec = meanliability if meanliability > 0 & groupbureau == `b' , nq(10)
		replace decile_liability = tempdec if groupbureau == `b'
		drop tempdec 
	}

	gen hadVG= y2 == 1 & x2 == 1  if selection == 1 & typedecontrole_selection == "VG"
	gen hadCP =  y2 == 1 & x2 == 0  if selection == 1 & typedecontrole_selection == "CP"
	bys firmid: egen auditVG = max(hadVG)
	bys firmid: egen auditCP = max(hadCP)

	bys firmid: gen n = _n 
	keep if n == 1
	drop n 

	*****************************
	*Select sample
	*****************************
	replace decile_turnover = 0 if decile_turnover == . 
	collapse (mean)  auditVG auditCP meanturnover (count) count = selectionyear, by(decile_turnover groupbureau)

	replace meanturnover = log(meanturnover)

	replace auditVG = 100*auditVG
	replace auditCP = 100*auditCP


		#delim ;
		tw
		(scatter auditVG meanturnover if groupbureau == 4, msize(large)) (line auditVG meanturnover if groupbureau == 4, lwidth(thick)) 
		(scatter auditVG meanturnover if groupbureau == 3, msize(large)) (line auditVG meanturnover if groupbureau == 3, lwidth(thick)) 
		(scatter auditVG meanturnover if groupbureau == 2, msize(large)) (line auditVG meanturnover if groupbureau == 2, lwidth(thick)) 
		(scatter auditVG meanturnover if groupbureau == 1, msize(large)) (line auditVG meanturnover if groupbureau == 1, lwidth(thick)) 
		,
		xtitle(log(turnover))
		legend(order(1 "SME" 3 "Liberal" 5 "MTU" 7 "LTU") size(medium))
		ytitle(%)
		title(VG audit)
		;
		#delim cr

		graph export "$output/14 descriptive VG audit.pdf", as(pdf) replace

		#delim ;
		tw
		(scatter auditCP meanturnover if groupbureau == 4, msize(large)) (line auditCP  meanturnover if groupbureau == 4, lwidth(thick)) 
		(scatter auditCP  meanturnover if groupbureau == 3, msize(large)) (line auditCP  meanturnover if groupbureau == 3, lwidth(thick)) 
		(scatter auditCP  meanturnover if groupbureau == 2, msize(large)) (line auditCP  meanturnover if groupbureau == 2, lwidth(thick)) 
		(scatter auditCP  meanturnover if groupbureau == 1, msize(large)) (line auditCP  meanturnover if groupbureau == 1, lwidth(thick)) 
		,
		xtitle(log(turnover))
		legend(order(1 "SME" 3 "Liberal" 5 "MTU" 7 "LTU") size(medium))
		ytitle(%)
		title(CP audit)
		;
		#delim cr

		graph export "$output/14 descriptive CP audit.pdf", as(pdf) replace

restore 


**************
*Show that firm characteristics do not matter for the position of the firm 
**************
keep if algorithm + dgid == 1 

*Create for each inspector three groups (up, middle, bottom) 
egen idinsp = group(inspectorclusteryear)

gen position = . 
sum idinsp
forvalues x = 1/`r(max)' {
	
	xtile t = sequencing if idinsp == `x', nq(3)
	replace position = t if idinsp == `x'
	drop t
}

*Regression
local k = 0 
foreach predict in algorithm x x3 profitrate  {

local ++k		
	replace `predict' = 0 if `predict' == . 	
		
	eststo r`k': reghdfe 1.position `predict', a(inspectorclusteryear) vce(cluster inspectorclusteryear)

			qui sum 1.position if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			
	eststo r`k'_2: reghdfe 2.position `predict', a(inspectorclusteryear) vce(cluster inspectorclusteryear)

			qui sum 2.position if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'			

}

*Export table

#delim ;
esttab r1* r2* r3* r4*
		using "$output\12 regression balancing test position.tex",
		order(algorithm x x3 profitrate )
		label se keep(algorithm x x3 profitrate )
		mtitles("P(top)" "P(middle)" "P(top)" "P(middle)" "P(top)" "P(middle)" "P(top)" "P(middle)") 
		s(N r2 pp, label("\hline N" "R2" "Mean outcome" )) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(algorithm "Algorithm case" x "log(Mean Turnover)" x3 "log(Mean Tax Liability)" profitrate "Profit rate")
		prehead("\begin{tabular}{lrrrrrrrr} \hline \hline \\") 
		posthead(\hline) postfoot("\hline \end{tabular}")
		replace
		substitute(\_ _)
	;
#delim cr

*******************************************************************
*******************************************************************
*CHARACTERISITCS OF SELECTED AND NON SELECTED
*******************************************************************
*******************************************************************

use "$analysisdata/datasetforanalysis.dta", clear

tab selectionmethod 

estimates drop  _all

*****************************
*Select sample
*****************************

*Generate a variable that is the difference between a notification and the previous one for the same inspector  
replace dgid = 1 if overlap == 1 
replace algorithm = 1 if random  == 1 
replace algorithm = 0 if safeties == 1 

**********************************
*List of outcomes to be investigated
**********************************
foreach v of varlist *filed* {
	replace `v' = 0 if `v' == .
}

*Turn to missing if no filing 
forvalues y = 2014/2020 {
	egen filesomething = rowmax(*filed`y')
	replace turnover`y' = . if filesomething == 0
	drop filesomething
	
	replace profitrate`y' = . if IS_filed`y' == 0
	replace payroll`y' = . if RAS_IRPP_filed`y' == 0 
}

*Turnover one year before audit 
gen turnover_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace turnover_L1 = turnover`L1' if selectionyear == `y'
	
}

*Profit one year before audit
gen profitrate_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace profitrate_L1 = profitrate`L1' if selectionyear == `y'
	
}

*Payroll one year before audit
gen payroll_L1 = . 

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace payroll_L1 = payroll`L1' if selectionyear == `y'
	replace payroll_L1 = . if RAS_IRPP_filed`L1' == 0 & selectionyear == `y'	
	
}

*Firm traded with foreign countries one year before audit
gen trade_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	egen TRADE`L1' = rowmax(IMP_filed`L1' EXP_filed`L1')
	replace trade_L1 = TRADE`L1' if selectionyear == `y'
	
}

*Firm received money from governoment one year before audit
gen procurement_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace procurement_L1 = MAN_filed`L1' if selectionyear == `y'
	
}

*Material costs
gen materialcosts_L1 = .

forvalues y = 2018/2020 {
	
	local L1 = `y' - 1
	replace materialcosts_L1 = material_inp`L1' if selectionyear == `y'
	
}

*Drop outliers
sum distance, d 
replace distance = . if distance >= `r(p99)' & distance != . 
gen logdistance  = log(distance)

sum materialcosts_L1, d 
replace materialcosts_L1 = `r(p99)' if materialcosts_L1 >= `r(p99)' & materialcosts_L1 != . 
gen logmaterialcosts_L1 = log(materialcosts_L1 + 1)

sum durationcar, d 
replace durationcar = . if durationcar >= `r(p99)' & durationcar != . 
cap drop logdurationcar
gen logdurationcar = log(durationcar)

sum durationcar, d 
gen longduration = durationcar >= `r(p50)' & durationcar != . 

sum payroll_L1, d 
replace payroll_L1 = `r(p99)' if payroll_L1 >= `r(p99)' & payroll_L1 != . 
gen logpayroll_L1 = log(payroll_L1 + 1)

sum turnover_L1, d 
replace turnover_L1 =  `r(p99)' if turnover_L1 >= `r(p99)' & turnover_L1 != . 
gen logturnover_L1 = log(turnover_L1 + 1)

sum profitrate_L1, d 
replace profitrate_L1 = `r(p99)' if profitrate_L1 >= `r(p99)' &  profitrate_L1 != .
replace profitrate_L1 = `r(p1)' if  profitrate_L1 < `r(p1)'
 
gen logturnover2017 = log(turnover2017 + 1)
replace logturnover2017 = log(turnover2016 + 1) if logturnover2017 == . | logturnover2017 == 0 
replace logturnover2017 = log(turnover2015 + 1) if logturnover2017 == . | logturnover2017 == 0 
replace logturnover2017 = log(turnover2014 + 1) if logturnover2017 == . | logturnover2017 == 0 

gen logpayroll2017 = log(payroll2017 + 1)
replace logpayroll2017 = log(payroll2016 + 1) if logpayroll2017 == . | logpayroll2017 == 0 
replace logpayroll2017 = log(payroll2015 + 1) if logpayroll2017 == . | logpayroll2017 == 0 
replace logpayroll2017 = log(payroll2014 + 1) if logpayroll2017 == . | logpayroll2017 == 0 

gen profitrate_2017 = profitrate2017
replace profitrate_2017 = log(profitrate2016 + 1) if profitrate_2017 == . | profitrate_2017 == 0 
replace profitrate_2017 = log(profitrate2015 + 1) if profitrate_2017 == . | profitrate_2017 == 0 
replace profitrate_2017 = log(profitrate2014 + 1) if profitrate_2017 == . | profitrate_2017 == 0 

egen trade2017 = rowmax(IMP_filed2017 IMP_filed2016 IMP_filed2015 IMP_filed2014 EXP_filed2017 EXP_filed2016 EXP_filed2015 EXP_filed2014)

**********************************
*Regression table
**********************************
global characteristic "logturnover_L1 logpayroll_L1 profitrate_L1 trade_L1 durationcar firmage  q3 q5 q15"

clonevar originalselection = selection
drop selection

local c = 0 
estimates drop _all

forvalues controltype = 1/2 {

	gen selection = controle == `controltype'

		foreach outcome of varlist $characteristic {

		local ++c

		*Specification for CP with inspector x year FE 
					eststo r`c': reghdfe `outcome' algorithm overlap random safeties if selection == 1, a(inspectorclusteryear) vce(robust)
					
					estadd local taxcenteryear "Yes"
					estadd local inspectoryear "Yes"
					estadd local turnoverdeciles "No"			
					estadd local activity "No"			
					
					qui sum `outcome' if e(sample)==1 
					estadd local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome = int(100*`r(mean)')/100
					local meanoutcome : di %5.2f `meanoutcome'
					estadd local pp `meanoutcome'
					test algorithm == random
					local pvalue : di %5.2f `r(p)'
					estadd local pvalue = round(`pvalue', 0.01)
					qui unique firmid if e(sample)==1 
					estadd local uniquefirms = 	r(unique) 		
			estadd local N = e(N)	, replace					

		} 

		
		local keepvar1 "algorithm overlap random"
		local keepvar2 "algorithm overlap"
		
		*Summary results for selected firms 
		#delim ;
		esttab r*
				using "$output\13 characteristics of selection `controltype'.tex",
				order( algorithm overlap random )
				label se keep(`keepvar`controltype'')
				nomtitles nonumber 
				s(N r2 pp, label("N"  "R2" "Mean outcome")) 
				star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
				b(%5.2f) se(%5.2f) coeflabels(overlap "Inspectors x Overlap" algorithm "Algorithm" random "Algorithm x Random" safeties "Replacement" norm_sequencing "Norm. Position on List" norm_sequencing2 "Norm. Position Squared")
				prehead("") 
				posthead("") postfoot("\bottomrule")
				replace
				substitute(\_ _)
			;
		#delim cr

		
	preserve 
	
		bys firmid: egen selection_years = max(selection)

		*Drop duplicates 
		bys firmid: gen n = _n
		keep if n == 1 
		drop n
				
		drop firmage 
		gen firmage = 2017 - year_creation	
				
		local c = 0 
		estimates drop _all
		
		foreach outcome in logturnover2017 logpayroll2017 profitrate_2017 trade2017  durationcar firmage q3 q5 q15 {
			
			*Specification for CP with inspector x year FE 
			eststo s`outcome': reghdfe `outcome' selection_years, a(bureau) vce(cluster bureau)
			
			estadd local taxcenteryear "Yes"
			estadd local inspectoryear "Yes"
			estadd local turnoverdeciles "No"			
			estadd local activity "No"			
			
			qui sum `outcome' if e(sample)==1 
			estadd local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome = int(100*`r(mean)')/100
			local meanoutcome : di %5.2f `meanoutcome'
			estadd local pp `meanoutcome'
			qui unique firmid if e(sample)==1 
			estadd local uniquefirms = 	r(unique) 
			estadd local N = e(N)	, replace					
			
		}
		
		*Summary results for whole sample
		#delim ;
		esttab slogturnover2017 slogpayroll2017 sprofitrate_2017 strade2017 sdurationcar sfirmage sq3 sq5 sq15
			using "$output\13 characteristics of selection inspector whole sample `controltype'.tex",
			order(selection_years)
			label se keep(selection_years)
			nomtitles nonumber 
			s(N r2 pp, label("N" "R2" "Mean outcome")) 
			star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
			b(%5.2f) se(%5.2f) coeflabels(selection_years "Inspectors' Selection")
			prehead("") 
			posthead("") postfoot("\bottomrule")
			replace
			substitute(\_ _)
			;
		#delim cr

		restore 
		
	drop selection	
}

*********************************************************************************
*FIGURE 1
*********************************************************************************
	use "$rawdata\Inspector survey data and analysis\stata\proc/base_finale_2_En.dta", clear	

*************************************************************
* FIGURE A2 in the paper 
*************************************************************	
*************************************************************
* Objective of Audits 
*************************************************************	
	************
	*Module III*
	************
	
	*Adjust the scale from 0 to 1 to 1 to 100
	gen Prob_Diversity_Audits_100 = Prob_Diversity_Audits * 100
	gen Prob_Return_100 = Prob_Return * 100
	gen Prob_Detected_Evasion_100 = Prob_Detected_Evasion * 100
	gen Prob_N_Audits_100 = Prob_N_Audits * 100
	gen Prob_Penalties_100 = Prob_Penalties * 100

	*Probabiblity to be one of the top two most importnat objectives 
		#delim ; 
		graph bar (mean) Prob_Diversity_Audits_100 Prob_Return_100 Prob_Detected_Evasion_100 Prob_N_Audits_100 Prob_Penalties_100, bargap(80)  
		nofill showyvars 
		yvaroptions(relabel(1 "Diverse Audit Types" 2 "Max. Audit Return" 3 "Max. Evasion Rate" 4 "Number of Audits" 5 "Max. Penalties") label(angle(45))) 
		ytitle("% of Inspectors Reporting Objective Among Top 2", size(3.2))  
		ylabel(, angle(0) format(%10.0gc) labsize(medsmall))  
		graphregion(ic(white) fc(white) lc(white)) plotr(ic(white)  fc(white) lc(white)) ylab(, nogrid)   
		bar(1, color(blue*1)) bar(2, color(blue*0.6)) bar(3, color(ebg))
		bar(4, color(ltblue*1.1)) bar(5, color(ltblue*0.7)) bar(6, color(lavender))  
		legend(off)  ; 
		
	#delim cr	
		
		graph save "$output/IS_audit_objectives.gph", replace
		graph export "$output/IS_audit_objectives.pdf", replace
		graph export "$output/IS_audit_objectives.png", replace
		
	
	* Remove variables created to construct the graph	
	drop Prob_Diversity_Audits_100 Prob_Return_100 Prob_Detected_Evasion_100 Prob_N_Audits_100 Prob_Penalties_100

		
		
	/* Other goals mentioned in the open question: 	(mod3_q4_b)
	- Pedgagoy 
	- Ensure a minimum amount of recovery
	- With Some taxpayers know that audit will be difficult  
														*/ 
	
	*********************************************************************************
	*	Tradeoff/crossing point between return and amount 
	*********************************************************************************
	** Where is the revealed tradeoff between the two:
	** Classify everyone between 0 and 1 in the tradeoff (See my past notes on this) 

	use "$rawdata\Inspector survey data and analysis\stata\proc/base_finale_2_En.dta", clear	
	
		** Drop inspectors saying they dont know because not currently controlling

	drop if inlist(ID,1,9,40)
	
	local vlist mod3_q5_a_2_d1 mod3_q5_2_2_d1 mod3_q5_3_2_d1 mod3_q5_4_2_d1 mod3_q5_5_2_d1
	foreach var of local vlist {
		tab `var' 
		}	
	
	** 26, 17, 18, 8, 16, 9 
	
	clear 
	set obs 5 
	gen id = _n 
	
	gen evasion_amount = -10 if id == 1
	replace evasion_amount = -0 if id == 2
	replace evasion_amount = 7 if id == 3
	replace evasion_amount = 15 if id == 4
	replace evasion_amount = 22.5 if id == 5

	gen density = 0 
	gen cum_density = 0
	
	local i = 0
	
	foreach k in 26 17 18 8 16 {
		local i = `i'+1
		display `i'
		replace density = `k' / 94  if id == `i'
		replace cum_density = density[`i']  if id == `i'
		replace cum_density = density[`i'] + cum_density[`i'-1]  if id == `i'	& id != 1	
		}
	
	
	replace cum_density = cum_density * 100			
		
	#delim ; 
	twoway  scatter cum_density evasion_amount, msymbol(Oh) msize(large) ||
	lowess cum_density evasion_amount, lc(blue) ,  
	    text(25.75 -10.8

        "`=ustrunescape("\u23A7")'" /* RCB UPPER HOOK   */
        "`=ustrunescape("\u23AA")'" /* RCB EXTENSION    */
        "`=ustrunescape("\u23A8")'" /* RCB MIDDLE PIECE */    
        "`=ustrunescape("\u23AA")'" /* RCB EXTENSION    */
        "`=ustrunescape("\u23A9")'" /* RCB LOWER HOOK   */

        , size(7.6)  color(red)
    )
	text(24 -11.2 "Always select larger", color(red) place(nw) size(3))
	text(24 -11.2 "firms (45.7%)", color(red) place(sw) size(3))
text( 72 -0.6

        "`=ustrunescape("\u23A7")'" /* LCB UPPER HOOK   */
		"`=ustrunescape("\u23AA")'" /* RCB EXTENSION    */
        "`=ustrunescape("\u23A8")'" /* LCB MIDDLE PIECE */
		"`=ustrunescape("\u23AA")'" /* RCB EXTENSION    */
        "`=ustrunescape("\u23A9")'" /* LCB LOWER HOOK   */  
        
        , size(7.2) color(purple)
    )
	


	text(72 -1 "Trade-off evasion amount", place(nw) size(3) color(purple))
	text(72 -1 "vs evasion rate (44.7%)", place(sw) size(3) color(purple))
    text( 97.6 22.3

        "`=ustrunescape("\u23A7")'" /* RCB UPPER HOOK   */
        "`=ustrunescape("\u23A8")'" /* RCB MIDDLE PIECE */
        "`=ustrunescape("\u23A9")'" /* RCB LOWER HOOK   */  

        , size(2.5) color(green)

    )
	
	text(96.7 21.7 "Always select", place(nw) color(green) size(3))
	text(96.7 21.7 "smaller firms (9.6%)", place(sw) color(green) size(3))


	yscale(range(0 100) titlegap(3))
	ytitle("% of Inspectors Choosing to Audit Larger Firms", size(4))
	ylabel(0(25)100, nogrid labsize(medsmall)) 
	yline(50, lcolor(black) lpattern(dash)) 
	xtitle("")
	xscale(range(-22 25))
	xla(-22 `" "Dif. Evaded Amount" "Dif. Rate of Evasion" "' -10 `" "-10 M" "[-30%]" "' 
	-0 `" "0 M" "[-25%]" "' 7 `" "+7 M" "[-20%]" "' 15 `" "+15 M" "[-13%]" "' 22.5 `" "+22.5 M" "[0%]" "', labsize(medsmall) tlc(none)) 
	legend(off)
	graphregion(color(white)); 
	
	#delim cr
	
	graph save "$output/IS_evasion_rate_tradeoff.gph", replace
	graph export "$output/IS_evasion_rate_tradeoff.pdf", replace	
	graph export "$output/IS_evasion_rate_tradeoff.png", replace		
	
	*********************************************************************************
	*	Type of information used: Spread into three panels 
	*********************************************************************************
		
	** For figures we will transform all variables on the frequency of use into 0 to 100
	* In the data they go from 0 (never use) to 4 (always use): so the goal is to multiply everuything by 25 and then divide by 100

	* Colors: 
	/*		
	bar(1, color(ltblue*1*1)) bar(2, color(ltblue*0.5)) bar(3, color(ltblue*1.8)) 
		bar(4, color(ltblue*1.3)) bar(5, color(ltblue*0.8))  bar(6, color(ebg)) 
		bar(7, color(blue)) bar(9, color(midblue)) bar(10, color(lavender)) 
		*/ 
	
	use "$rawdata\Inspector survey data and analysis\stata\proc/base_finale_2_En.dta", clear	

	*******************
	* Self-reports
	*******************
	
	local vlist mod6_q5_1  mod6_q5_2  mod6_q5_3  
	foreach var of local vlist {
		tab `var' 
		}
		foreach var of local vlist {
		sum `var' 
		}	
		
	local vlist mod6_q5_1  mod6_q5_2  mod6_q5_3  
	foreach var of local vlist {
		replace `var' = `var' * 25 
		}	

	#delim ; 
	
	graph bar (mean) mod6_q5_1  mod6_q5_3 mod6_q5_2  , 
		bargap(80)   nofill 
		showyvars yvaroptions(relabel(1 "CIT & VAT" 2 "Balance sheet" 3 "Wage withholding" ) 
		label(angle(45) labsize(*1))) 
		ytitle("% of Inspectors Using Information", size(4.5))  
		ylabel(0(20)100, angle(0) format(%10.0gc) labsize(medlarge)) 	
		ylab(, nogrid) 
		note("Self-Reports", size(medlarge) position(6))  
		graphregion(ic(white) fc(white) lc(white)) plotr(ic(white)  fc(white) lc(white)) 
		bar(1, color(gs4)) bar(2, color(gs9)) bar(3, color(gs13)) 
		legend(off)  
		name(G1, replace); 
		
	#delim cr	
		
// 	graph save "$graphs\Graphpre_Mod6q5_dir", replace
// 	graph export "$graphs\Graphpre_Mod6q5_dir.pdf", replace

	// 4 "VAT Annex"

	
	*******************
	* third_party_data
	*******************	
	
	local vlist mod6_q5_8 mod6_q5_9  mod6_q5_10 mod6_q5_11 mod6_q5_12  mod6_q5_13 
	foreach var of local vlist {
		tab `var' 
		}	
	foreach var of local vlist {
		sum `var' 
		}
		
	local vlist  mod6_q5_8 mod6_q5_9  mod6_q5_10 mod6_q5_11 mod6_q5_12  mod6_q5_13 
	foreach var of local vlist {
		replace `var' = `var' * 25
		}		
		
	#delim ; 	
		
	graph bar (mean) mod6_q5_13  mod6_q5_11 mod6_q5_8  mod6_q5_12  mod6_q5_10 mod6_q5_9 , 
		bargap(80)  nofill showyvars 
		bar(1, color(blue*1.3)) bar(2, color(blue*0.8))
		bar(3, color(blue*0.4)) bar(4, color(ltblue*1.2)) bar(5, color(ltblue*0.8)) bar(6, color(ltblue*0.4)) 
		yvaroptions(relabel(1 "B2B payments" 2 "Contract registry" 3 "VAT Annexes" 4 "Customs" 5 "Collection unit" 6 "Procurement" ) 
		label(angle(45) labsize(*1))) 
		ylabel(0(20)100,  tlength(0) nogrid glcolor(no) labcolor(white) tlcolor(white)  angle(0) format(%10.0gc) labsize(medlarge))  
		graphregion(ic(white) fc(white) lc(white)) plotr(ic(white)  fc(white) lc(white)) 
		note("Third-Party", size(medlarge)  position(6))
		legend(off) 
		name(G2, replace); 
		
	#delim cr
	
// mod6_q5_14
	
	*******************
	* Soft data 
	*******************	
	
	local vlist mod6_q5_4  mod6_q5_5  mod6_q5_6  mod6_q5_7  mod6_q5_15  mod6_q5_14
	foreach var of local vlist {
		tab `var' 
		}	
	foreach var of local vlist {
		sum `var' 
		}
		
	local vlist  mod6_q5_4  mod6_q5_5  mod6_q5_6  mod6_q5_7  mod6_q5_15  mod6_q5_14
	foreach var of local vlist {
		replace `var' = `var' * 25 
		}		
	
	#delim ; 	
	
	graph bar (mean) mod6_q5_5 mod6_q5_4  mod6_q5_6 mod6_q5_14  mod6_q5_15 mod6_q5_7   ,  
		bargap(80)  nofill showyvars 
		bar(1, color(dkgreen*1.2)) bar(2, color(dkgreen*0.8)) bar(3, color(dkgreen*0.4)) 
		bar(4, color(green*0.4)) bar(5, color(lime*0.8))  bar(6, color(lime*0.4)) 
		yvaroptions(relabel(1 "Colleagues" 2 "Field Observations" 3 "News" 4 "Denunciations" 5 "Firm Reputation" 6 "Rumors") 
		label(angle(45) labsize(*1)) )	
		ylabel(0(20)100,  tlength(0) nogrid glcolor(no) labcolor(white) tlcolor(white) angle(0) format(%10.0gc) labsize(medlarge))  	
		graphregion(ic(white) fc(white) lc(white)) plotr(ic(white)  fc(white) lc(white))  	 
		note("Soft Information", size(medlarge) position(6)) 
		legend(off) 	
		name(G3, replace); 

	#delim cr 	

	** COMBINED FIGURE: 		
	graph  combine G1 G2 G3, imargin(tiny) xcommon  col(3) 	graphregion(ic(white) fc(white) lc(white)) plotr(ic(white)  fc(white) lc(white)) 
	
	
	graph save "$output/IS_Data_Used_for_Selection.gph", replace
	graph export "$output/IS_Data_Used_for_Selection.pdf", replace
	graph export "$output/IS_Data_Used_for_Selection.png", replace


