************************************************************************************************************************************************************************
* Created in APR 2022
* Purpose: Reproduce the main regression results in Anti-corruption, government subsidies, and innovation: Evidence from China
************************************************************************************************************************************************************************


set more off
set matsize 11000
global options "drop(*yea* *pro*) nogaps stats( N r2, fmt( %9.0f %9.3f)) b(%6.3f) replace star(* 0.1 ** 0.05 *** 0.01) compress se(%6.3f) varwidth(20)"
global options2 "nogaps stats( N r2, fmt( %9.0f %9.3f)) b(%6.3f) replace star(* 0.1 ** 0.05 *** 0.01) compress se(%6.3f) varwidth(20)"

global ControlVar1 "lsoe lpolitical lroa ltobinq lleverage" 
global ControlVar2 "lnasset llnage lleverage lintangible lroa ltobinq lsoe lpolitical"


********************************************************************************************************************************************************************
*Table 3. Sample descriptive statistics
********************************************************************************************************************************************************************
use main_dataset, clear
global Var1 "subsidy_s etc_s aetc_s rd_s subsidy_rd pat_us cite_us rdefficiency asset_mil age leverage roa tobinq intangible soe political n_business" 
tabstat $Var1, stat(mean sd min p50 max n) long


********************************************************************************************************************************************************************
*Table 4. Pearson correlation matrix
********************************************************************************************************************************************************************
use main_dataset, clear
global Var2 "subsidy_s rdefficiency aetc_s pat_us cite_us asset_mil age leverage roa tobinq intangible soe political" 
pwcorr $Var2, sig


********************************************************************************************************************************************************************
* Table 5. Panel regressions: Merit, corruption, and subsidies
********************************************************************************************************************************************************************
use main_dataset, clear

****Panel A: Before and after the removal of top provincial officials on corruption charges
reghdfe subsidy_s lrdefficiency, absorb(inddummy prodummy year) vce(cluster firm)  
est store r1
reghdfe subsidy_s laetc_s if lrdefficiency!=., absorb(inddummy prodummy year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval, absorb(inddummy prodummy year) vce(cluster firm) 
est store r3
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval, absorb(inddummy prodummy year) vce(cluster firm) 
est store r4
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1, absorb(inddummy prodummy year) vce(cluster firm) 
est store r5
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1, absorb(firm year) vce(cluster firm) keepsing 
est store r6
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) keepsing       
est store r7
esttab r* using result5_A.rtf, $options

****Panel B: Before and after unanticipated departures of provincial technology bureau heads
reghdfe subsidy_s lrdefficiency, absorb(inddummy prodummy year) vce(cluster firm)  
est store r1
reghdfe subsidy_s laetc_s if lrdefficiency!=., absorb(inddummy prodummy year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture, absorb(inddummy prodummy year) vce(cluster firm) 
est store r3
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture, absorb(inddummy prodummy year) vce(cluster firm) 
est store r4
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1, absorb(inddummy prodummy year) vce(cluster firm) 
est store r5
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1, absorb(firm year) vce(cluster firm) keepsing
est store r6
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) keepsing
est store r7
esttab r* using result5_B.rtf, $options

****Panel C: With interaction terms
use main_dataset, clear
drop if laetc_s==.
drop if lrdefficiency==.

bys year:egen medianrdefficiency=median(lrdefficiency)
gen lhighleff=lrdefficiency>medianrdefficiency
bys year:egen medianaetc_s=median(laetc_s)
gen lhighlaetc=laetc_s>medianaetc_s

gen lhighleff_rde=lhighleff*lrdefficiency
gen lhighleff_rdepostre=lhighleff_rde*lpostremoval
gen lhighleff_rdepostde=lhighleff_rde*lpostdeparture

gen lhighlaetc_aetc=lhighlaetc*laetc_s
gen lhighlaetc_aetcpostre=lhighlaetc_aetc*lpostremoval
gen lhighlaetc_aetcpostde=lhighlaetc_aetc*lpostdeparture

