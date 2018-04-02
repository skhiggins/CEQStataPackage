/***
	TESTS - ISSUE #24
	do file created by Ivan Gutierrez, ivangutierrez1988@gmail.com
	last revised Apr 1, 2018
*/

*********
** LOG **
*********

capture : log close
log using "tests/logs/test-issue#24.log", text replace
version 13.0
set more off

************
** LOCALS **
************

// Temporal master workbook (mwb)
clear
tempfile mwb
putexcel set "`mwb'.xlsx", replace
putexcel A1 = ("")

// PPP conversion factors
local ppp       = 1.5713184
local cpibase   = 79.560051
local cpisurvey = 95.203354

// CEQ commands options
#delimit ;
local income_options_SA1
	market(ym_SA1)
	mpluspensions(yp_SA1)
	netmarket(yn_SA1)
	gross(yg_SA1)
	disposable(yd_SA1)
	consumable(yc_SA1)
	final(yf_SA1);
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
local ppp_options
	ppp(`ppp')
	cpibase(`cpibase')
	cpisurvey(`cpisurvey')
	baseyear(2005)
	yearly;
#delimit cr

**********
** DATA **
**********

use "tests/data/pof3.dta", clear 
keep if (yg_SA1 != .)
sample 0.1

**********
** TEST **
**********

// #1 - Applied to ceqdom
ceqdom using "`mwb'.xlsx", `income_options_SA1' hhid(code_uc)

// #2 - Applied to ceqdomext
#delimit ;
ceqdomext using "`mwb'.xlsx", 
	`income_options_SA1' 
	`direct_options_SA1'
	`indirect_options'
	`inkind_options'
	hhid(code_uc);
#delimit cr

**************
** CLEAN UP **
**************

capture : rm "`mwb'.xlsx"
log close
// endof(test-issue#24.do)
