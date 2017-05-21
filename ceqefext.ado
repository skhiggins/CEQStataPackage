* ADO FILE FOR EFFECTIVENESS SHEET OF CEQ OUTPUT TABLES

* VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.4 03Jan2016 For use with Feb 2016 version of Output Tables
*! (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

* CHANGES
*  v1.1 Added Poverty options as well as cleaned some bugs 
*  v1.2 Added Beckerman Imervoll, FI/FGP indicators
*  v1.3 Fixed bugs for Beckerman Imervoll and spending effectiveness

* NOTES
* 

* TO DO
    

** NOTES



** TO DO

*************************
** PRELIMINARY PROGRAMS *
*************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

#delimit cr
* Program to compute Gini coefficient;* GINI USING COVARIANCE FORMULA
* Makes two adjustments relative to the "naive" approach:
*  first is to multiply by (N-1)/N to adjust for the fact that Stata uses sample covariance
*  second is to estimate F(y) using Lerman and Yitzhaki (1989); weighted fractional ranks would give biased estimate
* With these two adjustments, covgini gives same answer as Gini commands based on 
*  discrete formulas to 9 decimal places


cap program drop covgini
program define covgini, rclass sortpreserve
	syntax varname [if] [in] [pw aw iw fw/]
	preserve
	marksample touse
	qui keep if `touse' // drops !`if', !`in', and any missing values of `varname'
	local 1 `varlist'
	sort `1' // sort in increasing order of incomes
	tempvar F wnorm wsum // F is adjusted fractional rank, wnorm normalized weights,
		// wsum sum of normalized weights for obs 1, ..., i-1
	if "`exp'"!="" { // with weights
		local 2 `exp'
		qui summ `2'
		qui gen `wnorm' = `2'/r(sum) // weights normalized to sum to 1
		qui gen double `wsum' = sum(`wnorm')
		qui gen double `F' = `wsum'[_n-1] + `wnorm'/2 // from Lerman and Yitzhaki (1989)
		qui replace `F' = `wnorm'/2 in 1
		qui corr `1' `F' [aw=`2'], cov
		local cov = r(cov_12)
		qui summ `1' [aw=`2'], meanonly 
		local mean = r(mean)
	}
	else { // no weights
		qui gen `F' = _n/_N // sorted so this works in unweighted case; 
			// cumul `1', gen(`F') would also work
		qui corr `1' `F', cov
		local cov = r(cov_12)
		qui summ `1', meanonly
		local mean = r(mean)
	}
	local gini = ((r(N)-1)/r(N))*(2/`mean')*`cov' // the (N-1)/N term adjusts for
		// the fact that Stata does sample cov
	return scalar gini = `gini'
	di as result "Gini: `gini'"
	restore
end


cap program drop ceqtaxstar
program define ceqtaxstar, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			taxes(varname)
			]
			;
		#delimit cr	
		local ww `exp' //weights
		*no taxes income
		tempvar notax
		gen double `notax'=`startinc'
		count
		local N=r(N)
		gsort - `notax' 
		
		replace `taxes'=abs(`taxes')
		qui sum `taxes' [w=`ww']
		local tot=r(sum) //total amount to redistribute
		local cum=0-`tot' //cum takes a positive value when we have redistributed more than enough
		forvalues x=2/`N'{
			tempvar tstar
			gen double `tstar'=`notax'
			qui sum `tstar' in `x'
			replace `tstar'=r(mean) in 1/`x'
			tempvar difstar
			gen double `difstar'=`notax'-`tstar'
			qui sum `difstar' [w=`ww'] if `difstar'>0 
			local cum=r(sum)-`tot'
			drop `tstar' `difstar'

			if `cum'>0{
				local stop=`x'
				continue,break
			}
		}
		tempvar ytaxstar
		gen double `ytaxstar'=`notax'
		qui sum `ww' in 1/`stop'
		local redist=`cum'/r(sum)
		qui sum `ytaxstar' in `stop'
		replace `ytaxstar'=r(mean) + `redist' in 1/`stop'
		tempvar taxstar id_taxstar
		gen double `taxstar'=`notax'-`ytaxstar' in 1/`stop'
		gen  `id_taxstar'=1 in 1/`stop'
		cap drop ____id_taxstar
		cap drop ____ytaxstar
		gen double ____id_taxstar=`id_taxstar'
		gen double ____ytaxstar=`ytaxstar'
		*qui sum `taxstar' [w=`ww'] in 1/`stop'
		*local cumf=r(sum)-`tot'
		* di `cumf' //test to see if all tax has been redistributed;
		end

		* Program to compute harm tax formula for poverty impact effectiveness
*generates income variable (ytaxharm) whith ideal taxes 
*rest of observations have no tax income
*var taxharm has the harm tax for those obs. rest is missing

cap program drop ceqtaxharm
program define ceqtaxharm, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			endinc(varname)
			taxes(varname)
			]
			;
			#delimit cr
		local ww `exp' //weights;
		*no taxes income
		tempvar notax
		gen double `notax'=`endinc'+abs(`taxes')
		count
		local N=r(N)
		sort `notax' 

		qui sum `taxes' [w=`ww']
		local tot=r(sum) //total amount to redistribute
		local cum=0-`tot' //cum takes a positive value when we have redistributed more than enough
		forvalues x=2/`N'{
			
			tempvar tharm
			gen double `tharm'=`notax'
			replace `tharm'=0 in 1/`x'
			
			tempvar difstar
			gen double `difstar'=`notax'-`tharm'
			qui sum `difstar' [w=`ww'] if `difstar'>0 
			local cum=r(sum)-`tot'
			drop `tharm' `difstar'
			if `cum'>0{
				local stop=`x'
				continue,break
			}
		}
		tempvar ytaxharm
		gen double `ytaxharm'=`notax'
		qui sum `ww' in 1/`stop'
		local redist=`cum'/r(sum)
		qui sum `ytaxharm' in `stop'
		replace `ytaxharm'=0 in 1/`stop'
		tempvar taxharm id_taxharm
		gen double `taxharm'=0 in 1/`stop'
		gen  `id_taxharm'=1 in 1/`stop'
		cap drop ____id_taxharm
		cap drop ____ytaxharm
		gen double ____id_taxharm=`id_taxharm'
		gen double ____ytaxharm=`ytaxharm'
		end

		
