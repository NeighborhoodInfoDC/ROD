/**************************************************************************
	 Program:  Foreclosures_2015.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   M. Cohen
	 Created:  6/24/2016
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2015.		
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=N, 
	  revisions = %str(Added thr. 12/31/15),
	  year = 2015,
	  files = 

	/** Verified data (include all YTD files) **/
	Foreclosures_2015_p1
    Foreclosures_2015_p2
    Foreclosures_2015_p3
    Foreclosures_2015_p4
    Foreclosures_2015_p5
    Foreclosures_2015_p6
    Foreclosures_2015_p7
    
    Foreclosures_2015_l1
    Foreclosures_2015_l2
    Foreclosures_2015_l3
    Foreclosures_2015_l4
    Foreclosures_2015_l5
    /*Foreclosures_2015_l6*/
    Foreclosures_2015_l7
    Foreclosures_2015_l8
    Foreclosures_2015_l9
    Foreclosures_2015_l10
    Foreclosures_2015_l11
    Foreclosures_2015_l12
    Foreclosures_2015_l13
    Foreclosures_2015_l14
    Foreclosures_2015_l15
    Foreclosures_2015_l16
    Foreclosures_2015_l17
    Foreclosures_2015_l18
    Foreclosures_2015_l19
    Foreclosures_2015_l20
    Foreclosures_2015_l21
    Foreclosures_2015_l22
    Foreclosures_2015_l23
    Foreclosures_2015_l24
    Foreclosures_2015_l25
    Foreclosures_2015_l26
    Foreclosures_2015_l27
    Foreclosures_2015_l28
    Foreclosures_2015_l29
    Foreclosures_2015_l30
    Foreclosures_2015_l31
    Foreclosures_2015_l32
    Foreclosures_2015_l33
    Foreclosures_2015_l34
    Foreclosures_2015_l35
	DOC2015079856
	DOC2015122913
	DOC2015061448
	/** New multiple lots **/
		

			/** MED DEVELOPERS, LLC;**/

	)

options  mprint=y symbolgen=y;  
	run;


