 /**************************************************************************
 Program:  Foreclosures_rtp_reo_EvanHenley.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   R. Grace
 Created:  07/02/12
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a foreclosure data set with REO properties for list of property addresses and owners.

 Modifications: From Foreclosures_rtp_reo.sas by Peter Tatian (mod. 05/07/09 L. Hendey For HNC - REO Data)
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
libname rod "D:\DCData\Libraries\ROD\Data";
libname realprop "D:\DCData\Libraries\RealProp\Data";

%let suffix=_evan;
%let end_date='30sep2011'd;

/** Macro Foreclosures - Start Definition **/

%macro Foreclosures_reo( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds (where = (in_reo_end = 1));

    set Rod.Foreclosures_history;
    where prev_sale_prp in ( '10', '11', '12', '13' );

	*not using or prev_sale_date as 1 option because only want inventory from foreclosures or using or next_sale_date as 3 option
		because do not have sale after that in foreclosure history file;
     
	if not( missing( post_sale_date ) ) then start_dt = post_sale_date; 
	else if not( missing( outcome_date ) )  then start_dt = outcome_date;
	
    if not( missing( next_sale_date ) ) then end_dt = next_sale_date;
	else end_dt = &rpt_end_dt;

	if missing( start_dt ) then delete;
    
    ** Align start and end dates with beginning of quarter **;
    
 	adj_start_dt = intnx( "&unit", start_dt, 0, 'beginning' );
    adj_end_dt = intnx( "&unit", end_dt, 0, 'beginning' );

    ** Create obs. for each ssl/episode/qtr with outcome vars. **;
    
    length 
       in_reo_beg in_reo_end reo_start 3;
    
    report_dt = intnx( "&unit", max( adj_start_dt, &rpt_start_dt ), 0, 'beginning' );
    
    do while ( report_dt <= min( adj_end_dt, &rpt_end_dt ) );
    
      report_dt_end = intnx( "&unit", report_dt, 0, 'end' );
    
      if post_sale_reo = 1 and ( start_dt < report_dt and end_dt >= report_dt ) then in_reo_beg = 1;
      else in_reo_beg = 0;
      
      if post_sale_reo = 1 and ( start_dt < report_dt_end and end_dt >= report_dt_end ) then in_reo_end = 1;
      else in_reo_end = 0;
		
	  if post_sale_reo = 1 and ( report_dt <= start_dt <= report_dt_end ) then reo_start = 1;
      else reo_start = 0;
      
 	  output;
	  report_dt = intnx( "&unit", report_dt, 1, 'beginning' );
  	end;
    
    format report_dt start_dt end_dt adj_start_dt adj_end_dt  mmddyy10.;
    
    label 
      report_dt = 'Report reference date'
      start_dt = 'Episode start date'
      end_dt = 'Episode end date'
	  in_reo_beg = 'REO Inventory (beginning of reporting period)'
	  in_reo_end = 'REO Inventroy (end of reporting period)'
	  reo_start = 'Property Enters REO Inventory'
    ;
    
    keep 
      ssl city ward2002 zip post_sale_owncat post_sale_ownerr report_dt end_dt adj_end_dt outcome_date outcome_code2 
	  in_reo_end reo_start post_sale_reo firstnotice_date ;
    
  run;


%mend Foreclosures_reo;

/** End Macro Definition **/


%Foreclosures_reo( out_ds= Foreclosures_qtr_reo_&suffix., unit=qtr, rpt_end_dt=&end_date. )


proc sort data = realprop.parcel_base out = parcel_base ;
by ssl;
run;

data Forecl_reo (where = (in_reo_end = 1 and report_dt = '01jul2011'd) keep = premiseadd ssl ward2002 zip post_sale_owncat post_sale_ownerr report_dt end_dt adj_end_dt outcome_date outcome_code2 
	  in_reo_end reo_start post_sale_reo firstnotice_date);
	merge Foreclosures_qtr_reo_&suffix. (in = a) parcel_base;
	by ssl;
	if a;
run;

proc sort data = forecl_reo;
by ward2002 premiseadd;
run;

ods html file="K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\REO_2011Q3.xls" style=minimal;

proc print data=Forecl_reo label noobs;
  var Premiseadd ward2002 post_sale_ownerr firstnotice_date outcome_date;
  label 
	Premiseadd = "Address"
	Zip = "ZIP"
	ward2002 = "2002 Ward"
	post_sale_ownerr = "Bank (Owner) Name"
	firstnotice_date = "Date of First Notice of Foreclosure"
	outcome_date = "Date of Outcome";
run;

ods html close;
ods listing;


