{smcl}
{* 17dec2020}{...}
{cmd:help ceqefext} (beta version; please report bugs) {right:Rodrigo Aranda}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqefextend} {hline 2} Computes effectiveness indicators for CEQ extended income concepts for the "E14. Effectiveness" sheets of the CEQ Master Workbook 2016

{pstd}
{ul:Caution:} The construction of the CEQ income concepts Market Income, Market Income plus Pensions, Net Market Income, Gross Income, and Taxable Income will differ depending on which scenario for the public contributory pension system has been chosen. In the public contributory Pensions as Deferred Income (PDI) scenario, pension system income is treated as (Market) income earned previously deferred until today; while pension system contributions are treated as mandatory savings (income deferred to one’s future self).  In contrast, the contributory Pensions as Government Transfer(PGT) scenario, pension system income is treated as a pure transfer (from the fisc), while pension system contributions are treated as a tax. In the PDI scenario pensions are prefiscal income while in the PGT scenario the public contributory pension system is a fiscal tax and transfer system that redistributes income from today’s working-age population to today’s pension-age population.  When the user wishes to analyze both PDI and PGT scenarios, this command must be run twice: once for outputting information generated under the PDI scenario to a Masterworkbook (section E); and again for outputting information generated under the PGT scenario to its own Masterworkbook (section E).  See also the Income concepts options section below for more detail.


{title:Syntax}

{p 8 11 2}
    {cmd:ceqassump} {varlist} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency (the default){p_end}

{pstd}
Note that the default PPP conversion factors, default poverty lines and default income cutoffs are related. See Poverty Lines options and Income group cut-offs options for a more detailed explanation.

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
    (should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
    (should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Poverty lines}
{synopt :{opth pl1(real)}}Lowest poverty line in $ PPP (default is $1.90 PPP per day){p_end}
{synopt :{opth pl2(real)}}Second lowest poverty line in $ PPP (default is $3.20 PPP per day){p_end}
{synopt :{opth pl3(real)}}Third lowest poverty line in $ PPP (default is $5.50 PPP per day){p_end}
{synopt :{opth nationale:xtremepl(string)}}National extreme poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth nationalm:oderatepl(string)}}National moderate poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth othere:xtremepl(string)}}Other extreme poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth otherm:oderatepl(string)}}Other moderate poverty line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth prop:ortion(real)}}Relative poverty line as a proportion of median household income from 0 to 1 (default is 0.5){p_end}
   
{syntab:Income group cut-offs}
{synopt :{opth cut1(real)}}Upper bound (exclusive) income for ultra-poor; default is $1.90 PPP per day{p_end}
{synopt :{opth cut2(real)}}Upper bound (exclusive) income for extreme poor; default is $3.20 PPP per day{p_end}
{synopt :{opth cut3(real)}}Upper bound (exclusive) income for moderate poor; default is $5.50 PPP per day{p_end}
{synopt :{opth cut4(real)}}Upper bound (exclusive) income for vulnerable; default is $11.50 PPP per day{p_end}
{synopt :{opth cut5(real)}}Upper bound (exclusive) income for middle class; default is $57.60 PPP per day{p_end}

{syntab:Produce subset of results}
{synopt :{opt nod:ecile}}Do not produce results by decile{p_end}
{synopt :{opt nog:roup}}Do not produce results by income group{p_end}

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values in the variables in {varlist}

{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth sheetm(string)}}Name of sheet to write results ranking by market income. Default is "E14.m Effectiveness"{p_end}
{synopt :{opth sheetmp(string)}}Name of sheet to write results ranking by market income plus pensions. Default is "E14.m+p Effectiveness"{p_end}
{synopt :{opth sheetn(string)}}Name of sheet to write results ranking by net market income. Default is "E14.n Effectiveness"{p_end}
{synopt :{opth sheetg(string)}}Name of sheet to write results ranking by gross income. Default is "E14.g Effectiveness"{p_end}
{synopt :{opth sheett(string)}}Name of sheet to write results ranking by taxable income. Default is "E14.t Effectiveness"{p_end}
{synopt :{opth sheetd(string)}}Name of sheet to write results ranking by disposable income. Default is "E14.d Effectiveness"{p_end}
{synopt :{opth sheetc(string)}}Name of sheet to write results ranking by consumable income. Default is "E14.c Effectiveness"{p_end}
{synopt :{opth sheetf(string)}}Name of sheet to write results ranking by final income. Default is "E14.f Effectiveness"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}.

