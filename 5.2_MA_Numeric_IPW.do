/*==============================================================================   						
META-ANALYSIS FOR CONTINUOUS OUTCOMES

The purpose of this code is to meta-analyse regression results from each country 
to obtain statistically pooled coefficients and SE from linear regressions 
for grip strength. 

Inputs are Excel spreadsheets containing linear regression coefficients and 
SE for grip strength at each exposure level.

This code takes two Excel files as inputs: one from stratified analyses and another 
from unstratified analyses. It outputs two Excel files: one containing meta-analysed
results from unstratified analyses, and another from stratified analyses.

Author: Laura Gimeno
================================================================================*/ 

* ssc install fre
* ssc istall metan

*===============================================================================
* META-ANALYSIS OF UNSTRATIFIED REGRESSION COEFFICIENTS 
*===============================================================================

* Importing the excel file which contains the data to meta-analyse
import excel "continuous_unstrat_ipw.xlsx", firstrow clear

	*Not really needed here as only have one outcome
	encode outcome, gen(out)
	fre out 
	drop if out ==. 
	
	encode exposure, gen(exp)
	fre exp 
	drop  if exp == 2 // drop baseline
	 
	encode region, gen(area) 
	fre(area)
	 
	* ordering the countries so output is grouped by region
	fre country
	gen orderstudy =. 
	recode orderstudy (.=13) if country =="Spain"
	recode orderstudy (.=12) if country =="Greece"
	recode orderstudy (.=11) if country =="Italy"
	recode orderstudy (.=10) if country =="Belgium"
	recode orderstudy (.=9) if country =="Switzerland"
	recode orderstudy (.=8) if country =="France"
	recode orderstudy (.=7) if country =="Netherlands"
	recode orderstudy (.=6) if country =="Germany"
	recode orderstudy (.=5) if country =="Austria"
	recode orderstudy (.=4) if country =="Sweden"
	recode orderstudy (.=3) if country =="Denmark"
	recode orderstudy (.=2) if country =="England"
	recode orderstudy (.=1) if country =="USA"
	label def orderstudy 1 "USA" 2 "England" 3 "Denmark" 4 "Sweden" 5 "Austria"  ///
						 6 "Germany" 7 "Netherlands" 8 "France" 9 "Switzerland" ///
						 10 "Belgium" 11 "Italy" 12 "Greece" 13 "Spain"
	label val orderstudy orderstudy
	fre orderstudy
	tab country orderstudy
	
	*fre out
	fre exp
	fre orderstudy
	decode orderstudy, gen(Study)
	
	destring coef_unexp coef_se, replace // to numeric  
	
putexcel set "MA_results_con_ipw.xlsx", replace
putexcel A1 = "Model" B1 = "Region" C1 = "Outcome" D1 = "Exposure" E1 = "Overall Effect Size" ///
	F1 = "lower_ci" G1 = "upper_ci" H1 = "I-squared heterogeneity statistic"
local row = 2 // start inputting from this row

foreach outc of numlist 1/2 {
	if `outc' == 1 {
		global out_name "Grip BMI"
	}
	if `outc' == 2 {
	global out_name "Grip HW"
	}
 
foreach area of numlist 1/5 {
		if `area' == 1 {
			global region_name "England"
		}
		if `area' == 2 {
			global region_name "Northern Europe"
		}
		if `area' == 3 {
			global region_name "Southern Europe"
		}
		if `area' == 4 {
			global region_name "USA"
		}
		if `area' == 5 {
			global region_name "Western Europe"
		}

foreach exp of numlist 1/5 {
		
	if `exp' == 5 {
		global exp_name "Pre 1925"
	}
	if `exp' == 1 {
		global exp_name "1925-35"
	}	
	if `exp' == 2 {
		global exp_name "1936-45"
	}		
	if `exp' == 3 {
		global exp_name "1946-54"
	}		
	if `exp' == 4 {
		global exp_name "1955-59"
	}		
		
	meta set coef_unexp coef_se if exp == `exp' & area == `area', studylabel(country) 
	capture noisily meta sum if exp == `exp' & area == `area', random(mle)  
	if _rc == 0 {
		putexcel A`row' = ("Unstratified")
		putexcel B`row' = ("${region_name}")
		putexcel C`row' = ("${out_name}") // only one outcome here but can replace with macro if list
		putexcel D`row' = ("${exp_name}") // gives the level of exposure 
		putexcel E`row' = (`r(theta)') // point estimate
		putexcel F`row' = (`r(ci_lb)') // lower bound
		putexcel G`row' = (`r(ci_ub)') // upper bound
		putexcel H`row' = (`r(I2)') // heterogeneity
		}

	loc row = `row' + 1 // move down to fill in next row of the spreadsheet 	
	
		if `exp' == 2 {
		putexcel A`row' = ("Unstratified")
		putexcel B`row' = ("${region_name}")
		putexcel C`row' = ("grip")
		putexcel D`row' = ("1936-45")  
		putexcel E`row' = ("0")
		
		loc row = `row' + 1 
		}

			
} // end of exposure loop
} // end of region  loop 	

* Now getting the unstratifed variables 

foreach exp of numlist 1/5 {
		
	if `exp' == 5 {
		global exp_name "Pre 1925"
	}
	if `exp' == 1 {
		global exp_name "1925-35"
	}	
	if `exp' == 2 {
		global exp_name "1936-45"
	}		
	if `exp' == 3 {
		global exp_name "1946-54"
	}		
	if `exp' == 4 {
		global exp_name "1955-59"
	}		
		
	meta set coef_unexp coef_se if exp == `exp', studylabel(country) 
	capture noisily meta sum if exp == `exp', random(mle)  
	if _rc == 0 {
		putexcel A`row' = ("Unstratified")
		putexcel B`row' = ("Overall")
		putexcel C`row' = ("${out_name}") // only one outcome here but can replace with macro if list
		putexcel D`row' = ("${exp_name}") // gives the level of exposure 
		putexcel E`row' = (`r(theta)') // point estimate
		putexcel F`row' = (`r(ci_lb)') // lower bound
		putexcel G`row' = (`r(ci_ub)') // upper bound
		putexcel H`row' = (`r(I2)') // heterogeneity
		}
			
		loc row = `row' + 1
			
		if `exp' == 2 {
		putexcel A`row' = ("Unstratified")
		putexcel B`row' = ("Overall")
		putexcel C`row' = ("${out_name}")
		putexcel D`row' = ("1936-45")  
		putexcel E`row' = ("0")
		
		loc row = `row' + 1 
		}
		
} // end of exposure loop
} // end of outcome loop 

putexcel save 