* Program to compute ideal transfer for impact effectiveness
*generates income variable (ybenstar) whith ideal transfers 
*rest of observations have no transfer income
*var benstar has the ideal transfers for those obs. rest is missing
cap program drop ceqbenstar
program define ceqbenstar, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			ben(varname)
			]
			;
		#delimit cr	

		local ww `exp' //weights
		*no transfers income
		tempvar noben
		gen double `noben'=`startinc'
		count
		local N=r(N)
		sort `noben' 

		qui sum `ben' [w=`ww']
		local tot=r(sum) //total amount to redistribute
		local cum=0-`tot' //cum takes a positive value when we have redistributed more than enough
		forvalues x=2/`N'{
			tempvar bstar
			gen double `bstar'=`noben'
			qui sum `bstar' in `x'
			replace `bstar'=r(mean) in 1/`x'
			tempvar difstar
			gen double `difstar'=`noben'-`bstar'
			qui sum `difstar' [w=`ww'] if `difstar'<0 
			local cum=abs(r(sum))-`tot'
			drop `bstar' `difstar'
			if `cum'>0{
				local stop=`x'
				continue,break
			}
		}
		tempvar ybenstar
		gen double `ybenstar'=`noben'
		qui sum `ww' in 1/`stop'
		local redist=`cum'/r(sum)
		qui sum `ybenstar' in `stop'
		replace `ybenstar'=r(mean) - `redist' in 1/`stop'
		tempvar benstar id_benstar
		gen double `benstar'=`ybenstar'-`noben' in 1/`stop'
		gen  `id_benstar'=1 in 1/`stop'

		qui sum `benstar' [w=`ww'] in 1/`stop'
		*local cumf=r(sum)-`tot'
		cap drop ____id_benstar
		cap drop ____ybenstar
		gen double ____id_benstar=`id_benstar'
		gen double ____ybenstar=`ybenstar'
		end
		
		
		
****Spending Effectiveness program;
			cap program drop _ceqspend
program define _ceqspend, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			inc(varname)
			sptax(varname)
			spben(varname)
			]
			;
			#delimit cr
		local ww `exp' //weights
		local id_tax=0
		local id_ben=0
		*gini original
		covgini `inc' `pw'
		local g_orig=r(gini)
		
		*See if we are dealing with taxes or transfers
		if wordcount("`sptax'")>0{
		local id_tax=1
		tempvar inter
		gen double `inter'=abs(`sptax')
		
		}
		if wordcount("`spben'")>0{
		local id_ben=1
		tempvar inter
		gen double `inter'=abs(`spben')
		}
		tempvar o_inc
		
		if `id_tax'==1{
		gen double `o_inc'=`inc'+`inter'
		gsort - `o_inc' //Because of taxes
		}
		if `id_ben'==1{
		gen double `o_inc'=`inc'-`inter'
		sort `o_inc'
		}
		
		tempvar n
		gen `n'=_n
		count
		local tot=r(N)
		forvalues p=1/100{ //Find the cutoff points for centile tests;
			local n`p'=round((`tot'*`p')/100)
		}
		
		*Finder in distribution;
			forvalues p=1/100{
	
				tempvar oi_`p'
				gen `oi_`p''=`o_inc'
				qui sum `oi_`p'' in `n`p''
				replace `oi_`p''=r(mean) in 1/`n`p''
				covgini `oi_`p'' `pw'
				local g_`p'=r(gini)
				drop `oi_`p''
				local dif= `g_`p''-`g_orig'
				if `dif'<0{;//PErcentile where we have to settle
					local stop=`n`p''
					local start=`n`p''-round((`tot'/100))
					di `stop'
					di `start'
					continue,break
				}
		
			}
			if `start'==0{
				local start=1
			}
			forvalues p=`start'/`stop'{
				tempvar oi_`p'
				gen `oi_`p''=`o_inc'
				qui sum `oi_`p'' in `p'
				replace `oi_`p''=r(mean) in 1/`p'
				covgini `oi_`p'' `pw'
				local g_`p'=r(gini)
				drop `oi_`p''
				local dif= `g_`p''-`g_orig'

				if `dif'<0{
					

					local stop=`p'-1
					continue,break
				}
			}
			if `stop'==0{
				local stop=1
			}
			tempvar oi_`stop'
			gen `oi_`stop''=`o_inc'
			qui sum `o_inc' in `stop'
			replace `oi_`stop''=r(mean) in 1/`stop'
			tempvar gap
			if `id_tax'==1{
			gen `gap'=`o_inc'-`oi_`stop''
			}
			if `id_ben'==1{
			gen `gap'=`oi_`stop''-`o_inc'
			}
			qui sum `gap' `aw'
			local prime=r(sum)
			qui sum `inter' `aw'
			local tot_inter=r(sum)
		    if `tot_inter'<0{
			local tot_inter=r(sum)*(-1)
			}
			local sp_ef=`prime'/`tot_inter'
			return scalar sp_ef =  `sp_ef' //Spending Effectiveness
	end

	
	****Poverty Spending effectiveness;
* Program to computepoverty spending effectiveness for FGT1 and FGT2
*generates scalars  sp_ef_pov_1 and sp_ef_pov_2

cap program drop ceqbensp
program define ceqbensp, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			ben(varname)
			zz(string)
			obj1(string)
			obj2(string)
			*
			]
			;

		local ww `exp' ;
		*no transfers income;
		tempvar noben;
		gen double `noben'=`startinc';
		count;
		local N=r(N);
		sum `ben' `aw';
		local totben=r(sum);
		sort `noben' ;
		
		if wordcount("`obj2'")==0{;
		local f=1;
		};
		else{;
		local f=2;
		};
							forvalues fgt=1/`f'{;
							tempvar n;
							gen `n'=_n;
							count;
							local N=r(N);
							forvalues p=1/100{;//Find the cutoff points for centile tests;
								local n`p'=round((`N'*`p')/100);
							};
							*Finder in distribution for fgt1 or 2;
							forvalues p=1/100{;
								tempvar oi_`p';
								gen `oi_`p''=`noben';
								qui sum `oi_`p'' in `n`p'';
								replace `oi_`p''=r(mean) in 1/`n`p'';
								
								tempvar fgt1_`p' fgt2_`p';
								qui gen `fgt1_`p'' = max((`zz'-`oi_`p'')/`zz',0) ;// normalized povety gap of each individual;
								qui gen `fgt2_`p'' = `fgt1_`p''^2 ;
								
								qui summ `fgt`fgt'_`p'' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local fgt`fgt'`p'=r(mean);
								
								drop  `fgt1_`p'' `fgt2_`p'';
								local dif= `fgt`fgt'`p''- `obj`fgt'';
								
								if `dif'<0{;//PErcentile where we have to settle;
									local stop=`n`p'';
									local start=`n`p''-round((`N'/100));
									di `stop';
									di `start';
									continue,break;
								};
		
							};
							if `start'==0{;
								local start=1;
							};
							forvalues p=`start'/`stop'{;
								tempvar oi_`p';
								gen `oi_`p''=`noben';
								qui sum `oi_`p'' in `p';
								replace `oi_`p''=r(mean) in 1/`p';
								
								tempvar fgt1_`p' fgt2_`p';
								qui gen `fgt1_`p'' = max((`zz'-`oi_`p'')/`zz',0) ;// normalized povety gap of each individual;
								qui gen `fgt2_`p'' = `fgt1_`p''^2 ;
								
								qui summ `fgt`fgt'_`p'' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local fgt`fgt'_p'=r(mean);
								
								drop  `fgt1_`p'' `fgt2_`p'';
								local dif= `fgt`fgt'`p''- `obj`fgt'';
								if `dif'<0{;
								

								local stop=`p'-1;
								continue,break;		
							};		
					};
							if `stop'==0{;
							local stop=1;
							};
							tempvar oi_`stop';
							gen `oi_`stop''=`noben';
							qui sum `noben' in `stop';
							replace `oi_`stop''=r(mean) in 1/`stop';
							tempvar gap;
							gen `gap'=`oi_`stop''-`noben';
							qui sum `gap' `aw';
							local prime=r(sum);
							
							local sp_ef_pov_`fgt'=`prime'/`totben';
							
			
							};//end of fgt loop;			
return scalar sp_ef_pov_1 =  `sp_ef_pov_1';//spending effectiveness indicator for FGT 1 or 2;
if wordcount("`obj2'")>0{;
return scalar sp_ef_pov_2 =  `sp_ef_pov_2';//spending effectiveness indicator for FGT 1 or 2;
};
end;


#delimit cr
****************************************************
***Beckerman Imervoll program
cap program drop ceqbeck
program define ceqbeck, rclass sortpreserve
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			preinc(varname)
			postinc(varname)
			/* POVERTY LINES */
			zline(string)
			]
			;
#delimit cr			
*quietly {
tempvar difference
gen double `difference' = `postinc'-`preinc'
tempvar pre_shortfall
gen double `pre_shortfall' = `zline' - `preinc'
tempvar post_shortfall
gen double `post_shortfall' = `zline' - `postinc'

sum `difference' [`weight' =`exp'] if `preinc' < `zline'
scalar AB = r(sum)
summarize `difference' [`weight' =`exp']
scalar ABC = r(sum)
summarize `post_shortfall' [`weight' =`exp'] if `preinc' < `zline' & `postinc'>= `zline'
scalar B = -r(sum)
summarize `difference' [`weight'= `exp'] if `postinc' <  `zline'
scalar A1 = r(sum)
summarize `pre_shortfall' [`weight' =`exp'] if `preinc' <  `zline' & `postinc' >= `zline'
scalar A2 = r(sum)
scalar A = A1 + A2
summarize `pre_shortfall' [`weight' =`exp'] if `preinc' < `zline'
scalar AD = r(sum)
scalar VEE = AB/ABC
scalar Spillover = B/AB
scalar PRE = A/ABC
scalar PGE = A/AD

