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

local date: disp  c(current_date)
di "`date'"
set scheme s1color

*********************
*Load dataset for analysis
*********************
use "$analysisdata/datasetforanalysis.dta", clear

estimates drop  _all


*For each year, predict whether firm was selected by DGID based on 
	*whether firm was selecter 1 year earlier, 2 years earlier (only for 2020)
	*whether firm is in top decile of turnover within tax unit 
	*whether firm presented losses 
	*whether firm declared CIT, VAT, CGU, IMP, EXP
	
gsort firmid -controle	
by firmid: gen n = _n 
keep if n == 1 
drop n

drop selection20*

replace droitssimples_confirmation = droitssimples_notification  if droitssimples_confirmation  == . | droitssimples_confirmation   == 0

rename ( ds_2014_notificationTVA ds_2015_notificationTVA ds_2016_notificationTVA ds_2017_notificationTVA ds_2018_notificationTVA ds_2019_notificationTVA ds_2020_notificationTVA ds_2014_notificationIS ds_2015_notificationIS ds_2016_notificationIS ds_2017_notificationIS ds_2018_notificationIS ds_2019_notificationIS ds_2020_notificationIS) ( ds_notificationTVA_2014 ds_notificationTVA_2015 ds_notificationTVA_2016 ds_notificationTVA_2017 ds_notificationTVA ds_2019_notificationTVA_2018 ds_notificationTVA_2020 ds_notificationIS_2014 ds_notificationIS_2015 ds_notificationIS_2016 ds_notificationIS_2017 ds_notificationIS_2018 ds_notificationIS_2019 ds_notificationIS_2020)
		
foreach y in 2018 2019 2020 {
	
gen y2`y' = 0 
replace y2`y' = 1 if y2 == 1 & selectionyear == `y'	& controle == 2 & horsprogramme == 0 
	
gen selection`y' = 0 
replace selection`y' = 1 if selectionyear == `y'
	
gen dgid`y' = 0 
replace dgid`y' = 1 if selectionyear == `y' & dgid == 1 

gen algorithm`y' = 0 
replace algorithm`y' = 1 if selectionyear == `y' & algorithm == 1

gen horsprogramme`y' = 0 
replace horsprogramme`y' = 1 if selectionyear == `y' & horsprogramme == 1 
	
gen audit`y' = 0 
replace audit`y' = 2 if anneeduchrono == `y' & controle == 2
replace audit`y' = 1 if anneeduchrono == `y' & controle == 1

gen droitssimples`y' = droitssimples_confirmation if  anneeduchrono == `y' & controle == 2

}

keep  y220* audit20* selection20* firmid bureau ninea horsprogramme20* dgid20* algorithm20* flag_defaillance20* TVA_filed20* TAF_filed20* RAS_IRPP_filed20* MAN_filed20* IS_filed20* IMP_filed20* EXP_filed20* CGU_filed20* TVAAN_montant_exoneration20* MAN_numberdeclarations20* IMP_numberdeclarations20* EXP_numberdeclarations20* activity_group20* risk_group20* ratio120* ratio220* ratio320* ratioTVA120* ratioTVA220* ratioIS120* ratioIS220* ratioTP120* ratioImportations120* flag_defaillance20* turnover20* payroll20* nemployees20* payroll_turnover20* VAT_credit20* VAT_liability20* IS_liability20* CGU_liability20* PAYE_liability20* year20* labor_inp20* gross_tax_base20* profit20* totalsales20* totalexports20* totalVAT20* VATrate20* material_inp20* totalcosts20* profitrate20* TVAAN_filed20* riskscore* ds_notification* droitssimples*

collapse (max) y220*  audit20* selection20*  horsprogramme20* dgid20* algorithm20* TVA_filed20* TAF_filed20* RAS_IRPP_filed20* MAN_filed20* IS_filed20* IMP_filed20* EXP_filed20* CGU_filed20* TVAAN_montant_exoneration20* MAN_numberdeclarations20* IMP_numberdeclarations20* EXP_numberdeclarations20* activity_group20* risk_group20* ratio120* ratio220* ratio320* ratioTVA120* ratioTVA220* ratioIS120* ratioIS220* ratioTP120* ratioImportations120* flag_defaillance20* turnover20* payroll20* nemployees20* payroll_turnover20* VAT_credit20* VAT_liability20* IS_liability20* CGU_liability20* PAYE_liability20* year20* labor_inp20* gross_tax_base20* profit20* totalsales20* totalexports20* totalVAT20* VATrate20* material_inp20* totalcosts20* profitrate20* TVAAN_filed20* droitssimples20*, by(firmid bureau )

