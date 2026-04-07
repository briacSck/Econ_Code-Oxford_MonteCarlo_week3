/*# The program for "Hedging on the Hill" by Christensen, Jin, Sridharan, and Wellman#*/

*Setup
clear

set more off
local dir `c(pwd)'
cd "$dir"

use firmcyclepanel.dta, clear

local controls "politicalconnections mktvol beta mve btm roa loss cash govtsales zscore leverage competition ppe"

*Table 1A
estpost summarize idiovol politicalhedge `controls' crashriskskew crashriskduvol volinvcapx volinvrd volinvacq volearnib volearnpti volearncashetr ret, detail
estimates store m1
esttab m1 using "T1A.rtf", replace ///
cells("count(fmt(%9.0gc) label(N)) mean(fmt(3) label(Mean)) sd(fmt(3) label(Std)) p25(fmt(3) label(P25)) p50(fmt(3) label(Median)) p75(fmt(3) label(P75))") ///
nomtitle nonumber noobs label compress
estimates clear

*Table 1B
estpost tabstat politicalhedge, by(year) stat(count mean)
estimates store m1

esttab m1 using "T1B.rtf", replace ///
cells("count(fmt(%9.0gc) label(N)) mean(fmt(3) label(Mean))") noobs nomtitle nonumber
estimates clear

*Table 1C
estpost tabstat politicalhedge, by(ff12) stat(count mean)
estimates store m1

esttab m1 using "T1C.rtf", replace ///
cells("count(fmt(%9.0gc) label(N)) mean(fmt(3) label(Mean))") noobs nomtitle nonumber
estimates clear

