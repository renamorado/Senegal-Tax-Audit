*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   March 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*Read data on taxpayers' survey. 

set more off
clear all 

*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","alipi") { 										// Alipio's computer
		global rootdir "D:\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits\Analysis all data\replication_package"
	}

		global rawdata "$rootdir\Raw data"
		global analysisdata "$rootdir\Working data"
		global wastedata "$rootdir\Intermediate data"

cd "$rootdir"
