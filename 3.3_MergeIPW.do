/* =============================================================================
MERGE INVERSE PROBABILITY WEIGHTS BACK TO MAIN DATASET

Author: Laura Gimeno

NOTE: Ammend file paths 
==============================================================================*/

* Get main dataset
use "long_form.dta", clear
count

* Merge in weights 
merge 1:1 id year using "weights_combined.dta"
drop _merge 

save "long_form_ipws.dta", replace 

* We generate the final analysis weights by multiplying the IPWs and the survey weights 
gen tot_wtcore = resp_w50 * comb_wtcore 
gen tot_wtn = resp_w50 * comb_wtn 

save "long_form_ipws.dta", replace 
