
 filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_map_concentration.log";
 filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_map_concentration.lst";
 proc printto print=outnew log=lognew new;
 run;
 /**************************************************************************
 Program:  Foreclosures_map_concentration.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L Hendey
 Created:  08/14/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create datasets to map foreclosure and reo inventory.

Modified: 04/13/10 for DC data.

**************************************************************************/



%let suffix=&val_suffix.;
%let rpt_dt=&val_rpt.; *report date is beginning of reference period (qtr);
%let end_yr=&val_endyr.;

proc sort data=rod.Foreclosures_qtr_&suffix. out=Foreclosures_qtr_&suffix.;
by report_dt;
proc sort data=rod.foreclosures_qtr_reo_&suffix. out=foreclosures_qtr_reo_&suffix.;
by report_dt;
data rod.foreclosures_map_&suffix.;
set Foreclosures_qtr_&suffix. (where=(report_dt=&rpt_dt.)) foreclosures_qtr_reo_&suffix. (where=(report_dt=&rpt_dt. and in_reo_beg=1)); 

fc_or_distress_sale=.;
if foreclosure_sale=1 or distressed_sale=1 then fc_or_distress_sale=1; 

rename prev_sale_prp=proptype;

run;
proc printto;
run;