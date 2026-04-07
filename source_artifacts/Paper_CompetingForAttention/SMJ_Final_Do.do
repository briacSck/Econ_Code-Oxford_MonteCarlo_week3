*** This file was generated with STATA 15 IC ***
*** Required packages: 
***		- estout
***		- reghdfe



clear all 


use "C:\Users\annak\Dropbox\Research\News Aggregators Paper\Revision_SMJ\Round 2\Replication\FinalFiles\SMJ_Final.dta"



***** MAIN PAPER 
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************


***** Table 1 -- Summary Statistics

su VGM after TotalVisits lav_Visits av_TotalVisits logTotalVisits lHerfCont, detail
su after av_TotalVisits lav_Visits logTotalVisits lHerfCont if VGM==1, detail
su after av_TotalVisits lav_Visits logTotalVisits lHerfCont if VGM==0, detail


***** Table 2 -- Main Results

eststo clear

reghdfe logTotalVisits afterXVGM , absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars



***** Table 3 -- Without dropping 17 months in between 

// Generating this table requires additional data. 
// Please contact kerkhof@ifo.de. 
// The data will be delivered upon request. 


***** Table 4 -- Two treatment periods

// Generating this table requires additional data. 
// Please contact kerkhof@ifo.de. 
// The data will be delivered upon request. 




***** Table 5 -- Scale and Scope by Quintiles

* Scale

xtile quint_Scale=av_TotalVisits, n(5) 

g Scale_qi1 = (quint_Scale==1)
g Scale_qi2 = (quint_Scale==2)
g Scale_qi3 = (quint_Scale==3)
g Scale_qi4 = (quint_Scale==4)
g Scale_qi5 = (quint_Scale==5)

g post_qi1_Scale = after*Scale_qi1
g post_qi2_Scale = after*Scale_qi2
g post_qi3_Scale = after*Scale_qi3
g post_qi4_Scale = after*Scale_qi4
g post_qi5_Scale = after*Scale_qi5

g post_qi1_VGM_Scale = after*Scale_qi1*VGM
g post_qi2_VGM_Scale = after*Scale_qi2*VGM
g post_qi3_VGM_Scale = after*Scale_qi3*VGM
g post_qi4_VGM_Scale = after*Scale_qi4*VGM
g post_qi5_VGM_Scale = after*Scale_qi5*VGM


* Scope

xtile quint_Scope=lHerfCont, n(5) 

g Scope_qi1 = (quint_Scope==1)
g Scope_qi2 = (quint_Scope==2)
g Scope_qi3 = (quint_Scope==3)
g Scope_qi4 = (quint_Scope==4)
g Scope_qi5 = (quint_Scope==5)

g post_qi1_Scope = after*Scope_qi1
g post_qi2_Scope = after*Scope_qi2
g post_qi3_Scope = after*Scope_qi3
g post_qi4_Scope = after*Scope_qi4
g post_qi5_Scope = after*Scope_qi5

g post_qi1_VGM_Scope = after*Scope_qi1*VGM
g post_qi2_VGM_Scope = after*Scope_qi2*VGM
g post_qi3_VGM_Scope = after*Scope_qi3*VGM
g post_qi4_VGM_Scope = after*Scope_qi4*VGM
g post_qi5_VGM_Scope = after*Scope_qi5*VGM


* Generate Table 

eststo clear 

reghdfe logTotalVisits afterXVGM post_lav_Visits post_qi2_VGM_Scale post_qi3_VGM_Scale post_qi4_VGM_Scale post_qi5_VGM_Scale, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_qi2_VGM_Scope post_qi3_VGM_Scope post_qi4_VGM_Scope post_qi5_VGM_Scope, absorb(metaID monthtime) cl(metaID)
eststo

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars



***** APPENDIX
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************




***** Figure A1

* Generate monthly interactions

tab monthtime

forvalues i = 620(1)672 {

g m`i' = (monthtime == `i')
g m`i'lvis = m`i'*lav_Visits
g m`i'lHerfContNL = m`i'*lHerfCont

g VGM`i' = (monthtime == `i' & VGM == 1)
g VGM`i'lvis =  VGM`i'*lav_Visits
g VGM`i'lHerfContNL =  VGM`i'*lHerfCont

}

g pre = (monthtime <=636)



** Scale

g prelvis = pre*lav_Visits
g postlvis = after*lav_Visits

