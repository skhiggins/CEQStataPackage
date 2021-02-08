{smcl}
{* 17dec2020}{...}
{cmd:help ceqrace}{beta version; please report bugs} {right:Rodrigo Aranda}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqrace} {hline 2} Produces results tables for Ethno Racial Master Workbook under Commitment to Equity (CEQ) framework{p_end}

{title:Syntax}

{p 8 11 2}
    {cmd:ceqrace} using({it:filename}) {weight} {ifin} [{cmd:,}table({it:name}) {it:options}] {break}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{cmd:Tables}}
{synopt:{cmd:f3}} Ethno-Racial Populations{p_end}
{synopt:{cmd:f5}} Population Composition{p_end}
{synopt:{cmd:f6}} Income Distribution{p_end}
{synopt:{cmd:f7}} Summary Poverty Rates{p_end}
{synopt:{cmd:f8}} Summary Poverty Gap Rates{p_end}
{synopt:{cmd:f9}} Summary Poverty Gap Squared Rates{p_end}
{synopt:{cmd:f10}} Summary Inequality Indicators{p_end}
{synopt:{cmd:f11}} Mean Incomes{p_end}
{synopt:{cmd:f12}} Incidence by Decile{p_end}
{synopt:{cmd:f13}} Incidence by Socioeconomic Group{p_end}
{synopt:{cmd:f16}} Fiscal Profile{p_end}
{synopt:{cmd:f17}} Coverage Rates (Totals){p_end}
{synopt:{cmd:f18}} Coverage Rates (Targets){p_end}
{synopt:{cmd:f20}} Mobility Matrices{p_end}
{synopt:{cmd:f21}} Education (populations){p_end}
{synopt:{cmd:f23}} Educational Probability{p_end}
{synopt:{cmd:f24}} Infrastructure Access{p_end}
{synopt:{cmd:f25}} Theil Disaggregation    {p_end}
{synopt:{cmd:f26}} Inequality of Opportunity{p_end}
{synopt:{cmd:f27}} Significance{p_end}
{synopt :{opt open}}Automatically open CEQ Ethno Racial Master Workbook with new results added{p_end}

{syntab:{cmd:Ethno-Racial groups}}

{synopt :{opth race1(varname)}}Indigenous Population{p_end}
{synopt :{opth race2(varname)}}White/Non-Ethnic Population{p_end}
{synopt :{opth race3(varname)}}African Descendant Population{p_end}
{synopt :{opth race4(varname)}}Other Races/Ethnicities{p_end}
{synopt :{opth race5(varname)}}Non-Responses{p_end}

