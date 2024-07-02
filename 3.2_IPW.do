/* =============================================================================
INVERSE PROBABILITY WEIGHTS FOR CORE INTERVIEWS 

This code takes the imputed data in wide format, and constructs logistic regression
models to predict the probability of response to each wave given a respondent's 
individual-level characteristics. 

Because we imputed data only for sweeps where a participant was age-eligible, 
we need to run multiple regressions for those who entered the study in 2004, then 
entered the study in 2006, then 2008, then 2010, etc.

We run models for each study, and in SHARE we include an additional indicator of 
country in the models. 

We then create different versions of the variable (truncating at 99th percentile,
50, 30, and 20), and multiply each of these with the cross-sectional  weights. 
In a later do-file, we test these different weights to choose a truncation value.

Author: Laura Gimeno
==============================================================================*/

* Ammend path file 
use "mi_wide_form", clear
sort _mi_m study 

*===============================================================================
* CORE INTERVIEWS
*===============================================================================

***************** HEALTH AND RETIREMENT STUDY **********************************

* For 2006 ---------------------------------------------------------------------

mi estimate, saving(mi_ipw_est_us06, replace) dots: ///
			logit svy_core2006 i.gender c.age2004 svy_core2004 mar_stat2004 ///
				  child2004 self_health2004 mob_any2004 iadl_any2004 adl_any2004 ///
				  diab2004 lung2004 heart2004 hibp2004 i.cohort c.birthyear ///
				  education2004 if study == 1 
mi predict xb using mi_ipw_est_us06 if study == 1 
mi passive: gen resp_prob2006 = invlogit(xb) if study == 1 & svy_core2006 == 1
mi passive: gen resp_w2006 = 1/resp_prob2006 if study == 1 & svy_core2006 == 1
sum resp_w2006 if svy_core2006 == 1 & study == 1 
drop xb 

* For 2008 ---------------------------------------------------------------------

mi estimate, saving(mi_ipw_est_us08a, replace) dots: ///
			logit svy_core2008 i.gender c.age2006 svy_core2004 svy_core2006 ///
			      mar_stat2004 mar_stat2006 child2004 child2006 self_health2004 ///
				  self_health2006 mob_any2004 mob_any2006 iadl_any2004 iadl_any2006 ///
				  adl_any2004 adl_any2006 diab2004 diab2006 lung2004 lung2006 ///
				  heart2004 heart2006 hibp2004 hibp2006 i.cohort c.birthyear ///
				  education2006 if study == 1 
mi predict xb11 using mi_ipw_est_us08a if study == 1
mi passive: gen resp_prob2008 = invlogit(xb11) if study == 1 & svy_core2008 == 1 

mi estimate, saving(mi_ipw_est_us08b, replace) dots: ///
			logit svy_core2008 i.gender c.age2006 svy_core2006 mar_stat2006 ///
			child2006 self_health2006 mob_any2006 iadl_any2006 adl_any2006 ///
			diab2006 lung2006 heart2006 hibp2006 i.cohort c.birthyear ///
			education2006 if study == 1 
mi predict xb12 using mi_ipw_est_us08b if study == 1
mi passive: replace resp_prob2008 = invlogit(xb12) if study == 1 & resp_prob2008 ==. & svy_core2008 == 1 

mi passive: gen resp_w2008 = 1/resp_prob2008 if study == 1 & svy_core2008 == 1 
sum resp_w2008 if svy_core2008 == 1 & study == 1 
drop xb11 xb12  

* For 2010 ---------------------------------------------------------------------

mi estimate, saving(mi_ipw_est_us10a, replace) dots: ///
			logit svy_core2010 i.gender c.age2008 svy_core2004 svy_core2006 ///
				  svy_core2008 mar_stat2004 mar_stat2006 mar_stat2008 /// 
				  child2004 child2006 child2008 self_health2004 self_health2006 ///
				  self_health2008 mob_any2004 mob_any2006 mob_any2008 ///
				  iadl_any2004 iadl_any2006 iadl_any2008 adl_any2004 adl_any2006 ///
				  adl_any2008 diab2004 diab2006 diab2008 lung2004 lung2006 ///
				  lung2008 heart2004 heart2006 heart2008 hibp2004 hibp2006 hibp2008 ///
				  i.cohort c.birthyear education2008 if study == 1 
mi predict xb21 using mi_ipw_est_us10a if study == 1
mi passive: gen resp_prob2010 = invlogit(xb21) if study == 1 & svy_core2010 == 1 

mi estimate, saving(mi_ipw_est_us10b, replace) dots: ///
			logit svy_core2010 i.gender c.age2008 svy_core2006 svy_core2008 ///
				  mar_stat2006 mar_stat2008 child2006 child2008 self_health2006 ///
				  self_health2008 mob_any2006 mob_any2008 iadl_any2006 ///
				  iadl_any2008 adl_any2006 adl_any2008 diab2006 diab2008 lung2006 ///
				  lung2008 heart2006 heart2008 hibp2006 hibp2008 i.cohort ///
				  c.birthyear education2008 if study == 1 
mi predict xb22 using mi_ipw_est_us10b if study == 1
mi passive: replace resp_prob2010 = invlogit(xb22) if study == 1 & resp_prob2010 ==. & svy_core2010 == 1 

mi estimate, saving(mi_ipw_est_us10c, replace) dots: ///
			logit svy_core2010 i.gender c.age2008 svy_core2008 mar_stat2008 ///
				  child2008 self_health2008 mob_any2008 iadl_any2008 diab2008 ///
				  lung2008 heart2008 hibp2008 i.cohort c.birthyear ///
				  education2008 if study == 1 
mi predict xb23 using mi_ipw_est_us10c if study == 1
mi passive: replace resp_prob2010 = invlogit(xb23) if study == 1 & resp_prob2010 ==. & svy_core2010 == 1 

mi passive: gen resp_w2010 = 1/resp_prob2010 if study == 1  & svy_core2010 == 1
sum resp_w2010 if svy_core2010 == 1 & study == 1
drop xb21 xb22 xb23 

* For 2012 ---------------------------------------------------------------------

mi estimate, saving(mi_ipw_est_us12a, replace) dots: ///
			logit svy_core2012 i.gender c.age2010 svy_core2004 svy_core2006 ///
				  svy_core2008 svy_core2010 mar_stat2004 mar_stat2006 mar_stat2008 ///
				  mar_stat2010 child2004 child2006 child2008 child2010 self_health2004 ///
				  self_health2006 self_health2008 self_health2010 mob_any2004 ///
				  mob_any2006 mob_any2008 mob_any2010 iadl_any2004 iadl_any2006 ///
				  iadl_any2008 iadl_any2010 adl_any2004 adl_any2006 adl_any2008 ///
				  adl_any2010 diab2004 diab2006 diab2008 diab2010 lung2004 lung2006 ///
				  lung2008 lung2010 heart2004 heart2006 heart2008 heart2010 ///
				  hibp2004 hibp2006 hibp2008 hibp2010 i.cohort c.birthyear ///
				  education2010 if study == 1 
mi predict xb31 using mi_ipw_est_us12a if study == 1
mi passive: gen resp_prob2012 = invlogit(xb31) if study == 1 & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_us12b, replace) dots: ///
			logit svy_core2012 i.gender c.age2010 svy_core2006 svy_core2008 ////
				  svy_core2010 mar_stat2006 mar_stat2008 mar_stat2010 child2006 ///
				  child2008 child2010 self_health2006 self_health2008 self_health2010 ///
				  mob_any2006 mob_any2008 mob_any2010 iadl_any2006 iadl_any2008 ///
				  iadl_any2010 adl_any2006 adl_any2008 adl_any2010 diab2006 diab2008 ///
				  diab2010 lung2006 lung2008 lung2010 heart2006 heart2008 heart2010 ///
				  hibp2006 hibp2008 hibp2010 i.cohort c.birthyear education2010 if study == 1 
mi predict xb32 using mi_ipw_est_us12b if study == 1
mi passive: replace resp_prob2012 = invlogit(xb32) if study == 1 & resp_prob2012 ==. & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_us12c, replace) dots: ///
			logit svy_core2012 i.gender c.age2010  svy_core2008 svy_core2010 ///
				  mar_stat2008 mar_stat2010 child2008 child2010 self_health2008 ///
				  self_health2010 mob_any2008 mob_any2010 iadl_any2008 iadl_any2010 ///
				  adl_any2008 adl_any2010 diab2008 diab2010 lung2008 lung2010 heart2008 ///
				  heart2010 hibp2008 hibp2010 i.cohort c.birthyear education2010 if study == 1 
mi predict xb33 using mi_ipw_est_us12c if study == 1
mi passive: replace resp_prob2012 = invlogit(xb33) if study == 1 & resp_prob2012 ==. & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_us12d, replace) dots: ///
			logit svy_core2012 i.gender c.age2010 svy_core2010 mar_stat2010 ///
				  child2010 self_health2010 mob_any2010 iadl_any2010 adl_any2010 ///
				  diab2010 lung2010 heart2010 hibp2010 i.cohort c.birthyear ///
				  education2010 if study == 1 
mi predict xb34 using mi_ipw_est_us12d if study == 1
mi passive: replace resp_prob2012 = invlogit(xb34) if study == 1 & resp_prob2012 ==. & svy_core2012 == 1 