reshape long audit y2 selection  horsprogramme  dgid  algorithm   TVA_filed  TAF_filed  RAS_IRPP_filed  MAN_filed  IS_filed  IMP_filed  EXP_filed  CGU_filed  TVAAN_montant_exoneration  MAN_numberdeclarations  IMP_numberdeclarations  EXP_numberdeclarations  activity_group  risk_group  ratio1  ratio2  ratio3  ratioTVA1  ratioTVA2  ratioIS1  ratioIS2  ratioTP1  ratioImportations1  flag_defaillance  turnover  payroll  nemployees  payroll_turnover  VAT_credit  VAT_liability  IS_liability  CGU_liability  PAYE_liability  year  labor_inp  gross_tax_base  profit  totalsales  totalexports  totalVAT  VATrate  material_inp  totalcosts  profitrate  TVAAN_filed evadedturnover droitssimples, i(firmid bureau) j(value)

drop year
rename value year

gen evasionturnover = droitssimples/0.3
replace evasionturnover = 0 if evasionturnover < 0 

*Winsorize
sum evasionturnover, d 
replace evasionturnover = `r(p99)' if evasionturnover > `r(p99)' & evasionturnover != .

egen id = group(firmid)
xtset id year

*Create share of evasion as percentage of turnover (four yeras for evasion, but take 5 years of turnover, including the current year)
gen evaded4years  = evasionturnover/4
gen turnover4years = turnover
replace turnover4years  = 0 if turnover4years  == .
forvalues x = 1/4 {
	replace turnover4years = turnover4years + L`x'.turnover if L`x'.turnover  != . 
}
replace turnover4years = turnover4years/5

*Winsorize top and drop bottom ()
sum turnover4years if turnover4years > 0 , d
replace turnover4years = `r(p99)' if turnover4years > `r(p99)'

gen shareevasion = evaded4years/(turnover4years + evaded4years)

gen logturnover = log(turnover4years + 1)
bys id: egen audited = max(y2)

gen y2algorithm = y2*algorithm
bys id: egen auditedalgorithm = max(y2algorithm)

*Keep only one observation for each company 
drop if audited == 1 & y2 != 1 
drop if audited == 0 & year != 2018

drop if logturnover == 0 & audited == 0

********************************
*Non parametric estimation of shares as a function of turnover
********************************
egen num_bureau = group(bureau)

*Obs the function lpoly does not allow for multiple regressors, but it has the advantage that it makes predictions out of sample. Since we would like to control for bureau F.E., we first demean the variables and then add the mean back into the predictions. 

*Compute the probability of audit at different levels of turnover
lpoly audited logturnover, gen(audited_hat) at(logturnover) nograph bwidth(0.6)
lpoly auditedalgorithm logturnover, gen(auditedalgorithm_hat) at(logturnover) nograph bwidth(0.6)
lpoly shareevasion logturnover, gen(shareevasion_hat) at(logturnover) nograph bwidth(0.6)

*****************************
*Compute the probability schedule for each audit selection rule
*****************************
*Compute share of algorithm audits in the probability of audits
gen discretionarypart = audited_hat - auditedalgorithm_hat  

