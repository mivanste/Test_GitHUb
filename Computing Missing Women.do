set more off
clear all

global graphs "C:\Users\milan\Documents\Uni\UCL\How to measure women overmortality\Empirical work\Figures"
global datasource "C:\Users\milan\Documents\Uni\UCL\How to measure women overmortality\Empirical work\Datasources"

use "$datasource\panel91"


					*** DATA CLEANING ***

keep if slabel2 == "Uttar Pradesh" | slabel2 == "Kerala"
replace slabel2 ="uttarp" if slabel2 == "Uttar Pradesh"
replace slabel2 ="kerala" if slabel2 == "Kerala"
rename slabel2 state

collapse (sum) pop*, by(state)

** create female population variables **
foreach year in 6 7 8 9 {
	foreach age in 00 05 10 15 20 25 {
		gen pop`age'f`year'=pop`age'`year'-pop`age'm`year'
	}
}

** create age groups ** 
foreach year in 6 7 8 9 {
	gen pop4_14_`year'= pop05`year' + pop10`year'
	gen pop4_14_m_`year' = pop05m`year' + pop10m`year'
	gen pop4_14_f_`year' = pop05f`year' + pop10f`year'

	gen pop15_24_`year'= pop15`year' + pop20`year'
	gen pop15_24_m_`year' = pop15m`year' + pop20m`year'
	gen pop15_24_f_`year' = pop15f`year' + pop20f`year'	

	gen pop25_34_`year'= pop25`year'
	gen pop25_34_m_`year' = pop25m`year'
	gen pop25_34_f_`year' = pop25f`year'

}

reshape long pop4_14_ pop15_24_ pop25_34_, i(state) j(year)

keep state year pop4_14_* pop15_24_* pop25_34_*

** create cohorts ** 
foreach sex in m f {
	gen cohort1_`sex' = pop4_14_`sex'_6
		replace cohort1_`sex' = pop15_24_`sex'_7 if year == 7
		replace cohort1_`sex' = pop25_34_`sex'_8 if year == 8 
		replace cohort1_`sex' = . if year == 9

	gen cohort2_`sex' = pop4_14_`sex'_7
		replace cohort2_`sex' = pop15_24_`sex'_8 if year == 8
		replace cohort2_`sex' = pop25_34_`sex'_9 if year == 9 
		replace cohort2_`sex' = . if year == 6
}

keep cohort* year state

** To see how the sex ratio evolved following cohorts ** 
foreach number in 1 2 {
	gen sexratio_`number' = (cohort`number'_f / cohort`number'_m) * 100
}

label define YEAR 6 "1961" 7 "1971" 8 "1981" 9 "1991"
label values year YEAR
foreach i in 1 2 {
	label variable sexratio_2 "Sex ratio"
}

cd "$graphs"
twoway (line sexratio_1 year), by (state) yline (100)
	graph export "Evolution of sex-ratio, first cohort.png", replace
twoway (line sexratio_2 year), by (state) yline (100)
	graph export "Evolution of sex-ratio, second cohort.png", replace
* CHECK GRAPH COMBINE AND LABEL VARIABLE SEX RATIO AND VALUES YEAR

