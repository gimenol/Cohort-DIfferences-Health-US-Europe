/*==============================================================================
EXTRACTION OF VARIABLES FROM HARMONISED HRS 

The purpose of this script is to use extract variables that are relevant to the 
analysis from the HRS harmonised dataset. This will then be merged with variables
from the RAND HRS longitudinal file and weights from the core files for 2016 and 2018. 

Author: Laura Gimeno 
==============================================================================*/ 

set maxvar 32767 

* Ammend file path here 
use "H_HRS_c.dta", clear

count // 42,233 

describe 
local 	no_vars = `r(k)'
di 		"`no_vars'"

keep 	hhidpn r*nwtresp r*scwtresp r*rxdiab radiagdiab r*rxhibp r*rxbldthn r*systo ///
		r*diasto r*bpcomp r*bparm r*bldpos r*bpcompl r*chole r*rxchol raeducl r*mobilsev ///
		r*mobilsevm r*mobilseva r*iadlfour r*iadlfourm r*iadlfoura r*adltot_h r*adltotm_h ///
		r*adltota_h r*obese r*mobese r*bmicat r*mbmi r*mbmicat r*gripsum r*gripcomp ///
		r*gripeff r*grippos r*handrt r*walkcomp r*walkcompl r*walkaid r*wspeed ///
		r*smokef r*bmi inw*pm 
		
describe 
local 	no_vars = `r(k)'
di 		"`no_vars'"

* Ammend file path here 
save "hrs_harmo.dta", replace

		