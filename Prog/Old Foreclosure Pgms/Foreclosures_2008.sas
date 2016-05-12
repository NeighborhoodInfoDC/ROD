/**************************************************************************
 Program:  Foreclosures_2008.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2008.

 Modifications: 7/01/08 L Hendey
  09/24/08 PAT  Added data for June - August 2008.
  10/31/08 PAT  Added data for September 2008.
  11/24/08 PAT  Added verified thr. 11/17/08, unverified thr. 11/24/08.
  12/08/08 ANW  Added verified thr. 12/01/08, unverified thr. 12/08/08.
  12/15/08 ANW  Added verified thr. 12/08/08, unverified thr. 12/15/08.
  12/22/08 ANW  Added verified thr. 12/11/08, unverified thr. 12/22/08.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  revisions = %str(Added verified thr. 12/11/08, unverified thr. 12/22/08.),
  year = 2008,
  files = 
    /** Verified data (include all files) **/
    Foreclosures_2008_p1
    Foreclosures_2008_p2
    Foreclosures_2008_p3
    Foreclosures_2008_p4
    Foreclosures_2008_p5
    Foreclosures_2008_p6
    Foreclosures_2008_p7
    Foreclosures_2008_p8
    Foreclosures_2008_p9
    Foreclosures_2008_p10
    Foreclosures_2008_p11
    Foreclosures_2008_p12
    Foreclosures_2008_p13
    Foreclosures_2008_p14
    Foreclosures_2008_p15
    Foreclosures_2008_p16
    Foreclosures_2008_p17
    Foreclosures_2008_p18
    Foreclosures_2008_p19
    Foreclosures_2008_p20
    Foreclosures_2008_p21
    Foreclosures_2008_p22
    Foreclosures_2008_p23
    Foreclosures_2008_p24
	Foreclosures_2008_p25
	Foreclosures_2008_p26
    Foreclosures_2008_p27
	Foreclosures_2008_p28
	Foreclosures_2008_p29
	Foreclosures_2008_p30

    /** Unverified data (only include newest files) **/
    Foreclosures_2008_u5
   )


run;

