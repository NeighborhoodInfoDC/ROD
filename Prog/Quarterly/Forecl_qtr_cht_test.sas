/**************************************************************************
 Program:  Forecl_qtr_cht.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create data for quarterly foreclosure chart
 (inventory, starts, sales, distressed sales, avoided).

 Modifications: 2/5/10 L Hendey Modified for ROD Quarterly and included end of qtr inventory
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )


%let suffix = 2009_3;


** Summarize data for chart **;

proc summary data=ROD.Foreclosures_qtr_&suffix._test nway;
  where ui_proptype in ( '10', '11' );
  class report_dt;
  var in_foreclosure_beg foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided in_foreclosure_end;
  output out=Chart (drop=_type_ _freq_) sum=;
run;

proc print data=Chart;
  id report_dt;
run;

data Csv_out (compress=no);

  length year_fmt $ 4;

  set Chart;
  
  if qtr( report_dt ) = 1 then year_fmt = put( year( report_dt ), 4. );
  else year_fmt = "";
  
  drop report_dt;
  
run;


filename fexport "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_qtr_&suffix._test.csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;


run;
