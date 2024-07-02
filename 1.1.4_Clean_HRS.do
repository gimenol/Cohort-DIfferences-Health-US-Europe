/*==============================================================================
CLEANING HRS DATASET

In this script, I clean the dataset that I have built from HRS. I generate some 
new variables related to study, country, cohort etc. I also rename and relabel 
variables in a more consistent manner. This involves substituting out the wave 
number in variable names for the year in which the survey took place. This will 
allow me to merge variables from the different studies together in a way that 
makes sense. 

An important part of this script is dealing with the weights, sampling units and 
strata. Because this dataset will be used along SHARE and ELSA, it is important 
to have well-aligned variables containing the correct information. For this reason, 
I generate secondary strata and a secondary stratum, and an FPC = 1 so that I can 
use the same svy set command for all countries. I also build two sets of weights: 
one for outcomes featuring in the core questionnaire, and another for when looking 
at outcomes used during physical assessment.  

Author: Laura Gimeno
==============================================================================*/ 

* Ammend file path here 
use "hrs_merged.dta", clear

rename hhidpn ID 

gen COUNTRY = 1 
lab define countrylab 1 "USA" 2 "England" 3 "Austria" 4 "Germany" 5 "Sweden" ///
					  6 "Netherlands" 7 "Spain" 8 "Italy" 9 "France" 10 "Denmark" ///
					  11 "Greece" 12 "Switzerland" 13 "Belgium"
lab values COUNTRY countrylab 

gen COUNTRYGRP = 1 
lab define countrygrplab 1 "USA" 2 "England" 3 "Western Europe" 4 "Northern Europe" 5 "Southern Europe"
lab val COUNTRYGRP countrygrplab
lab var COUNTRYGRP "Geographic area" 

gen COHORT =.
recode rabyear .m =. 
replace COHORT = 1 if rabyear < 1925
replace COHORT = 2 if rabyear >= 1925 & rabyear < 1936 & rabyear !=.
replace COHORT = 3 if rabyear >= 1936 & rabyear < 1946 & rabyear !=.
replace COHORT = 4 if rabyear >= 1946 & rabyear < 1955 & rabyear !=.
replace COHORT = 5 if rabyear >= 1955 & rabyear < 1960 & rabyear !=.
replace COHORT = 6 if rabyear >= 1960 & rabyear !=.

label define cohortlab 1 "<1925 Greatest Generation" 2 "1925-35 Early Silent Generation" 3 "1936-1945 - Late Silent Generation" 4 "1946-1954 Early Baby Boomers" 5 "1955-1959 Late Baby Boomers" 6 ">1960" 
label values COHORT cohortlab
label variable COHORT "Birth cohort"

gen STUDY = 1 
label define studylab 1 "HRS" 2 "ELSA" 3 "SHARE"
label val STUDY studylab 
label var STUDY "Study"

rename rabyear BIRTHYEAR 

rename ragender GENDER
recode GENDER 1=0 2=1 
label define genlab 0 "Man" 1 "Woman"
label values GENDER genlab
label variable GENDER "Gender"

rename raeducl EDUCATION
recode EDUCATION .m =.
recode EDUCATION 1/2=0 3=1 
label define edulab 0 "No degree" 1 "Degree"
label val EDUCATION edulab

* Whether in physical measures module 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
drop r*pmbmi
foreach x of varlist inw*pm {
	gettoken sffx years: years 
	rename `x' SVY_N_`sffx'
	recode SVY_N_`sffx' .=0
	tab SVY_N_`sffx', m 
	label var SVY_N_`sffx' "Whether complete nurse component"
}

* Whether respondent for core questionnaire
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist inw* {
	gettoken sffx years: years 
	rename `x' SVY_CORE_`sffx'
	recode SVY_CORE_`sffx' .=0
	tab SVY_CORE_`sffx', m 
	label var SVY_CORE_`sffx' "Whether completed core survey in year X"
} 

* Age at interview
drop respagey*
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*agey_m {
	gettoken sffx years: years 
	rename `x' AGE_`sffx'
	label var AGE_`sffx' "Age (years) at interview"
	recode AGE_`sffx' .m=. 
} 

foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace AGE_`y' = `y' - BIRTHYEAR if BIRTHYEAR !=. & AGE_`y' ==.
}

* Age group
lab define agelab 1 "50-54" 2 "55-59" 3 "60-64" 4 "64-69" 5 "70-74" 6 "75-79" 7 "80-84" 8 "85+"

foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 { 
	gen AGEGRP_`y' = 0 
	replace AGEGRP_`y' = 1 if AGE_`y' < 55
	replace AGEGRP_`y' = 2 if AGE_`y' >= 55 & AGE_`y' < 60  
	replace AGEGRP_`y' = 3 if AGE_`y' >= 60 & AGE_`y' < 65
	replace AGEGRP_`y' = 4 if AGE_`y' >= 65 & AGE_`y' < 70
	replace AGEGRP_`y' = 5 if AGE_`y' >= 70 & AGE_`y' < 75
	replace AGEGRP_`y' = 6 if AGE_`y' >= 75 & AGE_`y' < 80
	replace AGEGRP_`y' = 7 if AGE_`y' >= 80 & AGE_`y' < 85
	replace AGEGRP_`y' = 8 if AGE_`y' >= 85 
	lab val AGEGRP_`y' agelab 
}

* Clean and set response as zero if age < 50 
foreach x in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace SVY_CORE_`x' = 0 if AGE_`x' < 50  
}
foreach x in 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace SVY_N_`x' = 0 if AGE_`x' < 50
} 

* Marital status 
drop remstat 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define marlab 1 "Currently married or partnered" 0 "Separated/divorced/widowed/never married/not partnered"
foreach x of varlist r*mstat {
	gettoken sffx years: years 
	rename `x' MAR_STAT_`sffx'
	recode MAR_STAT_`sffx' 1/3=1 4/8=0 .m=. .d=. .r=. .j=.
	label val MAR_STAT_`sffx' marlab 
	label var MAR_STAT_`sffx' "Marital status (with partnership)"
	tab MAR_STAT_`sffx', m
}

* Child (this needs to be analysed using the household weight I think?)
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
lab define childlab 0 "No children" 1 "Has children"
foreach x of varlist h*child {
	gettoken sffx years: years 
	rename `x' CHILD_`sffx'
	recode CHILD_`sffx' .m=. 1/max=1
	label val CHILD_`sffx' childlab
	label var CHILD_`sffx' "Number of children"
	tab CHILD_`sffx', m 
}

* Self-rated health 
drop r*shltc
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define healthlab 0 "Excellent/V Good/Good" 1 "Fair/Poor"
foreach x of varlist r*shlt {
	gettoken sffx years: years 
	rename `x' SELF_HEALTH_`sffx'
	recode SELF_HEALTH_`sffx' 1/3=0 4/5=1 .d =. .m=. .r=.
	label val SELF_HEALTH_`sffx' healthlab
	label var SELF_HEALTH_`sffx' "Poor/fair self-rated health"
	tab SELF_HEALTH_`sffx', m 
} 

* Ever high BP 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*hibpe {
	gettoken sffx years: years 
	rename `x' HIBP_`sffx'
	label var HIBP_`sffx' "Ever diagnosed with high BP"
	tab HIBP_`sffx', m 
} 

* Ever diabetes 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*diabe {
	gettoken sffx years: years 
	rename `x' DIAB_`sffx'
	label var DIAB_`sffx' "Ever diagnosed with diabetes"
	tab DIAB_`sffx', m 
} 

rename radiagdiab AGE_FIRST_DIAB 

* Ever cancer 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*cancre {
	gettoken sffx years: years 
	rename `x' CANCER_`sffx'
	label var CANCER_`sffx' "Ever diagnosed with cancer"
	tab CANCER_`sffx', m 
} 

* Ever lung disease 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*lunge {
	gettoken sffx years: years 
	rename `x' LUNG_`sffx'
	label var LUNG_`sffx' "Ever diagnosed with lung disease"
	tab LUNG_`sffx', m 
} 

