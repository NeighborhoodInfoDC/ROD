/**************************************************************************
 Program:  extract_foreclosures_history.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   R Grace
 Created:  11/10/2011
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect

 Description:  Extract of foreclosure history for NYU October 2011.

 Modifications: 
***************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

options mprint symbolgen;
** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

/*Download most recent sales_master_forecl file, parcel info files*/
rsubmit;
proc download data=rod.foreclosures_history out=rod.foreclosures_history;
run;
proc download data=realprop.parcel_base out = realprop.parcel_base;
run;
endrsubmit;


proc sort data=realprop.parcel_base out=parcel_base;
by ssl;
proc sort data = rod.foreclosures_history out= foreclosures_history_sorted;
by ssl;
run;

Data forecl_history_address;
	merge 	foreclosures_history_sorted (in = a)
			parcel_base;
	by ssl;
	if a;
run;

Data extract_forecl_history (keep = 
ssl
filingdate_r
x_coord
y_coord
premiseadd
unitnumber
firstnotice_date
lastnotice_date
firstcancel_date
lastcancel_date
firsttdeed_date
lasttdeed_date
num_notice
num_cancel
num_tdeed
outcome_code2
outcome_date
prev_sale_prp
);
	set forecl_history_address;
	where filingdate_r ge '01jan2000'd;/*<--This should capture any foreclosures that started 2000 or later, 
											but it would also capture any foreclosures that ended (outcome) 
											2000 or later, but started earlier than 2000)*/

run;

Data rod.extract_forecl_history;
retain 	
ssl
filingdate_r
x_coord
y_coord
premiseadd
unitnumber
prev_sale_prp
firstnotice_date
lastnotice_date
firstcancel_date
lastcancel_date
firsttdeed_date
lasttdeed_date
num_notice
num_cancel
num_tdeed
outcome_code2
outcome_date
;
	set extract_forecl_history;
run;
/*
proc freq data = rod.extract_forecl_history_102011;
where firstnotice_date lt '01jan2000'd;
tables filingdate_r;
run;

proc freq data = rod.extract_forecl_history_102011;
where firstnotice_date lt '01jan2000'd;
tables firstcancel_date;
run;

proc freq data = rod.extract_forecl_history_102011;
where firstnotice_date lt '01jan2000'd;
tables firstnotice_date;
run;

proc freq data = rod.extract_forecl_history_102011;
where firsttdeed_date lt '01jan2000'd;
tables firsttdeed_date;
run;

proc freq data = rod.extract_forecl_history_102011;
where premiseadd = "";
tables premiseadd;
run;
*/

proc export data=rod.extract_forecl_history replace
   outfile='K:\Metro\PTatian\DCData\Libraries\ROD\prog\NYU_Extract\extract_forecl_history_120511.csv'
   dbms=dlm; 
   delimiter=',';
 run;