mi passive: gen resp_w2012 = 1/resp_prob2012 if study == 1 & svy_core2012 == 1 
sum resp_w2012 if svy_core2012 == 1 & study == 1
drop xb31 xb32 xb33 xb34 

* For 2014 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_us14a, replace) dots: ///
			logit svy_core2014 i.gender c.age2012 svy_core2004 svy_core2006 ///
			      svy_core2008 svy_core2010 svy_core2012 mar_stat2004 mar_stat2006 ///
				  mar_stat2008 mar_stat2010 mar_stat2012 child2004 child2006 ///
				  child2008 child2010 child2012 self_health2004 self_health2006 ///
				 self_health2008 self_health2010 self_health2012 mob_any2004 ///
				 mob_any2006 mob_any2008 mob_any2010 mob_any2012 iadl_any2004 ///
				 iadl_any2006 iadl_any2008 iadl_any2010 iadl_any2012 adl_any2004 ///
				 adl_any2006 adl_any2008 adl_any2010 adl_any2012 diab2004 diab2006 /// 
				 diab2008 diab2010 diab2012 lung2004 lung2006 lung2008 lung2010 ///
				 lung2012 heart2004 heart2006 heart2008 heart2010 heart2012 hibp2004 ///
				 hibp2006 hibp2008 hibp2010 hibp2012 i.cohort c.birthyear ///
				 education2012 if study == 1 
mi predict xb41 using mi_ipw_est_us14a if study == 1 
mi passive: gen resp_prob2014 = invlogit(xb41) if study == 1 & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_us14b, replace) dots: ///
			logit svy_core2014 i.gender c.age2012 svy_core2006 svy_core2008 ///
				  svy_core2010 svy_core2012 mar_stat2006 mar_stat2008 mar_stat2010 ///
				  mar_stat2012 child2006 child2008 child2010 child2012 self_health2006 ///
				  mob_any2008 mob_any2010 mob_any2012 iadl_any2006 iadl_any2008 ///
				  iadl_any2010 iadl_any2012 adl_any2006 adl_any2008 adl_any2010 ///
				  hibp2008 hibp2010 hibp2012 i.cohort c.birthyear ///
				  education2012 if study == 1 
mi predict xb42 using mi_ipw_est_us14b if study == 1
mi passive: replace resp_prob2014 = invlogit(xb42) if study == 1 & resp_prob2014 ==. & svy_core2014 == 1

mi estimate, saving(mi_ipw_est_us14c, replace) dots: ///
			logit svy_core2014 i.gender c.age2012 svy_core2008 svy_core2010 ///
				  svy_core2012 mar_stat2008 mar_stat2010 mar_stat2012 child2008 ///
				  child2010 child2012 self_health2008 self_health2010 self_health2012 ///
				  mob_any2008 mob_any2010 mob_any2012 iadl_any2008 iadl_any2010 ///
				  iadl_any2012 adl_any2008 adl_any2010 adl_any2012 diab2008 diab2010 ///
				  diab2012 lung2008 lung2010 lung2012 heart2008 heart2010 heart2012 ///
				  hibp2008 hibp2010 hibp2012 i.cohort c.birthyear education2012 if study == 1 
mi predict xb43 using mi_ipw_est_us14c if study == 1
mi passive: replace resp_prob2014 = invlogit(xb43) if study == 1  & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_us14d, replace) dots: ///
			logit svy_core2014 i.gender c.age2012 svy_core2010 svy_core2012 ///
				  mar_stat2010 mar_stat2012 child2010 child2012 self_health2010 ///
				  self_health2012 mob_any2010 mob_any2012 iadl_any2010 iadl_any2012 ///
				  adl_any2010 adl_any2012 diab2010 diab2012 lung2010 lung2012 ///
				  heart2010 heart2012 hibp2010 hibp2012 i.cohort c.birthyear ///
				  education2012 if study == 1 
mi predict xb44 using mi_ipw_est_us14d if study == 1
mi passive: replace resp_prob2014 = invlogit(xb44) if study == 1  & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_us14e, replace) dots: ///
			logit svy_core2014 i.gender c.age2012 svy_core2012 mar_stat2012 ///
				  child2012 self_health2012 mob_any2012 iadl_any2012 adl_any2012 ///
				  diab2012 lung2012 heart2012 hibp2012 i.cohort c.birthyear ///
				  education2012 if study == 1 
mi predict xb45 using mi_ipw_est_us14e if study == 1
mi passive: replace resp_prob2014 = invlogit(xb45) if study == 1 & resp_prob2014 ==. & svy_core2014 == 1 

mi passive: gen resp_w2014 = 1/resp_prob2014 if study == 1 & svy_core2014 == 1
sum resp_w2014 if svy_core2014 == 1 & study == 1 
drop xb41 xb42 xb43 xb44 xb45

* For 2016 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_us16a, replace) dots: ///
			logit svy_core2016 i.gender c.age2014 svy_core2004 svy_core2006 ///
				  svy_core2008 svy_core2010 svy_core2012 svy_core2014 mar_stat2004 /// 
				  mar_stat2006 mar_stat2008 mar_stat2010 mar_stat2012 mar_stat2014 ///
				  child2004 child2006 child2008 child2010 child2012 child2014 ///
				  self_health2004 self_health2006 self_health2008 self_health2010 ///
				  self_health2012 self_health2014 mob_any2004 mob_any2006 mob_any2008 ///
				  mob_any2010 mob_any2012 mob_any2014 iadl_any2004 iadl_any2006 ///
				  iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 adl_any2004 ///
				  adl_any2006 adl_any2008 adl_any2010 adl_any2012 adl_any2014 diab2004 ///
				  diab2006 diab2008 diab2010 diab2012 diab2014 lung2004 lung2006 ///
				  lung2008 lung2010 lung2012 lung2014 heart2004 heart2006 heart2008 ///
				  heart2010 heart2012 heart2014 hibp2004 hibp2006 hibp2008 hibp2010 ///
				  hibp2012 hibp2014 i.cohort c.birthyear education2014 if study == 1 
mi predict xb51 using mi_ipw_est_us16a if study == 1 
mi passive: gen resp_prob2016 = invlogit(xb51) if study == 1 & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_us16b, replace) dots: ///
			logit svy_core2016 i.gender c.age2014 svy_core2006 svy_core2008 ///
				  svy_core2010 svy_core2012 svy_core2014 mar_stat2006 mar_stat2008 ///
				  mar_stat2010 mar_stat2012 mar_stat2014 child2006 child2008 ///
				  child2010 child2012 child2014 self_health2006 self_health2008 ///
				  self_health2010 self_health2012 self_health2014 mob_any2006 /// 
				  mob_any2008 mob_any2010 mob_any2012 mob_any2014 iadl_any2006 ///
				  iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 adl_any2006 ///
				  adl_any2008 adl_any2010 adl_any2012 adl_any2014 diab2006 diab2008 ///
				  diab2010 diab2012 diab2014 lung2006 lung2008 lung2010 lung2012 ///
				  lung2014 heart2006 heart2008 heart2010 heart2012 heart2014 hibp2006 ///
				  hibp2008 hibp2010 hibp2012 hibp2014 i.cohort c.birthyear ///
				  education2014 if study == 1 
mi predict xb52 using mi_ipw_est_us16b if study == 1
mi passive: replace resp_prob2016 = invlogit(xb52) if study == 1  & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_us16c, replace) dots: ///
			logit svy_core2016 i.gender c.age2014 svy_core2008 svy_core2010 ///
				  svy_core2012 svy_core2014 mar_stat2008 mar_stat2010 mar_stat2012 ///
				  mar_stat2014 child2008 child2010 child2012 child2014 self_health2008 ///
				  self_health2010 self_health2012 self_health2014 mob_any2008 mob_any2010 ///
				  mob_any2012 mob_any2014 iadl_any2008 iadl_any2010 iadl_any2012 ///
				  iadl_any2014 adl_any2008 adl_any2010 adl_any2012 adl_any2014 diab2008 ///
				  diab2010 diab2012 diab2014 lung2008 lung2010 lung2012 lung2014 ///
				  heart2008 heart2010 heart2012 heart2014 hibp2008 hibp2010 hibp2012 ///
				  hibp2014 i.cohort c.birthyear education2014 if study == 1 
mi predict xb53 using mi_ipw_est_us16c if study == 1
mi passive: replace resp_prob2016 = invlogit(xb53) if study == 1 & resp_prob2016 ==. & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_us16d, replace) dots: /// 
			logit svy_core2016 i.gender c.age2014 svy_core2010 /// 
				  svy_core2012 svy_core2014 mar_stat2010 mar_stat2012 mar_stat2014 ///
				  child2010 child2012 child2014 self_health2010 self_health2012 ///
				  self_health2014 mob_any2010 mob_any2012 mob_any2014 iadl_any2010 /// 
				  iadl_any2012 iadl_any2014 adl_any2010 adl_any2012 adl_any2014 diab2010 ///
				  diab2012 diab2014 lung2010 lung2012 lung2014 heart2010 heart2012 ///
				  heart2014 hibp2010 hibp2012 hibp2014 i.cohort c.birthyear ///
				  education2014 if study == 1 
