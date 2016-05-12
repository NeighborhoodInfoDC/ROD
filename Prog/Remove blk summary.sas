/**************************************************************************
 Program:  Remove Blk Summary.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  10/01/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a SAS View with all foreclosure notice files.

 Modifications: 
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;


** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )


rsubmit;
 x "delete [dcdata.rod.data]Foreclosures_sum_bl00.sas7bdat;30";

 proc datasets library=rod;
 run;
endrsubmit;


/** Macro DC_delete_meta_file - Start Definition **/

rsubmit;

%macro DC_delete_meta_file( 
         ds_lib= ,
         ds_name= ,
);

  %Delete_metadata_file(  
         ds_lib=&ds_lib,
         ds_name=&ds_name,
         meta_lib=metadat,
         meta_pre= meta,
         update_notify=
  )

  ** Purge extra copies of metadata files **;

  x "purge /keep=10 [&_dcdata_path..metadata.data]meta*.*";

%mend DC_delete_meta_file;

/** End Macro Definition **/

run;

endrsubmit;



** Delete files from metadata system **;

rsubmit;

%DC_delete_meta_file( ds_lib=rod , ds_name=foreclosures_sum_bl00 )

run;

endrsubmit;

signoff;