return scalar VEE=VEE
return scalar Spill = Spillover
return scalar PRE = PRE
return scalar PGE = PGE
*}

end

	***Marginal contribution ID
	
	cap program drop _ceqmcid
program define _ceqmcid, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			inc(varname)
			sptax(varname)
			spben(varname) 
			pline(string)  
			]
			;
			#delimit cr
		local ww `exp' //weights
		local id_tax=0
		local id_ben=0
		
		tempvar inter
		*See if we are dealing with taxes or transfers
		if wordcount("`sptax'")>0{
		local id_tax=1
		gen double `inter'=abs(`sptax')
		
		}
		if wordcount("`spben'")>0{
		local id_ben=1
		gen double `inter'=abs(`spben')
		}
		
		
		if `id_tax'==1{
		tempvar o_inc
		gen double `o_inc'=`inc'+`inter'
		}
		if `id_ben'==1{
		tempvar o_inc
		gen double `o_inc'=`inc'-`inter'
		}
		
		
			*gini final income
			covgini `inc' `pw'
			local g_f=r(gini)
			covgini `o_inc' `pw'
			local g_o=r(gini)
		
			local mc=`g_o'-`g_f'
			return scalar mc_ineq =  `mc' //Marginal Contribution
		
		if wordcount("`pline'")>0{
			tempvar pov0_o pov1_o pov2_o
			tempvar pov0_f pov1_f pov2_f
			gen `pov0_o'=(`o_inc'<`pline')
			gen `pov0_f'=(`inc'<`pline')
			
			qui gen `pov1_o' = max((`pline'-`o_inc')/`pline',0) // normalized povety gap of each individual
			qui gen `pov2_o' = `pov1_o'^2 
			qui gen `pov1_f' = max((`pline'-`inc')/`pline',0) // normalized povety gap of each individual
			qui gen `pov2_f' = `pov1_f'^2 
			forvalues f=0/2{
			qui sum `pov`f'_o' `aw'
			local p`f'_o=r(mean)
	
			qui sum `pov`f'_f' `aw'
			local p`f'_f=r(mean)
			local mc`f'=`p`f'_o'-`p`f'_f'
			return scalar mc_p`f'=`mc`f'' //Marginal Contribution of poverty fgt:`f'
			}
		}
		end
			
