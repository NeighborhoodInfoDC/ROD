/**************************************************************************
 Program:  Foreclosures_1997.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 1997.

 Modifications: 2/4/08 By CM & KP; 6/30/08 LH 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 1997,
  revisions = Correct SSLs.,
  files = 
    Foreclosures_1997_p1
    Foreclosures_1997_p2
    Foreclosures_1997_p3
    Foreclosures_1997_p4
    Foreclosures_1997_p5
    Foreclosures_1997_p6
    Foreclosures_1997_p7
    Foreclosures_1997_p8
    Foreclosures_1997_p9
    Foreclosures_1997_p10
    Foreclosures_1997_p11
    Foreclosures_1997_p12
    Foreclosures_1997_p13
    Foreclosures_1997_p14
    Foreclosures_1997_p15
   )


run;


