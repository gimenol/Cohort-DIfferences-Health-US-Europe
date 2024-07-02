/* =============================================================================
CHECK TRUNCATION FOR INVERSE PROBABILITY WEIGHTS 

Author: Laura Gimeno
==============================================================================*/

use "long_form_ipws.dta", clear 

* With truncation at 99.5th percentile
svyset comb_psu1 [pw = tot_wtn99], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country ==2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* With truncation at 50 
svyset comb_psu1 [pw = tot_wtn50], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country == 2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* With truncation at 30 
svyset comb_psu1 [pw = tot_wtn30], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country == 2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* With truncation at 20 
svyset comb_psu1 [pw = tot_wtn20], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country == 2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* With no truncation 
svyset comb_psu1 [pw = tot_wtn], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country == 2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* With normal weights 
svyset comb_psu1 [pw = comb_wtn], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc1) || pnum 
svy, subpop(if svy_n == 1 & country == 2) eform: glm obese_msred ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)


* Checking descriptives

* Weighted proportions of women, uni educated, diabetes, and obese people across three time sweeps 

preserve 
keep if year == 2016
svyset comb_psu1 [pw = comb_wtcore], strata(comb_strat1) vce(robust) singleunit(centered) 
svy: prop gender if svy_core == 1 , over(study) 
restore 


gen agegrp2 = age 
recode agegrp2 min/64 = 1 65/max = 2 
label define agegrplab 1 "<65" 2 "65+"

preserve 
keep if year == 2004
svyset comb_psu1 [pw = tot_wtcore], strata(comb_strat1) vce(robust) singleunit(centered) 
svy: prop cohort if svy_core == 1 , over(study) 
restore 