mi predict xb54 using mi_ipw_est_us16d if study == 1
mi passive: replace resp_prob2016 = invlogit(xb54) if study == 1 & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_us16e, replace) dots: ///
			logit svy_core2016 i.gender c.age2014 svy_core2012 svy_core2014 ///
				  mar_stat2012 mar_stat2014 child2012 child2014 self_health2012 ///
				  self_health2014 mob_any2012 mob_any2014 iadl_any2012 iadl_any2014 ///
				  adl_any2012 adl_any2014 diab2012 diab2014 lung2012 lung2014 heart2012 ///
				  heart2014 hibp2012 hibp2014 i.cohort c.birthyear education2014 if study == 1 
mi predict xb55 using mi_ipw_est_us16e if study == 1
mi passive: replace resp_prob2016 = invlogit(xb55) if study == 1 & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_us16f, replace) dots: ///
			logit svy_core2016 i.gender c.age2014 svy_core2014 mar_stat2014 ///
			child2014 self_health2014 mob_any2014 iadl_any2014 adl_any2014 ///
			diab2014 lung2014 heart2014 hibp2014 i.cohort c.birthyear ///
			education2014 if study == 1 
mi predict xb56 using mi_ipw_est_us16f if study == 1
mi passive: replace resp_prob2016 = invlogit(xb56) if study == 1 & resp_prob2016 ==. & svy_core2016 == 1 

mi passive: gen resp_w2016 = 1/resp_prob2016 if study == 1 & svy_core2016 == 1 
sum resp_w2016 if svy_core2016 == 1 & study == 1 
drop xb51 xb52 xb53 xb54 xb55 xb56 

* For 2018 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_us18a, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2004 svy_core2006 ///
			  svy_core2008 svy_core2010 svy_core2012 svy_core2014 svy_core2016 ///
			  mar_stat2004 mar_stat2006 mar_stat2008 mar_stat2010 mar_stat2012 ///
			  mar_stat2014 mar_stat2016 child2004 child2006 child2008 child2010 ///
			  child2012 child2014 child2016 self_health2004 self_health2006 ///
			  self_health2008 self_health2010 self_health2012 self_health2014 ///
			  self_health2016 mob_any2004 mob_any2006 mob_any2008 mob_any2010 ///
			  mob_any2012 mob_any2014 mob_any2016 iadl_any2004 iadl_any2006 ///
			  iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 iadl_any2016 ///
			  adl_any2004 adl_any2006 adl_any2008 adl_any2010 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2004 diab2006 diab2008 diab2010 diab2012 ///
			  diab2014 diab2016 lung2004 lung2006 lung2008 lung2010 lung2012 ///
			  lung2014 lung2016 heart2004 heart2006 heart2008 heart2010 heart2012 ///
			  heart2014 heart2016 hibp2004 hibp2006 hibp2008 hibp2010 hibp2012 ///
			  hibp2014 hibp2016 i.cohort c.birthyear education2016 if study == 1 
mi predict xb61 using mi_ipw_est_us18a if study == 1 & svy_core2018 == 1 
mi passive: gen resp_prob2018 = invlogit(xb61) if study == 1

mi estimate, saving(mi_ipw_est_us18b, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2006 svy_core2008 /// 
			  svy_core2010 svy_core2012 svy_core2014 svy_core2016 mar_stat2006 /// 
			  mar_stat2008 mar_stat2010 mar_stat2012 mar_stat2014 mar_stat2016 ///
			  child2006 child2008 child2010 child2012 child2014 child2016 self_health2006 ///
			  self_health2008 self_health2010 self_health2012 self_health2014 ///
			  self_health2016 mob_any2006 mob_any2008 mob_any2010 mob_any2012 mob_any2014 ///
			  mob_any2016 iadl_any2006 iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 ///
			  iadl_any2016 adl_any2006 adl_any2008 adl_any2010 adl_any2012 adl_any2014 ///
			  adl_any2016 diab2006 diab2008 diab2010 diab2012 diab2014 diab2016 lung2006 ///
			  lung2008 lung2010 lung2012 lung2014 lung2016 heart2006 heart2008 heart2010 ///
			  heart2012 heart2014 heart2016 hibp2006 hibp2008 hibp2010 hibp2012 hibp2014 ///
			  hibp2016 i.cohort c.birthyear education2016 if study == 1  
mi predict xb62 using mi_ipw_est_us18b if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb62) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_us18c, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2008 svy_core2010 ///
			  svy_core2012 svy_core2014 svy_core2016 mar_stat2008 mar_stat2010 ///
			  mar_stat2012 mar_stat2014 mar_stat2016 child2008 child2010 child2012 ///
			  child2014 child2016 self_health2008 self_health2010 self_health2012 ///
			  self_health2014 self_health2016 mob_any2008 mob_any2010 mob_any2012 ///
			  mob_any2014 mob_any2016 iadl_any2008 iadl_any2010 iadl_any2012 ///
			  iadl_any2014 iadl_any2016 adl_any2008 adl_any2010 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2008 diab2010 diab2012 diab2014 ///
			  diab2016 lung2008 lung2010 lung2012 lung2014 lung2016 heart2008 ///
			  heart2010 heart2012 heart2014 heart2016 hibp2008 hibp2010 hibp2012 ///
			  hibp2014 hibp2016 i.cohort c.birthyear education2016 if study == 1 
mi predict xb63 using mi_ipw_est_us18c if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb63) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_us18d, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2010 svy_core2012 svy_core2014 ///
			  svy_core2016 mar_stat2010 mar_stat2012 mar_stat2014 mar_stat2016 ///
			  child2010 child2012 child2014 child2016 self_health2010 self_health2012 ///
			  self_health2014 self_health2016 mob_any2010 mob_any2012 mob_any2014 ///
			  mob_any2016 iadl_any2010 iadl_any2012 iadl_any2014 iadl_any2016 ///
			  adl_any2010 adl_any2012 adl_any2014 adl_any2016 diab2010 diab2012 ///
			  diab2014 diab2016 lung2010 lung2012 lung2014 lung2016 heart2010 ///
			  heart2012 heart2014 heart2016 hibp2010 hibp2012 hibp2014 hibp2016 ///
			  i.cohort c.birthyear education2016 if study == 1 
mi predict xb64 using mi_ipw_est_us18d if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb64) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_us18e, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2012 svy_core2014 svy_core2016 ///
			  mar_stat2012 mar_stat2014 mar_stat2016 child2012 child2014 child2016 ///
			  self_health2012 self_health2014 self_health2016 mob_any2012 mob_any2014 ///
			  mob_any2016 iadl_any2012 iadl_any2014 iadl_any2016 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2012 diab2014 diab2016 lung2012 lung2014 ///
			  lung2016 heart2012 heart2014 heart2016 hibp2012 hibp2014 hibp2016 ///
			  i.cohort c.birthyear education2016 if study == 1 
mi predict xb65 using mi_ipw_est_us18e if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb65) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_us18f, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2014 svy_core2016 /// 
		mar_stat2014 mar_stat2016 child2014 child2016 self_health2014 self_health2016 ///
		mob_any2014 mob_any2016 iadl_any2014 iadl_any2016 adl_any2014 adl_any2016 ///
		diab2014 diab2016 lung2014 lung2016 heart2014 heart2016 hibp2014 hibp2016 ///
		i.cohort c.birthyear education2016 if study == 1 
mi predict xb66 using mi_ipw_est_us18f if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb66) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_us18g, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2016 mar_stat2016 child2016 ///
		self_health2016 mob_any2016 iadl_any2016 adl_any2016 diab2016 lung2016 ///
		heart2016 hibp2016 i.cohort c.birthyear education2016 if study == 1 
mi predict xb67 using mi_ipw_est_us18g if study == 1 
mi passive: replace resp_prob2018 = invlogit(xb67) if study == 1 & resp_prob2018 ==. & svy_core2018 == 1

mi passive: gen resp_w2018 = 1/resp_prob2018 if study == 1 & svy_core2018 == 1
sum resp_w2018 if svy_core2018 == 1 & study == 1 
drop xb61 xb62 xb63 xb64 xb65 xb66 xb67 

********************* ENGLISH LONGITUDINAL STUDY OF AGEING *********************

* For 2006 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk06, replace) dots: ///
		logit svy_core2006 i.gender c.age2004 svy_core2004 mar_stat2004 ///
			  child2004 self_health2004 mob_any2004 iadl_any2004 adl_any2004 ///
			  diab2004 lung2004 heart2004 hibp2004 i.cohort c.birthyear ///
			  education2004 if study == 2
mi predict xb using mi_ipw_est_uk06 if study == 2
mi passive: replace resp_prob2006 = invlogit(xb) if study == 2 & svy_core2006 == 1 
mi passive: replace resp_w2006 = 1/resp_prob2006 if study == 2 & resp_w2006 ==. & svy_core2006 == 1 
sum resp_w2006 if svy_core2006 == 1 & study == 2
drop xb 

* For 2008 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk08a, replace) dots: ///
		logit svy_core2008 i.gender c.age2006 svy_core2004 svy_core2006 ///
			  mar_stat2004 mar_stat2006 child2004 child2006 self_health2004 ///
			  self_health2006 mob_any2004 mob_any2006 iadl_any2004 iadl_any2006 ///
			  adl_any2004 adl_any2006 diab2004 diab2006 lung2004 lung2006 ///
			  heart2004 heart2006 hibp2004 hibp2006 i.cohort c.birthyear ///
			  education2006 if study == 2
