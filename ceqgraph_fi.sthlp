{smcl}
{* 20aug2016}{...}
{cmd:help ceqgraph fi} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqgraph fi} {hline 2} Graphs fiscal impoverishment (FI) and fiscal gains to the poor (FGP) measures from Higgins and Lustig (2016).

{pstd}
{ul:Caution:} The construction of the CEQ income concepts Market Income, Market Income plus Pensions, Net Market Income, Gross Income, and Taxable Income will differ depending on which scenario for the public contributory pension system has been chosen. In the public contributory Pensions as Deferred Income (PDI) scenario, pension system income is treated as (Market) income earned previously deferred until today; while pension system contributions are treated as mandatory savings (income deferred to one’s future self).  In contrast, the contributory Pensions as Government Transfer(PGT) scenario, pension system income is treated as a pure transfer (from the fisc), while pension system contributions are treated as a tax. In the PDI scenario pensions are prefiscal income while in the PGT scenario the public contributory pension system is a fiscal tax and transfer system that redistributes income from today’s working-age population to today’s pension-age population.  When the user wishes to analyze both PDI and PGT scenarios, this command must be run twice: once for outputting information generated under the PDI scenario to a Masterworkbook (section E); and again for outputting information generated under the PGT scenario to its own Masterworkbook (section E).  See also the Income concepts options section below for more detail.

{title:Syntax}

{p 8 11 2}
    {cmd:ceqgraph fi} {ifin} {weight} [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mp:luspensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

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

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions

{syntab:Produce subset of results (if none specified, all produced)}
{synopt :{opt head:count}}Produce results for FI and FGP headcounts{p_end}
{synopt :{opt tot:al}}Produce results for total FI and FGP{p_end}
{synopt :{opt per:capita}}Produce results for per capita FI and FGP{p_end}
{synopt :{opt norm:alized}}Produce results for per capita FI and FGP normalized by the poverty line{p_end}

{syntab:Graphing options}
{synopt :{opth pl1(real)}}The lowest of three poverty lines to be graphed, expressed in PPP dollars per day (default is $1.90 PPP per day).{p_end}
{synopt :{opth pl2(real)}}The second of three poverty lines to be graphed, expressed in PPP dollars per day (default is $3.20 PPP per day).{p_end}
{synopt :{opth pl3(real)}}The highest of three poverty lines to be graphed (and the maximum income included in the graph) expressed in PPP dollars per day (default is $4.00 PPP per day).{p_end}
{synopt :{opth precision(real)}}Increment for grid-based method to compute FI and FGP. (Default is $0.01 PPP per day.){p_end}
{synopt :{opth scheme(string)}}Set the graph scheme ({stata help scheme}; default is "s1mono"){p_end}
{synopt :{opth path(string)}}The directory to save the graphs in{p_end}
{synopt :{opth graphname(string)}}The prefix of the saved graph names (default is "fi"){p_end}
{synopt :{it:{help twoway_options}}}Any options documented in
   {bind:{bf:[G] {it:twoway_options}}}{p_end}
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 14.1 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth base:year(real)}}Base year of PPP conversion (e.g., 2005, 2011){p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheet(string)}}Name of sheet to write results. Default is "E27. FIFGP"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}

{synoptline}
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}.

{title:Description}

{pstd}
{cmd:ceqgraph fi} graphs the FI and FGP measures derived in Higgins and Lustig (2016). These measures
compare pre-fisc and post-fisc incomes, for two pre-fisc incomes (market income--given by
{opth m:arket(varname)}--and market income plus pensions--given by {opth mp:luspensions(varname)}) and two
post-fisc incomes (consumable income--given by {opth c:onsumable(varname)}--and final income--given by
{opth f:inal(varname)}). The measures include the FI and FGP headcounts (where the denominator is the total
population; produced if {opt head:count}
is specified); total FI and FGP (in dollars per day adjusted for purchasing power parity [PPP]; produced if {opt tot:al} is specified); FI and
FGP per capita (in PPP dollars per day), where k=1/|S| and S is the set of individuals in society with
cardinality |S| (i.e. total FI or FGP is divided by the total population; produced if {opt per:capita} is specified); and normalized FI and FGP,
where k = 1/(|S|z) and z is the poverty line (i.e., per capita FI or FGP as a proportion of the poverty
line; produced if {opt norm:alized} is specified). If none of {opt head:count}, {opt tot:al}, {opt per:capita},
and {opt norm:alized} are specified, all graphs are produced by default.

