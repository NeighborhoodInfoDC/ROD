/**************************************************************************
 Program:  Forecl_cluster_tbl.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/27/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Table of foreclosure indicators by ward/cluster.
 
 SPRING 2009

 Modifications: 03/25/10 LH Adjusted for ROD Directory
 				03/23/11 LH Added 2010. 
				08/11/14 LH Added 2011, 2012, 2013. Updated for SAS1. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

/** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=Realprop 
  outlib=Realprop memtype=(data);
  select Num_units_:;

run;

endrsubmit;

** End submitting commands to remote server 

run;
**/;

%Init_macro_vars_rod( rpt_yr=2011, rpt_qtr=4, sales_qtr_offset=-2 )

%let year = 2011;
%let rpt_end_dt='31dec2011'd;
%let suffix=2011_4;


%macro Foreclosures( out_ds=, unit=, rpt_start_dt='01jan1999'd, rpt_end_dt= );

  data &out_ds;

    set Rod_r.Foreclosures_history;
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
    
    if not( missing( outcome_date ) ) then end_dt = outcome_date;
    else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 365;
    else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 365;
    
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
      distressed_sale = 'Distressed sales' 
      foreclosure_avoided = 'Foreclosures avoided'
	  reo = 'Real Estate Owned Property'
    ;
    
    keep 
      ssl usecode city ward2002 ward2012  cluster_tr2000 x_coord y_coord geo2000 prev_sale_owncat post_sale_owncat
      report_dt firstnotice_date start_dt end_dt adj_start_dt adj_end_dt  new_proptype anc2002 prev_sale_prp
      outcome_date outcome_code outcome_code2 prev_sale_ownocc prev_sale_hstd num_notice zip reo
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

%Foreclosures( out_ds=ROD_l.Foreclosures_year_&suffix., unit=year, rpt_end_dt=&rpt_end_dt.);

/** Macro Geo - Start Definition **/

%macro Geo( geo=, geosuf= );

  proc summary data=ROD.Foreclosures_year_&suffix. nway;
    where prev_sale_prp in ( '10', '11' ) and year( report_dt ) = &year;
    class &geo report_dt;
    var in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided;
    output out=Chart (drop=_type_ _freq_) sum=;
  run;

  data &geo._tr;

    merge 
      Chart 
      RealPr_r.Num_units_&geosuf (keep=&geo units_sf_condo_: );
    by &geo;
    
    select ( year( report_dt ) );
      when ( 1999 ) units_sf_condo = units_sf_condo_1999;
      when ( 2000 ) units_sf_condo = units_sf_condo_2000;
      when ( 2001 ) units_sf_condo = units_sf_condo_2001;
      when ( 2002 ) units_sf_condo = units_sf_condo_2002;
      when ( 2003 ) units_sf_condo = units_sf_condo_2003;
      when ( 2004 ) units_sf_condo = units_sf_condo_2004;
      when ( 2005 ) units_sf_condo = units_sf_condo_2005;
      when ( 2006 ) units_sf_condo = units_sf_condo_2006;
      when ( 2007 ) units_sf_condo = units_sf_condo_2007;
      when ( 2008 ) units_sf_condo = units_sf_condo_2008; 
      when ( 2009 ) units_sf_condo = units_sf_condo_2009; 
      when ( 2010 ) units_sf_condo = units_sf_condo_2010;
	  when ( 2011 ) units_sf_condo = units_sf_condo_2011;
	  when ( 2012 ) units_sf_condo = units_sf_condo_2012;
	  when ( 2013 ) units_sf_condo = units_sf_condo_2013;
      otherwise units_sf_condo = units_sf_condo_2013;
    end;
    
    in_foreclosure_beg_rate = 1000 * in_foreclosure_beg / units_sf_condo;
    in_foreclosure_end_rate = 1000 * in_foreclosure_end / units_sf_condo;
    foreclosure_start_rate = 1000 * foreclosure_start / units_sf_condo;
    foreclosure_sale_rate = 1000 * foreclosure_sale / units_sf_condo;
    distressed_sale_rate = 1000 * distressed_sale / units_sf_condo;
    foreclosure_avoided_rate = 1000 * foreclosure_avoided / units_sf_condo;
        
    drop units_sf_condo_: ;
    
  run;

  proc print data=&geo._tr;
    id report_dt &geo;
    sum in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided;
    title2 "File = &geo._tr";
  run;

  title2;

%mend Geo;

/** End Macro Definition **/


%Geo( geo=ward2012, geosuf=wd12 )

%Geo( geo=cluster_tr2000, geosuf=cltr00 )

%Geo( geo=city, geosuf=city )


** Add wards to cluster file, resort **;

data cluster_tr2000_tr;

  set cluster_tr2000_tr;

  ** Cluster ward var **;
  
  length ward2012 $ 1;
  
  ward2012 = put( cluster_tr2000, $cl0wd2f. );
  
  label ward2012 = 'Ward (cluster-based)';
  
run;


** Merge transposed data together **;

data ROD_l.Forecl_cluster_tbl_&suffix.;

  set city_tr ward2012_tr cluster_tr2000_tr;
  
  ** Remove noncluster areas **;
  
  if cluster_tr2000 = '99' then delete;

run;

proc sort data=ROD.Forecl_cluster_tbl_&suffix.;
  by ward2012 cluster_tr2000;
run;

%File_info( data=ROD.Forecl_cluster_tbl_&suffix., printobs=0 )

proc print data=ROD.Forecl_cluster_tbl_&suffix.;
  id city ward2012 cluster_tr2000;
  title2 "File = Table";
run;
title2;


**** Write data to Excel table ****;

/** Macro Output_table4 - Start Definition **/

%macro Output_table( start_row=, end_row=, sheet= );

  filename xout dde  "excel|L:\Libraries\ROD\Prog\[DC Foreclosures Wd Cls &year..xls]&sheet!R&start_row.C1:R&end_row.C16" 
    lrecl=1000 notab;

  data _null_;

    file xout;
    
    set ROD.Forecl_cluster_tbl_&suffix.;
    by ward2012;
    
    cluster_num = input( cluster_tr2000, 2. );
    
    if ward2012 = '' then 
      put 'Washington, D.C. Total' '09'x '09'x '09'x '09'x @;
    else if Cluster_tr2000 = '' then 
      put ward2012 '09'x '09'x '09'x '09'x @;
    else
      put '09'x cluster_num '09'x '09'x Cluster_tr2000 $clus00s. '09'x @;
      
    put  
      in_foreclosure_beg '09'x 
      foreclosure_start '09'x 
      foreclosure_sale '09'x 
      distressed_sale '09'x 
      foreclosure_avoided '09'x
      in_foreclosure_end '09'x 
      
      in_foreclosure_beg_rate '09'x 
      foreclosure_start_rate '09'x 
      foreclosure_sale_rate '09'x 
      distressed_sale_rate '09'x 
      foreclosure_avoided_rate '09'x
      in_foreclosure_end_rate '09'x
    ;
      
    if last.ward2012 then put;
    
  run;

  filename xout clear;

%mend Output_table;

/** End Macro Definition **/

options missing='-';


** Write table **;

%Output_table( 
  sheet = Table X,
  start_row = 8, 
  end_row = 63
)