{syntab:{cmd:Income Concepts}}
{synopt :{opth o:riginal(varname)}}Original income{p_end}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mplusp:ensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth n:etmarket(varname)}}Net market income{p_end}
{synopt :{opth g:ross(varname)}}Gross income{p_end}
{synopt :{opth taxab:le(varname)}}Taxable income{p_end}
{synopt :{opth d:isposable(varname)}}Disposable income{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:{cmd:Tax and Transfer Concepts}}
{synopt :{opth dtax:(varname)}}Direct Taxes{p_end}
{synopt :{opth cont:rib(varname)}}Contributions{p_end}
{synopt :{opth conyp:ensions(varname)}}Contributory Pensions{p_end}
{synopt :{opth contp:ensions(varname)}}Contributions to Pensions{p_end}
{synopt :{opth nonc:ontrib(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth flagcct:(varname)}}Flagship CCT{p_end}
{synopt :{opth otran:sfers(varname)}}Other Direct Transfers{p_end}
{synopt :{opth isub:sidies(varname)}}Indirect Subsidies{p_end}
{synopt :{opth itax:(varname)}}Indirect Taxes{p_end}
{synopt :{opth ike:duc(varname)}}In-kind Education{p_end}
{synopt :{opth ikh:ealth(varname)}}In-kind Health{p_end}
{synopt :{opth hu:rban(varname)}}Housing and Urban{p_end}

{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency (the default){p_end}

{syntab:Poverty lines}
{synopt :{opth next:reme(string)}}National Extreme Poverty Line in same units as income variables (can be a scalar or {varname}){p_end}
{synopt :{opth nmod:erate(string)}}National Moderate Poverty Line in same units as income variables (can be a scalar or {varname}){p_end}

{syntab:Income group cut-offs}
{synopt :{opth cut1(real)}}Upper bound (exclusive) income for ultra-poor; default is $1.90 PPP per day{p_end}
{synopt :{opth cut2(real)}}Upper bound (exclusive) income for extreme poor; default is $3.20 PPP per day{p_end}
{synopt :{opth cut3(real)}}Upper bound (exclusive) income for moderate poor; default is $5.50 PPP per day{p_end}
{synopt :{opth cut4(real)}}Upper bound (exclusive) income for vulnerable; default is $11.50 PPP per day{p_end}
{synopt :{opth cut5(real)}}Upper bound (exclusive) income for middle class; default is $57.60 PPP per day{p_end}

{syntab:{cmd:Coverage}}
{synopt :{opth cct:(varname)}}Conditional Cash Transfers{p_end}
{synopt :{opth nonc:ontrib(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth pens:ions(varname)}}Non Contributory Pensions{p_end}
{synopt :{opth unem:ploy(varname)}}Unemployment Benefits {p_end}
{synopt :{opth foodt:ransfers(varname)}}Food Transfers{p_end}
{synopt :{opth otran:sfers(varname)}}Other Direct Transfers{p_end}
{synopt :{opth health(varname)}}Health{p_end}
{synopt :{opth pen:sions(varname)}}Pensions{p_end}
{synopt :{opth sch:olarships(varname)}}Scholarships{p_end}
{synopt :{opth tarcct(varname)}}Conditional Cash Transfers Target Population{p_end}
{synopt :{opth tarncp(varname)}}Non Contributory Pensions Target Population{p_end}
{synopt :{opth tarpen(varname)}}Pensions Target Population{p_end}

{syntab:{cmd:Education}}
{synopt :{opth age:(varname)}}Age{p_end}
{synopt :{opth edpre:(varname)}}Pre-School{p_end}
{synopt :{opth redpre:(varname)}}Pre-School Age Range (1 if is in range){p_end}
{synopt :{opth edpri:(varname)}}Primary School{p_end}
{synopt :{opth redpri:(varname)}}Primary School Age Range (1 if is in range){p_end}
{synopt :{opth edsec:(varname)}}Secondary School {p_end}
{synopt :{opth redsec:(varname)}}Secondary School Age Range (1 if is in range){p_end}
{synopt :{opth edter:(varname)}}Terciary School {p_end}
{synopt :{opth redter:(varname)}}Terciary School Age Range (1 if is in range) {p_end}
{synopt :{opth edpub:lic(varname)}}Public School {p_end}
{synopt :{opth edpriv:ate(varname)}}Private School {p_end}
{synopt :{opth attend:(varname)}}Attends School {p_end}


{syntab:{cmd:Infrastructure Access (Dichotomous Variables)}}
{synopt :{opth water:(varname)}}Water{p_end}
{synopt :{opth electricity:(varname)}}Electricity{p_end}
{synopt :{opth walls:(varname)}}Walls{p_end}
{synopt :{opth floors:(varname)}}Floors{p_end}
{synopt :{opth roof:(varname)}}Roof{p_end}
{synopt :{opth sewage:(varname)}}Sewage{p_end}
{synopt :{opth roads:(varname)}}Roads{p_end}
           
{syntab:{cmd:Household}}
{synopt :{opth hhe:ad(varname)}}Household head identifier {p_end}
{synopt :{opth hhid:(varname)}}Household ID {p_end}
                
{syntab:{cmd:Circumstance}}
{synopt :{opth gender(varname)}}Gender{p_end}
{synopt :{opth ur:ban(varname)}}Urban Identifier{p_end}
{synopt :{opth edpar:(varname)}}Parent's Education {p_end}

{syntab:{cmd:Survey Information}}
{synopt :{opth hs:ize(varname)}}Number of members in the household{p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling designs); can also be set using {help svyet:svyset}{p_end}
       
{hline}

{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}.

{title:Description}
{pstd}
{cmd:ceqrace} Produces results by race or ethnicity based on Commitment to Equity (CEQ) framework, the 20 tables of the Ethno-racial Workbook can be estimated separately and saved in the Excel file specified in {it:using(filename)}.
{p_end}
{pstd}
The variables given by {opth race(varname)} must be dummy variables that identify different races or groups in the intended order where up to five variables are allowed, and the ordering in the Ethno-racial Workbook is taken as reference.
{p_end}
{pstd}
This program uses the {cmd:table({it:name})} option to identify which table to generate and uses the {cmd:putexcel} command to export to Excel. Options vary depending on the table that is being exported (for more information see below in section {cmd:Tables and Examples}.
{p_end}
{pstd}
This program uses the following built in programs from DASP {cmd: digini}, {cmd: dientropy} and {cmd: dinineq}. It uses {cmd: ineqdeco} and {cmd: ceq} as well.
{p_end}
{pstd}
{cmd:All monetary values must be in per capita monthly LCU.}
{p_end}
{pstd}
Poverty lines are used for poverty results; for results by income group, the cut-offs of these groups can be changed using the {opth cut1(real)} to {opth cut5(real)} options; the default groups are ultra-poor ($0 to $1.90 per day in purchasing power parity [PPP] adjusted US dollars), extreme poor ($1.90 to $3.20 PPP per day), moderate poor ($3.20 to $5.50 PPP per day), vulnerable ($5.50 to $11.50 PPP per day), middle class ($11.50 to $57.60 PPP per day) and wealthy ($57.60 and more PPP per day). For example, specify {cmd:cut1(1.90)} to change the first cut-off to $1.90 PPP per day (which would cause the lowest group to range from $0 to $1.90 PPP per day, and the second group--if {opth cut2(real)} is not specified so the default second cut-off is maintained--to range from $1.90 to $3.20 PPP).
{p_end}
{pstd}
{cmd: ceqrace} automatically converts local currency variables to PPP dollars, using the PPP conversion
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
{p_end}
{hline}

{title:Tables and examples}
{syntab:{cmd:F3.-  Ethno-Racial Populations}}    Variables in {varlist}, and [{weight}] are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace  [pw=weight] using CEQ_Ethno_Racial_Workbook.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f3) }{p_end}
 
{syntab:{cmd:F5.- Population Composition}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f5) o(y_m) d(y_d) hhid(hhid) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F6.- Distribution}} Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f6) o(y_m) d(y_d) hhid(hhid) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F7.- Poverty}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f7) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F8.- Poverty Gap}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f8) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F9.- Poverty Gap Squared}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth next:reme(string)}, and {opth nmod:erate(string)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f9) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year next(137) nmod(350)}{p_end}