*Before and after the removal of top provincial officials on corruption charges
reghdfe subsidy_s lhighleff_rdepostre lhighleff_rde lpostremoval, absorb(inddummy prodummy year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lhighlaetc_aetcpostre lhighlaetc_aetc lpostremoval, absorb(inddummy prodummy year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lhighleff_rdepostre lhighleff_rde lhighlaetc_aetcpostre lhighlaetc_aetc lpostremoval, absorb(inddummy prodummy year) vce(cluster firm) 
est store r3
esttab r* using result5_C1.rtf, $options2

*Before and after unanticipated departures of provincial technology bureau heads
reghdfe subsidy_s lhighleff_rdepostde lhighleff_rde lpostdeparture, absorb(inddummy prodummy year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lhighlaetc_aetcpostde lhighlaetc_aetc lpostdeparture, absorb(inddummy prodummy year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lhighleff_rdepostde lhighleff_rde lhighlaetc_aetcpostde lhighlaetc_aetc lpostdeparture, absorb(inddummy prodummy year) vce(cluster firm) 
est store r3
esttab r* using result5_C2.rtf, $options2


********************************************************************************************************************************************************************
* Table 6. Subsidies and future innovation: Before and after the removal of top provincial officials on corruption charges
********************************************************************************************************************************************************************
use main_dataset, clear

*Panel A: U.S. patents
reghdfe pat_us lsubsidy_s lpat_us ,absorb(year) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval lpat_us,absorb(year) vce(cluster firm) 
est store r2 
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval lpat_us $ControlVar2,absorb(year) vce(cluster firm) 
est store r3
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval lpat_us $ControlVar2,absorb(year inddummy prodummy) vce(cluster firm) 
est store r4
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2,absorb(year firm) vce(cluster firm) keepsing
est store r5
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) keepsing
est store r6
esttab r* using result6_A.rtf, $options

*Panel B: U.S. relative patent citation strength
reghdfe cite_us lsubsidy_s lcite_us,absorb(year) cluster(firm) 
est store r1
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval lcite_us,absorb(year) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval lcite_us $ControlVar2,absorb(year) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval lcite_us $ControlVar2,absorb(year inddummy prodummy) vce(cluster firm) 
est store r4
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2,absorb(year firm) vce(cluster firm) keepsing
est store r5
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) keepsing
est store r6
esttab r* using result6_B.rtf, $options


********************************************************************************************************************************************************************
* Table 7. Subsidies and future innovation: Before and after the unanticipated departures of provincial technology bureau heads
********************************************************************************************************************************************************************
use main_dataset, clear

*Panel A: U.S. patents
reghdfe pat_us lsubsidy_s lpat_us ,absorb(year) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lpat_us,absorb(year) vce(cluster firm) 
est store r2 
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lpat_us $ControlVar2,absorb(year) vce(cluster firm) 
est store r3
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lpat_us $ControlVar2,absorb(year inddummy prodummy) vce(cluster firm) 
est store r4
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2,absorb(year firm) vce(cluster firm) keepsing
est store r5
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) keepsing
est store r6
esttab r* using result7_A.rtf, $options

*Panel B. U.S. relative patent citation strength
reghdfe cite_us lsubsidy_s lcite_us,absorb(year) cluster(firm) 
est store r1
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lcite_us,absorb(year) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lcite_us $ControlVar2,absorb(year) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture lcite_us $ControlVar2,absorb(year inddummy prodummy) vce(cluster firm) 
est store r4
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2,absorb(year firm) vce(cluster firm) keepsing
est store r5
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) keepsing
est store r6
esttab r* using result7_B.rtf, $options


********************************************************************************************************************************************************************
* Table 8. Subsidies and external financing
********************************************************************************************************************************************************************
use main_dataset, clear

