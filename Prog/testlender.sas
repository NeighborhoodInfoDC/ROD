
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )
%let start_dt = '01jan1990'd;
%let end_dt   = '30sep2010'd;

%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;

rsubmit ;
%let start_yr = %sysfunc( year( &start_dt ) );
%let end_yr = %sysfunc( year( &end_dt ) );

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
    Rod.Foreclosures_2009
    Rod.Foreclosures_2010
  ;
 
  where  ( &start_dt <= filingdate <= &end_dt ); 
  **where ui_proptype in ( '10', '11' ) and ( &start_dt <= filingdate <= &end_dt );
  **where ui_proptype in ( '10', '11' ) and ui_instrument in ( 'F1' 'F5') and ( &start_dt <= filingdate <= &end_dt );
  
run;

data trusteedeed foreclose;
	set foreclosures; 

year=year(filingdate);

	if ui_instrument in ('F1' 'F4')  then output foreclose;
	if ui_instrument = 'F5'   then output trusteedeed;

	run;
proc sort data=realprop.sales_master;
by ssl saledate;
proc sort data=trusteedeed;
by ssl filingdate;
run;
data trustee_sales;
merge realprop.sales_master (in=a  rename=(saledate=filingdate))
	  
	  trusteedeed (in=b keep=ui_instrument ssl filingdate grantee grantor xlot multiplelots ui_proptype)
			;
by ssl filingdate;

if a then sales=1; 

%lender_history(grantee,granteeR);

if granteeR=" " then granteeR=grantee;

run;
endRsubmit;