{title:Required commands}

{title:Description}

{pstd}
{cmd:ceqefext} calculates the CEQ effectiveness indicators. Indicators include spending effectiveness and impact
effectiveness indicators for Gini, headcount index, poverty gap, and squared poverty gap for a number of poverty lines.
The effectiveness indicators of fiscal interventions are compared with respect to market income, market income + pensions,
net market income, gross income, and disposable income. For this reason fiscal interventions are necessary for ceqefext
to run, if they are excluded from the command there will be an error. With the fiscal intervention options, total taxes
and total benefits are used to estimate the impact effeectivness from one income concept to another.

{pstd}
The extended income concepts are created from the CEQ core income concepts, specified with the options
{opth m:arket(varname)}, {opth mp:luspensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)},
{opth t:axable(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)},
{opth c:onsumable(varname)}, and {opth f:inal(varname)}, and the fiscal interventions. Note that each
fiscal intervention option takes a {varlist} that can (and often should) have greater than one
variable: the variables provided should be as disaggregated as possible. For example, there might be
survey questions about ten different direct cash transfer programs; each of these would be a variable,
and all ten variables would be included with the {opth dtr:ansfers(varlist)} option. Contributory
pensions are specified by {opth p:ensions(varlist)}, direct transfers by {opth dtr:ansfers(varlist)},
direct taxes (not including contributions) by {opth dtax:es(varlist)}}, contributions (including
variables for both employer and employee contributions if applicable) by {opth co:ntribs(varlist)},
indirect subsidies by  {opth su:bsidies(varlist)}, indirect taxes by {opth indtax:es(varlist)}, health
benefits by {opth health(varlist)}, educaiton benefits by {opth educ:ation(varlist)}, and other public
in-kind benefits by {opth other:public(varlist)}. Tax and contribution variables may be saved as
either positive or negative values, as long as one is used consistently for all tax and contribution
variables. For user fees that should be subtracted out of health and education benefits, the gross
benefits should be specified by a set of variables (e.g., gross primary education benefits, gross
secondary education benefits, etc.), and another variable with user fees, stored as negative values,
should also be included in the {opth health(varlist)} or {opth educ:ation(varlist)} option. The variables provided in the {opth health(varlist)}, {opth educ:ation(varlist)}, and {opth other:public(varlist)} options should already be net of co-payments and user fees; we nevertheless include the separate options {opth userfeesh:ealth(varlist)}, {opth userfeese:duc(varlist)}, and {opth userfeeso:ther(varlist)} so that, for example, user fees can be analyzed.

{pstd}
{cmd: ceqefext} automatically converts local currency variables to PPP dollars, using the PPP conversion
factor given by {opth ppp(real)}, the consumer price index (CPI) of the year of PPP (e.g., 2005 or
2011) given by {opth cpib:ase(real)}, and the CPI of the year of the household
survey used in the analysis given by {opth cpis:urvey(real)}. The year of PPP, also called base year,
refers to the year of the International Comparison Program (ICP) that is being used, e.g. 2005 or 2011.
The survey year refers to the year of the household survey used in the analysis. If the year of PPP is
2005, the PPP conversion factor should be the "2005 PPP conversion factor, private consumption (LCU per
international $)" indicator from the World Bank's World Development Indicators (WDI). If the year of
PPP is 2011, use the "PPP conversion factor, private consumption (LCU per international $)" indicator
from WDI. The PPP conversion factor should convert from year of PPP to year of PPP. In other words,
when extracting the PPP conversion factor, it is possible to select any year; DO NOT select the year of
the survey, but rather the year that the ICP was conducted to compute PPP conversion factors (e.g.,
2005 or 2011). The base year (i.e., year of PPP) CPI, which can also be obtained from WDI, should match
the base year chosen for the PPP conversion factor. The survey year CPI should match the year of the
household survey. Finally, for the PPP conversion, the user can specify whether the original variables
are in local currency units per day ({opt da:ily}), per month ({opt mo:nthly}), or per year
({opt year:ly}, the default assumption).

