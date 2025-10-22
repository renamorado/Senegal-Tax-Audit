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

*cap drop L1turnover
****************************
*Cleaning and generating variables
****************************

*Generate numeric variable for bureau
gen numeric_bureau = 1 if bureau == "DGE"
replace numeric_bureau = 2 if bureau == "CME1"
replace numeric_bureau = 3 if bureau == "CME2"
replace numeric_bureau = 4 if bureau == "CPR"
replace numeric_bureau = 5 if numeric_bureau  == . 

*Cleaning
replace activity_group = 100 if activity_group == -1
replace algorithm = 1 if random == 1 
replace y11 = 0 if y2 == 1 & y11 == .

*Select sample of selected cases (excluding replacement)
drop if safeties == 1 
keep if selection == 1 

*Transform some variables (positive ones) in logs 
foreach v of varlist productivity* turnover* firmage durationcar distance {
	replace `v' = log(`v' + 1)
}

gen evasion_cost1 = log(evasionvalue/y16 +1)
gen audit_yield = log(penalites_confirmation/y16 + 1)
	replace audit_yield = 0 if y2 == 1 & audit_yield == . 
	
*Demean variables at the list level
foreach v of varlist y4 y11 y2 turnover* productivity* profitrate* firmage durationcar distance *filed* evasion_cost1 audit_yield {

    if strpos("`v'", "dec") == 0 {
	bys inspectorclusteryear: egen mean`v' = mean(`v')

	clonevar original`v' = `v'
	replace `v' = `v' - mean`v' 
	}
} 

*Create deciles of economic variables within bureau
forvalues y = 2014/2019 {
		
	foreach j in turnover productivity profitrate   {
	
	gen dec`j'`y' = 0
	
	qui sum numeric_bureau
	forvalues b  = 1/`r(max)' {
		
		xtile dectemp = `j'`y' if `j'`y' > 0 & numeric_bureau == `b' , nq(10)
		replace dec`j'`y' = dectemp if `j'`y' > 0 & numeric_bureau == `b'		
		drop dectemp
	
		}
	}	
}

*For each year, predict whether firm was selected by DGID based on 
	*whether firm was selected 1 year earlier, 2 years earlier (only for 2020)
	*whether firm is in top decile of turnover within tax unit 
	*whether firm presented losses 
	*whether firm declared CIT, VAT, CGU, IMP, EXP
	
drop selection20*
	
foreach y in 2018 2019 2020 {
	
gen y2VG`y' = 0 
replace y2VG`y' = 1 if y2 == 1 & selectionyear == `y' & typedecontrole_selection == "VG"	

gen y2CP`y' = 0 
replace y2CP`y' = 1 if y2 == 1 & selectionyear == `y' & typedecontrole_selection == "CP"
	
gen selectionVG`y' = 0 
replace selectionVG`y' = 1 if selectionyear == `y' & typedecontrole_selection == "VG"	

gen selectionCP`y' = 0 
replace selectionCP`y' = 1 if selectionyear == `y' & typedecontrole_selection == "CP"	
	
gen dgid`y' = 0 
replace dgid`y' = 1 if selectionyear == `y' & dgid == 1 

gen algorithm`y' = 0 
replace algorithm`y' = 1 if selectionyear == `y' & algorithm == 1

gen horsprogramme`y' = 0 
replace horsprogramme`y' = 1 if selectionyear == `y' & horsprogramme == 1 
	
gen audit`y' = 0 
replace audit`y' = 2 if anneeduchrono == `y' & controle == 2
replace audit`y' = 1 if anneeduchrono == `y' & controle == 1

}

*Create lags in different columns for the variables to be used in prediction (notice that the dataset is identified by audits, so they may happen in different years)
foreach v in y2VG selectionVG y2CP selectionCP decturnover decproductivity decprofitrate  productivity profitrate TVA_filed TAF_filed  RAS_IRPP_filed MAN_filed IS_filed IMP_filed EXP_filed CGU_filed TVAAN_filed {
	
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

*Create deciles based on information about firms
foreach j in firmage distance durationcar {
	
	gen dec`j' = 0
	
	qui sum numeric_bureau
	forvalues b  = 1/`r(max)' {
		
		xtile dectemp = `j' if `j' > 0 & numeric_bureau == `b' , nq(10)
		replace dec`j'= dectemp if `j' > 0 & numeric_bureau == `b'		
		drop dectemp
	
		}
	}	


replace decdistance = 0 if decdistance == .
replace decdurationcar = 0 if decdurationcar == .
replace decfirmage = 0 if decfirmage == .

*Replace lagged turnover with earlier year if missing
replace L1turnover = L2turnover if L1turnover == . 
replace L1turnover = L3turnover if L1turnover == . 
replace L1turnover = L0turnover if L1turnover == . 

drop L0*

foreach v of varlist L1* L2* L3* decfirmage decdurationcar decdistance firmage durationcar distance {
	gen miss_`v' = `v' == . 
	replace `v' = 0 if `v' == .
}

replace L1turnover  = . if L1turnover == 0 

************************************
*Set up globals for the prediction models
************************************

*Try several prediction models and compare them using ROC, and misclassification 
	*linear regression
	*logit regression with fixed effects
	*poisson
	*Lasso
	*random forest 
	*RF with continuous variables
	
*several types of models
		* 1) only turnover
		* 2) turnover plus other tax declarations 
		* 3) all characteristics of firms
global model0 "L1turnover L1turnoversq L1turnovercu"
global model0rf "L1turnover"
global model0rfc "L1turnover"

global model1   "L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu firmage durationcar distance"
global model1rf "L1turnover L1profitrate L1productivity firmage durationcar distance "
global model1rfc "L1turnover L1profitrate L1productivity firmage durationcar distance"

global model2   "L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu firmage durationcar distance"
global model2rf   "L1turnover L1profitrate  L1productivity  firmage durationcar distance"
global model2rfc "L1turnover  L1profitrate L1productivity firmage durationcar distance"

global model3 "i.L*dec* L*filed* i.decfirmage i.decdurationcar i.decdistance"
global model3rf "L*dec* L*filed* decfirmage decdurationcar decdistance"
global model3rfc  "L*filed* L1turnover L2turnover L3turnover L1profitrate L2profitrate L3profitrate L1productivity L2productivity L3productivity  firmage durationcar distance"
	
global figurename1_1 "10 predicted vs realized full audits only turnover" 	
global figurename1_1bureau "10 predicted vs realized full audits only turnover by bureau" 	
global figurename1_0 "10 predicted vs realized desk audits only turnover" 	
global figurename1_0bureau "10 predicted vs realized desk audits only turnover by bureau" 	

global figurename2_1 "10 predicted vs realized full audits all characteristics" 	
global figurename2_1bureau "10 predicted vs realized full audits all characteristics by bureau" 	
global figurename2_0 "10 predicted vs realized desk audits all characteristics" 	
global figurename2_0bureau "10 predicted vs realized desk audits all characteristics by bureau" 

global figurename3_1 "10 predicted vs realized full audits characteristics and filing" 	
global figurename3_1bureau "10 predicted vs realized full audits characteristics and filing by bureau" 	
global figurename3_0 "10 predicted vs realized desk audits characteristics and filing" 	
global figurename3_0bureau "10 predicted vs realized desk audits characteristics and filing by bureau" 

foreach v in L1turnover L1turnoversq L1turnovercu L1profitrate L1profitratesq L1profitratecu L1productivity L1productivitysq L1productivitycu firmage durationcar distance {
	replace `v' = 0 if `v' == .
}


sa "$analysisdata/datasetforanalysis_predictionexercise.dta", replace 

***********************************
*Predict execution only based on firm size (ranking the firms by size and picking the largest)
************************************
use "$analysisdata/datasetforanalysis_predictionexercise.dta", clear

bys inspectorclusteryear: egen totalexecution = total(originaly2)
gsort inspectorclusteryear -L1turnover
by inspectorclusteryear : gen n = _n
gen predicted_by_size = n <= totalexecution
drop n

bys inspectorclusteryear algorithm: egen totalexecution_method = total(originaly2)
gsort inspectorclusteryear algorithm -L1turnover
by inspectorclusteryear algorithm: gen n = _n
gen predicted_by_size_method = n <= totalexecution_method

tab predicted_by_size originaly2 if controle == 2
tab predicted_by_size originaly2 if controle == 1

matrix p = J(5, 6, 0)
matrix rownames p = "DGE" "CME1" "CME2" "CPR" "DSF"
matrix colnames p = "All executed" "Algorithm"  "Inspectors" "All executed" "Algorithm"  "Inspectors"

forvalues v = 1/5 {
	
	sum predicted_by_size if originaly2  == 1 & numeric_bureau == `v' & controle == 2
	matrix p[`v', 1] = round(100*`r(mean)', 1)
	sum predicted_by_size_method if originaly2  == 1 & numeric_bureau == `v' & algorithm == 1 & controle == 2
	matrix p[`v', 2] = round(100*`r(mean)', 1)
	sum predicted_by_size_method if originaly2  == 1 & numeric_bureau == `v' & algorithm == 0 & controle == 2
	matrix p[`v', 3] = round(100*`r(mean)', 1)	 
	
	sum predicted_by_size if originaly2  == 1 & numeric_bureau == `v' & controle == 1
	matrix p[`v', 4] = round(100*`r(mean)', 1)
	sum predicted_by_size_method if originaly2  == 1 & numeric_bureau == `v' & algorithm == 1 & controle == 1
	matrix p[`v', 5] = round(100*`r(mean)', 1)
	sum predicted_by_size_method if originaly2  == 1 & numeric_bureau == `v' & algorithm == 0 & controle == 1
	matrix p[`v', 6] = round(100*`r(mean)', 1)	
	
}

*Export table
#delim ;
esttab matrix(p)
		using "$output\10 prediction coefficients predict by size only.tex",
		nonumbers nomtitle
		prehead("") 
		posthead("\hline") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr


************************************
*Descriptive table with the differences between algorithm and inspectors, and the coefficients of a model trained on inspector cases
************************************
preserve 

*Regression with continuous variables
	regress y2 L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed if dgid == 1 & controle == 2

	local r2 = `e(r2)'
	
	matrix j = J(16,6,0)
	matrix rownames j = "log(turnover)" "log(productivity)" "profit rate" "log(age)" "log(distance)" "log(duration by car)" "filed VAT" "filed TAF" "filed WIT" "had procurement" "filed CIT" "had imports" "had exports" "filed CGU" "filed VAT annex" "\hline R2"
	matrix colnames j = "Coefficient" "SE"  "Coefficient" "SE" "Difference" "SE"
	
	local r = 0 
	foreach v in L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed {
		
		local ++r
		matrix j[`r', 1] = round(_b[`v'], 0.01)
		matrix j[`r', 2] = round(_se[`v']	, 0.01)
		
	} 