* Ever heart problems  
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*hearte {
	gettoken sffx years: years 
	rename `x' HEART_`sffx'
	label var HEART_`sffx' "Ever diagnosed with heart problems"
	tab HEART_`sffx', m 
} 

* Ever high cholesterol 
local years "2014 2016 2018"
foreach x of varlist r*hchole {
	gettoken sffx years: years 
	rename `x' CHOL_`sffx'
	recode CHILD_`sffx' .d=. .r=. .m=.
	label var CHOL_`sffx' "Ever diagnosed with high cholesterol"
	tab CHOL_`sffx', m 
} 

* ADL score
drop r*iadltot_h
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltot_h {
	gettoken sffx years: years 
	rename `x' ADL_SCORE_`sffx'
	recode ADL_SCORE_`sffx' .x =. .s=. .r=. .m=. .d=. 
	label var ADL_SCORE_`sffx' "ADL score (0-6)"
	tab ADL_SCORE_`sffx', m 
} 

* ADL missings  
drop r*iadltotm_h
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltotm_h {
	gettoken sffx years: years 
	rename `x' ADL_MISS_`sffx'
	label var ADL_MISS_`sffx' "Number missing items ADL score"
	tab ADL_MISS_`sffx', m 
} 

* Any difficulty with ADLs 
drop r*iadltota_h
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltota_h {
	gettoken sffx years: years 
	rename `x' ADL_ANY_`sffx'
	recode ADL_ANY_`sffx' .d=. .m=. .r=. .s=. .x=. 
	label var ADL_ANY_`sffx' "If any difficulty with ADL"
	tab ADL_ANY_`sffx', m 
} 

* IADL score
local years "1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfour {
	gettoken sffx years: years 
	rename `x' IADL_SCORE_`sffx'
	recode IADL_SCORE_`sffx' .q=. .x=. .z=. .d=. .r=. .s=. .m=. 
	label var IADL_SCORE_`sffx' "IADL score (0-4)"
	tab IADL_SCORE_`sffx', m 
} 

* IADL missings  
local years "1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfourm {
	gettoken sffx years: years 
	rename `x' IADL_MISS_`sffx'
	label var IADL_MISS_`sffx' "Number missing items IADL score"
	tab IADL_MISS_`sffx', m
} 

* Any difficulty with IADLs 
local years "1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfoura {
	gettoken sffx years: years 
	rename `x' IADL_ANY_`sffx'
	recode IADL_ANY_`sffx' .d=. .r=. .s=. .x=. .z =. .m=. 
	label var IADL_ANY_`sffx' "If any difficulty with IADL"
	tab IADL_ANY_`sffx', m 
} 

* Mobility score 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsev {
	gettoken sffx years: years 
	rename `x' MOB_SCORE_`sffx'
	recode MOB_SCORE_`sffx' .r=. .s=. .x=. .d=. .m=. .q=. 
	label var MOB_SCORE_`sffx' "Mobility score (0-7)"
	tab MOB_SCORE_`sffx', m 
} 

* Mobility missings  
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsevm {
	gettoken sffx years: years 
	rename `x' MOB_MISS_`sffx'
	recode MOB_SCORE_`sffx' .d=. .m=. .r=. .s=. .q=. .x=. 
	label var MOB_MISS_`sffx' "Number missing items mobility score"
	tab MOB_MISS_`sffx', m 
} 

* Any difficulty with mobility 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilseva {
	gettoken sffx years: years 
	rename `x' MOB_ANY_`sffx'
	recode MOB_ANY_`sffx' .d=. .m=. .r=. .s=. .q=. .x=. 
	label var MOB_ANY_`sffx' "If any difficulty with mobility"
	tab MOB_ANY_`sffx', m 
} 

* Indicators of severe functional limitations 
foreach x in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen SEV_MOB_`x' = 0 
	replace SEV_MOB_`x' = 1 if MOB_SCORE_`x' > 1 & MOB_SCORE_`x' !=.
	replace SEV_MOB_`x' =. if MOB_SCORE_`x' ==. 	
	
	gen SEV_ADL_`x' = 0 
	replace SEV_ADL_`x' = 1 if ADL_SCORE_`x' > 1 & ADL_SCORE_`x' !=. 
	replace SEV_ADL_`x' =. if ADL_SCORE_`x' ==.
}

