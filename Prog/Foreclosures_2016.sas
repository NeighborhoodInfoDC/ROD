/**************************************************************************
	 Program:  Foreclosures_2016.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   M. Cohen
	 Created:  6/24/2016
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2016.		
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=N, 
	  revisions = %str(Added thr. 06/10/16),
	  year = 2016,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2016_p1
	   Foreclosures_2016_p2
	   Foreclosures_2016_p3
	   Foreclosures_2016_p4
	   Foreclosures_2016_p5
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

	/** New multiple lots **/
		

			/** MED DEVELOPERS, LLC;**/

	)

options  mprint=y symbolgen=y;  
	run;


