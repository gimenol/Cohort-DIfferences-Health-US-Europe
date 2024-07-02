/* =============================================================================
MULTIPLE IMPUTATION OF LONG FORM DATA 

This do file takes the data that is stored in long form, and extracts a number 
of predictors of non-response. We impute missing values for these predictors of
non-response in order to include the data in logit models that predict the 
probability of non-response to a given sweep.

Note that we impute data for everyone, even  if they are missing from the sweep, 
because we have limited information in some studies about why someone is a non-
respondent because they are ineligible (died, migrated) or because they dropped 
out of the study. We overcome this limitation by multiplying non-response weights 
by the cross-sectional survey weight so that the combined weight will always 
be 0 if the individual was non-respondent.

Author: Laura Gimeno
==============================================================================*/

* Ammend file path 
use "long_form.dta", clear 

gen age2 = age^2
gen countrycohort = cohort*country

keep id svy_core svy_n comb_wtcore comb_wtn totalsweeps_core ///
	 totalsweeps_nurse year pnum ///
	 country countrygrp study countrycohort ///
	 age age2 cohort birthyear gender ///
	 mar_stat child self_health education ///
	 mob_any adl_any iadl_any ///
	 diab cancer lung heart hibp

mi set flong

mi register regular gender year 
mi register imputed svy_n svy_core age age2 comb_wtcore comb_wtn ///
			totalsweeps_core totalsweeps_nurse mar_stat child self_health ///
			mob_any iadl_any adl_any diab cancer lung heart hibp countrycohort /// 
			cohort birthyear country countrygrp study education pnum 

tab _mi_miss // choosing variables that are already fairly complete (so 47% complete observations)

* There are a number of variables here that are complete (age, age2, cohort, birth year
* country, country group, study, totalsweeps, country*cohort interaction term, weights etc)
* so  we include them in the 'regress' part of the MI model in order to overcome 
* issues related to model convergence. 

mi impute chained (regress) age age2 birthyear cohort country countrygrp ///
							study totalsweeps_core totalsweeps_nurse countrycohort ///
							comb_wtcore comb_wtn pnum ///
				  (logit, augment) adl_any iadl_any mob_any hibp diab cancer ///
								   lung heart education svy_core svy_n mar_stat ///
								   child self_health ///
				  = year, ///
				  by(gender) rseed(1234) force dots noisily add(20) burnin(10) 

save "mi_long_form", replace 

use "mi_long_form", clear // reshape to wide 
sleep 1000
mi reshape wide svy_n svy_core age age2 comb_wtcore comb_wtn mar_stat child ///
				self_health mob_any iadl_any adl_any diab cancer lung heart ///
				hibp countrycohort education, i(id) j(year)
save "mi_wide_form", replace
