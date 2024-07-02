/*==============================================================================
CLEANING SHARE DATASET

In this script, I clean the SHARE analysis dataset. I generate some 
new variables related to study, country, cohort etc. I also rename and relabel 
variables in a more consistent manner. This involves substituting out the wave 
number in variable names for the year in which the survey took place. This will 
allow me to merge variables from the different studies together in a way that 
makes sense. 

An important part of this script is dealing with the weights, sampling units and 
strata, to ensure that I am able to analyse data from all countries in an aligned 
way. This involves generating 'fake' strata (primary and secondary) for countries 
who are missing this information, and unique values for PSU and SSU for countries 
who do not have this data. As there is no information given on FPC, I assign a 
value of 1 to ensure that Stata takes into account the second level of sample design.

Author: Laura Gimeno
==============================================================================*/ 

* Ammend file path 
use "share_harmo.dta", clear

rename mergeid ID 

* Only going to keep countries which participated in first wave
keep if country < 24 
rename country COUNTRY 
recode COUNTRY 11=3 12=4 13=5 14=6 15=7 16=8 17=9 18=10 19=11 20=12 23=13 
lab define countrylab 1 "USA" 2 "England" 3 "Austria" 4 "Germany" 5 "Sweden" ///
					  6 "Netherlands" 7 "Spain" 8 "Italy" 9 "France" 10 "Denmark" ///
					  11 "Greece" 12 "Switzerland" 13 "Belgium"
label val COUNTRY countrylab

gen COUNTRYGRP = COUNTRY
recode COUNTRYGRP 4=3 5=4 6=3 7=5 8=5 9=3 10=4 11=5 12=3 13=3
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

gen STUDY = 3
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
recode EDUCATION .m =.
recode EDUCATION 1/2=0 3=1 
label define edulab 0 "No Degree" 1 "Degree"
label val EDUCATION edulab

* Whether in wave (we only have to keep the general indicator because this is the one to use with the weight)
drop inw*sc // drop-off questionnaire 
drop inw*lh // life history questionnaire
drop inw7 // dropping this to keep those who responded to either condensed version or full questionnaire
rename inw7c SVY_CORE_2016 
recode SVY_CORE_2016 .=0 
label var SVY_CORE_2016 "Whether complete core survey in year X"
local years "2004 2006 2010 2012 2014 2018"
foreach x of varlist inw* {
	gettoken sffx years: years 
	rename `x' SVY_CORE_`sffx'
	recode SVY_CORE_`sffx' .=0
	label var SVY_CORE_`sffx' "Whether complete core survey in year X"
} 

/* There were no nurse visits in SHARE, so the same variable (inw) is used for the
small number of physical measures collected. For ease of data wrangling, I create 
a variable to flag inclusion in 'nurse wave' that is the same as the variable abpve. 
In combination with the analysis weight, it can be used to identify respondents. */ 
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
	gen SVY_N_`y' = SVY_CORE_`y' 
	recode SVY_N_`y' .=0
	label var SVY_N_`y' "Whether complete nurse component"
	tab SVY_N_`y', m 
}

* Age at interview
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*agey {
	gettoken sffx years: years 
	rename `x' AGE_`sffx'
	recode AGE_`sffx' .d=. .m=.
	label var AGE_`sffx' "Age (years) at interview wave"
	tab AGE_`sffx', m 
} 

foreach y in 2004 2006 2010 2012 2014 2016 2018 {
	replace AGE_`y' = `y' - BIRTHYEAR if BIRTHYEAR !=. & AGE_`y' ==. 
	count if AGE_`y' ==. 
}

* Age group
lab define agelab 1 "50-54" 2 "55-59" 3 "60-64" 4 "64-69" 5 "70-74" 6 "75-79" 7 "80-84" 8 "85+"

