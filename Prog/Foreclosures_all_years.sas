/**************************************************************************
 Program:  Foreclosures_all_years.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/18/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a data view of all foreclosure record files.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Rod )

data Rod.Foreclosures_all_years / view=Rod.Foreclosures_all_years;

  set
    Rod.Foreclosures_1999
    Rod.Foreclosures_2000
    Rod.Foreclosures_2001
    Rod.Foreclosures_2002
    Rod.Foreclosures_2003
    Rod.Foreclosures_2004
    Rod.Foreclosures_2005
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009
    Rod.Foreclosures_2010
    Rod.Foreclosures_2011
    Rod.Foreclosures_2012
  ;
  
run;

%File_info( data=Rod.Foreclosures_all_years, freqvars=ward2012 )
