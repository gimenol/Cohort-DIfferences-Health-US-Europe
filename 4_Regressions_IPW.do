/*======================================================================================
UNSTRATIFIED ANALYSIS 

The purpose of this script is to use data from the long format file to run a series of 
unstratified modified Poisson regressions with robust standard errors (one for each 
outcome and each country), and to extract the adjusted RRs and SE from each 
regression. These RRs and SE then populate an Excel spreadsheet, which can be 
meta-analysed.

This script generates two Excel files. One containing grip strength (as the only 
continuous variable), and another containing all other outcomes. The reason for
generating two files is that the meta-anlysis code will differ slightly for each 
spreadsheet (for the binary outcomes RRs will need to be exponentiated but this 
is not the case for the continuous outcome).

Author: Laura Gimeno
======================================================================================*/


* Open dataset 
use "/Users/lauragimeno/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Documents/SHARE ELSA HRS/data/final/long_form_ipws.dta", clear
fpc2 = 0 

*======================================================================================
*For measures in core questionnaire in all studies
*======================================================================================

putexcel set "unstratified_core_ipws.xlsx", replace open
putexcel A1 = "country" B1 = "region" C1 = "outcome" D1 = "exposure" E1 = "coef_unexp" F1 = "coef_se" 
local row = 2 

* Create a variable list for the binary outcomes which require use of core weights
global outcome heart cancer lung chol diab hibp limitation mild_disability mod_disability sev_disability 

foreach o in $outcome {
	
forval j = 1/13 {
	
* Set svy data 
svyset comb_psu1 [pw = tot_wtcore], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc2) || pnum 

* Assign labels to the countries 
if `j' == 1 {
	global country_name = "USA"
	global region_name = "USA"
}
if `j' == 2 {
	global country_name = "England"
	global region_name = "England"
}
if `j' == 3 {
	global country_name = "Austria"
	global region_name = "Western Europe"
}
if `j' == 4 {
	global country_name = "Germany"
	global region_name = "Western Europe"
}
if `j' == 5 {
	global country_name = "Sweden"
	global region_name = "Northern Europe"
}
if `j' == 6 {
	global country_name = "Netherlands"
	global region_name = "Western Europe"
}                                           
if `j' == 7 {
	global country_name = "Spain"
	global region_name = "Southern Europe"
}
if `j' == 8 {
	global country_name = "Italy"
	global region_name = "Southern Europe"
} 
if `j' == 9 {
	global country_name = "France"
	global region_name = "Western Europe"
}
if `j' == 10 {
	global country_name = "Denmark"
	global region_name = "Northern Europe"
}
if `j' == 11 {
	global country_name = "Greece"
	global region_name = "Southern Europe"
}
if `j' == 12 {
	global country_name = "Switzerland"
	global region_name = "Western Europe"
}
if `j' == 13 {
	global country_name = "Belgium"
	global region_name = "Western Europe"
}

* use group 3 as the reference group as it contains the mean year of birth   
svy, subpop(if svy_core == 1 & country == `j'): glm `o' ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* Export the relevant results as transposed matrix 
mat temp = r(table)'
mat results = temp[1..5, "b"], temp[1..5, "se"]

* Populate Excel sheet with the RRs and SEs from the transposed matrix 
putexcel E`row' = matrix(results)

* Now we want to fill in the other rows of the table with the names of the country, level and outcome

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
	putexcel D`row_num' = ("${exp_name}")
		
	putexcel A`row_num' = ("${country_name}")
	
	putexcel C`row_num' = ("`o'")
	
	putexcel B`row_num' = ("${region_name}")
	}

local row = `row' + 5 // update row number for next outcome/country 

} // end of country loop

} // end of outcome loop 

*======================================================================================
* For SR obesity, which is only measured in HRS and SHARE 
*======================================================================================

foreach j in 1 3 4 5 6 7 8 9 10 11 12 13 {
	
* Set svy data 
svyset comb_psu1 [pw = tot_wtcore], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc2) || pnum

