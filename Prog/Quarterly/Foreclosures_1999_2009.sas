/**************************************************************************
 Program:  Foreclosures_1999_2009.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/25/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a SAS View with all foreclosure notice files.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( HsngMon )
%DCData_lib( ROD )

data HsngMon.Foreclosures_1999_2009 / view=HsngMon.Foreclosures_1999_2009;

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
  ;
 
run;

