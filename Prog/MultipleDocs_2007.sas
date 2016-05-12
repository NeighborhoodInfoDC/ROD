/**************************************************************************
 Program:  MultipleDocs_2007.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

rsubmit;

title2 "List multiple documents for a single property";

%Dup_check(
  data=Rod.Foreclosures_2007,
  by=ssl,
  id=FilingDate DocumentNo Instrument Grantor,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)

run;

endrsubmit;

signoff;
