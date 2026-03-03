*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   October 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

**# Objective
*  Plot by deciles of evasion the number of inspectors and average duration of cases 


*Set-up
set scheme stcolor
set more off
clear all 

global check = 1 // to save outside official replication folder
*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","49354415") { 										// Alipio's computer
		global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}
	
	if strpos("`c(username)'","wb648862") { 										// Roldan's computer
		global rootdir "C:\Users\wb648862\Dropbox\Senegal tax audits"
	}
	
	
	if $check == 1 {
	global output "C:\Users\User\OneDrive\World Bank\Senegal-Tax-Audit\Output"
	}
	di "$output"
	
/*	
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits"				// Insert path to shared Dropbox folder "Senegal Tax Audits"
	}
*/	
		global ados "$rootdir\Analysis all data\replication_package\ado"
		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		
		if $check == 1 {
	global output "C:\Users\wb648862\OneDrive - WBG\Documents\GitHub\Senegal-Tax-Audit\Output"
	}
	di "$output"

*****
set seed 12342345
*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   March 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*This script creates summary statistics
local date: disp  c(current_date)
di "`date'"
set scheme s1color


******************************************
******************************************
*2 ANALYZE INSPECTOR CHARACTERISTICS 
******************************************
******************************************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all

*****************************
*Select sample
*****************************
keep if selection == 1  
drop if safeties == 1

******************
*Add appropriate information about inspectors
******************

*Add information on the inspectors that carried out the case
preserve 
		
*		replace verificateur1 = verificateur_selection if typedecontrole_selection == "CP"
		
*		drop verificateur_selection
		
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
		
		drop selection groupbureau codeinspector
		
		*Add data on inspector characteristics
		merge m:1 verificateur using "$analysisdata/inspectorsurvey"
		
		*Create variables 
		gen answeredsurvey = _merge == 3
		drop _merge 
		
		clonevar yearsexperience = mod1_q3 
		clonevar education = mod2_q1 
		clonevar enthusiasmalgorithm =  mod7_q4_e

		bys firmid selectionyear controle: gen numberagents = _N
		
		gen years_cat = 1 if yearsexperience > 0 & yearsexperience <= 5 
		replace years_cat = 2 if yearsexperience > 5 & yearsexperience <= 10 
		replace years_cat = 3 if yearsexperience > 10 

		gen education_cat1 = mod2_q1 == 1  if mod2_q1 != . 
		gen education_cat2 = education == 7 | education == 2 | education == 3  if mod2_q1 != . 
		gen education_cat3 = education == 4  if mod2_q1 != . 
		gen education_cat4 = education == 5 if mod2_q1 != . 

		gen education_cat = . 
		forvalues x = 1/4 {
			replace education_cat = `x' if education_cat`x' == 1 
		}
		
		gen mastersphd = education_cat3 == 1 | education_cat4 == 1
		replace mastersphd = . if mod2_q1 == . 

		gen age_cat = .
		replace age_cat = 1 if age <= 30
		replace age_cat = 2 if age > 30 & age <= 40 
		replace age_cat = 3 if age > 40 & age != .

		gen enthusiasm = enthusiasmalgorithm == 3 if enthusiasmalgorithm != .
		gen monthsexperience = 12*mod1_q3 + mod1_q3_b

		bys verificateur: gen n = _n
		sum monthsexperience if n == 1, d
		gen highexperience = monthsexperience > r(p50) if monthsexperience != .
		drop n
		
		gen agevariable = age != . 
		
		collapse (count) answered_education = education_cat answered_enthusiasm = enthusiasmalgorithm answered_experience = monthsexperience (sum) answeredsurvey agevariable (mean)  mastersphd meanage = age yearsexperience monthsexperience highexperience enthusiasm numberagents education_cat* (median) medianage = age medianyearsexperience = yearsexperience (max) maxyearsexperience = yearsexperience maxage = age maxedu = education_cat, by(firmid selectionyear controle)
		
		ds firmid selectionyear controle, not
		foreach v in `r(varlist)' {
			
			label var `v' "Inspector survey information"
			
		}
		
		tempfile inspectors 
		sa `inspectors', replace 
		
restore 

cap noisily drop mastersphd age yearsexperience monthsexperience enthusiasm numberagents medianage medianyearsexperience maxyearsexperience maxage maxedu

merge m:1 firmid selectionyear controle using `inspectors'
drop if _merge == 2 
drop _merge 