*Regression with continuous variables
	regress y2 L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed if dgid == 1 & controle == 2

	local r2 = `e(r2)'
	
	matrix j = J(16,6,0)
	matrix rownames j = "log(turnover)" "log(productivity)" "profit rate" "log(age)" "log(distance)" "log(duration by car)" "filed VAT" "filed TAF" "filed WIT" "had procurement" "filed CIT" "had imports" "had exports" "filed CGU" "filed VAT annex" "\hline R2"
	matrix colnames j = "Coefficient" "SE"  "Coefficient" "SE" "Difference" "SE"
	
	local r = 0 
	foreach v in L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed {
		
		local ++r
		matrix j[`r', 1] = round(_b[`v'], 0.01)
		matrix j[`r', 2] = round(_se[`v']	, 0.01)
		
	} 

	local ++r
	matrix j[`r', 1] = round(`r2', 0.01)		

*Regression with dummy variables
foreach v of varlist L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed {
	sum `v', d
	replace `v' = `v' >= r(p50) if `v' != . 
}

	regress y2 L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed if dgid == 1 & controle == 2

	local r2 = `e(r2)'
	
	local r = 0 
	foreach v in L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed {
		
		local ++r
		matrix j[`r', 3] = round(_b[`v'], 0.01)
		matrix j[`r', 4] = round(_se[`v']	, 0.01)
		
	} 

	local ++r
	matrix j[`r', 3] = round(`r2', 0.01)	
	
	local r = 0 
	foreach v in L1turnover L1productivity L1profitrate  firmage distance durationcar  L1TVA_filed L1TAF_filed  L1RAS_IRPP_filed L1MAN_filed L1IS_filed L1IMP_filed L1EXP_filed L1CGU_filed L1TVAAN_filed {
		
		local ++r
		
		regress `v' algorithm if controle == 2
		matrix j[`r', 5] = round(_b[algorithm], 0.01)
		matrix j[`r', 6] = round(_se[algorithm]	, 0.01)
		
	} 	


	*Export table
	#delim ;
	esttab matrix(j)
			using "$output\10 prediction coefficients matrix.tex",
			nonumbers nomtitle
			prehead("") 
			posthead("\hline") postfoot("\hline")
			replace
			substitute(\_ _)
		;
	#delim cr

restore 

************************	
*Predict the probability of execution in 100 iterations with 70% training sample (to plot the distribution of estimates)
************************
*select 1/3 of sample as training
set seed 1908345
cap drop n
cap drop N

foreach m in 3 {

cap drop yhat*  
		
		*Estimate the model 100 times taking random draws of 70% of DGID cases
		matrix pred`m'VG = J(100, 3, 0)
		matrix pred`m'CP = J(100, 3, 0)
		
		matrix MSE`m'VG = J(100, 3, 0)
		matrix MSE`m'CP = J(100, 3, 0)
		
		forvalues d = 1/100 {
			
			di `d'
			
			*Select sample randomly
			gen xrand = runiform()
			sort dgid controle xrand 
			by dgid controle: gen n = _n
			by dgid controle: gen N = _N
			gen training = n/N < 0.7 if dgid == 1
			drop n N
		
			qui regress y2 ${model`m'}  if dgid == 1 & controle == 2 & training == 1
					predict yhatolsVG if controle == 2 

			qui lasso linear y2 ${model`m'}   if dgid == 1 & controle == 2 & training == 1
					predict yhatlassoVG if controle == 2 

			qui rforest y2  ${model`m'rfc} if dgid == 1 & controle == 2 & training == 1, type(reg)
					predict yhatrf_cVG if controle == 2 
			
			local c = 0 
			qui foreach v in yhatolsVG yhatlassoVG  yhatrf_cVG { 
				
				local ++c
				sum `v' if dgid == 1
				matrix pred`m'VG[`d', `c'] = `r(mean)'
				
				gen sq_diff = (y2 - `v')^2 if dgid == 1
				sum sq_diff, d 
				matrix MSE`m'VG[`d', `c'] = `r(mean)'
				drop sq_diff
				
			}
			
			drop yhatolsVG yhatlassoVG yhatrf_cVG 
			
		************************	
		*Desk audits
		************************

		qui regress y2 ${model`m'} if dgid == 1 & controle == 1 & training == 1
				predict yhatolsCP if controle == 1
				
		qui lasso linear y2 ${model`m'} if dgid == 1 & controle == 1 & training == 1
				predict yhatlassoCP if controle == 1
			
		*qui rforest y2 ${model`m'rf} if dgid == 1 & controle == 1 & training == 1, type(reg)
		*		predict yhatrfCP if controle == 1 
			
		qui rforest y2 ${model`m'rfc} if dgid == 1 & controle == 1 & training == 1, type(reg)
				predict yhatrf_cCP if controle == 1 		

			local c = 0 
			qui foreach v in yhatolsCP yhatlassoCP  yhatrf_cCP { 
				
				local ++c
				sum `v' if dgid == 1
				matrix pred`m'CP[`d', `c'] = `r(mean)'
				
				gen sq_diff = (y2 - `v')^2 if dgid == 1
				sum sq_diff, d 
				matrix MSE`m'CP[`d', `c'] = `r(mean)'
				drop sq_diff
				
			}
			drop yhatolsCP yhatlassoCP  yhatrf_cCP
			drop xrand training
		}
}

***************************
*Predict values using the whole sample
***************************
***Obs
			*how to compute confidence intervals for these predictions? 
			*for the linear regression, I think I could do it by using the predict, stdp command in stata (though probably there are some computations needed to aggregate it to obtain the standard error of the mean)
			*for random forest, probably the only way is via bootstrap?

foreach m in 3 {

cap drop yhat*

			*Prepare tables for estimation results
			matrix results = J(14, 15, 0)
			
			************************	
			*Full audits
			************************
			
				eststo olsvg`m': qui regress y2 ${model`m'}  if dgid == 1 & controle == 2 
						predict yhatolsVG if controle == 2 	
						
						gen residual = yhatolsVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual
						
				eststo lassovg`m': qui lasso linear y2 ${model`m'}   if dgid == 1 & controle == 2, lambda(0.025)
						predict yhatlassoVG if controle == 2 	
						
						gen residual = yhatlassoVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual	
						
				qui rforest y2 ${model`m'rf}  if dgid == 1 & controle == 2, type(reg)
						predict yhatrfVG if controle == 2 

						gen residual = yhatrfVG - y2
						replace residual = residual^2
						sum residual 
						local mse = round(r(mean), 0.01)
						drop residual
						
						*Add the importance variable in the e(b) matrix for esttab 
						matrix importance = e(importance)
						
						qui regress y2 ${model`m'rf}  if dgid == 1 & controle == 2
						local N = `e(N)'						
						*Fill in table
						matrix b = e(b)
						local colnames: colnames b
						local r = 0
						foreach v in `colnames' {
							di "`v'"
							local ++r
							matrix b[1,`r'] = 0
							cap matrix b[1,`r']=importance["`v'",1]
						}	
						
						eststo rfvg`m': ereturn post b 
						estadd local mse = `mse'
						estadd local N = `N'

				qui rforest y2  ${model`m'rfc} if dgid == 1 & controle == 2 , type(reg)
						predict yhatrf_cVG if controle == 2 
				
			************************	
			*Desk audits
			************************

			qui regress y2 ${model`m'} if dgid == 1 & controle == 1
					predict yhatolsCP if controle == 1

			qui lasso linear y2 ${model`m'} if dgid == 1 & controle == 1 
					predict yhatlassoCP if controle == 1
				
			qui rforest y2 ${model`m'rf} if dgid == 1 & controle == 1, type(reg)
					predict yhatrfCP if controle == 1 
				
			qui rforest y2 ${model`m'rfc} if dgid == 1 & controle == 1, type(reg)
					predict yhatrf_cCP if controle == 1 				
			
			*****************************************
			*TABLES USING PREDICTED VALUE AS CONTROL
			*****************************************	
			foreach audit in "CP" "VG" {

			local n = 0
			foreach predict in ols lasso rf rf_c {
			local ++n
				gen predicted = yhat`predict'`audit'
					eststo r`n'`audit': reg y2 predicted algorithm , vce(robust)
					gen sq_diff = (y2 - predicted)^2
					sum sq_diff if dgid == 1
					estadd local MSE = round(`r(mean)', 0.01)
					
				drop predicted sq_diff
				}
			}

			*Export table
			#delim ;
			esttab r1VG r2VG r3VG r4VG r1CP r2CP r3CP r4CP
					using "$output\10 prediction models `m'.tex",
					order(  predicted algorithm )
					label se keep(  predicted algorithm)
					nomtitles		nonumbers
					coeflabels(predicted "Prediction" algorithm "Algorithm")
					s(N r2 MSE, label("N" "R2" "MSE")) 
					star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
					prehead("") 
					posthead("") postfoot("\hline")
					replace
					substitute(\_ _)
				;
			#delim cr

			*****************************************~
			*STORE RESULTS IN MATRICES
			*****************************************
			*Summary table with results
			matrix results`m' = J(12, 12, 1)
			matrix colnames  results`m' = "x" "VG" "algorithm" "realized"  "predicted" "model" "p1" "p25" "p50" "p75" "p99" "MSPE"

			*All years 
			local r = 0
			local audittype = 0

			foreach audit in "CP" "VG" {
			local ++audittype
			local x = 0 

				foreach algorithm in "0" "1"  {

				local model = 0 

					foreach predict in ols lasso rf_c {

					local ++model 
					local ++r
					local ++x

					matrix results`m'[`r', 1] = `x'
					matrix results`m'[`r', 2] = `audittype'
					matrix results`m'[`r', 3] = `algorithm'

					sum y2 if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 4] = `r(mean)'
									
					sum yhat`predict'`audit' if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 5] = `r(mean)'

					matrix results`m'[`r', 6] = `model'

					*Get the prediction distribution (stored in matrices)
					svmat pred`m'`audit' 

					*The predictions are numbered according to the models, so we can use the `model' local to obtain the prediction distributions
					sum pred`m'`audit'`model', d
					matrix results`m'[`r', 7] = `r(p1)'
					matrix results`m'[`r', 8] = `r(p25)'
					matrix results`m'[`r', 9] = `r(p50)'
					matrix results`m'[`r', 10] = `r(p75)'
					matrix results`m'[`r', 11] = `r(p99)'

					drop pred`m'`audit'*

					*Get the MSPE associated with that model
					svmat MSE`m'`audit'
					sum MSE`m'`audit'`model', d
					matrix results`m'[`r', 12] = `r(mean)'

					drop MSE`m'`audit'*

					}

				local ++x

				}

			}

			*****************************************
			*MATRICES by bureau
			*****************************************
			*Summary table with results
			matrix resultsb`m' = J(20, 6, 1)
			matrix colnames  resultsb`m' = "x" "VG" "algorithm" "realized"  "predicted" "model"

			*All years 
			local r = 0
			local audittype = 0

			foreach audit in "CP" "VG" {
			local ++audittype
			local x = 0 
					
				foreach numeric in 1 2 3 4 5 {

					foreach algorithm in "0" "1"  {

					local ++r
					local ++x
					
					matrix resultsb`m'[`r', 1] = `x'
					matrix resultsb`m'[`r', 2] = `audittype'
					matrix resultsb`m'[`r', 3] = `algorithm'
					
					sum y2 if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric'
					matrix resultsb`m'[`r', 4] = `r(mean)'
									
					sum yhatrf_c`audit' if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric'

					matrix resultsb`m'[`r', 5] = `r(mean)'

					matrix resultsb`m'[`r', 6] = `numeric'
					
					}

				local ++x

				}
		}
}

/*
*****************************************
*TABLES WITH ESTIMATION RESULTS (ONLY FOR THREE FIRST MODELS)
*****************************************	

foreach m in 0 1 2 3 {

cap drop yhat*

			*Prepare tables for estimation results
			matrix results = J(14, 15, 0)
			
			************************	
			*Full audits
			************************
			
				eststo olsvg`m': qui regress y2 ${model`m'}  if controle == 2 
						predict yhatolsVG if controle == 2 	
						
						gen residual = yhatolsVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual
						
				eststo lassovg`m': qui lasso linear y2 ${model`m'}   if  controle == 2, lambda(0.025)
						predict yhatlassoVG if controle == 2 	
						
						gen residual = yhatlassoVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual	
						
				qui rforest y2 ${model`m'rf}  if  controle == 2, type(reg)
						predict yhatrfVG if controle == 2 

						gen residual = yhatrfVG - y2
						replace residual = residual^2
						sum residual 
						local mse = round(r(mean), 0.01)
						drop residual
						
						*Add the importance variable in the e(b) matrix for esttab 
						matrix importance = e(importance)
						
						qui regress y2 ${model`m'rf}  if controle == 2
						local N = `e(N)'						
						*Fill in table
						matrix b = e(b)
						local colnames: colnames b
						local r = 0
						foreach v in `colnames' {
							di "`v'"
							local ++r
							matrix b[1,`r'] = 0
							cap matrix b[1,`r']=importance["`v'",1]
						}	
						
						eststo rfvg`m': ereturn post b 
						estadd local mse = `mse'
						estadd local N = `N'

				qui rforest y2  ${model`m'rfc} if controle == 2 , type(reg)
						predict yhatrf_cVG if controle == 2 
}

#delim ;
esttab olsvg0 lassovg0 rfvg0 olsvg1 lassovg1 rfvg1 olsvg2 lassovg2 rfvg2
		using "$output\10 prediction models summary coefficients all.tex",
		label se 
		nomtitles	nocons	nonumbers
		s(N mse, label("N" "MSE")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		prehead("") 
		coeflabels(L1turnover "L1 log(turnover)" L1turnoversq "L1 log(turnover) sq." L1turnovercu "L1 log(turnover) cub." L1profitrate "L1 profit rate" L1profitratesq "L1 profit rate sq." L1profitratecu "L1 profit rate cub." L1productivity "L1 log(productivity)" L1productivitysq "L1 log(productivity) sq." L1productivitycu "L1 log(productivity) cub." firmage "log(firm's age)" durationcar "log(minutes by car)" distance "log(distance in m)" q5 "Share of sales in cash")
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr
*/

*****************************************~
*PLOT GRAPHS
*****************************************			
foreach m in 3 {

			preserve 

					clear 
					svmat results`m', names(col)
					
					*VG graph Predicted vs realized 
					forvalues x = 1/4 {
						sum MSPE if algorithm == 0 & VG == 2 & model == `x'
						global mspe`x' = round(`r(mean)', 0.01)
						di "${mspe`x'}"
					}
					
						#delim; 
						tw 
						
						(rcap p99 p1 x if algorithm == 0 & VG == 2, lcolor(black%50))
						(rbar p75 p50 x if algorithm == 0 & VG == 2, color(gs12) barw(.5))
						(rbar p50 p25 x if algorithm == 0 & VG == 2, color(gs12) barw(.5))
						
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 1, color(black) msymbol(circle))
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 2, color(black)  msymbol(diamond))
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 3, color(black)  msymbol(triangle))

						(scatter predicted x if algorithm == 1 & VG == 2 & model == 1, color(black%50) msymbol(circle))
						(scatter predicted x if algorithm == 1 & VG == 2 & model == 2, color(black%50) msymbol(diamond))
						(scatter predicted x if algorithm == 1 & VG == 2 & model == 3, color(black%50) msymbol(triangle))

						(line realized x if algorithm == 0 & VG == 2, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 2, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						ylabel(-0.1(0.05)0.12)

						legend(order(- "Predictions: " 4 "OLS" 5 "Lasso" 6 "Random Forest") r(1))
						
						text(-0.02 2 "(MSPE)", place(c))
						
						text(0 1 "${mspe1}", place(c))
						text(0 2 "${mspe2}", place(c))
						text(0 3 "${mspe3}", place(c))
						;
						#delim cr

					graph export "$output\\${figurename`m'_1}.pdf", as(pdf) replace
					
					*CP graph Predicted vs realized 
					forvalues x = 1/4 {
						sum MSPE if algorithm == 0 & VG == 1 & model == `x'
						global mspe`x' = round(`r(mean)', 0.01)
						di "${mspe`x'}"
					}
					
						#delim; 
						tw 
						
						(rcap p99 p1 x if algorithm == 0 & VG == 1, lcolor(black%50))
						(rbar p75 p50 x if algorithm == 0 & VG == 1, color(gs12) barw(.5))
						(rbar p50 p25 x if algorithm == 0 & VG == 1, color(gs12) barw(.5))
						
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 1, color(black) msymbol(circle))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 2, color(black)  msymbol(diamond))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 3, color(black)  msymbol(triangle))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 4, color(black)  msymbol(X))

						(scatter predicted x if algorithm == 1 & VG == 1 & model == 1, color(black%50) msymbol(circle))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 2, color(black%50) msymbol(diamond))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 3, color(black%50) msymbol(triangle))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 4, color(black%50) msymbol(X))

						(line realized x if algorithm == 0 & VG == 1, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 1, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						ylabel(-0.1(0.05)0.12)
						legend(order(- "Predictions: " 4 "OLS" 5 "Lasso" 6 "Random Forest") r(1))
						
						text(-0.01 2 "(MSPE)", place(c))
						
						text(0 1 "${mspe1}", place(c))
						text(0 2 "${mspe2}", place(c))
						text(0 3 "${mspe3}", place(c))
						text(0 4 "${mspe4}", place(c))
						;
						#delim cr

					graph export "$output\\${figurename`m'_0}.pdf", as(pdf) replace	

			restore

			*Plot graphs by bureau
			preserve 

					clear 
					svmat resultsb`m', names(col)

					*Predicted vs realized 
					#delim: 
					tw 
					(bar predicted x if algorithm == 0 & VG == 2 & model == 1, color(navy) msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 2 & model == 2, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 2 & model == 3, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 2 & model == 4, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 2 & model == 5, color(navy)  msymbol(diamond))

					(bar predicted x if algorithm == 1 & VG == 2 & model == 1, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 2 & model == 2, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 2 & model == 3, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 2 & model == 4, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 2 & model == 5, color(orange%50) msymbol(circle))

					(scatter realized x if model == 1 & VG == 2, color(black%50) msymbol(T))
					(scatter realized x if model == 2 & VG == 2, color(black%50) msymbol(T))
					(scatter realized x if model == 3 & VG == 2, color(black%50) msymbol(T))
					(scatter realized x if model == 4 & VG == 2, color(black%50) msymbol(T))
					(scatter realized x if model == 5 & VG == 2, color(black%50) msymbol(T))

					,
					xlabel(1.5 "Large Taxpayers" 4.5 "Medium Taxpayers 1" 7.5 "Medium Taxpayers 2" 10.5 "Liberal Professions" 13.5 "SME", labsize(small))
					ytitle("p.p. relative to F.E. benchmark")
					xtitle("")
					title("") 
					legend(order(- "Predictions: " 1 "Inspector" 6 "Algorithm" 11 "Realized") r(1))
					;
					#delim cr

						graph export "$output\\${figurename`m'_1bureau}.pdf", as(pdf) replace	


					#delim: 
					tw 
					(bar predicted x if algorithm == 0 & VG == 1 & model == 1, color(navy) msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 1 & model == 2, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 1 & model == 3, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 1 & model == 4, color(navy)  msymbol(diamond))
					(bar predicted x if algorithm == 0 & VG == 1 & model == 5, color(navy)  msymbol(diamond))

					(bar predicted x if algorithm == 1 & VG == 1 & model == 1, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 1 & model == 2, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 1 & model == 3, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 1 & model == 4, color(orange%50) msymbol(circle))
					(bar predicted x if algorithm == 1 & VG == 1 & model == 5, color(orange%50) msymbol(circle))

					(scatter realized x if model == 1 & VG == 1, color(black%50) msymbol(T))
					(scatter realized x if model == 2 & VG == 1, color(black%50) msymbol(T))
					(scatter realized x if model == 3 & VG == 1, color(black%50) msymbol(T))
					(scatter realized x if model == 4 & VG == 1, color(black%50) msymbol(T))
					(scatter realized x if model == 5 & VG == 1, color(black%50) msymbol(T))

					,
					xlabel(1.5 "Large Taxpayers" 4.5 "Medium Taxpayers 1" 7.5 "Medium Taxpayers 2" 10.5 "Liberal Professions" 13.5 "SME", labsize(small))
					ytitle("p.p. relative to F.E. benchmark")
					xtitle("")
					title("") 
					legend(order(- "Predictions: " 1 "Inspector" 6 "Algorithm" 11 "Realized") r(1))
					;
					#delim cr

						graph export "$output\\${figurename`m'_0bureau}.pdf", as(pdf) replace	

			restore
}

