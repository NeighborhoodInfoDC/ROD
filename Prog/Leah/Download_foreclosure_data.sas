%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

rsubmit;

%let start_dt = '01jan1990'd;
%let end_dt   = '31dec2008'd;

data Foreclosures;

  set
	Rod.Foreclosures_1990
	Rod.Foreclosures_1991
	Rod.Foreclosures_1992
	Rod.Foreclosures_1993
	Rod.Foreclosures_1994
	Rod.Foreclosures_1995
  	Rod.Foreclosures_1996
    Rod.Foreclosures_1997
    Rod.Foreclosures_1998
    Rod.Foreclosures_1999
    Rod.Foreclosures_2000
    Rod.Foreclosures_2001 
    Rod.Foreclosures_2002 
    Rod.Foreclosures_2003 
    Rod.Foreclosures_2004 
    Rod.Foreclosures_2005
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007 
    Rod.Foreclosures_2008
  ;
  by filingdate;
 
  where  ( &start_dt <= filingdate <= &end_dt ); 
  **where ui_proptype in ( '10', '11' ) and ( &start_dt <= filingdate <= &end_dt );
  **where ui_proptype in ( '10', '11' ) and ui_instrument in ( 'F1' 'F5') and ( &start_dt <= filingdate <= &end_dt );
  
run;

proc download status=no
  data=Foreclosures 
  out=Foreclosures;

run;

endrsubmit;
