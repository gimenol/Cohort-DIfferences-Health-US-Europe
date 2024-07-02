/*==============================================================================
CLEANING ELSA DATASET

In this script, I clean the ELSA analysis dataset. I generate some 
new variables related to study, country, cohort etc. I also rename and relabel 
variables in a more consistent manner. This involves substituting out the wave 
number in variable names for the year in which the survey took place. This will 
allow me to merge variables from the different studies together in a way that 
makes sense. 

An important part of this script is dealing with the weights, sampling units and 
strata. Because this dataset will be used along SHARE and HRS, it is important 
to have well-aligned variables containing the correct information. For this reason, 
I generate secondary strata and a secondary stratum, and an FPC = 1 so that I can 
use the same svy set command for all countries.

Author: Laura Gimeno
==============================================================================*/ 

* Ammend file path
use "elsa_harmo.dta", clear

rename idauniq ID 
tostring ID, replace 

gen COUNTRY = 2
lab define countrylab 1 "USA" 2 "England" 3 "Austria" 4 "Germany" 5 "Sweden" ///
					  6 "Netherlands" 7 "Spain" 8 "Italy" 9 "France" 10 "Denmark" ///
					  11 "Greece" 12 "Switzerland" 13 "Belgium" 
lab values COUNTRY countrylab 

gen COUNTRYGRP = 2
lab define countrygrplab 1 "USA" 2 "England" 3 "Western Europe" 4 "Northern Europe" 5 "Southern Europe"
lab val COUNTRYGRP countrygrplab
lab var COUNTRYGRP "Geographic area" 

gen COHORT =.
recode rabyear .m =. .d=.
replace COHORT = 1 if rabyear < 1925
replace COHORT = 2 if rabyear >= 1925 & rabyear < 1936 & rabyear !=.
replace COHORT = 3 if rabyear >= 1936 & rabyear < 1946 & rabyear !=.
replace COHORT = 4 if rabyear >= 1946 & rabyear < 1955 & rabyear !=.
replace COHORT = 5 if rabyear >= 1955 & rabyear < 1960 & rabyear !=.
replace COHORT = 6 if rabyear >= 1960 & rabyear !=.

label define cohortlab 1 "<1925 Greatest Generation" 2 "1925-35 Early Silent Generation" 3 "1936-1945 - Late Silent Generation" 4 "1946-1954 Early Baby Boomers" 5 "1955-1959 Late Baby Boomers" 6 ">1960" 
label values COHORT cohortlab
label variable COHORT "Birth cohort"

gen STUDY = 2
label define studylab 1 "HRS" 2 "ELSA" 3 "SHARE"
label val STUDY studylab 
label var STUDY "Study"

rename rabyear BIRTHYEAR 
recode BIRTHYEAR .d=. 

rename ragender GENDER
recode GENDER 1=0 2=1
label define genlab 0 "Man" 1 "Woman"
label values GENDER genlab
label variable GENDER "Gender"

rename raeducl EDUCATION
recode EDUCATION .m =. .d=. .o=. .r=. 
recode EDUCATION 1/2=0 3=1  
label define edulab 0 "No Degree" 1 "Degree"
label val EDUCATION edulab

* Whether completed nurse component 
local years "2004 2008 2012 2016"
foreach x of varlist inw*n {
	gettoken sffx years: years 
	rename `x' SVY_N_`sffx'
	recode SVY_N_`sffx' . = 0 
	label var SVY_N_`sffx' "Whether complete nurse component"
	tab SVY_N_`sffx', m 
}

* Whether completed core survey
drop inw*lh inw*sc 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist inw* {
	gettoken sffx years: years 
	rename `x' SVY_CORE_`sffx'
	recode SVY_CORE_`sffx' .=0 
	label var SVY_CORE_`sffx' "Whether complete core survey in year X"
	tab SVY_CORE_`sffx', m 
} 

* Age at interview
drop r*fagey 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*agey {
	gettoken sffx years: years 
	rename `x' AGE_`sffx'
	recode AGE_`sffx' .d=. 
	label var AGE_`sffx' "Age (years) at interview"
	tab AGE_`sffx', m 
} 

foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace AGE_`y' = `y' - BIRTHYEAR if BIRTHYEAR !=. & AGE_`y' ==. 
	count if AGE_`y' ==. 
}

