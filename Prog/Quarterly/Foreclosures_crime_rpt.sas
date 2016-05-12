
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp)

%global val_suffix val_end val_rpt val_endyr;


%let val_suffix=2010_2;
%let val_end='30jun2010'd;
%let val_rpt='01apr2010'd;
%let val_endyr=2010; *end_dt is the end of the reference period - records with a start date after the end date are not included in tables;
%let val_endlag='30jun2009'd;


%let suffix=&val_suffix.;
%let end_date=&val_end.;

/*rsubmit;
proc download data=rod.foreclosures_history_sale out=rod.foreclosures_history_sale;
run;
endrsubmit;*/

proc format;
	value salecod
						           
1="Trustees Deed (matching sale) and REO"
2="Trustees Deed (matching sale) and Not REO"
3="Trustees Deed (no matching sale)"
4="Distressed Sale & REO"
5="Distressed Sale & not REO"
6="Market Sale (more than a year after last Fc notice)"
7="Market Sale - no previous fc episode"
8="REO Exit"
9="REO Transfer"
10="Buyer=Seller"
11="Other";

run;

proc contents data=rod.foreclosures_history_sale;
run;
/** Macro Foreclosures - Start Definition **/

%macro Foreclosures_crime( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds;

    set Rod.Foreclosures_history_sale;
    where post_sale_prp in ( '10', '11', '12', '13' );

	*not using or prev_sale_date as 1 option because only want inventory from foreclosures or using or next_sale_date as 3 option
		because do not have sale after that in foreclosure history file;
     
	if not( missing( post_sale_date ) ) then start_dt = post_sale_date; 
	else if post_sale_date in (.n .u) then start_date=filingdate_R;
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
      ssl prev_sale_prp city ward2002 zip geo2000 cluster_tr2000 x_coord y_coord usecode post_sale_owncat 
      report_dt firstnotice_date start_dt end_dt adj_start_dt adj_end_dt prev_sale_ownocc filingdate_r
      outcome_date outcome_code outcome_code2 tdeed_grantee record_type post_Sale_owner post_sale_price
	  prev_sale_price post_sale_prp
      in_reo_beg in_reo_end reo_start post_sale_date next_sale_date post_sale_reo sale_code prev_sale_reo
	  next_sale_date next_sale_owncat prev_sale_owner prev_sale_owncat next_Sale_owner next_sale_price
	 ;
    
  run;

  %File_info( data=&out_ds, printobs=5 )


  /*proc print data=&out_ds (obs=50);
    by ssl;
    id report_dt;
    var firstnotice_date outcome_date start_dt end_dt outcome_code2 
        in_reo_beg in_reo_end reo_start ;
  run;*/
 

%mend Foreclosures_crime;

%Foreclosures_crime( out_ds=rod.Foreclosures_qtr_crime_&suffix., unit=qtr, rpt_end_dt=&end_date. )

proc sort data=rod.foreclosures_qtr_crime_2010_2 out=foreclosures_qtr_crime_2010_2;
by ssl post_sale_date;
run;
proc sort data=realprop.parcel_base out=parcel_base;
by ssl;
data qtr_base;
merge foreclosures_qtr_crime_2010_2(in=a) parcel_base (keep= ssl ownerpt_extractdat_last ownerpt_extractdat_first);
by ssl;
if a;

run;

data rod.foreclosures_crime_2003_1;

  set qtr_base (where=(report_dt='01jan2003'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 data rod.foreclosures_crime_2004_1;
 
     set qtr_base (where=(report_dt='01jan2004'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 
 data rod.foreclosures_crime_2005_1;
 
   set qtr_base (where=(report_dt='01jan2005'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 
 data rod.foreclosures_crime_2006_1;
 
    set qtr_base (where=(report_dt='01jan2006'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 
 data rod.foreclosures_crime_2007_1;
 
   set qtr_base (where=(report_dt='01jan2007'd));
 by ssl;
 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 data rod.foreclosures_crime_2008_1;
 
    set qtr_base (where=(report_dt='01jan2008'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 
 
 data rod.foreclosures_crime_2009_1;
 
     set qtr_base (where=(report_dt='01jan2009'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 data rod.foreclosures_crime_2010_1;
 
    set qtr_base (where=(report_dt='01jan2010'd));
 by ssl;

 if last.ssl ne 1 then delete;
 if ownerpt_extractdat_last < report_dt then delete;
 if ownerpt_extractdat_first > report_dt then delete;
 run;
 

 proc contents data=rod.foreclosures_crime_2010_1;
 run;
