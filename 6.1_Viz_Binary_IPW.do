/*==============================================================================
DATA VISUALISATION OF META-ANALYSED RESULTS FOR BINARY OUTCOMES  

This script takes the meta-anlysed results for the binary outcomes and visualises 
them. It runs in two parts. 

Author: Laura Gimeno
================================================================================*/

import excel "MA_results_ipw.xlsx", firstrow clear

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

* for outcomes in SHARE, ELSA and HRS    

foreach j in 1 2 3 4 7 9 10 11 13 {
	if `j' == 1 {
		global title_name "Cancer"
	}
	if `j' == 2 {
		global title_name "Diabetes"
	}
	if `j' == 3 {
		global title_name "Heart problems"
	}
	if `j' == 4 {
		global title_name "High blood pressure"
	}
	if `j' == 5 {
		global title_name "High cholesterol"
	}
	if `j' == 6 {
		global title_name "High measured BP"
	}
	if `j' == 7 {
		global title_name "Lung Disease"
	}
	if `j' == 8 {
		global title_name "Measured obesity"
	}
	if `j' == 9 {
		global title_name "Mild disability"
	}
	if `j' == 10 {
		global title_name "Mobility limitation"
	}
	if `j' == 11 {
		global title_name "Moderate disability"
	}
	if `j' == 12 {
		global title_name "Self-reported obesity"
	}
	if `j' == 13 {
		global title_name "Severe disability"
	}

preserve 
keep if out == `j'
twoway (rcapsym lower_ci upper_ci offset_ordercohort if Region == "USA", ///
			horizontal lstyle(ci) lcolor(purple) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "USA", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msize(medlarge) msymbol(O) mcolor(purple)) || ///
	   (rcapsym lower_ci upper_ci offset_ordercohort if Region == "England", ///
			horizontal lstyle(ci) lcolor(cranberry) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "England", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(cranberry)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Western Europe", ///
			horizontal lstyle(ci) lcolor(ebblue*1.75) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Western Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
       leg(off) msymbol(O) msize(medlarge) mcolor(ebblue*1.75)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Northern Europe", ///
			horizontal lstyle(ci) lcolor(midgreen) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Northern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(midgreen)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Southern Europe", ///
			horizontal lstyle(ci) lcolor(orange) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Southern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(orange)), ///
       ytitle("") /// 
	   ylabel(1 "SE" 3 "NE" 5 "WE" 7 "UK" 9 "US", nogrid angle(horizontal) labsize(medlarge)) ///
	   xtitle("Risk Ratio", size(medlarge))  ///
	   xlabel(,labsize(medlarge)) ///
	   xsize(3.5) ysize(5) ///
       graphregion(color(white)) title("") || ///
	   scatteri 9 1, msymbol(O) msize(medlarge) mcolor(purple) || ///
	   scatteri 7 1, msymbol(O) msize(medlarge) mcolor(cranberry) || ///
	   scatteri 5 1, msymbol(O) msize(medlarge) mcolor(ebblue*1.75) || ///
	   scatteri 3 1, msymbol(O) msize(medlarge) mcolor(midgreen) || ///
	   scatteri 1 1, msymbol(O) msize(medlarge) mcolor(orange)
graph save "${title_name}.gph", replace
graph export "${title_name}.svg", replace
restore 	   
} 

* For outcomes in ELSA and SHARE only 

preserve 
keep if out == 5 
twoway (rcapsym lower_ci upper_ci offset_ordercohort if Region == "England", ///
			horizontal lstyle(ci) lcolor(cranberry) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "England", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(cranberry)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Western Europe", ///
			horizontal lstyle(ci) lcolor(ebblue*1.75) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Western Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(ebblue*1.75)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Northern Europe", ///
			horizontal lstyle(ci) lcolor(midgreen) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Northern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(midgreen)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Southern Europe", //
			horizontal lstyle(ci) lcolor(orange) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Southern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(orange)), ///
       ytitle("") /// 
	   ylabel(1 "SE" 3 "NE" 5 "WE" 7 "UK" 9 "US", nogrid angle(horizontal) labsize(medlarge)) ///
	   xtitle("Risk Ratio", size(medlarge))  ///
	   xlabel(,labsize(medlarge)) ///
	   xsize(3.5) ysize(5) ///
       graphregion(color(white)) title("") || ///
	   scatteri 7 1, msymbol(O) msize(medlarge) mcolor(cranberry) || ///
	   scatteri 5 1, msymbol(O) msize(medlarge) mcolor(ebblue*1.75) || ///
	   scatteri 3 1, msymbol(O) msize(medlarge) mcolor(midgreen) || ///
	   scatteri 1 1, msymbol(O) msize(medlarge) mcolor(orange)
