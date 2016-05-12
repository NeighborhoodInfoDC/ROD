/**************************************************************************
 Program:  Foreclosures_2009.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  01/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read foreclosure data for 2009.

 Modifications:
  01/13/09 ANW  Added verified thr. 01/06/09, unverified thr. 01/13/09.
  01/26/09 ANW  Added verified thr. 01/13/09, unverified thr. 01/26/09.
  02/02/09 ANW  Added verified thr. 01/14/09, unverified thr. 02/02/09.
  02/09/09 ANW  Added verified thr. 01/30/09, unverified thr. 02/09/09.
  02/16/09 ANW  Added verified thr. 02/05/09, unverified thr. 02/16/09.
  02/23/09 ANW  Added verified thr. 02/05/09, unverified thr. 02/23/09.
  03/02/09 ANW  Added verified thr. 02/08/09, unverified thr. 03/02/09.
  03/09/09 ANW  Added verified thr. 03/02/09, unverified thr. 03/09/09.
  03/16/09 ANW  Added verified thr. 03/05/09, unverified thr. 03/16/09.
  03/23/09 ANW  Added verified thr. 03/11/09, unverified thr. 03/23/09.
  03/30/09 ANW  Added verified thr. 03/24/09, unverified thr. 03/30/09.
  04/06/09 ANW  Added verified thr. 03/30/09, unverified thr. 04/06/09.
  04/13/09 ANW  Added verified thr. 03/31/09, unverified thr. 04/13/09.
  04/20/09 ANW  Added verified thr. 04/09/09, unverified thr. 04/20/09.
  04/27/09 ANW  Added verified thr. 04/15/09, unverified thr. 04/27/09.
  05/04/09 ANW  Added verified thr. 04/27/09, unverified thr. 05/04/09.
  05/11/09 ANW  Added verified thr. 04/30/09, unverified thr. 05/11/09.
  05/18/09 ANW  Added verified thr. 05/07/09, unverified thr. 05/18/09.
  05/26/09 ANW  Added verified thr. 05/13/09, unverified thr. 05/26/09.
  06/01/09 ANW  Added verified thr. 05/18/09, unverified thr. 06/01/09.
  06/08/09 ANW  Added verified thr. 05/27/09, unverified thr. 06/08/09.
  06/15/09 ANW  Added verified thr. 06/02/09, unverified thr. 06/15/09.
  06/23/09 ANW  Added verified thr. 06/15/09, unverified thr. 06/23/09.
  06/29/09 ANW  Added verified thr. 06/22/09, unverified thr. 06/29/09.
  07/06/09 ANW  Added verified thr. 06/24/09, unverified thr. 07/06/09.
  07/13/09 ANW  Added verified thr. 06/30/09, unverified thr. 07/13/09.
  07/23/09 ANW  Added verified thr. 07/14/09, unverified thr. 07/22/09.
  07/27/09 ANW  Added verified thr. 07/16/09, unverified thr. 07/27/09.
  08/03/09 ANW  Added verified thr. 07/16/09, unverified thr. 08/03/09.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )


%Read_foreclosures(
  finalize= Y,
  revisions = %str(Added verified thr. 07/16/09, unverified thr. 08/03/09.),
  year = 2009,
  files = 
   /** Verified data (include all files) **/
   Foreclosures_2009_p1
   Foreclosures_2009_p2
   Foreclosures_2009_p3
   Foreclosures_2009_p4
   Foreclosures_2009_p5
   Foreclosures_2009_p6
   Foreclosures_2009_p7
   Foreclosures_2009_p8
   Foreclosures_2009_p9
   Foreclosures_2009_p10
   Foreclosures_2009_p11
   Foreclosures_2009_p12
   Foreclosures_2009_p13
   Foreclosures_2009_p14
   Foreclosures_2009_p15
   Foreclosures_2009_p16
   Foreclosures_2009_p17
   Foreclosures_2009_p18
   Foreclosures_2009_p19
   Foreclosures_2009_p20
   Foreclosures_2009_p21
   Foreclosures_2009_p22
   Foreclosures_2009_p23
   Foreclosures_2009_p24
   Foreclosures_2009_p25
   Foreclosures_2009_p26
   Foreclosures_2009_p27
   Foreclosures_2009_p28
   Foreclosures_2009_p29
   Foreclosures_2009_p30
   Foreclosures_2009_p31
   Foreclosures_2009_p32
   Foreclosures_2009_p33
   Foreclosures_2009_p34
   Foreclosures_2009_p35
   Foreclosures_2009_p36
   Foreclosures_2009_p37
   Foreclosures_2009_p38
   Foreclosures_2009_p39
   Foreclosures_2009_p40
   Foreclosures_2009_p41
   Foreclosures_2009_p42
   Foreclosures_2009_p43
   Foreclosures_2009_p44
   Foreclosures_2009_p45
   Foreclosures_2009_p46
   Foreclosures_2009_p47
   Foreclosures_2009_p48
   Foreclosures_2009_p49
   Foreclosures_2009_p50
   Foreclosures_2009_p51
   Foreclosures_2009_p52
   Foreclosures_2009_p53
   Foreclosures_2009_p54
   Foreclosures_2009_p55
   Foreclosures_2009_p56
   Foreclosures_2009_p57
   Foreclosures_2009_p58
   Foreclosures_2009_p59
   Foreclosures_2009_p60
   Foreclosures_2009_p61
   Foreclosures_2009_p62


   /** Unverified data (only include newest files) **/
   Foreclosures_2009_u29
)
run;
