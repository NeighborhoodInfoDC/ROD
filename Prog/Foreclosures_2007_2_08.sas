/**************************************************************************
 Program:  Foreclosures_2007_2_2008.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2007.

 Modifications:2/4/08 By CM & KP 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  year = 2007,
  files = 
    Foreclosures_2007_p1
    Foreclosures_2007_p2
    Foreclosures_2007_p3
    Foreclosures_2007_p4
    Foreclosures_2007_p5
    Foreclosures_2007_p6
    Foreclosures_2007_p7
    Foreclosures_2007_p8
    Foreclosures_2007_p9
    Foreclosures_2007_p10
)

rsubmit;

title2 "List multiple documents for a single property";

%Dup_check(
  data=Rod.Foreclosures_2007,
  by=ssl,
  id=FilingDate UI_Instrument,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)

run;

endrsubmit;

