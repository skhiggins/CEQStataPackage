* SAMPLE STATA CODE TO ADJUST FOR UNDERESTIMATION OF BENEFICIARIES
* (Example uses numbers for Bolsa Familia in Brazil)

* Code adapted from code for Souza, Osorio, Soares (2011), provided by Sergei Soares

* preliminaries
scalar S = 7320188 // number of beneficiary households according to survey
scalar N = 12370915 // number of beneficiary households according to national accounts
scalar H = N – S
scalar prop = H/S // proportion of beneficiaries who reported that needs to 
			// be randomly sampled and matched to non-reporters
gen transfer1_h_rep = transfer1_h
	// transfer1_h is a variable with the benefit accruing to the household,
	// and equals that value for all members of the household, not just the member
	// that directly received the benefit

* if dataset is individuals, collapse to households:
tempfile original
save `original', replace
drop if head != 1 // where head==1 denotes household head
 // note other household vars such as dummy for existence of children in
 // household must have already been constructed 

* matching
assert !missing(transfer1_h)
generate beneficiary = (transfer1_h > 0)
probit beneficiary lny nmemb child age i.race i.state urban car ///
 [pw=s_weight] if incl==1
predict phat if incl==1, p
table beneficiary, c(mean phat p10 phat p25 phat p75 phat p90 phat)
	// the line above checks distribution of predicted probabilities;
	// the researcher should look at its results
set seed 48490251 // can be any number; set seed so random sampling of 
 // beneficiary HHs doesn't change upon re-running do file
// Randomly sample from beneficiaries the proportion we need to impute
// (then we will match them with most similar non-beneficiaries)
gen selec=(runiform()<=prop) if beneficiary==1 & phat!=.
tempfile households
save `households', replace
keep if selec==1 | (beneficiary==0 & phat!=.)
	// selec==1 are randomly sampled beneficiaries; 
	// (beneficiary==0 & phat!=.) are the "donor pool" of non-beneficiaries from which
	// we will select households to impute benefits to
keep hh_code selec beneficiary phat transfer1_h*
gsort –beneficiary –phat
gen simben=(selec!=.)
gen n=.
count if beneficiary==1
forvalues i=1/`r(N)' { // For each of the randomly selected beneficiary households
	quietly {
		// Calculate difference between predicted probability of receiving program between 
		// each non-beneficiary household and the `i'th beneficiary household
		gen double abs = abs(phat-phat[`i']) if simben==0
			// Then select the closest non-beneficiary household and impute benefits (replace simben = 1)
		summarize abs
		replace simben = 1 if abs==r(min)
		replace n = `i' if abs==r(min) // n tells you which household they matched with
			// Then give them the same transfer as the matched household
		replace transfer1_h = transfer1_h[`i'] if abs==r(min)
		drop abs
	}	
}
keep if simben==1 & beneficiary==0 // only keep new imputed beneficiaries;
	// we will merge them back in to original data set
rename transfer1_h transfer1_h_imp // to be clear it is the imputed value for these households
keep hh_code transfer1_h_imp simben
tempfile imputed
save `imputed', replace

// Now return to original data set to merge in transfer values for "imputed beneficiaries"
use `households', clear
sort hh_code
merge hh_code using `imputed'
drop _merge
// Imputation flag:
generate transfer1_is_imputed = (transfer1_h==0 & simben==1 & beneficiary==0)
// Replace the transfer value (of 0) with the simulated value for those households:
replace transfer1_h = transfer1_h_imp if transfer1_is_imputed==1
keep hh_code transfer1_h*
save `households', replace
use `original', clear
drop transfer1_h
merge m:1 hh_code using `households'
drop _merge