foreach x in 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {	
	gen SEV_IADL_`x' = 0 
	replace SEV_IADL_`x' = 1 if IADL_SCORE_`x' > 1 & IADL_SCORE_`x' !=. 
	replace SEV_IADL_`x' =. if IADL_SCORE_`x' ==. 
}

* Disability categories 
foreach y in 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen LIMITATION_`y' = 0 
	replace LIMITATION_`y' = 1 if ADL_ANY_`y' == 0 & IADL_ANY_`y' == 0 & MOB_ANY_`y' == 1 
	replace LIMITATION_`y' =. if ADL_ANY_`y' ==. | IADL_ANY_`y' ==. | MOB_ANY_`y' ==. 
	
	gen MILD_DISABILITY_`y' = 0 
	replace MILD_DISABILITY_`y' = 1 if ADL_ANY_`y' == 0 & IADL_ANY_`y' == 1
	replace MILD_DISABILITY_`y' =. if ADL_ANY_`y' ==. | IADL_ANY_`y' ==. 
	
	gen MOD_DISABILITY_`y' = 0 
	replace MOD_DISABILITY_`y' = 1 if ADL_SCORE_`y' == 1 | ADL_SCORE_`y' == 2 
	replace MOD_DISABILITY_`y' =. if ADL_SCORE_`y' ==. 
	
	gen SEV_DISABILIY_`y' = 0 
	replace SEV_DISABILIY_`y' = 1 if ADL_SCORE_`y' > 2 
	replace SEV_DISABILIY_`y' =. if ADL_SCORE_`y' ==. 
}

/* Takes meds for cholesterol
local years "2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*rxchol {
	gettoken sffx years: years 
	rename `x' MEDS_CHOL_`sffx'
	label var MEDS_CHOL_`sffx' "Takes medication for cholesterol"
}
*/ 

* Takes meds for high BP
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*rxhibp {
	gettoken sffx years: years 
	rename `x' MEDS_HIBP_`sffx'
	recode MEDS_HIBP_`sffx' .m=. .r=. .d=. 
	label var MEDS_HIBP_`sffx' "Takes medication for high BP"
	tab MEDS_HIBP_`sffx', m 
}

* BMI measured 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mbmi {
	gettoken sffx years: years 
	rename `x' BMI_MSRED_`sffx'
	recode BMI_MSRED_`sffx' .d=. .r=. .m=. .x=. .n=. .s=. 
	replace BMI_MSRED_`sffx' =. if BMI_MSRED_`sffx' > 70 | BMI_MSRED_`sffx' < 14 
	label var BMI_MSRED_`sffx' "BMI based on measured height and weight"
	tab BMI_MSRED_`sffx', m 
} 

* BMI SR
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*bmi {
	gettoken sffx years: years 
	rename `x' BMI_SR_`sffx'
	recode BMI_SR_`sffx' .d=. .m=. .r=. 
	replace BMI_SR_`sffx' =. if BMI_SR_`sffx' > 70 | BMI_SR_`sffx' < 14 
	label var BMI_SR_`sffx' "BMI based on SR height and weight"
	tab BMI_SR_`sffx', m 
}

* Obesity measured 
lab define oblab 0 "No" 1 "Yes"
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobese {
	gettoken sffx years: years 
	rename `x' OBESE_MSRED_`sffx'
	recode OBESE_MSRED_`sffx' .d=. .m=. .n=. .s=. .x=. .r=. 
	label var OBESE_MSRED_`sffx' "Obese based on measured BMI"
	label val OBESE_MSRED_`sffx' oblab
	tab OBESE_MSRED_`sffx', m 
}

* Obesity SR 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*obese {
	gettoken sffx years: years 
	rename `x' OBESE_SR_`sffx'
	recode OBESE_SR_`sffx' .d=. .m=. .r=.
	label var OBESE_SR_`sffx' "Obese based on SR BMI"
	label val OBESE_SR_`sffx' oblab 
	tab OBESE_SR_`sffx', m 
} 