*Add information on the inspectors within the tax office (for selection of full audits)
preserve
	
	keep if x2 == 1
	drop verificateur_selection

	keep bureauclusteryear verificateur*
	
	egen group = group(verificateur*), missing
	bys bureauclusteryear group: gen n = _n 
	keep if n == 1 
	drop n	
	
	reshape long verificateur, i(bureauclusteryear group) j(number)
	drop if verificateur == ""
	drop number 	
	drop group
	
	*Add data on inspector characteristics
	merge m:1 verificateur using "$analysisdata/inspectorsurvey"	
	drop _merge 
	
	bys bureauclusteryear: gen numberagents_bureau = _N

	gen education_cat1 = mod2_q1 == 1  if mod2_q1 != . 
	gen education_cat2 = mod2_q1 == 7 | mod2_q1 == 2 | mod2_q1 == 3  if mod2_q1 != . 
	gen education_cat3 = mod2_q1 == 4  if mod2_q1 != . 
	gen education_cat4 = mod2_q1 == 5 if mod2_q1 != . 

	gen mastersphd_bureau = education_cat3 == 1 | education_cat4 == 1
	replace mastersphd_bureau = . if mod2_q1 == . 

	gen enthusiasm_bureau = mod7_q4_e == 3 if mod7_q4_e != .
	gen monthsexperience_bureau = 12*mod1_q3 + mod1_q3_b

	bys verificateur: gen n = _n
	sum monthsexperience_bureau if n == 1, d
	gen highexperience_bureau = monthsexperience_bureau > r(p50) if monthsexperience_bureau != .
	drop n
	
	collapse (mean) highexperience_bureau monthsexperience_bureau mastersphd_bureau enthusiasm_bureau age, by(bureauclusteryear)

	tempfile inspectors 
	sa `inspectors', replace 

restore 

merge m:1 bureauclusteryear using `inspectors'
drop if _merge == 2 
drop _merge 

*Add information on the inspectors that selected/were assigned the case (for desk audits)

*Merge with only the inspector of the selection 
clonevar verificateur = verificateur_selection
merge m:1 verificateur using "$analysisdata/inspectorsurvey", update replace 
drop if _merge == 2 

gen answeredsurvey_selection = _merge >= 3
drop _merge 

clonevar yearsexperience_selection = mod1_q3 
clonevar education_selection = mod2_q1 
clonevar enthusiasmalgorithm_selection =  mod7_q4_e

gen years_cat_selection = 1 if yearsexperience_selection > 0 & yearsexperience_selection <= 5 
replace years_cat = 2 if yearsexperience_selection > 5 & yearsexperience_selection <= 10 
replace years_cat = 3 if yearsexperience > 10 

gen education_cat1_selection  = mod2_q1 == 1  if mod2_q1 != . 
gen education_cat2_selection  = mod2_q1 == 7 | mod2_q1 == 2 | mod2_q1 == 3  if mod2_q1 != . 
gen education_cat3_selection  = mod2_q1 == 4  if mod2_q1 != . 
gen education_cat4_selection  = mod2_q1 == 5 if mod2_q1 != . 

gen mastersphd_selection = education_cat3_selection ==1 | education_cat3_selection == 1 
replace mastersphd_selection = . if mod2_q1 == . 

gen age_cat_selection = .
replace age_cat_selection = 1 if age <= 30
replace age_cat_selection = 2 if age > 30 & age <= 40 
replace age_cat_selection = 3 if age > 40 & age != .

gen enthusiasm_selection = enthusiasmalgorithm_selection == 3 if enthusiasmalgorithm != .
gen monthsexperience_selection = 12*mod1_q3 + mod1_q3_b

bys verificateur: gen n = _n

