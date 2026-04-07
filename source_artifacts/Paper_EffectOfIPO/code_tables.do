*********************************************************************
* The following code replicates the summary statistics presented in Figure 1   and all tables of sample distribution, summary statistics, and regression results presented in the paper and internet appendix.
*********************************************************************

cd "PATH TO DIRECTORY WITH DATA FILES"

*****************************************************************
**************** Figures and tables in the paper ****************
*****************************************************************

*** Figure 1
*** Draw the figures in Excel based on the descriptive statistics
use sample_full, clear //Final sample used for the descriptive statistics and the regressions.

global etr="gaap_etr"
global higher_than_ipo="higher_than_ipo_gaap_etr"

* Figure 1a
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year0==1, stat(mean) f(%9.4f) //IPO_Year
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year1==1, stat(mean) f(%9.4f) //IPO_Year+1
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year2==1, stat(mean) f(%9.4f) //IPO_Year+2

* Figure 1b
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year0==1, stat(mean) f(%9.4f) //IPO_Year
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year1==1, stat(mean) f(%9.4f) //IPO_Year+1
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year2==1, stat(mean) f(%9.4f) //IPO_Year+2


global etr="cash_etr"
global higher_than_ipo="higher_than_ipo_cash_etr"

* Figure 1c
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year0==1, stat(mean) f(%9.4f) //IPO_Year
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year1==1, stat(mean) f(%9.4f) //IPO_Year+1
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==1 & ipo_year2==1, stat(mean) f(%9.4f) //IPO_Year+2

* Figure 1d
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year0==1, stat(mean) f(%9.4f) //IPO_Year
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year1==1, stat(mean) f(%9.4f) //IPO_Year+1
fsum ipo1_lag$etr lag$etr $etr if $higher_than_ipo==0 & ipo_year2==1, stat(mean) f(%9.4f) //IPO_Year+2



*** descriptive statistics of IPOs
use sample_full, clear
bysort ipo_dealnumber: keep if _n==_N
rename ipo_dealnumber dealnumber 
keep dealnumber
merge 1:1 dealnumber using ipo_variables //The IPO dataset
keep if _merge==3
drop _merge 

* Table 1, Panel B: IPO distribution by year
tab ipo_year

* Table 2, Panel B: descriptive statistics of IPOs
fsum grossproceeds ir uw_rank big4 at_preipoyr pi_at_preipoyr, stat(mean median sd) f(%12.4f)


*** descriptive statistics of incumbent firms
*** Table 1, Panel B: distribution of incumbent firms by year
use sample_full, clear
tab fyear

* Table 2, Panel A: descriptive statistics of incumbent firms
* The continuous variables are winsorized by year at the 1st and 99th percentiles.
fsum cash_etr lagcash_etr ipo1_lagcash_etr cash_etr_median gaap_etr laggaap_etr ipo1_laggaap_etr gaap_etr_median s_rd s_ad s_sga s_capexp s_cash s_fi s_eqinc nol s_intangible s_ppent s_fcf size roa_pretax lev_lt, stat(mean median sd) f(%9.4f)

fsum ch1_cash_etr diff_lagcash_etr diff_median_lagcash_etr ch1_gaap_etr diff_laggaap_etr diff_median_laggaap_etr ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_nol ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt, stat(mean median sd) f(%9.4f)



*** Regression results
*** Table 3
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global cv="ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_nol ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table3, excel replace ctitle(ch1_$etr) addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table3, excel append ctitle(ch1_$etr) addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 4, Columns (1) and (2)
use sample_full, clear
drop if ipo_news_LN_high==.

* winsorization
foreach v of varlist ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

gen diff_lagetr_news_high=diff_lag$etr *ipo_news_LN_high
reg ch1_$etr diff_lag$etr ipo_news_LN_high diff_lagetr_news_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel replace ctitle(ch1_$etr News) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

drop diff_lagetr_news_high
gen diff_lagetr_news_high=diff_lag$etr *ipo_news_LN_high
reg ch1_$etr diff_lag$etr ipo_news_LN_high diff_lagetr_news_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel append ctitle(ch1_$etr News) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
use sample_full, clear
drop if ch_gtrends_ipo_1m_neg==.

* winsorization
foreach v of varlist ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

