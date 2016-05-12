/**************************************************************************
 Program:  Forecl_yr_city.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L Hendey
 Created:  05/19/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create annual summary for city for Jenn's Kids & Foreclosures.

 Modifications: 
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( REALPROP )


*sf_condo total; 
proc summary data=ROD.Foreclosures_year_2009_4 nway;
  where ui_proptype in ( '10', '11' );
  class city report_dt;
  var in_foreclosure_beg foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided reo;
  output out=Chart (drop=_type_ _freq_) sum=;
run;

data Chart_units;

  merge 
    Chart 
    RealProp.Num_units_city (keep=city units_sf_condo_: );
  by city;
  
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
    otherwise units_sf_condo = units_sf_condo_2008;
  end;
  
  in_foreclosure_beg_rate = 1000 * in_foreclosure_beg / units_sf_condo;
  foreclosure_start_rate = 1000 * foreclosure_start / units_sf_condo;
  foreclosure_sale_rate = 1000 * foreclosure_sale / units_sf_condo;
  
  drop units_sf_condo_: ;
  
run;

proc print data=Chart_units;

run;

proc sort data=Chart_units;
  by report_dt city;

/** Macro Export - Start Definition **/

%macro Export( var=, prefix= );

  proc transpose data=Chart_units 
      out=Chart_units_tr (drop=_name_ compress=no) 
      prefix=&prefix;
    var &var;
    id city;
    by report_dt;
    format city $1. report_dt year4.;

  proc print;
    

  filename fexport "&_dcdata_path\ROD\Prog\&prefix..csv" lrecl=256;

  proc export data=Chart_units_tr
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

%mend Export;

/** End Macro Definition **/


%Export( var=foreclosure_start_rate , prefix=forecl_st_rate_city_yr_2009  )

%Export( var=foreclosure_start , prefix=forecl_st_city_yr_2009  )