sum age if x2 == 0 & n == 1, d
gen highage_selection = age > r(p50) if x2 == 0

sum monthsexperience if n == 1, d
gen highexperience_selection = monthsexperience_selection > r(p50) & monthsexperience_selection != .
replace highexperience_selection  = . if monthsexperience_selection  == . 
drop n

bys verificateur: gen n = _n
sum age if n == 1, d
gen old_selection = age > r(p50) & age != .
replace old_selection  = . if age  == . 
drop n

clonevar meanage_selection = age
replace  meanage_selection  = . if answeredsurvey_selection == 0

drop verificateur 

drop if safeties == 1

gen all_answeredsurvey = y16 == answeredsurvey & y16  > 0 & y16 != .
gen all_meanage = y16 == agevariable & y16  > 0 & y16 != .
gen all_maxage = y16 == agevariable & y16  > 0 & y16 != .
gen all_mastersphd = y16 == answered_education & y16  > 0 & y16 != .
gen all_enthusiasm = y16 == answered_enthusiasm & y16  > 0 & y16 != .
gen all_highexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_yearsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_monthsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_maxyearsexperience = y16 == answered_experience & y16  > 0 & y16 != .
gen all_maxedu = y16 == answered_education & y16  > 0 & y16 != .


**********************************
**#Desk audits
**********************************
estimates drop _all
*age of firm: firmage
*riskscore

tempfile raw 
save `raw'

keep if x2 == 0  //Only keep desk audits

gen startedalgorithm = algorithm*y2 


*adding firm characterisics
egen turnover_mean = rowmean(turnover2014 turnover2015 turnover2016 turnover2017 turnover2018 turnover2019 turnover2020)
egen nemployees_avg = rowmean(nemployees*)
*gen logs
foreach var of varlist  turnover_mean nemployees_avg firmage {
gen log`var' = log(`var'+1)
}

eststo clear

* Outcomes (columns within each group)
local outcomes  "logturnover lognemployees_avg logfirmage riskscore"

* RHS (rows)
local rhs       "mastersphd_selection highage_selection highexperience_selection"

* Column titles (used in mtitles)
local coltitle_logturnover      "\shortstack{log(Turnover)\\(Mean)}"
local coltitle_lognemployees_avg "\shortstack{log(N. Employees)\\(Mean)}"
local coltitle_logfirmage       "\shortstack{log(Firm age)\\(Mean)}"
local coltitle_riskscore        "\shortstack{Risk score\\(Mean)}"

* Samples (3 groups)
local samples "all alg ins"
local if_all ""
local if_alg "if algorithm==1"
local if_ins "if algorithm==0"

* Labels for mgroups
local glab_all "All"
local glab_alg "Algorithm cases"
local glab_ins "Inspector cases"

* We will store estimation names here in the exact order we want them in the table
local estlist ""
local mtitles ""

*******************************************************
* 2) Loop over samples → collapse → regress outcomes
*******************************************************
foreach s of local samples {

    local cond `if_`s''

    preserve
        * Collapse to inspector-year (or your preferred unit)
        collapse (mean) enthusiasm_selection highexperience_selection highage_selection mastersphd_selection ///
                        logturnover lognemployees_avg logfirmage riskscore ///
                        `cond', ///
                by(inspectorclusteryear verificateur_selection bureauclusteryear selectionyear)

        foreach y of local outcomes {

            * Store: tag_outcome (no spaces!)
            eststo `s'_`y': reghdfe `y' `rhs', absorb(bureauclusteryear) vce(robust)

            * Add stats / flags
            estadd local BureauYearFE "Yes"
			qui su `y' if e(sample), meanonly
			local m : di %5.2f r(mean)
			estadd local meanoutcome "`m'", replace

            * Build ordered lists for esttab
            local estlist "`estlist' `s'_`y'"
            local mtitles `"`mtitles' "`coltitle_`y''""'
        }
    restore
}

