/**************************************************************************
	 Program:  Foreclosures_2012.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   R. Pitingolo
	 Created:  01/31/12
	 Version:  SAS 9.1
	 Environment:  Windows with SAS/Connect
	 
	 Description:  Read foreclosure data for 2012.

	 Modifications:
	   01/30/12 RMP Added verified thr. 01/18/12 and unverified thr. 01/30/12
	   02/06/12 RMP Added verified thr. 02/01/12 and unverified thr. 02/06/12
	   02/16/12 RMP Added verified thr. 02/10/12 and unverified thr. 02/16/12
	   02/21/12 RMP Added verified thr. 02/14/12 and unverified thr. 02/21/12
   	   02/28/12 RMP Added verified thr. 02/21/12 and unverified thr. 02/28/12
	   03/05/12 RMP Added verified thr. 02/24/12 and unverified thr. 03/05/12
	   03/13/12 RMP Added verified thr. 02/28/12 and unverified thr. 03/13/12
	   03/19/12 RMP Added verified thr. 03/08/12 and unverified thr. 03/19/12
	   03/27/12 RMP Added verified thr. 03/16/12 and unverified thr. 03/27/12
	   04/02/12 RMP Added verified thr. 03/21/12 and unverified thr. 04/02/12
	   04/09/12 RMP Added verified thr. 03/28/12 and unverified thr. 04/09/12
	   04/17/12 RMP Added verified thr. 04/03/12 and unverified thr. 04/17/12
	   04/23/12 RMP Added verified thr. 04/11/12 and unverified thr. 04/23/12
       04/30/12 RMP Added verified thr. 04/19/12 and unverified thr. 04/30/12
	   05/08/12 RMP Added verified thr. 05/03/12 and unverified thr. 05/08/12
	   05/14/12 RMP Added verified thr. 05/09/12 and unverified thr. 05/14/12
	   05/21/12 RMP Added verified thr. 05/16/12 and unverified thr. 05/21/12
	   05/29/12 RMP Added verified thr. 05/23/12 and unverified thr. 05/29/12
	   06/04/12 RMP Added verified thr. 05/28/12 and unverified thr. 06/04/12
       06/18/12 BJL Added verified thr. 06/11/12 and unverified thr. 06/18/12
	   06/25/12 BJL Added verified thr. 06/18/12 and unverified thr. 06/26/12
	   07/02/12 BJL Added verified thr. 06/25/12 and unverified thr. 07/02/12
	   07/09/12 BJL Added verified thr. 07/02/12 and unverified thr. 07/10/12
       07/16/12 BJL Added verified thr. 07/09/12 and unverified thr. 07/16/12
       07/24/12 BJL Added verified thr. 07/16/12 and unverified thr. 07/24/12
       08/03/12 BJL Added verified thr. 07/27/12 and unverified thr. 07/31/12
		08/03/12 BJL Added verified thr. 08/06/12 and unverified thr. 08/13/12
09/04/12 BJL Added verified thr. 08/27/12 and unverified thr. 09/04/12
09/17/12 BJL Added verified thr. 09/12/12 and unverified thr. 09/17/12
09/24/12 BJL Added verified thr. 09/20/12 and unverified thr. 09/24/12
10/02/12 BJL Added verified thr. 09/28/12 and unverified thr. 10/02/12
10/08/12 BJL Added verified thr. 10/02/12 and unverified thr. 10/08/12
10/16/12 BJL Added verified thr. 10/10/12 and unverified thr. 10/16/12
10/31/12 BJL Added verified thr. 10/24/12 and unverified thr. 10/31/12
10/31/12 BJL Added verified thr. 11/07/12 and unverified thr. 11/12/12
10/31/12 BJL Added verified thr. 11/09/12 and unverified thr. 11/19/12
10/31/12 BJL Added verified thr. 11/21/12 and unverified thr. 11/26/12
12/12/12 BJL Added verified thr. 12/05/12 and unverified thr. 12/12/12
1/6/12 BJL Added verified thr. 12/21/12 and unverified thr. 12/31/12
**************************************************************************/

	
	%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
	%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp )

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=Y, 
	  revisions = %str(Added verified thr. 12/21/12, unverified thr. 12/31/12)  ,
	  year = 2012,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2012_p1
	   Foreclosures_2012_p2
	   Foreclosures_2012_p3
	   Foreclosures_2012_p4
	   Foreclosures_2012_p5
	   Foreclosures_2012_p6
	   Foreclosures_2012_p7
	   Foreclosures_2012_p8
	   Foreclosures_2012_p9
	   Foreclosures_2012_p10
	   Foreclosures_2012_p11
	   Foreclosures_2012_p12
	   Foreclosures_2012_p13
	   Foreclosures_2012_p14
	   Foreclosures_2012_p15
	   Foreclosures_2012_p16
	   Foreclosures_2012_p17
	   Foreclosures_2012_p18
	   Foreclosures_2012_p19
	   Foreclosures_2012_p20
	   Foreclosures_2012_p21
	   Foreclosures_2012_p22
	   Foreclosures_2012_p23
	   Foreclosures_2012_p24
	   Foreclosures_2012_p25
	   Foreclosures_2012_p26
	   Foreclosures_2012_p27
	   Foreclosures_2012_p28
	   Foreclosures_2012_p29
	   Foreclosures_2012_p30
	   Foreclosures_2012_p31
	   Foreclosures_2012_p32
	   Foreclosures_2012_p33
	   Foreclosures_2012_p34
	   Foreclosures_2012_p35
	   Foreclosures_2012_p36
	   Foreclosures_2012_p37
	   Foreclosures_2012_p38
	   Foreclosures_2012_p39
	   Foreclosures_2012_p40
	   Foreclosures_2012_p41
	   Foreclosures_2012_p42
	   Foreclosures_2012_p45
	   Foreclosures_2012_p46
	   Foreclosures_2012_p47
	   Foreclosures_2012_p48
	   Foreclosures_2012_p49
	   Foreclosures_2012_p50
	   Foreclosures_2012_p51
	   Foreclosures_2012_p52
	   Foreclosures_2012_p53
	   Foreclosures_2012_p54
	   Foreclosures_2012_p55
	   Foreclosures_2012_p56
	   Foreclosures_2012_p57
	   Foreclosures_2012_p58
	   Foreclosures_2012_p59
	   Foreclosures_2012_p60
	   Foreclosures_2012_p61
	   Foreclosures_2012_p62
	   Foreclosures_2012_p63
	   Foreclosures_2012_p64
	   Foreclosures_2012_p65
	   Foreclosures_2012_p66
	   Foreclosures_2012_p67
	   Foreclosures_2012_p68
	   Foreclosures_2012_p69
	   Foreclosures_2012_p70
	   Foreclosures_2012_p71
	   Foreclosures_2012_p72
	   Foreclosures_2012_p73
	   Foreclosures_2012_p74
	   Foreclosures_2012_p75
	   Foreclosures_2012_p76
	   Foreclosures_2012_p77
	   Foreclosures_2012_p78
	   Foreclosures_2012_p79
	   Foreclosures_2012_p80
	   Foreclosures_2012_p81
	   Foreclosures_2012_p82
	   Foreclosures_2012_p83
	   Foreclosures_2012_p84
	   Foreclosures_2012_p85
	   Foreclosures_2012_p86


	

		/** 4345 HAWTHORNE ST NW;**/
		Doc2012073502
		
		/** unlisted;**/
		Doc2012134200




	/** Unverified data (comment out all but the newest file) **/
		/* Foreclosures_2012_u1 */
		/* Foreclosures_2012_u2 */
		/* Foreclosures_2012_u3 */
		/* Foreclosures_2012_u4 */
		/* Foreclosures_2012_u5 */
		/* Foreclosures_2012_u6 */
		/* Foreclosures_2012_u7 */
		/* Foreclosures_2012_u8 */
		/* Foreclosures_2012_u9 */
		/* Foreclosures_2012_u10 */
		/* Foreclosures_2012_u11 */
		/* Foreclosures_2012_u12 */
		/* Foreclosures_2012_u13 */
		/* Foreclosures_2012_u14 */
		/* Foreclosures_2012_u15 */
		/* Foreclosures_2012_u16 */
		/* Foreclosures_2012_u17 */
		/* Foreclosures_2012_u18 */
		/* Foreclosures_2012_u19 */
		/*Foreclosures_2012_u20 */
		/*Foreclosures_2012_u21 */
		/*Foreclosures_2012_u22*/
		/*Foreclosures_2012_u23*/
		/*Foreclosures_2012_u24*/
		/*Foreclosures_2012_u25*/
		/*Foreclosures_2012_u26*/
		/*Foreclosures_2012_u27*/
		/*Foreclosures_2012_u29*/
		/*Foreclosures_2012_u30*/
		/*Foreclosures_2012_u31*/
		/*Foreclosures_2012_u32*/
		/*Foreclosures_2012_u33*/
		/*Foreclosures_2012_u34*/
		/*Foreclosures_2012_u35*/
		/*Foreclosures_2012_u36*/
		/*Foreclosures_2012_u37*/
		/*Foreclosures_2012_u38*/
		/*Foreclosures_2012_u39*/
		/*Foreclosures_2012_u40*/
		/*Foreclosures_2012_u41*/
		Foreclosures_2012_u42
	)

	run;


signoff;