mi predict xb11 using mi_ipw_est_uk08a if study == 2 
mi passive: replace resp_prob2008 = invlogit(xb11) if study == 2 & svy_core2008 == 1 

mi estimate, saving(mi_ipw_est_uk08b, replace) dots: ///
		logit svy_core2008 i.gender c.age2006 svy_core2006 mar_stat2006 ///
			  child2006 self_health2006 mob_any2006 iadl_any2006 adl_any2006 ///
			  diab2006 lung2006 heart2006 hibp2006 i.cohort c.birthyear ///
			  education2006 if study == 2
mi predict xb12 using mi_ipw_est_uk08b if study == 2
mi passive: replace resp_prob2008 = invlogit(xb12) if study == 2 & resp_prob2008 ==. & svy_core2008 == 1 

mi passive: replace resp_w2008 = 1/resp_prob2008 if study == 2 & resp_w2008 ==. & svy_core2008 == 1 
sum resp_w2008 if svy_core2008 == 1 & study == 2
drop xb11 xb12  

* For 2010 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk10a, replace) dots: ///
		logit svy_core2010 i.gender c.age2008 svy_core2004 svy_core2006 ///
			  svy_core2008 mar_stat2004 mar_stat2006 mar_stat2008 child2004 ///
			  child2006 child2008 self_health2004 self_health2006 self_health2008 ///
			  mob_any2004 mob_any2006 mob_any2008 iadl_any2004 iadl_any2006  ///
			  iadl_any2008 adl_any2004 adl_any2006 adl_any2008 diab2004 diab2006 ///
			  diab2008 lung2004 lung2006 lung2008 heart2004 heart2006 heart2008 hibp2004 ///
			  hibp2006 hibp2008 i.cohort c.birthyear education2008 if study == 2
mi predict xb21 using mi_ipw_est_uk10a if study == 2
mi passive: replace resp_prob2010 = invlogit(xb21) if study == 2 & svy_core2010 == 1

mi estimate, saving(mi_ipw_est_uk10b, replace) dots: ///
		logit svy_core2010 i.gender c.age2008 svy_core2006 svy_core2008 ///
			  mar_stat2006 mar_stat2008 child2006 child2008 self_health2006 ///
			  self_health2008 mob_any2006 mob_any2008 iadl_any2006 iadl_any2008 ///
			  adl_any2006 adl_any2008 diab2006 diab2008 lung2006 lung2008 heart2006 ///
			  heart2008 hibp2006 hibp2008 i.cohort c.birthyear education2008 if study == 2
mi predict xb22 using mi_ipw_est_uk10b if study == 2
mi passive: replace resp_prob2010 = invlogit(xb22) if study == 2 & resp_prob2010 ==. & svy_core2010 == 1

mi estimate, saving(mi_ipw_est_uk10c, replace) dots: ///
		logit svy_core2010 i.gender c.age2008 svy_core2008 mar_stat2008 ///
		child2008 self_health2008 mob_any2008 iadl_any2008 diab2008 lung2008 ///
		heart2008 hibp2008 i.cohort c.birthyear education2008 if study == 2
mi predict xb23 using mi_ipw_est_uk10c if study == 2
mi passive: replace resp_prob2010 = invlogit(xb23) if study == 2 & resp_prob2010 ==. & svy_core2010 == 1 

mi passive: replace resp_w2010 = 1/resp_prob2010 if study == 2 & resp_w2010 ==. & svy_core2010 == 1 
sum resp_w2010 if svy_core2010 == 1 & study == 2
drop xb21 xb22 xb23 

* For 2012 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk12a, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2004 svy_core2006 ///
			  svy_core2008 svy_core2010 mar_stat2004 mar_stat2006 mar_stat2008 ///
			  mar_stat2010 child2004 child2006 child2008 child2010 self_health2004 ///
			  self_health2006 self_health2008 self_health2010 mob_any2004 ///
			  mob_any2006 mob_any2008 mob_any2010 iadl_any2004 iadl_any2006 ///
			  iadl_any2008 iadl_any2010 adl_any2004 adl_any2006 adl_any2008 ///
			  adl_any2010 diab2004 diab2006 diab2008 diab2010 lung2004 lung2006 ///
			  lung2008 lung2010 heart2004 heart2006 heart2008 heart2010 hibp2004 ///
			  hibp2006 hibp2008 hibp2010 i.cohort c.birthyear education2010 if study == 2
mi predict xb31 using mi_ipw_est_uk12a if study == 2
mi passive: replace resp_prob2012 = invlogit(xb31) if study == 2 & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_uk12b, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2006 svy_core2008 svy_core2010 ///
		mar_stat2006 mar_stat2008 mar_stat2010 child2006 child2008 child2010 ///
		self_health2006 self_health2008 self_health2010 mob_any2006 mob_any2008 ///
		mob_any2010 iadl_any2006 iadl_any2008 iadl_any2010 adl_any2006 adl_any2008 ///
		adl_any2010 diab2006 diab2008 diab2010 lung2006 lung2008 lung2010 heart2006 ///
		heart2008 heart2010 hibp2006 hibp2008 hibp2010 i.cohort c.birthyear education2010 if study == 2 
mi predict xb32 using mi_ipw_est_uk12b if study == 2
mi passive: replace resp_prob2012 = invlogit(xb32) if study == 2 & resp_prob2012 ==. & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_uk12c, replace) dots: ///
		logit svy_core2012 i.gender c.age2010  svy_core2008 svy_core2010 mar_stat2008 ///
		mar_stat2010 child2008 child2010 self_health2008 self_health2010 mob_any2008 ///
		mob_any2010 iadl_any2008 iadl_any2010 adl_any2008 adl_any2010 diab2008 diab2010 ///
		lung2008 lung2010 heart2008 heart2010 hibp2008 hibp2010 i.cohort c.birthyear ///
		education2010 if study == 2
mi predict xb33 using mi_ipw_est_uk12c if study == 2
mi passive: replace resp_prob2012 = invlogit(xb33) if study == 2 & resp_prob2012 ==. & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_uk12d, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2010 mar_stat2010 child2010 ///
		self_health2010 mob_any2010 iadl_any2010 adl_any2010 diab2010 lung2010 ///
		heart2010 hibp2010 i.cohort c.birthyear education2010 if study == 2
mi predict xb34 using mi_ipw_est_uk12d if study == 2
mi passive: replace resp_prob2012 = invlogit(xb34) if study == 2 & resp_prob2012 ==. & svy_core2012 == 1 

mi passive: replace resp_w2012 = 1/resp_prob2012 if study == 2 & resp_w2012 ==. & svy_core2012 == 1 
sum resp_w2012 if svy_core2012 == 1 & study == 2
drop xb31 xb32 xb33 xb34 

* For 2014 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk14a, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2004 svy_core2006 ///
			  svy_core2008 svy_core2010 svy_core2012 mar_stat2004 mar_stat2006 ///
			  mar_stat2008 mar_stat2010 mar_stat2012 child2004 child2006 child2008 ///
			  child2010 child2012 self_health2004 self_health2006 self_health2008 ///
			  self_health2010 self_health2012 mob_any2004 mob_any2006 mob_any2008 ///
			  mob_any2010 mob_any2012 iadl_any2004 iadl_any2006 iadl_any2008 ///
			  iadl_any2010 iadl_any2012 adl_any2004 adl_any2006 adl_any2008 ///
			  adl_any2010 adl_any2012 diab2004 diab2006 diab2008 diab2010 diab2012 ///
			  lung2004 lung2006 lung2008 lung2010 lung2012 heart2004 heart2006 ///
			  heart2008 heart2010 heart2012 hibp2004 hibp2006 hibp2008 hibp2010 /// 
			  hibp2012 i.cohort c.birthyear education2012 if study == 2
mi predict xb41 using mi_ipw_est_uk14a if study == 2
mi passive: replace resp_prob2014 = invlogit(xb41) if study == 2 & svy_core2014 == 1  

