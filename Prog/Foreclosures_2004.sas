/**************************************************************************
 Program:  Foreclosures_2004.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/16/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2004.

 Modifications: 06/30/08 L. Hendey Added Revision line
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
  year = 2004,
  revisions = Updated File with Label.,
  files = 
    Foreclosures_2004_p1 
    /*Old Trustee deed files
	Foreclosures_2004_p2*/
    Foreclosures_2004_p3
    Foreclosures_2004_p4
    Foreclosures_2004_p5
    Foreclosures_2004_p6
    Foreclosures_2004_p7
    Foreclosures_2004_p8

	/*New trustee deed files*/
	Foreclosures_2004_p9

)

