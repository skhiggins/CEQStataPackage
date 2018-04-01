/***
	TESTS - ISSUE #21
	do file created by Ivan Gutierrez, ivangutierrez1988@gmail.com
	last revised Apr 1, 2018
*/

*********
** LOG **
*********

capture : log close
log using "tests/logs/test-issue#21", smcl replace
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
#delimit cr

**********
** DATA **
**********

use "tests/data/pof3.dta", clear // available upon request
keep if (yg_SA1 != .)
sample 1

**********
** TEST **
**********

#delimit ;
ceqgraph conc using "`mwb'",
	`income_options_SA1'
	`direct_options_SA1'
	`indirect_options'
	`inkind_options'
	hhid(code_uc)
	path("tests/data")
	country("My country")
	surveyyear("YYYY/MM")
	authors("Author#1, Author#2, Author#3");
#delimit cr

**************
** CLEANING **
**************

// Remove graphs
foreach type in "direct" "indirect" "inkind" "summary" {
	local files : dir "tests/data" files "conc_`type'_*", respectcase
	foreach file in `files' {
		local myregex = "^(conc_`type')(.)*(\.(gph|png))$"
		if regexm(`"`file'"', "`myregex'") {
			capture : rm "tests/data/`file'"
		}
	}
}

// Close log-file
log close
beep