foreach y in 2004 2006 2010 2012 2014 2016 2018 { 
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
foreach x in 2004 2006 2010 2012 2014 2016 2018 {
	replace SVY_CORE_`x' = 0 if AGE_`x' < 50 
	replace SVY_N_`x' = 0 if AGE_`x' < 50 
}

* Marital status 
drop r*mstath 
local years "2004 2006 2010 2012 2014 2016 2018"
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
drop h*fchild
drop h*grchild
local years "2004 2006 2010 2012 2014 2016 2018" 
lab define childlab 0 "No children" 1 "Has children"
foreach x of varlist h*child {
	gettoken sffx years: years 
	rename `x' CHILD_`sffx'
	recode CHILD_`sffx' 1/max=1 
	label val CHILD_`sffx' childlab
	label var CHILD_`sffx' "Number of children"
	tab CHILD_`sffx', m 
} 

* Self-rated health 
drop rachshlt rachfshlt
local years "2004 2006 2010 2012 2014 2016 2018"
label define healthlab 0 "Excellent/V Good/Good" 1 "Fair/Poor"
foreach x of varlist r*shlt {
	gettoken sffx years: years 
	rename `x' SELF_HEALTH_`sffx'
	recode SELF_HEALTH_`sffx' .d=. .m=. .r=. 1/3=0 4/5=1 
	label val SELF_HEALTH_`sffx' healthlab 
	label var SELF_HEALTH_`sffx' "Self-rated health"
	tab SELF_HEALTH_`sffx', m 
} 

* Ever high BP 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*hibpe {
	gettoken sffx years: years 
	rename `x' HIBP_`sffx'
	recode HIBP_`sffx' .r=. .m=. .d=.
	label var HIBP_`sffx' "Ever diagnosed with high BP"
	tab HIBP_`sffx', m 
} 

rename radiaghib AGE_FIRST_HIBP

* Ever diabetes 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*diabe {
	gettoken sffx years: years 
	rename `x' DIAB_`sffx'
	recode DIAB_`sffx' .r=. .m=. .d=.
	label var DIAB_`sffx' "Ever diagnosed with diabetes"
	tab DIAB_`sffx', m 
} 

rename radiagdiab AGE_FIRST_DIAB

* Ever cancer 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*cancre {
	gettoken sffx years: years 
	rename `x' CANCER_`sffx'
	recode CANCER_`sffx' .r=. .m=. .d=.
	label var CANCER_`sffx' "Ever diagnosed with cancer"
	tab CANCER_`sffx', m 
} 

rename radiagcancr AGE_FIRST_CANCR

* Ever lung disease 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*lunge {
	gettoken sffx years: years 
	rename `x' LUNG_`sffx'
	recode LUNG_`sffx' .r=. .m=. .d=.
	label var LUNG_`sffx' "Ever diagnosed with lung disease"
	tab LUNG_`sffx', m 
} 

rename radiaglung AGE_FIRST_LUNG 

* Ever heart problems  
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*hearte {
	gettoken sffx years: years 
	rename `x' HEART_`sffx'
	recode HEART_`sffx' .r=. .m=. .d=.
	label var HEART_`sffx' "Ever diagnosed with heart problems"
	tab HEART_`sffx', m 
} 

rename radiagheart AGE_FIRST_HEART

* Ever high cholesterol 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*hchole {
	gettoken sffx years: years 
	rename `x' CHOL_`sffx'
	recode CHOL_`sffx' .r=. .m=. .d=.
	label var CHOL_`sffx' "Ever diagnosed with high cholesterol"
	tab CHOL_`sffx', m 
} 

rename radiaghchol AGE_FIRST_CHOL

* ADL score
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*adltot_s {
	gettoken sffx years: years 
	rename `x' ADL_SCORE_`sffx'
	recode ADL_SCORE_`sffx' .r=. .m=. .d=.
	label var ADL_SCORE_`sffx' "ADL score (0-6)"
	tab ADL_SCORE_`sffx', m 
} 

* ADL missings  
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*adltotm_s {
	gettoken sffx years: years 
	rename `x' ADL_MISS_`sffx'
	label var ADL_MISS_`sffx' "Number missing items ADL score"
	tab ADL_MISS_`sffx', m 
} 

* Any difficulty with ADLs 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*adltota_s {
	gettoken sffx years: years 
	rename `x' ADL_ANY_`sffx'
	recode ADL_ANY_`sffx' .r=. .m=. .d=.
	label var ADL_ANY_`sffx' "If any difficulty with ADL"
	tab ADL_ANY_`sffx', m 
} 

* IADL score
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfour {
	gettoken sffx years: years 
	rename `x' IADL_SCORE_`sffx'
	recode IADL_SCORE_`sffx' .r=. .m=. .d=.
	label var IADL_SCORE_`sffx' "IADL score (0-4)"
	tab IADL_SCORE_`sffx', m 
} 

* IADL missings  
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfourm {
	gettoken sffx years: years 
	rename `x' IADL_MISS_`sffx'
	label var IADL_MISS_`sffx' "Number missing items IADL score"
	tab IADL_MISS_`sffx', m 
} 

* Any difficulty with IADLs 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*iadlfoura {
	gettoken sffx years: years 
	rename `x' IADL_ANY_`sffx'
	recode IADL_ANY_`sffx' .r=. .m=. .d=.
	label var IADL_ANY_`sffx' "If any difficulty with IADL"
	tab IADL_ANY_`sffx', m 
} 

* Mobility score 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsev {
	gettoken sffx years: years 
	rename `x' MOB_SCORE_`sffx'
	recode MOB_SCORE_`sffx' .r=. .m=. .d=.
	label var MOB_SCORE_`sffx' "Mobility score (0-7)"
	tab MOB_SCORE_`sffx', m 
} 

* Mobility missings  
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilsevm {
	gettoken sffx years: years 
	rename `x' MOB_MISS_`sffx'
	label var MOB_MISS_`sffx' "Number missing items mobility score"
	tab MOB_MISS_`sffx', m 
} 

* Any difficulty with mobility 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*mobilseva {
	gettoken sffx years: years 
	rename `x' MOB_ANY_`sffx'
	recode MOB_ANY_`sffx' .r=. .m=. .d=.
	label var MOB_ANY_`sffx' "If any difficulty with mobility"
	tab MOB_ANY_`sffx', m 
} 

* Indicators of severe functional limitations 
foreach x in 2004 2006 2010 2012 2014 2016 2018 {
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
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
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

* Takes meds for high BP
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*rxhibp {
	gettoken sffx years: years 
	rename `x' MEDS_HIBP_`sffx'
	recode MEDS_HIBP_`sffx' .r=. .m=. .d=.
	label var MEDS_HIBP_`sffx' "Takes medication for high BP"
	tab MEDS_HIBP_`sffx', m 
}

* BMI SR
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*bmi {
	gettoken sffx years: years 
	rename `x' BMI_SR_`sffx'
	recode BMI_SR_`sffx' .d=. .i=. .m=. .r=. 
	replace BMI_SR_`sffx' =. if BMI_SR_`sffx' < 14 | BMI_SR_`sffx' > 70
	label var BMI_SR_`sffx' "BMI based on SR height and weight"
	tab BMI_SR_`sffx', m 
} 

* BMI category SR 
label define bmilab 1 "underweight less than 18.5" ///
					2 "normal weight from 18.5 to 24.9" ///
					3 "pre-obesity from 25 to 29.9" ///
					4 "obesity class 1 from 30 to 34.9" ///
					5 "obesity class 2 from 35 to 39.9" ///
					6 "obesity class 3 greater than 40" 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*bmicat {
	gettoken sffx years: years 
	rename `x' BMICAT_SR_`sffx'
	recode BMICAT_SR_`sffx' .d=. .i=. .m=. .r=. 
	label var BMICAT_SR_`sffx' "BMI category based on SR height and weight"
	label val BMICAT_SR_`sffx' bmilab 
	tab BMICAT_SR_`sffx', m 
}

* Obesity (self-reported)
lab define oblab 0 "No" 1 "Yes"
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
	gen OBESE_SR_`y' = BMICAT_SR_`y'
	recode OBESE_SR_`y' 1/3=0 4/6=1 
	lab val OBESE_SR_`y' oblab
	label var OBESE_SR_`y' "Whether obese based on SR BMI"
	tab OBESE_SR_`y', m 
}
drop BMICAT*

