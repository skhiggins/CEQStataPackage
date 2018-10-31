		*set trace on
		clear all
//         global clear
        set more off
		*update all
	    *ssc install ceq, replace
*--------------------------------------------------------------------------------------------
* Country: CEQ XXX 20XX
* Author of the do file: XXX 
* Date: XXX XXth, 20XX
*THE DO FILE IS ELABORATED FOR RUNINIG THE ADO FILES AT HOUSEHOLD LEVEL AND FOR PERCAPITA AND ADULT EQUIVALENT ESCALES
*--------------------------------------------------------------------------------------------

		*STEPS FOR USING THIS ADO FILE
			*1. Fill in Information on Directories 
			*2. Fill in information on the data set
			*3. Make changes to the data set if any is needed. This varies from country to country. 
			*4. Fill in Information of the Study
			*5. Prepare the information needed to run ceq stata package
			*6. Run the ado files
						
****************************************************************************************************************************
*1.- Fill in Information on Directories 
****************************************************************************************************************************

	*____________________________________________________________________
	   
	   local IOS=1  // Change this to 0 when using windows
	*____________________________________________________________________
	
	********************************************************************************************
// 	if `IOS'== 1 {
// 	    global path  "/Users/CrisCarrera/Dropbox (Personal)/CEQ/Re_Runs Monitoring/Uruguay/Deliveries/Mar21_2018/"
// 		global data  "${path}3.DATA/Original/proc/"
// 		global mod   "${path}3.DATA/CreatedByCEQ/CC/"
// 		global do    "${path}4.DO FILES/CreatedByCEQ/CC/"
// 		global MWB   "${path}1.WORKBOOKS/CreatedByCEQ/CC/MWB E/Data_Mod/TestE13/"
// 		global Graphs "${MWB}Graphs/"
// }
// 	if `IOS'== 0 {	
// 	    global path   "Agregar dirección de path para windows"
// 		global data  "${path}3. Household Surveys & Admin Account Data\MicroData\Encovi 2014\"
// 		global mod   "${path}3. Household Surveys & Admin Account Data\MicroData\Datamodified\2014New\"
// 		global do    "${path}5. DO FILES\"
// 	}
****************************************************************************************************************************
*2.- Fill in information on the data set
		//use "${data}UY CEQ database 2009.dta", clear
		use "UY CEQ database 2009.dta", clear
		
		capture log close
		log using test-issue#36.log, replace
// 		log using "${MWB}URY_July17.log", replace

****************************************************************************************************************************
*3.- Make changes to the data set if any is needed. This varies from country to country. 

