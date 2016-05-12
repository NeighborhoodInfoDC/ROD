/**************************************************************************
 Program:  Foreclosures_yyyy.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for yyyy.

 Modifications:
  ??/??/yy ???  Added verified thr. ??/??/yy, unverified thr. ??/??/yy.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= N,
  revisions = %str(Added verified thr. ??/??/yy, unverified thr. ??/??/yy.),
  year = yyyy,
  files = 
    /** Verified data (include all files) **/
    Foreclosures_yyyy_p1

    /** Unverified data (only include newest files) **/
    Foreclosures_yyyy_u1

)


run;