reghdfe logTotalVisits prelvis postlvis VGM620 VGM621 VGM622 VGM623 VGM624 VGM625 VGM626 VGM627 VGM628 VGM629 VGM630 VGM631 VGM632 VGM633 VGM634 VGM635 VGM636 VGM655 VGM656 VGM657 VGM658 VGM659 VGM660 VGM661 VGM662 VGM663 VGM664 VGM665 VGM666 VGM667 VGM668 VGM669 VGM670 VGM671 VGM672 VGM620lvis VGM621lvis VGM622lvis VGM623lvis VGM624lvis VGM625lvis VGM626lvis VGM627lvis VGM628lvis VGM629lvis VGM630lvis VGM631lvis VGM632lvis VGM633lvis VGM634lvis VGM635lvis VGM636lvis VGM655lvis VGM656lvis VGM657lvis VGM658lvis VGM659lvis VGM660lvis VGM661lvis VGM662lvis VGM663lvis VGM664lvis VGM665lvis VGM666lvis VGM667lvis VGM668lvis VGM669lvis VGM670lvis VGM671lvis VGM672lvis , absorb(metaID monthtime) cl(metaID)   
// Copy-paste estimates and CI into excel and generate graph. 


** Scope

g preH = pre*lHerfCont
g postH = after*lHerfCont

reghdfe logTotalVisits preH postH VGM620 VGM621 VGM622 VGM623 VGM624 VGM625 VGM626 VGM627 VGM628 VGM629 VGM630 VGM631 VGM632 VGM633 VGM634 VGM635 VGM636 VGM655 VGM656 VGM657 VGM658 VGM659 VGM660 VGM661 VGM662 VGM663 VGM664 VGM665 VGM666 VGM667 VGM668 VGM669 VGM670 VGM671 VGM672 VGM620lHerfContNL VGM621lHerfContNL VGM622lHerfContNL VGM623lHerfContNL VGM624lHerfContNL VGM625lHerfContNL VGM626lHerfContNL VGM627lHerfContNL VGM628lHerfContNL VGM629lHerfContNL VGM630lHerfContNL VGM631lHerfContNL VGM632lHerfContNL VGM633lHerfContNL VGM634lHerfContNL VGM635lHerfContNL VGM636lHerfContNL VGM655lHerfContNL VGM656lHerfContNL VGM657lHerfContNL VGM658lHerfContNL VGM659lHerfContNL VGM660lHerfContNL VGM661lHerfContNL VGM662lHerfContNL VGM663lHerfContNL VGM664lHerfContNL VGM665lHerfContNL VGM666lHerfContNL VGM667lHerfContNL VGM668lHerfContNL VGM669lHerfContNL VGM670lHerfContNL VGM671lHerfContNL VGM672lHerfContNL , absorb(metaID monthtime) cl(metaID)   
// Copy-paste estimates and CI into excel and generate graph. 





***** Figure A2
// Run the regressions.
// Copy-paste the estimates for i.monthtime and the corresponding CIs into Excel-file.
// Generate connected lines from that. Have all lines in one graph. 
xi: xtreg logTotalVisits afterXVGM i.monthtime, fe cl(metaID)
xi: xtreg logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM i.monthtime, fe cl(metaID)
xi: xtreg logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM i.monthtime, fe cl(metaID)
xi: xtreg logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM i.monthtime, fe cl(metaID)




***** Table A1

* Generate false treatments 

//Note: This does NOT include the 17 months in between!

forvalues i = 623(1)637 {
g fake`i'= (monthtime >= `i' & VGM == 1)
}


* Scale 


forvalues i = 623(1)637 {
g fpost`i' = (monthtime >= `i')
g fpost`i'vis = fpost`i'*lav_Visits 
g fakevisvgm`i' = lav_Visits*fake`i' 
reghdfe logTotalVisits fake`i' fpost`i'vis fakevisvgm`i' if monthtime < 655, absorb(metaID monthtime) cl(metaID)

g fpost_VGM_m`i'       = _b[fake`i']
g fpost_VGM_Scale_m`i' = _b[fakevisvgm`i']

g se_fpost_VGM_m`i'       = _se[fake`i']
g se_fpost_VGM_Scale_m`i' = _se[fakevisvgm`i']

}

list fpost_VGM_m* if _n == 1
list fpost_VGM_S* if _n == 1

list se_fpost_VGM_m* if _n == 1
list se_fpost_VGM_S* if _n == 1


drop fpost*
drop se_*


* Scope 

