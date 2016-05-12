/**************************************************************************
 Program:  Foreclosures_check_parcels.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey 
 Created:  11/10/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: 

**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

rsubmit;
proc download data=rod.foreclosures_history out=rod.foreclosures_history;
run;
endrsubmit;
rsubmit;
proc download data=rod.foreclosures_2010 out=rod.foreclosures_2010;
run;
endrsubmit;

data ROD.Foreclosures_1999_2010 / view=ROD.Foreclosures_1999_2010;

  set
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
 
run;


proc sort data=rod.foreclosures_history out=history; 
by filingdate;
data history2;
	set history;
where ownerpt_extractdat_last=. and filingdate gt '01jan2003'd;

run;

proc sort data=history2;
by ssl filingdate;
run;

proc sort data=ROD.Foreclosures_1999_2010 out=view;
by ssl filingdate;

data history_doc;
merge history2 (in=a) view (keep=ssl filingdate Instrument DocumentNo grantor grantee) ;
if a;
by ssl filingdate;

run;
proc sort data=realprop.parcel_base out=parcel;
by ssl;
data history_doc_addr; 
merge history_doc (in=a) parcel (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last premiseadd proptype);
if a;
by ssl;

keep ssl ownerpt_extractdat_first premiseadd proptype
run;


proc sort data=ROD.Foreclosures_1999_2010 out=view;
by ssl ;
proc sort data=realprop.parcel_base out=parcel;
by ssl;
data test_file;
merge view (in=a) parcel (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last premiseadd proptype);
if a;
by ssl;
run;

data file_2003plus;
set test_file;
where filingdate gt  '01jan2003'd & ownerpt_extractdat_last =.;
run;
proc print data=file_2003plus;
where verified=0 and filingdate lt '01oct2010'd;
var ssl documentno instrument filingdate grantee;
run;
proc export data=file_2003plus 
OUTFILE= "D:\DCDATA\Libraries\ROD\Prog\SSL to Check.csv" 
            DBMS=CSV REPLACE;
RUN;


proc print data=rod.foreclosures_history;
where lastnotice_grantorR="Mortgage Electronic Registration Systems";
var ssl lastnotice_date lastnotice_grantorR Ui_proptype;
run;

proc print data=realprop.sales_master;
where ssl="0507    0074";
run;

data file_2003plus_UI;
set test_file;
where filingdate gt  '01jan2003'd & ownerpt_extractdat_last ~=. and ownerpt_extractdat_last lt '01jan2009'd;
run;
proc print data=file_2003plus_UI;
where verified=0 and filingdate lt '01oct2010'd;
var ssl documentno instrument filingdate grantee;
run;
proc export data=file_2003plus_UI 
OUTFILE= "D:\DCDATA\Libraries\ROD\Prog\SSL to Check UI.csv" 
            DBMS=CSV REPLACE;
RUN;