****************************************************************************************************************************
*4.- Fill in Information on the Study
****************************************************************************************************************************

		local PPP=2005 // Change this to 2011 when using PPP 2011

		local ISOcountry  URY    // ISO Letters of the country
		local survey  "2009"   //Year of the study, generally is the same year of the survey year
		local base   `PPP' //Year of PPP it can be 2005 or 2011, if using 2011 do not forger to change the poverty line in each command. 

****************************************************************************************************************************
*5.- Prepare the information needed to run ceq stata package
	*Study
		local country 	 "Uruguay"
		local authors    "XXXX"
		local baseyear   `PPP'
		local surveyyear `survey'
		local group     "National"
		local scenario  "PDI"
		local project  "Re-runs"

	*Survey
		local hsize   "hsize"
		local hhid    "hhid"
		local w 	"weight"
		local psu "psu"		 
		local strata "strata"
		
	*Cuts

	if `PPP'==2005 {
		local cut1 "1.25"
		local cut2 "2.50"
		local cut3 "4.00"
	}

	if `PPP'==2011 {
		local cut1 "1.90"
		local cut2 "3.20"
		local cut3 "5.50"
	}

	*Information on PPP convertion factore
	ceqppp , country(`ISOcountry') baseyear(`base') surveyyear(`survey') locals
	local period "yearly"

	*************************************
	*Special modifications for each country 
	
	gen con_frlx_ri=1 if con_frlx_pc!=0
	g edu_prim_pc=edu_prim_hh/hsize
	gen edu_prim_ri=1 if edu_prim_pc!=0
	
	gen edu_sec_ti=1 if (edu_lose_ti==1  | edu_upse_ti==1)
	replace edu_sec_ti=0 if missing(edu_sec_ti)
	
	*************************************

	*************************************
	*Checking of general variables 
	
	des hhid we* psu str* urb* hs* memb* rel* age gen* at* level* type* pline* inf* 
	//br hhid hs* memb* rel*
	//tab  /*psu str*/ hs* adult* /*memb*/ age /* pline*/
// 	codebook /* urb*/ rel* gen* at* level* /*type*/ inf* 

	*************************************


	local ym  "ym_pc"
	local yp  "yp_pc"
	local yn  "yn_pc" 
	local yt  "yt_pc"
	local yg  "yg_pc"
	local yd  "yd_pc"
	local yc  "yc_pc"
	local yf  "yf_pc"

	local nationale "pline_ext"
	local nationalm "pline_mod"
	
	local pen "pen_jubx_pc"
	local dtx "dtx_pitx_pc"
	local con "con_ssxx_pc con_pats_pc con_hsxx_pc con_frlx_pc con_path_pc con_patf_pc"
	local dtr "dtr_ncpx_pc dtr_afam_pc dtr_optx_pc dtr_food_pc"
    //local sub "XXX"	
	local itx "itx_vatx_pc itx_exci_pc"	
	local edu "edu_care_pc edu_pres_pc edu_prim_pc edu_lose_pc edu_upse_pc edu_terc_pc"
	local hlt "hlt_snis_pc hlt_nonc_pc"
	//local oth "XXX"
	
	*************************************
	des `pen' `dtx' `con' `dtr' `sub' `itx' `edu' `hlt'
	*************************************
	
// 	tabstat `pen' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtx' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `con' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtr' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	//tabstat `sub' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `itx' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `edu' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `hlt' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	//tabstat `oth' [w=`w'], stat(sum) format(%15.0fc) col(stat)
//
	tabstat `ym' `yp' `yn' `yt' `yg' `yd' `yc' `yf'[w=`w'], stat(sum) format(%15.0fc) col(stat)
	
	local pen_18 "`pen'"
	local dtx_18 "`dtx'"
	local con_18 "`con'" 
	local dtr_18 "`dtr'" 
    //local sub_18 "XXX"	
	local itx_18 "`itx'"	
	local edu_18 "`edu'"
	local hlt_18 "`hlt'"
	//local oth_18 "XXX"
	
	
	local pen_r "pen_jubx_ri"
	local dtx_r "dtx_pitx_ri"
	local con_r "con_ssxx_ri con_pats_ri con_hsxx_ri con_frlx_ri con_path_ri con_patf_ri"
	local dtr_r "dtr_ncpx_ri dtr_afam_ri dtr_optx_ri dtr_food_ri" // dtr_afam_rni
	//local sub_r "XXX"
	local itx_r "itx_vatx_rh itx_exci_rh"
	local edu_r "edu_care_ri edu_pres_ri edu_prim_ri edu_lose_ri edu_upse_ri edu_terc_ri"
	local hlt_r "hlt_snis_ri hlt_nonc_ri"
	//local oth_r "XXX"

	*************************************
// 	codebook `pen_r' `dtx_r' `con_r' `dtr_r' `sub_r' `itx_r' `edu_r' `hlt_r'
// 	*************************************
//	
// 	tabstat `pen_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtx_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `con_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtr_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	//tabstat `sub_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `itx_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `edu_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	tabstat `hlt_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
// 	//tabstat `oth_r' [w=`w'], stat(sum) format(%15.0fc) col(stat)
//
// 	tabstat `pen_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtx_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `con_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `dtr_r' , stat(sum) format(%15.0fc) col(stat)
// 	//tabstat `sub_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `itx_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `edu_r' , stat(sum) format(%15.0fc) col(stat)
// 	tabstat `hlt_r' , stat(sum) format(%15.0fc) col(stat)
	//tabstat `oth_r' , stat(sum) format(%15.0fc) col(stat)

	//local pen_19 "`pen'" 
	local dtx_19 "`dtx'"
	local con_19 "`con'" 
	//local dtr_19 "`dtr'" 
    //local sub_19 ""	
	local itx_19 "`itx'"	
	local edu_19 "`edu'"
	//local hlt_19 "`hlt'"
	//local oth_19 ""

	//local pen_r19 "`pen'"
	local dtx_r19 "`dtx'"
	local con_r19 "`con'"
	//local dtr_r19 "`dtr'"
	//local sub_r19 ""
	local itx_r19 "`itx'"
	local edu_r19 "`edu'" 
	//local hlt_r19 "`hlt'"
	//local oth_r19 ""

	 *Target population
    //local pen_t "pen_agex_ti"
	local dtx_t "dtx_pitx_ti"
	local con_t "con_ssxx_ti con_pats_ti con_hsxx_ti con_frlx_ti con_path_ti con_patf_ti"
	//local dtr_t ""
	//local sub_t ""
	//local itx_t ""
	local edu_t "edu_care_ti edu_pres_ti edu_prim_ti edu_lose_ti edu_upse_ti edu_terc_ti"
	//local hlt_t ""
	
	*************************************