{pstd}
{cmd: ceqgraph fi} automatically converts local currency variables to PPP dollars, using the PPP conversion
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
By default, {cmd: ceqgraph fi} does not allow income concept or fiscal intervention variables to have missing
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy,
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has
missing values, the command will produce an error. For flexibility, however, the command includes an
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus
allowing the command to run even if there are missing values.

{pstd}
Negative incomes are allowed, but a warning is issued for each core income concept that
has negative values (or positive values when a fiscal intervention is stored as negative values). This is because
various measures are no longer well-behaved when negative values are included (for example, the Gini coefficient,
concentration coefficient, or squared poverty gap can exceed 1, and other desirable properties of these measures
when incomes are non-negative no longer hold when negative values are allowed).

{pstd}
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered
using {help svyset} since {cmd:ceqgraph} automatically uses the information specified using
{help svyset}. Alternatively, the primary sampling unit can be entered using the {opth psu(varname)}
option and strata can be entered using the {opth s:trata(varname)} option.

{pstd}
Three poverty lines are included as dashed vertical lines in the graph, and the domain of the graph
is from 0 to the highest of the three poverty lines. These three poverty lines, which should be
expressed in PPP dollars per day, can be changed using
the {opth pl1(real)} option for the lowest poverty line (the default is $1.90 PPP per day),
{opth pl2(real)} for the middle poverty line (the default is $3.20 PPP per day), and
{opth pl3(real)} for the highest of the three poverty lines (the default is $4 PPP per day);
the highest poverty line also determines the highest income included in the graphs.
For example, to change the lowest poverty line from $1.90 to $3.00, specify {cmd:pl1(1.90)}.
Because the FI and FGP graphs are produced using a grid-based method where FI and FGP are computed for
every poverty line along a range from 0 to the maximum poverty line, precision can be adjusted using
{opth precision(real)}, where a higher number will produce a choppier graph but make the program run
faster. The default precision is 0.01 (i.e., FI and FGP are calculated in poverty line increments of
$0.01 PPP per day).

{pstd}
The resulting graphs from {cmd:ceqgraph fi} are saved in the directory specified by the {opth path(string)} option
(or, by default, the current directory) with the file name {bf:`graphname'_`measure'_`y0'_to_`y1'.gph} where
`graphname' is the prefix specified by {opth graphname(string)} (or "fi" by default),
`measure' is one of headcount, total, percapita, or normalized, `y0' is a letter representing the
pre-fisc income concept (either m or mp), and `y1' is a letter representing the post-fisc income
concept (either c or f).



{marker cor}
{dlgtab:Core options}

{phang}
{opt using} is required, and indicates the filename for the output. Results are automatically exported to the CEQ Master Workbook if
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By
default, {cmd:ceqgraph fi} prints to the sheets titled "E27. FIFGP"; the user can override the sheet names using the
{opt sheet(string)}. Exporting directly to the Master Workbook requires Stata 14.1 or newer. The Master
Workbook populated with results from {cmd:ceqgraph fi} can be automatically opened if the {opt open}
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
Taxable income given by {opth t:axable(varname)} as Gross Income (PDI) MINUS all non-taxable Gross Income components.

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
Taxable income given by {opth t:axable(varname)} as Gross Income (PGT) MINUS all non-taxable Gross Income components.

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




{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqgraph fi [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) c(yc) f(yf) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi')}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqgraph fi [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) c(yc) f(yf) ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi')}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Higgins, Sean and Nora Lustig. 2016. {browse "http://www.sciencedirect.com/science/article/pii/S0304387816300220":"Can a Poverty-Reducing and Progressive Tax and Transfer System Hurt the Poor?"} Journal of Development Economics 122, 63-75.{p_end}


