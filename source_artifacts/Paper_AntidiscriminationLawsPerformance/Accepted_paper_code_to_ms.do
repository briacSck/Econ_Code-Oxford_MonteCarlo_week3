*****Replication code for 'How do anti-discrimination laws affect firm performance and financial policies? Evidence from the post-World War II period'******;

***Tables 2-12 replication code that will be given to MS****;
use "ad_dataset_ms1.dta", clear
global cont "ln_at_adj  ni_at  ppent_at  div_payer  state_inc_growth"
global cont2 "ln_at_adj   ppent_at  div_payer  state_inc_growth"
 
tsset cm_id fyear
 
*Table 2; 
fre fyear  if census_region_south!=. & randsamp1!=.
fre state_final  if census_region_south!=. & randsamp1!=.
fre census_region_all  if census_region_south!=. & randsamp1!=.
 
*Table 3: Summary statistics for main variables, except splitting variables*;
tabstat ad_law2 oibdp_atw ni_atw empgrw lev_dlc_dltt_at lev_lt_at lev_mkt at_adj ni_at_vol ppent_at   div_payer state_inc_growth  , s(n mean sd p25 p50 p75 )  column(statistics) varwidth(16)
 
*Table 4: Profitability tests *;
*Operating Profitability tests: 1. no controls, 2. w/controls and 3. state-specific time trend;
reghdfe  oibdp_atw  ad_law2     if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat replace tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

reghdfe  oibdp_atw  ad_law2  $cont2    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

reghdfe  oibdp_atw  ad_law2  $cont2 i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a( cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

*Net profitability tests*;
reghdfe  ni_atw ad_law2     if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))
 
reghdfe  ni_atw ad_law2  $cont2    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))
 
reghdfe  ni_atw ad_law2  $cont2  i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a(   cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

*Employment growth tests*;
reghdfe empgrw  ad_law2     if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

reghdfe empgrw  ad_law2  $cont2    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))
 
reghdfe empgrw  ad_law2  $cont2  i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

 

