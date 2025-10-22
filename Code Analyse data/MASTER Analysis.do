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

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}
	
/*	
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits"				// Insert path to shared Dropbox folder "Senegal Tax Audits"
	}
*/	
	
		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"



		

local date: disp  c(current_date)
di "`date'"
set scheme s1color

********************************
*1 SUMMARY STATISTICS
********************************
do "$rawdata/Analysis all data/replication_package/Code Analyse data/1 Summary Statistics.do"

********************************
*2 REGRESSIONS MAIN RESULTS
********************************
do "$rawdata/Analysis all data/replication_package/Code Analyse data/2 Regressions main results.do"

********************************
*3 TAXPAYER SURVEY ANALYSIS
********************************
do "$rawdata/Analysis all data/replication_package/Code Analyse data/3 Analysis taxpayer survey.do"

********************************
*4 PREDICTION EXERCISE
********************************
do "$rawdata/Analysis all data/replication_package/Code Analyse data/4 Prediction exercise.do"

********************************
*5 DETERRENCE EXERCISE
********************************
do "$rawdata/Analysis all data/replication_package/Code Analyse data/5 Deterrence.do"