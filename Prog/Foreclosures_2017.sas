/**************************************************************************
 Program:  Foreclosures_2017.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   M. Cohen
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2017.

 Modifications:
  06/01/17 MAC  Added verified thr. 05/20/17.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= N,
  revisions = %str(Added verified thr. 05/20/17.),
  year = 2017,
  files = 
    /** Verified data (include all files) **/
 	   Foreclosures_2017_p1
	   Foreclosures_2017_p2
	   Foreclosures_2017_p3
	   Foreclosures_2017_p4
	   Foreclosures_2017_p5

	   Foreclosures_2017_l1
	   Foreclosures_2017_l2
	   Foreclosures_2017_l3
	   Foreclosures_2017_l4
	   Foreclosures_2017_l5
	   Foreclosures_2017_l6
	   Foreclosures_2017_l7
	   Foreclosures_2017_l8
	   Foreclosures_2017_l9
	   Foreclosures_2017_l10
	   Foreclosures_2017_l11
	   Foreclosures_2017_l12
	   Foreclosures_2017_l13
	   Foreclosures_2017_l14
	   Foreclosures_2017_l15
	   Foreclosures_2017_l16
	   Foreclosures_2017_l17

)


run;

