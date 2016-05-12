/**************************************************************************
 Program:  Foreclosures_2000_2010.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/14/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a SAS View with all foreclosure notice files.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

data Rod.Foreclosures_2000_2010 / view=Rod.Foreclosures_2000_2010;

  set
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
  ;
 
run;

