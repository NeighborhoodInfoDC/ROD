/**************************************************************************
 Program:  Foreclosures_add_bpk_cluster2017.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/19/18
 Version:  SAS 9.4
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add bridge park and cluster 0217 to Foreclosures_yyyy data sets.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( ROD )

%let revisions = Added bridge park and cluster 2017 geographies ;

/** Macro Process_all - Start Definition **/

%macro Process_all( );

  %local year label;
  
  %do year = 1990 %to 2014;
  
    %let label = Property foreclosure notices;

    data Foreclosures_&year (label="&label, &year, DC");

      set ROD.Foreclosures_&year;
      
      %Block10_to_bpk( );
	  %Block10_to_cluster17( );

    run;


 %Finalize_data_set(
    data=Foreclosures_&year,
    out=Foreclosures_&year,
    outlib=ROD,
    label="&label, &year, DC",
    sortby=FilingDate,
    /** Metadata parameters **/
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=5
  )

  %end;

%mend Process_all;

/** End Macro Definition **/


%Process_all()