* Age group
lab define agelab 1 "50-54" 2 "55-59" 3 "60-64" 4 "64-69" 5 "70-74" 6 "75-79" 7 "80-84" 8 "85+"

foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 { 
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
foreach x in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace SVY_CORE_`x' = 0 if AGE_`x' < 50 
}
foreach x in 2004 2008 2012 2016 {
	replace SVY_N_`x' = 0 if AGE_`x' < 50 
}

* Marital status 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define marlab 1 "Currently married or partnered" 0 "Separated/divorced/widowed/never married/not partnered"
foreach x of varlist r*mstat {
	gettoken sffx years: years 
	rename `x' MAR_STAT_`sffx'
	recode MAR_STAT_`sffx' 1/3=1 4/8=0 .m=. .d=. .r=. 
	label val MAR_STAT_`sffx' marlab 
	label var MAR_STAT_`sffx' "Marital status (with partnership)"
	tab MAR_STAT_`sffx', m 
}

* Child 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
lab define childlab 0 "No children" 1 "Has children"
foreach x of varlist r*child {
	gettoken sffx years: years 
	rename `x' CHILD_`sffx'
	recode CHILD_`sffx' .m=. 1/max=1 
	label val CHILD_`sffx' childlab
	label var CHILD_`sffx' "Number of children"
	tab CHILD_`sffx', m 
} 

* Self-rated health 
drop rachshlt
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define healthlab 0 "Excellent/V Good/Good" 1 "Fair/Poor"
foreach x of varlist r*shlt {
	gettoken sffx years: years 
	rename `x' SELF_HEALTH_`sffx'
	recode SELF_HEALTH_`sffx' 1/3=0 4/5=1 .d =. .p=. .r=. //proxies cannot answer this question 
	label val SELF_HEALTH_`sffx' healthlab
	label var SELF_HEALTH_`sffx' "Self-rated health"
	tab SELF_HEALTH_`sffx', m 
} 

* Ever high BP 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*hibpe {
	gettoken sffx years: years 
	rename `x' HIBP_`sffx'
	recode HIBP_`sffx' .d=. .m=. .r=. 
	label var HIBP_`sffx' "Ever diagnosed with high BP"
	tab HIBP_`sffx', m 
} 

* Ever diabetes 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*diabe {
	gettoken sffx years: years 
	rename `x' DIAB_`sffx'
	recode DIAB_`sffx' .d=. .m=. .r=. 
	label var DIAB_`sffx' "Ever diagnosed with diabetes"
	tab DIAB_`sffx', m 
} 

rename radiagdiab AGE_FIRST_DIAB

* Ever cancer 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*cancre {
	gettoken sffx years: years 
	rename `x' CANCER_`sffx'
	recode CANCER_`sffx' .d=. .m=. .r=. 
	label var CANCER_`sffx' "Ever diagnosed with cancer"
	tab CANCER_`sffx', m 
} 

rename radiagcancr AGE_FIRST_CANCER

* Ever lung disease 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*lunge {
	gettoken sffx years: years 
	rename `x' LUNG_`sffx'
	recode LUNG_`sffx' .d=. .m=. .r=. 
	label var LUNG_`sffx' "Ever diagnosed with lung disease"
	tab LUNG_`sffx', m 
} 

* Ever heart problems  
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*hearte {
	gettoken sffx years: years 
	rename `x' HEART_`sffx'
	recode HEART_`sffx' .d=. .m=. .r=. 
	label var HEART_`sffx' "Ever diagnosed with heart problems"
	tab HEART_`sffx', m 
}
	
* Ever high cholesterol 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*hchole {
	gettoken sffx years: years 
	rename `x' CHOL_`sffx'
	recode CHOL_`sffx' .d=. .m=. .r=. 
	label var CHOL_`sffx' "Ever diagnosed with high cholesterol"
	tab CHOL_`sffx', m 
} 

* ADL score
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltot_e {
	gettoken sffx years: years 
	rename `x' ADL_SCORE_`sffx'
	recode ADL_SCORE_`sffx' .p=. .m=. .d=. .r=. // proxies could not answer this question in W1 
	label var ADL_SCORE_`sffx' "ADL score (0-6)"
	tab ADL_SCORE_`sffx', m 
} 

* ADL missings  
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltotm_e {
	gettoken sffx years: years 
	rename `x' ADL_MISS_`sffx'
	label var ADL_MISS_`sffx' "Number missing items ADL score"
	tab ADL_MISS_`sffx', m 
} 

