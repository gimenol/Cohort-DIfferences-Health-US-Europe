/*==============================================================================
META-ANALYSIS OF BINARY VARIABLES

The purpose of this code is to meta-analyse regression results from each country 
to obtain stratistically pooled Risk Ratios and 95% Confidence Intervals from 
modified Poisson regression with robust standard errors. The inputs are Excel 
spreadsheets containing unexponentiated RR and SE for each outcome, country and 
exposure level. The outputs are Excel files containing the meta-analyses 
exponentiated RRs and 95% CIs. 

This code takes two Excel files as input (one for stratified analyses and the other
for unstratified analyses) and produces two Excel files as output (one for 
stratified analyses and another for unstratified analyses).

Author: Laura Gimeno
==============================================================================*/ 

* ssc install fre
* ssc istall metan

*===============================================================================
* META-ANALYSIS OF UNSTRATIFIED RISK RATIOS 
*===============================================================================

import excel "unstratified_core_ipws.xlsx", firstrow clear 

* encode outcomes
encode outcome, gen(outc)
fre outc 
drop if outc ==. 

* encode exposure	
encode exposure, gen(expo)
fre expo 
drop  if expo == 2 // drop baseline

* encode region 
encode region, gen(area)
fre area
	 
* ordering the countries so output is grouped by region
fre country
gen orderstudy =. 
recode orderstudy (.=13) if country == "Spain"
recode orderstudy (.=12) if country == "Greece"
recode orderstudy (.=11) if country == "Italy"
recode orderstudy (.=10) if country == "Belgium"
recode orderstudy (.=9) if country == "Switzerland"
recode orderstudy (.=8) if country == "France"
recode orderstudy (.=7) if country == "Netherlands"
recode orderstudy (.=6) if country == "Germany"
recode orderstudy (.=5) if country == "Austria"
recode orderstudy (.=4) if country == "Sweden"	
recode orderstudy (.=3) if country == "Denmark"
recode orderstudy (.=2) if country == "England"
recode orderstudy (.=1) if country == "USA"
label def orderstudy 1 "USA" 2 "England" 3 "Denmark" 4 "Sweden" 5 "Austria"  ///
					 6 "Germany" 7 "Netherlands" 8 "France" 9 "Switzerland" ///
					 10 "Belgium" 11 "Italy" 12 "Greece" 13 "Spain"
label val orderstudy orderstudy
fre orderstudy
tab country orderstudy

* check everything is in order
fre outc
fre expo
fre orderstudy
decode orderstudy, gen(Study)
	
destring coef_unexp coef_se, replace // to numeric  
	
putexcel set "MA_results_ipw.xlsx", replace
putexcel A1 = "Model" B1 = "Region" C1 = "Outcome" D1 = "Exposure" E1 = "Overall Effect Size" ///
		 F1 = "lower_ci" G1 = "upper_ci" H1 = "I-squared heterogeneity statistic"
local row = 2 // start inputting from this row
	
foreach outc of numlist 1/15 {  
	if `outc' == 1 {
		global out_name "Cancer"
	}
	if `outc' == 2 {
		global out_name "High cholesterol"
	}
	if `outc' == 3 {
		global out_name "Diabetes"
	}
	if `outc' == 4 {
		global out_name "Heart problems"
	}
	if `outc' == 5 {
		global out_name "High BP"
	}
	if `outc' == 6 {
		global out_name "High measured BP"
	}			
	if `outc' == 7 {
		global out_name "Mobility limitation"
	}
	if `outc' == 8 {
		global out_name "Lung disease"
	}
	if `outc' == 9 {
		global out_name "Mild disability"
	}
	if `outc' == 10 {
		global out_name "Moderate disability"
	}
	if `outc' == 11 {
		global out_name "Measured Obesity"
	}
	if `outc' == 12 {
		global out_name "Self-Reported Obesity"
	}
	if `outc' == 13 {
		global out_name "Severe disability"   
	}
	
	foreach expo of numlist 1/8 {
		
		if `expo' == 5 {
			global exp_name "Pre 1925"
		}
		if `expo' == 1 {
			global exp_name "1925-35"
		}	
		if `expo' == 2 {
			global exp_name "1936-45"
		}		
		if `expo' == 3 {
			global exp_name "1946-54"
		}		
		if `expo' == 4 {
			global exp_name "1955-59"
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
			
		* Random effects meta-analysis transforming into exponentiated RR 
		meta set coef_unexp coef_se if outc == `outc' & expo == `expo' & area == `area', random(mle) studylabel(country) 
		capture noisily meta sum if outc == `outc' & expo == `expo' & area == `area', transform(exp) 
		if _rc == 0 {
			putexcel A`row' = ("Unstratified")
			putexcel B`row' = ("${region_name}") // gives us region name
			putexcel C`row' = ("${out_name}") // gives us outcome name 
			putexcel D`row' = ("${exp_name}") // gives the level of exposure 
			putexcel E`row' = (exp(`r(theta)')) 
			putexcel F`row' = (exp(`r(ci_lb)'))
			putexcel G`row' = (exp(`r(ci_ub)'))
			putexcel H`row' =  `r(I2)'
			}
			
		loc row = `row' + 1 // move down to fill in next row of the spreadsheet 	
		
		if `expo' == 2 {
			putexcel A`row' = ("Unstratified")
			putexcel B`row' = ("${region_name}")
			putexcel C`row' = ("$out_name")
			putexcel D`row' = ("1936-45") 
			putexcel E`row' = ("1") 
		
			loc row = `row' + 1 
		 }
		
	} // end of region loop 
	
		meta set coef_unexp coef_se if outc == `outc' & expo == `expo', studylabel(country) random(mle) // transforming into exponentiated RR 
		capture noisily meta sum if outc == `outc' & expo == `expo', transform(exp)
		if _rc == 0 {
			putexcel A`row' = ("Unstratified")
			putexcel B`row' = ("Overall") // not stratified by region
			putexcel C`row' = ("${out_name}") // gives us outcome name 
			putexcel D`row' = ("${exp_name}") // gives the level of exposure 
			putexcel E`row' = (exp(`r(theta)')) 
			putexcel F`row' = (exp(`r(ci_lb)'))
			putexcel G`row' = (exp(`r(ci_ub)'))
			putexcel H`row' =  `r(I2)'
			}
			
			loc row = `row' + 1 
		
		if `expo' == 2 {
			putexcel A`row' = ("Unstratified")
			putexcel B`row' = ("${region_name}")
			putexcel C`row' = ("$out_name")
			putexcel D`row' = ("1936-45") 
			putexcel E`row' = ("1") 
		
			loc row = `row' + 1 
		}
		
} // end of exposure loop 

} // end of outcome loop 

putexcel close
