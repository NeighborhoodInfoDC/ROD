/**************************************************************************
 Program:  Foreclosures_2006.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2006.

 Modifications:
 06/30/08 L. Hendey Added Revision line and deleted dup check code. 
 08/03/09 A. Williams added re-downloaded trustee deed files
 12/03/10 A. Williams Corrected SSLs.
 12/22/10 L. Hendey   Corrected a missing SSL.
 01/07/11 L. Hendey   Added dup list macro.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  year = 2006,
  revisions = Corrected a missing SSL.,
  files = 
    Foreclosures_2006_p1
    Foreclosures_2006_p2
    Foreclosures_2006_p3
    Foreclosures_2006_p4
    Foreclosures_2006_p5
    Foreclosures_2006_p6
    /*New trustee deed file*/
	Foreclosures_2006_p7
)
