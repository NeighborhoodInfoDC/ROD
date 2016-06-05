/**************************************************************************
 Program:  Foreclosures_add_voterpre2012.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/30/14
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add voterpre2012 to Foreclosures_yyyy data sets.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( ROD )

/** Macro Process_all - Start Definition **/

%macro Process_all( );

  %local year label;
  
  %do year = 1990 %to 2014;
  
    %let label = Property foreclosure notices;

    data Foreclosures_&year (label="&label, &year, DC");

      set ROD.Foreclosures_&year;
      
      %Block10_to_vp12()

    run;

    proc datasets library=ROD memtype=(data);
      change Foreclosures_&year=xxx_Foreclosures_&year /memtype=data;
      copy in=work out=ROD memtype=data;
        select Foreclosures_&year;
    quit;

    %File_info( data=ROD.Foreclosures_&year, printobs=0, freqvars=voterpre2012 )
    
    %Dc_update_meta_file(
      ds_lib=ROD,
      ds_name=Foreclosures_&year,
      creator_process=Foreclosures_add_voterpre2012.sas,
      restrictions=None,
      revisions=%str(Added var voterpre2012 to data set.)
    )

  %end;

%mend Process_all;

/** End Macro Definition **/


%Process_all()

