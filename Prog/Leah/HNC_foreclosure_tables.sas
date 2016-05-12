** PROGRAM NAME: HNC_Foreclosure_Tables.sas
**
** PROJECT:  HNC2009, 08358-000-00
** DESCRIPTION : Exploratory work on match DC foreclosure data and sales data.  

** ASSISTING PROGRAMS:
** PREVIOUS PROGRAM:
** FOLLOWING PROGRAM:
**

** AUTHOR    :  L Hendey
**'
** CREATED     : 04/08/09
** MODIFICATIONS: 04/09/09
**   
**
*******************************************************************************;

%include 'k:\metro\kpettit\hnc2009\programs\hncformats.sas';

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);
%fdate();
** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


proc format;
  value $OwnCat
    '010' = 'Single-family owner-occupied'
    '020' = 'Multifamily owner-occupied'
    '030' = 'Other individuals'
    '040' = 'DC government'
    '050' = 'US government'
    '060' = 'Foreign governments'
    '070' = 'Quasi-public entities'
    '080' = 'Community development corporations/organizations'
    '090' = 'Private universities, colleges, schools'
    '100' = 'Churches, synagogues, religious'
    '110' = 'Corporations, partnership, LLCs, LLPs, associations'
    '111' = 'Nontaxable corporations, partnerships, associations'
    '115' = 'Taxable corporations, partnerships, associations'
	'120' = 'Government-Sponsored Enterprise'
	'130' = 'Banks, Lending, Mortgage and Servicing Companies'
    ;

	value outcomII

	1="In foreclosure"
	2="Property sold, foreclosed, REO"
	3="Property sold, foreclosed, Other"
	4="Property sold, distressed sale, REO"
	5="Property sold, distressed sale, Other"
	6="Property sold, distressed sale, Pre 2001"
	7="Property sold, foreclosure avoided"
	8="No sale, foreclosure avoided"
	9="Cancellation"
	.n="No notices before regular sale";
	
	value outcome
	1="In foreclosure"
	2="Property sold, foreclosed"
	3="Property sold, distressed sale"
	4="Property sold, foreclosure avoided"
	5="No sale, foreclosure avoided"
	6="Cancellation"
	.n="No notices before regular sale";
	
run;
proc contents data=rod.foreclosure_sales_collapse;
run;

data table1;
	set rod.foreclosure_sales_collapse;

if firstnotice_date ne . then firstnotice_year=year(firstnotice_date);
else if firstnotice_year=. then firstnotice_year=year(tdeed_date);
else if firstnotice_year=. then firstnotice_year=year(post_sale_date);

if outcome_date ne .n then outcome_year=year(outcome_date);
else if outcome_year=. then outcome_year=year(firstnotice_date);

flag_residential=.;
if ui_proptype in ('10' '11' '12' '13') then flag_residential=1;

flag_sfcondo=.;
if ui_proptype in ('10' '11') then flag_sfcondo=1;

flag_singlefamily=.;
if ui_proptype='10' then flag_singlefamily=1;

flag_condo=.;
if ui_proptype='11' then flag_condo=1;

flag_multifamily=.;
if ui_proptype in ('12' '13') then flag_multifamily=1; 

flag_resident_cat=.;
if ui_proptype ='10' then flag_resident_cat=1;
if ui_proptype='11' then flag_resident_cat=2;
if ui_proptype in ('12' '13') then flag_resident_cat=3;

flag_ownerocc=.;  
if prev_sale_ownocc=1 then flag_ownerocc=1;

flag_renterocc=.;
if prev_sale_ownocc=0 then flag_renterocc=1;

aval_category=.;
if 0 <= prev_sale_aval <75000 then aval_category=1;
if 75000 <= prev_sale_aval <125000 then aval_category=2;
if 125000 <= prev_sale_aval <250000 then aval_category=3;
if  prev_sale_aval >=250000 then aval_category=4;

ownership_years=(firstnotice_date-prev_sale_date)/365;
ownership_years_cat=.;
if 0 <= ownership_years <1 then ownership_years_cat=1;
if 1 <= ownership_years <3  then ownership_years_cat=2;
if 3 <= ownership_years <5 then ownership_years_cat=3;
if  ownership_years >=5 then ownership_years_cat=4;


