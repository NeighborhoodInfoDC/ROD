/**************************************************************************
 Program:  Foreclosures_2007.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2007.

 Modifications:
  03/05/08 PAT Added data through 12/31/07.
  06/30/08 L. Hendey Added Revision line and deleted dup check code. 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  year = 2007,
  revisions = Updated File with Label.,
  files = 
    Foreclosures_2007_p1
    Foreclosures_2007_p2
    Foreclosures_2007_p3
    Foreclosures_2007_p4
    Foreclosures_2007_p5
    Foreclosures_2007_p6
    Foreclosures_2007_p7
    Foreclosures_2007_p8
    Foreclosures_2007_p9
    Foreclosures_2007_p10
    Foreclosures_2007_p11
    Foreclosures_2007_p12
)

signoff;

