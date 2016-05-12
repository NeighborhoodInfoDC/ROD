/**************************************************************************
 Program:  Foreclosures_qtr.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create quarterly & yearly foreclosure data sets for 
 generating summary tables.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( HsngMon )
%DCData_lib( Rod )

/** Macro Foreclosures - Start Definition **/

%macro Foreclosures( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds;

    set Rod.Foreclosures_history;
    where ui_proptype in ( '10', '11', '12', '13' );
    
    ** Set episode dates **;
    
    if not( missing( firstnotice_date ) ) then start_dt = firstnotice_date;
    else if not( missing( outcome_date ) ) then start_dt = outcome_date - 365;
    
    if not( missing( outcome_date ) ) then end_dt = outcome_date;
    else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 365;
    else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 365;
    
    if missing( start_dt ) or missing( end_dt ) then delete;
    
    ** Align start and end dates with beginning of quarter **;
    
    adj_start_dt = intnx( "&unit", start_dt, 0, 'beginning' );
    adj_end_dt = intnx( "&unit", end_dt, 0, 'beginning' );
    
    ** Create obs. for each ssl/episode/qtr with outcome vars. **;
    
    length 
      in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale 
      distressed_sale foreclosure_avoided 3;
    
    report_dt = intnx( "&unit", max( adj_start_dt, &rpt_start_dt ), 0, 'beginning' );
    
    do while ( report_dt <= min( adj_end_dt, &rpt_end_dt ) );
    
      report_dt_end = intnx( "&unit", report_dt, 0, 'end' );
    
      if start_dt < report_dt and end_dt >= report_dt then in_foreclosure_beg = 1;
      else in_foreclosure_beg = 0;
      
      if start_dt < report_dt_end and end_dt >= report_dt_end then in_foreclosure_end = 1;
      else in_foreclosure_end = 0;
            
      if report_dt <= start_dt <= report_dt_end then foreclosure_start = 1;
      else foreclosure_start = 0;
      
      foreclosure_avoided = 0;
      foreclosure_sale = 0;
      distressed_sale = 0;
      
      if report_dt <= end_dt <= report_dt_end then do;
      
        select ( outcome_code );
          when ( 1, 4, 5, 6, .n )
            foreclosure_avoided = 1;
          when ( 2 ) 
            foreclosure_sale = 1;
          when ( 3 )
            distressed_sale = 1;
          otherwise do;
            %warn_put( msg="Unknown outcome code: " _n_= ssl= outcome_code= )
          end;
        end;
        
      end;
        
      output;
      
      report_dt = intnx( "&unit", report_dt, 1, 'beginning' );
                
    end;
    
    format report_dt start_dt end_dt adj_start_dt adj_end_dt mmddyy10.;
    
    label 
      report_dt = 'Report reference date'
      start_dt = 'Episode start date'
      end_dt = 'Episode end date'
      in_foreclosure_beg = 'In foreclosure (begining of reporting period)'
      in_foreclosure_end = 'In foreclosure (end of reporting period)'
      foreclosure_start = 'Foreclosure starts'
      foreclosure_sale = 'Foreclosure sales'
      distressed_sale = 'Distressed sales' 
      foreclosure_avoided = 'Foreclosures avoided'
    ;
    
    keep 
      ssl ui_proptype usecode city ward2002 cluster_tr2000 x_coord y_coord geo2000 prev_sale_owncat
      report_dt firstnotice_date start_dt end_dt adj_start_dt adj_end_dt 
      outcome_date outcome_code outcome_code2
      in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided;
    
  run;

  %File_info( data=&out_ds, printobs=5 )

  /*
  proc print data=&out_ds (obs=50);
    by ssl;
    id report_dt;
    var firstnotice_date outcome_date start_dt end_dt outcome_code 
        in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided;
  run;
  */

%mend Foreclosures;

/** End Macro Definition **/


%Foreclosures( out_ds=HsngMon.Foreclosures_qtr_2009_3, unit=qtr, rpt_end_dt='30jun2009'd )

%Foreclosures( out_ds=HsngMon.Foreclosures_year_2009_3, unit=year, rpt_end_dt='30jun2009'd )


