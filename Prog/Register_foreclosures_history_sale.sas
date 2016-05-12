/**************************************************************************
 Program:  Register_foreclosures_history_sale.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/06/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Register the ROD.Foreclosures_history file with the
 metadata system.

 Modifications: 12/06/10 - LH New File. Updated Sales through 8/17/10, Forecl through 06/30/10.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

%Dc_update_meta_file(
  ds_lib=ROD,
  ds_name=Foreclosures_history_sale,
  creator_process=Foreclosures_history_sales.sas,
  restrictions=None,
  revisions=%str(New File. Sales through 8/17/10, Forecl through 06/30/10.)
) 

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;