foreach m in 3 {

cap drop yhat*

			*Prepare tables for estimation results
			matrix results = J(14, 15, 0)
			
			************************	
			*Full audits
			************************
			
				eststo olsvg`m': qui regress y2 ${model`m'}  if dgid == 1 & controle == 2 
						predict yhatolsVG if controle == 2 	
						
						gen residual = yhatolsVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual
						
				eststo lassovg`m': qui lasso linear y2 ${model`m'}   if dgid == 1 & controle == 2, lambda(0.025)
						predict yhatlassoVG if controle == 2 	
						
						gen residual = yhatlassoVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual	
						
				qui rforest y2 ${model`m'rf}  if dgid == 1 & controle == 2, type(reg)
						predict yhatrfVG if controle == 2 

						gen residual = yhatrfVG - y2
						replace residual = residual^2
						sum residual 
						local mse = round(r(mean), 0.01)
						drop residual
						
						*Add the importance variable in the e(b) matrix for esttab 
						matrix importance = e(importance)
						
						qui regress y2 ${model`m'rf}  if dgid == 1 & controle == 2
						local N = `e(N)'						
						*Fill in table
						matrix b = e(b)
						local colnames: colnames b
						local r = 0
						foreach v in `colnames' {
							di "`v'"
							local ++r
							matrix b[1,`r'] = 0
							cap matrix b[1,`r']=importance["`v'",1]
						}	
						
						eststo rfvg`m': ereturn post b 
						estadd local mse = `mse'
						estadd local N = `N'

				qui rforest y2  ${model`m'rfc} if dgid == 1 & controle == 2 , type(reg)
						predict yhatrf_cVG if controle == 2 
				
			************************	
			*Desk audits
			************************

			qui regress y2 ${model`m'} if dgid == 1 & controle == 1
					predict yhatolsCP if controle == 1

			qui lasso linear y2 ${model`m'} if dgid == 1 & controle == 1 
					predict yhatlassoCP if controle == 1
				
			qui rforest y2 ${model`m'rf} if dgid == 1 & controle == 1, type(reg)
					predict yhatrfCP if controle == 1 
				
			qui rforest y2 ${model`m'rfc} if dgid == 1 & controle == 1, type(reg)
					predict yhatrf_cCP if controle == 1 				
			
			*****************************************
			*TABLES USING PREDICTED VALUE AS CONTROL
			*****************************************	
			foreach audit in "CP" "VG" {

			local n = 0
			foreach predict in ols lasso rf rf_c {
			local ++n
				gen predicted = yhat`predict'`audit'
					eststo r`n'`audit': reg y2 predicted algorithm , vce(robust)
					gen sq_diff = (y2 - predicted)^2
					sum sq_diff if dgid == 1
					estadd local MSE = round(`r(mean)', 0.01)
					
				drop predicted sq_diff
				}
			}

			*Export table
			#delim ;
			esttab r1VG r2VG r3VG r4VG r1CP r2CP r3CP r4CP
					using "$output\10 prediction models `m'.tex",
					order(  predicted algorithm )
					label se keep(  predicted algorithm)
					nomtitles		nonumbers
					coeflabels(predicted "Prediction" algorithm "Algorithm")
					s(N r2 MSE, label("N" "R2" "MSE")) 
					star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
					prehead("") 
					posthead("") postfoot("\hline")
					replace
					substitute(\_ _)
				;
			#delim cr

			*****************************************~
			*STORE RESULTS IN MATRICES
			*****************************************
			*Summary table with results
			matrix results`m' = J(12, 12, 1)
			matrix colnames  results`m' = "x" "VG" "algorithm" "realized"  "predicted" "model" "p1" "p25" "p50" "p75" "p99" "MSPE"

			*All years 
			local r = 0
			local audittype = 0

			foreach audit in "CP" "VG" {
			local ++audittype
			local x = 0 

				foreach algorithm in "0" "1"  {

				local model = 0 

					foreach predict in ols lasso rf_c {

					local ++model 
					local ++r
					local ++x

					matrix results`m'[`r', 1] = `x'
					matrix results`m'[`r', 2] = `audittype'
					matrix results`m'[`r', 3] = `algorithm'

					sum y2 if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 4] = `r(mean)'
									
					sum yhat`predict'`audit' if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 5] = `r(mean)'

					matrix results`m'[`r', 6] = `model'

					*Get the prediction distribution (stored in matrices)
					svmat pred`m'`audit' 

					*The predictions are numbered according to the models, so we can use the `model' local to obtain the prediction distributions
					sum pred`m'`audit'`model', d
					matrix results`m'[`r', 7] = `r(p1)'
					matrix results`m'[`r', 8] = `r(p25)'
					matrix results`m'[`r', 9] = `r(p50)'
					matrix results`m'[`r', 10] = `r(p75)'
					matrix results`m'[`r', 11] = `r(p99)'

					drop pred`m'`audit'*

					*Get the MSPE associated with that model
					svmat MSE`m'`audit'
					sum MSE`m'`audit'`model', d
					matrix results`m'[`r', 12] = `r(mean)'

					drop MSE`m'`audit'*

					}

				local ++x

				}

			}

			*****************************************
			*MATRICES by bureau
			*****************************************
			*Summary table with results
			matrix resultsb`m' = J(20, 6, 1)
			matrix colnames  resultsb`m' = "x" "VG" "algorithm" "realized"  "predicted" "model"

			*All years 
			local r = 0
			local audittype = 0

			foreach audit in "CP" "VG" {
			local ++audittype
			local x = 0 
					
				foreach numeric in 1 2 3 4 5 {

					foreach algorithm in "0" "1"  {

					local ++r
					local ++x
					
					matrix resultsb`m'[`r', 1] = `x'
					matrix resultsb`m'[`r', 2] = `audittype'
					matrix resultsb`m'[`r', 3] = `algorithm'
					
					sum y2 if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric'
					matrix resultsb`m'[`r', 4] = `r(mean)'
									
					sum yhatrf_c`audit' if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric'

					matrix resultsb`m'[`r', 5] = `r(mean)'

					matrix resultsb`m'[`r', 6] = `numeric'
					
					}

				local ++x

				}
		}
}
/*
*****************************************
*TRAIN MODEL USING ALGORITHM DATA AND EXTRAPOLATE TO INSPECTORS DATA (SANITY CHECK)
*****************************************
*/
local m = 3
foreach m in 3 {

cap drop yhat*

			*Prepare tables for estimation results
			matrix results = J(14, 15, 0)
			
			************************	
			*Full audits
			************************
			
				eststo olsvg`m': qui regress y2 ${model`m'}  if algorithm == 1 & controle == 2 
						predict yhatolsVG if controle == 2 	
						
						gen residual = yhatolsVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual
						
				eststo lassovg`m': qui lasso linear y2 ${model`m'}  if algorithm == 1 & controle == 2, lambda(0.025)
						predict yhatlassoVG if controle == 2 	
						
						gen residual = yhatlassoVG - y2
						replace residual = residual^2
						sum residual 
						estadd local mse = round(r(mean), 0.01)
						drop residual	
						
				qui rforest y2 ${model`m'rf}  if algorithm == 1 & controle == 2, type(reg)
						predict yhatrfVG if controle == 2 

						gen residual = yhatrfVG - y2
						replace residual = residual^2
						sum residual 
						local mse = round(r(mean), 0.01)
						drop residual
						
						*Add the importance variable in the e(b) matrix for esttab 
						matrix importance = e(importance)
						
						qui regress y2 ${model`m'rf}  if algorithm == 1 & controle == 2
						local N = `e(N)'						
						*Fill in table
						matrix b = e(b)
						local colnames: colnames b
						local r = 0
						foreach v in `colnames' {
							di "`v'"
							local ++r
							matrix b[1,`r'] = 0
							cap matrix b[1,`r']=importance["`v'",1]
						}	
						
						eststo rfvg`m': ereturn post b 
						estadd local mse = `mse'
						estadd local N = `N'

				qui rforest y2  ${model`m'rfc} if algorithm == 1 & controle == 2 , type(reg)
						predict yhatrf_cVG if controle == 2 
						
			************************	
			*Desk audits
			************************

			qui regress y2 ${model`m'} if algorithm == 1 & controle == 1
					predict yhatolsCP if controle == 1

			qui lasso linear y2 ${model`m'} if algorithm == 1 & controle == 1 
					predict yhatlassoCP if controle == 1
				
			qui rforest y2 ${model`m'rf} if algorithm == 1 & controle == 1, type(reg)
					predict yhatrfCP if controle == 1 
				
			qui rforest y2 ${model`m'rfc} if algorithm == 1 & controle == 1, type(reg)
					predict yhatrf_cCP if controle == 1 				
		
			*****************************************~
			*STORE RESULTS IN MATRICES
			*****************************************
			*Summary table with results
			matrix results`m' = J(12, 6, 1)
			matrix colnames  results`m' = "x" "VG" "algorithm" "realized"  "predicted" "model" 

			*All years 
			local r = 0
			local audittype = 0

			foreach audit in "CP" "VG" {
			local ++audittype
			local x = 0 

				foreach algorithm in "0" "1"  {

				local model = 0 

					foreach predict in ols lasso rf_c {

					local ++model 
					local ++r
					local ++x

					matrix results`m'[`r', 1] = `x'
					matrix results`m'[`r', 2] = `audittype'
					matrix results`m'[`r', 3] = `algorithm'

					sum y2 if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 4] = `r(mean)'
									
					sum yhat`predict'`audit' if controle == `audittype' & algorithm == `algorithm'
					matrix results`m'[`r', 5] = `r(mean)'

					matrix results`m'[`r', 6] = `model'

					}

				local ++x

				}

			}
}


foreach m in 3 {

			preserve 

					clear 
					svmat results`m', names(col)
					
						#delim; 
						tw 
						
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 1, color(black) msymbol(circle))
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 2, color(black)  msymbol(diamond))
						(scatter predicted x if algorithm == 0 & VG == 2 & model == 3, color(black)  msymbol(triangle))

						(scatter predicted x if algorithm == 1 & VG == 2 & model == 1, color(black%50) msymbol(circle))
						(scatter predicted x if algorithm == 1 & VG == 2 & model == 2, color(black%50) msymbol(diamond))
						(scatter predicted x if algorithm == 1 & VG == 2 & model == 3, color(black%50) msymbol(triangle))

						(line realized x if algorithm == 0 & VG == 2, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 2, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						ylabel(-0.1(0.05)0.12)

						legend(order(- "Predictions: " 4 "OLS" 5 "Lasso" 6 "Random Forest") r(1))
	
						;
						#delim cr

					graph export "$output\10 predicted vs realized full audits characteristics and filing trained on algorithm.pdf", as(pdf) replace	
					
					*CP graph Predicted vs realized 
						#delim; 
						tw 
						
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 1, color(black) msymbol(circle))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 2, color(black)  msymbol(diamond))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 3, color(black)  msymbol(triangle))
						(scatter predicted x if algorithm == 0 & VG == 1 & model == 4, color(black)  msymbol(X))

						(scatter predicted x if algorithm == 1 & VG == 1 & model == 1, color(black%50) msymbol(circle))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 2, color(black%50) msymbol(diamond))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 3, color(black%50) msymbol(triangle))
						(scatter predicted x if algorithm == 1 & VG == 1 & model == 4, color(black%50) msymbol(X))

						(line realized x if algorithm == 0 & VG == 1, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 1, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						ylabel(-0.1(0.05)0.12)
						legend(order(- "Predictions: " 4 "OLS" 5 "Lasso" 6 "Random Forest") r(1))
	
						;
						#delim cr

					graph export "$output\10 predicted vs realized desk audits characteristics and filing trained on algorithm.pdf", as(pdf) replace	

			restore
}
/*
*****************************************~
*Undestand role of distance
*****************************************		

xtile quartiledistance = distance, nq(4)
xtile quartileduration = durationcar, nq(4)

eststo ols1: regress y2 i.quartiledistance L1turnover if dgid == 1 & controle == 2 
eststo ols2: regress y2 i.quartiledistance L1turnover if controle == 2 
eststo ols3: regress y2 i.quartileduration L1turnover if dgid == 1 & controle == 2 
eststo ols4: regress y2 i.quartileduration L1turnover if controle == 2 

#delim ;
esttab ols1 ols2 ols3 ols4 
		using "$output\10 prediction models distance analysis.tex",
		label se drop(1.quartile* _cons) order(L1turnover)
		nomtitles	nocons	nonumbers
		s(N, label("N")) 
		star(* 0.10 ** 0.05 *** 0.01) noomitted noconstant   
		prehead("") 
		coeflabels(2.quartiledistance "2 Quart. Distance" 3.quartiledistance "3 Quart. Distance"  4.quartiledistance "4 Quart. Distance"  2.quartileduration "2 Quart. Duration"  3.quartileduration "3 Quart. Duration" 4.quartileduration "4 Quart. Duration")
		posthead("") postfoot("\hline")
		replace
		substitute(\_ _)
	;
#delim cr

************************	
*Predict the probability of detection of evasion
************************
foreach outcome in y4 y11 {

	foreach m in 1 2 3 {

	cap drop yhat*  

			regress `outcome' ${model`m'}  if dgid == 1 & controle == 2 & originaly2 == 1
					predict yhatolsVG if controle == 2 

			lasso linear `outcome' ${model`m'}  if dgid == 1 & controle == 2 & originaly2 == 1
					predict yhatlassoVG if controle == 2 

			rforest `outcome' ${model`m'rf}  if dgid == 1 & controle == 2 & originaly2 == 1, type(reg)
					predict yhatrfVG if controle == 2 

			rforest `outcome'  ${model`m'rfc} if dgid == 1 & controle == 2 & originaly2 == 1, type(reg)
					predict yhatrf_cVG if controle == 2 

			************************	
			*Desk audits
			************************

			regress `outcome' ${model`m'} if dgid == 1 & controle == 1 & originaly2 == 1
					predict yhatolsCP if controle == 1

			lasso linear `outcome' ${model`m'} if dgid == 1 & controle == 1 & originaly2 == 1
					predict yhatlassoCP if controle == 1

			rforest `outcome' ${model`m'rf} if dgid == 1 & controle == 1 & originaly2 == 1, type(reg)
					predict yhatrfCP if controle == 1 

			rforest `outcome' ${model`m'rfc} if dgid == 1 & controle == 1 & originaly2 == 1, type(reg)
					predict yhatrf_cCP if controle == 1 		

			*Predict values
			*rforest notificationvalue L1turnover L2turnover L3turnover L1profit L2profit L3profit firmage durationcar distance inspectorclusteryear  i.activity_group if y2 == 1 & controle == 2, type(reg)
			*		predict nothatrf_cVG if controle == 2 			

			***Obs
						*how to compute confidence intervals for these predictions? 
						*for the linear regression, I think I could do it by using the predict, stdp command in stata (though probably there are some computations needed to aggregate it to obtain the standard error of the mean)
						*for random forest, probably the only way is via bootstrap

				*****************************************~
				*GRAPHS
				*****************************************
				*Summary table with results
				matrix results = J(12, 7, 1)
				matrix colnames  results = "x" "VG" "algorithm" "realized"  "predictedex" "predictednonex" "model"

				*All years 
				local r = 0
				local audittype = 0

				foreach audit in "CP" "VG" {
				local ++audittype
				local x = 0 
					
					foreach algorithm in "0" "1"  {
					
					local model = 0 
					
						foreach predict in ols lasso rf_c {
						
						local ++model 
						local ++r
						local ++x
						
						matrix results[`r', 1] = `x'
						matrix results[`r', 2] = `audittype'
						matrix results[`r', 3] = `algorithm'
						
						sum `outcome' if controle == `audittype' & algorithm == `algorithm'
						matrix results[`r', 4] = `r(mean)'
										
						sum yhat`predict'`audit' if controle == `audittype' & algorithm == `algorithm' & originaly2 == 1 
						matrix results[`r', 5] = `r(mean)'
						
						sum yhat`predict'`audit' if controle == `audittype' & algorithm == `algorithm' & originaly2 == 0 
						matrix results[`r', 6] = `r(mean)'					

						matrix results[`r', 7] = `model'
						
						}
						
					local ++x
					
					}
					
				}

				*Plot graphs
				preserve 

						clear 
						svmat results, names(col)

						*Predicted vs realized 
						#delim: 
						tw 
						(scatter predictedex x if algorithm == 0 & VG == 2 & model == 1, color(black) msymbol(circle))
						(scatter predictedex x if algorithm == 0 & VG == 2 & model == 2, color(black)  msymbol(diamond))
						(scatter predictedex x if algorithm == 0 & VG == 2 & model == 3, color(black)  msymbol(triangle))
						
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 1, color(red) msymbol(circle))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 2, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 3, color(red)  msymbol(triangle))

						(scatter predictedex x if algorithm == 1 & VG == 2 & model == 1, color(black%50) msymbol(circle))
						(scatter predictedex x if algorithm == 1 & VG == 2 & model == 2, color(black%50) msymbol(diamond))
						(scatter predictedex x if algorithm == 1 & VG == 2 & model == 3, color(black%50) msymbol(triangle))
						
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 1, color(red%50) msymbol(circle))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 2, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 3, color(red%50) msymbol(triangle))

						(line realized x if algorithm == 0 & VG == 2, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 2, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						legend(order(- "Predictions: " 1 "OLS" 2 "Lasso" 3 "Random Forest") r(1))
						;
						#delim cr

							graph export "$output\\${figurename`m'_1} detection `outcome'.pdf", as(pdf) replace	


						#delim: 
						tw 
						(scatter predictedex x if algorithm == 0 & VG == 1 & model == 1, color(black) msymbol(circle))
						(scatter predictedex x if algorithm == 0 & VG == 1 & model == 2, color(black)  msymbol(diamond))
						(scatter predictedex x if algorithm == 0 & VG == 1 & model == 3, color(black)  msymbol(triangle))
						
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 1, color(red) msymbol(circle))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 2, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 3, color(red)  msymbol(triangle))

						(scatter predictedex x if algorithm == 1 & VG == 1 & model == 1, color(black%50) msymbol(circle))
						(scatter predictedex x if algorithm == 1 & VG == 1 & model == 2, color(black%50) msymbol(diamond))
						(scatter predictedex x if algorithm == 1 & VG == 1 & model == 3, color(black%50) msymbol(triangle))
						
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 1, color(red%50) msymbol(circle))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 2, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 3, color(red%50) msymbol(triangle))

						(line realized x if algorithm == 0 & VG == 1, lcolor(black) lwidth(thick))
						(line realized  x if algorithm == 1 & VG == 1, lcolor(black%50) lwidth(thick))

						,
						xlabel(2 "Inspectors" 6 "Algorithm")
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						legend(order(- "Predictions: " 1 "OLS" 2 "Lasso" 3 "Random Forest") r(1))
						;
						#delim cr

							graph export "$output\\${figurename`m'_0} detection `outcome'.pdf", as(pdf) replace	

				restore

				*****************************************
				*Graphs by bureau
				*****************************************
				*Summary table with results
				matrix results = J(20, 7, 1)
				matrix colnames  results = "x" "VG" "algorithm" "realized"  "predictedex" "predictednonex" "model"

				*All years 
				local r = 0
				local audittype = 0

				foreach audit in "CP" "VG" {
				local ++audittype
				local x = 0 
						
					foreach numeric in 1 2 3 4 5 {

						foreach algorithm in "0" "1"  {

						local ++r
						local ++x
						
						matrix results[`r', 1] = `x'
						matrix results[`r', 2] = `audittype'
						matrix results[`r', 3] = `algorithm'
						
						sum `outcome' if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric'
						matrix results[`r', 4] = `r(mean)'
										
						sum yhatrf_c`audit' if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric' & originaly2 == 1
						matrix results[`r', 5] = `r(mean)'
						
						sum yhatrf_c`audit' if controle == `audittype' & algorithm == `algorithm' & numeric_bureau == `numeric' & originaly2 == 0
						matrix results[`r', 6] = `r(mean)'					

						matrix results[`r', 7] = `numeric'
						
						}
						
					local ++x
					
					}
					
				}

				*Plot graphs
				preserve 

						clear 
						svmat results, names(col)

						*Predicted vs realized 
						#delim: 
						tw 
						(bar predictedex x if algorithm == 0 & VG == 2 & model == 1, color(navy) msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 2 & model == 2, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 2 & model == 3, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 2 & model == 4, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 2 & model == 5, color(navy)  msymbol(diamond))

						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 1, color(red) msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 2, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 3, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 4, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 2 & model == 5, color(red)  msymbol(diamond))					
						
						(bar predictedex x if algorithm == 1 & VG == 2 & model == 1, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 2 & model == 2, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 2 & model == 3, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 2 & model == 4, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 2 & model == 5, color(orange%50) msymbol(diamond))
						
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 1, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 2, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 3, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 4, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 2 & model == 5, color(red%50) msymbol(diamond))					
						(scatter realized x if model == 1 & VG == 2, color(black%50) msymbol(T))
						(scatter realized x if model == 2 & VG == 2, color(black%50) msymbol(T))
						(scatter realized x if model == 3 & VG == 2, color(black%50) msymbol(T))
						(scatter realized x if model == 4 & VG == 2, color(black%50) msymbol(T))
						(scatter realized x if model == 5 & VG == 2, color(black%50) msymbol(T))

						,
						xlabel(1.5 "Large Taxpayers" 4.5 "Medium Taxpayers 1" 7.5 "Medium Taxpayers 2" 10.5 "Liberal Professions" 13.5 "SME", labsize(small))
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						legend(order(1 "Inspector" 11 "Algorithm" 21 "Realized" 6 "Predicted non executed") r(1) size(small))
						;
						#delim cr

							graph export "$output\\${figurename`m'_1bureau} detection `outcome'.pdf", as(pdf) replace	


						#delim: 
						tw 
						(bar predictedex x if algorithm == 0 & VG == 1 & model == 1, color(navy) msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 1 & model == 2, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 1 & model == 3, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 1 & model == 4, color(navy)  msymbol(diamond))
						(bar predictedex x if algorithm == 0 & VG == 1 & model == 5, color(navy)  msymbol(diamond))

						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 1, color(red) msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 2, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 3, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 4, color(red)  msymbol(diamond))
						(scatter predictednonex x if algorithm == 0 & VG == 1 & model == 5, color(red)  msymbol(diamond))					
						
						(bar predictedex x if algorithm == 1 & VG == 1 & model == 1, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 1 & model == 2, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 1 & model == 3, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 1 & model == 4, color(orange%50) msymbol(diamond))
						(bar predictedex x if algorithm == 1 & VG == 1 & model == 5, color(orange%50) msymbol(diamond))
						
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 1, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 2, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 3, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 4, color(red%50) msymbol(diamond))
						(scatter predictednonex x if algorithm == 1 & VG == 1 & model == 5, color(red%50) msymbol(diamond))		
						
						(scatter realized x if model == 1 & VG == 1, color(black%50) msymbol(T))
						(scatter realized x if model == 2 & VG == 1, color(black%50) msymbol(T))
						(scatter realized x if model == 3 & VG == 1, color(black%50) msymbol(T))
						(scatter realized x if model == 4 & VG == 1, color(black%50) msymbol(T))
						(scatter realized x if model == 5 & VG == 1, color(black%50) msymbol(T))
						,
						xlabel(1.5 "Large Taxpayers" 4.5 "Medium Taxpayers 1" 7.5 "Medium Taxpayers 2" 10.5 "Liberal Professions" 13.5 "SME", labsize(small))
						ytitle("p.p. relative to F.E. benchmark")
						xtitle("")
						title("") 
						legend(order(1 "Inspector" 11 "Algorithm" 21 "Realized" 6 "Predicted non executed") r(1) size(small))
						;
						#delim cr

							graph export "$output\\${figurename`m'_0bureau} detection `outcome'.pdf", as(pdf) replace	

				restore

	}
}