mi estimate, saving(mi_ipw_est_uk14b, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2006 svy_core2008 ///
			  svy_core2010 svy_core2012 mar_stat2006 mar_stat2008 mar_stat2010 /// 
			  mar_stat2012 child2006 child2008 child2010 child2012 self_health2006 ///
			  self_health2008 self_health2010 self_health2012 mob_any2006 mob_any2008 ///
			  mob_any2010 mob_any2012 iadl_any2006 iadl_any2008 iadl_any2010 iadl_any2012 ///
			  adl_any2006 adl_any2008 adl_any2010 adl_any2012 diab2006 diab2008 ///
			  diab2010 diab2012 lung2006 lung2008 lung2010 lung2012 heart2006 ///
			  heart2008 heart2010 heart2012 hibp2006 hibp2008 hibp2010 hibp2012 ///
			  i.cohort c.birthyear education2012 if study == 2
mi predict xb42 using mi_ipw_est_uk14b if study == 2
mi passive: replace resp_prob2014 = invlogit(xb42) if study == 2 & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_uk14c, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2008 svy_core2010 ///
			  svy_core2012 mar_stat2008 mar_stat2010 mar_stat2012 child2008 child2010 ///
			  child2012 self_health2008 self_health2010 self_health2012 mob_any2008 ///
			  mob_any2010 mob_any2012 iadl_any2008 iadl_any2010 iadl_any2012 ///
			  adl_any2008 adl_any2010 adl_any2012 diab2008 diab2010 diab2012 ///
			  lung2008 lung2010 lung2012 heart2008 heart2010 heart2012 hibp2008 ///
			  hibp2010 hibp2012 i.cohort c.birthyear education2012 if study == 2
mi predict xb43 using mi_ipw_est_uk14c if study == 2
mi passive: replace resp_prob2014 = invlogit(xb43) if study == 2 & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_uk14d, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2010 svy_core2012 ///
			  mar_stat2010 mar_stat2012 child2010 child2012 self_health2010 ///
			  self_health2012 mob_any2010 mob_any2012 iadl_any2010 iadl_any2012 ///
			  adl_any2010 adl_any2012 diab2010 diab2012 lung2010 lung2012 ///
			  heart2010 heart2012 hibp2010 hibp2012 i.cohort c.birthyear ///
			  education2012 if study == 2
mi predict xb44 using mi_ipw_est_uk14d if study == 2
mi passive: replace resp_prob2014 = invlogit(xb44) if study == 2 & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_uk14e, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2012 mar_stat2012 ///
			  child2012 self_health2012 mob_any2012 iadl_any2012 adl_any2012 ///
			  diab2012 lung2012 heart2012 hibp2012 i.cohort c.birthyear ///
			  education2012 if study == 2 
mi predict xb45 using mi_ipw_est_uk14e if study == 2
mi passive: replace resp_prob2014 = invlogit(xb45) if study == 2 & resp_prob2014 ==. & svy_core2014 == 1

mi passive: replace resp_w2014 = 1/resp_prob2014 if study == 2 & resp_w2014 ==. & svy_core2014 == 1 
sum resp_w2014 if svy_core2014 == 1 & study == 2
drop xb41 xb42 xb43 xb44 xb45

* For 2016 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk16a, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2004 svy_core2006 ///
			  svy_core2008 svy_core2010 svy_core2012 svy_core2014 mar_stat2004 ///
			  mar_stat2006 mar_stat2008 mar_stat2010 mar_stat2012 mar_stat2014 ///
			  child2004 child2006 child2008 child2010 child2012 child2014 ///
			  self_health2004 self_health2006 self_health2008 self_health2010 ///
			  self_health2012 self_health2014 mob_any2004 mob_any2006 mob_any2008 ///
			  mob_any2010 mob_any2012 mob_any2014 iadl_any2004 iadl_any2006 ///
			  iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 adl_any2004 ///
			  adl_any2006 adl_any2008 adl_any2010 adl_any2012 adl_any2014 ///
			  diab2004 diab2006 diab2008 diab2010 diab2012 diab2014 lung2004 ///
			  lung2006 lung2008 lung2010 lung2012 lung2014 heart2004 heart2006 ///
			  heart2008 heart2010 heart2012 heart2014 hibp2004 hibp2006 hibp2008 ///
			  hibp2010 hibp2012 hibp2014 i.cohort c.birthyear education2014 if study == 2 
mi predict xb51 using mi_ipw_est_uk16a if study == 2
mi passive: replace resp_prob2016 = invlogit(xb51) if study == 2 & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_uk16b, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2006 svy_core2008 svy_core2010 ///
			  svy_core2012 svy_core2014 mar_stat2006 mar_stat2008 mar_stat2010 ///
			  mar_stat2012 mar_stat2014 child2006 child2008 child2010 child2012 ///
			  child2014 self_health2006 self_health2008 self_health2010 self_health2012 ///
			  self_health2014 mob_any2006 mob_any2008 mob_any2010 mob_any2012 ///
			  mob_any2014 iadl_any2006 iadl_any2008 iadl_any2010 iadl_any2012 ///
			  iadl_any2014 adl_any2006 adl_any2008 adl_any2010 adl_any2012 ///
			  adl_any2014 diab2006 diab2008 diab2010 diab2012 diab2014 lung2006 ///
			  lung2008 lung2010 lung2012 lung2014 heart2006 heart2008 heart2010 ///
			  heart2012 heart2014 hibp2006 hibp2008 hibp2010 hibp2012 hibp2014 ///
			  i.cohort c.birthyear education2014 if study == 2
mi predict xb52 using mi_ipw_est_uk16b if study == 2
mi passive: replace resp_prob2016 = invlogit(xb52) if study == 2 & resp_prob2016 ==. & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_uk16c, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2008 svy_core2010 svy_core2012 ///
			  svy_core2014 mar_stat2008 mar_stat2010 mar_stat2012 mar_stat2014 ///
			  child2008 child2010 child2012 child2014 self_health2008 self_health2010 ///
			  self_health2012 self_health2014 mob_any2008 mob_any2010 mob_any2012 ///
			  mob_any2014 iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 ///
			  adl_any2008 adl_any2010 adl_any2012 adl_any2014 diab2008 diab2010 ///
			  diab2012 diab2014 lung2008 lung2010 lung2012 lung2014 heart2008 heart2010 ///
			  heart2012 heart2014 hibp2008 hibp2010 hibp2012 hibp2014 i.cohort ///
			  c.birthyear education2014 if study == 2
mi predict xb53 using mi_ipw_est_uk16c if study == 2
mi passive: replace resp_prob2016 = invlogit(xb53) if study == 2 & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_uk16d, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2010 svy_core2012 svy_core2014 ///
			  mar_stat2010 mar_stat2012 mar_stat2014 child2010 child2012 child2014 ///
			  self_health2010 self_health2012 self_health2014 mob_any2010 mob_any2012 ///
			  mob_any2014 iadl_any2010 iadl_any2012 iadl_any2014 adl_any2010 ///
			  adl_any2012 adl_any2014 diab2010 diab2012 diab2014 lung2010 lung2012 ///
			  lung2014 heart2010 heart2012 heart2014 hibp2010 hibp2012 hibp2014 ///
			  i.cohort c.birthyear education2014 if study == 2
mi predict xb54 using mi_ipw_est_uk16d if study == 2
mi passive: replace resp_prob2016 = invlogit(xb54) if study == 2 & resp_prob2016 ==. & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_uk16e, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2012 svy_core2014 ///
			  mar_stat2012 mar_stat2014 child2012 child2014 self_health2012 ///
			  self_health2014 mob_any2012 mob_any2014 iadl_any2012 iadl_any2014 ///
			  adl_any2012 adl_any2014 diab2012 diab2014 lung2012 lung2014 heart2012 ///
			  heart2014 hibp2012 hibp2014 i.cohort c.birthyear education2014 if study == 2
mi predict xb55 using mi_ipw_est_uk16e if study == 2
mi passive: replace resp_prob2016 = invlogit(xb55) if study == 2 & resp_prob2016 ==. & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_uk16f, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2014 mar_stat2014 ///
			  child2014 self_health2014 mob_any2014 iadl_any2014 adl_any2014 ///
			  diab2014 lung2014 heart2014 hibp2014 i.cohort c.birthyear ///
			  education2014 if study == 2
mi predict xb56 using mi_ipw_est_uk16f if study == 2
mi passive: replace resp_prob2016 = invlogit(xb56) if study == 2 & resp_prob2016 ==. & svy_core2016 == 1

mi passive: replace resp_w2016 = 1/resp_prob2016 if study == 2 & resp_w2016 ==. & svy_core2016 == 1 
sum resp_w2016 if svy_core2016 == 1 & study == 2
drop xb51 xb52 xb53 xb54 xb55 xb56 

* For 2018 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_uk18a, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2004 svy_core2006 ///
			  svy_core2008 svy_core2010 svy_core2012 svy_core2014 svy_core2016 ///
			  mar_stat2004 mar_stat2006 mar_stat2008 mar_stat2010 mar_stat2012 ///
			  mar_stat2014 mar_stat2016 child2004 child2006 child2008 child2010 ///
			  child2012 child2014 child2016 self_health2004 self_health2006 ///
			  self_health2008 self_health2010 self_health2012 self_health2014 ///
			  self_health2016 mob_any2004 mob_any2006 mob_any2008 mob_any2010 ///
			  mob_any2012 mob_any2014 mob_any2016 iadl_any2004 iadl_any2006 ///
			  iadl_any2008 iadl_any2010 iadl_any2012 iadl_any2014 iadl_any2016 ///
			  adl_any2004 adl_any2006 adl_any2008 adl_any2010 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2004 diab2006 diab2008 diab2010 ///
			  diab2012 diab2014 diab2016 lung2004 lung2006 lung2008 lung2010 ///
			  lung2012 lung2014 lung2016 heart2004 heart2006 heart2008 heart2010 ///
			  heart2012 heart2014 heart2016 hibp2004 hibp2006 hibp2008 hibp2010 ///
			  hibp2012 hibp2014 hibp2016 i.cohort c.birthyear education2016 if study == 2 
mi predict xb61 using mi_ipw_est_uk18a if study == 2
mi passive: replace resp_prob2018 = invlogit(xb61) if study == 2 & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_uk18b, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2006 svy_core2008 ///
			  svy_core2010 svy_core2012 svy_core2014 svy_core2016 mar_stat2006 ///
			  mar_stat2008 mar_stat2010 mar_stat2012 mar_stat2014 mar_stat2016 ///
			  child2006 child2008 child2010 child2012 child2014 child2016 ///
			  self_health2006 self_health2008 self_health2010 self_health2012 ///
			  self_health2014 self_health2016 mob_any2006 mob_any2008 mob_any2010 ///
			  mob_any2012 mob_any2014 mob_any2016 iadl_any2006 iadl_any2008 iadl_any2010 ///
			  iadl_any2012 iadl_any2014 iadl_any2016 adl_any2006 adl_any2008 adl_any2010 ///
			  adl_any2012 adl_any2014 adl_any2016 diab2006 diab2008 diab2010 diab2012 ///
			  diab2014 diab2016 lung2006 lung2008 lung2010 lung2012 lung2014 lung2016 ///
			  heart2006 heart2008 heart2010 heart2012 heart2014 heart2016 hibp2006 ///
			  hibp2008 hibp2010 hibp2012 hibp2014 hibp2016 i.cohort c.birthyear ///
			  education2016 if study == 2 
mi predict xb62 using mi_ipw_est_uk18b if study == 2
mi passive: replace resp_prob2018 = invlogit(xb62) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_uk18c, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2008 svy_core2010 ///
			  svy_core2012 svy_core2014 svy_core2016 mar_stat2008 mar_stat2010 ///
			  mar_stat2012 mar_stat2014 mar_stat2016 child2008 child2010 child2012 ///
			  child2014 child2016 self_health2008 self_health2010 self_health2012 ///
			  self_health2014 self_health2016 mob_any2008 mob_any2010 mob_any2012 ///
			  mob_any2014 mob_any2016 iadl_any2008 iadl_any2010 iadl_any2012 ///
			  iadl_any2014 iadl_any2016 adl_any2008 adl_any2010 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2008 diab2010 diab2012 diab2014 diab2016 ///
			  lung2008 lung2010 lung2012 lung2014 lung2016 heart2008 heart2010 ///
			  heart2012 heart2014 heart2016 hibp2008 hibp2010 hibp2012 hibp2014 ///
			  hibp2016 i.cohort c.birthyear education2016 if study == 2 
mi predict xb63 using mi_ipw_est_uk18c if study == 2
mi passive: replace resp_prob2018 = invlogit(xb63) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_uk18d, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2010 svy_core2012 ///
			  svy_core2014 svy_core2016 mar_stat2010 mar_stat2012 mar_stat2014 ///
			  mar_stat2016 child2010 child2012 child2014 child2016 self_health2010 ///
			  self_health2012 self_health2014 self_health2016 mob_any2010 mob_any2012 ///
			  mob_any2014 mob_any2016 iadl_any2010 iadl_any2012 iadl_any2014 ///
			  iadl_any2016 adl_any2010 adl_any2012 adl_any2014 adl_any2016 diab2010 ///
			  diab2012 diab2014 diab2016 lung2010 lung2012 lung2014 lung2016 ///
			  heart2010 heart2012 heart2014 heart2016 hibp2010 hibp2012 hibp2014 ///
			  hibp2016 i.cohort c.birthyear education2016 if study == 2 
mi predict xb64 using mi_ipw_est_uk18d if study == 2
mi passive: replace resp_prob2018 = invlogit(xb64) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_uk18e, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2012 svy_core2014 ///
			  svy_core2016 mar_stat2012 mar_stat2014 mar_stat2016 child2012 ///
			  child2014 child2016 self_health2012 self_health2014 self_health2016 ///
			  mob_any2012 mob_any2014 mob_any2016 iadl_any2012 iadl_any2014 ///
			  iadl_any2016 adl_any2012 adl_any2014 adl_any2016 diab2012 diab2014 ///
			  diab2016 lung2012 lung2014 lung2016 heart2012 heart2014 heart2016 ///
			  hibp2012 hibp2014 hibp2016 i.cohort c.birthyear education2016 if study == 2
mi predict xb65 using mi_ipw_est_uk18e if study == 2
mi passive: replace resp_prob2018 = invlogit(xb65) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_uk18f, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2014 svy_core2016 ///
			  mar_stat2014 mar_stat2016 child2014 child2016 self_health2014 ///
			  self_health2016 mob_any2014 mob_any2016 iadl_any2014 iadl_any2016 ///
			  adl_any2014 adl_any2016 diab2014 diab2016 lung2014 lung2016 heart2014 ///
			  heart2016 hibp2014 hibp2016 i.cohort c.birthyear education2016 if study == 2 
mi predict xb66 using mi_ipw_est_uk18f if study == 2
mi passive: replace resp_prob2018 = invlogit(xb66) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_uk18g, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2016 mar_stat2016 ///
			  child2016 self_health2016 mob_any2016 iadl_any2016 adl_any2016 ///
			  diab2016 lung2016 heart2016 hibp2016 i.cohort c.birthyear ///
			  education2016 if study == 2
mi predict xb67 using mi_ipw_est_uk18g if study == 2
mi passive: replace resp_prob2018 = invlogit(xb67) if study == 2 & resp_prob2018 ==. & svy_core2018 == 1 

mi passive: replace resp_w2018 = 1/resp_prob2018 if study == 2 & resp_w2018 ==. & svy_core2018 == 1
sum resp_w2018 if svy_core2018 == 1 & study == 2 
drop xb61 xb62 xb63 xb64 xb65 xb66 xb67 

************* SURVEY OF HEALTH, AGEING AND RETIREMENT IN EUROPE ****************

* For 2006 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_eu06, replace) dots: ///
		logit svy_core2006 i.gender c.age2004 svy_core2004 mar_stat2004 ///
			  child2004 self_health2004 mob_any2004 iadl_any2004 adl_any2004 ///
			  diab2004 lung2004 heart2004 hibp2004 i.cohort c.birthyear ///
			  education2004 i.country if study == 3