* Table 5: Robustnesss tests w/profitability industry-year FE, census division-year FE, beg characteristic-year FE, and neig. state AD law control*;
reghdfe  oibdp_atw  ad_law2  $cont2   if census_region_south!=. & randsamp1!=. ,  a( i.sic_2#i.fyear  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat replace tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

*Census division-year FE added. Note we add i.fyear and not c.fyear here;   
reghdfe  oibdp_atw  ad_law2  $cont2   if census_region_south!=. & randsamp1!=. ,  a( i.census_division#i.fyear  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

*Firm characteristic x year FE along with firm and year FE*;
reghdfe oibdp_atw    ad_law2     if census_region_south!=. & randsamp1!=. ,  a( i.cm_id i.fyear  c.ppent_at_beg#i.fyear c.div_payer_beg#i.fyear c.state_inc_growth_beg#i.fyear c.ln_at_adj_beg#i.fyear ) vce(cluster cm_id )
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

*Neighboring state AD law control*;
reghdfe  oibdp_atw  ad_law2  ad_sn_median $cont2  if census_region_south!=. & randsamp1!=. ,  a(   cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

  


*Table 6: Leverage baseline regressions;
*Firm FE baseline regressions*;
reghdfe lev_dlc_dltt_at  ad_law2      if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   replace tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

*Firm FE baseline regressions w/controls*;
reghdfe lev_dlc_dltt_at  ad_law2  $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append  tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))
 
reghdfe lev_dlc_dltt_at ad_law2   $cont  i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(2) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

*Repeat with total leverage and market leverage*;
reghdfe lev_lt_at  ad_law2       if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_lt_at  ad_law2    $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_lt_at ad_law2   $cont  i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(2) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_mkt  ad_law2        if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_mkt  ad_law2     $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_mkt ad_law2   $cont  i.state_id#c.fyear   if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(2) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

 


*Table 7 *;
*Robustness tests for leverage 1. SIC2-year FE 2. Region-year FE 3. Beginning yr Char- year FE 4. Neighboring St AD Law etc.;
*Industry x year FE*;
reghdfe lev_dlc_dltt_at  ad_law2    $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear  i.sic_2#i.fyear ) vce(cluster cm_id )
outreg2 using do.xls, tstat replace tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

*Nine Census divisions (instead of Census regions) x year FE*;
reghdfe lev_dlc_dltt_at  ad_law2    $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear i.census_division#i.fyear ) vce(cluster cm_id )
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

*Firm characteristic x year FE along with firm and year FE*;
 reghdfe lev_dlc_dltt_at  ad_law2     if census_region_south!=. & randsamp1!=. ,  a( i.cm_id i.fyear c.ni_at_beg#i.fyear c.ppent_at_beg#i.fyear c.div_payer_beg#i.fyear c.state_inc_growth_beg#i.fyear c.ln_at_adj_beg#i.fyear ) vce(cluster cm_id )
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

*Control for neighboring state AD Law*;
*Neighboring ad law included*;
reghdfe lev_dlc_dltt_at  ad_law2 ad_sn_median $cont  /*i.state_id#c.fyear*/   if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls, tstat append tdec(2) rdec(2) bdec(3) addstat (Num obs, e(N))

 

 
*Table 8 Panel A ---  Control for RTW designation*;
 *Profitability tests w/controls*;
reghdfe  oibdp_atw  ad_law2  $cont2  rtw  i.state_id#c.fyear if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat replace  tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N))

*leverage ;
reghdfe lev_dlc_dltt_at  ad_law2 rtw i.state_id#c.fyear $cont    if census_region_south!=. & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append  tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))
  
*Table 8 Panels B-D  *;
*Drop southern states*;
reghdfe oibdp_atw  ad_law2  $cont2 i.state_id#c.fyear    if census_region_south!=1 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   replace tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2  $cont i.state_id#c.fyear   if census_region_south!=1 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append  tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

*Drop New York*;
reghdfe oibdp_atw  ad_law2  $cont2  i.state_id#c.fyear    if state_id!=33 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2  $cont  i.state_id#c.fyear    if state_id!=33 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

*Drop Illinois*;
reghdfe  oibdp_atw  ad_law2  $cont2  i.state_id#c.fyear    if state_id!=14 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2  $cont  i.state_id#c.fyear    if state_id!=14 & randsamp1!=. ,  a(cm_id fyear) vce(cluster cm_id)  
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

 
*Table 10: Black share state level*;
reghdfe oibdp_atw  ad_law2   i.state_id#c.fyear $cont2    if census_region_south!=. & randsamp1!=. & pctbk50_mod>= median_pctbk50    ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, replace  tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe oibdp_atw  ad_law2   i.state_id#c.fyear $cont2    if census_region_south!=. & randsamp1!=. & pctbk50_mod< median_pctbk50   ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2   i.state_id#c.fyear $cont    if census_region_south!=. & randsamp1!=. & pctbk50_mod>= median_pctbk50,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2   i.state_id#c.fyear $cont    if census_region_south!=. & randsamp1!=. & pctbk50_mod< median_pctbk50   ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))
 

*Table 11: Black share city level;
reghdfe oibdp_atw  ad_law2   i.state_id#c.fyear $cont2    if census_region_south!=. & randsamp1!=. & pctbk50_sma>= median_pctbk50_sma  & pctbk50_sma~=.  ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat replace tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe oibdp_atw  ad_law2   i.state_id#c.fyear $cont2    if census_region_south!=. & randsamp1!=. & pctbk50_sma< median_pctbk50_sma     & pctbk50_sma~=.  ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append  tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe lev_dlc_dltt_at  ad_law2   i.state_id#c.fyear $cont    if census_region_south!=. & randsamp1!=. & pctbk50_sma>= median_pctbk50_sma    & pctbk50_sma~=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append  tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe lev_dlc_dltt_at  ad_law2   i.state_id#c.fyear $cont    if census_region_south!=. & randsamp1!=. & pctbk50_sma<  median_pctbk50_sma    & pctbk50_sma~=.  ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append  tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)


*Table 12 (sub-sample tests)*;
*Panel A: Sub-sample by labor intensity*;
reghdfe oibdp_atw  ad_law2  $cont2    if census_region_south!=. & randsamp1!=. & sale_emp<=median_sale_emp  &  sale_emp~=.,  a(i.state_id#c.fyear cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   replace tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe oibdp_atw  ad_law2  $cont2    if census_region_south!=. & randsamp1!=. &  sale_emp>median_sale_emp  &  sale_emp~=.,  a( i.state_id#c.fyear cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2  $cont    if census_region_south!=. & randsamp1!=. & sale_emp<=median_sale_emp   &  sale_emp~=.,  a(i.state_id#c.fyear cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at  ad_law2  $cont    if census_region_south!=. & randsamp1!=. & sale_emp>median_sale_emp   &  sale_emp~=.,  a(i.state_id#c.fyear cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3)  addstat (Num obs, e(N), Num clusters, e(N_clust))


*Table 12 ;
*Panel B : AA migration*;
reghdfe oibdp_atw ad_law2  $cont2 i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. &  sost==0 &  r_migpr_50_70 >= r_migpr_med_50_70 & r_migpr_50_70~=. , a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe oibdp_atw ad_law2  $cont2 i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. & sost==0 & r_migpr_50_70 <r_migpr_med_50_70 & r_migpr_50_70 ~=. , a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe lev_dlc_dltt_at ad_law2  $cont i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. &  sost==0 & r_migpr_50_70 >=r_migpr_med_50_70 & r_migpr_50_70 ~=. , a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe lev_dlc_dltt_at ad_law2  $cont i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. & sost==0 & r_migpr_50_70 <r_migpr_med_50_70 & r_migpr_50_70~=., a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)



*Table 12 *;
*Panel C  Industry concentrtion   *;
reghdfe oibdp_atw ad_law2  $cont2   i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. &     r_herf_ind >=r_herf_ind_med & r_herf_ind ~=. , a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe oibdp_atw  ad_law2  $cont2  i.state_id#c.fyear if census_region_south!=. & randsamp1!=. &  r_herf_ind < r_herf_ind_med & r_herf_ind ~=. , a( cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)
   
reghdfe lev_dlc_dltt_at ad_law2  $cont   i.state_id#c.fyear  if census_region_south!=. & randsamp1!=. &    r_herf_ind >=r_herf_ind_med & r_herf_ind ~=. , a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

reghdfe lev_dlc_dltt_at ad_law2  $cont  i.state_id#c.fyear if census_region_south!=. & randsamp1!=. &  r_herf_ind <r_herf_ind_med & r_herf_ind ~=. , a(  cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, tstat append tdec(3) rdec(2) bdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *) e(N_clust depvar model clustvar vcetype wtype)

  


*Table 9: Augmented sample and enforcement vs. non-enforcement test*;
use "ad_dataset_ms2.dta", clear
global cont "ln_at_adj  ni_at  ppent_at  div_payer  state_inc_growth"
global cont2 "ln_at_adj     ppent_at  div_payer  state_inc_growth"

*Panel A and B; 
reghdfe oibdp_atw ad_law_landes   $cont2  i.state_id#c.fyear  if census_region_south!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, replace   tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at ad_law_landes   $cont  i.state_id#c.fyear  if census_region_south!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls, append   tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe oibdp_atw ad_law_enforce  ad_law_notenforce  $cont2  i.state_id#c.fyear  if census_region_south!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))

reghdfe lev_dlc_dltt_at ad_law_enforce  ad_law_notenforce   $cont  i.state_id#c.fyear  if census_region_south!=. ,  a(cm_id fyear) vce(cluster cm_id)
outreg2 using do.xls,   append tstat    tdec(3) rdec(2) bdec(3) addstat (Num obs, e(N), Num clusters, e(N_clust))
 
 
  
 