*Panel A: Before and after the removal of top provincial officials on corruption charges
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if DEF_dummy==1, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if DEF_dummy==0, absorb(firm year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if CA_dummy==1, absorb(firm year) vce(cluster firm) 
est store r3
reghdfe subsidy_s lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if CA_dummy==0, absorb(firm year) vce(cluster firm) 
est store r4
esttab r* using result8_A.rtf, $options

*Panel B: Before and after unanticipated departures of provincial technology bureau heads
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if DEF_dummy==1, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if DEF_dummy==0, absorb(firm year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if CA_dummy==1, absorb(firm year) vce(cluster firm) 
est store r3
reghdfe subsidy_s lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if CA_dummy==0, absorb(firm year) vce(cluster firm) 
est store r4
esttab r* using result8_B.rtf, $options


********************************************************************************************************************************************************************
* Table 9. Subsidies, external financing, and future innovation
********************************************************************************************************************************************************************
use main_dataset, clear

*Panel A: Before and after the removal of top provincial officials on corruption charges
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==1,absorb(year firm) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==0,absorb(year firm) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==1,absorb(year firm) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==0,absorb(year firm) vce(cluster firm) 
est store r4
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==1,absorb(year firm) vce(cluster firm) 
est store r5
reghdfe pat_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==0,absorb(year firm) vce(cluster firm) 
est store r6
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==1,absorb(year firm) vce(cluster firm) 
est store r7
reghdfe cite_us lsubsidy_s lsubsidy_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==0,absorb(year firm) vce(cluster firm) 
est store r8
esttab r* using result9_A.rtf, $options

*Panel B: Before and after unanticipated departures of provincial technology bureau heads
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==1,absorb(year firm) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==0,absorb(year firm) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==1,absorb(year firm) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if DEF_dummy==0,absorb(year firm) vce(cluster firm) 
est store r4
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==1,absorb(year firm) vce(cluster firm) 
est store r5
reghdfe pat_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==0,absorb(year firm) vce(cluster firm) 
est store r6
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==1,absorb(year firm) vce(cluster firm) 
est store r7
reghdfe cite_us lsubsidy_s lsubsidy_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s if CA_dummy==0,absorb(year firm) vce(cluster firm) 
est store r8
esttab r* using result9_B.rtf, $options


********************************************************************************************************************************************************************
*Table 10. Deterrence effect and social network effect
********************************************************************************************************************************************************************

*Panel A: Deterrence Effect
use main_dataset, clear
gen post2012=year>2012
gen lrdefficiency_post2012=lrdefficiency*post2012
gen laetc_post2012=laetc_s*post2012
keep if year<2016&year>2008

reghdfe subsidy_s lrdefficiency laetc_s  lrdefficiency_post2012 laetc_post2012 $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lrdefficiency laetc_s  lrdefficiency_post2012 laetc_post2012 $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if HC_dummy==1, absorb(firm year) vce(cluster firm) 
est store r2
reghdfe subsidy_s lrdefficiency laetc_s  lrdefficiency_post2012 laetc_post2012 $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s if HC_dummy==0, absorb(firm year) vce(cluster firm) 
est store r3
esttab r* using result10_A.rtf, $options

*Panel B: Social network effect - In-province rotations of officials
use main_dataset, clear
gen lrdefficiency_postrotation1=lrdefficiency*lpostrotation1
gen laetc_postrotation1=laetc_s*lpostrotation1
gen lrdefficiency_postrotation2=lrdefficiency*lpostrotation2
gen laetc_postrotation2=laetc_s*lpostrotation2

reghdfe subsidy_s lrdefficiency laetc_s lpostrotation1 lrdefficiency_postrotation1 laetc_postrotation1 $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_s lrdefficiency laetc_s lpostrotation2 lrdefficiency_postrotation2 laetc_postrotation2 $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r2
esttab r* using result10_B.rtf, $options


********************************************************************************************************************************************************************
*Table 11. Subsidy granting decisions, by subsidy types
********************************************************************************************************************************************************************
use main_dataset, clear

*Panel A: Before and after the removal of top provincial officials on corruption charges
reghdfe subsidy_strong lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_weak lrdefficiency laetc_s lpostremoval lrdefficiency_postremoval laetc_postremoval $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r2
esttab r* using result11_A.rtf, $options

*Panel B: Before and after unanticipated departures of provincial technology bureau heads
reghdfe subsidy_strong lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r1
reghdfe subsidy_weak lrdefficiency laetc_s lpostdeparture lrdefficiency_postdeparture laetc_postdeparture $ControlVar1 i.year#c.lrdefficiency i.year#c.laetc_s i.prodummy#c.lrdefficiency i.prodummy#c.laetc_s, absorb(firm year) vce(cluster firm) 
est store r2
esttab r* using result11_B.rtf, $options


********************************************************************************************************************************************************************
*Table 12. Subsidies and future innovation, by subsidy type
********************************************************************************************************************************************************************
use main_dataset, clear
gen lss_postremoval=lsubsidy_strong*lpostremoval
gen lsw_postremoval=lsubsidy_weak*lpostremoval
gen lss_postdeparture=lsubsidy_strong*lpostdeparture
gen lsw_postdeparture=lsubsidy_weak*lpostdeparture


*Panel A: Before and after the removal of top provincial officials on corruption charges
reghdfe pat_us lsubsidy_strong lss_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_weak lsw_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_strong lss_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_weak lsw_postremoval lpostremoval $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r4
esttab r* using result12_A.rtf, $options

*Panel B: Before and after unanticipated departures of provincial technology bureau heads
reghdfe pat_us lsubsidy_strong lss_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r1
reghdfe pat_us lsubsidy_weak lsw_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r2
reghdfe cite_us lsubsidy_strong lss_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r3
reghdfe cite_us lsubsidy_weak lsw_postdeparture lpostdeparture $ControlVar2 i.prodummy#c.lsubsidy_s i.year#c.lsubsidy_s,absorb(year firm) vce(cluster firm) 
est store r4
esttab r* using result12_B.rtf, $options



*************************************************************************The end*************************************************************************************