* Height 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*height {
	gettoken sffx years: years 
	rename `x' HEIGHT_`sffx'
	recode HEIGHT_`sffx' .d=. .m=. .r=. .i=.
	lab var HEIGHT_`sffx' "Height in metres"
	tab HEIGHT_`sffx', m 
}

* Weight 
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*weight {
	gettoken sffx years: years 
	rename `x' WEIGHT_`sffx'
	recode WEIGHT_`sffx' .d=. .m=. .r=. .i=.
	lab var WEIGHT_`sffx' "Weight in kilograms"
	tab WEIGHT_`sffx', m 
}

* Grip strength 
local years "2004 2006 2008 2010 2012 2014 2016 2018"
foreach x of varlist r*gripsum {
	gettoken sffx years: years 
	rename `x' GRIP_`sffx'
	recode GRIP_`sffx' .m=. .n=. .d=. .r=. .l=. .t=. .p=. .i=.
	label var GRIP_`sffx' "Max grip strength dominant hand"
	tab GRIP_`sffx', m 
}

* Number of cigarettes smoked 
local years "2004 2006 2014 2016 2018"
label define smoklab 0 "Not current smoker" 1 "Current smoker"
foreach x of varlist r*smokef {
	gettoken sffx years: years 
	rename `x' NUMSMOK_`sffx'
	recode NUMSMOK_`sffx' 1/max=1 .d=. .m=. .r=. .q=. 
	label val NUMSMOK_`sffx' smoklab 
	label var NUMSMOK_`sffx' "Smoking status"
	tab NUMSMOK_`sffx', m 
} 