* Assign labels to the countries 
if `j' == 1 {
	global country_name = "USA"
	global region_name = "USA"
}
if `j' == 3 {
	global country_name = "Austria"
	global region_name = "Western Europe"
}
if `j' == 4 {
	global country_name = "Germany"
	global region_name = "Western Europe"
}
if `j' == 5 {
	global country_name = "Sweden"
	global region_name = "Northern Europe"
}
if `j' == 6 {
	global country_name = "Netherlands"
	global region_name = "Western Europe"
}                                           
if `j' == 7 {
	global country_name = "Spain"
	global region_name = "Southern Europe"
}
if `j' == 8 {
	global country_name = "Italy"
	global region_name = "Southern Europe"
} 
if `j' == 9 {
	global country_name = "France"
	global region_name = "Western Europe"
}
if `j' == 10 {
	global country_name = "Denmark"
	global region_name = "Northern Europe"
}
if `j' == 11 {
	global country_name = "Greece"
	global region_name = "Southern Europe"
}
if `j' == 12 {
	global country_name = "Switzerland"
	global region_name = "Western Europe"
}
if `j' == 13 {
	global country_name = "Belgium"
	global region_name = "Western Europe"
}
																							
svy, subpop(if svy_core == 1 & country == `j'): glm obese_sr ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* Export the relevant results as transposed matrix 
mat temp = r(table)'
mat results = temp[1..5, "b"], temp[1..5, "se"]

* Populate Excel sheet with the RRs and SEs from the transposed matrix 
putexcel E`row' = matrix(results)

* Now we want to fill in the other rows of the table with the names of the country, level and outcome

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
	putexcel C`row_num' = ("obese_sr")
		
	putexcel A`row_num' = ("${country_name}")
	
	putexcel B`row_num' = ("${region_name}")
	
	putexcel D`row_num' = ("${exp_name}")
}

local row = `row' + 5 // update row number for next outcome/country 

} // end of country loop 

*======================================================================================
*For measured obesity and measured BP which are only collected in HRS and ELSA
*======================================================================================

* Create variable list for binary outcomes which require use of nurse weights 
global outcome obese_msred hibpm // hiptreat

foreach o in $outcome {
	
forval j = 1/2 {
	
* Set svy data 
svyset comb_psu1 [pw = tot_wtn], strata(comb_strat1) vce(robust) singleunit(centered) fpc(fpc2) || pnum

* Assign labels to the countries 
if `j' == 1 {
	global country_name = "USA"
	global region_name = "USA"
}
if `j' == 2 {
	global country_name = "England"
	global region_name = "England"
}
							
svy, subpop(if svy_n == 1 & country == `j'): glm `o' ib3.cohort c.age c.age#c.age i.gender, fam(poisson) link(log)

* Export the relevant results as transposed matrix 
mat temp = r(table)'
mat results = temp[1..5, "b"], temp[1..5, "se"]

* Populate Excel sheet with the RRs and SEs from the transposed matrix 
putexcel E`row' = matrix(results)

* Now we want to fill in the other rows of the table with the names of the country, level and outcome

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
	putexcel D`row_num' = ("${exp_name}")
		
	putexcel A`row_num' = ("${country_name}")
	
	putexcel C`row_num' = ("`o'")
	
	putexcel B`row_num' = ("${region_name}")
}

local row = `row' + 5 // update row number for next outcome/country 

} // end of country loop

} // end of outcome loop 

putexcel save 

*======================================================================================
*For grip strength which is measured in all three studies and is a continuous variable
*======================================================================================

gen bmi = bmi_sr 
replace bmi = bmi_msred if study == 2 

putexcel set "continuous_unstrat_ipw.xlsx", open replace 
putexcel A1 = "country" B1 = "region" C1 = "outcome" D1 = "exposure" E1 = "coef_unexp" F1 = "coef_se" 
local row = 2 

