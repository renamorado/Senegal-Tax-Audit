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
	
	if strpos("`c(username)'","User") { 										// Roldan's personal computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}


/*
	if strpos("`c(username)'","YOUR COMPUTER'S USER NAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
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
cd "$rawdata/Analysis all data/replication_package/Code Prepare Tax Data"

foreach dofile in "0 Read ANSD data" "1 Read tax data" "2 Read TP, customs and treasury data" "3 Annexes TVA" "4 Read Repertoires" "5 Read Past audits" "6 Collapse and merge datasets" "7 Cleaning and sanity checks" {
	
	cd "$rawdata/Analysis all data/replication_package/Code Prepare Tax Data"

	display "`dofile'"
	qui do "`dofile'.do"
	
}