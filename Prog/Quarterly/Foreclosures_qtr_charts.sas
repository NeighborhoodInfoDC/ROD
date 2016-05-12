/**************************************************************************
 Program:  Foreclosures_qtr_charts.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L Hendey
 Created:  07/23/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create quarterly charts and maps for DC foreclosure data

 Modifications: 11/11/10 LH Changed UI_proptype to prev_sale_prp.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp)

%global val_suffix val_end val_rpt val_endyr;


%let val_suffix=2012_4;
%let val_end='31dec2012'd;
%let val_rpt='01oct2012'd;
%let val_endyr=2012; *end_dt is the end of the reference period - records with a start date after the end date are not included in tables;
%let val_endlag='31dec2011'd;
%let forecl_hist_file=foreclosures_history;


%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\foreclosures_rpt.sas";
%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\foreclosures_rpt_reo.sas";
%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\Forecl_qtr_cht.sas";
%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\foreclosures_qtr_outcomes.sas";
%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\foreclosures_dc_map_concentration.sas";
%include "K:\Metro\PTatian\DCData\Libraries\ROD\Prog\Quarterly\foreclosures_rpt_sales.sas";
