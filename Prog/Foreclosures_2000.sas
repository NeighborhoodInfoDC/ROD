/**************************************************************************
 Program:  Foreclosures_2000.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2000.

 Modifications: 2/4/08 by CM & KP; 6/30/08 LH 
	08/03/09 A. Williams added re-downloaded trustee deed files
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 2000,
  revisions = Corrected SSLs.,
  files = 
    Foreclosures_2000_p1
    Foreclosures_2000_p2
    Foreclosures_2000_p3
    Foreclosures_2000_p4
    Foreclosures_2000_p5
    Foreclosures_2000_p6
    Foreclosures_2000_p7
    Foreclosures_2000_p8
    Foreclosures_2000_p9
    Foreclosures_2000_p10
    Foreclosures_2000_p11
    /*New Trustee deed files*/
	Foreclosures_2000_p12
    Foreclosures_2000_p13
    Foreclosures_2000_p14
    Foreclosures_2000_p15
  )


run;



