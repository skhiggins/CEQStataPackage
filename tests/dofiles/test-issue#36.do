/***
	TESTS - ISSUE #36
	Rosie Li
*/

*********
** LOG **
*********
clear all
cd "C:/Users/Rosie/Dropbox/CEQ_ado/"
capture : log close
log using "test-issue#36.log", replace
version 13.0

************
** LOCALS **
************

// Temportal objects
tempfile mwb

// For CEQ commands
#delimit ;
local income_options_SA1
	market(ym_SA1)
	/*mpluspensions(yp_SA1)
	netmarket(yn_SA1)
	gross(yg_SA1)
	disposable(yd_SA1)
	consumable(yc_SA1)
	final(yf_SA1)*/;
local direct_options_SA1
	pensions(pc_contributory_pen)
	dtransfers(
		pc_BolsaFamilia 
		pc_scholarships 
		pc_BPC 
		pc_special_pensions 
		pc_unemployment_ben
		pc_other_transfers
		pc_milk_ben
	)
	dtaxes(
		pc_income_taxes
		pc_property_taxes
	)
	contribs(
		pc_contribs_to_pen
		pc_other_contributions 
		pc_FGTS
	);
local indirect_options
	subsidies(pc_energy_subsidies)
	indtaxes(pc_indirect_taxes);
local inkind_options
	health(pc_health_ben)
	education(
		pc_preschool_educ_ben
		pc_primary_educ_ben
		pc_secondary_educ_ben
		pc_special_educ_ben
		pc_vocational_educ_ben
		pc_tertiary_educ_ben
	);
#delimit cr

**********
** DATA **
**********

use "pof3.dta", clear // available upon request
keep if (yg_SA1 != .)
set seed 2018421
sample 0.1

count
replace pc_energy_subsidies = - pc_energy_subsidies in 1/20

**********
** TEST **
**********

#delimit ;


	ceqmarg_sep5 using "MEX_NAT_Reruns_CEQMWB2017_E13_2011PPP_Feb07_2018.xlsx",
	`income_options_SA1'
	negatives
	ppp(1)
	cpibase(103.15684)
	cpisurvey(108.69572)	
	/*`direct_options_SA1'*/
	`indirect_options'
	/*`inkind_options'*/
	hhid(code_uc);

#delimit cr	



**************
** CLEANING **
**************

// Remove graphs
// foreach type in "direct" "indirect" "inkind" "summary" {
// 	local files : dir "tests/data" files "conc_`type'_*", respectcase
// 	foreach file in `files' {
// 		local myregex = "^(conc_`type')(.)*(\.(gph|png))$"
// 		if regexm(`"`file'"', "`myregex'") {
// 			capture : rm "tests/data/`file'"
// 		}
// 	}
// }

// Close log-file
log close
exit