*Table 2
reghdfe idiovol politicalhedge, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge politicalconnections , absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3  using "T2.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge politicalconnections `controls') /// 
order(politicalhedge politicalconnections `controls') ///
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Table 3
reghdfe idiovol politicalhedge c.politicalhedge#c.partydivbelow `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge c.politicalhedge#c.tpuabove `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge c.politicalhedge#c.epuabove `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge c.politicalhedge#c.partisanabove `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m4
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3 m4 using "T3.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge c.politicalhedge#c.partydivbelow c.politicalhedge#c.tpuabove c.politicalhedge#c.epuabove c.politicalhedge#c.partisanabove) /// 
order(politicalhedge c.politicalhedge#c.partydivbelow c.politicalhedge#c.tpuabove c.politicalhedge#c.epuabove c.politicalhedge#c.partisanabove) /// 
stats(controls year firm N r2_a, label("Controls" "Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes
estimates clear

*Table 4
reghdfe crashriskskew politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe crashriskduvol politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 using "T4.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge `controls') /// 
order(politicalhedge `controls') ///
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear 

*Table 5
reghdfe d_volinvcapx politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvrd politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvacq politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3 
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3 using "T5.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge `controls') /// 
order(politicalhedge `controls') /// 
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes
estimates clear

*Table 6
reghdfe d_volearnib politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearnpti politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearncashetr politicalhedge `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3 
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3 using "T6.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge `controls') /// 
order(politicalhedge `controls') /// 
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes
estimates clear

*Table 7
reghdfe ret earnm1 earn earnp1 ///
politicalconnections retp1 mve losst growtht, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe ret earnm1 earn earnp1 politicalhedge earnm1politicalhedge earnpoliticalhedge earnp1politicalhedge ///
politicalconnections retp1 mve losst growtht, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 using "T7.rtf", replace b(3) t(2) ar2(2) ///
keep(earnm1 earn earnp1 politicalhedge earnm1politicalhedge earnpoliticalhedge earnp1politicalhedge ///
politicalconnections retp1 mve losst growtht) /// 
order(earnm1 earn earnp1 politicalhedge earnm1politicalhedge earnpoliticalhedge earnp1politicalhedge ///
politicalconnections retp1 mve losst growtht) /// 
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes

*Table 8A
reghdfe idiovol politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe crashriskskew politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe crashriskduvol politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvcapx politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m4
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvrd politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m5
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvacq politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m6
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearnib politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m7
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearnpti politicalhedge `controls' derivatived , absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m8
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearncashetr politicalhedge `controls' derivatived, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m9
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 using "T8A.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge derivatived) /// 
order(politicalhedge derivatived) ///
stats(controls firm year N r2_a, label("Controls" "Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Table 8B
reghdfe idiovol politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe crashriskskew politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe crashriskduvol politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvcapx politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m4
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvrd politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m5
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volinvacq politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m6
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearnib politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m7
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearnpti politicalhedge `controls' derivativec , absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m8
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

reghdfe d_volearncashetr politicalhedge `controls' derivativec, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m9
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 using "T8B.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge derivativec) /// 
order(politicalhedge derivativec) ///
stats(controls firm year N r2_a, label("Controls" "Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Table 9 Column 1 and 2
reghdfe politicalhedge `controls', absorb(ff48 year) 
estimates store m1 
estadd local ind "YES"
estadd local firm "NO"
estadd local year "YES"

reghdfe idiovol hedgeresidual1 `controls' , absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local ind "NO"
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 using "T9_12.rtf", replace b(3) t(2) ar2(2) ///
keep(hedgeresidual1 `controls') /// 
order(hedgeresidual1 `controls') ///
stats(year ind firm N r2_a, label("Year FE" "Industry FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Table 9 Column 3 and 4
reghdfe politicalhedge `controls', absorb(gvkey year)  cluster(gvkey) keepsingleton
estimates store m1 
estadd local ind "NO"
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol hedgeresidual2 `controls' , absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local ind "NO"
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 using "T9_34.rtf", replace b(3) t(2) ar2(2) ///
keep(hedgeresidual2 `controls') /// 
order(hedgeresidual2 `controls') ///
stats(year ind firm N r2_a, label("Year FE" "Industry FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Table 10A
reghdfe idiovol politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventyear c.treat#c.eventyear c.politicalhedge#c.treat#c.eventyear ///
 `controls', absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

esttab m1 using "T10A.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventyear c.treat#c.eventyear c.politicalhedge#c.treat#c.eventyear) /// 
order(politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventyear c.treat#c.eventyear c.politicalhedge#c.treat#c.eventyear) ///
stats(controls year firm N r2_a, label("Controls" "Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Appendix O1
reghdfe idiovol politicalhedge if connect_dummy == 1, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m1
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge politicalconnections if connect_dummy == 1, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m2
estadd local firm "YES"
estadd local year "YES"

reghdfe idiovol politicalhedge `controls' if connect_dummy == 1, absorb(gvkey year) cluster(gvkey) keepsingleton
estimates store m3
estadd local firm "YES"
estadd local year "YES"

esttab m1 m2 m3  using "AppendixC1.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge politicalconnections `controls') /// 
order(politicalhedge politicalconnections `controls') ///
stats(year firm N r2_a, label("Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear

*Appendix O2
estpost correlate idiovol politicalhedge `controls' crashriskskew crashriskduvol d_volinvcapx d_volinvrd d_volinvacq d_volearnib d_volearnpti d_volearncashetr, matrix
esttab using "AppendixC2.csv", replace not unstack nonumbers nomtitles compress noobs star b(2) label 
estimates clear

*Appendix Figure O1
preserve
collapse (mean) politicalhedge partydivision, by(year)
label variable politicalhedge "Political Hedge"
label variable partydivision"Party Division"
label variable year "Election Cycle"
 twoway connected politicalhedge year , yaxis(1) lcolor(red) lpattern(solid) lwidth(medthick) msymbol(circle) mcolor(red) msize(med) xlabel(1998(2)2016)|| ///
|| connected partydivision year , yaxis(2) lcolor(blue) lpattern(dash) lwidth(medthick) msymbol(square) mcolor(blue) msize(med)
graph export "AFC1.png", replace
restore

*Appendix Figure O2
preserve
collapse (mean) politicalhedge tpu, by(year)
label variable politicalhedge "Political Hedge"
label variable tpu "Tax Policy Uncertainty"
label variable year "Election Cycle"
 twoway connected politicalhedge year , yaxis(1) lcolor(red) lpattern(solid) lwidth(medthick) msymbol(circle) mcolor(red) msize(med) xlabel(1998(2)2016)|| ///
|| connected tpu year , yaxis(2) lcolor(blue) lpattern(dash) lwidth(medthick) msymbol(square) mcolor(blue) msize(med)
graph export "AFC2.png", replace
restore

*Appendix Figure O3
preserve
collapse (mean) politicalhedge epu, by(year)
label variable politicalhedge "Political Hedge"
label variable epu "Economic Policy Uncertainty"
label variable year "Election Cycle"
 twoway connected politicalhedge year , yaxis(1) lcolor(red) lpattern(solid) lwidth(medthick) msymbol(circle) mcolor(red) msize(med) xlabel(1998(2)2016)|| ///
|| connected epu year , yaxis(2) lcolor(blue) lpattern(dash) lwidth(medthick) msymbol(square) mcolor(blue) msize(med)
graph export "AFC3.png", replace
restore

*Appendix Figure O4
preserve
collapse (mean) politicalhedge partisanconflict, by(year)
label variable politicalhedge "Political Hedge"
label variable partisanconflict "Partisan Conflict"
label variable year "Election Cycle"
 twoway connected politicalhedge year , yaxis(1) lcolor(red) lpattern(solid) lwidth(medthick) msymbol(circle) mcolor(red) msize(med) xlabel(1998(2)2016)|| ///
|| connected partisanconflict year , yaxis(2) lcolor(blue) lpattern(dash) lwidth(medthick) msymbol(square) mcolor(blue) msize(med)
graph export "AFC4.png", replace
restore

use firmdaypanel.dta, clear
*Table 1A
estpost summarize intravol, detail
estimates store m1
esttab m1 using "T1A_2.rtf", replace ///
cells("count(fmt(%9.0gc) label(N)) mean(fmt(3) label(Mean)) sd(fmt(3) label(Std)) p25(fmt(3) label(P25)) p50(fmt(3) label(Median)) p75(fmt(3) label(P75))") ///
nomtitle nonumber noobs label compress
estimates clear


*Table 10B
reghdfe intravol politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventdate c.treat#c.eventdate c.politicalhedge#c.treat#c.eventdate ///
 `controls', absorb(ff12 date) cluster(gvkey) keepsingleton
estimates store m1
estadd local controls "YES"
estadd local firm "YES"
estadd local year "YES"

esttab m1 using "T10B.rtf", replace b(3) t(2) ar2(2) ///
keep(politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventdate c.treat#c.eventdate c.politicalhedge#c.treat#c.eventdate) /// 
order(politicalhedge c.politicalhedge#c.treat c.politicalhedge#c.eventdate c.treat#c.eventdate c.politicalhedge#c.treat#c.eventdate) ///
stats(controls year firm N r2_a, label("Controls" "Year FE" "Firm FE" "# of Obs." "Adj. R2") fmt(0 0 0 %9.0gc %8.2f)) ///
nogaps star(* 0.10 ** 0.05 *** 0.01) label nonotes 
estimates clear
