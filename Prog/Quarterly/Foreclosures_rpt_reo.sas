 filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt_reo.log";
 filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt_reo.lst";
 proc printto print=outnew log=lognew new;
 run;
 
 /**************************************************************************
 Program:  Foreclosures_rtp_reo.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/24/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create quarterly & yearly foreclosure data sets for 
 generating summary tables.

 Modifications: 05/07/09 L. Hendey For HNC - REO Data
**************************************************************************/


%let suffix=&val_suffix.;
%let end_date=&val_end.;
%let forecl_file= &forecl_hist_file;

/** Macro Foreclosures - Start Definition **/

%macro Foreclosures_reo( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds;

    set Rod.&forecl_file.;
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
      ssl prev_sale_prp city ward2002 zip geo2000 cluster_tr2000 x_coord y_coord usecode post_sale_owncat 
      report_dt firstnotice_date start_dt end_dt adj_start_dt adj_end_dt prev_sale_ownocc
      outcome_date outcome_code outcome_code2 lasttdeed_grantee record_type 
      in_reo_beg in_reo_end  reo_start post_sale_date next_sale_date post_sale_reo prev_sale_owner prev_sale_owncat
      prev_sale_price post_sale_price next_sale_price next_sale_owner next_sale_owncat
	 ;
    
  run;


  %File_info( data=&out_ds, printobs=5 )


  /*proc print data=&out_ds (obs=50);
    by ssl;
    id report_dt;
    var firstnotice_date outcome_date start_dt end_dt outcome_code2 
        in_reo_beg in_reo_end reo_start ;
  run;*/
 

%mend Foreclosures_reo;

/** End Macro Definition **/


%Foreclosures_reo( out_ds=rod.Foreclosures_qtr_reo_&suffix., unit=qtr, rpt_end_dt=&end_date. )
%Foreclosures_reo( out_ds=rod.Foreclosures_mon_reo_&suffix., unit=month, rpt_end_dt=&end_date.  )

%Foreclosures_reo( out_ds=rod.Foreclosures_year_reo_&suffix., unit=year, rpt_end_dt=&end_date.  )

*using end date as 01/01/09 to capture increase in reo in the end of 08 for yearly data;

proc printto;
run;
