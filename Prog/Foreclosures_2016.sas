/**************************************************************************
	 Program:  Foreclosures_2016.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   M. Cohen
	 Created:  6/24/2016
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2016.
	 Modifications: Added through 12/31/2016	
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=N, 
	  revisions = %str(Added thr. 12/31/16),
	  year = 2016,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2016_p1
	   Foreclosures_2016_p2
	   Foreclosures_2016_p3
	   Foreclosures_2016_p4
	   Foreclosures_2016_p5
	   Foreclosures_2016_p6
	   Foreclosures_2016_p7
	   Foreclosures_2016_p8
	   Foreclosures_2016_p9
	   Foreclosures_2016_p10
	   Foreclosures_2016_p11
	   Foreclosures_2016_p12
	   Foreclosures_2016_l1
	   Foreclosures_2016_l2
	   Foreclosures_2016_l3
	   Foreclosures_2016_l4
	   Foreclosures_2016_l5
	   Foreclosures_2016_l6
	   Foreclosures_2016_l7
	   Foreclosures_2016_l8
	   Foreclosures_2016_l9
	   Foreclosures_2016_l10
	   Foreclosures_2016_l11
	   Foreclosures_2016_l12
	   Foreclosures_2016_l13
	   Foreclosures_2016_l14
	   Foreclosures_2016_l15
	   Foreclosures_2016_l16
	   Foreclosures_2016_l17
	   Foreclosures_2016_l18
	   Foreclosures_2016_l19
	   Foreclosures_2016_l20
	   Foreclosures_2016_l21
	   Foreclosures_2016_l22
	   Foreclosures_2016_l23
	   Foreclosures_2016_l24
	   Foreclosures_2016_l25
	   Foreclosures_2016_l26
	   Foreclosures_2016_l27
	   Foreclosures_2016_l28
	   Foreclosures_2016_l29
	   Foreclosures_2016_l30
	   Foreclosures_2016_l31
	   Foreclosures_2016_l32
	   Foreclosures_2016_l33
	   Foreclosures_2016_l34
	   Foreclosures_2016_l35
	   Foreclosures_2016_l36
	/** New multiple lots **/
		

			/** MED DEVELOPERS, LLC;**/

	)

options  mprint=y symbolgen=y;  
	run;