#delimit cr
// BEGIN _fifgpmc (Edited from _fifgp, Higgins 2015)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts
capture program drop _fifgpmc
program define _fifgpmc,rclass
	#delimit;
	syntax  [if] [in] [aw] [, 
		z(string)
		taxes(varname)
		benef(varname)
		startinc(varname)
		endinc(varname)
		];
	#delimit cr
	tempvar tax1 ben1
	if wordcount("`taxes'")>0{
		gen `tax1'=`taxes'
	}
	if wordcount("`taxes'")==0{
		gen `tax1'=0
	}
	if wordcount("`benef'")>0{

gen `ben1'=`benef'
}
if wordcount("`benef'")==0{
gen `ben1'=0

}
	tempvar notax noben
	qui gen double `notax'=`endinc'+`tax1'
	qui gen double `noben'=`endinc'-`ben1'
	
	*total taxes and transfers;
	qui sum `tax1' [`weight' `exp']
	local T=r(sum)
	qui sum `ben1' [`weight' `exp']
	local B=r(sum)
	local TB=`T'+`B'
	
	tempvar  d_fi d_fi_t d_fg d_fg_b
	
	qui gen `d_fi' = min(`startinc',`z') - min(`startinc',`endinc',`z')
	qui gen `d_fi_t' = min(`notax',`z') - min(`notax',`endinc',`z')   //! Isn't `notax' exactly the same asm`startinc'?
	qui gen `d_fg' = min(`endinc',`z') - min(`startinc',`endinc',`z')
	qui gen `d_fg_b' = min(`endinc',`z') - min(`noben',`endinc',`z')
	
	foreach v in fi fi_t fg fg_b{
	qui summ `d_`v'' [`weight' `exp'], meanonly
			local t_`v' = r(sum)
			local pc_`v' = r(mean)
			local n_`v' = r(mean)/`z'
	}
	*Marginal contributions
	foreach m in t pc n{
		if wordcount("`taxes'")>0{

			local `m'_mc_t=``m'_fi'-``m'_fi_t'
			local mceft_`m'=(`T'/`TB')*(1-(``m'_mc_t'/`T'))
			local MCEF_`m'=`mceft_`m''
			scalar MCEF_`m'=`mceft_`m''
			return scalar MCEF_`m' = `mceft_`m''
		}
		if wordcount("`benef'")>0{
			local `m'_mc_b=``m'_fg_b'-``m'_fg'
			local mcefb_`m'=(`B'/`TB')*((``m'_mc_b'/`B'))
			local MCEF_`m'=`mcefb_`m''
			scalar MCEF_`m'=`mcefb_`m''
			return scalar MCEF_`m' = `mcefb_`m''			
		}
		
			**if wordcount("``m'_mc_t'")==0 local mceft_`m'=0
			**if  wordcount("``m'_mc_b'")==0 local mcefb_`m'=0
			
			**else{
			**scalar MCEF_`m'=.
			**return scalar MCEF_`m' = . 
			**	}
	}
end // END _fifgpmc	
*********************
* ceqefext PROGRAM *
*********************

capture program drop ceqefext
program define ceqefext
version 13.0
	#delimit ;
	syntax 
		[using]
		[if] [in] [pweight] 
		[, 
			/* INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			OPEN
			*
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqefext
	local version 1.4
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to raranda@tulane.edu)"
	
	** income concept options
	#delimit ;
	local inc_opt
		market
		mpluspensions
		netmarket
		gross
		taxable
		disposable
		consumable
		final
	;
	#delimit cr
	local inc_opt_used ""
	foreach incname of local inc_opt {
		if "``incname''"!="" local inc_opt_used `inc_opt_used' `incname' 
	}
	local list_opt2 ""
	foreach incname of local inc_opt_used {
		local `incname'_opt "`incname'(``incname'')" // `incname' will be e.g. market
			// and ``incname'' will be the varname 
		local list_opt2 `list_opt2' `incname'2(``incname'') 
	}
	
	** negative incomes
	foreach v of local inc_opt {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
		}
	}	
	
	local counter=1
	local n_inc_opts = wordcount("`inc_opt_used'")
	foreach incname of local inc_opt_used {
		// preliminary: 
		//	to open only on last iteration of _ceqdomext,
		//  only print warnings and messages once
		if "`open'"!="" & `counter'==`n_inc_opts' {
			local open_opt "open"
		}
		else {
			local open_opt ""
		}
		if `counter'==1 {
			local nodisplay_opt "" 
		}
		else {
			local nodisplay_opt "nodisplay"
		}
		
		local ++counter
	
		_ceqefext `using' `if' `in' [`weight' `exp'], ///
			``incname'_opt' `list_opt2' `options' `open_opt' `nodisplay_opt' ///
			_version("`version'") 
	}
end