**** GENERATE THE PSU, STRATA AND WEIGHTS ****

/* Because of the  multi-country nature of SHARE, cleaning weights, strata, and 
sampling units is more challenging in this dataset */ 

* Whether proxy respondents
local years "2004 2006 2010 2012 2014 2016 2018"
foreach x of varlist r*proxy {
	gettoken sffx years: years 
	rename `x' PROXY_`sffx'
	label var PROXY_`sffx' "Proxy Response"
	tab PROXY_`sffx', m 
} 

* Strata1
count if raestrat1 == "" & raestrat2 != "" // only countries with Stratum 1 have Stratum 2 

* Sime countries did not use clustering, so we need to give them a single stratum number 
* Countries that did not use clustering are: Germany, Netherlands, and Denmark
* There are also several countries missing large numbers of strata, so we also replace these (France, Sweden, and some from Belgium)

tab COUNTRY if raestrat1 == ""
replace raestrat1 = "DE-Fake-Stratum" if raestrat1 == "" & COUNTRY == 4 // Germany 
replace raestrat1 = "SE-Fake-Stratum" if raestrat1 == "" & COUNTRY == 5 // Sweden
replace raestrat1 = "NL-Fake-Stratum" if raestrat1 == "" & COUNTRY == 6 // Netherlands
replace raestrat1 = "FR-Fake-Stratum" if raestrat1 == "" & COUNTRY == 9 // France 
replace raestrat1 = "DK-Fake-Stratum" if raestrat1 == "" & COUNTRY == 10 // Denmark 
replace raestrat1 = "BE-Fake-Stratum" if raestrat1 == "" & COUNTRY == 13 // Belgium 
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
		gen COMB_STRAT1_`y' = raestrat1
		lab var COMB_STRAT1_`y' "Strata level 1"
		count if COMB_STRAT1_`y' == ""
}

* Strat2 

/* NOTE: After exploring whether results differed when using primary, secondary, 
and within individual clustering versus primary and within individual clustering 
only, we decided to use the latter and keep only primary strata and SUs in the 
analysis. However, others may find the work below helpful for their own analyses, 
so we have left this part of the code in and just commented out. 

RAESTRAT2 values are provided for Italy and Switzerland, but are missing for most 
respondents from Switzerland. I take the same approach as above for Switzerland, assigning 
all respondents with missing stratum in Switzerland the same fake stratum.

Because Spain does not have a secondary stratum but does have values for RAPSU2, 
I also assign Spanish respondents a dummy missing stratum following the same 
process as Switzerland. 
tab COUNTRY if raestrat2 != "" // as we would expect 
tab COUNTRY if raestrat2 == "" & COUNTRY == 8 | raestrat2 == "" & COUNTRY == 12 // none missing for Italy 
replace raestrat2 = "CH-Fake-Substratum" if raestrat2 == "" & COUNTRY == 12 // Switzerland
replace raestrat2 = "ES-Fake-Substratum" if raestrat2 == "" & COUNTRY == 7 // Spain
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
		gen COMB_STRAT2_`y' = raestrat2
		label var COMB_STRAT2_`y' "Strata level 2"
}

replace raestrat2 = "AT-Fake-Substratum" if raestrat2 == "" & COUNTRY == 3 // Austria 
replace raestrat2 = "DE-Fake-Substratum" if raestrat2 == "" & COUNTRY == 4 // Germany
replace raestrat2 = "SE-Fake-Substratum" if raestrat2 == "" & COUNTRY == 5 // Sweden
replace raestrat2 = "NL-Fake-Substratum" if raestrat2 == "" & COUNTRY == 6 // Netherlands
replace raestrat2 = "ES-Fake-Substratum" if raestrat2 == "" & COUNTRY == 7 // Spain
replace raestrat2 = "IT-Fake-Substratum" if raestrat2 == "" & COUNTRY == 8 // Italy
replace raestrat2 = "FR-Fake-Substratum" if raestrat2 == "" & COUNTRY == 9 // France
replace raestrat2 = "DK-Fake-Substratum" if raestrat2 == "" & COUNTRY == 10 // Denmark
replace raestrat2 = "GR-Fake-Substratum" if raestrat2 == "" & COUNTRY == 11 // Greece
replace raestrat2 = "CH-Fake-Substratum" if raestrat2 == "" & COUNTRY == 12 // Switzerland
replace raestrat2 = "BE-Fake-Substratum" if raestrat2 == "" & COUNTRY == 13 // Belgium
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
		gen COMB_STRAT2_`y' = raestrat2
		lab var COMB_STRAT2_`y' "Strata level 2"
} */

* PSU1 
tab COUNTRY if rapsu1 == "" // 24,490 missing PSUs 
* Denmark and Switzerland did not use a clustered sample design, and there are many 
* missing values for France, Greece and Sweden 
* We need to assign a unique PSU within countries for each missing PSU 
destring rapsu1, replace // this generates missing values 
sort rapsu1
format rapsu1 %15.0f // maximum rapsu1 value is 516077027 
egen newpsu = seq() if rapsu1 ==., from(516077028)
duplicates report newpsu // all new PSUs are unique 
replace rapsu1 = newpsu if rapsu1 ==. 
tostring rapsu1, replace
replace rapsu1 = "" if rapsu1 == "." 
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
		gen COMB_PSU1_`y' = rapsu1
		label var COMB_PSU1_`y' "PSU level 1"
		count if COMB_PSU1_`y' == ""
}
drop newpsu