* Any difficulty with ADLs 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*adltota_e {
	gettoken sffx years: years 
	rename `x' ADL_ANY_`sffx'
	recode ADL_ANY_`sffx' .p=. .m=. .d=. .r=. 
	label var ADL_ANY_`sffx' "If any difficulty with ADL"
	tab ADL_ANY_`sffx', m 
} 

* IADL score
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfour {
	gettoken sffx years: years 
	rename `x' IADL_SCORE_`sffx'
	recode IADL_SCORE_`sffx' .p=. .m=. .d=. .r=. // proxies could not answer this question in W1 
	label var IADL_SCORE_`sffx' "IADL score (0-4)"
	tab IADL_SCORE_`sffx', m 
} 

* IADL missings  
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfourm {
	gettoken sffx years: years 
	rename `x' IADL_MISS_`sffx'
	label var IADL_MISS_`sffx' "Number missing items IADL score"
	tab IADL_MISS_`sffx', m 
} 

* Any difficulty with IADLs 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfoura {
	gettoken sffx years: years 
	rename `x' IADL_ANY_`sffx'
	recode IADL_ANY_`sffx' .p=. .m=. .d=. .r=. // proxies could not answer this question in W1 
	label var IADL_ANY_`sffx' "If any difficulty with IADL"
	tab IADL_ANY_`sffx' , m 
} 

* Mobility score 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsev {
	gettoken sffx years: years 
	rename `x' MOB_SCORE_`sffx'
	recode MOB_SCORE_`sffx' .p=. .m=. .d=. .r=. // proxies could not answer this question in W1 
	label var MOB_SCORE_`sffx' "Mobility score (0-7)"
	tab MOB_SCORE_`sffx', m 
} 

* Mobility missings  
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsevm {
	gettoken sffx years: years 
	rename `x' MOB_MISS_`sffx'
	label var MOB_MISS_`sffx' "Number missing items mobility score"
	tab MOB_MISS_`sffx', m 
} 

* Any difficulty with mobility 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilseva {
	gettoken sffx years: years 
	rename `x' MOB_ANY_`sffx'
	recode MOB_ANY_`sffx' .p=. .m=. .r=. .d=. // proxies could not answer this question in W1 
	label var MOB_ANY_`sffx' "If any difficulty with mobility"
	tab MOB_ANY_`sffx', m 
} 

* Indicators of severe functional limitations 
foreach x in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen SEV_MOB_`x' = 0 
	replace SEV_MOB_`x' = 1 if MOB_SCORE_`x' > 1 & MOB_SCORE_`x' !=.
	replace SEV_MOB_`x' =. if MOB_SCORE_`x' ==. 
	
	gen SEV_ADL_`x' = 0 
	replace SEV_ADL_`x' = 1 if ADL_SCORE_`x' > 1 & ADL_SCORE_`x' !=. 
	replace SEV_ADL_`x' =. if ADL_SCORE_`x' ==.
	
	gen SEV_IADL_`x' = 0 
	replace SEV_IADL_`x' = 1 if IADL_SCORE_`x' > 1 & IADL_SCORE_`x' !=. 
	replace SEV_IADL_`x' =. if IADL_SCORE_`x' ==. 
}

