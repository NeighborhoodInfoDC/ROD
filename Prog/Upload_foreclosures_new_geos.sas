/**************************************************************************
 Program:  Upload_foreclosures_new_geos.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/01/12
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload and register the metadata for Foreclosures_*
 data sets with new 2010 and 2012 geographies added.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

/** Macro Run_all - Start Definition **/

%macro Run_all;

  %local year;

  %do year = 1990 %to 2012;

    %syslput year=&year;

    ** Start submitting commands to remote server **;

    rsubmit;

    proc upload status=no
      data=Rod.Foreclosures_&year._new 
      out=Rod.Foreclosures_&year;
    run;

    ** Register metadata **;

    %Dc_update_meta_file(
      ds_lib=Rod,
      ds_name=Foreclosures_&year,
      creator_process=Foreclosures_&year..sas,
      restrictions=None,
      revisions=
        %str(Update_geos_foreclosures.sas: Added Anc2012 Psa2012 Geo2010 GeoBlk2010 Ward2012 Parcel_geo_match. Dropped Casey_nbr2003 Casey_ta2003.)
    )

    run;

    endrsubmit;

    ** End submitting commands to remote server **;

  %end;

%mend Run_all;

/** End Macro Definition **/

%Run_all

run;

signoff;