** For sheet E14. Effectiveness
// BEGIN ceqefext
// BEGIN _ceqefext (Aranda 2016)
capture program drop _ceqefext  
program define _ceqefext, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/* INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/* REPEAT FOR CONCENTRATION MATRIX */
			/* (temporary hack-y patch) */
			market2(varname)
			mpluspensions2(varname)
			netmarket2(varname) 
			gross2(varname)
			taxable2(varname)
			disposable2(varname) 
			consumable2(varname)
			final2(varname)
			/* FISCAL INTERVENTIONS: */
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			CONTribs(varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			/* PPP CONVERSION */
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			/* SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)
			/* POVERTY LINES */
			PL1(real 1.25)
			PL2(real 2.50)
			PL3(real 4.00)
			NATIONALExtremepl(string)   
			NATIONALModeratepl(string)  
			OTHERExtremepl(string)      
			OTHERModeratepl(string)			
			/* EXPORTING TO CEQ MASTER WORKBOOK: */
			sheetm(string)
			sheetmp(string)
			sheetn(string)
			sheetg(string)
			sheett(string)
			sheetd(string)
			sheetc(string)
			sheetf(string)
			OPEN
			/* GROUP CUTOFFS */
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			/* INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /* string because could be range of years */
			AUTHors(string)
			
			BASEyear(real -1)
			/* OTHER OPTIONS 
			NODecile
			NOGroup
			NOCentile
			NOBin
			*/
			NODIsplay
			_version(string)
		]
	;
	#delimit cr
		
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit if "`nodisplay'"=="" display as text in smcl
	local die display as error in smcl
	local command ceqefext
	local version `_version'
	
	
	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local m2 `market2'
	local mp2 `mpluspensions2'
	local n2 `netmarket2'
	local g2 `gross2'
	local t2 `taxable2'
	local d2 `disposable2'
	local c2 `consumable2'
	local f2 `final2'
	local alllist m mp n g t d c f
	local alllist2 m2 mp2 n2 g2 t2 d2 c2 f2
	local incomes = wordcount("`alllist'")
	
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local varlist2 ""
	local counter = 1
	
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		local varlist2 `varlist2' ``y'2'
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		if "``y''"!="" local `y'__ `y' // so `m__' is e.g. m if market() was specified, "" otherwise
		local ++counter
	}
	
	local d_m      = "Market Income"
	local d_mp     = "Market Income + Pensions"
	local d_n      = "Net Market Income"
	local d_g      = "Gross Income"
	local d_t      = "Taxable Income"
	local d_d      = "Disposable Income"
	local d_c      = "Consumable Income"
	local d_f      = "Final Income"
	
	foreach y of local alllist {
		if "``y''"!="" {
			scalar _d_``y'' = "`d_`y''"
		}
	}
	
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize and hhid
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group and bin not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid'
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	***********************
	** SVYSET AND WEIGHTS *
	***********************
	cap svydes
	scalar no_svydes = _rc
	if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen double `weightvar' = `w'*`hsize'
			local w `weightvar'
		}
		else local w "`hsize'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
	}
	if "`psu'"=="" & "`r(su1)'"!="" {
		local psu `r(su1)'
	}
	if "`strata'"=="" & "`r(strata1)'"!="" {
		local strata `r(strata1)'
	}
	if "`strata'"!="" {
		local opt strata(`strata')
	}
	** now set it:
	if "`exp'"!="" qui svyset `psu' `pw', `opt'
	else           qui svyset `psu', `opt'
	
	************************
	** PRESERVE AND MODIFY *
	************************
	
	** poverty lines
	local povlines `pl1' `pl2' `pl3' `nationalextremepl' `nationalmoderatepl' `otherextremepl' `othermoderatepl'
	*rows foreach poverty line:
	*For Impact Ef. and Spending Ef
	local ref_pl1_1=1
	local ref_pl1_2=2
	local ref_pl2_1=3
	local ref_pl2_2=4
	local ref_pl3_1=5
	local ref_pl3_2=6
	local ref_nationalextremepl_1=7
	local ref_nationalextremepl_2=8
	local ref_nationalmoderatepl_1=9
	local ref_nationalmoderatepl_2=10
	local ref_otherextremepl_1=11
	local ref_otherextremepl_2=12
	local ref_othermoderatepl_1=13
	local ref_othermoderatepl_2=14
	*For FI/FGP
	local rfi_pl1=3
	local rfi_pl2=8
	local rfi_pl3=13
	local rfi_nationalextremepl=18
	local rfi_nationalmoderatepl=23
	local rfi_otherextremepl=28
	local rfi_othermoderatepl=33
	*For Beckerman Imervoll
	local rbk_pl1=1
	local rbk_pl2=5
	local rbk_pl3=9
	local rbk_nationalextremepl=13
	local rbk_nationalmoderatepl=17
	local rbk_otherextremepl=21
	local rbk_othermoderatepl=25
	
	
	local plopts pl1 pl2 pl3 nationalextremepl nationalmoderatepl otherextremepl othermoderatepl
	foreach p of local plopts {
		if "``p''"!="" {
			cap confirm number ``p'' // `p' is the option name eg pl125 so ``p'' is what the user supplied in the option
			if !_rc scalar _`p'_isscalar = 1 // !_rc = ``p'' is a number
			else { // if _rc, i.e. ``p'' not number
				cap confirm numeric variable ``p''
				if _rc {
					`die' "Option " in smcl "{opt `p'}" as error " must be specified as a scalar or existing variable."
					exit 198
				}
				else scalar _`p'_isscalar = 0 // else = if ``p'' is numeric variable
			}
		}
	}
	scalar _relativepl_isscalar = 1 // `relativepl' created later
	
	// ! Added the below chunk of code
	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}
	
	local relevar `varlist2' `allprogs' ///
				  `w' `psu' `strata' ///
				  `pl_tokeep' 
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist2 {
		qui count if missing(`var')  
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found" 
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
			}
		}
	}
	
	** missing fiscal interventions 
	foreach var of local allprogs {
		if "`varlist'"=="`market'" {   // so that it only runs once 
			qui count if missing(`var') 
			if "`ignoremissing'"=="" {
				if r(N) {
					`die' "Missing values not allowed; `r(N)' missing values of `var' found"
					`die' "For households that did not receive/pay the tax/transfer, assign 0"
					exit 198
				}
			}
			else {
				if r(N) {
				qui drop if missing(`var')
				di "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				}
			}
		} 
	}
	
	** columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind alltaxes alltaxescontribs alltransfers 
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen `v_`cat''=0 // because necessary for local programcols
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
		}	
	}
	foreach bc of local broadcats {
		if wordcount("``bc''")>0 { // i.e. if any of the options were specified; for bc=inkind this says if any options health education or otherpublic were specified
			tempvar v_`bc'
			qui gen `v_`bc'' = 0
			foreach var of local `bc' { // each element will be blank if not specified
				qui replace `v_`bc'' = `v_`bc'' + `var'
			}
		}
	}	

	#delimit ;
	local programcols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`dtaxes' `contribs' `v_dtaxescontribs'
		`subsidies' `v_subsidies' `indtaxes' `v_indtaxes'
		`v_alltaxes' `v_alltaxescontribs'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local transfercols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`subsidies' `v_subsidies'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
		}
		scalar _d_`pr' = "`d_`pr''"
	}
	scalar _d_`v_pensions'         = "All contributory pensions"
	scalar _d_`v_dtransfers'       = "All direct transfers excluding contributory pensions"
	scalar _d_`v_dtransfersp'      = "All direct transfers including contributory pensions"
	scalar _d_`v_contribs'         = "All contributions"
	scalar _d_`v_dtaxes'           = "All direct taxes"
	scalar _d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	scalar _d_`v_subsidies'        = "All indirect subsidies"
	scalar _d_`v_indtaxes'         = "All indirect taxes"
	scalar _d_`v_health'           = "All health"
	scalar _d_`v_education'        = "All education"
	scalar _d_`v_otherpublic'      = "All other public spending" // LOH need to fix that this is showing up even when I don't specify the option
	scalar _d_`v_inkind'           = "All in-kind"
	scalar _d_`v_alltransfers'     = "All transfers and subsidies excluding contributory pensions"
	scalar _d_`v_alltransfersp'    = "All transfers and subsidies including contributory pensions"
	scalar _d_`v_alltaxes'         = "All taxes"
	scalar _d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU 
	foreach y of local alllist {
		if "``y''"!="" local supercols `supercols' fi_`y'
	}
	
	** titles 
	local _totLCU   = "Effectiveness"
	
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "EFFECTIVENESS WITH RESPECT TO `uppered'"
	}
	
	******************
	** PARSE OPTIONS *
	******************
	
	
	** ado file specific
	foreach vrank of local alllist {
		if "`sheet`vrank''"=="" {
			if "`vrank'"=="mp" local sheet`vrank' "E14.m+p Effectiveness"
			else {
				local sheet`vrank' "E14.`vrank' Effectiveness" // default name of sheet in Excel files
			}
		}
	}
	
	** make sure using is xls or xlsx
	cap putexcel clear
	if `"`using'"'!="" {
		qui di " // for Notepad++ syntax highlighting
		local period = strpos("`using'",".")
		if `period'>0 { // i.e., if `"`using'"' contains .
			local ext = substr("`using'",`period',.)
			if "`ext'"!=".xls" & "`ext'"!=".xlsx" {
				`die' "File extension must be .xls or .xlsx to write to an existing CEQ Master Workbook (requires Stata 13 or newer)"
				exit 198
			}
		}
		else {
			local using `"`using'.xlsx"'
			qui di "
			`dit' "File extension of {bf:using} not specified; .xlsx assumed"
		}
		// give error if file doesn't exist:
		confirm file `"`using'"'
		qui di "
	}
	else { // if "`using'"==""
		`dit' "Warning: No file specified with {bf:using}; results saved in {bf:return list} but not exported to Output Tables"
	}
	if strpos(`"`using'"'," ")>0 & "`open'"!="" { // has spaces in filename
		qui di "
		`dit' `"Warning: `"`using'"' contains spaces; {bf:open} option will not be executed. File can be opened manually after `command' runs."'
		local open "" // so that it won't try to open below
	}	
	
	** create new variables for program categories

	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `x'
			else local postax `x'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	if wordcount("`postax'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `postax'; replaced with negative for calculations"
	}
	
	/*foreach y of local alllist {
		local marg`y' ``y''
	}	*/
	** create extended income variables
	
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y''+`pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y''- `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=-abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `v_alltransfers' {
		foreach y in `m__' `mp__' `n__' { // omit g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
		}		
	}
	local maxlength = 0
	foreach v of local alllist {
		if "``v''"!="" {
			local length = wordcount("`marg`v''")
			local maxlength = max(`maxlength',`length')
		}
	}
	local colsneeded = (wordcount("`supercols'"))*`maxlength'*2 // *2 is for crossings and p-values
	
	 //! Previously where poverty line locals are located
	
	
	* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" {
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
				foreach ext of local marg`v' {
					tempvar `ext'_ppp
					qui gen ``ext'_ppp' = (`ext'/`divideby')*(1/`ppp_calculated')
				}
			}
		}	
	}
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	
	#delimit;
	
	*Temporary dataset from which to run results;
	qui tempfile orig;
	qui save `orig',replace;
	*****************************************************RUN RESULTS******************************;
	qui{;
	local rowc=0;
	

	foreach y of local alllist {;
		if "``y''"!="" {;
		use `orig',clear;
			
			local cols = (wordcount("`marg`y''"));
			*Inequality;
			matrix g_ie_`y'=J(1,`cols',.);
			matrix g_se_`y'=J(1,`cols',.);
			*Poverty;
			matrix p_ie_`y'=J(14,`cols',.);
			matrix p_se_`y'=J(14,`cols',.);
			*Fiscal impoverishment;
			matrix fi_`y'=J(35,`cols',.);
			*Beckerman Imervoll Effectiveness Indicators;
			matrix bi_`y'=J(28,`cols',.);
			
			local col = 0 /*1 */ ;
			local colc=0;
				foreach ext of local int`y' {;
				local col=`col'+1;
				local row = 0;
				local rfi=0;
				local rbk=0;			
				
				qui sum ``y'' ;
				local m_`y'=r(mean);
				qui sum `ext' ;
				local m_`ext'=r(mean);
				local is_tax=0;
				local is_ben=0;
				*Generate variables with the individual tax or transfer;
				*if `m_`ext''<`m_`y''{;
					if `m_`ext''<0{;
					tempvar int_tax;
					gen double `int_tax'=abs( `ext');
					local is_tax=1;
				
				};
				if `m_`ext''>0{;
					tempvar int_ben;
					gen double `int_ben'=abs( `ext');
					local is_ben=1;
				};
				if `m_`ext''==`m_`y''{; //IE AND SE are missing if intervention=0;
					matrix g_ie_`y'[1,`col'] =.;
					matrix g_se_`y'[1,`col'] =.;
				};
					tempvar yo;
					gen double `yo'=``y''-`ext'; ///without transfers (-) without tax (+);
				  tempvar `y'o_ppp;
					 gen double ``y'o_ppp'=(`yo'/`divideby')*(1/`ppp_calculated');
					 
					 
				*for taxes;
				if `is_tax'==1 {;

					*****Gini********************;

					*Impact effectiveness;
					ceqtaxstar [w=`w'], startinc(``y'') taxes(`int_tax');			
					tempvar ystar;
					gen double `ystar'=____ytaxstar;
					cap drop ____ytaxstar   ____id_taxstar;
					covgini ``y'' `pw';//gini of column income;
					local g1_`y'=r(gini);
					covgini `yo' `pw';//gini of row income;
					local g2_`yo'=r(gini);
					covgini `ystar' `pw';//gini of star income;
					local g_star=r(gini);
					local imef=(`g2_`yo''-`g1_`y'')/(`g2_`yo''-`g_star');
					matrix g_ie_`y'[1,`col'] =`imef';
					*Spending Effectiveness;
					_ceqmcid `pw', inc(``y'') sptax(`int_tax') ;
					*If Marg. Cont. is negative, SE is missing;
					if r(mc_ineq)<0{;
						matrix g_se_`y'[1,`col'] =.;

					};
					else{;
						_ceqspend [w=`w'],inc(``y'') sptax(`int_tax');
						local spef=r(sp_ef);
						matrix g_se_`y'[1,`col'] =`spef';

					};
					*****Poverty********************;
					*Convert to ppp;
					 tempvar int_tax_ppp;
					 gen double  `int_tax_ppp'=(`int_tax'/`divideby')*(1/`ppp_calculated');
					 tempvar ystar_ppp;
					 gen double `ystar_ppp'=(`ystar'/`divideby')*(1/`ppp_calculated');
					 tempvar `y'_ppp;
					 gen double ``y'_ppp'=(``y''/`divideby')*(1/`ppp_calculated');
					
					 
		

			
					
					if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
					foreach p in `plopts'  { ;// plopts includes all lines;
						if "``p''"!="" {	;
						if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
								local _pline = ``p'';
								local vtouse1 ``y'_ppp';//1 is for original;
								local vtouse2 ``y'o_ppp';//2 is for income without intervention;
								local vtouse3 `ystar_ppp';//3 is for ideal income; 
							};
							else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
								local _pline = ``p''; // set `_pline' as that scalar and;
								local vtouse1 ``y''   ;// use original income variable;
								local vtouse2 `yo';//income without intervention;
								local vtouse3 `ystar';//income with ideal intervention;
							};
							else if _`p'_isscalar==0 {; // if pov line is variable,;
								tempvar `v'_normalized1 ; // create temporary variable that is income...;
								tempvar `v'_normalized2 ; // create temporary variable that is income...;
								tempvar `v'_normalized3 ; // create temporary variable that is income...;

								qui gen ``v'_normalized1' = ``y''/``p'' ;// normalized by pov line;   //! changed from `y' to ``y'';
								qui gen ``v'_normalized2' = `yo'/``p'' ;// normalized by pov line;
								qui gen ``v'_normalized3' = `ystar'/``p'' ;// normalized by pov line;

								local _pline = 1            ;           // and normalized pov line is 1;
								local vtouse1 ``v'_normalized1'; // use normalized income in the calculations;
								local vtouse2 ``v'_normalized2'; // use normalized income in the calculations;
								local vtouse3 ``v'_normalized3'; // use normalized income in the calculations;

							};
							
							
							tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3;
							qui gen `zyzfgt1_1' = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_1' = `zyzfgt1_1'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_2' = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_2' = `zyzfgt1_2'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_3' = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_3' = `zyzfgt1_3'^2 ;                           // square of normalized poverty gap;
							
							
								
							
								qui summ `zyzfgt1_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_orig=r(mean);
								qui summ `zyzfgt1_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_2=r(mean);
								qui summ `zyzfgt1_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_3_st=r(mean);
								
								qui summ `zyzfgt2_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_orig=r(mean);
								qui summ `zyzfgt2_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_2=r(mean);
								qui summ `zyzfgt2_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_3_st=r(mean);
															drop `zyzfgt1_3' `zyzfgt1_2' `zyzfgt1_1' `zyzfgt2_3' `zyzfgt2_2' `zyzfgt2_1';

																****Poverty Impact effectiveness;

								//Marginal contributions for fgt 1,2;
								local mp_1_`p'_`y'=`p1_`y'_2'-`p1_`y'_orig';//Observed MC;
								local mp_1_`p'_`y'_s=`p1_`y'_2'-`p1_`y'_3_st';//Star MC;
								local mp_2_`p'_`y'=`p2_`y'_2'-`p2_`y'_orig';//Observed MC;
								local mp_2_`p'_`y'_s=`p2_`y'_2'-`p2_`y'_3_st';//Star MC;
								
								****For Impact effectiveness there can only be a negative effect, we use the harm formula Ch. 5 CEQ Handbook;
								forval i=1/2 {;
								if `mp_`i'_`p'_`y''<0{;
								ceqtaxharm [w=`w'], endinc(``y'') taxes(`int_tax');			
								tempvar yharm;
								gen double `yharm'=____ytaxharm;
								cap drop ____ytaxharm   ____id_taxharm;
								tempvar yharm_ppp;
								gen `yharm_ppp'=(`yharm'/`divideby')*(1/`ppp_calculated');
								
								
								if "``p''"!="" {	;
								if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
								local _pline = ``p'';
								local vtouseh `yharm_ppp';//h is for harm;
								};
								
								else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
								local _pline = ``p''; // set `_pline' as that scalar and;
								local vtouseh `yharm'   ;
								};
								else if _`p'_isscalar==0 {; // if pov line is variable,;
								tempvar `v'_normalizedh ; // create temporary variable that is income...;
								qui gen ``v'_normalizedh' = `yharm'/``p'' ;// normalized by pov line;  //! changed from ``v'_normalized1' to ``v'_normalizedh';
								local _pline = 1            ;           // and normalized pov line is 1;
								local vtouseh ``v'_normalizedh'; // use normalized income in the calculations;					
								};
							
							
								tempvar zyzfgt1_h zyzfgt2_h;
								qui gen `zyzfgt1_h' = max((`_pline'-`vtouseh')/`_pline',0) ;// normalized povety gap of each individual;
								qui gen `zyzfgt2_h' = `zyzfgt1_h'^2 ;                           // square of normalized poverty gap;							
								
								
								qui summ `zyzfgt`i'_h' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p`i'_h=r(mean);
								
								local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
								if `mst_p`i'_h' == 0 {;   // Added on Mar28, 2017
									local eft_`i'_h=0;
									noi di "test"; //!;
								};
								else {;
									local eft_`i'_h=(`mp_`i'_`p'_`y''/`mst_p`i'_h')*(-1);
								};
								*return scalar eft_`i'_h =  `eft_`i'_h';//Impact effectiveness indicator, v has the variable name of the transfer, y=income, p=poverty line ;
								
								local row=`row'+1;
								matrix p_ie_`y'[`ref_`p'_`i'',`col'] = `eft_`i'_h';
								matrix p_se_`y'[`ref_`p'_`i'',`col'] = .;
								

								/*local row=`row'+1;
								matrix p_ie_`y'[`row',`col'] = `eft_2_h';
								matrix p_se_`y'[`row',`col'] = .;*/
								};
								};
								
								else{;
								local row=`row'+1;
								

								matrix p_ie_`y'[`ref_`p'_`i'',`col'] =.;
								matrix p_se_`y'[`ref_`p'_`i'',`col'] = .;
								
								};
						};
						tempvar taxesef;
							gen double `taxesef'=abs(`vtouse2'-`vtouse1');

							_fifgpmc `aw',taxes(`taxesef')  startinc(`vtouse1') endinc(`vtouse2') z(`_pline');   //! mark
							local rfi=`rfi_`p'';
							matrix fi_`y'[`rfi',`col']=MCEF_t;
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=MCEF_pc;
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=MCEF_n;
							*Beckerman Immervol NOT FOR TAXES SO MISSING VALUES;
							 local rbk=`rbk_`p'';
							 matrix bi_`y'[`rbk',`col']=.;//Vertical Expenditure Efficiency;
							local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Spillover Index;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Poverty Reduction Efficiency;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Poverty Gap Efficiency;

						};
						};
						
						};
					};
					
					cap drop `ystar';
				
				*For transfers;
					if `is_ben'==1{;

					*****Gini********************;
					*Impact effectiveness;
					ceqbenstar [w=`w'], startinc(``y'') ben(`int_ben');			
					tempvar ystar;
					gen double `ystar'=____ybenstar;
					cap drop  ____ybenstar ____id_benstar ;
					covgini ``y'' `pw';//gini of column income;
					local g1_`y'=r(gini);
					covgini `yo' `pw';//gini of row income;
					local g2_`yo'=r(gini);
					covgini `ystar' `pw';//gini of star income;
					local g_star=r(gini);
					local imef=(`g2_`yo''-`g1_`y'')/(`g2_`yo''-`g_star');
					matrix g_ie_`y'[1,`col'] =`imef';

					*Spending Effectiveness;
					_ceqmcid `pw', inc(``y'') spben(`int_ben') ;
					*If Marg. Cont. is negative, SE is missing;
					if r(mc_ineq)<0{;
						matrix g_se_`y'[1,`col'] =.;

					};
					else{;
						_ceqspend [w=`w'],inc(``y'') spben(`int_ben');
						local spef=r(sp_ef);
						matrix g_se_`y'[1,`col'] =`spef';
	

					};
					*********Poverty************;
					*Convert to ppp;
					 tempvar int_ben_ppp;
					 gen double  `int_ben_ppp'=(`int_ben'/`divideby')*(1/`ppp_calculated');
					 tempvar ystar_ppp;
					 gen double `ystar_ppp'=(`ystar'/`divideby')*(1/`ppp_calculated');
					 tempvar `y'_ppp;
					 gen double ``y'_ppp'=(``y''/`divideby')*(1/`ppp_calculated');
					
					
					if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
					foreach p in `plopts'  { ;// plopts includes all lines;
						if "``p''"!="" {	;
						if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
								local _pline = ``p'';
								local vtouse1 ``y'_ppp';//1 is for original;
								local vtouse2 ``y'o_ppp';//2 is for income without intervention;
								local vtouse3 `ystar_ppp';//3 is for ideal income; 
							};
							else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
								local _pline = ``p''; // set `_pline' as that scalar and;
								local vtouse1 ``y''   ;// use original income variable;
								local vtouse2 `yo';//income without intervention;
								local vtouse3 `ystar';//income with ideal intervention;
							};
							else if _`p'_isscalar==0 {; // if pov line is variable,;
								tempvar `v'_normalized4 ; // create temporary variable that is income...;   //! changed normaliezd1(2,3) to narmalized4(5,6) here and below;
								tempvar `v'_normalized5 ; // create temporary variable that is income...;
								tempvar `v'_normalized6 ; // create temporary variable that is income...;

								qui gen ``v'_normalized4' = ``y''/``p'' ;// normalized by pov line;  //! changed from `y' to ``y'';
								qui gen ``v'_normalized5' = `yo'/``p'' ;// normalized by pov line;
								/*qui gen ``v'_normalized2' = `yo'/``p'' ;// normalized by pov line;*/
								qui gen ``v'_normalized6' = `ystar'/``p'' ;// normalized by pov line;

								local _pline = 1            ;           // and normalized pov line is 1;
								local vtouse1 ``v'_normalized4'; // use normalized income in the calculations;
								local vtouse2 ``v'_normalized5'; // use normalized income in the calculations;
								local vtouse3 ``v'_normalized6'; // use normalized income in the calculations;

							};
							
							
							tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3;
							qui gen `zyzfgt1_1' = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_1' = `zyzfgt1_1'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_2' = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_2' = `zyzfgt1_2'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_3' = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_3' = `zyzfgt1_3'^2 ;                           // square of normalized poverty gap;
							

								qui summ `zyzfgt1_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_orig=r(mean);
								qui summ `zyzfgt1_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_2=r(mean);
								qui summ `zyzfgt1_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_3_st=r(mean);
								
								qui summ `zyzfgt2_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_orig=r(mean);
								qui summ `zyzfgt2_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_2=r(mean);
								qui summ `zyzfgt2_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_3_st=r(mean);
							
								
								//Marginal contributions for fgt 1,2;
								local mp_1_`p'_`y'=`p1_`y'_2'-`p1_`y'_orig';//Observed MC;
								local mp_1_`p'_`y'_s=`p1_`y'_2'-`p1_`y'_3_st';//Star MC;
								local mp_2_`p'_`y'=`p2_`y'_2'-`p2_`y'_orig';//Observed MC;
								local mp_2_`p'_`y'_s=`p2_`y'_2'-`p2_`y'_3_st';//Star MC;
								forval i=1/2 {;
								****Poverty Impact effectiveness;
								****For Impact effectiveness with Transfers there can only be a positive effect;
								if `mp_`i'_`p'_`y''>0{;
								*Impact effectiveness;
								*Ystar already exists;
								*local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
								scalar eft_`i' =  (`mp_`i'_`p'_`y''/`mp_`i'_`p'_`y'_s');//MC/MCstar;
								
								local row=`row'+1;
								matrix p_ie_`y'[`ref_`p'_`i'',`col'] = eft_`i';
								****Poverty Spending effectiveness;
								tempvar bentouse;
								gen double `bentouse'=abs(`vtouse1'-`vtouse2');
								ceqbensp  [w=`w'], startinc(`vtouse2') ben(`bentouse') zz(`_pline') obj1(`p1_`y'_orig') obj2(`p2_`y'_orig');	
								matrix p_se_`y'[`ref_`p'_`i'',`col'] = r(sp_ef_pov_`i');


								};
			
								else{;
								local row=`row'+1;

								
								matrix p_ie_`y'[`ref_`p'_`i'',`col'] =.;
								matrix p_se_`y'[`ref_`p'_`i'',`col'] =.;
								};
								
								};
						tempvar benef;
							gen double `benef'=abs(`vtouse2'-`vtouse1');
							_fifgpmc `aw',benef(`benef')  startinc(`vtouse1') endinc(`vtouse2') z(`_pline');
							local rfi=`rfi_`p'';
							matrix fi_`y'[`rfi',`col']=MCEF_t;
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=MCEF_pc;
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=MCEF_n;
							
							
							*Beckerman Immervol ;

							ceqbeck `aw',preinc(`vtouse2') postinc(`vtouse1') zline(`_pline');
							
							
							
							 local rbk=`rbk_`p'';
							 local disp=r(VEE);
							 matrix bi_`y'[`rbk',`col']=r(VEE);//Vertical Expenditure Efficiency;
							local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=r(Spill);//Spillover Index;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=r(PRE);//Poverty Reduction Efficiency;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=r(PGE);//Poverty Gap Efficiency;
	
						
						
						};
					};
					cap drop `ystar';
					
					
				};
				
				
			
			
			
			
				};
			
			
				};
				
			};
			};
};//end quietly;
			#delimit cr	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		qui di "
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 4 // this one will stay fixed (column B)

		// Print information
		local date `c(current_date)'
		local titlesprint
		local titlerow = 7
		local trow1 = 9
		local trow2 = 27
		local trow3 = 45
		local trow4 =82

		local titlecol = 1
		local titlelist country surveyyear authors date 

		foreach y of local alllist {
			local startcol = `startcol_o'
			local titles`y'
			if "``y''"!="" {
				local r_g_ie=10
				local r_g_se=28
				local r_p_ie=12
				local r_p_se=30
				local r_fi=46
				local r_bi=83
				
				foreach x in g_ie g_se p_ie p_se fi bi{
				
				qui	putexcel D`r_`x''=matrix(`x'_`y') using `"`using'"',keepcellformat modify sheet("`sheet`y''")

				}
				
					foreach ext of local marg`y' {
						returncol `startcol'
						local titles1`y' `titles1`y'' `r(col)'`trow1'=(_d_`ext')
						local titles2`y' `titles2`y'' `r(col)'`trow2'=(_d_`ext')
						local titles3`y' `titles3`y'' `r(col)'`trow3'=(_d_`ext')
						local titles4`y' `titles4`y'' `r(col)'`trow4'=(_d_`ext')
						local startcol=`startcol'+1 
						
					}
				
				
				#delimit;
				local date `c(current_date)';		
				local titlesprint;
				local titlerow = 3;
				local titlecol = 1;
				local titlelist country surveyyear authors date ppp baseyear cpibase cpisurvey ppp_calculated;

				foreach title of local titlelist {;
				returncol `titlecol';
				if "``title''"!="" & "``title''"!="-1" 
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''");
				local titlecol = `titlecol' + 2;
				};
				qui putexcel `titlesprint'  `versionprint' `titles1`y'' `titles2`y'' `titles3`y'' `titles4`y'' using `"`using'"', modify keepcellformat sheet("`sheet`y''");

				#delimit cr
				
			}
		}
		}
    *********
    ** OPEN *
    *********
    if "`open'"!="" & "`c(os)'"=="Windows" {
         shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
    }
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {
         shell open `using'
    }
    else if "`open'"!="" & "`c(os)'"=="Unix" {
         shell xdg-open `using'
    }
	
	*************
	** CLEAN UP *
	*************
	quietly putexcel clear
	restore // note this also restores svyset
	
end	// END ceqefext