* Indicators of disability 
foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
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

* Takes meds for cholesterol
local years "2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*rxhchol {
	gettoken sffx years: years 
	rename `x' MEDS_CHOL_`sffx'
	label var MEDS_CHOL_`sffx' "Takes medication for cholesterol"
}

* Takes meds for high BP
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*rxhibp {
	gettoken sffx years: years 
	rename `x' MEDS_HIBP_`sffx'
	recode MEDS_HIBP_`sffx' .d=. .m=. .r=.
	label var MEDS_HIBP_`sffx' "Takes medication for high BP"
	tab MEDS_HIBP_`sffx', m 
}

* Takes meds for diabetes 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*rxdiab {
	gettoken sffx years: years 
	rename `x' MEDS_DIAB_`sffx'
	label var MEDS_DIAB_`sffx' "Takes medication for diabetes"
}

* BMI measured 
local years "2004 2008 2012 2016"
foreach x of varlist r*mbmi {
	gettoken sffx years: years 
	rename `x' BMI_MSRED_`sffx'
	recode BMI_MSRED_`sffx' .i=. .n=. .s=. .x=. .e=. .m=. .p=.
	replace BMI_MSRED_`sffx' =. if BMI_MSRED_`sffx' < 14 | BMI_MSRED_`sffx' > 70 
	label var BMI_MSRED_`sffx' "BMI based on measured height and weight"
	tab BMI_MSRED_`sffx', m 
} 

* BMI category measured
label define bmilab 1 "underweight less than 18.5" ///
					2 "normal weight from 18.5 to 24.9" ///
					3 "pre-obesity from 25 to 29.9" ///
					4 "obesity class 1 from 30 to 34.9" ///
					5 "obesity class 2 from 35 to 39.9" ///
					6 "obesity class 3 greater than 40" 
local years "2004 2008 2012 2016"
foreach x of varlist r*mbmicat {
	gettoken sffx years: years 
	rename `x' BMICAT_MSRED_`sffx'
	recode BMICAT_MSRED_`sffx' .i=. .n=. .s=. .x=. .e=. .m=. .p=. 
	label var BMICAT_MSRED_`sffx' "BMI category based on measured height and weight"
	label val BMICAT_MSRED_`sffx' bmilab
	tab BMICAT_MSRED_`sffx', m
}
 
* Obesity (measured)
lab define oblab 0 "No" 1 "Yes"
foreach y in 2004 2008 2012 2016 {
	gen OBESE_MSRED_`y' = BMICAT_MSRED_`y'
	recode OBESE_MSRED_`y' 1/3=0 4/6=1 
	label var OBESE_MSRED_`y' "Whether obese based on measured BMI"
	label val OBESE_MSRED_`y' oblab
	tab OBESE_MSRED_`y', m 
}
drop BMICAT* 