mi predict xb using mi_ipw_est_eu06 if study == 3
mi passive: replace resp_prob2006 = invlogit(xb) if study == 3 & svy_core2006 == 1 
mi passive: replace resp_w2006 = 1/resp_prob2006 if study == 3 & resp_w2006 ==. & svy_core2006 == 1 
sum resp_w2006 if svy_core2006 == 1 & study == 3
drop xb 

* For 2010 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_eu10a, replace) dots: ///
		logit svy_core2010 i.gender c.age2006 svy_core2004 svy_core2006 ///
			  mar_stat2004 mar_stat2006 child2004 child2006 self_health2004 ///
			  self_health2006 mob_any2004 mob_any2006 iadl_any2004 iadl_any2006 ///
			  adl_any2004 adl_any2006 diab2004 diab2006 lung2004 lung2006 heart2004 ///
			  heart2006 hibp2004 hibp2006 i.cohort c.birthyear education2006 ///
			  i.country if study == 3
mi predict xb21 using mi_ipw_est_eu10a if study == 3
mi passive: replace resp_prob2010 = invlogit(xb21) if study == 3 & svy_core2010 == 1

mi estimate, saving(mi_ipw_est_eu10b, replace) dots: ///
			logit svy_core2010 i.gender c.age2006 svy_core2006 mar_stat2006 ///
				  child2006 self_health2006 mob_any2006 iadl_any2006 adl_any2006 ///
				  diab2006 lung2006 heart2006 hibp2006 i.cohort c.birthyear ///
				  education2006 i.country if study == 3
mi predict xb22 using mi_ipw_est_eu10b if study == 3
mi passive: replace resp_prob2010 = invlogit(xb22) if study == 3 & resp_prob2010 ==. & svy_core2010 == 1

mi passive: replace resp_w2010 = 1/resp_prob2010 if study == 3 & resp_w2010 ==. & svy_core2010 == 1 
sum resp_w2010 if svy_core2010 == 1 & study == 3
drop xb21 xb22 

* For 2012 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_eu12a, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2004 svy_core2006 ///
			  svy_core2010 mar_stat2004 mar_stat2006 mar_stat2010 child2004 ///
			  child2006 child2010 self_health2004 self_health2006 self_health2010 ///
			  mob_any2004 mob_any2006 mob_any2010 iadl_any2004 iadl_any2006 ///
			  iadl_any2010 adl_any2004 adl_any2006 adl_any2010 diab2004 diab2006 ///
			  diab2010 lung2004 lung2006 lung2010 heart2004 heart2006 heart2010 ///
			  hibp2004 hibp2006 hibp2010 i.cohort c.birthyear education2010 ///
			  i.country if study == 3
mi predict xb31 using mi_ipw_est_eu12a if study == 3
mi passive: replace resp_prob2012 = invlogit(xb31) if study == 3 & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_eu12b, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2006 svy_core2010 ///
			  mar_stat2006 mar_stat2010 child2006 child2010 self_health2006 ///
			  self_health2010 mob_any2006 mob_any2010 iadl_any2006 iadl_any2010 ///
			  adl_any2006 adl_any2010 diab2006 diab2010 lung2006 lung2010 ///
			  heart2006 heart2010 hibp2006 hibp2010 i.country i.cohort ///
			  c.birthyear education2010 if study == 3
mi predict xb32 using mi_ipw_est_eu12b if study == 3
mi passive: replace resp_prob2012 = invlogit(xb32) if study == 3 & resp_prob2012 ==. & svy_core2012 == 1 