* Height 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*height {
	gettoken sffx years: years 
	rename `x' HEIGHT_`sffx'
	recode HEIGHT_`sffx' .d =. .m=. .r=. 
	replace HEIGHT_`sffx' =. if HEIGHT_`sffx' > 3 
	label var HEIGHT_`sffx' "Height in metres"
	tab HEIGHT_`sffx', m 
}

* Weight 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*weight {
	gettoken sffx years: years 
	rename `x' WEIGHT_`sffx'
	recode WEIGHT_`sffx' .d =. .m=. .r=. 
	label var WEIGHT_`sffx' "Weight in kg"
	tab WEIGHT_`sffx', m 
} 

* Systolic BP 
local years "2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*systo {
	gettoken sffx years: years 
	rename `x' SYS_BP_`sffx'
	recode SYS_BP_`sffx' .d=. .r=. .m=. .x=. .n=. .s=. .i=. 
	replace SYS_BP_`sffx' =. if SYS_BP_`sffx' < 70 | SYS_BP_`sffx' > 270 
	label var SYS_BP_`sffx' "Average systolic BP"
	tab SYS_BP_`sffx', m 
}

* Diastolic BP 
local years "2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*diasto {
	gettoken sffx years: years 
	rename `x' DIA_BP_`sffx'
	recode DIA_BP_`sffx' .d=. .r=. .m=. .x=. .n=. .s=. .i=. 
	replace DIA_BP_`sffx' =. if DIA_BP_`sffx' < 50 | DIA_BP_`sffx' > 150 
	label var DIA_BP_`sffx' "Average diastolic BP"
	tab DIA_BP_`sffx', m 
}

* Generate marker of high measured BP 
foreach y in 2006 2008 2010 2012 2014 2016 2018 {
	gen HIBPM_`y' = 0 
	replace HIBPM_`y' = 1 if SYS_BP_`y' > 139 & AGE_`y' < 80 | DIA_BP_`y' > 89 & AGE_`y' < 80 
	replace HIBPM_`y' = 1 if SYS_BP_`y' > 149 & AGE_`y' >= 80 | DIA_BP_`y' > 89 & AGE_`y' >= 80
	replace HIBPM_`y' =. if SYS_BP_`y' ==. & DIA_BP_`y' ==. 
	gen HIBPTREAT_`y' = HIBPM_`y' 
	replace HIBPTREAT_`y' = 1 if MEDS_HIBP_`y' == 1 
	gen SYS_TREAT_`y' = SYS_BP_`y' 
	replace SYS_TREAT_`y' = SYS_TREAT_`y' + 10 if MEDS_HIBP_`y' == 1
	gen DIA_TREAT_`y' = DIA_BP_`y' 
	replace DIA_TREAT_`y' = DIA_TREAT_`y' + 10 if MEDS_HIBP_`y' == 1 
}

* Grip strength 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*gripsum {
	gettoken sffx years: years 
	rename `x' GRIP_`sffx'
	recode GRIP_`sffx' .d=. .m=. .r=. .l=. .t=. .i=. .x=. .n=. .s=. 
	label var GRIP_`sffx' "Max grip strength dominant hand"
	tab GRIP_`sffx', m 
}

* Number of cigarettes smoked 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define smoklab 0 "Not current smoker" 1 "Current smoker"
foreach x of varlist r*smokef {
	gettoken sffx years: years 
	rename `x' NUMSMOK_`sffx'
	recode NUMSMOK_`sffx' 1/max=1 .d=. .r=. .m=. 
	label val NUMSMOK_`sffx' smoklab 
	label var NUMSMOK_`sffx' "Smoking status"
	tab NUMSMOK_`sffx', m 
} 

**** GENERATE THE PSU, STRATA AND WEIGHTS ****