{pstd}
If the data set is at the individual level (each observation is an individual), the variable with the
identification code of each household (i.e., it takes the same value for all members within a
household) should be specified in the {opth hh:id(varname)} option; the {opth hs:ize(varname)} option
should not be specified. If the data set is at the household level, the number of members in the
household should be specified in {opth hs:ize(varname)}; the {opth hh:id(varname)} option should not be
specified. In either case, the weight used should be the household sampling weight and should {it:not}
be multiplied by the number of members in the household since the program will do this multiplication
automatically in the case of household-level data.

{pstd}
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered
using {help svyset} since {cmd:ceqefext} automatically uses the information specified using {help svyset}.
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and
strata can be entered using the {opth s:trata(varname)} option.

{pstd}
Results are automatically exported to the CEQ Master Workbook Output Tables if {cmd:using} {it:filename}
is specifed in the command, where {it:filename} is the Master Workbook. By default,
{cmd:ceqefext}} prints to the sheets titled "E14.X Effectiveness" where X indicates the income
concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)},
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options,
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master
Workbook populated with results from {cmd:ceqefext} can be automatically opened if the {opt open}
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in
matrices available from {cmd:return list}.

{marker opt}
{title:Options}

{marker cor}
{dlgtab:Core options}

{phang}
{opt using} is required, and indicates the filename for the output. Results are automatically exported to the CEQ Master Workbook Output Tables if {cmd:using} {it:filename}
is specifed in the command, where {it:filename} is the Master Workbook. By default,
{cmd:ceqefext}} prints to the sheets titled "E14.X Effectiveness" where X indicates the income
concept (m, m+p, n, g, t, d, c, f); the user can override the sheet names using the
{opt sheetm(string)}, {opt sheetmp(string)}, {opt sheetn(string)}, {opt sheetg(string)},
{opt sheett(string)}, {opt sheetd(string)}, {opt sheetc(string)}, and {opt sheetf(string)} options,
respectively. Exporting directly to the Master Workbook requires Stata 13 or newer. The Master
Workbook populated with results from {cmd:ceqefext} can be automatically opened if the {opt open}
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in
matrices available from {cmd:return list}.


{p 8 8 2}
Notice that if the user wishes to do the CEQ {it} Assessment {sf} for both the {bf: "pensions as deferred income scenario"} and
{bf: "pensions as government transfer scenario"}, the ado does {bf: NOT} run both scenarios automatically. The user must run the
ado twice, one time per scenario (see Income concepts options for an explanation on the differences across
scenarios), and create two separate sets of E sheets. Hence, {it:filename} should be changed accordingly.


{marker inc}
{dlgtab:Income concepts options}

{pstd}
The CEQ core income concepts include market income, market income plus pensions, net market income, gross income,
taxable income, disposable income, consumable income, and final income. The variables for these income
concepts, which should be expressed in local currency units (preferably {bf:per year} for ease of comparison
with totals from national accounts), are indicated using the {opth m:arket(varname)}, {opth mp:luspensions(varname)},
{opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth t:axable(varname)}, {opth d:isposable(varname)},
{opth c:onsumable(varname)}, and {opth f:inal(varname)} options.

