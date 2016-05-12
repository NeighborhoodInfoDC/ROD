/**************************************************************************
 Program:  Monthly_foreclosures.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Monthly foreclosure report.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

proc format;
  value $propsum
    '10' = 'Single-family homes'
    '11' = 'Condominium units'
    '12', '13' = 'Multifamily buildings';
run;

%let start_date = '01aug2007'd;
%let end_date = '31aug2009'd;

** Notices filed, residential properties only **;

data Notices / view=Notices;

  set 
    Rod.Foreclosures_2007
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009;
  
  where &start_date <= filingdate <= &end_date and ui_proptype =: '1' and
   ui_instrument in ( 'F1', 'F5' );
   
  length mon_ab $ 1;
  mon_ab = put( filingdate, monname1. );

run;

proc summary data=Notices nway;
  class ui_instrument ui_proptype filingdate mon_ab ssl;
  id x_coord y_coord;
  output out=Notices_monthly_ssl;
  format filingdate yymmd7. ui_proptype $propsum.;
run;

proc summary data=Notices_monthly_ssl chartype;
  class ui_instrument ui_proptype filingdate mon_ab;
  output out=Notices_monthly (where=(_type_ in ( '1011', '1111' ) ) );
  format filingdate yymmd7. ui_proptype $propsum.;
run;

proc print;

run;

filename fexport "D:\DCData\Libraries\ROD\Prog\Notices_monthly.csv" lrecl=1000;

proc export data=Notices_monthly
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;


** Mapping data **;

data Rod.Notices_monthly_ssl_2009_08 (compress=no);
  set Notices_monthly_ssl;
  where year( filingdate ) = 2009;
run;