* PSU2 

/* NOTE: After exploring whether results differed when using primary, secondary, 
and within individual clustering versus primary and within individual clustering 
only, we decided to use the latter and keep only primary strata and SUs in the 
analysis. However, others may find the work below helpful for their own analyses, 
so we have left this part of the code in and just commented out. 

RAPSU2 values are only meant to be provided for Italy and Spain - but they 
are missing for most respondents in Spain. I take the same approach as above 
where I assign an individual SSU number for each respondent in Spain or Italy 
if they are missing a value for SSU. 

Even though Switzerland does not have any values for RAPSU2, I assign every 
person from Switzerland a unique RAPSU2 number because they have secondary 
stratum so we need to plug in the second level into the svy command. 

tab COUNTRY if rapsu2 != "" // this is as expected 
tab COUNTRY if rapsu2 == "" & COUNTRY == 7 | rapsu2 == "" & COUNTRY == 8 // only missing for Spain
destring rapsu2, replace 
sort rapsu2 
format rapsu2 %15.0f // largest value of RAPSU2 is 69304 
egen newpsu2 = seq() if rapsu2 ==. & COUNTRY == 7 | rapsu2 ==. & COUNTRY == 12, from(69305)
duplicates report newpsu2 // check that any observations !=. are not duplicated 
replace rapsu2 = newpsu2 if rapsu2 ==. & COUNTRY == 7 | rapsu2 ==. & COUNTRY == 12 
tostring rapsu2, replace 
replace rapsu2 = "" if rapsu2 == "." 
drop newpsu2
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
	gen COMB_PSU2_`y' = rapsu2 
	label var COMB_PSU2_`y' "PSU level 2"
} 

destring rapsu2, replace
sort rapsu2 
summarize rapsu2 // maximum value is 69304 
egen newpsu2 = seq() if rapsu2 ==., from(69305) t(139993)
duplicates report newpsu2 // should have no duplicates 
replace rapsu2 = newpsu2 if rapsu2 ==. 
tostring rapsu2, replace 
replace rapsu2 = "" if rapsu2 == "."
drop newpsu2 
foreach y in 2004 2006 2008 2010 2012 2014 2016 2018 {
	gen COMB_PSU2_`y' = rapsu2 
	label var COMB_PSU2_`y' "SSU"
} 

Generate an FPC = 1 for countries with a SSU/secondary stratum (Spain, Italy, Switzerland)
gen FPC1 = 1 if COUNTRY == 7 | COUNTRY == 8 | COUNTRY == 12

*/ 

