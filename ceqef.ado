** ADO FILE FOR EFFECTIVENESS SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.3 03May2016 For use with Jul 2016 version of Output Tables
** v1.2 03Jan2016 For use with Jul 2016 version of Output Tables
*! (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

** CHANGES
**  v1.2 Added Spending effectiveness, changes in Spillover so it shows in Excel, FI/FGP results available for all income concepts
**  v1.3 Updated to produce no results for FI/FGP per capita and normalized per capita effectiveness indicator
**		 Fix the national poverty line specification to include both variables and scalar condition for Beckerman
**		 Add the weight local in subcommands

** NOTES
** No spending effectiveness. Results are not feasible for poverty using the whole system.

** TO DO
** See if other indicators can be used (or even make sense) for the system such as s-gini, 90/10, theil, etc.

************************
* PRELIMINARY PROGRAMS *
************************

#delimit cr
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

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
	
	if wordcount("`taxes'")==0{
	tempvar taxes
	gen `taxes'=0
	}
	if wordcount("`benef'")==0{
	tempvar benef
	gen `benef'=0
	}
	tempvar notax noben
	qui gen double `notax'=`endinc'+`taxes'
	qui gen double `noben'=`endinc'-`benef'
	
	*total taxes and transfers;
	 sum `taxes' [`weight' `exp']
	local T=abs(r(sum))
	 sum `benef' [`weight' `exp']
	local B=r(sum)
	local TB=`T'+`B'
	
	tempvar  d_fi d_fi_t d_fg d_fg_b
	
	qui gen `d_fi' = min(`startinc',`z') - min(`startinc',`endinc',`z')
	qui gen `d_fi_t' = min(`notax',`z') - min(`notax',`endinc',`z')
	
	*	qui gen `d_fi' = min(`y0',`z') - min(`y0',`y1',`z')
	*qui gen `d_fg' = min(`y1',`z') - min(`y0',`y1',`z')
	
	
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
		
		local `m'_mc_t=``m'_fi'-``m'_fi_t'
		
		
		local `m'_mc_b=``m'_fg_b'-``m'_fg'
		
		
		if `T'!=0 /*& (``m'_mc_t'>=0 & ``m'_mc_t'!=0)*/{
			local mceft_`m'=(`T'/`TB')*(1-(``m'_mc_t'/`T'))
		}
		else{
		local mceft_`m'=0
		}
		if `B'!=0 /*& (``m'_mc_b'>=0 & ``m'_mc_b'!=.)*/{
			local mcefb_`m'=(`B'/`TB')*((``m'_mc_b'/`B'))
		}
		else{
		local mcefb_`m'=0
		}
		
			local MCEF_`m'=`mceft_`m''+`mcefb_`m''
			scalar MCEF_`m'=`mceft_`m''+`mcefb_`m''
			return scalar MCEF_`m' = `mceft_`m''+`mcefb_`m''
		
		}
		

end // END _fifgpmc		
	

* Program to compute ideal tax for impact effectiveness
*generates income variable (ytaxstar) whith ideal taxes 
*rest of observations have no tax income
*var taxstar has the ideal tax for those obs. rest is missing

 
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
		*noisily di `cumf' //test to see if all transfer has been redistributed
		cap drop ____id_benstar
		cap drop ____ybenstar
		gen double ____id_benstar=`id_benstar'
		gen double ____ybenstar=`ybenstar'
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
			covgini `inc' [pw = `exp']
			local g_f=r(gini)
			covgini `o_inc' [pw = `exp']
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
			qui sum `pov`f'_o' [aw = `exp']
			local p`f'_o=r(mean)
			qui sum `pov`f'_f' [aw = `exp']
			local p`f'_f=r(mean)
			local mc`f'=`p`f'_o'-`p`f'_f'
			return scalar mc_p`f'=`mc`f'' //Marginal Contribution of poverty fgt:`f'
			}
		}
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
		covgini `inc' [pw = `exp']
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
				covgini `oi_`p'' [pw = `exp']
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
				covgini `oi_`p'' [pw = `exp']
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
			qui sum `gap' [aw = `exp']
			local prime=r(sum)
			qui sum `inter' [aw = `exp']
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
		sum `ben' [aw = `exp'];
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
								
								qui summ `fgt`fgt'_`p'' [aw = `exp'], meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
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
								
								qui summ `fgt`fgt'_`p'' [aw = `exp'], meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
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
							qui sum `gap' [aw = `exp'];
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
quietly {
tempvar difference
gen double `difference' = `postinc'-`preinc'
tempvar pre_shortfall
gen double `pre_shortfall' = `zline' - `preinc'
tempvar post_shortfall
gen double `post_shortfall' = `zline' - `postinc'

sum `difference' [`weight'=`exp'] if `preinc' < `zline'
scalar AB = r(sum)
summarize `difference' [`weight'=`exp']
scalar ABC = r(sum)
summarize `post_shortfall' [`weight'=`exp'] if `preinc' < `zline' & `postinc'>= `zline'
scalar B = -r(sum)
summarize `difference' [`weight'=`exp'] if `postinc' <  `zline'
scalar A1 = r(sum)
summarize `pre_shortfall' [`weight'=`exp'] if `preinc' <  `zline' & `postinc' >= `zline'
scalar A2 = r(sum)
scalar A = A1 + A2
summarize `pre_shortfall' [`weight'=`exp'] if `preinc' < `zline'
scalar AD = r(sum)
scalar VEE = AB/ABC
scalar Spillover = B/AB
scalar PRE = A/ABC
scalar PGE = A/AD

