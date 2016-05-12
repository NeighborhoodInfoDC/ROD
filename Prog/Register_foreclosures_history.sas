/**************************************************************************
 Program:  Register_foreclosures_history.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/06/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Register the ROD.Foreclosures_history file with the
 metadata system.

 Modifications: 07/09/09 - LH Updated with Sales data through 3/31/09 and Foreclosures through 6/30/09.
 		03/25/10 - LH New episodes if >2 yr bt notices. Updated Sales through 1/12/10, Forecl through 12/31/09. 
		07/15/10 - LH Removed Sales with Bank as seller. Updated Sales through 4/21/10, Forecl through 03/31/10.
		11/04/10 - LH Recoded Lender Names. Updated Sales through 8/17/10, Forecl through 06/30/10.
		01/10/11 - LH Improvements to code. Updated Sales through 10/19/10, Forecl through 09/30/10.
		01/23/11 - LH Refinement of code, added sale type and document number.	
		02/04/11 - LH Counts unmatched Trustees Deeds as ownership change. Post_ vars are after episode now.
		03/03/11 - LH Updated Sales through 01/04/11, Forecl through 12/31/10.
		10/14/11 - LH Updates ui_proptype, sales through 6/01/11, Forecl through 03/31/11.
		11/15/11 - LH Updated Sales through 09/29/11, Forecl through 06/30/11.
		04/05/12 - LH Updated Sales through 12/28/11, Forecl through 09/30/11.	
		08/27/12 - LH Updated Sales through 05/12/12, Forecl through 03/31/12.
		11/21/12 - LH Updated Sales through 07/16/12, Forecl through 06/30/12. 
		04/25/13 - LH Updated Sales through 12/31/12, Forecl through 12/31/12. 
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
  ds_name=Foreclosures_history,
  creator_process=Foreclosures_history.sas,
  restrictions=None,
  revisions=%str(Updated Sales through 07/16/12, Forecl through 06/30/12.) 
)  

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