*Compute the probability of audit if there were only algorithm or inspection audits \
cap drop prob_inspector_audits delta_prob_inspector prob_algorithm_audits delta_prob_algorithm prob_inspector_audits_temp
gen prob_inspector_audits = . 	
gen delta_prob_inspector = . 	
gen prob_algorithm_audits = . 
gen delta_prob_algorithm = . 

	gen prob_inspector_audits_temp = (audited_hat - auditedalgorithm_hat)
	replace prob_inspector_audits_temp = 0 if prob_inspector_audits_temp < 0 
	
	*Inspectors
	sum audited if logturnover != . 
	local meantotal = r(mean)

	sum prob_inspector_audits_temp 
	local meaninspector = r(mean)

	local missingdensity = (`meantotal'/`meaninspector')
	di `missingdensity'

	replace prob_inspector_audits = prob_inspector_audits_temp*`missingdensity' 
	replace delta_prob_inspector = prob_inspector_audits - audited_hat 
	
	*Adjustment to make sure the mean delta is zero
	sum delta_prob_inspector 
	replace delta_prob_inspector = delta_prob_inspector - `r(mean)'
	
	*Algorithm
	sum audited if logturnover != . 
	local meantotal = r(mean)

	replace auditedalgorithm_hat = 0 if auditedalgorithm_hat < 0 	
	sum auditedalgorithm_hat 
	local meanalgorithm = r(mean)

	local missingdensity = (`meantotal'/`meanalgorithm')
	di `missingdensity'

	replace prob_algorithm_audits = auditedalgorithm_hat*`missingdensity' 
	replace delta_prob_algorithm = prob_algorithm_audits - audited_hat

	*Adjustment to make sure the mean delta is zero
	sum delta_prob_algorithm 
	replace delta_prob_algorithm = delta_prob_algorithm - `r(mean)'

*Create five quintiles to compute the elasticity at different levels of turnover
xtile decile = logturnover , nq(10)

*Figure showing the difference between algorithm and inspectors 

sort logturnover

pctile pc = logturnover, nquantiles(100)  
xtile xt = logturnover, nquantiles(100)  

tw (lpoly prob_algorithm_audits logturnover if logturnover > 13, lwidth(thick) lcolor(navy)) (lpoly prob_inspector_audits logturnover if logturnover > 13, lwidth(thick) lcolor(cranberry)) (lpoly audited_hat logturnover if logturnover > 13, lwidth(thin) lpattern(-) lcolor(black)) (histogram logturnover  if logturnover > 13, col(navy%50)), xtitle("Log(Turnover)") legend(order(1 "Algorithm schedule" 2 "Inspectors' schedule" 3 "Realized") r(1)) xlabel(13(1)22)

graph export "$output\13 counterfactual audit probabilities.pdf", as(pdf) replace

******************************************
*Estimate Elasticity of evasion at different levels of probability of audit
******************************************
gen audited_hat_bureau = . 
sum num_bureau

forvalues x = 1/8 {
	
	di `x'
	
	lpoly audited logturnover if num_bureau == `x' , gen(audited_hat_temp) at(logturnover) nograph bwidth(0.6)
	
	replace  audited_hat_bureau = audited_hat_temp  if num_bureau == `x' 
	
	drop *_temp
} 

	replace audited_hat_bureau = 0 if audited_hat_bureau < 0  //Correct few cases of negative predicted probabilities
	sum audited_hat_bureau, d
	replace audited_hat_bureau = r(p99) if audited_hat_bureau > r(p99)  //Correct few cases of negative predicted probabilities

gen logshareevasion = log(shareevasion) if evaded4years != . 

*************
*ESTIMATE ELASTICITY
**************
cap drop elasticity*

*Exclude sizes that are not present in several bureaus 
xtile vintile = logturnover, nq(20)

*Count number of bureaus per vintile 
tab num_bureau, gen(dum_bur)

forvalues x = 1/8 {
	
	bys vintile: egen total`x' = sum(dum_bur`x')

}

gen sample = 1 if vintile != . 

forvalues x = 1/8 {
	
	forvalues q = 1/20 {
		
		replace sample = 0 if vintile == `q' & total`x' < 100 & num_bureau == `x'
		
	}
}

eststo r1ols: regress logshareevasion audited_hat_bureau logturnover c.audited_hat_bureau#c.logturnover i.num_bureau

eststo r2ols: regress logshareevasion audited_hat_bureau logturnover  i.num_bureau 

