/*==============================================================================
EXTRACTION OF VARIABLES FROM THE ELSA HARMONISED DATASET 

The purpose of this script is to use extract variables that are relevant to the 
analysis from the ELSA harmonised dataset. These will later be merged  with
additional information from ELSA on biomarkers, downloaded from the UK Data 
Service.

Author: Laura Gimeno
==============================================================================*/ 

set maxvar 32767 

* Ammend file path here 
use "H_ELSA_g2.dta", clear

count // 19,802 

describe 
local 	no_vars = `r(k)'
di 		"`no_vars'"  // 10,535 

keep 	idauniq s*idauniq inw* r*strat r*clust r*cwtresp r*scwtresp r*nwtresp r*npwtresp h*cpl ///
		r*iwindm r*iwindy r*wnrsm r*wnrsy rabyear radyear r*agey ragender raracem ///
		raeducl r*mstat r*mpart r*mstath rabplace r*nhmliv r*shlt r*adltot_e r*adltotm_e ///
		r*adltota_e r*iadlfour r*iadlfourm r*iadlfoura r*mobilsev r*mobilsevm r*mobilseva ///
		r*hibpe r*diabe r*cancre r*lunge r*hearte r*chole r*rxhibp r*rxdiab r*rxhchol radiagdiab ///
		radiagcancr r*vgactx_e r*mdactx_e r*ltactx_e r*drink r*drinkd_e r*drinkn_e r*drinkwn_e ///
		r*smokev r*smoken r*smokef r*child r*mbmi r*mbmicat r*systo r*diasto r*bpcomp r*bpact30 ///
		r*gripcomp r*grippos r*griprsta r*wspeed r*walkcomp r*walkaid r*cohort_e ///
		r*scwtresp inw*sc inw*n r*gripsum r*walkaid r*mheight r*weight r*proxy

* Ammend file path here 
save "elsa_harmo.dta", replace