mi estimate, saving(mi_ipw_est_eu12d, replace) dots: ///
		logit svy_core2012 i.gender c.age2010 svy_core2010 mar_stat2010 ///
		child2010 self_health2010 mob_any2010 iadl_any2010 adl_any2010 diab2010 ///
		lung2010 heart2010 hibp2010 i.cohort c.birthyear education2010 ///
		i.country if study == 3
mi predict xb34 using mi_ipw_est_eu12d if study == 3
mi passive: replace resp_prob2012 = invlogit(xb34) if study == 3 & resp_prob2012 ==. & svy_core2012 == 1 

mi passive: replace resp_w2012 = 1/resp_prob2012 if study == 3 & resp_w2012 ==. & svy_core2012 == 1
sum resp_w2012 if svy_core2012 == 1 & study == 3

drop xb31 xb32 xb34 

* For 2014
mi estimate, saving(mi_ipw_est_eu14a, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2004 svy_core2006 ///
			  svy_core2010 svy_core2012 mar_stat2004 mar_stat2006 mar_stat2010 ///
			  mar_stat2012 child2004 child2006 child2010 child2012 self_health2004 ///
			  self_health2006 self_health2010 self_health2012 mob_any2004 ///
			  mob_any2006 mob_any2010 mob_any2012 iadl_any2004 iadl_any2006 ///
			  iadl_any2010 iadl_any2012 adl_any2004 adl_any2006 adl_any2010 ///
			  adl_any2012 diab2004 diab2006 diab2010 diab2012 lung2004 lung2006 ///
			  lung2010 lung2012 heart2004 heart2006 heart2010 heart2012 hibp2004 ///
			  hibp2006 hibp2010 hibp2012 i.cohort c.birthyear education2012 ///
			  i.country if study == 3
mi predict xb41 using mi_ipw_est_eu14a if study == 3
mi passive: replace resp_prob2014 = invlogit(xb41) if study == 3 & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_eu14b, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2006 svy_core2010 ///
			  svy_core2012 mar_stat2006 mar_stat2010 mar_stat2012 child2006 ///
			  child2010 child2012 self_health2006 self_health2010 self_health2012 ///
			  mob_any2006 mob_any2010 mob_any2012 iadl_any2006 iadl_any2010 ///
			  iadl_any2012 adl_any2006 adl_any2010 adl_any2012 diab2006 diab2010 ///
			  diab2012 lung2006 lung2010 lung2012 heart2006 heart2010 heart2012 ///
			  hibp2006 hibp2010 hibp2012 i.cohort c.birthyear education2012 ///
			  i.country if study == 3
mi predict xb42 using mi_ipw_est_eu14b if study == 3
mi passive: replace resp_prob2014 = invlogit(xb42) if study == 3 & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_eu14d, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2010 svy_core2012 ///
			  mar_stat2010 mar_stat2012 child2010 child2012 self_health2010 ///
			  self_health2012 mob_any2010 mob_any2012 iadl_any2010 iadl_any2012 ///
			  adl_any2010 adl_any2012 diab2010 diab2012 lung2010 lung2012 heart2010 ///
			  heart2012 hibp2010 hibp2012 i.cohort c.birthyear education2012 ///
			  i.country if study == 3
mi predict xb44 using mi_ipw_est_eu14d if study == 3
mi passive: replace resp_prob2014 = invlogit(xb44) if study == 3 & resp_prob2014 ==. & svy_core2014 == 1 

mi estimate, saving(mi_ipw_est_eu14e, replace) dots: ///
		logit svy_core2014 i.gender c.age2012 svy_core2012 mar_stat2012 child2012 ///
			  self_health2012 mob_any2012 iadl_any2012 adl_any2012 diab2012 ///
			  lung2012 heart2012 hibp2012 i.cohort c.birthyear education2012 ///
			  i.country if study == 3
mi predict xb45 using mi_ipw_est_eu14e if study == 3
mi passive: replace resp_prob2014 = invlogit(xb45) if study == 3 & resp_prob2014 ==. & svy_core2014 == 1 

mi passive: replace resp_w2014 = 1/resp_prob2014 if study == 3 & resp_w2014 ==. & svy_core2014 == 1
sum resp_w2014 if svy_core2014 == 1 & study == 3
drop xb41 xb42 xb44 xb45

* For 2016 ---------------------------------------------------------------------
mi estimate, saving(mi_ipw_est_eu16a, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2004 svy_core2006 ///
			  svy_core2010 svy_core2012 svy_core2014 mar_stat2004 mar_stat2006 ///
			  mar_stat2010 mar_stat2012 mar_stat2014 child2004 child2006 child2010 ///
			  child2012 child2014 self_health2004 self_health2006 self_health2010 ///
			  self_health2012 self_health2014 mob_any2004 mob_any2006 mob_any2010 ///
			  mob_any2012 mob_any2014 iadl_any2004 iadl_any2006 iadl_any2010 ///
			  iadl_any2012 iadl_any2014 adl_any2004 adl_any2006 adl_any2010 ///
			  adl_any2012 adl_any2014 diab2004 diab2006 diab2010 diab2012 ///
			  diab2014 lung2004 lung2006 lung2010 lung2012 lung2014 heart2004 ///
			  heart2006 heart2010 heart2012 heart2014 hibp2004 hibp2006 hibp2010 ///
			  hibp2012 hibp2014 i.cohort c.birthyear education2014 ///
			  i.country if study == 3
mi predict xb51 using mi_ipw_est_eu16a if study == 3
mi passive: replace resp_prob2016 = invlogit(xb51) if study == 3 & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_eu16b, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2006 svy_core2010 ///
			  svy_core2012 svy_core2014 mar_stat2006 mar_stat2010 mar_stat2012 ///
			  mar_stat2014 child2006 child2010 child2012 child2014 self_health2006 ///
			  self_health2010 self_health2012 self_health2014 mob_any2006 ///
			  mob_any2010 mob_any2012 mob_any2014 iadl_any2006  iadl_any2010 ///
			  iadl_any2012 iadl_any2014 adl_any2006 adl_any2010 adl_any2012 ///
			  adl_any2014 diab2006 diab2010 diab2012 diab2014 lung2006 lung2010 ///
			  lung2012 lung2014 heart2006 heart2010 heart2012 heart2014 hibp2006 ///
			  hibp2010 hibp2012 hibp2014 i.country i.cohort c.birthyear ///
			  education2014 if study == 3
mi predict xb52 using mi_ipw_est_eu16b if study == 3
mi passive: replace resp_prob2016 = invlogit(xb52) if study == 3 & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_eu16d, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2010 svy_core2012 ///
			  svy_core2014 mar_stat2010 mar_stat2012 mar_stat2014 child2010 ///
			  child2012 child2014 self_health2010 self_health2012 self_health2014 ///
			  mob_any2010 mob_any2012 mob_any2014 iadl_any2010 iadl_any2012 ///
			  iadl_any2014 adl_any2010 adl_any2012 adl_any2014 diab2010 diab2012 ///
			  diab2014 lung2010 lung2012 lung2014 heart2010 heart2012 heart2014 ///
			  hibp2010 hibp2012 hibp2014 i.cohort c.birthyear education2014 ///
			  i.country if study == 3
mi predict xb54 using mi_ipw_est_eu16d if study == 3
mi passive: replace resp_prob2016 = invlogit(xb54) if study == 3 & resp_prob2016 ==. & svy_core2016 == 1

mi estimate, saving(mi_ipw_est_eu16e, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2012 svy_core2014 ///
			  mar_stat2012 mar_stat2014 child2012 child2014 self_health2012 ///
			  self_health2014 mob_any2012 mob_any2014 iadl_any2012 iadl_any2014 ///
			  adl_any2012 adl_any2014 diab2012 diab2014 lung2012 lung2014 heart2012 ///
			  heart2014 hibp2012 hibp2014 i.cohort c.birthyear education2014 ///
			  i.country if study == 3
mi predict xb55 using mi_ipw_est_eu16e if study == 3
mi passive: replace resp_prob2016 = invlogit(xb55) if study == 3 & resp_prob2016 ==. & svy_core2016 == 1 

mi estimate, saving(mi_ipw_est_eu16f, replace) dots: ///
		logit svy_core2016 i.gender c.age2014 svy_core2014 mar_stat2014 child2014 ///
			  self_health2014 mob_any2014 iadl_any2014 adl_any2014 diab2014 ///
			  lung2014 heart2014 hibp2014 i.cohort c.birthyear education2014 ///
			  i.country if study == 3
mi predict xb56 using mi_ipw_est_eu16f if study == 3
mi passive: replace resp_prob2016 = invlogit(xb56) if study == 3 & resp_prob2016 ==. & svy_core2016 == 1 

mi passive: replace resp_w2016 = 1/resp_prob2016 if study == 3 & resp_w2016 ==. & svy_core2016 == 1 
sum resp_w2016 if svy_core2016 == 1 & study == 3
drop xb51 xb52 xb54 xb55 xb56 

* For 2018 ---------------------------------------------------------------------

mi estimate, saving(mi_ipw_est_eu18a, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2004 svy_core2006 ///
			  svy_core2010 svy_core2012 svy_core2014 svy_core2016 mar_stat2004 ///
			  mar_stat2006 mar_stat2010 mar_stat2012 mar_stat2014 mar_stat2016 ///
			  child2004 child2006 child2010 child2012 child2014 child2016 ///
			  self_health2004 self_health2006 self_health2010 self_health2012 ///
			  self_health2014 self_health2016 mob_any2004 mob_any2006 mob_any2010 ///
			  mob_any2012 mob_any2014 mob_any2016 iadl_any2004 iadl_any2006 ///
			  iadl_any2010 iadl_any2012 iadl_any2014 iadl_any2016 adl_any2004 ///
			  adl_any2006 adl_any2010 adl_any2012 adl_any2014 adl_any2016 diab2004 ///
			  diab2006 diab2010 diab2012 diab2014 diab2016 lung2004 lung2006 lung2010 ///
			  lung2012 lung2014 lung2016 heart2004 heart2006 heart2010 heart2012 ///
			  heart2014 heart2016 hibp2004 hibp2006 hibp2010 hibp2012 hibp2014 hibp2016 ///
			  i.cohort c.birthyear education2016 i.country if study == 3
mi predict xb61 using mi_ipw_est_eu18a if study == 3
mi passive: replace resp_prob2018 = invlogit(xb61) if study == 3 & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_eu18b, replace) dots: /// 
		logit svy_core2018 i.gender c.age2016 svy_core2006 svy_core2010 svy_core2012 ///
			  svy_core2014 svy_core2016 mar_stat2006 mar_stat2010 mar_stat2012 ///
			  mar_stat2014 mar_stat2016 child2006 child2010 child2012 child2014 ///
			  child2016 self_health2006 self_health2010 self_health2012 self_health2014 ///
			  self_health2016 mob_any2006 mob_any2010 mob_any2012 mob_any2014 mob_any2016 ///
			  iadl_any2006 iadl_any2010 iadl_any2012 iadl_any2014 iadl_any2016 ///
			  adl_any2006 adl_any2010 adl_any2012 adl_any2014 adl_any2016 diab2006 ///
			  diab2010 diab2012 diab2014 diab2016 lung2006 lung2010 lung2012 lung2014 ///
			  lung2016 heart2006 heart2010 heart2012 heart2014 heart2016 hibp2006 hibp2010 ///
			  hibp2012 hibp2014 hibp2016 i.cohort c.birthyear education2016 ///
			  i.country if study == 3
mi predict xb62 using mi_ipw_est_eu18b if study == 3
mi passive: replace resp_prob2018 = invlogit(xb62) if study == 3 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_eu18d, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2010 svy_core2012 svy_core2014 ///
			  svy_core2016 mar_stat2010 mar_stat2012 mar_stat2014 mar_stat2016 child2010 ///
			  child2012 child2014 child2016 self_health2010 self_health2012 self_health2014 ///
			  self_health2016 mob_any2010 mob_any2012 mob_any2014 mob_any2016 iadl_any2010 ///
			  iadl_any2012 iadl_any2014 iadl_any2016 adl_any2010 adl_any2012 adl_any2014 ///
			  adl_any2016 diab2010 diab2012 diab2014 diab2016 lung2010 lung2012 lung2014 ///
			  lung2016 heart2010 heart2012 heart2014 heart2016 hibp2010 hibp2012 hibp2014 ///
			  hibp2016 i.cohort c.birthyear education2016 i.country if study == 3
mi predict xb64 using mi_ipw_est_eu18d if study == 3
mi passive: replace resp_prob2018 = invlogit(xb64) if study == 3 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_eu18e, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2012 svy_core2014 ///
			  svy_core2016 mar_stat2012 mar_stat2014 mar_stat2016 child2012 child2014 ///
			  child2016 self_health2012 self_health2014 self_health2016 mob_any2012 ///
			  mob_any2014 mob_any2016 iadl_any2012 iadl_any2014 iadl_any2016 adl_any2012 ///
			  adl_any2014 adl_any2016 diab2012 diab2014 diab2016 lung2012 lung2014 ///
			  lung2016 heart2012 heart2014 heart2016 hibp2012 hibp2014 hibp2016 i.cohort ///
			  c.birthyear education2016 i.country if study == 3
mi predict xb65 using mi_ipw_est_eu18e if study == 3
mi passive: replace resp_prob2018 = invlogit(xb65) if study == 3 & resp_prob2018 ==. & svy_core2018 == 1 

mi estimate, saving(mi_ipw_est_eu18f, replace) dots: /// 
		logit svy_core2018 i.gender c.age2016 svy_core2014 svy_core2016 ///
			  mar_stat2014 mar_stat2016 child2014 child2016 self_health2014 ///
			  self_health2016 mob_any2014 mob_any2016 iadl_any2014 iadl_any2016 ///
			  adl_any2014 adl_any2016 diab2014 diab2016 lung2014 lung2016 heart2014 ///
			  heart2016 hibp2014 hibp2016 i.cohort c.birthyear education2016 ///
			  i.country if study == 3
mi predict xb66 using mi_ipw_est_eu18f if study == 3
mi passive: replace resp_prob2018 = invlogit(xb66) if study == 3 & resp_prob2018 ==. & svy_core2018 == 1

mi estimate, saving(mi_ipw_est_eu18g, replace) dots: ///
		logit svy_core2018 i.gender c.age2016 svy_core2016 mar_stat2016 ///
			  child2016 self_health2016 mob_any2016 iadl_any2016 adl_any2016 ///
			  diab2016 lung2016 heart2016 hibp2016 i.cohort c.birthyear ///
			  education2016 i.country if study == 3
mi predict xb67 using mi_ipw_est_eu18g if study == 3
mi passive: replace resp_prob2018 = invlogit(xb67) if study == 3 & resp_prob2018 ==. & svy_core2018 == 1 

mi passive: replace resp_w2018 = 1/resp_prob2018 if study == 3 & resp_w2018 ==. & svy_core2018 == 1
sum resp_w2018 if svy_core2018 == 1 & study == 3
drop xb61 xb62 xb64 xb65 xb66 xb67 

save "ipw.dta", replace // update file path 

*===============================================================================
* Reshape all the data back to long form 
*===============================================================================

use "ipw.dta", clear

* The age squared variables cause issues so just regenerate these later 
drop age22004 age22006 age22008 age22010 age22012 age22014 age22016 age22018 

* reshape the data into long form
mi reshape long svy_n svy_core age comb_wtcore comb_wtn mar_stat child ///
		   self_health mob_any iadl_any adl_any diab cancer lung heart ///
		   hibp countrycohort education resp_prob resp_w, i(id) j(year)
 
* Get back to same long format data that we had originally
drop if age < 50 
drop if study == 3 & year == 2008 // no SHARE 2008 survey
drop if age ==. 
count if _mi_m == 0 // check how many observations we have

* Replace weights for those who don't have a weight 
* because it was their first time participating 
* (want it so we get original weight when multiplied with study weights)
mi passive: replace resp_w = 1 if svy_core == 1 & year == 2004 // replace for 2004 
mi passive: by id (year): gen fistresp = sum(svy_core) if svy_core == 1 // generating a marker for first response 
mi passive: replace resp_w = 1 if fistresp == 1 

* Weights should be 0 for those who didn't participate in the suvey, and those who had a zero/non-assigned cross-sectional weight
mi passive: replace resp_w = 0 if svy_core == 0 // if not in the study, weight should be zero 
mi passive: replace resp_w = 0 if comb_wtcore == 0 | comb_wtcore ==. // if weight is zero or missing, weight should be zero 

save "ipw_long.dta", replace 

*===============================================================================
* Checking 
*===============================================================================
use "ipw_long.dta", clear 

preserve 
keep if _mi_m == 0 
codebook resp_w 
restore 

/*
No missing weights, lots of zeros because these correspond to weights assigned to 
those who did not participate.  
*/

* Check distribution of weights 
hist resp_w if _mi_m == 0 & resp_w != 0 & resp_w != 1 
sum resp_w if resp_w != 0 & resp_w != 1, detail 
centile resp_w if _mi_m == 0 & resp_w !=0 & resp_w !=1, centile(99.5)

mi extract 0, clear  

gen resp_w99th = resp_w // truncate at 99th percentile
replace resp_w99th = 8.04 if resp_w99th > 8.04 // 1559 changes made 

gen resp_w50 = resp_w // truncate at 50
replace resp_w50 = 50 if resp_w50 > 50 // 24 changes made 

gen resp_w30 = resp_w // truncate at 30
replace resp_w30 = 30 if resp_w30 > 30 // 87 changes made 

gen resp_w20 = resp_w // truncate at 20 
replace resp_w20 = 20 if resp_w20 > 20 // 202 changes made 

gen tot_wtcore99 = comb_wtcore * resp_w99th 
gen tot_wtn99 = comb_wtn * resp_w99th 

gen tot_wtcore50 = comb_wtcore * resp_w50 
gen tot_wtn50 = comb_wtn * resp_w50

gen tot_wtcore30 = comb_wtcore * resp_w30 
gen tot_wtn30 = comb_wtcore * resp_w30 

gen tot_wtcore20 = comb_wtcore * resp_w20
gen tot_wtn20 = comb_wtn * resp_w20 

keep resp_w* tot_wtcore* tot_wtn* id year
save "weights_combined.dta", replace // ammend file path


