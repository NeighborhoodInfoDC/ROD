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
  08/03/09 A. Williams added re-downloaded trustee deed files
  01/07/11 L. Hendey Added dup list macro.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
options mprint symbolgen;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 2007,
  revisions = Corrected SSLs.,
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
    /*Trustee deed files*/
	Foreclosures_2007_p11
    Foreclosures_2007_p12

	/*New multp lot TD files*/
	New_multp_TD_2007
)

signoff;

