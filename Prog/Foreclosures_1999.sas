/**************************************************************************
 Program:  Foreclosures_1999.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 1999.

 Modifications: 2/4/08 by CM & KP; 6/30/08 LH 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 1999,
  revisions = Corrected SSLs.,
  files = 
    Foreclosures_1999_p1
    Foreclosures_1999_p2
    Foreclosures_1999_p3
    Foreclosures_1999_p4
    Foreclosures_1999_p5
    Foreclosures_1999_p6
    Foreclosures_1999_p7
    Foreclosures_1999_p8
    Foreclosures_1999_p9
    Foreclosures_1999_p10
    Foreclosures_1999_p11
    Foreclosures_1999_p12
    Foreclosures_1999_p13
    Foreclosures_1999_p14
    Foreclosures_1999_p15
    Foreclosures_1999_p16
    Foreclosures_1999_p17
  )


run;