{syntab:{cmd:F10.- Inequality}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)} are required..
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f10) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f)} {p_end}

{syntab:{cmd:F11.- Mean Income}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx, race1(indig) race2(white) race3(afrd) table(f11)m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f)} {p_end}

{syntab:{cmd:F12.- Incidence (Decile)}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)},
{opth dtax:(varname)}, {opth cont:ributions(varname)}, {opth contp:ensions(varname)}, {opth contyp:ensions(varname)}, {opth nonc:ontributory(varname)}, {opth flagcct:(varname)}, {opth otran:sfers(varname)}, {opth isub:sidies(varname)}, {opth itax:(varname)}, {opth ike:ducation(varname)},
{opth ikh:ealth(varname)}, {opth hu:rban(varname)},  {opth hhid(varname)}, are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f12) o(y_m) m(y_m) contp(contp) conyp(conyp) mplusp(y_mp) dtax(dtax) n(y_nm) nonc(nonc) flagcct(fcct) otran(otran) g(y_g) taxab(y_taxab) d(y_d) isub(isub) itax(itax) c(y_c) ike(ik_e) ikh(ik_h) hu(hu) f(y_f) hhid(hhid)}{p_end}

{syntab:{cmd:F13.- Incidence (income groups)}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)},
{opth dtax:(varname)}, {opth cont:ributions(varname)}, {opth contp:ensions(varname)}, {opth contyp:ensions(varname)}, {opth nonc:ontributory(varname)}, {opth flagcct:(varname)}, {opth otran:sfers(varname)}, {opth isub:sidies(varname)}, {opth itax:(varname)}, {opth ike:ducation(varname)},
{opth ikh:ealth(varname)}, {opth hu:rban(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f13) o(y_m) m(y_m) contp(contp) contyp(contyp) mplusp(y_mp) dtax(dtax) n(y_nm) nonc(nonc) flagcct(fcct) otran(otran) g(y_g) taxab(y_taxab) d(y_d) isub(isub) itax(itax) c(y_c) ike(ik_e) ikh(ik_h) hu(hu) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F16.-  Fiscal Profile}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth age(varname)}, {opth pens:ions(varname)}, {opth hhe(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f16) o(y_m) d(y_d) c(y_c) pens(pensions) hhe(hhe_id) hhid(hh_id)        ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F17.- Coverage (Total)}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth cct:(varname)}, {opth nonc:ontrib(varname)}, {opth unem:ploy(varname)}, {opth foodt:ransf(varname)}, {opth otran:sfers(varname)},
{opth hea:lth(varname)},  {opth pensions(varname)},  {opth hhe(varname)}, {opth hhid(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f17) o(y_m) cct(cct) nonc(nonc) unem(unemployment) foodt(f_tran) otran(o_tran) hea(health) pen(pensions) hhe(hhe_id) hhid(hh_id) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F18.- Coverage (target)}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth cct:(varname)}, {opth nonc:ontrib(varname)}, {opth pen:sions(varname)},  {opth hhe(varname)}, {opth hhid(varname)},  {opth tarcct(varname)}, {opth tarncp(varname)}, {opth tarpen(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f18) o(y_m) cct(cct) nonc(nonc) pen(pensions) hhe(hhe_id) hhid(hh_id)        tarncp(tncp) tarcct(tcct) tarpen(tpen) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F20.- Mobility}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f20) o(y_m) d(y_d) c(y_c) f(y_f) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F21.- Education (populations)}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth edpre:(varname)}, {opth edpri:(varname)}, {opth edsec:(varname)},
{opth edter:(varname)}, {opth redpre:(varname)}, {opth redpri:(varname)}, {opth redsec:(varname)}, {opth redter:(varname)}, {opth edpub:lic(varname)}, {opth edpriv:ate(varname)}, and {opth attend:(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f21) o(y_m) edpre(ed_pre) edpri(ed_pri) edsec(ed_sec) edter(ed_ter)        attend(attendschool) redpre(red_pre) redpri(red_pri) redsec(red_sec) redter(red_ter) hhe(id_hhead) hhid(id_hh) edpriv(private) edpub(public)}{p_end}