******************************
*Prediction of evasion amounts 
******************************
set seed 1908345
cap drop n
cap drop N

foreach m in 3 {

local m = 3
cap drop yhat*  
		
		*Estimate the model 100 times taking random draws of 70% of DGID cases
		matrix pred`m'VG = J(100, 3, 0)
		matrix pred`m'CP = J(100, 3, 0)
		
		matrix MSE`m'VG = J(100, 3, 0)
		matrix MSE`m'CP = J(100, 3, 0)
		
		forvalues d = 1/100 {
			
			di `d'
			
			*Select sample randomly
			gen xrand = runiform()
			sort dgid controle xrand 
			by dgid controle: gen n = _n
			by dgid controle: gen N = _N
			gen training = n/N < 0.7 if dgid == 1
			drop n N
		
			qui regress originaly4 ${model`m'}  if dgid == 1 & controle == 2 & training == 1
					predict yhatolsVG if controle == 2 

			qui lasso linear originaly4 ${model3}   if dgid == 1 & controle == 2 & training == 1
					predict yhatlassoVG if controle == 2 

			qui rforest originaly4  ${model3rf} if dgid == 1 & controle == 2 & training == 1 &  originaly4 != ., type(reg)
					predict yhatrf_cVG if controle == 2 
			
			local c = 0 
			qui foreach v in yhatolsVG yhatlassoVG  yhatrf_cVG { 
				
				local ++c
				sum `v' if dgid == 1
				matrix pred`m'VG[`d', `c'] = `r(mean)'
				
				gen sq_diff = (originaly4 - `v')^2 if dgid == 1
				sum sq_diff if training == 0, d 
				matrix MSE`m'VG[`d', `c'] = `r(mean)'
				drop sq_diff
				
			}
			
			drop yhatolsVG yhatlassoVG yhatrf_cVG 
			
		************************	
		*Desk audits
		************************

		qui regress originaly4 ${model3} if dgid == 1 & controle == 1 & training == 1
				predict yhatolsCP if controle == 1
				
		qui lasso linear originaly4 ${model3} if dgid == 1 & controle == 1 & training == 1
				predict yhatlassoCP if controle == 1
			
		*qui rforest y2 ${model`m'rf} if dgid == 1 & controle == 1 & training == 1, type(reg)
		*		predict yhatrfCP if controle == 1 
			
		qui rforest originaly4 ${model3rf} if dgid == 1 & controle == 1 & training == 1 & originaly4 != ., type(reg)
				predict yhatrf_cCP if controle == 1 		

			local c = 0 
			qui foreach v in yhatolsCP yhatlassoCP  yhatrf_cCP { 
				
				local ++c
				sum `v' if dgid == 1
				matrix pred`m'CP[`d', `c'] = `r(mean)'
				
				gen sq_diff = (originaly4 - `v')^2 if dgid == 1 
				sum sq_diff if training == 0, d 
				matrix MSE`m'CP[`d', `c'] = `r(mean)'
				drop sq_diff
				
			}
			drop yhatolsCP yhatlassoCP  yhatrf_cCP
			drop xrand 
			drop training
		}
}

******************************
*Figures of predicted evasion distributions and execution
******************************
use "$analysisdata/proc data/datasetforanalysis_predictionexercise.dta", clear 

replace y7 = y7*20

*Locals for graphs
local titleoriginaly4 "evasion"
local titleoriginalevasion_cost1 "cost"
local titley7 "rate"

*Locals for graphs: axis width
local cutoriginaly4 10 
local cutoriginalevasion_cost1 9 
local cuty7 0

local audit1 "CP"
local audit2 "VG"

foreach controltype in 1 2 {
	
	cap drop mseols msepoisson mserf
	if `controltype' == 1 {
	 svmat MSE3VG
	}
	if `controltype' == 2 {
	cap svmat MSE3CP
	} 
	
	cap rename (MSE3VG1 MSE3VG2 MSE3VG3) (mseols msepoisson mserf)
	cap rename (MSE3CP1 MSE3CP2 MSE3CP3) (mseols msepoisson mserf)
	
	*Loop over outcome variables
	foreach v in originaly4 originalevasion_cost1 y7 {

		cap drop yhatrf 
		cap drop n  
		cap drop predictionerror
		cap drop bin*
		cap drop yhat_nonexecuted*
		cap drop yhat_executed*
		cap drop originalevasion_count
		cap drop count 
		cap drop mean
		cap drop originaly2_mean
		cap drop `v'_count
		cap drop originaly4_count
		
		**********************************
		*Run Random Forest Model
		**********************************
		rforest `v' ${model3rfc} algorithm if controle == `controltype' & originaly2 == 1 & `v' != ., type(reg)
				predict yhatrf if controle == `controltype' 
					
		*Compute prediction model
		gen predictionerror = `v' - yhatrf 	
		sort `v'
		gen n = _n 
	
		*Compute accumulated density 
		sum n if `v' != .
		replace n = n/r(max)
		replace n = . if `v' == .
		
		*Create equally spaced bins 
		sum yhatrf if controle == `controltype', d 
		local min = floor(r(min))
		local max = floor(r(max))	

		gen bin = . 
		forvalues x = `min'/`max' {
			replace bin = `x' + 0.5 if yhatrf >= `x' &  yhatrf < `x' + 1 & controle == `controltype' 
		}			
		
		*Count the number of observations within the bin
		gen yhat_nonexecuted = originaly2 == 0 if yhatrf != .
		gen yhat_executed = originaly2 == 1 if yhatrf != .

		foreach vv in yhat_nonexecuted yhat_executed {
				bys bin: egen count = total(`vv')
				gen `vv'_count = count
				drop count
		}

		*Create bins for the original variable
		sum `v' if  controle ==  `controltype' & originaly2 == 1, d 
		local min = floor(r(min))
		local max = floor(r(max))	

		gen bin_original = . 
		forvalues x = `min'/`max' {
			replace bin_original = `x' + 0.5  if `v' >= `x' &  `v' < `x' + 1
		}	

		gen originalevasion = `v' != . & controle == `controltype' 
		*Count the number of observations within the bin
		foreach vv in originalevasion  {
				bys bin_original: egen count = total(`vv')
				gen `vv'_count = count
				drop count
		}

		*Transform the variables of count in percentages 
		foreach vv in  yhat_executed yhat_nonexecuted  originalevasion {
			egen total = total(`vv')
			replace `vv'_count = `vv'_count/total
			drop total
		}

		*Compute the mean execution based on the bins of predicted values
		foreach vv in originaly2 {
				bys bin: egen mean = mean(`vv')
				gen `vv'_mean = mean
				drop mean
		}

		*Obtain statistics of prediction error (stored in matrices)
		sum mseols
		local mspeols = round(r(mean), 0.1)
		sum mserf		
		local msperf = round(r(mean), 0.1)
		local textoriginaly4 `"text(0.5 6 "MSPE: `mspeols' for OLS and `msperf' for RF", place(c) size(small))"' 

		sort  bin_original
	
		*Density figures + Line of conditional execution
		#delim ; 
		tw 
		(connected yhat_nonexecuted_count bin if originaly2 == 0 & bin > `cut`v'', col(navy%50) recast(area) sort(bin)) 
		(connected yhat_executed_count bin if originaly2 == 1 & bin > `cut`v'', recast(area) col(dkgreen%50) sort(bin)) 
		(connected originalevasion_count bin_original if controle == `controltype' & originaly2 == 1 & bin_original > `cut`v'', recast(area) col(red%50) sort(bin_original)) 
		(lpoly originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'', lcolor(black) lwidth(thick))		
		(lpolyci originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'', level(90) color(black%30) )
		(scatter originalevasion_count bin_original if controle == `controltype' & bin_original < 1, col(red%50) sort(bin_original)), 
		legend(order(1 "Predicted evasion, non-executed" 2 "Predicted evasion, executed" 3 "Detected evasion" 4 "P(execution|predicted evasion)") c(1))
		`text`v''
		;
		#delim cr 

		graph export "$output\10 density predicted `title`v'' `audit`controltype''.pdf", as(pdf) replace	

		*CDF with prediction errors
		#delim ; 
		tw 
		(line n `v'  if controle == `controltype' & originaly2 == 1 & `v'  > 0, lwidth(vthick) col(orange)) 
		(line n `v' if controle == `controltype' & originaly2 == 1 & `v'  == 0, lwidth(vthick) col(orange)) 
		(rcap `v' yhatrf n if controle == `controltype' & originaly2 == 1 &  `v' >= yhatrf, horizontal  col(black%50)) 
		(rcap `v' yhatrf n if controle == `controltype' & originaly2 == 1 &  originaly4 < yhatrf, horizontal  col(gray%50))
		,
		legend(order(3 "Prediction error"))
		ytitle("Cumulative density")
		xtitle("Detected evasion (log)")
		;
		#delim cr

		graph export "$output\10 CDF `title`v'' and error `audit`controltype''.pdf", as(pdf) replace	

		*Distribution of predicted evasion for algorithm vs DGID
		#delim ; 
		tw 
		(histogram yhatrf if dgid == 0 & bin > `cut`v'', col(green%50) recast(area) sort(bin)) 
		(histogram yhatrf if dgid == 1 & bin > `cut`v'', col(navy%50) recast(area) sort(bin)) 	
		,
		xtitle("")
		legend(order(1 "P(execution|prediction & alg.)" 2 "P(execution|prediction & insp.)") r(2))
		;
		#delim cr 

		graph export "$output\10 prediction alg vs insp `title`v'' `audit`controltype''.pdf", as(pdf) replace	

		*Distribution of predicted evasion for algorithm vs DGID + line for execution 
		#delim ; 
		tw 
		(histogram yhatrf if dgid == 0 & bin > `cut`v'', col(green%50) recast(area) sort(bin)) 
		(histogram yhatrf if dgid == 1 & bin > `cut`v'', col(navy%50) recast(area) sort(bin)) 	
		(lpolyci originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'' & dgid == 0,  level(90) color(green%30) )
		(lpolyci originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'' & dgid == 1, level(90) color(navy%30) )
		(lpoly originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'' & dgid == 0,   lcolor(green) lwidth(thick))
		(lpoly originaly2 yhatrf if controle == `controltype' & yhatrf > `cut`v'' & dgid == 1,  lcolor(navy) lwidth(thick))			
		,
		legend(order(7 "P(execution|prediction & alg.)" 8 "P(execution|prediction & insp.)") r(2))
		;
		#delim cr 

		graph export "$output\10 execution and prediction alg vs insp `title`v'' `audit`controltype''.pdf", as(pdf) replace	
 		
		drop originalevasion
	}
}

******************************
*Graphs of Algorithm and Inspector prediction densities and execution
******************************

		**********************************
		*Run Random Forest Model
		**********************************
rforest originaly4 ${model3rfc} algorithm if controle == 2 & originaly2 == 1 & originaly4 != ., type(reg)
		predict yhatrf if controle == 2
	
cap drop total 
	foreach type in algorithm dgid { 
		preserve 
		cap drop yhat_executed 
		cap drop yhat_nonexecuted
		cap drop yhat_executed_count yhat_nonexecuted_count
		keep if `type' == 1 
		
		*Create equally spaced bins 
		sum yhatrf if controle == 2, d 
		local min = floor(r(min))
		local max = floor(r(max))	
		cap drop bin
		gen bin = . 
		forvalues x = `min'/`max' {
			replace bin = `x' + 0.5 if yhatrf >= `x' &  yhatrf < `x' + 1 & controle ==2 
		}			
		
		*Count the number of observations within the bin
		gen yhat_nonexecuted = originaly2 == 0 if yhatrf != .
		gen yhat_executed = originaly2 == 1 if yhatrf != .

		foreach vv in yhat_nonexecuted yhat_executed {
				bys bin: egen count = total(`vv')
				gen `vv'_count = count
				drop count
		}

		*Transform the variables of count in percentages 
		foreach vv in  yhat_executed yhat_nonexecuted  {
			egen total = total(`vv')
			replace `vv'_count = `vv'_count/total
			drop total
		}		
		
		*Create bins for the original variable
		sum originaly4 if controle == 2 & originaly2 == 1, d 
		local min = floor(r(min))
		local max = floor(r(max))	

		cap drop bin_original
		gen bin_original = . 
		forvalues x = `min'/`max' {
			replace bin_original = `x' + 0.5  if originaly4 >= `x' & originaly4 < `x' + 1
		}	
		
		cap drop  originaly2_mean
		cap drop mean
		*Compute the mean execution based on the bins of predicted values
		foreach vv in originaly2 {
				bys bin: egen mean = mean(`vv')
				gen `vv'_mean = mean
				drop mean
		}

		*Density figures + Line of conditional execution (without realized distribution)
		#delim ; 
		tw 
		(connected yhat_nonexecuted_count bin if originaly2 == 0 & bin > 10 , col(navy%50) recast(area) sort(bin)) 
		(connected yhat_executed_count bin if originaly2 == 1 & bin > 10 , recast(area) col(dkgreen%50) sort(bin)) 
		(lpoly originaly2 yhatrf if controle == 2 & yhatrf > 10, lcolor(black) lwidth(thick))		
		,
		legend(order(1 "Predicted evasion, non-executed" 2 "Predicted evasion, executed" 3 "P(execution|predicted evasion)") c(1))
		`text`v''
		;
		#delim cr 
		
		graph export "$output\10 density predicted evasion `type'.pdf", as(pdf) replace	
		cap drop yhat_nonexecuted 
		cap drop yhat_executed 
		cap drop yhat_executed_count yhat_nonexecuted_count

		restore 
	}

********************************************
*EX POST OPTIMIZED ALGORITHM
*Obs: Use prediction and see what the best evasion recovery could look like
********************************************
use "$analysisdata/proc data/datasetforanalysis_predictionexercise.dta", clear 

gen uniqueid = _n

global model3rfc  "L*filed* L1turnover L2turnover L3turnover L1profitrate L2profitrate L3profitrate L1productivity L2productivity L3productivity  firmage durationcar distance"

local lweighted0 ""
local lweighted1 "weighted"

gen executedinsp = originaly2*dgid
gen executedalg = originaly2*algorithm

*Loop over weighted or not 
foreach weighted in  0 1 {
	
	*Loop over the two types of audits 
	forvalues c = 1/2 {
			
		preserve 

		keep if controle == `c'

		*Only when using weights (expand the sample based on weights)
		if `weighted' == 1 {
		summarize originaly4, d
		expand 10 if originaly4  > 20
		}
		
		rforest originaly4 ${model3rfc} algorithm if  originaly2 == 1 & originaly4 != ., type(reg)
				predict yhatrf  	
		
		*Only when using weights (drop the expanded samples)
		if `weighted' == 1 {
		bys uniqueid: gen n = _n
		keep if n == 1
		drop n
		}
		
		*Count how many cases were executed 	
		bys inspectorclusteryear: egen totalexecuted = total(originaly2)	
		bys inspectorclusteryear: egen totalexecutedinsp = total(executedinsp)	
		bys inspectorclusteryear: egen totalexecutedalg = total(executedalg)	

		*Unconstrained optimization (only constraint is that the number of executed cases within list must be fixed)
			*Rank the cases by the amount of predicted evasion 
			gsort inspectorclusteryear -yhatrf
			by inspectorclusteryear : gen n = _n 

			gen optimized_all = n <= totalexecuted
			drop n

			*Optimize only among algorithm
			gsort inspectorclusteryear algorithm -yhatrf
			by inspectorclusteryear: gen n = _n 

			gen optimized_inspectors = n <= totalexecuted
			drop n 

			gsort inspectorclusteryear -algorithm -yhatrf
			by inspectorclusteryear: gen n = _n 

			gen optimized_algorithm = n <= totalexecuted
			drop n 
			
			*Optimize only based on size
			gsort inspectorclusteryear -L1turnover
			by inspectorclusteryear: gen n = _n 

			gen optimized_size = 0
			replace optimized_size  = 1 if n <= totalexecuted
			drop n 
			
		*Constrained optimization (keep fixed the number and distribution of algorithm and inspector cases executed in each list)
			*Rank the cases by the amount of predicted evasion 

			*Optimize keeping number constant
			gsort inspectorclusteryear algorithm -yhatrf
			by inspectorclusteryear algorithm: gen n = _n 

			gen optimized_all_c = 0
			replace optimized_all_c  = 1 if n <= totalexecutedinsp & dgid == 1 
			replace optimized_all_c  = 1 if n <= totalexecutedalg & algorithm == 1 
			drop n 

			*Optimize only inspector cases		
			gsort inspectorclusteryear algorithm -yhatrf
			by inspectorclusteryear: gen n = _n 

			gen optimized_inspectors_c  = 0
			replace optimized_inspectors_c = 1 if n <= totalexecutedinsp & dgid == 1
			replace optimized_inspectors_c = 1 if executedalg == 1 
			
			drop n 
		
			*Optimize only algorithm cases		
			gsort inspectorclusteryear -algorithm -yhatrf
			by inspectorclusteryear: gen n = _n 

			gen optimized_algorithm_c = 0
			replace optimized_algorithm_c = 1 if n <= totalexecutedalg & algorithm == 1
			replace optimized_algorithm_c  = 1 if executedinsp == 1 
			
			drop n 
		
			*Optimize only algorithm cases		
			gsort inspectorclusteryear algorithm -L1turnover
			by inspectorclusteryear algorithm: gen n = _n 

			gen optimized_size_c = 0
			replace optimized_size_c  = 1 if n <= totalexecutedinsp & dgid == 1 
			replace optimized_size_c  = 1 if n <= totalexecutedalg & algorithm == 1 
			drop n 
				
		*Compute the total amount of evasion (not in log)
		gen evasion = exp(originaly4)-1
		gen predictedevasion = exp(yhatrf)-1
		*gen predictedevasion = yhatrf
		*gen evasion = originaly4
		
		egen evasion1 = mean(evasion)
		bys originaly2: egen evasion2 = mean(predictedevasion) if originaly2 == 1 
		
		local r = 3
		foreach opt in all inspectors algorithm size all_c inspectors_c algorithm_c size_c {
				local ++r
				bys optimized_`opt': egen evasion`r' = mean(predictedevasion) if optimized_`opt' == 1 

		}
	
		collapse (mean) evasion1 evasion2 evasion4 evasion5 evasion6 evasion7 evasion8 evasion9 evasion10 evasion11
			
		gen id = 1 
		reshape long evasion, i(id) j(n)

		gen logevasion = log(evasion)
		br
		*gen logevasion = evasion

			if `c' == 2 {
				#delim ;
				tw 
				(bar logevasion n if n <= 2) 
				(bar logevasion n if n > 2 & n <= 7, col(navy))
				(bar logevasion n if n > 2 & n > 7, col("200 0 0")), 
				xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
				ylabel(15(2)21)
				xtitle("") 
				legend(off) 
				title("Full audits")
				ytitle("mean of log(evasion)")
				;
				#delim cr
					
				graph export "$output\10 ex post optimized mean log VG `lweighted`weighted''.pdf", as(pdf) replace	
			}

			if `c' == 1 {		

				#delim ;
				tw 
				(bar logevasion n if n <= 2) 
				(bar logevasion n if n > 2 & n <= 7, col(navy))
				(bar logevasion n if n > 2 & n > 7, col("200 0 0")), 
				xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
				xtitle("") 
				legend(off) 
				title("Desk audits")
				ytitle("mean of log(evasion)")
				;
				#delim cr
					
				graph export "$output\10 ex post optimized mean log CP `lweighted`weighted''.pdf", as(pdf) replace	
			}	
			
		restore 

	}
}

********************************************
*EX POST OPTIMIZED ALGORITHM BY BUREAU
*Obs: Use prediction and see what the best evasion recovery could look like
********************************************
forvalues c = 1/2 {
		
	preserve 

	keep if controle == `c'

	rforest originaly4 ${model3rfc} algorithm if  originaly2 == 1 & originaly4 != ., type(reg)
			predict yhatrf  	
		
	*Count how many cases were executed 	
	bys inspectorclusteryear: egen totalexecuted = total(originaly2)	
	bys inspectorclusteryear: egen totalexecutedinsp = total(executedinsp)	
	bys inspectorclusteryear: egen totalexecutedalg = total(executedalg)	

	*Unconstrained optimization (only constraint is that the number of executed cases within list must be fixed)
		*Rank the cases by the amount of predicted evasion 
		gsort inspectorclusteryear -yhatrf
		by inspectorclusteryear : gen n = _n 

		gen optimized_all = n <= totalexecuted
		drop n

		*Optimize only among algorithm
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_inspectors = n <= totalexecuted
		drop n 

		gsort inspectorclusteryear -algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_algorithm = n <= totalexecuted
		drop n 
		
		*Optimize only based on size
		gsort inspectorclusteryear -L1turnover
		by inspectorclusteryear: gen n = _n 

		gen optimized_size = 0
		replace optimized_size  = 1 if n <= totalexecuted
		drop n 
		
	*Constrained optimization (keep fixed the number and distribution of algorithm and inspector cases executed in each list)
		*Rank the cases by the amount of predicted evasion 

		*Optimize keeping number constant
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear algorithm: gen n = _n 

		gen optimized_all_c = 0
		replace optimized_all_c  = 1 if n <= totalexecutedinsp & dgid == 1 
		replace optimized_all_c  = 1 if n <= totalexecutedalg & algorithm == 1 
		drop n 

		*Optimize only inspector cases		
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_inspectors_c  = 0
		replace optimized_inspectors_c = 1 if n <= totalexecutedinsp & dgid == 1
		replace optimized_inspectors_c = 1 if executedalg == 1 
		
		drop n 
	
		*Optimize only algorithm cases		
		gsort inspectorclusteryear -algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_algorithm_c = 0
		replace optimized_algorithm_c = 1 if n <= totalexecutedalg & algorithm == 1
		replace optimized_algorithm_c  = 1 if executedinsp == 1 
		
		drop n 
	
		*Optimize only algorithm cases		
		gsort inspectorclusteryear algorithm -L1turnover
		by inspectorclusteryear algorithm: gen n = _n 

		gen optimized_size_c = 0
		replace optimized_size_c  = 1 if n <= totalexecutedinsp & dgid == 1 
		replace optimized_size_c  = 1 if n <= totalexecutedalg & algorithm == 1 
		drop n 
			
	*Compute the total amount of evasion (not in log)
	gen evasion = exp(originaly4)
	gen predictedevasion = exp(yhatrf)
	*gen predictedevasion = yhatrf
	*gen evasion = originaly4
	
	bys groupbureau: egen evasion1 = mean(evasion)
	bys originaly2 groupbureau: egen evasion2 = mean(predictedevasion) if originaly2 == 1 
	
	local r = 3
	foreach opt in all inspectors algorithm size all_c inspectors_c algorithm_c size_c {
			local ++r
			bys optimized_`opt' groupbureau: egen evasion`r' = mean(predictedevasion) if optimized_`opt' == 1 

	}
	
*	collapse (mean) evasion1 evasion2 evasion4 evasion5 evasion6 evasion7 evasion8 evasion9 evasion10 evasion11, by(inspectorclusteryear bureau)

	collapse (mean) evasion1 evasion2 evasion4 evasion5 evasion6 evasion7 evasion8 evasion9 evasion10 evasion11, by(groupbureau)
		
*	gen id = 1 
	reshape long evasion, i(groupbureau) j(n)

	gen logevasion = log(evasion)
	*gen logevasion = evasion

		if `c' == 2 {
			
			local l1 "LTU"
			local l2 "MTU"
			local l3 "Liberal"
			local l4 "SME"
				
			forvalues b = 1/4 {
				#delim ;
				tw 
				(bar logevasion n if n <= 2 & groupbureau == `b') 
				(bar logevasion n if n > 2 & n <= 7 & groupbureau == `b', col(navy))
				(bar logevasion n if n > 2 & n > 7 & groupbureau == `b', col("200 0 0")), 
				xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
				ylabel(12(2)19)
				xtitle("") 
				legend(off) 
				title("`l`b''")
				ytitle("log of mean(evasion)")
				saving(graph`b'.gph, replace)
				;
				#delim cr
			}
			
			graph combine graph1.gph graph2.gph graph3.gph graph4.gph
			
			graph export "$output\10 ex post optimized mean log bureau VG.pdf", as(pdf) replace	

			forvalues b = 1/4 {
			erase graph`b'.gph
			}
		
		}

		if `c' == 1 {		

			local l1 "LTU"
			local l2 "MTU"
			local l3 "Liberal"
			local l4 "SME"
				
			forvalues b = 1/4 {
				#delim ;
				tw 
				(bar logevasion n if n <= 2 & groupbureau == `b') 
				(bar logevasion n if n > 2 & n <= 7 & groupbureau == `b', col(navy))
				(bar logevasion n if n > 2 & n > 7 & groupbureau == `b', col("200 0 0")), 
				xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
				ylabel(10(2)19)
				xtitle("") 
				legend(off) 
				title("`l`b''")
				ytitle("log of mean(evasion)")
				saving(graph`b'.gph, replace)
				;
				#delim cr
			}
			
			graph combine graph1.gph graph2.gph graph3.gph graph4.gph
			
			graph export "$output\10 ex post optimized log mean bureau CP.pdf", as(pdf) replace	

			forvalues b = 1/4 {
			erase graph`b'.gph
			}
			
		}	
		
	restore 

}

*********************************
*Use absolute amounts
*********************************

forvalues c = 1/2 {
		
	preserve 

	keep if controle == `c'

	rforest originaly4 ${model3rfc} algorithm if  originaly2 == 1 & originaly4 != ., type(reg)
			predict yhatrf  	
		
	*Count how many cases were executed 	
	bys inspectorclusteryear: egen totalexecuted = total(originaly2)	
	bys inspectorclusteryear: egen totalexecutedinsp = total(executedinsp)	
	bys inspectorclusteryear: egen totalexecutedalg = total(executedalg)	

	*Unconstrained optimization (only constraint is that the number of executed cases within list must be fixed)
		*Rank the cases by the amount of predicted evasion 
		gsort inspectorclusteryear -yhatrf
		by inspectorclusteryear : gen n = _n 

		gen optimized_all = n <= totalexecuted
		drop n

		*Optimize only among algorithm
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_inspectors = n <= totalexecuted
		drop n 

		gsort inspectorclusteryear -algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_algorithm = n <= totalexecuted
		drop n 
		
		*Optimize only based on size
		gsort inspectorclusteryear -L1turnover
		by inspectorclusteryear: gen n = _n 

		gen optimized_size = 0
		replace optimized_size  = 1 if n <= totalexecuted
		drop n 
		
	*Constrained optimization (keep fixed the number and distribution of algorithm and inspector cases executed in each list)
		*Rank the cases by the amount of predicted evasion 

		*Optimize keeping number constant
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear algorithm: gen n = _n 

		gen optimized_all_c = 0
		replace optimized_all_c  = 1 if n <= totalexecutedinsp & dgid == 1 
		replace optimized_all_c  = 1 if n <= totalexecutedalg & algorithm == 1 
		drop n 

		*Optimize only inspector cases		
		gsort inspectorclusteryear algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_inspectors_c  = 0
		replace optimized_inspectors_c = 1 if n <= totalexecutedinsp & dgid == 1
		replace optimized_inspectors_c = 1 if executedalg == 1 
		
		drop n 
	
		*Optimize only algorithm cases		
		gsort inspectorclusteryear -algorithm -yhatrf
		by inspectorclusteryear: gen n = _n 

		gen optimized_algorithm_c = 0
		replace optimized_algorithm_c = 1 if n <= totalexecutedalg & algorithm == 1
		replace optimized_algorithm_c  = 1 if executedinsp == 1 
		
		drop n 
	
		*Optimize only algorithm cases		
		gsort inspectorclusteryear algorithm -L1turnover
		by inspectorclusteryear algorithm: gen n = _n 

		gen optimized_size_c = 0
		replace optimized_size_c  = 1 if n <= totalexecutedinsp & dgid == 1 
		replace optimized_size_c  = 1 if n <= totalexecutedalg & algorithm == 1 
		drop n 
			
	*Compute the total amount of evasion (not in log)
	gen evasion = exp(originaly4)
	gen predictedevasion = exp(yhatrf)
	*gen predictedevasion = yhatrf
	*gen evasion = originaly4
	
	egen evasion1 = total(evasion)
	bys originaly2: egen evasion2 = total(predictedevasion) if originaly2 == 1 
	
	local r = 3
	foreach opt in all inspectors algorithm size all_c inspectors_c algorithm_c size_c {
			local ++r
			bys optimized_`opt': egen evasion`r' = total(predictedevasion) if optimized_`opt' == 1 

	}
	
*	collapse (mean) evasion1 evasion2 evasion4 evasion5 evasion6 evasion7 evasion8 evasion9 evasion10 evasion11, by(inspectorclusteryear bureau)

	collapse (mean) evasion1 evasion2 evasion4 evasion5 evasion6 evasion7 evasion8 evasion9 evasion10 evasion11
		
	gen id = 1 
	reshape long evasion, i(id) j(n)

	gen logevasion = log(evasion)
	*gen logevasion = evasion

		if `c' == 2 {
			#delim ;
			tw 
			(bar logevasion n if n <= 2) 
			(bar logevasion n if n > 2 & n <= 7, col(navy))
			(bar logevasion n if n > 2 & n > 7, col("200 0 0")), 
			xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
			yline(25.31929, lwidth(thin) lcolor(black) lpattern(-))
			xtitle("") 
			legend(off) 
			ytitle("log(total evasion)")
			text(25.7 4 "+8%")
			text(25.7 5 "+1%")
			text(25.7 6 "-10%")
			;
			#delim cr
				
			graph export "$output\10 ex post optimized VG.pdf", as(pdf) replace	
		}

		if `c' == 1 {		

			#delim ;
			tw 
			(bar logevasion n if n <= 2) 
			(bar logevasion n if n > 2 & n <= 7, col(navy))
			(bar logevasion n if n > 2 & n > 7, col("200 0 0")), 
			xlabel(1 "Realized amount" 2 "Realized predicted" 4 "Optimized" 5 "Opt. Inspector" 6 "Opt. Algorithm" 7 "Opt. Size" 8 "Constr. Optimized" 9 "Constr. Opt. Inspector" 10 "Constr. Opt. Algorithm" 11 "Constr. Opt. Size", labsize(small) angle(45)) 
			yline(23.823, lwidth(thin) lcolor(black) lpattern(-))
			xtitle("") 
			legend(off) 
			ytitle("log(total evasion)")
			text(24.2 4 "+16%")
			text(24.2 5 "-4%")
			text(24.2 6 "-14%")

			;
			#delim cr	
				
			graph export "$output\10 ex post optimized CP.pdf", as(pdf) replace	
		}	
		
	restore 

}
