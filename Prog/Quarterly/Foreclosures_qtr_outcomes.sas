 filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_qtr_outcomes.log";
 filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_qtr_outcomes.lst";
 proc printto print=outnew log=lognew new;
 run;
/************************************************************************
 Program:  Foreclosures_qtr_outcomes.sas
 Library:  ROD
 Project:  DC Data Warehouse
 Author:   L. Hendey
 Created:  6/22/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create quarterly charts on foreclosure outcomes including for renter and seniors,
			   Based on original programming for HNC 2009.

 Modifications:

************************************************************************/

%let forecl_file= &forecl_hist_file;
%let suffix=&val_suffix.;
%let end_dt=&val_end.; *end_dt is the end of the reference period - records with a start date after the end date are not included in tables;
%let end_yr=&val_endyr.;
%let end_lag=&val_endlag;

proc format ;

  value $prop
    '10' = 'Single-family homes'
    '11' = 'Condominium units'
    '12', '13' = 'Multifamily (Coops/Rental)';

	value res_cat
	1="Single-Family Home"
	2="Condominium"
	3="Multi-Family Building";

	value tenure
	1="Owner-Occupied"
	0="Renter-Occupied"
	.n="Unknown";

	value owndt

	1="Purchased before 2003"
	2="Purchased between 2004 and 2006"
	3="Purchased 2007 or later";

	value colpse

	1="Foreclosure Completed"
	2="Distressed Sale"
	3="Foreclosure Avoided"
	4="Cancellation"
	5="Foreclosure Inventory" ;

	value $ptype

	10='Owner-Occupied Single-Family Home or Condominium'
	11='Renter-Occupied Single-Family Home or Condominium'
	12='Cooperative Building'
	14='Rental Apartment Building - Less than 5 Units'
	15='Rental Apartment Building - 5 or More Units';

	value pten

	1="Single-Family Homes: Owner-Occupied"
	2="Condominiums: Owner-Occupied"
	3="Single-Family Homes: Renter-Occupied"
	4="Condominiums: Renter-Occupied"
	5="Cooperatives"
	6="Rental Apartment Buildings: Less than 5 Units"
	7='Rental Apartment Buildings: 5 or More Units';

	value senr

	1="All Owner-Occupied"
	2="Moderate-Income Elderly Owner-Occupied";

run;
run;

/*
rsubmit;
proc download data=rod.FORECLOSURES_HISTORY out=rod.FORECLOSURES_HISTORY;
run;
endrsubmit;*/



data table1;
	set rod.&forecl_file.; 

***** Set episode dates for days to foreclosure*****;
 /**old code assumed 365 for missing first notice date - new code only uses episodes with valid first notice dates**
if outcome_code = 2 then do;
	  if not( missing( firstnotice_date ) ) then start_dt = firstnotice_date;
	  else if not( missing( outcome_date ) ) then start_dt = outcome_date - 365;
	  
	  if not( missing( outcome_date ) ) then end_dt = outcome_date;
	  else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 365;
	  else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 365;
	  
	  *if missing( start_dt ) or missing( end_dt ) then delete;
	  
	  if '01jan1999'd <= start_dt < &end_dt.;
	  
	  days = end_dt - start_dt;  
end;*/
if outcome_code = 2 then do;
	  if not( missing( firstnotice_date ) ) then start_dt = firstnotice_date;
  
	  if not( missing( outcome_date ) ) then end_dt = outcome_date;
	  
	  *if missing( start_dt ) or missing( end_dt ) then delete;
	  
	  if '01jan1999'd <= start_dt < &end_dt.;
	  
	  days = end_dt - start_dt;  
end;
*****Set first notice years for outcome data*****; 
	if firstnotice_date ne . then firstnotice_year=year(firstnotice_date);
	*if firstnotice_date=. then firstnotice_year=year(outcome_date-365);

*****Set first notice quarters for outcome data*****;

	*subfirstnotice_date=outcome_date-365;
	firstnotice_qtr = intnx( "qtr", firstnotice_date, 0, 'end' );
	*if firstnotice_qtr=. then firstnotice_qtr = intnx( "qtr", subfirstnotice_date, 0, 'end' );

*****Deleting records if firstnotice_date is past end reference date*****;

	if firstnotice_date gt &end_dt. then delete;
	if firstnotice_date=. and (outcome_date-365) gt &end_dt. then delete;


*****Collapse outcome code - remove in foreclosure group for outcomes*****;

	outcome_code_collapse=.;
	if outcome_code=2 then outcome_code_collapse=1;
	if outcome_code=3 then outcome_code_collapse=2;
	if outcome_code in (4 5) then outcome_code_collapse=3;
	if outcome_code=6 then outcome_code_collapse=3; *counting cancellations as foreclosure avoided;
	if outcome_code=1 then outcome_code_collapse=5;
	
*****Property Type flags*****;
flag_residential=.;
if prev_sale_prp in ('10' '11' '12' '13') then flag_residential=1;

flag_sfcondo=.;
if prev_sale_prp in ('10' '11') then flag_sfcondo=1;

flag_singlefamily=.;
if prev_sale_prp='10' then flag_singlefamily=1;

