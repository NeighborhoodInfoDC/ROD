/**************************************************************************
 Program:  Foreclosures_2010.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  01/04/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2010.

 Modifications:
  01/12/10 ANW  Added verified thr. 01/04/10, unverified thr. 01/12/10.
  01/20/10 ANW  Added verified thr. 01/13/10, unverified thr. 01/20/10.
  01/28/10 ANW  Added verified thr. 01/13/10, unverified thr. 01/28/10.
  02/01/10 ANW  Added verified thr. 01/27/10, unverified thr. 02/01/10.
  02/08/10 ANW  Added verified thr. 02/02/10, unverified thr. 02/05/10.
  02/16/10 ANW  Added verified thr. 02/05/10, unverified thr. 02/16/10.
  02/24/10 ANW  Added verified thr. 02/18/10, unverified thr. 02/24/10.
  03/01/10 ANW  Added verified thr. 02/24/10, unverified thr. 03/01/10.
  03/08/10 ANW  Added verified thr. 03/03/10, unverified thr. 03/08/10.
  03/15/10 ANW  Added verified thr. 03/10/10, unverified thr. 03/12/10.
  03/24/10 ANW  Added verified thr. 03/17/10, unverified thr. 03/24/10.
  
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  revisions = %str(Added COOP_units to file),
  year = 2010,
  files = 
   /** Verified data (include all files) **/
   Foreclosures_2010_p1
   Foreclosures_2010_p2
   Foreclosures_2010_p3
   Foreclosures_2010_p4
   Foreclosures_2010_p5
   Foreclosures_2010_p6
   Foreclosures_2010_p7
   Foreclosures_2010_p8
   Foreclosures_2010_p9
   Foreclosures_2010_p10
   Foreclosures_2010_p11
   Foreclosures_2010_p12
   Foreclosures_2010_p13
   Foreclosures_2010_p14
   Foreclosures_2010_p15
   Foreclosures_2010_p16
   Foreclosures_2010_p17
   Foreclosures_2010_p18
   Foreclosures_2010_p19
   Foreclosures_2010_p20
   Foreclosures_2010_p21
   Foreclosures_2010_p22
   Foreclosures_2010_p23
   Foreclosures_2010_p24


/** Unverified data (only include newest files) **/
    Foreclosures_2010_u12

)