count=1;
prev_sale_year=year(prev_sale_date);

flag_anynotice=.;
if num_notice gt 0 then flag_anynotice=1;

flag_fcdistress=.;
if outcome_code in (2 3) then flag_fcdistress=1;

run;



proc format ;
	value res_cat
	1="Single-Family Home"
	2="Condominium"
	3="Multi-Family Building";

	value tenure
	1="Owner-Occupied"
	0="Renter-Occupied"
	.n="Unknown";

	value aval
	1="$0 to $75,000"
	2="$75,000 to $125,000"
	3="$125,000 to $250,000"
	4="$250,000 and above";

	value ownyr
	1="Less than 1 year"
	2="1 to 3 years"
	3="3 to 5 years"
	4="5 years or more";

	run;

options nonumber nodate;
%macro tables;
%let yvar=firstnotice_year outcome_year;
%let ylab=Year of First Notice/Year of Outcome;
%let ylab2='Year of First Notice'/'Year of Outcome';
%do i=1 %to 2;
%let year=%scan(&yvar.,&i.,' ');
%let lab=%scan(&ylab.,&i.,'/');  
%let lab2=%scan(&ylab2.,&i,'/');

ods rtf file="D:\Projects\HNC\DC Foreclosure Tables, &lab..rtf" style=Styles.Rtf_arial_9pt;
title1 "Housing in the Nation's Capitol, 2009";
title2 "Reference Year is &lab.";
title3 "Table 1: Total Residential Properties in DC with Foreclosure Episode";
proc tabulate data=table1;
	where &year. ge 2000;
	var flag_residential;
	class outcome_code2 &year.;
	table outcome_code2=' ' all='Total',
		 flag_residential=' '*(&year.="&lab2."*colpctn=' ')/BOX="Percent";
    run;
