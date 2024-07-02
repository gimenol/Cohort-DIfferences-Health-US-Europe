/*==============================================================================
RESHAPE WIDE

Here, I reshape the long-form data back to wide, mostly to check that the 
number of observations is still correct, and to be able to get descriptive 
statistics at the cohort member level, rather than the observation level.

Author: Laura Gimeno 

NOTE: Make sure to ammend file paths.
==============================================================================*/ 

use "long_form.dta", clear

reshape wide age agegrp mar_stat child ///
			 comb_psu1 comb_strat1 ///
			 svy_n svy_core ///
			 comb_wtcore comb_wtn ///
			 rank_nurse rank_core ///
			 adl_any iadl_any mob_any ///
			 sev_adl sev_iadl sev_mob ///
			 adl_miss iadl_miss mob_miss ///
			 adl_score iadl_score mob_score ///
			 limitation mild_disability mod_disability sev_disability ///
			 self_health ///
			 cancer diab heart lung chol hibp ///
			 bmi_sr bmi_msred obese_sr obese_msred ///
			 numsmok ///
			 sys_bp sys_treat dia_bp dia_treat ///
			 hibpm hibptreat meds_hibp ///
			 grip height weight ///
			 meds_diab meds_chol elsa_bldwt hba1c bldchol, i(id) j(year)
			 
count // 114,526 so we still have the right number of people			 
			 
save "wide_form.dta", replace
