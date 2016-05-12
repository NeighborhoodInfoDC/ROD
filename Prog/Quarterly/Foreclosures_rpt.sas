
filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt.log";
filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt.lst";
proc printto print=outnew log=lognew new;
run;


/**************************************************************************
 Program:  Foreclosures_qtr.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create quarterly & yearly foreclosure data sets for 
 generating summary tables.

 Modifications: 2/5/10 L Hendey - Adjusted for Quarterly ROD 
				4/14/10 L Hendey - Added variables to output including prev_sale_ownocc and reo.
				4/26/10 L Hendey - Added ANC to output
**************************************************************************/

%let forecl_file= &forecl_hist_file;
%let suffix=&val_suffix.;
%let end_dt=&val_end.;


/** Macro Foreclosures - Start Definition **/

%macro Foreclosures( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds;

    set Rod.&forecl_file.;
    where prev_sale_prp in ( '10', '11', '12', '13' );
    
	  length 
      in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale 
      distressed_sale foreclosure_avoided 3 new_proptype $2;

	  ** break out rental multifamily **;
	if prev_sale_prp = '13' then do;
   		 if usecode in ( '023', '024' ) then new_proptype = '14';
    	else new_proptype = '15';
	 end;
	  else new_proptype = prev_sale_prp;

    ** Set episode dates **;
    
    if not( missing( firstnotice_date ) ) then start_dt = firstnotice_date;
    else if not( missing( outcome_date ) ) then start_dt = outcome_date - 365;
    
	if lastnotice_date > '17nov09'd then do;

	    if not( missing( outcome_date ) ) then end_dt = outcome_date;
	    else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 730;
	    else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 730;

	end;

	else if lastnotice_date <= '17nov09'd then do;

	    if not( missing( outcome_date ) ) then end_dt = outcome_date;
	    else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 365;
	    else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 365;

	end;
    
    if missing( start_dt ) or missing( end_dt ) then delete;
    
    ** Align start and end dates with beginning of quarter **;
    
    adj_start_dt = intnx( "&unit", start_dt, 0, 'beginning' );
    adj_end_dt = intnx( "&unit", end_dt, 0, 'beginning' );
    
    ** Create obs. for each ssl/episode/qtr with outcome vars. **;
    
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
      reo = 0; 

      if report_dt <= end_dt <= report_dt_end then do;
      
        select ( outcome_code );
          when ( 1, 4, 5, 6, .n, 7, 8, 9 )
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

	 if report_dt <= end_dt <= report_dt_end then do;
      
        select ( post_sale_reo );
          when ( 1 )
            reo = 1;
		    otherwise do;
            reo = 0;
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
      distressed_sale = 'Distressed sales (after Default or Foreclosure)' 
      foreclosure_avoided = 'Foreclosures avoided'
	  reo = 'Real Estate Owned Property'
    ;
    
    keep 
      ssl usecode city ward2002 cluster_tr2000 x_coord y_coord geo2000 prev_sale_owncat post_sale_owncat
      report_dt firstnotice_date start_dt end_dt adj_start_dt adj_end_dt  new_proptype anc2002 prev_sale_prp
      outcome_date outcome_code outcome_code2 prev_sale_ownocc prev_sale_hstd num_notice zip reo
      in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided
	  firstdefault_date;
    
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


%Foreclosures( out_ds=ROD.Foreclosures_qtr_&suffix., unit=qtr, rpt_end_dt=&end_dt. )

*%Foreclosures( out_ds=ROD.Foreclosures_year_&suffix., unit=year, rpt_end_dt='31dec2009'd );
proc printto;
run;
