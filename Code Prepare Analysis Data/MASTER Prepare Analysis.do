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
*net from http://www.stata-journal.com/software/sj15-4¨netnet install dm0085
*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","49354415") {										// Alipio's computer
		global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
		global rootdir_2 "C:\Users\User\Dropbox"
		}
		
/*
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits" 								// Insert path to shared Dropbox folder "Senegal Tax Audits"	
		global rootdir_2 "...\Dropbox"											// Insert path to local directory of Dropbox, this global macro will later be called to refer to the other 
																				// data storing folder "Infractions-sasie"
	}
*/

		global rawdata "$rootdir"
		global rawdata2 "$rootdir_2\Infractions-saisie"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		global code "$rootdir\Analysis all data\replication_package\Code Prepare Analysis Data"

local date: disp  c(current_date)
di "`date'"
set scheme s1color

********************************
*1 SUMMARY STATISTICS
********************************
cd "$rawdata/Analysis all data/replication_package/Code Prepare Tax Data"

foreach dofile in  "1 Selection" "2 read saisie data" "3 read suivi data" "4 merge selection and audits" "5 Tax declarations data"  "6 Inspector survey" "7 taxpayer survey" "8 Make final dataset for analysis" {
	
	cd "$rawdata/Analysis all data/replication_package/Code Prepare Analysis Data"

	display "`dofile'"
	qui do "`dofile'.do"
	
}


