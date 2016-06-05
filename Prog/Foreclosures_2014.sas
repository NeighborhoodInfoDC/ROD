/**************************************************************************
	 Program:  Foreclosures_2014.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   B. Losoya
	 Created:  01/27/14
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2013.

	 Modifications:
	   01/27/14 BJL Added verified thr. 01/15/13 and unverified thr. 01/27/13
		
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=N, 
	  revisions = %str(Added verified thr. 01/27/14, unverified thr. 02/10/14)  ,
	  year = 2014,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2014_p1
	   Foreclosures_2014_p2
	   Foreclosures_2014_p3
	   Foreclosures_2014_p4
	   


	/** New multiple lots **/
		

			/** MED DEVELOPERS, LLC;**/
	

	/** Unverified data (comment out all but the newest file) **/
		
		/*Foreclosures_2014_u1*/
		Foreclosures_2014_u2
	)

	run;


