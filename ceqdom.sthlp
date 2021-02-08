{smcl}
{* 17dec2020}{...}
{cmd:help ceqdom} (beta version; please report bugs) {right:Rodrigo Aranda}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqdom} {hline 2} Computes dominance indicators for CEQ core income concepts for the "E8. Dominance" sheets of the CEQ Master Workbook 2016

{pstd}
{ul:Caution:} The construction of the CEQ income concepts Market Income, Market Income plus Pensions, Net Market Income, Gross Income, and Taxable Income will differ depending on which scenario for the public contributory pension system has been chosen. In the public contributory Pensions as Deferred Income (PDI) scenario, pension system income is treated as (Market) income earned previously deferred until today; while pension system contributions are treated as mandatory savings (income deferred to one’s future self).  In contrast, the contributory Pensions as Government Transfer(PGT) scenario, pension system income is treated as a pure transfer (from the fisc), while pension system contributions are treated as a tax. In the PDI scenario pensions are prefiscal income while in the PGT scenario the public contributory pension system is a fiscal tax and transfer system that redistributes income from today’s working-age population to today’s pension-age population.  When the user wishes to analyze both PDI and PGT scenarios, this command must be run twice: once for outputting information generated under the PDI scenario to a Masterworkbook (section E); and again for outputting information generated under the PGT scenario to its own Masterworkbook (section E).  See also the Income concepts options section below for more detail.

{title:Syntax}

{p 8 11 2}
    {cmd:ceqdom} {ifin} {weight} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mp:luspensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth n:etmarket(varname)}}Net market income{p_end}
{synopt :{opth g:ross(varname)}}Gross income{p_end}
{synopt :{opth t:axable(varname)}}Taxable income{p_end}
{synopt :{opth d:isposable(varname)}}Disposable income{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
    (should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
    (should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Export directly to CEQ Master Workbook (requires Stata 13 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
{synoptline}
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}.

{title:Required commands}
{cmd:ceqdom} uses  {cmd:ksmirnov}, {cmd:domineq} from DASP, and {cmd:glcurve}.
{title:Description}

{pstd}
{cmd:ceqdom} calculates the CEQ dominance estimations for the CEQ core income concepts. Indicators include
number of crossings between lorenz/concentration curves for core income concepts. If there is zero
crossing, the program estimates a K-Smirnov test between the two distributions.

{pstd}
The income variables should be expressed in household per capita or per adult equivalent
terms, regardless of whether the data set being used is at the household or individual level. Hence, they should
have the same per-person amount for each member within a household when using individual-level data.

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
using {help svyset} since {cmd:ceqdom} automatically uses the information specified using {help svyset}.
Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option and
strata can be entered using the {opth s:trata(varname)} option. {cmd:domineq} requires that survey design is
entered using {help svyset} or through the {cmd:ceqdom}  program.


{marker opt}
{title:Options}

{marker cor}
{dlgtab:Core options}

{phang}
{opt using} is required, and indicates the filename for the output. Results are automatically exported to the CEQ Master Workbook Output Tables if {cmd:using} {it:filename}
is specifed in the command, where {it:filename} is the Master Workbook. Exporting directly to the Master
Workbook requires Stata 13 or newer. The Master Workbook populated with results from {cmd:ceqdom} can be automatically opened if the {opt open}
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



{title:Examples}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqdom [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) ///}{p_end}
{phang} {cmd:. t(yt) d(yd) c(yc) f(yf) pensreps(50) open}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqdom [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) n(yn) g(yg) ///}{p_end}
{phang} {cmd:. t(yt) d(yd) c(yc) f(yf) pensreps(50) open}{p_end}

{title:Saved results}

Pending

{title:Authors}

{p 4 4 2}Rodrigo Aranda, Tulane University, raranda@tulane.edu


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{pstd}Lustig, Nora, editor. 2018. {browse "https://commitmentoequity.org/publications-ceq-handbook":Commitment to Equity Handbook. Estimating the Impact of Fiscal Policy on Inequality and Poverty}. Brookings Institution Press and CEQ Institute, Tulane University. {p_end}