flag_condo=.;
if prev_sale_prp='11' then flag_condo=1;

flag_multifamily=.;
if prev_sale_prp in ('12' '13') then flag_multifamily=1; 

flag_resident_cat=.;
if prev_sale_prp ='10' then flag_resident_cat=1;
if prev_sale_prp='11' then flag_resident_cat=2;
if prev_sale_prp in ('12' '13') then flag_resident_cat=3;

flag_ownerocc=.;  
if prev_sale_ownocc=1 then flag_ownerocc=1;

flag_renterocc=.;
if prev_sale_ownocc=0 then flag_renterocc=1;

length new_proptype $ 2;
 if prev_sale_prp = '13' then do;
    if usecode in ( '023', '024' ) then new_proptype = '14';
    else new_proptype = '15';
  end;
  else new_proptype = prev_sale_prp;


***Foreclosure Type flags****;;
flag_anynotice=.;
if num_notice gt 0 then flag_anynotice=1;

flag_fcdistress=.;
if outcome_code in (2 3) then flag_fcdistress=1;


*****When property was purchased*****;
ownership_date=.;
if prev_sale_date <= '31dec2003'd then ownership_date=1;
if '01jan2004'd <= prev_sale_date <= '31dec2006'd then ownership_date=2;
if prev_sale_date  >= '01jan2007'd then ownership_date=3;


count=1;

run;


****Foreclosure Outcome Tables ;
ods tagsets.excelxp file="&_dcdata_path\ROD\prog\Quarterly\Foreclosures_outcomes_&suffix..xls"  style=styles.minimal_mystyle options(sheet_interval='page' );
ods tagsets.excelxp options( sheet_name="Ann. Outcome #" );
	proc tabulate data=table1;
		where 2003 <= firstnotice_year <= &end_yr.;
		var flag_residential;
		format outcome_code_collapse colpse.; 
		class outcome_code_collapse firstnotice_year;
		table outcome_code_collapse=' ' all='Total',
			 flag_residential=' '*(firstnotice_year="Year of First Notice of Foreclosure Sale"*N=' '*f=comma10. );
	    run;
ods tagsets.excelxp options( sheet_name="Ann. Outcome %");
	proc tabulate data=table1 format=8.0;
		where 2003 <= firstnotice_year <= &end_yr.;
		var flag_residential;
		format outcome_code_collapse colpse.; 
		class outcome_code_collapse firstnotice_year;
		table outcome_code_collapse=' ' all='Total',
			 flag_residential=' '*(firstnotice_year="Year of First Notice of Foreclosure Sale"*colpctn=' '*f=comma10.2);
	    run;

ods tagsets.excelxp options( sheet_name="Qtr. Outcome #" );
	proc tabulate data=table1;
		where 2003 <= firstnotice_year <= &end_yr.;
		var flag_residential;
		format outcome_code_collapse colpse. firstnotice_qtr yyq.; 
		class outcome_code_collapse firstnotice_qtr ;
		table outcome_code_collapse=' ' all='Total',
			 flag_residential=' '*(firstnotice_qtr="Quarter of First Notice of Foreclosure Sale"*N=' '*f=comma10. );
	    run;
ods tagsets.excelxp options( sheet_name="Qtr. Outcome %");
	proc tabulate data=table1 format=8.0;
		where 2003 <= firstnotice_year <= &end_yr.;
		var flag_residential;
		format outcome_code_collapse colpse. firstnotice_qtr yyq.; 
		class outcome_code_collapse firstnotice_qtr;
		table outcome_code_collapse=' ' all='Total',
			 flag_residential=' '*(firstnotice_qtr="Quarter of First Notice of Foreclosure Sale"*colpctn=' '*f=comma10.2);
	    run;

ods tagsets.excelxp options( sheet_name="Ann. Time to FC");

proc tabulate data=table1 format=comma10.0 noseps missing;
  where '01jan1999'd <= start_dt < &end_lag. and flag_sfcondo=1 ;
  class prev_sale_prp start_dt;
  var days;
  table 
    /** Rows **/
    start_dt=' ',
    /** Columns **/
    n='Properties Going to Foreclosure Sale'
    ( mean='Average Time to Foreclosure (Days)' * days=' ' ) * ( all='\~\~Total' prev_sale_prp=' ' )
    / box='Foreclosure Start';
  format prev_sale_prp $prop. start_dt year4.;

run;

ods tagsets.excelxp options( sheet_name="Qtr. Time to FC");
proc tabulate data=table1 format=comma10.0 noseps missing;
  where '01jan2007'd <= start_dt < &end_dt. and flag_sfcondo=1;
  class prev_sale_prp start_dt;
  var days;
  table 
    /** Rows **/
    start_dt=' ',
    /** Columns **/
    n='Properties Going to Foreclosure Sale'
    ( mean='Average Time to Foreclosure (Days)' * days=' ' ) * ( all='\~\~Total' prev_sale_prp=' ' )
    / box='Foreclosure Start';
  format prev_sale_prp $prop. start_dt yyq.;

run;
ods tagsets.excelxp close;



proc printto;
run;