gen diff_lagetr_ch_gtrends_neg=diff_lag$etr * ch_gtrends_ipo_1m_neg
reg ch1_$etr diff_lag$etr ch_gtrends_ipo_1m_neg diff_lagetr_ch_gtrends_neg $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel append ctitle(ch1_$etr "Incumbent Investor Attention") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

drop diff_lagetr_ch_gtrends_neg
gen diff_lagetr_ch_gtrends_neg=diff_lag$etr * ch_gtrends_ipo_1m_neg
reg ch1_$etr diff_lag$etr ch_gtrends_ipo_1m_neg diff_lagetr_ch_gtrends_neg $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel append ctitle(ch1_$etr "Incumbent Investor Attention") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (5) and (6)
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

gen diff_lagetr_recent_public=diff_lag$etr *public_private_prior_IPO_wi5yr
reg ch1_$etr diff_lag$etr public_private_prior_IPO_wi5yr diff_lagetr_recent_public $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel append ctitle(ch1_$etr "Previously Public IPOs") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
test diff_lag$etr +diff_lagetr_recent_public=0


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

drop diff_lagetr_recent_public
gen diff_lagetr_recent_public=diff_lag$etr *public_private_prior_IPO_wi5yr
reg ch1_$etr diff_lag$etr public_private_prior_IPO_wi5yr diff_lagetr_recent_public $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table4, excel append ctitle(ch1_$etr "Previously Public IPOs") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
test diff_lag$etr +diff_lagetr_recent_public=0



*** Table 5, Columns (1) and (2)
use sample_full, clear
drop if lagibes_net_pre==.

* winsorization
foreach v of varlist ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

gen diff_lagetr_lagibes_net_pre=diff_lag$etr *lagibes_net_pre
reg ch1_$etr diff_lag$etr lagibes_net_pre diff_lagetr_lagibes_net_pre $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table5, excel replace ctitle(ch1_$etr "Incumbent with Analyst Implied ETR Forecast") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

drop diff_lagetr_lagibes_net_pre
gen diff_lagetr_lagibes_net_pre=diff_lag$etr *lagibes_net_pre
reg ch1_$etr diff_lag$etr lagibes_net_pre diff_lagetr_lagibes_net_pre $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table5, excel append ctitle(ch1_$etr "Incumbent with Analyst Implied ETR Forecast") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

use sample_full, clear
foreach v of varlist yr_02to04 yr_09 yr_12 yr_17 {
gen diff_lagetr_`v'=diff_lag$etr *`v'
}

reg ch1_$etr diff_lag$etr diff_lagetr_yr_* yr_02to04 yr_09 yr_12 yr_17 $diff_median $cv, cluster(gvkey)
outreg2 using reg_table5, excel append ctitle(ch1_$etr "Enactment Years of Major Corporate Tax Legislation") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

use sample_full, clear
foreach v of varlist yr_02to04 yr_09 yr_12 yr_17 {
gen diff_lagetr_`v'=diff_lag$etr *`v'
}

reg ch1_$etr diff_lag$etr diff_lagetr_yr_* yr_02to04 yr_09 yr_12 yr_17 $diff_median $cv, cluster(gvkey)
outreg2 using reg_table5, excel append ctitle(ch1_$etr "Enactment Years of Major Corporate Tax Legislation") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 6, Panel A - GAAP ETR
global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global higher_than_ipo="higher_than_ipo_gaap_etr"

