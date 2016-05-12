/**************************************************************************
 Program:  Foreclosures_2002.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2002.

 Modifications:06/30/08 L. Hendey Added Revision line
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize = Y,
  year = 2002,
  revisions = Updated File with Label.,
  files = 
    Foreclosures_2002_p1
    Foreclosures_2002_p2
    Foreclosures_2002_p3
    Foreclosures_2002_p4
    Foreclosures_2002_p5
    Foreclosures_2002_p6
    Foreclosures_2002_p7
    Foreclosures_2002_p8
    Foreclosures_2002_p9
    Foreclosures_2002_p10
    Foreclosures_2002_p11
    Foreclosures_2002_p12
)


signoff;
