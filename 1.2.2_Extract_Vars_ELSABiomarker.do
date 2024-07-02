/*==============================================================================
EXTRACTION OF VARIABLES FROM ELSA NURSE SWEEPS 

The purpose of this script is to use extract variables that are relevant to the 
analysis from the ELSA nurse sweeps dataset. These variables will be used for the 
sensitivity analyese using biomarker data.

Author: Laura Gimeno 

NOTE: Make sure to ammend file paths. All files were downloaded from the UK 
Data Service (SN 5050)
==============================================================================*/ 

* Sweep 2 (2004)

use "UKDA-5050-stata/stata/stata13_se/wave_2_nurse_data_v2.dta", clear 
keep idauniq w2wtbld chol hba1c 
rename idauniq id 
rename w2wtbld ELSA_bldwt_2004 
rename chol bldchol_2004 
rename hba1c hba1c_2004 
save "ELSA_bloods_2004.dta", replace 

* Sweep 4 (2008)
use "UKDA-5050-stata/stata/stata13_se/wave_4_nurse_data.dta", clear
keep idauniq w4bldwt chol hba1c  
rename idauniq id 
rename w4bldwt ELSA_bldwt_2008
rename chol bldchol_2008
rename hba1c hba1c_2008
save "ELSA_bloods_2008.dta", replace 

* Sweep 6 (2012)
use "UKDA-5050-stata/stata/stata13_se/wave_6_elsa_nurse_data_v2.dta", clear
keep idauniq w6bldwt chol hba1c  
rename idauniq id 
rename w6bldwt ELSA_bldwt_2012
rename chol bldchol_2012 
rename hba1c hba1c_2012
save "ELSA_bloods_2012.dta", replace 

* Sweep 8/9 dataset (2016) 
use "UKDA-5050-stata/stata/stata13_se/elsa_nurse_w8w9_data_eul.dta", clear
keep idauniq w89bldwt chol hba1c 
rename idauniq id 
rename w89bldwt ELSA_bldwt_2016 
rename chol bldchol_2016
rename hba1c hba1c_2016 
duplicates report 
duplicates report id // two individuals have two records, but the records are different from one another
sort id 
quietly by id: gen dup = cond(_N == 1, 0, _n) // flag duplicates by ID
list if dup != 0
drop if dup == 2 // drop second observation based on ID (shouldn't affect results as not assigned weights anyway)
duplicates report id // all uniquely identfying observations 
drop dup
save "ELSA_bloods_2016.dta", replace 

* Merge the nurse sweeps together
use "ELSA_bloods_2004.dta", clear 
merge 1:1 id using "ELSA_bloods_2008.dta"
drop _merge 
merge 1:1 id using "ELSA_bloods_2012.dta"
drop _merge 
merge 1:1 id using "ELSA_bloods_2016.dta"
drop _merge 
save "ELSA_biomarkers.dta", replace 
