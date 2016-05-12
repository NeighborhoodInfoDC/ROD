
/**************************************************************************
 Program:  Monthly_foreclosures_2009_12_newmap.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  1/06/10
 Version:  SAS 9.1
 Environment:  Alpha w/SAS Connect
 
 Description:  Monthly foreclosure report.
 December 2009

 Modifications: L Hendey - Modified PT's original file. 
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

%let start_date = '01dec2007'd;
%let end_date = '31dec2009'd;
%let suffix = 2009_12;

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
/*
data classlev;

  length year $ 4;

  dt = &start_date;
  
  do while ( dt <= &end_date );
  
    year = put( dt, year4. );
    
    output;
    
    dt = intnx( 'month', dt, 1 );

  end;
  
  keep year;

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
*/
** Notices filed, residential properties only **;

data Notices / view=Notices;

  set 
    Rod.Foreclosures_2007
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009;
  
  where &start_date <= filingdate <= &end_date and ui_proptype =: '1' and
   ui_instrument in ( 'F1', 'F5' );
   
  length year $ 4;
  year = put( filingdate, year4. );

run;

proc summary data=Notices nway;
  class ui_instrument ui_proptype year ssl;
  id x_coord y_coord ward2002;
  output out=Notices_2009_ssl;
  format ui_proptype $propsum.;
run;
proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select Notices_2009_ssl ;

run;

endrsubmit;

** End submitting commands to remote server **;


** Export data for mapping **;

data Rod.Notices_2009_ssl_&suffix (compress=no);
  set Notices_2009_ssl;
  *where year( filingdate ) = year( &end_date );
  where year =: "2009";
run;

signoff;


proc freq data=rod.notices_2009_ssl_2009_12;
tables ui_proptype*ui_instrument;
run;
proc freq data=rod.notices_2009_ssl_2009_12;
where ui_proptype='10';
tables ui_instrument*ward2002;
run;
proc freq data=rod.notices_2009_ssl_2009_12;
where ui_proptype='11';
tables ui_instrument*ward2002;
run;
proc freq data=rod.notices_2009_ssl_2009_12;
where ui_proptype in ('12' '13');
tables ui_instrument*ward2002;
run;
