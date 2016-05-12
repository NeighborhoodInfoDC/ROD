/**************************************************************************
 Program:  Foreclosures_1993.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 1993.

 Modifications: 2/4/08 by CM & KP; 6/30/08 LH
 		01/07/11 LH Added dup list macro.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 1993,
  revisions = Partial Update of SSLs previously unmatched.,
  files = 
    Foreclosures_1993_p1
    Foreclosures_1993_p2
    Foreclosures_1993_p3
    Foreclosures_1993_p4
    Foreclosures_1993_p5
    Foreclosures_1993_p6
    Foreclosures_1993_p7
    Foreclosures_1993_p8
    Foreclosures_1993_p9
    Foreclosures_1993_p10
    Foreclosures_1993_p11
   )


run;