*******************************************************
* 3) Export table with 3 column groups
*******************************************************
#delim ;
esttab `estlist' using "$output\2 regression inspector characteristics selection desk audits.tex",
    replace booktabs
    keep(`rhs') order(`rhs')
    nonumbers collabels(none) noomitted noconstant
    b(%5.2f) se(%5.2f)
    star(* 0.10 ** 0.05 *** 0.01)
    mtitles(`mtitles')
    mgroups("`glab_all'" "`glab_alg'" "`glab_ins'",
        pattern(1 0 0 0  1 0 0 0  1 0 0 0)
        span
        prefix(\multicolumn{@span}{c}{) suffix(})
        erepeat(\cmidrule(lr){@span})
    )
    s(N r2 meanoutcome, label("N" "R2" "Mean outcome"))
    coeflabels(
        mastersphd_selection     "Masters/PhD"
        highage_selection        "Above median age"
        highexperience_selection "Above median experience"
    )
    substitute(\_ _)
;
#delim cr


**********************************
**#Full audits - executed cases only 
**********************************
use `raw', clear 

keep if x2 == 1  //Only keep full audits
keep if y2==1

*keep only cases that we know the inspectors that executed them
drop if verificateur_selection==verificateur1
count // 473 cases

*gen startedalgorithm = algorithm*y2 


*adding firm characterisics
egen turnover_mean = rowmean(turnover2014 turnover2015 turnover2016 turnover2017 turnover2018 turnover2019 turnover2020)
egen nemployees_avg = rowmean(nemployees*)
*gen logs
foreach var of varlist  turnover_mean nemployees_avg firmage {
gen log`var' = log(`var'+1)
}


*reshape long with verificateur
keep firmid raisonsociale selectionyear controle bureauclusteryear algorithm y2 y3 y4 ///
verificateur* groupbureau logturnover lognemployees_avg logfirmage riskscore x2  

drop verificateur_selection

* 1) Inspector–case long file
reshape long verificateur, i(firmid raisonsociale selectionyear controle x2 groupbureau) j(slot)
drop if verificateur == ""



*****
* Drop duplicates if same inspector appears twice on same case
****
bys firmid selectionyear verificateur algorithm: keep if _n == 1

* Team size per case + weights (optional but recommended)
bys firmid selectionyear controle: gen k = _N
gen w = 1/k // weighted by the inverse number of agents 


merge m:1 verificateur using "$analysisdata/inspectorsurvey", update replace 

drop if _merge == 2 

gen answeredsurvey_selection = _merge >= 3
drop _merge 

clonevar yearsexperience_selection = mod1_q3 
clonevar education_selection = mod2_q1 
clonevar enthusiasmalgorithm_selection =  mod7_q4_e

gen years_cat_selection = 1 if yearsexperience_selection > 0 & yearsexperience_selection <= 5 
replace years_cat = 2 if yearsexperience_selection > 5 & yearsexperience_selection <= 10 
replace years_cat = 3 if yearsexperience > 10 

gen education_cat1_selection  = mod2_q1 == 1  if mod2_q1 != . 
gen education_cat2_selection  = mod2_q1 == 7 | mod2_q1 == 2 | mod2_q1 == 3  if mod2_q1 != . 
gen education_cat3_selection  = mod2_q1 == 4  if mod2_q1 != . 
gen education_cat4_selection  = mod2_q1 == 5 if mod2_q1 != . 

gen mastersphd_selection = education_cat3_selection ==1 | education_cat3_selection == 1 
replace mastersphd_selection = . if mod2_q1 == . 

gen age_cat_selection = .
replace age_cat_selection = 1 if age <= 30
replace age_cat_selection = 2 if age > 30 & age <= 40 
replace age_cat_selection = 3 if age > 40 & age != .

gen enthusiasm_selection = enthusiasmalgorithm_selection == 3 if enthusiasmalgorithm != .
gen monthsexperience_selection = 12*mod1_q3 + mod1_q3_b

bys verificateur: gen n = _n

sum age if  n == 1, d
gen highage_selection = age > r(p50) if x2 == 1

sum monthsexperience if n == 1, d
gen highexperience_selection = monthsexperience_selection > r(p50) & monthsexperience_selection != .
replace highexperience_selection  = . if monthsexperience_selection  == . 
drop n

