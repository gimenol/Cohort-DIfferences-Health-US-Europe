/*==============================================================================
MERGING HRS, ELSA AND SHARE 

In this script, I merge together the cleaned datasets for HRS, SHARE and ELSA. 

Author: Laura Gimeno 

NOTE: Make sure to ammend file paths.
==============================================================================*/ 

* Open Master dataset (HRS)
use "hrs_prep.dta", clear 

* Convert variable ID to string so that we can match with SHARE and ELSA 
tostring ID, replace 
codebook ID

* Merge ELSA
append using "elsa_prep.dta"

* Merge in SHARE 
append using "share_prep.dta"

* Save 
save "merged.dta", replace

foreach y in 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace COMB_WTN_`y' = 0 if COMB_WTN_`y' ==. 
	replace COMB_WTCORE_`y' = 0 if COMB_WTCORE_`y' ==.
	replace SVY_CORE_`y' = 0 if SVY_CORE_`y' ==.
	replace SVY_N_`y' = 0 if SVY_N_`y' == . 
}

* Drop variables that relate to the period before 2004 
drop *_199* *_2000 *_2002

* Keep only those who responded at least once from 2004 onwards 
keep if TOTALSWEEPS_CORE > 0 | TOTALSWEEPS_NURSE > 0

count // 128,776

save "merged.dta", replace
