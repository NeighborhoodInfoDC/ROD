/**************************************************************************
	 Program:  Foreclosures_2014.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   B. Losoya
	 Created:  01/27/14
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2014.

	 Modifications:
	   01/27/14 BJL Added verified thr. 01/15/13 and unverified thr. 01/27/13
	   6/30/2016 MC Added files from new ROD files from 1/1/2014 through 12/31/2014
		
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=N, 
	  revisions = %str(Added thr. 12/31/14)  ,
	  year = 2014,
	  files = 

	/** Verified data (include all YTD files) **/
	Foreclosures_2014_p1
    Foreclosures_2014_p2
    Foreclosures_2014_p3
    Foreclosures_2014_p4
    Foreclosures_2014_p5

    Foreclosures_2014_l1
    Foreclosures_2014_l2
    Foreclosures_2014_l3
    Foreclosures_2014_l4
    Foreclosures_2014_l5
    Foreclosures_2014_l6
    Foreclosures_2014_l7
    Foreclosures_2014_l8
    Foreclosures_2014_l9
    Foreclosures_2014_l10
    Foreclosures_2014_l11
    Foreclosures_2014_l12
    Foreclosures_2014_l13
    Foreclosures_2014_l14
    Foreclosures_2014_l15
    Foreclosures_2014_l16
    Foreclosures_2014_l17
    Foreclosures_2014_l18

	   


	/** New multiple lots **/
		

			/** MED DEVELOPERS, LLC;**/
	

	/** Unverified data (comment out all but the newest file) **/
		
		/*Foreclosures_2014_u1
		Foreclosures_2014_u2*/
	)

	run;