bys verificateur: gen n = _n
sum age if n == 1, d
gen old_selection = age > r(p50) & age != .
replace old_selection  = . if age  == . 
drop n

clonevar meanage_selection = age
replace  meanage_selection  = . if answeredsurvey_selection == 0



* If you want a simple count of cases inspector participated in (unweighted):
gen one_case = 1

* 4) Collapse to inspector-year (like your desk audit collapse)
egen inspectorclusteryear_full = group(verificateur selectionyear), label

* team-adjusted sums
gen exec_w = y2*w
gen alg_w  = algorithm*w

eststo clear

* --- outcomes (columns) ---
local outcomes "n_cases logturnover lognemployees_avg logfirmage riskscore"

* --- RHS (rows) ---
local rhs "mastersphd_selection highage_selection highexperience_selection"

* --- Column titles ---
local coltitle_n_cases			"\shortstack{N Cases\\(Unw. Avg.)}"
local coltitle_logturnover       "\shortstack{log(Turnover)\\(W. Avg.)}"
local coltitle_lognemployees_avg "\shortstack{log(Employees)\\(W. Avg.)}"
local coltitle_logfirmage        "\shortstack{log(Firm age)\\(W. Avg.)}"
local coltitle_riskscore         "\shortstack{Risk score\\(W. Avg.)}"

* --- samples (groups) ---
local samples "all alg ins"
local if_all ""
local if_alg "algorithm==1"
local if_ins "algorithm==0"

local glab_all "All"
local glab_alg "Algorithm cases"
local glab_ins "Inspector cases"

* store names for esttab
local estlist ""
local mtitles ""

foreach s of local samples {

    preserve

        *--------------------------------------------
        * 1) Apply sample restriction at CASE level
        *--------------------------------------------
        local cond `if_`s''
        if "`cond'" != "" {
            keep if `cond'
        }

        *--------------------------------------------
        * 2) Collapse to inspector-year level (full audits)
        *    keep your exact collapse structure
        *--------------------------------------------
        collapse  (count) n_cases = one_case /// 
            (mean) y3 y4 logturnover lognemployees_avg logfirmage riskscore ///
            (max)  enthusiasm_selection highexperience_selection highage_selection mastersphd_selection ///
            [aw=w], ///
            by(inspectorclusteryear_full verificateur bureauclusteryear selectionyear)

        *--------------------------------------------
        * 3) Regressions for each outcome
        *--------------------------------------------
        foreach y of local outcomes {

            eststo `s'_`y': reghdfe `y' `rhs', absorb(bureauclusteryear) vce(robust)

            * add mean outcome (formatted, safe)
            qui su `y' if e(sample), meanonly
            local m : di %5.2f r(mean)
            estadd local meanoutcome "`m'", replace

            * (optional) FE flag
            estadd local BureauYearFE "Yes", replace

            * lists for esttab
            local estlist "`estlist' `s'_`y'"
            local mtitles `"`mtitles' "`coltitle_`y''""'
        }

    restore
}

****************************************************
* 4) Export (booktabs + hline under each group header)
****************************************************
#delim ;
esttab `estlist'
    using "$output\2 regression inspector characteristics full audits.tex",
    replace booktabs
    keep(`rhs') order(`rhs')
    nonumbers collabels(none) noomitted noconstant
    b(%5.2f) se(%5.2f)
    star(* 0.10 ** 0.05 *** 0.01)
    mtitles(`mtitles')
    mgroups("`glab_all'" "`glab_alg'" "`glab_ins'",
        pattern(1 0 0 0 0  1 0 0 0 0  1 0 0 0 0)
        span prefix(\multicolumn{@span}{c}{) suffix(})
        erepeat(\cmidrule(lr){@span})
    )
    s(N r2 meanoutcome, label("N" "R2" "Mean outcome"))
    coeflabels(
        mastersphd_selection     "Masters/PhD"
        highage_selection        "Above median age"
        highexperience_selection "Above median experience"
    )
    substitute(\_ _)
;
#delim cr