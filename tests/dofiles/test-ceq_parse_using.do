/***
	Tests for ceq_parse_using.ado
	do file created by Ivan Gutierrez, ivangutierrez1988@gmail.com
	last revised Mar 29, 2018
*/


*********
** LOG **
*********

capture : log close
log using "tests/logs/test-ceq_parse_using.log", text replace

**************
** Preamble **
**************

version 13.0
set more off
tempfile myfile
sysuse auto, clear

***********
** Tests **
***********

// Test #1
// Return nothing in the ideal case,
// even if `using' have many "." characters (see issue #24)
foreach open in "" "open" {
	local options cmd("mycmd") open("`open'")
	foreach xxx in "xls" "xlsx" {
		capture : rm "`myfile'.`xxx'"
		quietly : export excel "`myfile'.`xxx'", replace
		ceq_parse_using using "`myfile'.`xxx'", `options'
	}
}
// Test #2
// Return error 198 if `"`using'"' doesn't have xls or xlsx extension
foreach open in "" "open" {
	local options cmd("mycmd") open("`open'")
	foreach xxx in "docx" "pptx" {
		capture : rm "`myfile'.`xxx'"
		quietly : export excel "`myfile'.`xxx'"
		capture : ceq_parse_using using "`myfile'.`xxx'", `options'
		assert (_rc == 198)
	}
}
// Test #3
// Return error 601 if `"`using'"' doesn't exist
foreach open in "" "open" {
	local options cmd("mycmd") open("`open'")
	foreach xxx in "xls" "xlsx" {
		capture : rm "`myfile'.`xxx'"
		capture : ceq_parse_using using "`myfile'.`xxx'", `options'
		assert (_rc == 601)
	}
}
// Test #4
// Update `open' to nothing if `"`using'"' has " " characters
foreach open in "" "open" {
	local options cmd("mycmd") open("`open'")
	foreach xxx in "xls" "xlsx" {
		capture : rm "`myfile' .`xxx'"
		quietly : export excel "`myfile' .`xxx'"
		ceq_parse_using using "`myfile' .`xxx'", `options'
		assert ("`open'" == "")
	}  
}
// Test #5
// Clear the information set by "putexcel set" if no error is found
foreach open in "" "open" {
	local options cmd("mycmd") open("`open'")
	foreach xxx in "xls" "xlsx" {
		capture : rm "`myfile'.`xxx'"
		putexcel set "`myfile'.`xxx'"
		quietly : export excel "`myfile'.`xxx'", replace
		ceq_parse_using using "`myfile'.`xxx'", `options'
		capture : putexcel describe
		assert (_rc == 198)
	}
}

**************
** CLEAN UP **
**************

capture : rm "`mwb'.xlsx"
log close
// endof(test-ceq_parse_using.do)
