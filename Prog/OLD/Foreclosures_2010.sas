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
	  04/13/10 ANW  Added verified thr. 03/25/10, unverified thr. 04/07/10.
	  04/19/10 ANW  Added verified thr. 04/02/10, unverified thr. 04/19/10.
	  04/26/10 ANW  Added verified thr. 04/14/10, unverified thr. 04/26/10.
	  05/04/10 ANW  Added verified thr. 04/23/10, unverified thr. 05/04/10.
	  05/10/10 ANW  Added verified thr. 04/29/10, unverified thr. 05/10/10.
	  05/17/10 ANW  Added verified thr. 05/04/10, unverified thr. 05/17/10.
	  05/24/10 ANW  Added verified thr. 05/10/10, unverified thr. 05/24/10.
      06/02/10 ANW  Added verified thr. 05/14/10, unverified thr. 06/02/10.
	  06/07/10 ANW  Added verified thr. 05/18/10, unverified thr. 06/07/10.
	  06/14/10 ANW  Added verified thr. 05/24/10, unverified thr. 06/14/10.
	  06/21/10 ANW  Added verified thr. 05/26/10, unverified thr. 06/21/10.
	  06/28/10 ANW  Added verified thr. 05/28/10, unverified thr. 06/28/10.
	  07/12/10 ANW  Added verified thr. 06/14/10, unverified thr. 07/12/10.
	  07/19/10 JCL  Added verified thr. 06/16/10, unverified thr. 07/19/10.
	  07/26/10 JCL  Added verified thr. 06/24/10, unverified thr. 07/26/10.
	  08/03/10 ANW  Added verified thr. 06/28/10, unverified thr. 08/03/10.
	  08/09/10 JCL  Added verified thr. 06/28/10, unverified thr. 08/09/10.
	  08/16/10 JCL  Added verified thr. 06/28/10, unverified thr. 08/16/10.
	  08/24/10 ANW  Added verified thr. 06/29/10, unverified thr. 08/24/10.
	  08/26/10 ANW  Added verified thr. 07/21/10, unverified thr. 08/26/10.
	  08/30/10 ANW  Added verified thr. 08/12/10, unverified thr. 08/30/10.
	  09/08/10 ANW  Added verified thr. 08/23/10, unverified thr. 09/08/10.
	  09/13/10 ANW  Added verified thr. 08/25/10, unverified thr. 09/13/10.
	  09/20/10 ANW  Added verified thr. 09/01/10, unverified thr. 09/20/10.
	  09/28/10 ANW  Added verified thr. 09/10/10, unverified thr. 09/27/10.
	  10/05/10 ANW  Added verified thr. 09/22/10, unverified thr. 10/05/10.
	  10/12/10 ANW  Added verified thr. 09/28/10, unverified thr. 10/12/10.
	  10/18/10 ANW  Added verified thr. 10/01/10, unverified thr. 10/18/10.
	  11/05/10 ANW  Added verified thr. 10/19/10, unverified thr. 11/05/10.
	  11/12/10 ANW  Added verified thr. 10/19/10, unverified thr. 11/12/10.
	  11/15/10 ANW  Added verified thr. 10/20/10, unverified thr. 11/15/10.
		
	**************************************************************************/

	%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
	%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp )


	%Read_foreclosures(
	  finalize= Y,
	  revisions = %str(Added verified thr. 10/20/10, unverified thr. 11/15/10) ,
	  year = 2010,
	  files = 
	   /** Verified data (include all files) **/
	   Foreclosures_2010_p1
	   Foreclosures_2010_p2
	   
	   Foreclosures_2010_p4

	   Foreclosures_2010_p6
	   Foreclosures_2010_p7
	   Foreclosures_2010_p9
	   
	   Foreclosures_2010_p11
	   Foreclosures_2010_p13
	   Foreclosures_2010_p15
	   Foreclosures_2010_p17
	   Foreclosures_2010_p19
	   Foreclosures_2010_p21
	   Foreclosures_2010_p23
	   Foreclosures_2010_p25
	   Foreclosures_2010_p27
	   Foreclosures_2010_p28
	   Foreclosures_2010_p30
	   Foreclosures_2010_p32
	   Foreclosures_2010_p33
	   Foreclosures_2010_p35
	   Foreclosures_2010_p37
	   Foreclosures_2010_p39
	   Foreclosures_2010_p41
	   Foreclosures_2010_p43
	   Foreclosures_2010_p45
	   Foreclosures_2010_p47
	   Foreclosures_2010_p49
	   Foreclosures_2010_p51
	   Foreclosures_2010_p52
	   Foreclosures_2010_p54
	   Foreclosures_2010_p56
	   Foreclosures_2010_p58
	   Foreclosures_2010_p60
	   Foreclosures_2010_p62
	   Foreclosures_2010_p64
	   Foreclosures_2010_p66
	   Foreclosures_2010_p67
	   Foreclosures_2010_p69
	   Foreclosures_2010_p70
	   Foreclosures_2010_p72
	   Foreclosures_2010_p73
	   Foreclosures_2010_p75
	   Foreclosures_2010_p77
	   Foreclosures_2010_p78
	   Foreclosures_2010_p79
	   Foreclosures_2010_p80
	   Foreclosures_2010_p82
	   Foreclosures_2010_p83
	   Foreclosures_2010_p85
	   Foreclosures_2010_p87
	   Foreclosures_2010_p89
	   Foreclosures_2010_p90
	   Foreclosures_2010_p91
	   Foreclosures_2010_p92
	   Foreclosures_2010_p93
	   Foreclosures_2010_p94
	   Foreclosures_2010_p95
	   Foreclosures_2010_p96
	   Foreclosures_2010_p97


		Doc2010045065 /*Senate square foreclosure notice 5/17/2010*/
		Doc2010050396 /*Senate square foreclosure notice 6/1/2010*/
		Doc2010005170 /*Senate square foreclosure notice 1/19/2010*/
		Doc2010044542 /*Senate square foreclosure notice 5/14/2010*/
		Doc2010030334
		Doc2010051022
		Doc2010061280 /*Senate square trustees deed*/

	/** Unverified data (only include newest files) **/
	    Foreclosures_2010_u44

		/*New trustee deed files*/
		New_Trustees_1
		New_Trustees_2
		New_Trustees_3
		New_Trustees_4
	
		   /*Old trustee deed files rewritten to fix error with trustee deeds
					Foreclosures_2010_p3
					Foreclosures_2010_p5
					Foreclosures_2010_p8
					Foreclosures_2010_p10
					Foreclosures_2010_p12
					Foreclosures_2010_p14
					Foreclosures_2010_p16
					Foreclosures_2010_p18
					Foreclosures_2010_p20
					Foreclosures_2010_p22
					Foreclosures_2010_p24
					Foreclosures_2010_p26
					Foreclosures_2010_p29
					Foreclosures_2010_p31
					Foreclosures_2010_p34
					Foreclosures_2010_p36
					Foreclosures_2010_p38
					Foreclosures_2010_p40
					Foreclosures_2010_p42
					Foreclosures_2010_p44
					Foreclosures_2010_p46
					Foreclosures_2010_p48
					Foreclosures_2010_p50
					Foreclosures_2010_p53
					Foreclosures_2010_p55
					Foreclosures_2010_p57
					Foreclosures_2010_p59
					Foreclosures_2010_p61
					Foreclosures_2010_p63
					Foreclosures_2010_p65
					Foreclosures_2010_p68
					Foreclosures_2010_p71
					Foreclosures_2010_p74
					Foreclosures_2010_p76
					Foreclosures_2010_p81
					Foreclosures_2010_p84
					Foreclosures_2010_p86
					Foreclosures_2010_p88
*/
	)
	run;
signoff;