* Height 
local years "2004 2008 2012 2016"
foreach x of varlist r*mheight {
	gettoken sffx years: years 
	rename `x' HEIGHT_`sffx'
	recode HEIGHT_`sffx' .i=. .n=. .s=. .x=. .m=. 
	label var HEIGHT_`sffx' "Height in metres"
	tab HEIGHT_`sffx', m 
}

* Weight 
replace r8mweight = r9mweight if r8mweight ==. | r8mweight == .e | r8mweight == .i | r8mweight == .m | r8mweight == .n | r8mweight == .p | r8mweight == .x 
drop r9mweight
local years "2004 2008 2012 2016"
foreach x of varlist r*mweight {
	gettoken sffx years: years 
	rename `x' WEIGHT_`sffx'
	recode WEIGHT_`sffx' .i=. .n=. .s=. .x=. .m=. .p =.
	label var WEIGHT_`sffx' "Weight in kilograms"
	tab WEIGHT_`sffx', m 
}

* Systolic BP 
local years "2004 2008 2012 2016"
foreach x of varlist r*systo {
	gettoken sffx years: years 
	rename `x' SYS_BP_`sffx'
	recode SYS_BP_`sffx' .m=. .r=. .n=. .s=. 
	replace SYS_BP_`sffx' =. if SYS_BP_`sffx' < 70 | SYS_BP_`sffx' > 270 
	label var SYS_BP_`sffx' "Average systolic BP"
	tab SYS_BP_`sffx', m 
}

* Diastolic BP 
local years "2004 2008 2012 2016"
foreach x of varlist r*diasto {
	gettoken sffx years: years 
	rename `x' DIA_BP_`sffx'
	recode DIA_BP_`sffx' .m=. .n=. .r=. .s=. 
	replace DIA_BP_`sffx' =. if DIA_BP_`sffx' < 50 | DIA_BP_`sffx' > 150 
	label var DIA_BP_`sffx' "Average diastolic BP"
	tab DIA_BP_`sffx', m 
}

* Generate marker of high measured BP 
foreach y in 2004 2008 2012 2016 {
	gen HIBPM_`y' = 0 
	replace HIBPM_`y' = 1 if SYS_BP_`y' > 139 & AGE_`y' < 80 | DIA_BP_`y' > 89 & AGE_`y' < 80 
	replace HIBPM_`y' = 1 if SYS_BP_`y' > 149 & AGE_`y' >= 80 | DIA_BP_`y' > 89 & AGE_`y' > 79
	replace HIBPM_`y' =. if SYS_BP_`y' ==. & DIA_BP_`y' ==. 
	gen HIBPTREAT_`y' = HIBPM_`y' 
	replace HIBPTREAT_`y' = 1 if MEDS_HIBP_`y' == 1 
	gen SYS_TREAT_`y' = SYS_BP_`y' 
	replace SYS_TREAT_`y' = SYS_TREAT_`y' + 10 if MEDS_HIBP_`y' == 1
	gen DIA_TREAT_`y' = DIA_BP_`y' 
	replace DIA_TREAT_`y' = DIA_TREAT_`y' + 10 if MEDS_HIBP_`y' == 1 
}

* Grip strength 
local years "2004 2008 2012 2016"
foreach x of varlist r*gripsum {
	gettoken sffx years: years 
	rename `x' GRIP_`sffx'
	recode GRIP_`sffx' .l=. .m=. .n=. .s=. .t=. .d=. .r=.
	label var GRIP_`sffx' "Max grip strength dominant hand"
	tab GRIP_`sffx', m 
}

* Number of cigarettes smoked 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
label define smoklab 0 "Not current smoker" 1 "Current smoker"
foreach x of varlist r*smokef {
	gettoken sffx years: years 
	rename `x' NUMSMOK_`sffx'
	recode NUMSMOK_`sffx' min/1=0 1/max=1  .d=. .r=. .m=. 
	label val NUMSMOK_`sffx' smoklab 
	label var NUMSMOK_`sffx' "Smoking status"
	tab NUMSMOK_`sffx', m 
} 

**** GENERATE THE PSU, STRATA AND WEIGHTS ****

* Whether proxy respondent 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
lab def proxylab 0 "Non proxy" 1 "Proxy"
foreach x of varlist r*proxy {
	gettoken sffx years: years 
	rename `x' PROXY_`sffx'
	lab val PROXY_`sffx' proxylab
	lab var PROXY_`sffx' "Whether proxy respondent"
	tab PROXY_`sffx', m 
}


* PSU1 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*clust {
	gettoken sffx years: years 
	rename `x' COMB_PSU1_`sffx'
}

