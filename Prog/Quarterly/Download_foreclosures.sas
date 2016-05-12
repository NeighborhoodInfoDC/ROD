/**************************************************************************
 Program:  Download_foreclosures.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/24/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download foreclosure data sets.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )

** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=Rod 
  outlib=Rod memtype=(data);
  select Foreclosures_:;

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
