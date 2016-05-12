/**************************************************************************
 Program:  Monthly_foreclosures_2011_05.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  5/17/10
 Version:  SAS 9.1
 Environment:  Alpha w/SAS Connect
 
 Description:  Monthly foreclosure report.
 September 2010

 Modifications: 01/28/10 L Hendey - Corrected data for map download. 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

proc format;
  value $propsum
    '10' = 'Single-family homes'
    '11' = 'Condominium units'
    '12', '13' = 'Multifamily buildings';
run;

** update by one month each time **;

%let start_date = '01May2009'd;
%let end_date = '31May2011'd;
%let suffix = 2011_05;

%syslput start_date=&start_date;
%syslput end_date=&end_date;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=work 
  outlib=work memtype=(catalog);
  select formats;
run;

** Create format with year/month to makes sure every month is included **;

data classlev;

  length yymm $ 7;

  dt = &start_date;
  
  do while ( dt <= &end_date );
  
    yymm = put( dt, yymmd7. );
    
    output;
    
    dt = intnx( 'month', dt, 1 );

  end;
  
  keep yymm;

run;

proc print data=classlev;

%Data_to_format(
  FmtLib=work,
  FmtName=$yymm,
  Desc=,
  Data=classlev,
  Value=yymm,
  Label=yymm,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=N
  )

** Notices filed, residential properties only **;

data Notices / view=Notices;

  set 
    Rod.Foreclosures_2007
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009
	Rod.Foreclosures_2010
	Rod.Foreclosures_2011;
  
  where &start_date <= filingdate <= &end_date and ui_proptype =: '1' and
   ui_instrument in ( 'F1', 'F5' );
   
  length yymm $ 7 year $ 4;
  yymm = put( filingdate, yymmd7. );
  year = put( filingdate, year4. );
  
run;

** for charts **;
proc summary data=Notices nway;
  class ui_instrument ui_proptype yymm ssl;
  id x_coord y_coord;
  output out=Notices_monthly_ssl;
  format ui_proptype $propsum.;
run;

proc summary data=Notices_monthly_ssl chartype completetypes;
  class ui_instrument;
  class ui_proptype yymm / preloadfmt exclusive;
  output out=Notices_monthly (where=(_type_ in ( '101', '111' ) ) );
  format ui_proptype $propsum. yymm $yymm.;
run;

proc print data=Notices_monthly;

run;

** for maps **;
proc summary data=Notices nway;
  class ui_instrument ui_proptype year ssl;
  id x_coord y_coord ward2002;
  output out=Notices_year_ssl;
  format ui_proptype $propsum.;
run;

proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select Notices_monthly_ssl Notices_monthly Notices_year_ssl;

run;

endrsubmit;

** End submitting commands to remote server **;


** Export data for monthly charts **;

data Notices_monthly_b;

  retain ui_instrument ui_proptype yymm mon_ab _type_ _freq_;

  set Notices_monthly;
  
  if missing( _freq_ ) then _freq_ = 0;
  
  ** Single letter month abbreviation **;
  
  length mon_ab $ 1;
  mon_ab = put( mdy( substr( yymm, 6, 2), 1, substr( yymm, 1, 4 ) ), monname1. );

run;

filename fexport "D:\DCData\Libraries\ROD\Prog\Monthly\Notices_monthly_&suffix..csv" lrecl=1000;

proc export data=Notices_monthly_b
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;


** Export data for mapping **;

data Rod.Notices_year_ssl_&suffix (compress=no);
  set Notices_year_ssl;
  where year =: "2011";
run;

proc freq data=rod.notices_year_ssl_&suffix;
tables ui_proptype*ui_instrument;
run;

signoff;



