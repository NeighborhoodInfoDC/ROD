/**************************************************************************
 Program:  Download_formats.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download ROD format library from Alpha.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=ROD 
  outlib=ROD memtype=(catalog);
  select formats;

run;

endrsubmit;

** End submitting commands to remote server **;

proc catalog catalog=ROD.formats;
  contents;
quit;


run;

signoff;