proc tabulate data=table1;
	where &year. ge 2000;
	var flag_residential;
	class outcome_code2 &year.;
	table outcome_code2=' ' all='Total',
		 flag_residential=' '*( &year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;						

title3 "Table 1a: Residential Properties in DC with Foreclosure Episode, Outcomes by Structure Type";
proc tabulate data=table1;
	where &year. ge 2000;
	var count;
	format flag_resident_cat res_cat.;
	class outcome_code2 flag_resident_cat &year.;
	table outcome_code2=' ' all='Total', (flag_resident_cat='Type of Structure')*
		(&year.="&lab2."*colpctn=' '	)/BOX="Percent";
    run;		
proc tabulate data=table1;
	where &year. ge 2000;
	var count;
	format flag_resident_cat res_cat.;
	class outcome_code2 flag_resident_cat &year.;
	table outcome_code2=' ' all='Total', (flag_resident_cat='Type of Structure')*
		(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		

title3 "Table 2: Single-Family Homes and Condominiums  in DC with Foreclosure Episode, Outcomes by Tenure";
proc tabulate data=table1;
	where &year. ge 2000 and flag_sfcondo=1;
	var count;
	format prev_sale_ownocc tenure.;
	class outcome_code2 prev_sale_ownocc &year.;
	table outcome_code2=' ' all='Total', (prev_sale_ownocc ='Tenure')*
		(&year.="&lab2."*colpctn=' '	)/BOX="Percent";
    run;		
proc tabulate data=table1;
	where &year. ge 2000 and flag_sfcondo=1;
	var count;
	format prev_sale_ownocc tenure.;
	class outcome_code2 prev_sale_ownocc &year.;
	table outcome_code2=' ' all='Total', (prev_sale_ownocc='Tenure')*
		(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		

title3 "Table 3: Single-Family Homes and Condominiums in DC with Foreclosure Episode, Outcomes by Original Assessed Value";
proc tabulate data=table1;
	where &year. ge 2000 and flag_sfcondo=1;
	var count;
	format aval_category aval.;
	class outcome_code2 aval_category &year.;
	table outcome_code2=' ' all='Total', (aval_category ='Original Assessed Value')*
		(&year.="&lab2."*colpctn=' ' )/BOX="Percent";
    run;		
proc tabulate data=table1;
	where &year. ge 2000 and flag_sfcondo=1;
	var count;
	format aval_category aval.;
	class outcome_code2 aval_category &year.;
	table outcome_code2=' ' all='Total', (aval_category='Original Assessed Value')*
		(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		

title3 "Table 4: Single-Family Homes and Condominiums  in DC with Foreclosure Episode, Length of Ownership Before Notice";
proc tabulate data=table1;
	where &year. ge 2003 and flag_sfcondo=1;
	var flag_anynotice flag_fcdistress;
	format ownership_years_cat ownyr.;
	class ownership_years_cat  &year.;
	table ownership_years_cat=' ' all='Total', (flag_anynotice='Any Property with Foreclosure Notice'
									        flag_fcdistress='Foreclosed/Distressed Sale Properties')*
			(&year.="&lab2."*colpctn=' ' )/BOX="Percent";
run;
proc tabulate data=table1;
	where &year. ge 2003 and flag_sfcondo=1;
	var flag_anynotice flag_fcdistress;
	format ownership_years_cat ownyr.;
	class ownership_years_cat  &year.;
	table ownership_years_cat=' ' all='Total', (flag_anynotice='Any Property with Foreclosure Notice'
									        flag_fcdistress='Foreclosed/Distressed Sale Properties')*
			(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		

title3 "Table 4a: Single-Family Homes and Condominiums  in DC with Foreclosure Episode, Length of Ownership Before Notice, by Tenure";
	proc tabulate data=table1;
	where &year. ge 2003 and flag_sfcondo=1;
	var flag_anynotice flag_fcdistress;
	format ownership_years_cat ownyr. prev_sale_ownocc tenure.;
	class ownership_years_cat &year. prev_sale_ownocc;
	table prev_sale_ownocc,(ownership_years_cat=' ' all='Total'), (flag_anynotice='Any Property with Foreclosure Notice'
									        flag_fcdistress='Foreclosed/Distressed Sale Properties')*
			(&year.="&lab2."*colpctn=' ' )/BOX="Percent";
    run;		


	proc tabulate data=table1;
	where &year. ge 2003 and flag_sfcondo=1;
	var flag_anynotice flag_fcdistress;
	format ownership_years_cat ownyr. prev_sale_ownocc tenure.;
	class ownership_years_cat &year. prev_sale_ownocc;
	table prev_sale_ownocc,(ownership_years_cat=' ' all='Total'), (flag_anynotice='Any Property with Foreclosure Notice'
									        flag_fcdistress='Foreclosed/Distressed Sale Properties')*
			(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		


footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
ods rtf close;
%end;


%mend;
%tables;

	
proc tabulate data=table1;
	where firstnotice_year ge 2003 and flag_sfcondo=1;
	var flag_anynotice;
	format ownership_years_cat ownyr. prev_sale_ownocc tenure.;
	class ownership_years_cat  firstnotice_year prev_sale_ownocc;
	table ownership_years_cat=' ' all='Total', (prev_sale_ownocc="Tenure" )* 
			firstnotice_year="Year of First Notice"*N=" "/BOX="Frequency";
    run;		

	proc freq data=table1;
	where flag_sfcondo=1 and flag_fcdistress=1 and firstnotice_year ge 2003;
	tables ownership_years_cat*firstnotice_year;
	run;


	proc tabulate data=table1;
	where &year. ge 2003 and flag_sfcondo=1;
	var flag_anynotice flag_fcdistress;
	format ownership_years_cat ownyr. prev_sale_ownocc tenure.;
	class ownership_years_cat &year. prev_sale_ownocc;
	table prev_sale_ownocc*(ownership_years_cat all='Total'), (flag_anynotice='Any Property with Foreclosure Notice'
									        flag_fcdistress='Foreclosed/Distressed Sale Properties')*
			(&year.="&lab2."*N=' '*f=comma8. )/BOX="Frequency";
    run;		
