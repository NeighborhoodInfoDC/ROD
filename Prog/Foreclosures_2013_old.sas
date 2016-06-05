/**************************************************************************
	 Program:  Foreclosures_2013.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   B. Losoya
	 Created:  01/14/13
	 Version:  SAS 9.1
	 Environment:  Local Windows session (desktop)
	 
	 Description:  Read foreclosure data for 2013.

	 Modifications:
	   01/14/13 BJL Added verified thr. 01/8/13 and unverified thr. 01/14/13
		02/12/13 BJL Added verified thr. 02/6/13 and unverified thr. 02/11/13
	   02/20/13 BJL Added verified thr. 02/15/13 and unverified thr. 02/20/13
       02/25/13 BJL Added verified thr. 02/21/13 and unverified thr. 02/25/13
03/11/13 BJL Added verified thr. 03/07/13 and unverified thr. 03/11/13
03/18/13 BJL Added verified thr. 03/11/13 and unverified thr. 03/18/13
03/12/13 BJL Added verified thr. 03/21/13 and unverified thr. 03/25/13
04/1/13 BJL Added verified thr. 03/28/13 and unverified thr. 04/1/13
04/8/13 BJL Added verified thr. 04/3/13 and unverified thr. 04/8/13
04/8/13 BJL Added verified thr. 04/10/13 and unverified thr. 04/15/13
05/6/13 BJL Added verified thr. 05/1/13 and unverified thr. 05/6/13
06/24/13 BJL Added verified thr. 06/18/13 and unverified thr. 06/24/13
07/1/13 BJL Added verified thr. 06/21/13 and unverified thr. 07/1/13
08/5/13 BJL Added verified thr. 07/26/13 and unverified thr. 08/05/13
08/19/13 BJL Added verified thr. 08/08/13 and unverified thr. 08/19/13
08/26/13 BJL Added verified thr. 08/15/13 and unverified thr. 08/26/13
09/03/13 BJL Added verified thr. 08/15/13 and unverified thr. 09/03/13
09/11/13 BJL Added verified thr. 09/02/13 and unverified thr. 09/11/13
09/16/13 BJL Added verified thr. 09/09/13 and unverified thr. 09/16/13
09/23/13 BJL Added verified thr. 09/17/13 and unverified thr. 09/23/13
11/04/13 BJL Added verified thr. 11/01/13, unverified thr. 11/04/13
11/11/13 BJL Added verified thr. 11/06/13, unverified thr. 11/11/13
11/18/13 BJL Added verified thr. 11/13/13, unverified thr. 11/18/13
11/26/13 BJL Added verified thr. 11/21/13, unverified thr. 11/26/13
12/3/13 BJL Added verified thr. 11/29/13, unverified thr. 12/3/13
1/27/14 BJL Added verified thr. 11/29/13, unverified thr. 12/3/13, updated programs for SAS server
**************************************************************************/

	
	%include "L:\SAS\Inc\StdLocal.sas"; 


	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp)

	%Dup_document_list;

	%Read_foreclosures(
	  finalize=Y, 
	  revisions = %str(Added verified thr. 12/31/13, unverified thr. 12/3/13)  ,
	  year = 2013,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2013_p1
	   Foreclosures_2013_p2
	   Foreclosures_2013_p3
	   Foreclosures_2013_p4
	   Foreclosures_2013_p5
	   Foreclosures_2013_p6
	   Foreclosures_2013_p9
	   Foreclosures_2013_p10
	   Foreclosures_2013_p11
	   Foreclosures_2013_p12
	   Foreclosures_2013_p13
	   Foreclosures_2013_p14
	   Foreclosures_2013_p15
	   Foreclosures_2013_p16
	   Foreclosures_2013_p17
	   Foreclosures_2013_p18
	   Foreclosures_2013_p19
	   Foreclosures_2013_p20
	   Foreclosures_2013_p21
	   Foreclosures_2013_p22
	   Foreclosures_2013_p23
	   Foreclosures_2013_p24
	   Foreclosures_2013_p25
	   Foreclosures_2013_p26
	   Foreclosures_2013_p27
	   Foreclosures_2013_p28
	   Foreclosures_2013_p29
	   Foreclosures_2013_p30
	   Foreclosures_2013_p31
	   Foreclosures_2013_p32
	   Foreclosures_2013_p33
	   Foreclosures_2013_p34
	   Foreclosures_2013_p35
	   Foreclosures_2013_p36
	   Foreclosures_2013_p39
	   Foreclosures_2013_p40
	   Foreclosures_2013_p41
	   Foreclosures_2013_p42
	   Foreclosures_2013_p43
	   Foreclosures_2013_p44
	   Foreclosures_2013_p45
	   Foreclosures_2013_p46
	   Foreclosures_2013_p47
	   Foreclosures_2013_p48
	   Foreclosures_2013_p49
	   Foreclosures_2013_p50
	   Foreclosures_2013_p51
	   Foreclosures_2013_p52
	   Foreclosures_2013_p53
	   Foreclosures_2013_p54
	   Foreclosures_2013_p55
	   Foreclosures_2013_p56
	   Foreclosures_2013_p57
	   Foreclosures_2013_p58
	   Foreclosures_2013_p59
	   Foreclosures_2013_p60
	   Foreclosures_2013_p61
	   Foreclosures_2013_p62
	   Foreclosures_2013_p63
	   Foreclosures_2013_p64


	/** New multiple lots **/
		/*New_multp_2011*/

			/** MED DEVELOPERS, LLC;**/
		Doc2013003281

	/** Unverified data (comment out all but the newest file) **/
		/* Foreclosures_2013_u1 */
		/* Foreclosures_2013_u2 */
		/* Foreclosures_2013_u3 */
		/*Foreclosures_2013_u4*/
		/*Foreclosures_2013_u5*/
		/*Foreclosures_2013_u6*/
		/*Foreclosures_2013_u7*/
		/*Foreclosures_2013_u8*/
		/*Foreclosures_2013_u9*/
		/*Foreclosures_2013_u10*/
		/*Foreclosures_2013_u11*/
		/*Foreclosures_2013_u12*/
		/*Foreclosures_2013_u13*/
		/*Foreclosures_2013_u14*/
		/*Foreclosures_2013_u15*/
		/*Foreclosures_2013_u16*/
		/*Foreclosures_2013_u17*/
		/*Foreclosures_2013_u18
		/*Foreclosures_2013_u19*/
		/*Foreclosures_2013_u20*/
		/*Foreclosures_2013_u21*/
		/*Foreclosures_2013_u22*/
		/*Foreclosures_2013_u23*/
		/*Foreclosures_2013_u24*/
		/*Foreclosures_2013_u25*/
		/*Foreclosures_2013_u26*/
		/*Foreclosures_2013_u27*/
		/*Foreclosures_2013_u28*/
		Foreclosures_2013_u29
	)

	run;