* Indicator of whether proxy response 
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define proxylab 0 "Not proxy" 1 "Proxy"
foreach x of varlist r*proxy {
	gettoken sffx years: years 
	rename `x' PROXY_`sffx'
	lab val PROXY_`sffx' proxylab
	label var PROXY_`sffx' "Proxy interview"
	tab PROXY_`sffx', m 
}

* PSU1 
foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
		gen COMB_PSU1_`y' = 9000000 + raehsamp // make sure PSUs have unique number in HRS
		tostring COMB_PSU1_`y', replace 
		replace COMB_PSU1_`y' = subinstr(COMB_PSU1_`y', ".", "", .)
		count if COMB_PSU1_`y' == ""
}
drop raehsamp

* Strata1 
foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
		gen COMB_STRAT1_`y' = 9000000 + raestrat // make sure strata have unique number in HRS
		tostring COMB_STRAT1_`y', replace
		replace COMB_STRAT1_`y' = subinstr(COMB_STRAT1_`y', ".","",.)
		count if COMB_STRAT1_`y' == ""
}
drop raestrat

/* NOTE: After evaluating whether including secondary strata and SU in SHARE, we 
decided to work only with first PSU and primary strata plus an indicator of 
ID to cluster observations in individuals - this part of the code is therefore 
suppressed. */

/*gen raestrat2 = "US-Fake-Substratum"
foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen COMB_STRAT2_`y' = raestrat2
	lab var COMB_STRAT2_`y' "Strata level 2"
}
drop raestrat2

egen rapsu2 = seq() 
duplicates report rapsu2 // check that each value is unique 
tostring rapsu2, replace 
foreach y in 1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen COMB_PSU2_`y' = rapsu2
	label var COMB_PSU2_`y' "SSU"
}
drop rapsu2
*/ 

gen FPC1 = 1 

* Nurse analysis weight - for physical assessments 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*nwtresp {
	gettoken sffx years: years 
	rename `x' COMB_WTN_`sffx' 
	replace COMB_WTN_`sffx' = 0 if COMB_WTN_`sffx' ==. 
	replace COMB_WTN_`sffx' = 0 if AGE_`sffx' < 50 
	replace COMB_WTN_`sffx' = 0 if COMB_WTN_`sffx' == .m 
}

* Person analysis weight - for the main questionnaire
drop r*scwtresp
local years "1992 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*wtresp {
	gettoken sffx years: years 
	rename `x' COMB_WTCORE_`sffx'
	replace COMB_WTCORE_`sffx' = 0 if COMB_WTCORE_`sffx' ==.
	replace COMB_WTCORE_`sffx' = 0 if AGE_`sffx' < 50 
	replace COMB_WTCORE_`sffx' = 0 if COMB_WTCORE_`sffx' == .m 
} 

* Total number of sweeps participated in since 2004 
egen TOTALSWEEPS_CORE = rowtotal(SVY_CORE_2004 SVY_CORE_2006 SVY_CORE_2010 ///
								 SVY_CORE_2012 SVY_CORE_2014 SVY_CORE_2016 ///
								 SVY_CORE_2018) 
		* Normal to have people with zero because there were surveys before 2004
egen TOTALSWEEPS_NURSE = rowtotal(SVY_N_2004 SVY_N_2006 SVY_N_2008 SVY_N_2010 ///
								  SVY_N_2012 SVY_N_2014 SVY_N_2016 SVY_N_2018) 
		* Normal to have people with zero because there were surveys before 2004

**** KEEP RELEVANT VARIABLES IN THE ANALYTICAL DATASET TO MERGE WITH ELSA AND SHARE ****

drop s*hhidpn r*mpart r*mnev r*mstath radmonth radyear raddate radage_m r*agey_e radage_y ///
r*agey_b  rawtsamp r*wtr_nh r*wtcrnh rempart remstath ///
r*ltactx r*smoke* r*drink* r*diab r*diabs raevbrn r*rxbldthn r*bp* ///
r*bld* r*grip* r*walk* r*handrt racohbyr raracem r*wthh r*vgactx r*mdactx ///
r*rxdiab r*rxchol r*wthh r*bmicat r*wspeed AGE_FIRST* r*walkaid 

mdesc

* Ammend file path here 
save "hrs_prep.dta", replace





