/*==============================================================================
TRANSFORMING DATA FROM WIDE TO LONG

In this script, I transform the dataset from wide format (1 row per individual,
and columns for measurements in each year) to long format (1 row for each survey
year with observations for individuals split across rows). This is the format 
in which the data will be analysed. 

Once each row corresponds to a single year, I can easily compute some new variables
which are row-specific (i.e. in the wide format they would be spread across 
several columns): age-group, age2, and indicators for whether an individual is a 
'valid' respondent in that year (i.e., they have a positive analysis weight, 
a flag that indicates that they participated in the survey, and are aged 50+). 
I also transform all variable names to lower case and remove trailing underscores.

Author: Laura Gimeno 
==============================================================================*/ 

* Ammend file path 
use "merged.dta", replace

gen pnum = _n

/* 
There is no need to change any of the svy indicators or names of the weights
because this was all dealt with at the cleaning stage.

We do not need to transform gender, country, country group, study, cohort, 
education, gender or FPC because these remain constant across waves. 
*/ 

reshape long AGE_ AGEGRP_ MAR_STAT_ CHILD_ /// * demographic variables 
			 COMB_PSU1_ COMB_STRAT1_ ///  * sampling variables 
			 SVY_N_ SVY_CORE_  PROXY_ /// * whether participated in wave 
			 COMB_WTCORE_ COMB_WTN_  /// * weighting variables 
			 RANK_CORE_ RANK_NURSE_ ///
			 ADL_ANY_ ADL_SCORE_ ADL_MISS_ SEV_ADL_ /// * ADL limitations 
			 IADL_ANY_ IADL_SCORE_ IADL_MISS_ SEV_IADL_ /// * IADL limitations 
			 LIMITATION_ MILD_DISABILITY_ MOD_DISABILITY_ SEV_DISABILIY_ /// * disability indicators
			 SELF_HEALTH_ ///
			 MOB_ANY_ MOB_SCORE_ MOB_MISS_ SEV_MOB_ /// * mobility limitations 
			 CANCER_ DIAB_ HEART_ HIBP_ CHOL_ LUNG_ /// * doctor diagnoses 
			 OBESE_SR_ OBESE_MSRED_ /// * obesity 
			 NUMSMOK_ ///
			 SYS_BP_ DIA_BP_ MEDS_HIBP_ /// * for measured high BP
			 SYS_TREAT_ DIA_TREAT_ HIBPM_ HIBPTREAT_ ///
			 BMI_SR_ BMI_MSRED_ /// * measured BMI
			 GRIP_ HEIGHT_ WEIGHT_ MEDS_DIAB_ MEDS_CHOL_ ///
			 ELSA_bldwt_ hba1c_ bldchol_, i(ID) j(year)

save "long_form.dta", replace

* Put all variables in lower case and remove tailing underscore 
foreach v of varlist _all  {
capture ren `v' `=lower("`v'")'
}
rename *_ *

replace age = year - birthyear if age ==. // for SHARE 2008 
drop if birthyear ==.
drop if totalsweeps_core == 0 & totalsweeps_nurse == 0 
drop if age < 50 // not part of target
drop if cohort == 6 // drop born after 1960 
drop if year < 2004 // outside of period of interest
drop if year == 2008 & study == 3 // drop SHARE observations for 2008 when no data was collected

* Force values for chronic disease to take value of 1 if after a report of 1 in the data 
global disease diab cancer heart lung chol hibp

forval i = 1/7 {
foreach d in $disease {
	bysort id (year): replace `d' = 1 if `d'[_n-1] == 1  
}
foreach d in $disease {
	bysort id (year): replace `d' = 0 if `d'[_n+1] == 0
}
}

* Use height from wave 1 or 2 to complete missing height (assume this won't change much)
bysort id: egen heightmean = mean(height)
replace height = heightmean if height ==.
drop heightmean

* Correct total sweeps
drop totalsweeps_core 
bysort id: egen totalsweeps_core = sum(svy_core)
replace totalsweeps_core = 0 if totalsweeps_core ==.
drop totalsweeps_nurse
bysort id: egen totalsweeps_nurse = sum(svy_n)
replace totalsweeps_nurse = 0 if totalsweeps_nurse ==.

* Correct typo in one of the variable names 
rename sev_disabiliy sev_disability

recode chol .d=. .m=. .r=. .a=. 
recode self_health .m=. 

preserve
sort id year 
by id: keep if _n == 1
count // 114,526 people 
restore

* Ammend file path
save "long_form.dta", replace
