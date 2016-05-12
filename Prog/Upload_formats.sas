/**************************************************************************
 Program:  Upload_formats.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/13/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload formats to Alpha.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=ROD 
  outlib=ROD memtype=(catalog);
  select formats;
run;

proc catalog catalog=Rod.Formats;
  contents;
quit;

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