{syntab:{cmd:F23.- Educational Probability}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth edpre:(varname)}, {opth edpri:(varname)}, {opth edsec:(varname)},
{opth edter:(varname)}, {opth redpre:(varname)}, {opth redpri:(varname)}, {opth redsec:(varname)}, {opth redter:(varname)}, {opth attend:(varname)}, {opth hhid:(varname)}, and {opth hhe:ad(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f23) o(y_m) edpre(ed_pre) edpri(ed_pri) edsec(ed_sec) edter(ed_ter)        attend(attendschool) redpre(red_pre) redpri(red_pri) redsec(red_sec) redter(red_ter) hhid(id_hh) hhe(id_hhead) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F24.- Infraestructure Access}}    Variables in {varlist}, [{weight}], {opth o:riginal(varname)}, {opth hhid:(varname)}, {opth hhe:ad(varname)}, {opth water:(varname)}, {opth electricity:(varname)}, {opth walls:(varname)},
{opth floors:(varname)}, {opth roof:(varname)}, {opth sewage:(varname)}, {opth roads:(varname)},and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f24) o(y_m) hhid(id_hh) hhe(id_hhead) water(water) electricity(elect)        walls(walls) floors(floors) roof(roof) sewage(sewage) roads(roads) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}

{syntab:{cmd:F25.- Theil Decomposition}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)},
{opth gender(varname)}, {opth ur:ban(varname)}, and {opth edpar:(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f25) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) gender(sex) urban(rururb) edpar(parentsed)}{p_end}

