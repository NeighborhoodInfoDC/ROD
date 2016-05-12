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
	       08/03/09 A. Williams added re-downloaded trustee deed files
	       11/04/09	L. Hendey added file for doc no. 202064605 multiple lots
	       01/07/11 L. Hendey Added dup list macro.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize = Y,
  year = 2002,
  revisions = Corrected SSLs.,
  files = 
    Foreclosures_2002_p1
    /*Old trustee deed files
	Foreclosures_2002_p2
    Foreclosures_2002_p3*/
    Foreclosures_2002_p4
    Foreclosures_2002_p5
    Foreclosures_2002_p6
    Foreclosures_2002_p7
    Foreclosures_2002_p8
    Foreclosures_2002_p9
    Foreclosures_2002_p10
    Foreclosures_2002_p11
    Foreclosures_2002_p12

	/*New trustee deed files*/
	Foreclosures_2002_p13
	Foreclosures_2002_p14
	Foreclosures_2002_p15
	Doc2002064605

)


signoff;