foreach y in 2002 2004 { 
	replace COMB_PSU1_`y' = 8000000 + COMB_PSU1_`y' 
	tostring COMB_PSU1_`y', replace 
	replace COMB_PSU1_`y' = subinstr(COMB_PSU1_`y', ".", "", .)
	replace COMB_PSU1_`y' = ID if COMB_PSU1_`y' == ""
	count if COMB_PSU1_`y' == ""
}

foreach y in 2006 2008 2010 2012 2014 2016 2018{
	encode COMB_PSU1_`y', gen(newpsu_`y') 
	label values newpsu_`y' .
	gen newpsulong_`y' = 8000000 + newpsu_`y'
	tostring newpsulong_`y', replace
	replace newpsulong_`y' = subinstr(newpsulong_`y', ".","",.)
	drop COMB_PSU1_`y' 
	rename newpsulong_`y' COMB_PSU1_`y' 
	drop newpsu_`y'
	replace COMB_PSU1_`y' = ID if COMB_PSU1_`y' == ""
	count if COMB_PSU1_`y' == "" 
}

* Strata1 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*strat {
	gettoken sffx years: years 
	rename `x' COMB_STRAT1_`sffx'
}

foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	replace COMB_STRAT1_`y' = 8000000 + COMB_STRAT1_`y'
	tostring COMB_STRAT1_`y', replace 
	replace COMB_STRAT1_`y' = subinstr(COMB_STRAT1_`y', ".","",.)
	replace COMB_STRAT1_`y' = "GB-Fake-Stratum" if COMB_STRAT1_`y' == "" 
	count if COMB_STRAT1_`y' == ""
}

/* NOTE: After evaluating whether including secondary strata and SU in SHARE, we 
decided to work only with first PSU and primary strata plus an indicator of 
ID to cluster observations in individuals - this part of the code is therefore 
suppressed. */

/* gen raestrat2 = "GB-Fake-Substratum"
foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen COMB_STRAT2_`y' = raestrat2
	lab var COMB_STRAT2_`y' "Strata level 2"
}
drop raestrat2

egen rapsu2 = seq() 
duplicates report rapsu2 // check that each value is unique 
tostring rapsu2, replace 
foreach y in 2002 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen COMB_PSU2_`y' = rapsu2
	label var COMB_PSU2_`y' "SSU"
}
drop rapsu2
*/

gen FPC1 = 1 

* Core person analysis weight - for the main questionnaire
drop r*scwtresp 
local years "2002 2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*cwtresp {
	gettoken sffx years: years 
	rename `x' COMB_WTCORE_`sffx'
	replace COMB_WTCORE_`sffx' = 0 if COMB_WTCORE_`sffx' == .
	replace COMB_WTCORE_`sffx' = 0 if AGE_`sffx' < 50 
	count if COMB_WTCORE_`sffx' ==. 
}

* Nurse analysis weight - for the physical assessments 
drop r8npwtresp
local years "2004 2008 2012 2016"
foreach x of varlist r*nwtresp {
	gettoken sffx years: years 
	rename `x' COMB_WTN_`sffx'
	replace COMB_WTN_`sffx' = 0 if COMB_WTN_`sffx' ==. 
	replace COMB_WTN_`sffx' = 0 if AGE_`sffx' < 50 
	count if COMB_WTN_`sffx' ==. 
}

* Total number of sweeps participated in since 2004 
egen TOTALSWEEPS_CORE = rowtotal(SVY_CORE_2004 SVY_CORE_2006 SVY_CORE_2010  /// 
								 SVY_CORE_2012 SVY_CORE_2014 SVY_CORE_2016 ///
								 SVY_CORE_2018)
egen TOTALSWEEPS_NURSE = rowtotal(SVY_N_2004 SVY_N_2008 SVY_N_2012 SVY_N_2016)

drop s*idauniq h*cpl r*iwindm r*iwindy r*iwnrsm r*iwnrsy radyear r*mpart r*mstath ///
rabplace r*nhmliv r*ltactx_e r*drink* r*smoke* r*walk* r*bp* r*grip* r*vgactx_e r*mdactx_e ///
raracem r*cohort_e r*wspeed AGE_FIRST* 

mdesc

* Merge in biomarkers from other dataset 
rename ID id 
destring id, replace  
merge 1:1 id using "ELSA_biomarkers.dta" // ammend file path
drop _merge 
tostring id, replace 
rename id ID 

save "elsa_prep.dta", replace // ammend file path 

