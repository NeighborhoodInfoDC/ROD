/**************************************************************************
 Program:  Foreclosures_2003.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2003.

 Modifications:06/30/08 L. Hendey Added Revision line
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  year = 2003,
  revisions = Updated File with Label.,
  files = 
    Foreclosures_2003_p1
    Foreclosures_2003_p2
    Foreclosures_2003_p3
    Foreclosures_2003_p4
    Foreclosures_2003_p5
    Foreclosures_2003_p6
    Foreclosures_2003_p7
    Foreclosures_2003_p8
    Foreclosures_2003_p9
    Foreclosures_2003_p10
)


signoff;