{syntab:{cmd:F26.- Inequality of Opportunity}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)},
 {opth gender(varname)}, {opth ur:ban(varname)} are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f26) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c) f(y_f) gender(sex) urban(rururb)}{p_end}

{syntab:{cmd:F27.- Significance}}    Variables in {varlist}, [{weight}], {opth m:arket(varname)}, {opth mplusp:ensions(varname)}, {opth n:etmarket(varname)}, {opth g:ross(varname)}, {opth taxab:le(varname)}, {opth d:isposable(varname)}, {opth c:onsumable(varname)}, {opth f:inal(varname)}, {opth psu(varname)}, {opth s:trata(varname)}, and poverty lines are required.
{pstd} Example:{p_end}
{phang} {cmd:. ceqrace [pw=weight] using CEQ_Ethno_Racial_MWB.xlsx,race1(indig) race2(white) race3(afrd) race4(orace) race5(nonrace) table(f27) m(y_m) mplusp(y_mp) n(y_nm) g(y_g) taxab(y_taxab) d(y_d) c(y_c)        f(y_f) psu(upm) strata(strata) ppp(7.65) cpibase(78.661) cpisurvey(105.196) year}{p_end}


{marker opt}
{title:Options}

{marker cor}
{dlgtab:Core options}

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



{marker cut}
{dlgtab:Income group cut-offs options}

{pstd}
{opth cut1(real)} to {opth cut5(real)} are in $PPP. The default cut-off values of $1.90, $3.20 and $5.50 correspond to the income-category-specific poverty lines suggested in Joliffe & Prydz (2016), who determined the median (to the nearest 10 cents) national poverty line in $PPP (using the 2011 ICP PPP conversion factors) for each set of countries grouped under the World Bank's income classification system. Specifically, there are three income class-specific poverty lines: US$1.90 a day for low income countries, US$3.20 a day for lower middle- income countries and US$5.50 a day for upper middle-income countries. Thus, in the context of middle-income countries, we call those living on less than US$1.90 PPP per day the “ultra-poor.” The US$3.20 and US$5.50 PPP per day poverty lines are commonly used as extreme and moderate poverty lines for Latin America and roughly correspond to the median official extreme and moderate poverty lines in those countries.

{pstd}
The $11.50 and $57.60 cutoffs correspond to cutoffs for the vulnerable and middle-class populations suggested for the 2005-era PPP conversion factors by Lopez-Calva and Ortiz-Juarez (2014); $11.50 and $57.60 represent a United States CPI-inflation adjustment of the 2005-era $10 and $50 cutoffs.  The US$10 PPP per day line is the upper bound of those vulnerable to falling into poverty (and thus the lower bound of the middle class) in three Latin American countries, calculated by Lopez-Calva and Ortiz-Juarez (2014). Ferreira and others (2013) find that an income of around US$10 PPP also represents the income at which individuals in various Latin American countries tend to self-identify as belonging to the middle class and consider this a further justification for using it as the lower bound of the middle class. The US$10 PPP per day line was also used as the lower bound of the middle class in Latin America in Birdsall (2010) and in developing countries in all regions of the world in Kharas (2010). The US$50 PPP per day line is the upper bound of the middle class proposed by Ferreira and others (2013).

{pstd}
The user may specify any set of cut points that create exclusive population groups.  For example, the older cut points for the ultra-poor, extreme poor, moderate poor, vulnerable and middle class, which corresponded to the 2005-era PPP conversion factors were $1.25, $2.50, $4, $10 and $50 (respectively).



{hline}
{p 4 4 2}

{title:Author}

{p 4 4 2}Rodrigo Aranda, Tulane University, raranda@tulane.edu

{title:References}

{pstd}Commitment to Equity {browse "http://www.commitmentoequity.org":website}{p_end}

{pstd}Lustig, Nora, editor. 2018. {browse "https://commitmentoequity.org/publications-ceq-handbook":Commitment to Equity Handbook. Estimating the Impact of Fiscal Policy on Inequality and Poverty}. Brookings Institution Press and CEQ Institute, Tulane University. {p_end}

