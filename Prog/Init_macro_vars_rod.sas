/**************************************************************************
 Program:  Init_macro_vars_rod.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/07/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Initialize macro variables for standard 
 Housing Monitor tables and figures.

 Modifications:
  10/04/07 PAT Added g_sales_start_yr and g_sales_mid_yr.
  11/23/07 PAT Added g_s8_rpt_dt, g_s8_rpt_dt_fmt, g_s8_data, 
               g_s8_rpt_file, g_s8_rpt_xls, g_s8_map_file, 
               G_S8_PRES_RPT_LAG_DAYS.
  04/20/09 PAT Added sales_qtr_offset= parameter.
  04/23/09 PAT Corrected g_sales_start_dt (moved back 1 qtr)
  03/25/10 LH  Modified for ROD
**************************************************************************/

/** Macro Init_macro_vars - Start Definition **/

%macro Init_macro_vars_rod( rpt_yr=, rpt_qtr=, sales_start_dt=, sales_end_dt=, sales_qtr_offset=-3 );

  %global g_rpt_yr g_rpt_qtr g_sales_start_dt g_sales_start_yr g_sales_end_dt g_sales_end_yr 
          g_sales_mid_yr g_path g_table_wbk g_fig_wbk g_rpt_title g_s8_rpt_dt g_s8_rpt_dt_fmt
          g_s8_data g_s8_rpt_file g_s8_rpt_xls g_s8_map_file 
          G_S8_PRES_RPT_LAG_DAYS G_S8_PRES_START_DATE;
          
  %fdate()
  
  %let g_rpt_yr = &rpt_yr;
  %let g_rpt_qtr = &rpt_qtr;
  
  %let S8_RPT_QTR_START_OFFSET = 0;
  
  %if &sales_start_dt ~= %then %do;
    %let g_sales_start_dt = &sales_start_dt;
    %let g_sales_end_dt = &sales_end_dt;
  %end;
  %else %do;
    data _null_;
      date = intnx( 'qtr', input( "&rpt_yr.Q&rpt_qtr", yyq6. ), 1, 'beginning' );
      *g_sales_start_dt = intnx( 'qtr', date, %eval( (&sales_qtr_offset) - 41 ), 'beginning' );
      g_sales_end_dt = intnx( 'qtr', date, %eval( (&sales_qtr_offset) - 1 ), 'end' );
      g_sales_start_dt = intnx( 'year', g_sales_end_dt, -10, 'beginning' );
      g_sales_start_yr = year( g_sales_start_dt );
      g_sales_end_yr = year( g_sales_end_dt );
      g_sales_mid_yr = g_sales_start_yr + int( ( g_sales_end_yr - g_sales_start_yr ) / 2 );
      call symput( 'g_sales_start_dt', g_sales_start_dt );
      call symput( 'g_sales_end_dt', g_sales_end_dt );
      call symput( 'g_sales_start_yr', trim( left( g_sales_start_yr ) ) );
      call symput( 'g_sales_mid_yr', trim( left( g_sales_mid_yr ) ) );
      call symput( 'g_sales_end_yr', trim( left( g_sales_end_yr ) ) );
    run;
  %end;  
  
  %let g_path = &_dcdata_path\ROD\Prog;
  
  %if &rpt_qtr = 1 %then %let g_rpt_title = Winter &rpt_yr;
  %else %if &rpt_qtr = 2 %then %let g_rpt_title = Spring &rpt_yr;
  %else %if &rpt_qtr = 3 %then %let g_rpt_title = Summer &rpt_yr;
  %else %if &rpt_qtr = 4 %then %let g_rpt_title = Fall &rpt_yr;

  %let g_table_wbk = DC Foreclosures &g_rpt_title tables.xls;
  %let g_fig_wbk = DC Foreclosures &g_rpt_title figures.xls;
  
  %let g_sales_start_dt_fmt = %sysfunc( putn( &g_sales_start_dt, mmddyy10. ) ); 
  %let g_sales_end_dt_fmt = %sysfunc( putn( &g_sales_end_dt, mmddyy10. ) ); 
  
  %** Section 8 report reference date **;

  data _null_;
    date = intnx( 'qtr', input( "&rpt_yr.Q&rpt_qtr", yyq6. ), &S8_RPT_QTR_START_OFFSET, 'beginning' );
    call symput( 'g_s8_rpt_dt', date );
  run;
  
  %let g_s8_rpt_dt_fmt = %sysfunc( putn( &g_s8_rpt_dt, /*mmddyy10.*/ worddate12. ) ); 
  
  %let g_s8_data = Hud.Sec8mf_current_dc;
  %let g_s8_rpt_file = S8summary_&g_rpt_yr._&g_rpt_qtr;
  %let g_s8_rpt_xls = &g_s8_rpt_file..xls;
  %let g_s8_map_file = &g_s8_rpt_file;
  
  %let g_s8_pres_rpt_lag_days = 180;
  %let g_s8_pres_start_date = '01jan2000'd;

  %put _local_;
  %put _global_;
  
  %put 
    g_rpt_yr=&g_rpt_yr 
    g_rpt_qtr=&g_rpt_qtr 
    g_sales_start_dt=&g_sales_start_dt_fmt 
    g_sales_end_dt=&g_sales_end_dt_fmt
    g_path=&g_path 
    g_table_wbk=&g_table_wbk 
    g_fig_wbk=&g_fig_wbk 
    g_rpt_title=&g_rpt_title
    g_s8_rpt_dt_fmt=&g_s8_rpt_dt_fmt
  ;

%mend Init_macro_vars;

/** End Macro Definition **/