{pstd}
The public contributory old-age pension system can be incorporated into a CEQ Assessment as deferred income or as a government transfer (for a detailed discussion regarding
the alternatives see Lustig (2018) available at {browse "http://commitmentoequity.org/publications-ceq-handbook"}). The decision regarding the public contributory pension system can have a significant impact on assessing the redistributive power of a fiscal system, especially in countries with a high proportion of retirees and large spending on social security. The construction of Market income, Market income plus pensions, Gross income, Net market income, and Taxable Income will differ between the PDI and PGT scenarios (while Disposable income, Consumable income and Final income are equivalent in value in both scenarios). The user must create two separate sets of E sheets, one per scenario (for a more detailed
explanation see {cmd: using} in {help ceqlorenz##cor:core options}).

{pstd}
In CEQ {it} Assessments {sf} in the {bf: "pensions as deferred income scenario"}, it is assumed that contributions
during working years are a form of “forced saving” and income concepts are defined in the following way:

{p 16 16 10}
Market income given by {opth m:arket(varname)} as factor income (wages and salaries and income from capital) plus private transfers
 (remittances, private pensions, etc.) {bf: PLUS} imputed rent and own production {bf: MINUS} contributions to social insurance old-age pensions.

{p 16 16 10}
Market income plus pensions given by {opth mp:luspensions(varname)} as Market income (PDI) {bf: PLUS} contributory social
 insurance old-age pensions. Prefiscal income (PDI) is defined as Market income plus Pensions (PDI).

{p 16 16 10}
Gross Income given by {opth g:ross(varname)} as Market Income plus pensions (PDI) {bf: PLUS} direct cash and near cash
transfers (conditional and unconditional cash transfers, school feeding programs, free food transfers, etc.).

{p 16 16 10}
Net Market Income given by {opth n:etmarket(varname)} as Market Income plus pensions (PDI) {bf: MINUS} direct taxes
and {bf: MINUS} non-pension social contributions.

{p 16 16 10}
Taxable income given by {opth t:axable(varname)} as Gross Income (PDI) {bf: MINUS} all non-taxable Gross Income components.

{p 16 16 10}
Disposable income given by {opth d:isposable(varname)} as Market Income plus pensions (PDI) {bf: PLUS} all direct transfers
 {bf: MINUS} all direct taxes and non-pension social contributions.


{pstd}
In the {bf: "pensions as government transfer scenario"}, it is assumed that pensions are a pure government transfers and income concepts are defined in the following way:

{p 16 16 10}
Market income given by {opth m:arket(varname)} as factor income (wages and salaries and income from capital) plus private transfers
 (remittances, private pensions, etc.)  {bf: PLUS} imputed rent and own production. Prefiscal income (PGT) is defined as Market income (PGT).

{p 16 16 10}
Market income plus pensions given by {opth mp:luspensions(varname)} as Market income (PGT) {bf: PLUS} contributory social insurance old-age pensions.

{p 16 16 10}
Gross Income given by {opth g:ross(varname)} as Market Income plus pensions (PGT) {bf: PLUS} direct cash and near cash transfers (conditional and
 unconditional cash transfers, school feeding programs, free food transfers, etc.).

{p 16 16 10}
Net Market Income given by {opth n:etmarket(varname)} as Market Income (PGT) {bf: MINUS} direct taxes and {bf: MINUS}  non-pension
social contributions.

{p 16 16 10}
Taxable income given by {opth t:axable(varname)} as Gross Income (PGT) {bf: MINUS} all non-taxable Gross Income components.

{p 16 16 10}
Disposable income given by {opth d:isposable(varname)} as Market Income (PGT) {bf: MINUS}  all direct taxes {bf: PLUS} pension income {bf: PLUS}
 all other direct transfers {bf: MINUS} all pension and non-pension social contributions.


{pstd}
The construction of Consumable and Final income is done in the same way in both the PDI and PGT scenarios:

{p 16 16 10}
Consumable income given by {opth c:onsumable(varname)} as Disposable Income {bf: PLUS} indirect subsidies (energy, food and other general
 or targeted price subsidies) and {bf: MINUS} indirect taxes (VAT, excise taxes, and other indirect taxes).

{p 16 16 10}
Final income given by {opth f:inal(varname)} as Consumable income {bf: PLUS} Monetized value of in-kind transfers in education and health
 services at average government cost and {bf: MINUS} co-payments and user fees.


{marker pov}
{dlgtab: Poverty lines options}

{pstd}
Poverty lines in PPP dollars per day can be set using the {opth pl1(real)}, {opth pl2(real)}, and {opth pl3(real)} options. The default poverty
lines $1.90, $3.20 and $5.50 correspond to the income-category-specific poverty lines suggested in Joliffe & Prydz (2016), who determined the
median (to the nearest 10 cents) national poverty line in $PPP (using the 2011 ICP PPP conversion factors) for each set of countries grouped
under the World Bank's income classification system. Specifically, there are three income class-specific poverty lines: US$1.90 a day for low
income countries, US$3.20 a day for lower middle- income countries and US$5.50 a day for upper middle-income countries. Thus, in the context of
middle-income countries, we call those living on less than US$1.90 PPP per day the “ultra-poor.” The US$3.20 and US$5.50 PPP per day poverty lines
 are commonly used as extreme and moderate poverty lines for Latin America and roughly correspond to the median official extreme and moderate
poverty lines in those countries. The user may specify any poverty line values. For example, to change the lowest poverty line from $1.90 PPP per
day to $1.25 PPP per day, specify {cmd:pl1(1.25)}.

{pstd}
Poverty lines in local currency can be entered using the {opth nationale:xtremepl(string)},
{opth nationalm:oderatepl(string)}, {opth othere:xtremepl(string)}, {opth otherm:oderatepl(string)} options. Local currency poverty lines can
be entered as real numbers (for poverty lines that are fixed for the entire population) or variable names (for poverty lines that vary, for
example across space), and should be in the same units as the income concept variables (preferably local currency units per year). The relative
poverty line can be specfied as a proportion of median household income using {opth proportion(real)}, where {it:real} should be a proportion
between 0 and 1. The default proportion is 0.5, i.e. 50% of household median income. For example, to change the relative poverty line from 50% to
60% of median income (which is used by the OECD), specify {cmd:proportion(0.6)}.

{marker cut}
{dlgtab:Income group cut-offs options}

{pstd}
{opth cut1(real)} to {opth cut5(real)} are in $PPP. The default cut-off values of $1.90, $3.20 and $5.50 correspond to the income-category-specific poverty lines suggested in Joliffe & Prydz (2016), who determined the median (to the nearest 10 cents) national poverty line in $PPP (using the 2011 ICP PPP conversion factors) for each set of countries grouped under the World Bank's income classification system. Specifically, there are three income class-specific poverty lines: US$1.90 a day for low income countries, US$3.20 a day for lower middle- income countries and US$5.50 a day for upper middle-income countries. Thus, in the context of middle-income countries, we call those living on less than US$1.90 PPP per day the “ultra-poor.” The US$3.20 and US$5.50 PPP per day poverty lines are commonly used as extreme and moderate poverty lines for Latin America and roughly correspond to the median official extreme and moderate poverty lines in those countries.

{pstd}
The $11.50 and $57.60 cutoffs correspond to cutoffs for the vulnerable and middle-class populations suggested for the 2005-era PPP conversion factors by Lopez-Calva and Ortiz-Juarez (2014); $11.50 and $57.60 represent a United States CPI-inflation adjustment of the 2005-era $10 and $50 cutoffs.  The US$10 PPP per day line is the upper bound of those vulnerable to falling into poverty (and thus the lower bound of the middle class) in three Latin American countries, calculated by Lopez-Calva and Ortiz-Juarez (2014). Ferreira and others (2013) find that an income of around US$10 PPP also represents the income at which individuals in various Latin American countries tend to self-identify as belonging to the middle class and consider this a further justification for using it as the lower bound of the middle class. The US$10 PPP per day line was also used as the lower bound of the middle class in Latin America in Birdsall (2010) and in developing countries in all regions of the world in Kharas (2010). The US$50 PPP per day line is the upper bound of the middle class proposed by Ferreira and others (2013).

{pstd}
The user may specify any set of cut points that create exclusive population groups.  For example, the older cut points for the ultra-poor, extreme poor, moderate poor, vulnerable and middle class, which corresponded to the 2005-era PPP conversion factors were $1.25, $2.50, $4, $10 and $50 (respectively).



{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqefext [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions)     dtax(income_tax property_tax)     cont(employee_contrib employer_contrib)     dtransfer(cct noncontrip_pens unemployment scholarships food_transfers)     indtax(vat excise)     subsidies(energy_subs)     health(basic_health preventative_health inpatient_health user_fees)     education(daycare preschool primary secondary tertiary user_fees)     ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)    othere(`pl70') otherm(`pl140') open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqefext [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) n(yn) g(yg) t(yt) d(yd) c(yc) f(yf) pens(pensions)     dtax(income_tax property_tax)     cont(employee_contrib employer_contrib)     dtransfer(cct noncontrip_pens unemployment scholarships food_transfers)     indtax(vat excise)     subsidies(energy_subs)     health(basic_health preventative_health inpatient_health user_fees)     education(daycare preschool primary secondary tertiary user_fees) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') nationale(PLipea_ext) nationalm(PLipea)    othere(`pl70') otherm(`pl140') open}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org

{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{pstd}Higgins, Sean and Nora Lustig. 2016. "Can a Poverty-Reducing and Progressive Tax and Transfer System Hurt
the Poor?" Journal of Development Economics 122, 63-75.{p_end}

{pstd}Lustig, Nora, editor. 2018. {browse "https://commitmentoequity.org/publications-ceq-handbook":Commitment to Equity Handbook. Estimating the Impact of Fiscal Policy on Inequality and Poverty}. Brookings Institution Press and CEQ Institute, Tulane University. {p_end}