use sample_full, clear
gen diff_lagetr_same_quintile=diff_lag$etr *same_quint_lag$etr
reg ch1_$etr diff_lag$etr same_quint_lag$etr diff_lagetr_same_quintile $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table6_panelA, excel replace ctitle(ch1_$etr "Distance from the IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 6, Panel B - GAAP ETR
*** Columns (1) and (2)
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==1, cluster(gvkey)
outreg2 using reg_table6_panelB, excel replace ctitle(Table_6_Panel_B ch1_$etr "Higher than IPO" "Same Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==0, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Higher than IPO" "Different Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr


*** Columns (3) and (4)
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==1, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Lower than IPO" "Same Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==0, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Lower than IPO" "Different Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr



*** Table 6, Panel C - GAAP ETR
use sample_full, clear
gen diff_lagetr_low_etr=diff_lag$etr * lower_than_median_$etr
reg ch1_$etr diff_lag$etr lower_than_median_$etr diff_lagetr_low_etr $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table6_panelC, excel replace ctitle(ch1_$etr lower_than_ipo) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
test diff_lag$etr + diff_lagetr_low_etr =0



*** Table 6, Panel A - Cash ETR
global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"
global higher_than_ipo="higher_than_ipo_cash_etr"

use sample_full, clear
gen diff_lagetr_same_quintile=diff_lag$etr *same_quint_lag$etr
reg ch1_$etr diff_lag$etr same_quint_lag$etr diff_lagetr_same_quintile $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table6_panelA, excel append ctitle(ch1_$etr "Distance from the IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Table 6, Panel B - Cash ETR
*** Columns (1) and (2)
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==1, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Higher than IPO" "Same Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==0, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Higher than IPO" "Different Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1 &same_quint_lag$etr==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr


*** Columns (3) and (4)
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==1, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Lower than IPO" "Same Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==0, cluster(gvkey)
outreg2 using reg_table6_panelB, excel append ctitle(ch1_$etr "Lower than IPO" "Different Quintile") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0 &same_quint_lag$etr==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr



*** Table 6, Panel C - Cash ETR
use sample_full, clear
gen diff_lagetr_low_etr=diff_lag$etr * lower_than_median_$etr
reg ch1_$etr diff_lag$etr lower_than_median_$etr diff_lagetr_low_etr $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table6_panelC, excel append ctitle(ch1_$etr lower_than_ipo) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
test diff_lag$etr + diff_lagetr_low_etr =0



*** Table 7, Columns (1) and (2)
use sample_full, clear
drop if missing(ln_gtrends_filing_mth, ln_gtrends_filing_l12m, abs_vwret_mth_1m, turnover_mth_1m, ln_num_analyst, ln_mve, mtb)

* winsorization
foreach v of varlist ln_gtrends_filing_mth ln_gtrends_filing_l12m abs_vwret_mth_1m turnover_mth_1m ln_num_analyst ln_mve mtb {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

* herding indicator
foreach v in "cash_etr" "gaap_etr" {
gen diff_lag_ch1_`v'=diff_lag`v'*ch1_`v'
xtile xtile4_diff_lag_ch1_`v'=diff_lag_ch1_`v', n(4)
gen mimic4_`v'=0 if xtile4_diff_lag_ch1_`v'==4
replace mimic4_`v'=1 if xtile4_diff_lag_ch1_`v'==1
}


global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg ln_gtrends_filing_mth mimic4_$etr ln_gtrends_filing_l12m abs_vwret_mth_1m turnover_mth_1m ln_num_analyst ln_mve mtb i.fyear, cluster(gvkey)
outreg2 using reg_table7, excel replace ctitle(ln_gtrends_filing_mth "Investor Attention in 10-K Filing Month" "$etr") addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ln_gtrends_filing_mth mimic4_$etr ln_gtrends_filing_l12m abs_vwret_mth_1m turnover_mth_1m ln_num_analyst ln_mve mtb i.fyear, cluster(gvkey)
outreg2 using reg_table7, excel append ctitle(ln_gtrends_filing_mth "Investor Attention in 10-K Filing Month" "$etr") addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
use sample_full, clear
drop if missing(ch_f1_num_analyst_pct, ch1_size, ch1_s_intangible, ch1_mtb, ch1_issuance_eq_debt_f1yr, ch1_ewret, ch1_turnover, ch1_retsd)

* winsorization
foreach v of varlist ch_f1_num_analyst_pct ch1_size ch1_s_intangible ch1_mtb ch1_ewret ch1_turnover ch1_retsd {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

* herding indicator
foreach v in "cash_etr" "gaap_etr" {
gen diff_lag_ch1_`v'=diff_lag`v'*ch1_`v'
xtile xtile4_diff_lag_ch1_`v'=diff_lag_ch1_`v', n(4)
gen mimic4_`v'=0 if xtile4_diff_lag_ch1_`v'==4
replace mimic4_`v'=1 if xtile4_diff_lag_ch1_`v'==1
}


global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg ch_f1_num_analyst_pct mimic4_$etr ch1_size ch1_s_intangible ch1_mtb ch1_issuance_eq_debt_f1yr ch1_ewret ch1_turnover ch1_retsd i.fyear, cluster(gvkey)
outreg2 using reg_table7, excel append ctitle(ch_f1_num_analyst_pct "Change in Analyst Following" "$etr") addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ch_f1_num_analyst_pct mimic4_$etr ch1_size ch1_s_intangible ch1_mtb ch1_issuance_eq_debt_f1yr ch1_ewret ch1_turnover ch1_retsd i.fyear, cluster(gvkey)
outreg2 using reg_table7, excel append ctitle(ch_f1_num_analyst_pct "Change in Analyst Following" "$etr") addtext(Year FE, Yes) drop(i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 8, Panel A
*** Columns (1) to (3)
use sample_full, clear
drop if diff_fn_tax_cosine==.|diff_fn_nontax_cosine==.

* winsorization
foreach v of varlist ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

* herding indicator
foreach v in "cash_etr" "gaap_etr" {
gen diff_lag_ch1_`v'=diff_lag`v'*ch1_`v'
xtile xtile4_diff_lag_ch1_`v'=diff_lag_ch1_`v', n(4)
gen mimic4_`v'=0 if xtile4_diff_lag_ch1_`v'==4
replace mimic4_`v'=1 if xtile4_diff_lag_ch1_`v'==1
}


global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg diff_fn_nontax_cosine mimic4_$etr $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel replace ctitle(diff_fn_nontax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg diff_fn_tax_cosine mimic4_$etr $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel append ctitle(diff_fn_tax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg diff_fn_tax_cosine mimic4_$etr diff_fn_nontax_cosine $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel append ctitle(diff_fn_tax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (4) to (6)
global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg diff_fn_nontax_cosine mimic4_$etr $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel append ctitle(diff_fn_nontax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg diff_fn_tax_cosine mimic4_$etr $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel append ctitle(diff_fn_tax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg diff_fn_tax_cosine mimic4_$etr diff_fn_nontax_cosine $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelA, excel append ctitle(diff_fn_tax_cosine $etr) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 8, Panel B
*** Columns (1) and (2)
global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global higher_than_ipo="higher_than_ipo_gaap_etr"

use sample_full, clear
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1, cluster(gvkey)
outreg2 using reg_table8_panelB, excel replace ctitle(Table_8_Panel_B ch1_$etr Higher than IPO) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table8_panelB, excel append ctitle(ch1_$etr Lower than IPO) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr


*** Columns (3) and (4)
global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"
global higher_than_ipo="higher_than_ipo_cash_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1, cluster(gvkey)
outreg2 using reg_table8_panelB, excel append ctitle(ch1_$etr Higher than IPO) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==1
estimates store high

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table8_panelB, excel append ctitle(ch1_$etr Lower than IPO) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2
reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear if $higher_than_ipo==0
estimates store low
suest high low, cluster(gvkey)
test [high_mean]diff_lag$etr = [low_mean]diff_lag$etr



*** Table 8, Panel C
use sample_IPOyear, clear //Sample of the incumbent years ending in the significant IPO year

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelC, excel replace ctitle(IPOYear ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_table8_panelC, excel append ctitle(IPOYear ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table 8, Panel D
*** Columns (1) and (2)
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global higher_than_ipo="higher_than_ipo_gaap_etr"

gen diff_lagetr_ab_ch_vaa_neg=diff_lag$etr *ab_ch_vaa_neg
reg ch1_$etr diff_lag$etr ab_ch_vaa_neg diff_lagetr_ab_ch_vaa_neg $diff_median $cv i.fyear if $higher_than_ipo==1, cluster(gvkey)
outreg2 using reg_table8_panelD, excel replace ctitle(ch1_$etr "Higher than IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

gen diff_lagetr_ab_ch_vaa_pos=diff_lag$etr *ab_ch_vaa_pos
reg ch1_$etr diff_lag$etr ab_ch_vaa_pos diff_lagetr_ab_ch_vaa_pos $diff_median $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table8_panelD, excel append ctitle(ch1_$etr "Lower than IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global higher_than_ipo="higher_than_ipo_gaap_etr"

gen diff_lagetr_ab_ch_tax_res_neg=diff_lag$etr *ab_ch_tax_res_neg
reg ch1_$etr diff_lag$etr ab_ch_tax_res_neg diff_lagetr_ab_ch_tax_res_neg $diff_median $cv i.fyear if $higher_than_ipo==1, cluster(gvkey)
outreg2 using reg_table8_panelD, excel append ctitle(ch1_$etr "Higher than IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

gen diff_lagetr_ab_ch_tax_res_pos=diff_lag$etr *ab_ch_tax_res_pos
reg ch1_$etr diff_lag$etr ab_ch_tax_res_pos diff_lagetr_ab_ch_tax_res_pos $diff_median $cv i.fyear if $higher_than_ipo==0, cluster(gvkey)
outreg2 using reg_table8_panelD, excel append ctitle(ch1_$etr "Lower than IPO") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*****************************************************************
************* Tables in the internet appendix *******************
*****************************************************************

*** Table EC.1
use ipo_variables, clear
keep ipo_name ipo_year sic2
order ipo_name ipo_year sic2
sort ipo_name



*** Table EC.3, Panel A
*** Columns (1) and (2)
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg ch1_$etr diff_lag$etr diff_lagcfo_pretax $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelA, excel replace ctitle("ch1_$etr") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ch1_$etr diff_lag$etr diff_lagcfo_pretax $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelA, excel append ctitle("ch1_$etr") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

reg ch1_$etr diff_lag$etr diff_lagroa_pretax $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelA, excel append ctitle("ch1_$etr") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

reg ch1_$etr diff_lag$etr diff_lagroa_pretax $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelA, excel append ctitle("ch1_$etr") addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table EC.3, Panel B
use sample_msa, clear //Sample of incumbent firms defined as those located in the same MSA as a significant IPO.

global etr="gaap_etr"
global diff_median="diff_median9_laggaap_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear i.sic2, cluster(gvkey)
outreg2 using reg_tableEC3_panelB, excel replace ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes, Industry FE, Yes) drop($cv i.fyear i.sic2) depvar tstat bdec(3) tdec(2) adjr2


global etr="cash_etr"
global diff_median="diff_median9_lagcash_etr"

reg ch1_$etr diff_lag$etr $diff_median $cv i.fyear i.sic2, cluster(gvkey)
outreg2 using reg_tableEC3_panelB, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes, Industry FE, Yes) drop($cv i.fyear i.sic2) depvar tstat bdec(3) tdec(2) adjr2



*** Table EC.3, Panel C
*** Columns (1) and (2)
use sample_full, clear

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"
global same_above_median="same_above_median_gaap" 
global same_below_median="same_below_median_gaap" 
global above_ipo="above_ipo_gaap_etr"
global below_ipo="below_ipo_gaap_etr"
	
reg ch1_$etr $below_ipo $cv i.fyear if $same_above_median==1, cluster(gvkey)
outreg2 using reg_tableEC3_panelC, excel replace ctitle(ch1_$etr Above Median) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg ch1_$etr $above_ipo $cv i.fyear if $same_below_median==1, cluster(gvkey)
outreg2 using reg_tableEC3_panelC, excel append ctitle(ch1_$etr Below Median) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2


*** Columns (3) and (4)
global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"
global same_above_median="same_above_median_cash" 
global same_below_median="same_below_median_cash" 
global above_ipo="above_ipo_cash_etr"
global below_ipo="below_ipo_cash_etr"
	
reg ch1_$etr $below_ipo $cv i.fyear if $same_above_median==1, cluster(gvkey)
outreg2 using reg_tableEC3_panelC, excel append ctitle(ch1_$etr Above Median) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2

reg ch1_$etr $above_ipo $cv i.fyear if $same_below_median==1, cluster(gvkey)
outreg2 using reg_tableEC3_panelC, excel append ctitle(ch1_$etr Below Median) addtext(Controls, Yes, Year FE, Yes) drop($cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2



*** Table EC.3, Panel D
*** Columns (1) to (3)
use sample_full, clear
drop if ipo_lagab_acc_high==.

* winsorization
foreach v of varlist ch1_s_rd ch1_s_ad ch1_s_sga ch1_s_capexp ch1_s_cash ch1_s_fi ch1_s_eqinc ch1_s_intangible ch1_s_ppent ch1_s_fcf ch1_size ch1_roa_pretax ch1_lev_lt {
bysort fyear: egen pct1=pctile(`v'), p(1)
bysort fyear: egen pct99=pctile(`v'), p(99)
replace `v'=pct1 if `v'<pct1
replace `v'=pct99 if `v'>pct99& `v'!=.
drop pct1 pct99
}

global etr="gaap_etr"
global diff_median="diff_median_laggaap_etr"

gen diff_ipo_lagab_acc_high=diff_lag$etr *ipo_lagab_acc_high
gen diff_ipo_lagab_acc_abs_high=diff_lag$etr *ipo_lagab_acc_abs_high
gen diff_ipo_lagfsd_score_high=diff_lag$etr *ipo_lagfsd_score_high

reg ch1_$etr diff_lag$etr ipo_lagab_acc_high diff_ipo_lagab_acc_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel replace ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 

reg ch1_$etr diff_lag$etr ipo_lagab_acc_abs_high diff_ipo_lagab_acc_abs_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 

reg ch1_$etr diff_lag$etr ipo_lagfsd_score_high diff_ipo_lagfsd_score_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 


*** Columns (4) to (6)
global etr="cash_etr"
global diff_median="diff_median_lagcash_etr"

drop diff_ipo_lagab_acc_high diff_ipo_lagab_acc_abs_high diff_ipo_lagfsd_score_high
gen diff_ipo_lagab_acc_high=diff_lag$etr *ipo_lagab_acc_high
gen diff_ipo_lagab_acc_abs_high=diff_lag$etr *ipo_lagab_acc_abs_high
gen diff_ipo_lagfsd_score_high=diff_lag$etr *ipo_lagfsd_score_high

reg ch1_$etr diff_lag$etr ipo_lagab_acc_high diff_ipo_lagab_acc_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 

reg ch1_$etr diff_lag$etr ipo_lagab_acc_abs_high diff_ipo_lagab_acc_abs_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 

reg ch1_$etr diff_lag$etr ipo_lagfsd_score_high diff_ipo_lagfsd_score_high $diff_median $cv i.fyear, cluster(gvkey)
outreg2 using reg_tableEC3_panelD, excel append ctitle(ch1_$etr) addtext(Controls, Yes, Year FE, Yes) drop($diff_median $cv i.fyear) depvar tstat bdec(3) tdec(2) adjr2 



*** Table EC.3, Panel E
use sample_ipwra, clear //Sample of IPO industry's incumbent firms and firms in all other industries that did not experience a significant IPO event within the three years preceding and three years after an incumbent firm's industry IPO event.

*** Incumbents ETR > IPO ETR
global etr="cash_etr"

teffects ipwra (ch1_$etr $cv i.fyear)(higher_than_ipo1_$etr $cv i.fyear), vce(cl gvkey) 
tebalance summarize

teffects ipwra (ch1_$etr $cv i.fyear)(higher_than_ipo1_$etr $cv i.fyear), vce(cl gvkey) atet
tebalance summarize


global etr="gaap_etr"

teffects ipwra (ch1_$etr $cv i.fyear) (higher_than_ipo1_$etr $cv i.fyear), vce(cl gvkey)
tebalance summarize

teffects ipwra (ch1_$etr $cv i.fyear) (higher_than_ipo1_$etr $cv i.fyear), vce(cl gvkey) atet
tebalance summarize


*** Incumbents ETR < IPO ETR
global etr="cash_etr"

teffects ipwra (ch1_$etr $cv i.fyear)(lower_than_ipo1_$etr $cv i.fyear), vce(cl gvkey)
tebalance summarize

teffects ipwra (ch1_$etr $cv i.fyear)(lower_than_ipo1_$etr $cv i.fyear), vce(cl gvkey) atet
tebalance summarize


global etr="gaap_etr"

teffects ipwra (ch1_$etr $cv i.fyear) (lower_than_ipo1_$etr $cv i.fyear), vce(cl gvkey)
tebalance summarize

teffects ipwra (ch1_$etr $cv i.fyear) (lower_than_ipo1_$etr $cv i.fyear), vce(cl gvkey) atet
tebalance summarize




