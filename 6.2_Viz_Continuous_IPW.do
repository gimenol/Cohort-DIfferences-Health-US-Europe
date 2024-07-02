/*==============================================================================
DATA VISUALISATION OF META-ANALYSED RESULTS FOR CONTINUOUS OUTCOMES  

This script takes the meta-anlysed results for grip strength and visualises 
them. It runs in two parts.

Author: Laura Gimeno
================================================================================*/

import excel "MA_results_con_ipw.xlsx", firstrow clear

sort Outcome Exposure

* Drop empty lines 
egen empty = rowmiss(Model Region Outcome Exposure OverallEffectSize lower_ci upper_ci)
drop if empty > 0
drop empty

fre Outcome 
encode Outcome, gen(out)
fre out 

gen ordercohort =.
recode ordercohort (.=9) if Region == "USA"
recode ordercohort (.=7) if Region == "England"
recode ordercohort (.=5) if Region == "Western Europe"
recode ordercohort (.=3) if Region == "Northern Europe"
recode ordercohort (.=1) if Region == "Southern Europe"
label def ordercohort 5 "US" 4 "UK" 3 "WE" 2 "NE" 1 "SE" 
label val ordercohort ordercohort

fre Exposure
gen offset_ordercohort = ordercohort
replace offset_ordercohort = offset_ordercohort +0.5 if Exposure == "Pre 1925"
replace offset_ordercohort = offset_ordercohort +0.25 if Exposure == "1925-35"
replace offset_ordercohort = offset_ordercohort -0.25 if Exposure == "1946-54"
replace offset_ordercohort = offset_ordercohort -0.5 if Exposure == "1955-59"

destring OverallEffectSize, replace

* Grip strength and BMI 
foreach j in 1 2 {
	if `j' == 1 {
		global title_name "Grip BMI"
	}
	if `j' == 2 {
		global title_name "Grip HW"
	}

preserve 
keep if out == `j'
twoway (rcapsym lower_ci upper_ci offset_ordercohort if Region == "USA", ///
			horizontal lstyle(ci) lcolor(purple) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "USA", ///
			xline(0, lwidth(medthick) lstyle(foreground) lpattern(dash)) ///
			leg(off) msize(medlarge) msymbol(O) mcolor(purple)) || ///
	   (rcapsym lower_ci upper_ci offset_ordercohort if Region == "England", ///
			horizontal lstyle(ci) lcolor(cranberry) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "England", ///
			xline(0, lwidth(medthick) lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(cranberry)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Western Europe", ///
			horizontal lstyle(ci) lcolor(ebblue*1.75) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Western Europe", ///
			xline(0, lwidth(medthick) lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(ebblue*1.75)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Northern Europe", ///
			horizontal lstyle(ci) lcolor(midgreen) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Northern Europe", ///
			xline(0, lwidth(medthick) lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(midgreen)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Southern Europe", ///
			horizontal lstyle(ci) lcolor(orange) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Southern Europe", ///
			xline(0, lwidth(medthick) lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(orange)), ///
       ytitle("") /// 
	   ylabel(1 "SE" 3 "NE" 5 "WE" 7 "UK" 9 "US", nogrid angle(horizontal) labsize(medlarge)) ///
	   xtitle("Risk Ratio", size(medlarge))  ///
	   xlabel(,labsize(medlarge)) ///
	   xsize(3.5) ysize(5) ///
       graphregion(color(white)) title("") || ///
	   scatteri 9 0, msymbol(O) msize(medlarge) mcolor(purple) || ///
	   scatteri 7 0, msymbol(O) msize(medlarge) mcolor(cranberry) || ///
	   scatteri 5 0, msymbol(O) msize(medlarge) mcolor(ebblue*1.75) || ///
	   scatteri 3 0, msymbol(O) msize(medlarge) mcolor(midgreen) || ///
	   scatteri 1 0, msymbol(O) msize(medlarge) mcolor(orange)
graph save "${title_name}.gph", replace
graph export "${title_name}.svg", replace
restore 	   
}