eststo r1: ivregress 2sls logshareevasion (audited_hat_bureau c.audited_hat_bureau#c.logturnover =  i.num_bureau) logturnover  if sample == 1, nocons
gen elasticity = _b[audited_hat] + _b[c.audited_hat#c.logturnover]*logturnover
sum elasticity, d

eststo r2: ivregress 2sls logshareevasion (audited_hat_bureau =  i.num_bureau) logturnover  if sample == 1, nocons
gen elasticity_2 = _b[audited_hat]
sum elasticity_2, d

*Output
#delim ;
esttab r1ols  r1 r2ols r2
		using "$output\13 regression elasticities.tex",
		order(audited_hat_bureau  c.audited_hat_bureau#c.logturnover logturnover)
		label se keep(audited_hat_bureau logturnover c.audited_hat_bureau#c.logturnover)
		nomtitles nonumber
		b(%5.2f) se(%5.2f)		
		s(N r2, label("N" "R2")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		coeflabels(audited_hat_bureau "Audited probability" logturnover "Log(Turnover)" c.audited_hat_bureau#c.logturnover "Audited probability X Log(Turnover)")
		prehead("") 
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

*Cap elasticities at zero (i.e. we do not allow firms to declare less turnover when probability of audit increases)
replace elasticity  = 0 if elasticity  > 0 & elasticity !=. 
replace elasticity_2 = 0 if elasticity_2  > 0

*Impute share evasion using prediction
replace shareevasion = shareevasion_hat if shareevasion == . 

*****************************************
*Test multiple values of elasticities and compute the contribution to total declared turnover
*****************************************

matrix el = J(101,5,0)

*Store the actual amount of turnover declared
qui total turnover4years
local totalturnover = _b[turnover4years]

qui total turnover4years if decile < 10
local totalturnover_1to9 = _b[turnover4years]

local r = 0 
forvalues x = -100(1)0 {

	local ++r
	di `r'
	local elasticity = `x'/20
	matrix el[`r', 1] = `elasticity'

	
	*Counterfactual declaration for firms under algorithm probabilities
	gen cf_turnover_algorithm_temp = turnover4years - (`elasticity'*delta_prob_algorithm*shareevasion*(turnover4years*(1 + shareevasion)))
	
	*Counterfactual declaration for firms under inspector probabilities	
	gen cf_turnover_inspector_temp = turnover4years - (`elasticity'*delta_prob_inspector*shareevasion*(turnover4years*(1 + shareevasion)))
	
	*Compute change relative to actual declarations	
	qui total cf_turnover_algorithm_temp
	matrix el[`r', 2] = round(100*(_b[cf_turnover_algorithm_temp]/`totalturnover'-1), 0.01)	
	
	qui total cf_turnover_algorithm_temp if decile < 10
	matrix el[`r', 4] = round(100*(_b[cf_turnover_algorithm_temp]/`totalturnover_1to9'-1), 0.01)		

	qui total cf_turnover_inspector_temp
	matrix el[`r', 3] = round(100*(_b[cf_turnover_inspector_temp]/`totalturnover'-1), 0.01)	

	qui total cf_turnover_inspector_temp if decile < 10
	matrix el[`r', 5] = round(100*(_b[cf_turnover_inspector_temp]/`totalturnover_1to9'-1), 0.01)		
	
	drop cf_turnover_inspector_temp cf_turnover_algorithm_temp
	
}

esttab matrix(el)

svmat el

tw (line el2 el1, lcolor(navy) lwidth(thick)) (line el3 el1, lcolor(cranberry) lwidth(thick)) (line el4 el1, lcolor(navy) lpattern(-)) (line el5 el1, lcolor(cranberry) lpattern(-)), legend(order(1 "Algorithm total" 2 "Inspectors total" 3 "Algorithm except 10th decile" 4 "Inspectors except 10th decile")) xtitle(Elasticity of evasion) ytitle("% difference to actual declarations") yline(0, lcolo(black%50) lwidth(thick) ) note("Elasticity {&epsilon} assumed to be constant for all levels of turnover")  xline(-2, lcolor(black) lpattern(-))

graph export "$output\13 exercise elasticity constant.pdf", as(pdf) replace

drop el1 el2 el3 el4 el5

*****************************************
*Test multiple values of elasticities assuming that elasticity increases with share of evasion
*****************************************

*Choose an intercept and modify the slope. Choose slope
	*intercept of -40 
	*test slopes from 0 to 3 

matrix el2 = J(101,5,0)

*Store the actual amount of turnover declared
qui total turnover4years
local totalturnover = _b[turnover4years]

qui total turnover4years if decile < 10
local totalturnover_1to9 = _b[turnover4years]

local r = 0 
forvalues x = 0/100 {

	local ++r
	di `r'
	gen elasticity_temp = -39 + logturnover*(1.4+6*`x'/1000)
	replace elasticity_temp  = 0 if elasticity_temp  > 0 
	matrix el2[`r', 1] = round(1.4 +6*`x'/1000, 0.001)

	*Counterfactual declaration for firms under algorithm probabilities
	gen cf_turnover_algorithm_temp = turnover4years - (elasticity_temp*delta_prob_algorithm*shareevasion*(turnover4years*(1 + shareevasion)))
	
	*Counterfactual declaration for firms under inspector probabilities	
	gen cf_turnover_inspector_temp = turnover4years - (elasticity_temp*delta_prob_inspector*shareevasion*(turnover4years*(1 + shareevasion)))
	
	*Compute change relative to actual declarations	
	qui total cf_turnover_algorithm_temp
	matrix el2[`r', 2] = round(100*(_b[cf_turnover_algorithm_temp]/`totalturnover'-1), 0.001)	
	
	qui total cf_turnover_algorithm_temp if decile < 10
	matrix el2[`r', 4] = round(100*(_b[cf_turnover_algorithm_temp]/`totalturnover_1to9'-1), 0.001)		

	qui total cf_turnover_inspector_temp
	matrix el2[`r', 3] = round(100*(_b[cf_turnover_inspector_temp]/`totalturnover'-1), 0.001)	

	qui total cf_turnover_inspector_temp if decile < 10
	matrix el2[`r', 5] = round(100*(_b[cf_turnover_inspector_temp]/`totalturnover_1to9'-1), 0.001)		
	
	drop cf_turnover_inspector_temp cf_turnover_algorithm_temp 
	drop elasticity_temp
	
}

esttab matrix(el2)	

svmat el2

tw (line el22 el21, lcolor(navy) lwidth(thick)) (line el23 el21, lcolor(cranberry) lwidth(thick)) (line el24 el21, lcolor(navy) lpattern(-)) (line el25 el21, lcolor(cranberry) lpattern(-)), legend(order(1 "Algorithm total" 2 "Inspectors total" 3 "Algorithm except 10th decile" 4 "Inspectors except 10th decile")) xtitle(Slope of elasticity) ytitle("% difference to actual declarations") yline(0, lcolo(black%50) lwidth(thick) ) note("Elasticity {&epsilon} assumed to follow {&epsilon}=-41+slope x log(turnover)") xline(1.6, lcolor(black) lpattern(-))

graph export "$output\13 exercise elasticity depends on turnover.pdf", as(pdf) replace

drop el2*

************************
*Descriptives
************************

*Generate cumulative declared turnover for different levels of turnover
cumul logturnover, gen(cumul)

gen acc_turnover = . 

sort logturnover 
gen n = _n
sum n 
forvalues x = 1/`r(max)' {
	di `x'
	gen dummy = n <= `x' 
	bys dummy: egen totaltemp = total(turnover4years) if dummy == 1 
	replace acc_turnover = totaltemp  if n == `x'
	drop totaltemp dummy 
}

total turnover4years
replace acc_turnover = acc_turnover/_b[turnover4years]

sort turnover4years

tw (lpoly audited  logturnover if logturnover  >  12, lcolor(navy) lwidth(thick) bwidth(0.6)) (lpoly shareevasion logturnover if logturnover  >  12, lcolor(orange) lwidth(thick) bwidth(0.6)) (histogram logturnover if logturnover  >  12, col(navy%50))  (line cumul logturnover  if logturnover > 12, lcolor(black) lpattern(-)) (line acc_turnover logturnover if logturnover > 12, lcolor(red) lpattern(-)), legend(order (1 "P(audit)" 2 "Share evasion" 4 "Cumulative distribution" 5 "Cumulative declarations")) title("") xtitle("log(turnover)") ytitle("%")

graph export "$output\13 size evasion audits.pdf", as(pdf) replace

************************
*SUMMARY TABLES WITH THE PARAMETERS FROM REGRESSIONS
************************

*Counterfactual tax declarations
gen cf_turnover_algorithm = turnover4years - (elasticity*delta_prob_algorithm*shareevasion*(turnover4years*(1 + shareevasion)))
gen cf_turnover_inspector = turnover4years - (elasticity*delta_prob_inspector*shareevasion*(turnover4years*(1 + shareevasion)))

gen cf_turnover_algorithm_2 = turnover4years - (elasticity_2*delta_prob_algorithm*shareevasion*(turnover4years*(1 + shareevasion)))
gen cf_turnover_inspector_2 = turnover4years - (elasticity_2*delta_prob_inspector*shareevasion*(turnover4years*(1 + shareevasion)))

gen cf_evasionrate_algorithm = shareevasion*(1 + elasticity*delta_prob_algorithm)
gen cf_evasionrate_inspector = shareevasion*(1 + elasticity*delta_prob_inspector)

gen cf_evasionrate_algorithm2 = shareevasion*(1 + elasticity_2*delta_prob_algorithm)
gen cf_evasionrate_inspector2  = shareevasion*(1 + elasticity_2*delta_prob_inspector)

drop if decile == . 

collapse (sum) cf_turnover_inspector*  cf_turnover_algorithm* turnover4years (mean) shareevasion_hat audited_hat delta_prob_algorithm delta_prob_inspector elasticity* cf_evasionrate*, by(decile)

matrix results = J(11,10,0)

matrix colnames results = "Realized Revenue" "Inspector" "Algorithm" "Elasticity"  "Inspector" "Algorithm" "Elasticity" "Actual" "Inspector" "Algorithm"
matrix rownames results = "Decile 1" "Decile 2" "Decile 3" "Decile 4" "Decile 5" "Decile 6" "Decile 7" "Decile 8" "Decile 9" "Decile 10" "Total"

forvalues x = 1/10 {
	
local r = `x' 	

	total turnover4years if decile == `x'
	local total = _b[turnover4years]
	matrix results[`r', 1] = round(_b[turnover4years]/1000000, 1)
	total cf_turnover_inspector if decile == `x'
	matrix results[`r', 2] = round((_b[cf_turnover_inspector]-`total')/1000000, 1)
	total cf_turnover_algorithm if decile == `x'
	matrix results[`r', 3] = round((_b[cf_turnover_algorithm]-`total')/1000000, 1)	
	sum elasticity if decile == `x'
	matrix results[`r', 4]  = round(`r(mean)', 0.01)	
	total cf_turnover_inspector_2 if decile == `x'	
	matrix results[`r', 5] = round((_b[cf_turnover_inspector_2]-`total')/1000000, 1)
	total cf_turnover_algorithm_2 if decile == `x'
	matrix results[`r', 6] = round((_b[cf_turnover_algorithm_2]-`total')/1000000, 1)		
	sum elasticity_2 if decile == `x'
	matrix results[`r', 7]  = round(`r(mean)', 0.01)	
	total audited_hat if decile == `x'	
	matrix results[`r', 8] = round(_b[audited_hat]*100, 0.01)	
	total delta_prob_inspector if decile == `x'	
	matrix results[`r', 9] = round(_b[delta_prob_inspector]*100, 0.01)
	total delta_prob_algorithm if decile == `x'
	matrix results[`r', 10] = round(_b[delta_prob_algorithm]*100, 0.01)	
}

	total turnover4years
	local total = _b[turnover4years]
	matrix results[11, 1] = round(_b[turnover4years]/1000000, 1)
	total cf_turnover_inspector 
	matrix results[11, 2] = round((_b[cf_turnover_inspector]-`total')/1000000, 1)
	total cf_turnover_algorithm 
	matrix results[11, 3] = round((_b[cf_turnover_algorithm]-`total')/1000000, 1)
	sum elasticity
	matrix results[11, 4]  = round(`r(mean)', 0.01)	
	total cf_turnover_inspector_2
	matrix results[11, 5] = round((_b[cf_turnover_inspector_2]-`total')/1000000, 1)
	total cf_turnover_algorithm_2 
	matrix results[11, 6] = round((_b[cf_turnover_algorithm_2]-`total')/1000000, 1)	
	sum elasticity_2
	matrix results[11, 7]  = round(`r(mean)', 0.01)	
	sum audited_hat 
	matrix results[11, 8] = round(`r(mean)'*100, 0.01)	
	sum delta_prob_inspector 
	matrix results[11, 9] = round(`r(mean)'*100, 0.01)
	sum delta_prob_algorithm 
	matrix results[11, 10] = round(`r(mean)'*100, 0.01)	

esttab matrix(results)

#delim ;
esttab matrix(results)
		using "$output\13 deterrence.tex",
		b(%5.2f) se(%5.2f)		nomtitle
		prehead("") 
		posthead(\hline) postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

