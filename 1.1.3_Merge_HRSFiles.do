/*==============================================================================
EXTRACTION OF WEIGHTS FROM CORE 2016 AND 2018 FILES AND MERGING OF HRS VARIABLES

In this script I extract weights for 2016 and 2018 which do not feature in the 
RAND longitudinal file or the harmonised dataset, and I merge them with the 
subset of variables extracted from RAND HRS longitudinal file and harmonised 
HRS, linking by person ID. 

Author: Laura Gimeno
==============================================================================*/ 

* Ammend file path here 
use "trk2020v2/trk2020tr_r.dta", clear

keep HHID PN PPMWGTR QPMWGTR // keep weights for 2016 and 2018 which were not in RAND longitudinal file
rename PPMWGTR r13nwtresp // format same as RAND file
rename QPMWGTR r14nwtresp
gen str9 hhidpn=HHID+PN
drop HHID PN
destring hhidpn, replace 

* Save tracker weights - ammend file path here 
save "trackerweights.dta", replace 

* Open Master dataset - ammed path here 
use "RANDvars.dta", clear

* Merge in variables from harmonised dataset - ammend path here 
merge 1:1 hhidpn using "hrs_harmo.dta"

drop _merge // all are matched 

* Merge in remaining weights from tracker file - ammend path here 
merge 1:1 hhidpn using "trackerweights.dta"

drop if _merge == 2 // keep the observations in the master file
count
drop _merge

* Save intermediate dataset - ammend file path 
save "hrs_merged.dta", replace