forval j = 1/13 {
	
* Set svy data 
svyset comb_psu1 [pw = tot_wtn], strata(comb_strat1) singleunit(centered) fpc(fpc2) || pnum

* Assign labels to the countries 
if `j' == 1 {
	global country_name = "USA"
	global region_name = "USA"
}
if `j' == 2 {
	global country_name = "England"
	global region_name = "England"
}
if `j' == 3 {
	global country_name = "Austria"
	global region_name = "Western Europe"
}
if `j' == 4 {
	global country_name = "Germany"
	global region_name = "Western Europe"
}
if `j' == 5 {
	global country_name = "Sweden"
	global region_name = "Northern Europe"
}
if `j' == 6 {
	global country_name = "Netherlands"
	global region_name = "Western Europe"
}                                           
if `j' == 7 {
	global country_name = "Spain"
	global region_name = "Southern Europe"
}
if `j' == 8 {
	global country_name = "Italy"
	global region_name = "Southern Europe"
} 
if `j' == 9 {
	global country_name = "France"
	global region_name = "Western Europe"
}
if `j' == 10 {
	global country_name = "Denmark"
	global region_name = "Northern Europe"
}
if `j' == 11 {
	global country_name = "Greece"
	global region_name = "Southern Europe"
}
if `j' == 12 {
	global country_name = "Switzerland"
	global region_name = "Western Europe"
}
if `j' == 13 {
	global country_name = "Belgium"
	global region_name = "Western Europe"
}

* We additionally adjust for height here 
svy, subpop(if svy_n == 1 & country == `j'): regress grip ib3.cohort c.age c.age#c.age i.gender c.bmi 

* Export the relevant results as transposed matrix 
mat temp = r(table)'
mat results = temp[1..5, "b"], temp[1..5, "se"]

* Populate Excel sheet with the RRs and SEs from the transposed matrix 
putexcel E`row' = matrix(results)

* Now we want to fill in the other rows of the table with the names of the country, level and outcome

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
	putexcel D`row_num' = ("${exp_name}")
		
	putexcel A`row_num' = ("${country_name}")
	
	putexcel C`row_num' = ("grip")
	
	putexcel B`row_num' = ("${region_name}")
}

local row = `row' + 5 // update row number for next outcome/country 

} // end of country loop 

forval j = 1/13 {
	
* Set svy data 
svyset comb_psu1 [pw = tot_wtn], strata(comb_strat1) singleunit(centered) fpc(fpc2) || pnum

* Assign labels to the countries 
if `j' == 1 {
	global country_name = "USA"
	global region_name = "USA"
}
if `j' == 2 {
	global country_name = "England"
	global region_name = "England"
}
if `j' == 3 {
	global country_name = "Austria"
	global region_name = "Western Europe"
}
if `j' == 4 {
	global country_name = "Germany"
	global region_name = "Western Europe"
}
if `j' == 5 {
	global country_name = "Sweden"
	global region_name = "Northern Europe"
}
if `j' == 6 {
	global country_name = "Netherlands"
	global region_name = "Western Europe"
}                                           
if `j' == 7 {
	global country_name = "Spain"
	global region_name = "Southern Europe"
}
if `j' == 8 {
	global country_name = "Italy"
	global region_name = "Southern Europe"
} 
if `j' == 9 {
	global country_name = "France"
	global region_name = "Western Europe"
}
if `j' == 10 {
	global country_name = "Denmark"
	global region_name = "Northern Europe"
}
if `j' == 11 {
	global country_name = "Greece"
	global region_name = "Southern Europe"
}
if `j' == 12 {
	global country_name = "Switzerland"
	global region_name = "Western Europe"
}
if `j' == 13 {
	global country_name = "Belgium"
	global region_name = "Western Europe"
}

* We additionally adjust for height here 
svy, subpop(if svy_n == 1 & country == `j'): regress grip ib3.cohort c.age c.age#c.age i.gender c.height c.weight

* Export the relevant results as transposed matrix 
mat temp = r(table)'
mat results = temp[1..5, "b"], temp[1..5, "se"]

* Populate Excel sheet with the RRs and SEs from the transposed matrix 
putexcel E`row' = matrix(results)

* Now we want to fill in the other rows of the table with the names of the country, level and outcome

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
	putexcel D`row_num' = ("${exp_name}")
		
	putexcel A`row_num' = ("${country_name}")
	
	putexcel C`row_num' = ("grip_hw")
	
	putexcel B`row_num' = ("${region_name}")
}

local row = `row' + 5 // update row number for next outcome/country 

} // end of country loop 

putexcel save 