return scalar VEE=VEE
return scalar Spill = Spillover
return scalar PRE = PRE
return scalar PGE = PGE


}

end




*********************
* ceqef PROGRAM *
*********************

capture program drop ceqef
program define ceqef
	version 13.0   
	#delimit ;
	syntax 
		[using/]
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
			/* FISCAL INTERVENTIONS: */
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			COntribs(varlist)
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
			sheet(string)
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
			
			BASEyear(real -1)*
		]
	;

*****General Options;
* general programming locals;
	local dit display as text in smcl;
	local die display as error in smcl;
	local command ceqef;
	local version 1.3;
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to raranda@tulane.edu)";
	qui{;
	* weight (if they specified hhsize*hhweight type of thing);
	if strpos("`exp'","*")> 0 { ;
		`die' "Please use the household weight in {weight}, this will automatically be multiplied by the size of household given by {bf:hsize}";
		exit;
	};
	
	* hsize and hhid;
	if wordcount("`hsize' `hhid'")!=1 {;
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or ";
		`die' "{bf:hhid} (unique household identifier for individual-level data)";
		exit 198;
	};
	* make sure using is xls or xlsx;
	cap putexcel clear;
	if `"`using'"'!="" {;
		local period = strpos(`"`using'"',".");
		if `period'>0 { ;// i.e., if `"`using'"' contains .;
			local ext = substr(`"`using'"',`period',.);
			if "`ext'"!=".xls" & "`ext'"!=".xlsx" {;
				`die' "File extension must be .xls or .xlsx to write to an existing CEQ Master Workbook (requires Stata 13 or newer)";
				exit 198;
			};
		};
		else {;
			local using `"`using'.xlsx"';
			`dit' `"File extension of {bf:using} not specified, .xlsx assumed"';
		};
		// give error if file doesn't exist:;
		confirm file `"`using'"';
	};
	else {; // if "`using'"=="";
		`dit' "Warning: No file specified with {bf:using}, results saved in {bf:return list} but not exported to Output Tables";
	};
	if strpos(`"`using'"'," ")>0 & "`open'"!="" {; // has spaces in filename;
		`dit' `"Warning: `"`using'"' contains spaces, {bf:open} option will not be executed. File can be opened manually after `command' runs."';
		local open "";// so that it won't try to open below;
	};
	
	
	***********************
	* PRESERVE AND MODIFY *
	***********************;
	set type double;
	preserve;
	if wordcount("`if' `in'")!=0 quietly keep `if' `in';
	
	* collapse to hh-level data;
	if "`hsize'"=="" { ;// i.e., it is individual-level data;
		tempvar members;
		sort `hhid';
		qui bys `hhid': gen `members' = _N; // # members in hh ;
		qui bys `hhid': drop if _n>1; // faster than duplicates drop;
		local hsize `members';
	};
		* temporary variables;
	tempvar one;
	qui gen `one' = 1;
	**********************
	* SVYSET AND WEIGHTS *
	**********************;
	cap svydes;
	scalar no_svydes = _rc;
	if !_rc qui svyset ;// gets the results saved in return list;
	if "`r(wvar)'"=="" & "`exp'"=="" {;
		`dit' "Warning: weights not specified in svydes or the command";
		`dit' "Hence, equal weights (simple random sample) assumed";
	};
	else {;
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)';
		if "`exp'"!="" local w `exp';
		if "`w'"!="" {;
			tempvar weightvar;
			qui gen double `weightvar' = `w'*`hsize';
			local w `weightvar';
		};
		else local w "`hsize'";
		
		if "`w'"!="" {;
			local pw "[pw = `w']";
			local aw "[aw = `w']";
		};
		if "`exp'"=="" & "`r(wvar)'"!="" {;
			local weight "pw";
			local exp "`r(wvar)'";
		};
	};
	else if "`r(su1)'"=="" & "`psu'"=="" {;
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option";
		di as text "P-values will be incorrect if sample was stratified";
	};
	if "`psu'"=="" & "`r(su1)'"!="" {;
		local psu `r(su1)';
	};
	if "`strata'"=="" & "`r(strata1)'"!="" {;
		local strata `r(strata1)';
	};
	if "`strata'"!="" {;
		local opt strata(`strata');
	};
	* now set it:;
	if "`exp'"!="" qui svyset `psu' `pw', `opt';
	else           qui svyset `psu', `opt';

	**********
	* LOCALS *
	**********;
	
	* income concepts;
	local m `market';
	local mp `mpluspensions';
	local n `netmarket';
	local g `gross';
	local t `taxable';
	local d `disposable';
	local c `consumable';
	local f `final';
	local alllist m mp n g t d c f;
	local alllist2 m mp n g t d c f;
	local incomes = wordcount("`alllist'");
	local origlist m mp n g d;
	tokenize `alllist'; // so `1' contains m; to get the variable you have to do ``1'';
	local varlist "";
	local varlist2 "";
	local counter = 1;
	foreach y of local alllist {;
		local varlist `varlist' ``y''; // so varlist has the variable names;
		local varlist2 `varlist' ``y'2';
		// reverse tokenize:;
		local _`y' = `counter'; // so _m = 1, _mp = 2 (regardless of whether these options included);
		if "``y''"!="" local `y'__ `y' ;// so `m__' is e.g. m if market() was specified, "" otherwise;
		local ++counter;
	};

	local d_m      = "Market Income";
	local d_mp     = "Market Income + Pensions";
	local d_n      = "Net Market Income";
	local d_g      = "Gross Income";
	local d_t      = "Taxable Income";
	local d_d      = "Disposable Income";
	local d_c      = "Consumable Income";
	local d_f      = "Final Income";
	foreach y of local alllist {;
		if "``y''"!="" {;
			scalar _d_``y'' = "`d_`y''";
		};
	};
	
	* negative incomes;
	foreach v of local alllist {;
		if "``v''"!="" {;
			qui count if ``v''<0; 
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''";
		};
	};	
	#delimit cr
	* poverty lines
	local povlines `pl1' `pl2' `pl3' `nationalextremepl' `nationalmoderatepl' `otherextremepl' `othermoderatepl'
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

	* transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	* columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind alltaxes alltaxescontribs alltransfers 
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	**********
	*Tax and Transfer options between core income concepts
	**********
	tempvar taxdif
	gen double  `taxdif'=`taxable'-`gross' 
	replace `taxdif'=0 if  (`taxdif')>0
	replace `taxdif'=abs(`taxdif')
	**********
	*Market Income
	**********
	*From Market income to Market Income plus pensions
	tempvar /*tax_m_mp*/ ben_m_mp
	*gen double `tax_m_mp'=0
	egen double `ben_m_mp'=rsum(`pensions')
	*From Market income to Net Market Income
	tempvar tax_m_n ben_m_n
	egen double `tax_m_n'=rsum(`dtaxes')
	egen double `ben_m_n'=rsum(`pensions')
	*From Market income to Gross Income
	tempvar /*tax_m_g*/ ben_m_g
	*gen double `tax_m_g'=0
	egen double `ben_m_g'=rsum(`pensions' `dtransfers')
	*From Market income to Taxable Income
	tempvar tax_m_t ben_m_t
	gen double `tax_m_t'=`taxdif'
	egen double `ben_m_t'=rsum(`pensions' `dtransfers')
	*From Market income to Disposable Income
	tempvar tax_m_d ben_m_d
	egen double `tax_m_d'=rsum(`dtaxes')
	egen double `ben_m_d'=rsum(`pensions' `dtransfers')
	*From Market income to Consumable Income
	tempvar tax_m_c ben_m_c
	egen double `tax_m_c'=rsum(`dtaxes' `indtaxes')
	egen double `ben_m_c'=rsum(`pensions' `dtransfers' `subsidies')
	*From Market income to Final Income
	tempvar tax_m_f ben_m_f
	egen double `tax_m_f'=rsum(`dtaxes' `indtaxes')
	egen double `ben_m_f'=rsum(`pensions' `dtransfers' `subsidies' `inkind')
	
	**********
	*Market Income plus Pensions
	**********
	*From Market income plus Pensions to Net Market Income
	tempvar tax_mp_n /*ben_mp_n*/
	egen double `tax_mp_n'=rsum(`dtaxes')
	*gen double `ben_mp_n'=0
	*From Market income plus Pensions to Gross Income
	tempvar /*tax_mp_g*/ ben_mp_g
	*gen double `tax_mp_g'=0
	egen double `ben_mp_g'=rsum(`dtransfers')
	*From Market income plus Pensions to Taxable Income
	tempvar tax_mp_t ben_mp_t
	gen double `tax_mp_t'=`taxdif'
	egen double `ben_mp_t'=rsum(`dtransfers')
	*From Market income plus Pensions to Disposable Income
	tempvar tax_mp_d ben_mp_d
	egen double `tax_mp_d'=rsum(`dtaxes')
	egen double `ben_mp_d'=rsum(`dtransfers')
	*From Market income plus Pensions to Consumable Income
	tempvar tax_mp_c ben_mp_c
	egen double `tax_mp_c'=rsum(`dtaxes' `indtaxes')
	egen double `ben_mp_c'=rsum(`dtransfers' `subsidies')
	*From Market income plus Pensions to Final Income
	tempvar tax_mp_f ben_mp_f
	egen double `tax_mp_f'=rsum(`dtaxes' `indtaxes')
	egen double `ben_mp_f'=rsum(`dtransfers' `subsidies' `inkind')
	
	**********
	*Net Market Income 
	**********
	*From Net Market income to Gross Income
	tempvar tax_n_g ben_n_g
	gen double `tax_n_g'=`tax_m_d'
	egen double `ben_n_g'=rsum(`dtransfers' ) 
	*replace `ben_n_g'=`ben_n_g'-abs(`tax_m_d')
	*From Net Market income to Taxable Income
	tempvar tax_n_t ben_n_t dtr 
	egen double `dtr'=rsum(`dtransfers')
	
	gen double `tax_n_t'=`taxdif'+ abs(`dtr')
	egen double `ben_n_t'=rsum(`dtransfers')
	*From Net Market income to Disposable Income
	tempvar /*tax_n_d*/ ben_n_d
	*gen double `tax_n_d'=0
	egen double `ben_n_d'=rsum(`dtransfers')
	*From Net Market income to Consumable Income
	tempvar tax_n_c ben_n_c
	egen double `tax_n_c'=rsum(`indtaxes')
	egen double `ben_n_c'=rsum(`dtransfers' `subsidies')
	*From Net Market income to Final Income
	tempvar tax_n_f ben_n_f
	egen double `tax_n_f'=rsum(`indtaxes')
	egen double `ben_n_f'=rsum(`dtransfers' `subsidies' `inkind')
	
	**********
	*Gross Income 
	**********

	*From Gross income to Taxable Income
	tempvar tax_g_t /*ben_g_t*/
	gen double `tax_g_t'=`taxdif'
	*gen double `ben_g_t'=0
	*From Gross income to Disposable Income
	tempvar tax_g_d /*ben_g_d*/
	egen double `tax_g_d'=rsum(`dtaxes')
	*gen double `ben_g_d'=0
	*From Gross income to Consumable Income
	tempvar tax_g_c ben_g_c
	egen double `tax_g_c'=rsum(`dtaxes' `indtaxes')
	egen double `ben_g_c'=rsum(`subsidies')
	*From Gross income to Final Income
	tempvar tax_g_f ben_g_f
	egen double `tax_g_f'=rsum(`dtaxes' `indtaxes')
	egen double `ben_g_f'=rsum(`subsidies' `inkind')
	
	**********
	*Taxable Income 
	**********

	*From Taxable income to Disposable Income

	tempvar tax_t_d ben_t_d
	egen double `tax_t_d'=rsum(`dtaxes')
	gen double `ben_t_d'=`taxdif'
	*From Taxable income to Consumable Income
	tempvar tax_t_c ben_t_c
	egen double `tax_t_c'=rsum(`dtaxes' `indtaxes')
	egen double `ben_t_c'=rsum(`taxdif' `subsidies')
	*From Taxable income to Final Income
	tempvar tax_t_f ben_t_f
	egen double `tax_t_f'=rsum(`dtaxes' `indtaxes')
	egen double `ben_t_f'=rsum(`taxdif' `subsidies' `inkind')	
	
	**********
	*Disposable Income 
	**********
	*From Disposable income to Consumable Income
	tempvar tax_d_c ben_d_c
	egen double `tax_d_c'=rsum(`indtaxes')
	egen double `ben_d_c'=rsum(`subsidies')
	*From Disposable income to Final Income
	tempvar tax_d_f ben_d_f
	egen double `tax_d_f'=rsum(`indtaxes')
	egen double `ben_d_f'=rsum(`subsidies' `inkind')
	
	**********
	*Consumable Income 
	**********
	*From Consumable income to Final Income
	tempvar /*tax_c_f*/ ben_c_f
	*gen double `tax_c_f'=0
	egen double `ben_c_f'=rsum(`subsidies' `inkind')
	
	******Rows******
	local rw_ie_pl1_1=3
	local rw_ie_pl1_2=4
	local rw_ie_pl2_1=5
	local rw_ie_pl2_2=6
	local rw_ie_pl3_1=7
	local rw_ie_pl3_2=8
	local rw_ie_nationalextremepl_1=9
	local rw_ie_nationalextremepl_2=10
	local rw_ie_nationalmoderatepl_1=11
	local rw_ie_nationalmoderatepl_2=12
	local rw_ie_otherextremepl_1=13
	local rw_ie_otherextremepl_2=14
	local rw_ie_othermoderatepl_1=15
	local rw_ie_othermoderatepl_2=16
	
	local rw_se_pl1_1=19
	local rw_se_pl1_2=20
	local rw_se_pl2_1=21
	local rw_se_pl2_2=22
	local rw_se_pl3_1=23
	local rw_se_pl3_2=24
	local rw_se_nationalextremepl_1=25
	local rw_se_nationalextremepl_2=26
	local rw_se_nationalmoderatepl_1=27
	local rw_se_nationalmoderatepl_2=28
	local rw_se_otherextremepl_1=29
	local rw_se_otherextremepl_2=30
	local rw_se_othermoderatepl_1=31
	local rw_se_othermoderatepl_2=32
	*For Beckerman Imervoll
	local rbk_pl1=33
	local rbk_pl2=37
	local rbk_pl3=41
	local rbk_nationalextremepl=45
	local rbk_nationalmoderatepl=49
	local rbk_otherextremepl=53
	local rbk_othermoderatepl=57
	*For FI/FGP
	local rfi_pl1=62
	local rfi_pl2=65
	local rfi_pl3=68
	local rfi_nationalextremepl=71
	local rfi_nationalmoderatepl=74
	local rfi_otherextremepl=77
	local rfi_othermoderatepl=80
	

	
	* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" {
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
			}
		}	
	}
	
	#delimit;
	*******General Options*********;
	if `"`weight'"' != "" {;
		local wgt `"[`weight'`exp']"';
    };
	
	if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)';
	if "`exp'"!="" local w `exp';
	if "`w'"!="" {;
		tempvar weightvar;
		qui gen `weightvar' = `w'*`hsize';
		local w `weightvar';
	};
	else local w "`hsize'";
		if "`w'"!="" {;
		local pw "[pw = `w']";
		local aw "[aw = `w']";
	};
	
	
	*Effectiveness matrices for each income concept;
	foreach y of local 	alllist{;//generate matrices for results;
		matrix `y'_ef = J(82,8,.);
	};
	
	
	*Calculate Effectiveness indicators;
	foreach rw of local 	alllist{;//row income concept;
		foreach cc of local alllist{;//column income concept;	
			if ("`rw'" !="`cc'") & (`_`rw''<`_`cc'') {;
			****TAXES AND TRANSFERS for R and N;
			
			if "`tax_`rw'_`cc''"!=""{;
				tempvar taxesef;
				gen double `taxesef'=abs(`tax_`rw'_`cc'');
			};
			if "`ben_`rw'_`cc''"!=""{;
				tempvar benef;
				gen double `benef'=`ben_`rw'_`cc'';
			};
			local yes= wordcount("`benef'")+wordcount("`taxesef'");
			if (wordcount("`tax_`rw'_`cc''")>0 | wordcount("`ben_`rw'_`cc''")>0){; //ESTIMATE EFFECTIVENESS INDICATORS FOR CASES THAT APPLY;
				*impact effectiveness;
				/*if wordcount("`benef'")>0{;
					ceqbenstar [w=`w'], endinc(``cc'') ben(`benef');
				};
				if wordcount("`taxesef'")>0{;
					ceqtaxstar [w=`w'], endinc(``cc'') taxes(`taxesef');
				};*/
				if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")>0{;
					tempvar ystar;
					gen double `ystar'=``rw'';
					
					ceqtaxstar [w=`w'], startinc(``rw'') taxes(`taxesef');			
					ceqbenstar [w=`w'], startinc(``rw'') ben(`benef');
					replace `ystar'=____ybenstar if ____id_benstar==1 & ____id_taxstar!=1;
					replace `ystar'=____ytaxstar if ____id_taxstar==1 & ____id_benstar!=1;
					tempvar temptax;
					gen double	`temptax'=``rw''-	____ytaxstar if ____id_benstar==1 & ____id_taxstar==1;			
					tempvar tempben;
					gen double	`tempben'=	____ybenstar - ``rw'' if ____id_benstar==1 & ____id_taxstar==1;
					replace `ystar'=``rw'' - `temptax' +`tempben' if ____id_benstar==1 & ____id_taxstar==1;			
					cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar ;
					cap drop `temptax' `tempben';
				};
				if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
					ceqtaxstar [w=`w'], startinc(``rw'') taxes(`taxesef');
					tempvar ystar;
					gen double `ystar'=____ytaxstar;
					cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar;

				};
				if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
					ceqbenstar [w=`w'], startinc(``rw'') ben(`benef');					
					tempvar ystar;
					gen double `ystar'=____ybenstar;
					cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar;

				};
				covgini ``cc'' `pw';//gini of column income;
				local g1_`cc'=r(gini);
				di "`rw' ``rw''";
				covgini ``rw'' `pw';//gini of row income;
				local g2_`rw'=r(gini);
				covgini `ystar' `pw';//gini of star income;
				local g_star=r(gini);
				local imef=(`g2_`rw''-`g1_`cc'')/(`g2_`rw''-`g_star');
				matrix `rw'_ef[1,`_`cc'']=`imef';
				*noisily di in red "INEQ IMPACT EFF. `rw' `cc' Row= `row'";
			
		*IMPACT EFFECTIVENESS FOR POVERTY (WHEN THERE IS ONLY TAXES OR ONLY TRANSFERS);	
		*Convert to ppp;
		if "`tax_`rw'_`cc''"!=""{;
				tempvar int_tax;
				gen double `int_tax'=abs(`tax_`rw'_`cc'');
				
				tempvar int_tax_ppp;
				gen double  `int_tax_ppp'=(`int_tax'/`divideby')*(1/`ppp_calculated');
			};
			if "`ben_`rw'_`cc''"!=""{;
				tempvar int_ben;
				gen double `int_ben'=`ben_`rw'_`cc'';
				tempvar int_ben_ppp;
				gen double  `int_ben_ppp'=(`int_ben'/`divideby')*(1/`ppp_calculated');
			};
			
		/*tempvar int_tax;
		gen double `int_tax'=abs(`tax_`rw'_`cc'');
		tempvar int_ben;
		gen double `int_ben'=`ben_`rw'_`cc'';

		 tempvar int_tax_ppp;
		 gen double  `int_tax_ppp'=(`int_tax'/`divideby')*(1/`ppp_calculated');
		 
		 tempvar int_ben_ppp;
		 gen double  `int_ben_ppp'=(`int_ben'/`divideby')*(1/`ppp_calculated');
		 */
		 tempvar `rw'_ppp;
		 gen double ``rw'_ppp'=(``rw''/`divideby')*(1/`ppp_calculated');
		 tempvar `cc'_ppp;
		 gen double ``cc'_ppp'=(``cc''/`divideby')*(1/`ppp_calculated');
		 tempvar ystar_ppp;
		 gen double `ystar_ppp'=(`ystar'/`divideby')*(1/`ppp_calculated');
		 local row=2;
		*noisily di in red "Begin of POV IMPACT EFF. `rw' `cc' Row= `row'";

		*Only taxes MC<0 so harm formula);
		if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
		*if wordcount("`ben_`rw'_`cc''")==0) & wordcount("`tax_`rw'_`cc''")>0 {;
		foreach p in `plopts'{;
		if "``p''"!=""{;
			if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
								local _pline = ``p'';
								local vtouse1 ``cc'_ppp';//1 is for original;
								local vtouse2 ``rw'_ppp';//2 is for income without intervention;
								local vtouse3 `ystar_ppp';//3 is for ideal income; 
							};
							else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
								local _pline = ``p''; // set `_pline' as that scalar and;
								local vtouse1 ``cc''   ;// use original income variable;
								local vtouse2 ``rw'';//income without intervention;
								local vtouse3 `ystar';//income with ideal intervention;
							};
							else if _`p'_isscalar==0 {; // if pov line is variable,;
								tempvar `v'_normalized1 ; // create temporary variable that is income...;
								tempvar `v'_normalized2 ; // create temporary variable that is income...;
								tempvar `v'_normalized3 ; // create temporary variable that is income...;
								
								qui gen ``v'_normalized1' = ``cc''/``p'' ;// normalized by pov line;   
								qui gen ``v'_normalized2' = ``rw''/``p'' ;// normalized by pov line;
								qui gen ``v'_normalized3' = `ystar'/``p'' ;// normalized by pov line;
								
								local _pline = 1            ;           // and normalized pov line is 1;
								local vtouse1 ``v'_normalized1'; // use normalized income in the calculations;
								local vtouse2 ``v'_normalized2'; // use normalized income in the calculations;
								local vtouse3 ``v'_normalized3'; // use normalized income in the calculations;
							};
			
			tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt1_3 zyzfgt2_3 ;
							qui gen `zyzfgt1_1' = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_1' = `zyzfgt1_1'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_2' = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_2' = `zyzfgt1_2'^2 ;                           // square of normalized poverty gap;
							qui gen `zyzfgt1_3' = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
							qui gen `zyzfgt2_3' = `zyzfgt1_3'^2 ;                           // square of normalized poverty gap;
							
							forval i=1/2 {;
								qui summ `zyzfgt`i'_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p`i'_orig=r(mean);
								qui summ `zyzfgt`i'_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p`i'_wo=r(mean);
								qui summ `zyzfgt`i'_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p`i'_3=r(mean);
								
								drop  `zyzfgt`i'_3' `zyzfgt`i'_2' `zyzfgt`i'_1';
							
								****Poverty Impact effectiveness;
								//Marginal contributions for fgt 1,2;
								local mp_`i'_`p'_`rc'=`p`i'_2_wo'-`p`i'_orig';//Observed MC;
							
								****For Impact effectiveness there can only be a negative effect, we use the harm formula Ch. 5 CEQ Handbook;
								if `mp_`i'_`p'_`rc''<0{;
								ceqtaxharm [w=`w'], endinc(``cc'') taxes(`int_tax');			
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
								qui gen ``v'_normalizedh' = `yharm'/``p'' ;// normalized by pov line;  
								local _pline = 1            ;           // and normalized pov line is 1;
								local vtouseh ``v'_normalizedh'; // use normalized income in the calculations;					
								};
							
							
								tempvar zyzfgt1_h zyzfgt2_h;
								qui gen `zyzfgt1_h' = max((`_pline'-`vtouseh')/`_pline',0) ;// normalized povety gap of each individual;
								qui gen `zyzfgt2_h' = `zyzfgt1_h'^2 ;                           // square of normalized poverty gap;							
								
								
								qui summ `zyzfgt`i'_h' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p`i'_h=r(mean);
								
								local mst_p`i'_h=`p`i'_3' - `p`i'_h';//Ideal MC with tax formula;
								local eft_`i'_h=(`mp_`i'_`p'_`rc''/`mst_p`i'_h')*(-1);
								*return scalar eft_`i'_h =  `eft_`i'_h';//Impact effectiveness indicator, v has the variable name of the transfer, y=income, p=poverty line ;
								
								local row=`row'+1;								
								matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = `eft_`i'_h';

								*noisily di in green "Doing POV IMPACT EFF. TAXES `rw' `cc' Row= `row'";

								/*local row=`row'+1;
								matrix p_ie_`y'[`row',`col'] = `eft_2_h';
								matrix p_se_`y'[`row',`col'] = .;*/
								};
								};
								
								else{;
								local row=`row'+1;

								matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] =.;
		
								};
		};
		
		};
		};
		};
		*Only Benefits;
		local rowsp=18;
		if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
		if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
					foreach p in `plopts'  { ;// plopts includes all lines;
						if "``p''"!="" {	;
						if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
								local _pline = ``p'';
								local vtouse1 ``cc'_ppp';//1 is for original;
								local vtouse2 ``rw'_ppp';//2 is for income without intervention;
								local vtouse3 `ystar_ppp';//3 is for ideal income; 
							};
							else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
								local _pline = ``p''; // set `_pline' as that scalar and;
								local vtouse1 ``cc''   ;// use original income variable;
								local vtouse2 ``rw'';//income without intervention;
								local vtouse3 `ystar';//income with ideal intervention;
							};
							else if _`p'_isscalar==0 {; // if pov line is variable,;
								tempvar `v'_normalized4 ; // create temporary variable that is income...;  
								tempvar `v'_normalized5 ; // create temporary variable that is income...;
								tempvar `v'_normalized6 ; // create temporary variable that is income...;

								qui gen ``v'_normalized4' = ``cc''/``p'' ;// normalized by pov line;  
								qui gen ``v'_normalized5' = ``rw''/``p'' ;// normalized by pov line;
								/*qui gen ``v'_normalized2' = `ext'/``p'' ;// normalized by pov line;*/
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
							
							drop  `zyzfgt1_3' `zyzfgt1_2' `zyzfgt1_1' `zyzfgt2_3' `zyzfgt2_2' `zyzfgt2_1';
								
								//Marginal contributions for fgt 1,2;
								local mp_1_`p'=`p1_`y'_2'-`p1_`y'_orig';//Observed MC;
								local mp_1_`p'_s=`p1_`y'_2'-`p1_`y'_3_st';//Star MC;
								local mp_2_`p'=`p2_`y'_2'-`p2_`y'_orig';//Observed MC;
								local mp_2_`p'_s=`p2_`y'_2'-`p2_`y'_3_st';//Star MC;
								
								
						
								****Poverty Impact effectiveness;
								****For Impact effectiveness with Transfers there can only be a positive effect;
									forval i=1/2 {;
								if `mp_`i'_`p''>0{;
								*Impact effectiveness;
								*Ystar already exists;
								*local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
								scalar eft_`i' =  (`mp_`i'_`p''/`mp_`i'_`p'_s');//MC/MCstar;
								
								local row=`row'+1;
								matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = eft_`i';	
																

								local rowsp=`rowsp'+1;

								****Poverty Spending effectiveness;
								tempvar bentouse;
								gen double `bentouse'=abs(`vtouse1'-`vtouse2');
								
								ceqbensp  [w=`w'], startinc(`vtouse2') ben(`bentouse') zz(`_pline') obj1(`p1_`y'_orig') obj2(`p2_`y'_orig');	
								matrix `rw'_ef[`rw_se_`p'_`i'',`_`cc''] = r(sp_ef_pov_`i');	

								
								};
								else{;
									local row=`row'+1;
									matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = .;			
									local rowsp=`rowsp'+1;
									matrix `rw'_ef[`rw_se_`p'_`i'',`_`cc''] = .;
								};
							*noisily di in green "Doing POV IMPACT EFF. BEN `rw' `cc' Row= `row'";

								
								};
		
		};
		
		};
		};
		};
		
		*noisily di in red "End of POV IMPACT EFF. `rw' `cc' Row= `row'";
		};
		
		*SPENDING EFFECTIVENESS FOR INEQUALITY;
		
		local row=17;
		*Only TAXES with  MC>0 , with poverty it never happens with taxes;
		if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
		_ceqmcid `pw', inc(``cc'') sptax(`int_tax') ;
					*If Marg. Cont. is negative, SE is missing;
					if r(mc_ineq)<0{;
						matrix `rw'_ef[17,`_`cc''] = .;
					};
					else{;
						_ceqspend [w=`w'],inc(``cc'') sptax(`int_tax');
						local spef=r(sp_ef);
						matrix `rw'_ef[17,`_`cc''] =`spef';

					};
		};
		
		
		
				*Only TRANSFERS with  MC>0 ;

		if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
		*Spending Effectiveness;
					_ceqmcid `pw', inc(``cc'') spben(`int_ben') ;
					*If Marg. Cont. is negative, SE is missing;
					if r(mc_ineq)<0{;
						matrix `rw'_ef[17,`_`cc''] = .;
					};
					else{;
						_ceqspend [w=`w'],inc(``cc'') spben(`int_ben');
						local spef=r(sp_ef);
						matrix `rw'_ef[17,`_`cc''] =`spef';

					};
		};
		*Beckerman Imervoll Effectiveness Indicators (row 2 to 30);
		local row=33;
		*noisily di in red "Begin of BECK EFF. `rw' `cc' Row= `row'";
		// line 1608 to 1621 updated by Rosie on May 3rd, 2017;
		foreach p in `plopts'{;
			if "``p''"!=""{;
				if substr("`p'",1,2)!="pl" {; // these are the national PL;
					if _`p'_isscalar==1 { ; 
						local z= (``p''/`divideby')*(1/`ppp_calculated');
					};
					else if _`p'_isscalar==0 {;
						tempvar z;
						qui gen `z'= (``p''/`divideby')*(1/`ppp_calculated');
					};
				};	
				if substr("`p'",1,2)=="pl" {; // these are the national PL;
					local z= ``p'';
				};	
			
			ceqbeck `aw',preinc(``rw'_ppp') postinc(``cc'_ppp') zline(`z');
			local rowbk=`rbk_`p'';
				matrix `rw'_ef[`rowbk',`_`cc'']=r(VEE);//Vertical Expenditure Efficiency;
				local rowbk=`rowbk'+1;
				matrix `rw'_ef[`rowbk',`_`cc'']=r(Spill);//Spillover Index;
				local rowbk=`rowbk'+1;
				matrix `rw'_ef[`rowbk',`_`cc'']=r(PRE);//Poverty Reduction Efficiency;
				local rowbk=`rowbk'+1;
				matrix `rw'_ef[`rowbk',`_`cc'']=r(PGE);//Poverty Gap Efficiency;
				local rowbk=`rowbk'+1;
				
			
		};
		else{;
		local row=`row'+4;
		};
		};
	*noisily di in red "End of BECK EFF. `rw' `cc' Row= `row'";

	*FI/FGP (row 62 to  to 82);
	local row=62;
				*noisily di in red "Begin of FI/FGP EFF. `rw' `cc' Row= `row'";

	****TAXES AND TRANSFERS for R and N;
			if "`tax_`rw'_`cc''"!=""{;
				tempvar taxesef;
				gen double `taxesef'=abs((`tax_`rw'_`cc''/`divideby')*(1/`ppp_calculated'));
			};
			if "`ben_`rw'_`cc''"!=""{;
				tempvar benef;
				gen double `benef'=(`ben_`rw'_`cc''/`divideby')*(1/`ppp_calculated');
			};
			
			local yes= wordcount("`tax_`rw'_`cc''")+wordcount("`ben_`rw'_`cc''");
			if `yes'>0{; //ESTIMATE EFFECTIVENESS INDICATORS FOR CASES THAT APPLY;
				foreach p in `plopts'{;
				if "``p''"!=""{;
				if substr("`p'",1,2)!="pl" {; // these are the national PL;
						local z= (``p''/`divideby')*(1/`ppp_calculated');
					};	
					if substr("`p'",1,2)=="pl" {; // these are the national PL;
						local z= ``p'';
					};
					*FI/FGP effectiveness;
					
					if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")>0{;
						_fifgpmc `aw',taxes(`taxesef') benef(`benef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
						local rowfi=`rfi_`p'';
						matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
		
					};
					if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
							*noisily di in green "HEEEEEEEEEEEEEEREEEEE" in red "`rw' to `cc'";

						*set trace on;
						_fifgpmc `aw',taxes(`taxesef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
						local rowfi=`rfi_`p'';
						matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
						
				
						*set trace off;
						*noisily di r(MCEF_t);
						*noisily di r(MCEF_pc);
						*noisily di r(MCEF_n);
						};
					if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
						_fifgpmc `aw', benef(`benef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
					local rowfi=`rfi_`p'';
						matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
						matrix `rw'_ef[`rowfi',`_`cc'']=.;
						local rowfi=`rowfi'+1;
								
						*noisily di in green "FI/FGP INCOME COL:`cc':`_`cc'', row: `row', real col: `_`cc''";
					};
				};
				*else{;
				*local row=`row'+3;
				*};
				};
			};
		
			*noisily di in red "End of FI/FGP EFF. `rw' `cc' Row= `row'";

		};
		};
		*noisily matrix list `rw'_ef;
	};
	
	
	****************
	* SAVE RESULTS *
	****************;
		if `"`using'"'!="" {;
			`dit' `"Writing to "`using'", may take several minutes"';
		
			if "`sheet'"=="" local sheet=`"E9. Effectiveness"';	
			*Rows for core income concept results;	
			/*local r_m=11;
			local r_mp=64;
			local r_n=117;
			local r_g=170;
			local r_t=223;
			local r_d=276;
			local r_c=329;
			local r_f=382;*/
			
			local r_m=11;
			local r_mp=95;
			local r_n=179;
			local r_g=263;
			local r_t=347;
			local r_d=431;
			local r_c=515;
			local r_f=599;
			foreach y of local 	alllist{;
			qui	putexcel D`r_`y''=matrix(`y'_ef) using `"`using'"',keepcellformat modify sheet("`sheet'") ;

			};
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
				qui putexcel `titlesprint'  using `"`using'"', modify keepcellformat sheet("`sheet'");

			qui	putexcel A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'") using `"`using'"',  modify keepcellformat  sheet("`sheet'");  

			
		
		};
    ********
    * OPEN *
    ********;
		if "`open'"!="" & "`c(os)'"=="Windows" {;
			shell start `using'; // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, ;
		};
		else if "`open'"!="" & "`c(os)'"=="MacOSX" {;
			shell open `using';
		};
		else if "`open'"!="" & "`c(os)'"=="Unix" {;
			shell xdg-open `using';
		};
	
	************
	* CLEAN UP *
	************;
		quietly putexcel clear;
		restore;
	};
	
	end;	// END ceqef;

	
