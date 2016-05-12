/**************************************************************************
 Program:  Foreclosures_2005.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/16/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2005.

 Modifications: 06/30/08 L. Hendey  - Added Revision line. 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize=  Y,
  year = 2005,
  revisions = Updated File with Label.,
  files = 
    Foreclosures_2005_p1 
    Foreclosures_2005_p2
    Foreclosures_2005_p3
    Foreclosures_2005_p4
    Foreclosures_2005_p5
    Foreclosures_2005_p6
)

signoff;