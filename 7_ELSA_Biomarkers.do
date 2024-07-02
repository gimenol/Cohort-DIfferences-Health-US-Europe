/*==============================================================================   						
SUPPLEMENTARY ANALYSIS USING ELSA BIOMARKERS

Here we re-run models using ELSA biomarker data - this file contains code to 
analyse the data and graph the results.

Author: Laura Gimeno
================================================================================*/ 

use "long_form_ipws.dta", clear

keep if study == 2 
keep if year == 2004 | year == 2008 | year == 2012 | year == 2016
gen fpc2 = 0

* To simplify analyses, just keep variables that we actually need
keep id pnum year svy_n comb_psu1 comb_strat1 comb_wtn tot_wtn elsa*bldwt resp_w50 fpc2 ///
	 gender birthyear cohort age ///
	 bldchol sys_bp dia_bp hba1c ///
	 meds_chol meds_diab meds_hibp

* Generating indicator for diabetes based on HbA1c adjusting for medication 
tab hba1c, m 
recode hba1c min/-1 =. // recode to missing 
replace hba1c = (hba1c/10.929) + 2.15 if year > 2010 // convert IFCC units to DCCT units
gen hba1c_diabetic = hba1c 
replace hba1c_diabetic = hba1c + 1 if meds_diab == 1  
recode hba1c_diabetic min/6.4 = 0 6.5/max = 1 
lab define hba1clab 0 "HbA1c < 6.5% adjusting for meds" 1 "HbA1c >= 6.5% adjusting for meds"
lab val hba1c_diabetic hba1clab
tab hba1c_diabetic, m // this is where weights are going to be important 
lab var hba1c_diabetic "Accounting for med by +1%"

gen hba1c_diabetic2 = 0 
replace hba1c_diabetic2 = 1 if hba1c >= 6.5 
replace hba1c_diabetic2 = 1 if meds_diab == 1 
replace hba1c_diabetic2 =. if hba1c ==. 
tab hba1c_diabetic2, m
lab var hba1c_diabetic "Accounting for med by changing classification group"

* Generating indicator for high cholesterol based on blood total cholesterol 
tab bldchol, m 
recode bldchol min/-1 =. // recode to missing 

gen bldchol_high = bldchol
recode bldchol_high min/199 = 0 200/max = 1 
replace bldchol_high = 1 if meds_chol == 1 
lab define chollab 0 "Total chol < 200 (normal)" 1 "Total chol >= 200 (high)"
lab val bldchol_high chollab
tab bldchol_high, m 
lab var bldchol_high "Accounting for med by changing classification group"

* Generating indicator for high blood pressure 
tab dia_bp 
tab sys_bp

gen bldpressure_high =. 
replace bldpressure_high = 1 if sys_bp >= 140 | dia_bp >= 90 
replace bldpressure_high = 0 if sys_bp < 140 & dia_bp < 90 
replace bldpressure_high = 1 if meds_hibp == 1 
lab define bplab 0 "Normal BP" 1 "Measured high BP or on meds"
lab val bldpressure_high bplab 
tab bldpressure_high, m 
lab var bldpressure_high "Accounting for med by changing classification group and conservative approach to missingness"

gen bldpressure_high2 =. 
replace bldpressure_high2 = 1 if sys_bp >= 140 | dia_bp >= 90 
replace bldpressure_high2 = 0 if sys_bp < 140 & dia_bp < 90 
replace bldpressure_high2 = 0 if sys_bp < 140 & dia_bp ==.
replace bldpressure_high2 = 0 if dia_bp < 90 & sys_bp ==. 
replace bldpressure_high2 = 1 if meds_hibp == 1 
lab val bldpressure_high2 bplab 
tab bldpressure_high2, m 
lab var bldpressure_high2 "Accounting for med by changing classification group and less conservative approach to missingness"

gen sys_bp_meds = sys_bp
gen dia_bp_meds = dia_bp 
replace sys_bp_meds = sys_bp + 10 if meds_hibp == 1 
replace dia_bp_meds = dia_bp + 10 if meds_hibp == 1
gen bldpressure_high3 = . 
replace bldpressure_high3 = 1 if sys_bp_meds >= 140 | dia_bp_meds >= 90 
replace bldpressure_high3 = 0 if sys_bp_meds < 140 & dia_bp_meds < 90 
replace bldpressure_high3 = 0 if sys_bp_meds < 140 & dia_bp_meds ==. 
replace bldpressure_high3 = 0 if dia_bp_meds < 90 & sys_bp_meds ==. 
lab val bldpressure_high3 bplab 
tab bldpressure_high3, m 
lab var bldpressure_high3 "Accounting for med +10mmHg and less conservative approach to missingness"

* Generating a weight that multiplies cross-sectional weight for blood samples with IPW truncated at 50 
gen tot_bldwt = resp_w50 * elsa_bldwt

* Create a spreadsheet holding information on results for each outcome 
putexcel set "elsa_biomarkers.xlsx", replace open
putexcel A1 = "outcome" B1 = "exposure" C1 = "coef" D1 = "coef_se" E1 = "lcl" F1 = "ucl"
local row = 2 

