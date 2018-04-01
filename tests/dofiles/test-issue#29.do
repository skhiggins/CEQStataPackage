/***
	TESTS - ISSUE #29
	do file created by Ivan Gutierrez, ivangutierrez1988@gmail.com
	last revised Apr 1, 2018
*/

*********
** LOG **
*********

capture : log close
log using "tests/logs/test-issue#29.log", text replace
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

use "tests\data\pof3.dta", clear
drop if missing(yg_SA1)
sample 1

// Recode dummy variables
replace agua_canalizada = agua_canalizada - 1

***********
** TESTS **
***********

#delimit ;
// Call ceqinfra
ceqinfra agua_canalizada [pweight = w] using "`mwb'.xlsx",
	`income_options_SA1' 
	`ppp_options'
	hhid(code_uc);
// Import a subset of the generated mwb
import excel "`mwb'.xlsx",
	sheet("E21. Infrastructure Access") 
	cellrange(K15:M15)
	clear;
// Check the contents of cells K15:M15
assert (K == "y > 50");
assert (L == "y > 10");
assert (M == "y > 4");
#delimit cr

**************
** CLEAN UP **
**************

capture : rm "`mwb'.xlsx"
log close
// endof(test-issue#29.do)
