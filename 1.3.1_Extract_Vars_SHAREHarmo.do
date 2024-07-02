/*==============================================================================
EXTRACTION OF VARIABLES FROM THE SHARE HARMONISED DATASET 

The purpose of this script is to use extract variables that are relevant to the 
analysis from the SHARE harmonised dataset.

Author: Laura Gimeno
==============================================================================*/ 

set maxvar 32767 

* Ammend file path
use "/Users/lauragimeno/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Documents/2-SHARE ELSA HRS Paper/SHARE/share_harmonized/H_SHARE_f.dta", clear

count // 139,620 

describe 
local 	no_vars = `r(k)'
di 		"`no_vars'" // 6385 variables 

keep 	mergeid country inw* r*iwstat r*wtsamp rapsu* raestrat* r*wthh r*wtresp ///
		r*wtrespc h*cpl r*iwm r*iwy rabmonth rabyear r*agey r*agem ragender raeducl ///
		r*mstat r*mpart r*mstath rabplace racitizen r*nhmliv r*shlt r*adltot_s r*adltotm_s ///
		r*adltota_s r*iadlfour r*iadlfourm r*iadlfoura r*mobilsev r*mobilsevm r*mobilseva ///
		r*hibpe r*diabe r*cancre r*lunge r*hearte r*chole radiaghibp radiagdiab radiagcancr ///
		radiaglung radiagheart radiaghchol r*rxhibp r*rxdiab r*rxhchol r*bmi r*bmicat r*obese ///
		r*vgactx r*mdactx r*drinkev r*drink3m r*drinkx r*drinkxw r*drinkn r*smokev r*smoken ///
		r*smokef h*child r*wspeed r*walkaid r*walkcomp r*gripsum r*gripcomp r*grippos r*griprsta ///
		r*gripeff radyear radmonth r*walkaid r*height r*weight r*proxy

* Ammend file path 
save "share_harmo.dta", replace