global biomarkers hba1c_diabetic hba1c_diabetic2 bldchol_high

foreach biomarker in $biomarkers {
	
	* Set the data 
	svyset comb_psu1 [pw = tot_bldwt], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc2) || pnum 

	* Perform regression with group 3 as reference group
	svy, subpop(if svy_n == 1) eform: glm `biomarker' ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

	* Export the relevant results as transposed matrix 
	mat temp = r(table)'
	mat results = temp[1..5, "b"], temp[1..5, "se"], temp[1..5, "ll"], temp[1..5, "ul"]

	* Populate Excel sheet with the RRs and SEs from the transposed matrix 
	putexcel C`row' = matrix(results)

	* Populate other columns with information on exposure
	foreach i of numlist 1/5 {
		local row_num = `row' + `i' - 1 // get row number 
		if `i' == 1 {
			global exp_name "<1925"
		}
		if `i' == 2 {
			global exp_name "1925-35"
		} 
		if `i' == 3 {
			global exp_name "1936-45"
		}
		if `i' == 4 {
			global exp_name "1946-54"
		}
		if `i' == 5 {
			global exp_name "1955-59"
		}		
		putexcel A`row_num' = ("`biomarker'")
		putexcel B`row_num' = ("${exp_name}")
		}
	local row = `row' + 5 // update row number for next outcome/country 

} // end of outcome loop 

global bloodpressure bldpressure_high bldpressure_high2 bldpressure_high3  

foreach bloodpressure in $bloodpressure {
	
	* Set the data 
	svyset comb_psu1 [pw = tot_wtn], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc2) || pnum 

	* Perform regression with group 3 as reference group
	svy, subpop(if svy_n == 1) eform: glm `bloodpressure' ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

	* Export the relevant results as transposed matrix 
	mat temp = r(table)'
	mat results = temp[1..5, "b"], temp[1..5, "se"], temp[1..5, "ll"], temp[1..5, "ul"]

	* Populate Excel sheet with the RRs and SEs from the transposed matrix 
	putexcel C`row' = matrix(results)

	* Populate other columns with information on exposure
	foreach i of numlist 1/5 {
		local row_num = `row' + `i' - 1 // get row number 
		if `i' == 1 {
			global exp_name "<1925"
		}
		if `i' == 2 {
			global exp_name "1925-35"
		} 
		if `i' == 3 {
			global exp_name "1936-45"
		}
		if `i' == 4 {
			global exp_name "1946-54"
		}
		if `i' == 5 {
			global exp_name "1955-59"
		}		
		putexcel A`row_num' = ("`bloodpressure'")
		putexcel B`row_num' = ("${exp_name}")
		}
	local row = `row' + 5 // update row number for next outcome/country 

} // end of outcome loop 

putexcel close 

* Generate the graphs 
import excel "elsa_biomarkers.xlsx", firstrow clear

sleep 2000 // pauses sync to OneDrive 

fre exposure
gen ordercohort =.
recode ordercohort (.=5) if exposure == "<1925"
recode ordercohort (.=4) if exposure == "1925-35"
recode ordercohort (.=2) if exposure == "1946-54"
recode ordercohort (.=1) if exposure == "1955-59"
label def ordercohort 5 "Pre 1925" 4 "1925-35" 3 "1936-45" 2 "1946-54" 1 "1955-59" 
label val ordercohort ordercohort
fre ordercohort

drop if ordercohort ==. 

fre outcome 
encode outcome, gen(out)
fre out 

forval j = 1/6 {
	if `j' == 1 {
		global title_name "High chol and meds"
	}
	if `j' == 2 {
		global title_name "BP cons and meds"
	}
	if `j' == 3 {
		global title_name "BP non cons and meds"
	}
	if `j' == 4 {
		global title_name "BP non cons and 10mmHg meds"
	}
	if `j' == 5 {
		global title_name "Hba1c and 1% meds"
	}	
	if `j' == 6 {
		global title_name "HbA1c and meds"
	}
	
	preserve 
	keep if out == `j' 
	twoway (rcapsym lcl ucl ordercohort, horizontal lstyle(ci) lcolor(eltblue*1.75%30) lwidth(vthick) msize(vtiny) mcolor(%0)) || ///
       (scatter ordercohort coef, xline(1, lstyle(foreground) lpattern(dash)) ///
       leg(off) msymbol(O) mcolor(eltblue*1.75)), ///
       ytitle("Cohort") ylabel(1 "1955-59" 2 "1946-54" 3 "1936-46" 4 "1925-35" 5 "<1925", angle(horizontal)) ///
	   xtitle("Risk Ratio")  ///
       graphregion(color(white)) title("${title_name}") || ///
	   scatteri 3 1, msymbol(O) mcolor(black) text(3 1.1 "(Ref.)")
	graph save "Biomarker_${title_name}.gph", replace
	restore
	}
	