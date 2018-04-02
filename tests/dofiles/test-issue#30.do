/***
	TESTS - ISSUE #30
	do file created by Ivan Gutierrez, ivangutierrez1988@gmail.com
	last revised Apr 1, 2018
*/

*********
** LOG **
*********

capture : log close
log using "tests/logs/test-issue#30.log", text replace
version 13.0

************
** LOCALS **
************

// PPP conversion factors
local ppp       = 1.5713184
local cpibase   = 79.560051
local cpisurvey = 95.203354

// Temporal workbook
tempfile mwb
putexcel set "`mwb'.xlsx", replace
putexcel A1 = ("")

// For CEQ commands
#delimit ;
local cut_options
	cut1(01.25)
	cut2(01.90)
	cut3(03.20)
	cut4(05.50)
	cut5(10.00);
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

use "tests/data/pof3.dta", clear // available upon request
keep if (yg_SA1 != .)
sample 1

**********
** TEST **
**********

#delimit ;
ceqassump ym_SA1 ym_norent using "`mwb'.xlsx",
	`cut_options'
	`ppp_options'
	hhid(code_uc)
	country("My country")
	surveyyear("YYYY/MM")
	authors("Author#1, Author#2, Author#3");
import excel using "`mwb'.xlsx",
	sheet("E28. Assumption Testing") 
	cellrange(A57:B62)
	clear;
assert A[1] == "0";             assert B[1] == 1.25;
assert A[2] == "1.25";          assert B[2] == 1.9;
assert A[3] == "1.9";           assert B[3] == 3.2;
assert A[4] == "3.2";           assert B[4] == 5.5;
assert A[5] == "5.5";           assert B[5] == 10;
assert A[6] == "10 And More";
#delimit cr

**************
** CLEAN UP **
**************

// Close log-file
capture : rm "`mwb'.xlsx"
log close
// endof(test-issue#30.do)
