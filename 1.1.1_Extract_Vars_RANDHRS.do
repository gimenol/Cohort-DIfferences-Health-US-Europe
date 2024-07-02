/*==============================================================================
EXTRACTION OF VARIABLES FROM THE RAND HRS LONGITUDINAL FILE 

The purpose of this script is to use extract variables that are relevant to the 
analysis from the RAND HRS longitudinal file. This will then be merged with the 
harmonised variables available in the harmonised HRS files and the weights from
the core files for 2016 and 2018. 

Author:	Laura Gimeno
==============================================================================*/ 

set	maxvar 32767

* Ammend file path here 
use "randhrs1992_2018v2.dta", clear

count // 42,233 observations 

describe 
local	no_vars = `r(k)'
di 		"`no_vars'" // 15019 variables 

keep 	hhidpn s*hhidpn ragender r*mstat r*mpart inw* r*mnev r*mstath r*agey_b ///
		r*agey_e r*agey_m r*shlt r*shltc r*smokev r*smoken r*vgactx r*mdactx ///
		r*ltactx r*diab r*diabe r*diabs r*hibpe r*cancre r*lunge r*hearte h*child ///
		raevbrn rabyear rawtsamp r*wtresp r*wtr_nh r*wtcrnh raracem radmonth ///
		radyear radage_m radage_y raddate r*drink r*drinkr r*drinkn r*drinkd ///
		raestrat raehsamp r*wthh r*bmi racohbyr r*height r*weight r*proxy

describe 
local 	no_vars = `r(k)'
di 		"`no_vars'" 

* Ammend file path here 
save "RANDvars.dta", replace