graph save "cholesterol.gph", replace
graph export "cholesterol.svg", replace
restore 	   

* For outcomes only in HRS and SHARE 
preserve 
keep if out == 12
twoway (rcapsym lower_ci upper_ci offset_ordercohort if Region == "USA", ///
			horizontal lstyle(ci) lcolor(purple) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "USA", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msize(medlarge) msymbol(O) mcolor(purple)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Western Europe", ///
			horizontal lstyle(ci) lcolor(ebblue*1.75) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Western Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(ebblue*1.75)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Northern Europe", ///
			horizontal lstyle(ci) lcolor(midgreen) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Northern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(midgreen)) || ///
       (rcapsym lower_ci upper_ci offset_ordercohort if Region == "Southern Europe", ///
			horizontal lstyle(ci) lcolor(orange) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "Southern Europe", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(orange)), ///
       ytitle("") /// 
	   ylabel(1 "SE" 3 "NE" 5 "WE" 7 "UK" 9 "US", nogrid angle(horizontal) labsize(medlarge)) ///
	   xtitle("Risk Ratio", size(medlarge))  ///
	   xlabel(,labsize(medlarge)) ///
	   xsize(3.5) ysize(5) ///
       graphregion(color(white)) title("") || ///
	   scatteri 9 1, msymbol(O) msize(medlarge) mcolor(purple) || ///
	   scatteri 5 1, msymbol(O) msize(medlarge) mcolor(ebblue*1.75) || ///
	   scatteri 3 1, msymbol(O) msize(medlarge) mcolor(midgreen) || ///
	   scatteri 1 1, msymbol(O) msize(medlarge) mcolor(orange)
graph save "sr_obesity.gph", replace
graph export "sr_obesity.svg", replace
restore 	   

* For outcomes only in HRS and ELSA

foreach j in 6 8 {
	if `j' == 1 {
		global title_name "Cancer"
	}
	if `j' == 2 {
		global title_name "Diabetes"
	}
	if `j' == 3 {
		global title_name "Heart problems"
	}
	if `j' == 4 {
		global title_name "High blood pressure"
	}
	if `j' == 5 {
		global title_name "High cholesterol"
	}
	if `j' == 6 {
		global title_name "High measured BP"
	}
	if `j' == 7 {
		global title_name "Lung Disease"
	}
	if `j' == 8 {
		global title_name "Measured obesity"
	}
	if `j' == 9 {
		global title_name "Mild disability"
	}
	if `j' == 10 {
		global title_name "Mobility limitation"
	}
	if `j' == 11 {
		global title_name "Moderate disability"
	}
	if `j' == 12 {
		global title_name "Self-reported obesity"
	}
	if `j' == 13 {
		global title_name "Severe disability"
	}
	
preserve 
keep if out== `j'
twoway (rcapsym lower_ci upper_ci offset_ordercohort if Region == "USA", ///
			horizontal lstyle(ci) lcolor(purple) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "USA", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msize(medlarge) msymbol(O) mcolor(purple)) || ///
	   (rcapsym lower_ci upper_ci offset_ordercohort if Region == "England", ///
			horizontal lstyle(ci) lcolor(cranberry) lwidth(medthick) msymbol(none)) || ///
       (scatter offset_ordercohort OverallEffectSize if Region == "England", ///
			xline(1, lstyle(foreground) lpattern(dash)) ///
			leg(off) msymbol(O) msize(medlarge) mcolor(cranberry)), ///
       ytitle("") /// 
	   ylabel(1 "SE" 3 "NE" 5 "WE" 7 "UK" 9 "US", nogrid angle(horizontal) labsize(medlarge)) ///
	   xtitle("Risk Ratio", size(medlarge))  ///
	   xlabel(,labsize(medlarge)) ///
	   xsize(3.5) ysize(5) ///
       graphregion(color(white)) title("") || ///
	   scatteri 9 1, msymbol(O) msize(medlarge) mcolor(purple) || ///
	   scatteri 7 1, msymbol(O) msize(medlarge) mcolor(cranberry) 
graph save "${title_name}.gph", replace
graph export "${title_name}.svg", replace
restore 	   
} 
