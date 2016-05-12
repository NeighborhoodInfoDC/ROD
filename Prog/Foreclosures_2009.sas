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
  08/03/09 A. Williams added re-downloaded trustee deed files
  08/10/09 KEF  Added verified thr. 07/29/09, unverified thr. 08/10/09.
  08/31/09 ANW  Added verified thr. 08/27/09, unverified thr. 08/31/09.
  09/09/09 ANW  Added verified thr. 08/10/09, unverified thr. 09/9/09.
  09/15/09 ANW  Added verified thr. 09/01/09, unverified thr. 09/15/09.
  09/18/09 LH	Added files to split notices for McLean Gardens Lots	
  09/28/09 ANW  Added verified thr. 09/22/09, unverified thr. 09/28/09.
  10/05/09 ANW  Added verified thr. 09/29/09, unverified thr. 10/05/09.
  10/12/09 ANW  Added verified thr. 10/05/09, unverified thr. 10/12/09.
  10/20/09 ANW  Added verified thr. 10/08/09, unverified thr. 10/20/09.
  10/26/09 ANW  Added verified thr. 10/16/09, unverified thr. 10/19/09.
  11/02/09 ANW  Added verified thr. 10/22/09, unverified thr. 11/02/09.
  11/09/09 ANW  Added verified thr. 10/30/09, unverified thr. 11/09/09.
  11/16/09 ANW  Added verified thr. 11/06/09, unverified thr. 11/16/09.
  11/20/09 LH	Added files to split notices for Watergate Lots
  11/23/09 ANW  Added verified thr. 11/16/09, unverified thr. 11/23/09.
  11/30/09 ANW  Added verified thr. 11/19/09, unverified thr. 11/30/09.
  12/07/09 ANW  Added verified thr. 11/25/09, unverified thr. 12/07/09.
  12/14/09 ANW  Added verified thr. 12/09/09, unverified thr. 12/14/09.
  12/21/09 ANW  Added verified thr. 12/16/09, unverified thr. 12/21/09.
  12/31/09 ANW  Added verified thr. 12/21/09, unverified thr. 12/31/09.
  01/04/10 ANW  Added verified thr. 12/24/09, unverified thr. 12/31/09.
  01/06/10 ANW  Added files to split notices for Doc2009138046.
  01/12/10 ANW  Added verified thr. 12/31/09, unverified thr. 12/31/09.
  06/02/10 LH   Corrected McLean Gardens and Watergate Foreclosures
  12/06/10 LH   added new multiple lot trustees deeds
  01/07/11 LH	Added Dup_list macro and corrected ssls.
  01/21/11 LH 	Updated Multiple Lots.
/**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%Dup_document_list;

%Read_foreclosures(
  finalize= Y,
  revisions = %str(Updated Multiple Lots.),
  year = 2009,
  files = 
   /** Verified data (include all files) **/
   Foreclosures_2009_p1
   Foreclosures_2009_p3
   Foreclosures_2009_p5
   Foreclosures_2009_p7
   Foreclosures_2009_p8
   Foreclosures_2009_p10
   Foreclosures_2009_p12
   Foreclosures_2009_p14
   Foreclosures_2009_p16
   Foreclosures_2009_p17
   Foreclosures_2009_p19
   Foreclosures_2009_p21
   Foreclosures_2009_p23
   Foreclosures_2009_p24
   Foreclosures_2009_p26
   Foreclosures_2009_p28
   Foreclosures_2009_p30
   Foreclosures_2009_p32
   Foreclosures_2009_p34
   Foreclosures_2009_p36
   Foreclosures_2009_p38
   Foreclosures_2009_p40
   Foreclosures_2009_p42
   Foreclosures_2009_p44
   Foreclosures_2009_p46
   Foreclosures_2009_p48
   Foreclosures_2009_p50
   Foreclosures_2009_p52
   Foreclosures_2009_p54
   Foreclosures_2009_p56
   Foreclosures_2009_p57
   Foreclosures_2009_p59
   Foreclosures_2009_p61
   Foreclosures_2009_p63
   Foreclosures_2009_p64
   Foreclosures_2009_p65
   Foreclosures_2009_p66
   Foreclosures_2009_p67
   Foreclosures_2009_p68
   Foreclosures_2009_p69
   Foreclosures_2009_p70
   Foreclosures_2009_p71
   Foreclosures_2009_p72
   Foreclosures_2009_p73
   Foreclosures_2009_p74
   Foreclosures_2009_p75
   Foreclosures_2009_p76
   Foreclosures_2009_p77
   Foreclosures_2009_p78
   Foreclosures_2009_p79
   Foreclosures_2009_p80
   Foreclosures_2009_p81
   Foreclosures_2009_p82
   Foreclosures_2009_p83
   Foreclosures_2009_p84
   Foreclosures_2009_p85
   Foreclosures_2009_p86
   Foreclosures_2009_p87
   Foreclosures_2009_p88
   Foreclosures_2009_p89
   Foreclosures_2009_p90
   Foreclosures_2009_p91
   Foreclosures_2009_p92
   Foreclosures_2009_p93
   Foreclosures_2009_p94
   Foreclosures_2009_p95
   Foreclosures_2009_p96
   Foreclosures_2009_p97
   Foreclosures_2009_p98
   Foreclosures_2009_p99
   Foreclosures_2009_p100
   Foreclosures_2009_p101
   Foreclosures_2009_p102
   Foreclosures_2009_p103
   Foreclosures_2009_p104
   Foreclosures_2009_p105
   Foreclosures_2009_p106
   Foreclosures_2009_p107
   Foreclosures_2009_p108
   Foreclosures_2009_p109
   Foreclosures_2009_p110
   Foreclosures_2009_p111
   Foreclosures_2009_p112
   Foreclosures_2009_p113
   Foreclosures_2009_p114



   Doc2009138046
   Doc2009051883_new
   Doc2009093097_new
   Docs2009064674_new
 	
/** Unverified data (only include newest files) **/
   
  /*New trustee deed files*/
	Foreclosures_2009_p33
	Foreclosures_2009_p35
	Foreclosures_2009_p37
	Foreclosures_2009_p65

	New_multp_TD_2009

   /*Old trustee deed files rewritten to fix error with trustee deeds
   Foreclosures_2009_p2
   Foreclosures_2009_p4
   Foreclosures_2009_p6
   Foreclosures_2009_p9
   Foreclosures_2009_p11
   Foreclosures_2009_p13
   Foreclosures_2009_p15
   Foreclosures_2009_p18
   Foreclosures_2009_p20
   Foreclosures_2009_p22
   Foreclosures_2009_p25
   Foreclosures_2009_p27
   Foreclosures_2009_p29 
   Foreclosures_2009_p31
   Foreclosures_2009_p33
   Foreclosures_2009_p35
   Foreclosures_2009_p37
   Foreclosures_2009_p39
   Foreclosures_2009_p41
   Foreclosures_2009_p43
   Foreclosures_2009_p45
   Foreclosures_2009_p47
   Foreclosures_2009_p49
   Foreclosures_2009_p51
   Foreclosures_2009_p53
   Foreclosures_2009_p55
   Foreclosures_2009_p58
   Foreclosures_2009_p60
   Foreclosures_2009_p62*/




)
run;
