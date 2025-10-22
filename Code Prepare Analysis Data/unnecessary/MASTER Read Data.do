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

		global generaldata "$rootdir\Senegal tax audits"
		global rawdata "$rootdir\Infractions-saisie"
		global analysisdata "$rootdir\Senegal tax audits\Analysis all data"
	
*1 read saisie data 
	*Read saisie data from excel spreadsheets and append in dta files 
cd "$analysisdata\dofiles\1 Read data"	
do "1 read saisie data.do"

*2 Check missing nineas
	*Use merge with strings and fuzzy string matching (matchit) to discover missing nineas 
cd "$analysisdata\dofiles\1 Read data"	
do "2 Check missing nineas and stats.do"

	*2.1
	*Auxiliary file used in several do-files. It contains a very large number of nineas that were found "manually" and corrects them
	cd "$analysisdata\dofiles\1 Read data"	
	do "2.1 Manually input nineas.do"

*3 Suivi dataset 
cd "$analysisdata\dofiles\1 Read data"	
do "3 Dataset suivi.do"
	
*4 Integrate
	*Merge datasets of confirmation and notification and append DGE data (which already contains notification and confirmation combined)
cd "$analysisdata\dofiles\1 Read data"	
do "4 Merge notification, confirmation and suivi datasets.do"

	*4.1 Quality Tests
	cd "$analysisdata\dofiles\1 Read data"	
	do "4.1 Test integrating with ninea vs reference number.do"

	*4.2 Quality tests
	cd "$analysisdata\dofiles\1 Read data"	
	do "4.2 Summary stats issues with saisie data.do"

*5 Read dataset of selection of 2018,2019,2020	
cd "$analysisdata\dofiles\1 Read data"	
do "5 Selection.do"

*6 Merge selection and audits 
	*Create a dataset indicating by which method the audits were selected
cd "$analysisdata\dofiles\1 Read data"	
do "6 Merge selection and audits.do"

*7 Tax declarations
	*Reshape the panel of tax declarations to have a wide dataset identified by firm
cd "$analysisdata\dofiles\1 Read data"	
do "7 Tax declarations data.do"

*8 Inspector survey
cd "$analysisdata\dofiles\1 Read data"	
do "8 Inspector survey.do"

	*8.1
		*Auxiliary file used in several dofiles to clean the names of inspectors
	cd "$analysisdata\dofiles\1 Read data"	
	do "8.1 Clean verificateur names.do"

*9 Taxpayer survey	
cd "$analysisdata\dofiles\1 Read data"	
do "9 Taxpayer survey.do"

*10 Make final dataset for analysis
	*Merge Selection-Saisie with tax data, inspector survey data, and create outcomes for analysis. 
cd "$analysisdata\dofiles\1 Read data"	
do "10 Make final dataset for analysis.do"
