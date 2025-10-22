/* ---------------------------------- */
/* Graph related to Senegal paper TA1 */
/* ---------------------------------- */

clear all

	if strpos("`c(username)'","User") { 										// Roldan's computer
		global rootdir "C:\Users\User\Dropbox\Senegal tax audits"
	}
	
/*	
	if strpos("`c(username)'","YOUR COMPUTER'S USERNAME") { 					// INSERT YOUR USER NAME HERE
		global rootdir "...\Senegal tax audits"				// Insert path to shared Dropbox folder "Senegal Tax Audits"
	}
*/


global output "$rootdir\Analysis all data\replication_package\Output"

/* Create data */
set obs 10

gen ef_1=.
gen ef_2=.
gen n=.
gen ref=""
replace n=_n

replace ref="Hino et al. (2018)" if n==1
replace ref="Johnson et al. (2023)" if n==2
replace ref="Chalfin et al. (2016) II" if n==3
replace ref="Andini et al. (2022)" if n==4
replace ref="Glaeser et al. (2016)" if n==5
replace ref="Kleinberg et al. (2018)" if n==6
replace ref="Andini et al. (2018)" if n==7
replace ref="Battaglini et al. (2024)" if n==8
replace ref="Our study" if n==9
replace ref="Chalfin et al. (2016) I" if n==10

order n ref ef_1 ef_2

replace ef_1=600 	if n==1
replace ef_1=120 	if n==2
replace ef_1=105 	if n==3
replace ef_1=100 	if n==4
replace ef_1=50 	if n==5
replace ef_1=41.9 	if n==6
replace ef_1=41.8 	if n==7
replace ef_1=38 	if n==8
replace ef_1=30.4 	if n==9
replace ef_1=4.8 	if n==10

replace ef_2=100 	if n==1
replace ef_2=.		if n==2
replace ef_2=75	 	if n==3
replace ef_2=.	 	if n==4
replace ef_2=30	 	if n==5
replace ef_2=24.7 	if n==6
replace ef_2=29.5 	if n==7
replace ef_2=29 	if n==8
replace ef_2=17.4	if n==9
replace ef_2=.	 	if n==10

reshape long ef_, i(n) j(t)

ren ef_ ef
drop if ef==.
drop n t
gen n=_n
order n

replace n=n+1 if n>2
replace n=n+1 if n>4
replace n=n+1 if n>7
replace n=n+1 if n>9
replace n=n+1 if n>12
replace n=n+1 if n>15
replace n=n+1 if n>18
replace n=n+1 if n>21
replace n=n+1 if n>24

gen ef_l=ef

expand 2
gen N=_n
replace n=n-.5 if N>17