forvalues i = 623(1)637 {
g fpost`i' = (monthtime >= `i')
g fpost`i'HerfCont = fpost`i'*lHerfCont
g fakeHerfContvgm`i' = lHerfCont*fake`i' 
reghdfe logTotalVisits fake`i' fpost`i'HerfCont fakeHerfContvgm`i' if monthtime < 655, absorb(metaID monthtime) cl(metaID)

g fpost_VGM_m`i'       = _b[fake`i']
g fpost_VGM_Scope_m`i' = _b[fakeHerfContvgm`i']

g se_fpost_VGM_m`i'       = _se[fake`i']
g se_fpost_VGM_Scope_m`i' = _se[fakeHerfContvgm`i']

}

list fpost_VGM_m* if _n == 1
list fpost_VGM_S* if _n == 1

list se_fpost_VGM_m* if _n == 1
list se_fpost_VGM_S* if _n == 1


drop fpost*




***** Table A2 -- log(PrintedCopies) as placebo

eststo clear

reghdfe lp afterXVGM post_lav_Visits post_lav_Visits_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe lp afterXVGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe lp afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars



***** Table A3 -- Alternative DepVar: PIs

eststo clear

reghdfe logTotalPIs afterXVGM , absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalPIs afterXVGM post_lav_Visits post_lav_Visits_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalPIs afterXVGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalPIs afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars




***** Table A4 -- Alternative IndepVars

eststo clear

reghdfe logTotalVisits afterXVGM post_lav_Counties post_lav_Counties_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Circ post_lav_Circ_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lrel_Visits post_lrel_Visits_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lrel_WVis post_lrel_WVis_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_EntropCont post_EntropCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lCount post_lCount_VGM, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars



***** Table A5 -- Including linear outlet time trend

eststo clear

reghdfe logTotalVisits afterXVGM n, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM n, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM n, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM n, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars




***** Table A6 -- Seasonality * outlet FE

gen qu = substr(Date, 1, 1)

gen    outlet_quarter = Name + "_" + qu
encode outlet_quarter, generate(oq) 



eststo clear

qui xtreg logTotalVisits afterXVGM i.oq, fe cl(metaID)
eststo
qui xtreg logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM i.oq i.monthtime, fe cl(metaID)
eststo
qui xtreg logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM i.oq i.monthtime, fe cl(metaID)
eststo
qui xtreg logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM i.oq i.monthtime, fe cl(metaID)
eststo

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars keep(afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM)



***** Table A7 -- Narrower time window

eststo clear

reghdfe logTotalVisits afterXVGM if monthtime >= 626 & monthtime <= 666, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM if monthtime >= 626 & monthtime <= 666, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM if monthtime >= 626 & monthtime <= 666, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM if monthtime >= 626 & monthtime <= 666, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars




***** Table A8 -- Broader time window

// Generating this table requires additional data. 
// Please contact kerkhof@ifo.de. 
// The data will be delivered upon request. 



***** Table A9 -- Political orientation - center outlets

eststo clear

reghdfe logTotalVisits afterXVGM if (absscore <= 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM if (absscore <= 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM if (absscore <= 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM if (absscore <= 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars



***** Table A10 -- Political orientation - fringe outlets

eststo clear

reghdfe logTotalVisits afterXVGM if (absscore > 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM if (absscore > 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM post_lHerfCont post_lHerfCont_VGM if (absscore > 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM if (absscore > 0.013 & !missing(absscore)), absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars




***** Table A11 -- Google News Dispute

g google	             = (monthtime == 657 | monthtime == 658)
g google_VGM             = google * VGM
g google_lav_Visits      = google*lav_Visits
g google_lav_Visits_VGM  = google_lav_Visits*VGM
g google_lHerfCont       = google*lHerfCont
g google_lHerfCont_VGM   = google_lHerfCont*VGM


eststo clear

reghdfe logTotalVisits afterXVGM google_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM google_VGM google_lav_Visits google_lav_Visits_VGM post_lav_Visits post_lav_Visits_VGM, absorb(metaID monthtime) cl(metaID)
eststo
reghdfe logTotalVisits afterXVGM google_VGM google_lHerfCont google_lHerfCont_VGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 
reghdfe logTotalVisits afterXVGM google_VGM google_lav_Visits google_lav_Visits_VGM google_lHerfCont google_lHerfCont_VGM post_lav_Visits post_lav_Visits_VGM post_lHerfCont post_lHerfCont_VGM, absorb(metaID monthtime) cl(metaID)
eststo 

esttab, p star(* 0.10 ** 0.05 *** 0.01) r2 depvars