// 	codebook `pen_t' `dtx_t' `con_t' `dtr_t' `sub_t' `itx_t' `edu_t' `hlt_t'
	*************************************

	
	*Education E20
	
	replace level_school=5 if (level_school==3 | level_school==4)
	
	//label def level 0 "Not attending" 1 "Preschool" 2 "Primary" 3 "Lower secondary" 4 "Upper secondary" 5 "Secondary (total)" 6 "Post secondary non-tertiary" 7 "Tertiary (Bachelor`s or equivalent)" 8 "Master, Doctoral or equivalent" 9 "Other (Technical Education)" 
	//label val level_school level
	
// 	tabulate level_school if level_school!=0, gen(edu_)

/*

      Level of schooling that is |
                       attending |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                Pre-school [4-5] |      4,402       11.73       11.73
                   Primary[6-11] |     13,394       35.69       47.42
         Secondary(total)[12-17] |     12,785       34.07       81.50
                  Tertiary [18-] |      5,044       13.44       94.94
  Master, Doctoral or equivalent |        360        0.96       95.90
                Child care [0-3] |      1,540        4.10      100.00
---------------------------------+-----------------------------------
                           Total |     37,525      100.00

*/

// forval i=1(1)6 {
// replace edu_`i'=0 if edu_`i'==.
// }

local edu_pre   edu_1
local edu_pri	edu_2
local edu_sec   edu_3
local edu_ter	edu_4

local edu_tr "edu_1 edu_2 edu_3 edu_5"
	
	local preschool `edu_pre'     
	local primary   `edu_pri'    
	local secondary `edu_sec'    
	local tertiary  `edu_ter'   
	
	local preschoolage "edu_pres_ti"
	local primaryage   "edu_prim_ti"   
	local secondaryage "edu_sec_ti"   
	local tertiaryage  "edu_terc_ti"    
	
	gen public= (type_school==1)
	replace public =. if at_school==0  
	local  public   "public"  
	
/*	gen edu_pre2=(edu_1==1) if public==1
	gen edu_pri2=(edu_2==1) if public==1
	gen edu_sec2=(edu_3==1) if public==1
	gen edu_nter2=(edu_4==1) if public==1
	gen edu_uni2=(edu_5==1) if public==1
	
	local edu_tr2 "edu_pre2 edu_pri2 edu_sec2 edu_nter2 edu_uni2"

	tabstat `edu_tr' [w=weight], stat(sum) format(%15.0fc) col(stat) 
	tabstat `edu_tr2' [w=weight], stat(sum) format(%15.0fc) col(stat)
	tabstat `edu_r' [w=weight], stat(sum) format(%15.0fc) col(stat) 
	tabstat `edu_t' [w=weight], stat(sum) format(%15.0fc) col(stat) 
*/
	/*
	local inf "inf_water inf_elec inf_floor inf_walls inf_roof inf_roads"
	tabstat `inf' [w=weight], stat(sum) format(%15.0fc) col(stat)
	
	//collapse inf_water inf_elec inf_floor inf_walls inf_roof inf_roads weight, by (hhid)
	
	local inf "inf_water inf_elec inf_floor inf_walls inf_roof inf_roads"
	tabstat `inf' [w=weight], stat(sum) format(%15.0fc) col(stat)
	*/
*/	
*****************************************************************************************


*****************************************************************************************
*			MWB E sheet Names
*****************************************************************************************
local date_xlsm "May5_2018"

local mwb_xlsm E1 E2 E3 E5E6 E10 E11 E12 E13 E18 E19 E20 E21

foreach x of local mwb_xlsm {

local `x' 	"MWB2018_`x'_`date_xlsm'.xlsm"

}

local date_xlsx "XXX"

local mwb_xlsx E4 E7 E8 E9 E14 E15 E16 E17 E22 E23 E24 E25 E26 E27 E28

foreach x of local mwb_xlsx {

local `x' 	"MWB2018_`x'_`date_xlsx'.xlsm"

}
*****************************************************************************************

cd "C:\Users\Rosie\Dropbox\CEQ_ado"
 #delimit ;

*E13.m MC;
      ceqmarg_sep5 [pw=`w'] using "MEX_NAT_Reruns_CEQMWB2017_E13_2011PPP_Feb07_2018.xlsx",  
		hhid(`hhid') psu(`psu') strata(`strate')
		d(`yd')
        pensions(`pen') 
		contribs(`con') 
			pl1(`cut1')
			pl2(`cut2')
			pl3(`cut3')
		
		ppp(`ppp') cpibase(`cpibase') cpisurvey(`cpisurvey') `period'
		country(`country') base(`baseyear') surv(`surveyyear') auth(`authors')
		group(`group') scenario(`scenario') project(`project')
		nationalm(`nationalm')
		nationale(`nationale')

		;


exit;	
		