gen FPC1 = 1

* Person-level analysis weight 
drop r7wtresp
rename r7wtrespc COMB_WTCORE_2016 
replace COMB_WTCORE_2016 = 0 if AGE_2016 < 50 
replace COMB_WTCORE_2016 = 0 if COMB_WTCORE_2016 ==. 
count if COMB_WTCORE_2016 ==. 
local years "2004 2006 2010 2012 2014 2018"
foreach x of varlist r*wtresp {
	gettoken sffx years: years 
	rename `x' COMB_WTCORE_`sffx'
	replace COMB_WTCORE_`sffx' = 0 if AGE_`sffx' < 50
	replace COMB_WTCORE_`sffx' = 0 if COMB_WTCORE_`sffx' == .
	label var COMB_WTCORE_`sffx' "Person level analysis weights"
	count if COMB_WTCORE_`sffx' ==. 
} 

* SHARE doesn't have nurse visits so the same weights apply for any physical examinations
* This means that we can generate a nurse weight that is equal to the respondent weight. 
* The idea is that this will make it easier and less error prone when we merge files.  
foreach y in 2004 2006 2010 2012 2014 2016 2018 {
	gen COMB_WTN_`y' = COMB_WTCORE_`y'
	label var COMB_WTN_`y' "Person-level nurse weights"
}

* Total number of sweeps participated in since 2004 
egen TOTALSWEEPS_CORE = rowtotal(SVY_CORE_2004 SVY_CORE_2006 SVY_CORE_2010 ///
								 SVY_CORE_2012 SVY_CORE_2014 SVY_CORE_2016 ///
								 SVY_CORE_2018)
egen TOTALSWEEPS_NURSE = rowtotal(SVY_N_2004 SVY_N_2006 SVY_N_2010 SVY_N_2012 ///
								  SVY_N_2014 SVY_N_2016 SVY_N_2018)

drop r*iwstat r*wtsamp rapsu1 rapsu2 raestrat1 raestrat2 h*cpl r*iwy r*iwm rabmonth ///
	 radyear radmonth r*agem r*mpart rabplace racitizen r*nhmliv r*obese r*drink* ///
	 r*smokev r*smoken r*walkcomp r*gripcomp r*grippos r*griprsta r*gripeff ral*wthh ///
	 r*wthh r*vgactx r*mdactx r*rxdiab r*rxhchol r*wspeed AGE_FIRST* r*walkaid 

mdesc

* Ammend file path
save "share_prep.dta", replace