/* Make graph - Anne's modified version */
twoway 	(bar 	 ef n if n==1, 		barw(1) fcolor(midblue%60) 			lcolor(black%0) yaxis(2)) ///
		(bar 	 ef n if n==2, 		barw(1) fcolor(midblue%30)			lcolor(black%0) yaxis(2)) ///
		(bar 	 ef n if n==4, 		barw(1) fcolor(forest_green%60) 	lcolor(black%0)) ///
		(bar 	 ef n if n==6, 		barw(1) fcolor(lavender%60)			lcolor(black%0)) ///
		(bar 	 ef n if n==7, 		barw(1) fcolor(lavender%30) 		lcolor(black%0)) ///
		(bar 	 ef n if n==9,	 	barw(1) fcolor(dkorange%60)			lcolor(black%0)) ///
		(bar 	 ef n if n==11, 	barw(1) fcolor(cranberry%60) 		lcolor(black%0)) ///
		(bar 	 ef n if n==12, 	barw(1) fcolor(cranberry%30)		lcolor(black%0)) ///
		(bar 	 ef n if n==14, 	barw(1) fcolor(dkgreen%60) 			lcolor(black%0)) ///
		(bar 	 ef n if n==15, 	barw(1)	fcolor(dkgreen%30)			lcolor(black%0)) ///
		(bar 	 ef n if n==17, 	barw(1) fcolor(orange_red%60)		lcolor(black%0)) ///
		(bar 	 ef n if n==18, 	barw(1)	fcolor(orange_red%30)		lcolor(black%0)) ///
		(bar 	 ef n if n==20, 	barw(1)	fcolor(blue%60)				lcolor(black%0)) ///
		(bar 	 ef n if n==21, 	barw(1)	fcolor(blue%30)				lcolor(black%0)) ///
		(bar 	 ef n if n==23, 	barw(1)	fcolor(black)			lcolor(black%0)) ///
		(bar 	 ef n if n==24, 	barw(1)	fcolor(black)			lcolor(black%0)) ///
		(bar 	 ef n if n==26, 	barw(1)	fcolor(erose%60)			lcolor(black%0)) ///
		(scatter 	 ef n if n==.5, 	 mlabc(midblue%80) 	 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1) yaxis(2)) ///
		(scatter 	 ef n if n==1.5, 	 mlabc(midblue%40)		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1) yaxis(2)) ///
		(scatter 	 ef n if n==3.5, 	 mlabc(forest_green%80) msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==5.5, 	 mlabc(lavender%40)	 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==6.5, 	 mlabc(lavender%80) 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==8.5,	 mlabc(dkorange%40)	 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==10.5, 	 mlabc(cranberry%80) 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==11.5, 	 mlabc(cranberry%40)	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==13.5, 	 mlabc(dkgreen%80) 		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==14.5, 	 mlabc(dkgreen%40)		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==16.5, 	 mlabc(orange_red%80)	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==17.5, 	 mlabc(orange_red%40)	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==19.5, 	 mlabc(blue%40)		 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==20.5, 	 mlabc(blue%40)		 	msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==22.5, 	 mlabc(black)		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==23.5, 	 mlabc(black)		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)) ///
		(scatter 	 ef n if n==25.5, 	 mlabc(erose%80)		msymbol(none) mlabf(%12.0fc)  mlabs(vsmall) mlabel(ef_l) mlabposition(1)), ///
		xlab(	1.5 	`" "{bf:Hino}" "{bf:et al.}" " " "Water" "quality" " " "{it:Violations}" " " "(left)" "' /// 
				4 		`" "{bf:Johnson}" "{bf:et al.}" " " "Inspections" " " " " "{it:Injuries}" "' ///
				6.5 	`" "{bf:Chalfin}" "{bf:et al.}" " " "Tenure" "decisions" " " "{it:Test}" "{it:scores}" "' ///
				9 		`" "{bf:Andini}" "{bf:et al.}" " " "Credit" "guarantees" " " "{it:Loans}" "{it:granting}" "' ///
				11.5 	`" "{bf:Glaeser}" "{bf:et al.}" " " "Prediction" "tournament" " " "{it:Inspections}" "{it:productivity}" "' ///
				14.5 	`" "{bf:Kleinberg}" "{bf:et al.}" " " "Bail" "decisions" " " "{it:Crime/}" "{it:Incarceration}" "' ///
				17.5 	`" "{bf:Andini}" "{bf:et al.}" " " "Tax" "rebate" " " "{it:Food intake/}" "{it:Savings}" "' ///
				20.5 	`" "{bf:Battaglini}" "{bf:et al.}" " " "Audits" " " " " "{it:Evasion}" "' ///
				23.5 	`" "{bf:Our}" "{bf:study}" " "  "Tax" "audits" " " "{it:Evasion}" ""' ///
				26 		`" "{bf:Chalfin}" "{bf:et al.}" " " "Police" "hiring" " " "{it:Misconduct}" "', angle(0) labsize(1.75)) ///
		ytitle("", size(medsmall)) ytitle("Outcome Change (%)", size(medsmall) axis(2)) ///
		ylab(0(150)600, format(%12.0fc) labsize(medsmall) grid gstyle(dot) glcolor(gray%70) glw(medthin) axis(2)) ///
		ylab(0(30)120, format(%12.0fc) labsize(medsmall) grid gstyle(dot) glcolor(gray%70) glw(medthin)) /////
		graphregion(fcolor(white) lcolor(gs16)) xtitle("") legend(off)  ///
		yscale(titlegap(2) axis(2)) yscale(titlegap(2)) xscale(titlegap(4))
		graph export "$output/Literature_Graph.png", replace
		