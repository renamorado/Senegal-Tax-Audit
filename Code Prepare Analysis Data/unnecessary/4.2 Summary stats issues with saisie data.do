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
	
******************
*Get missing nineas
******************
cd "$analysisdata"

use "wastedata\\datasetsaisie", clear

gen missingninea = ninea == ""

matrix issues = J(13, 6, 0)

matrix  rownames issues = "All" "\hline 2017" "2018" "2019" "2020" "2021" "\hline DGE" "CME 1" "CME 2" "CPR" "DAKAR PLATEAU" "NGOR ALMADIES" "PIKINE GUEDIAWAYE" 
matrix  colnames issues = "Number of firms" "Missing nineas" "Only confirmation" "Only notification" "Neither" "Both"

local condition1 "."
local condition2 "missingninea == 1"
local condition3 "droitssimples_confirmation + penalites_confirmation != 0 & droitssimples_notification + penalites_notification == 0 "
local condition4 "droitssimples_notification + penalites_notification != 0 & droitssimples_confirmation + penalites_confirmation == 0"
local condition5 "droitssimples_notification + penalites_notification  + droitssimples_confirmation + penalites_confirmation == 0"
local condition6 "droitssimples_notification + penalites_notification != 0 & droitssimples_confirmation + penalites_confirmation != 0"

forvalues c = 1/6 {

	local r = 0  
	
	local ++r
	count if `condition`c''
	matrix issues[`r', `c'] = `r(N)'

	foreach y in 2017 2018 2019 2020 2021 {
	local ++r
	cap count if `condition`c'' & anneeduchrono == "`y'"
	cap count if `condition`c'' & anneeduchrono == `y'

	matrix issues[`r', `c'] = `r(N)'
	}	
	
	foreach b in DGE CME1 CME2 CPR DP NGA PKG {
	local ++r
	count if `condition`c'' & bureau == "`b'"
	matrix issues[`r', `c'] = `r(N)'
	}
}

esttab matrix(issues)
