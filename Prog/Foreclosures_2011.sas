	/**************************************************************************
	 Program:  Foreclosures_2011.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   R. Grace
	 Created:  01/18/11
	 Version:  SAS 9.1
	 Environment:  Windows with SAS/Connect
	 
	 Description:  Read foreclosure data for 2011.

	 Modifications:
	   01/18/11 RAG	Added unverified thr. 01/18/11
	   01/24/11 RAG Added unverified thr. 01/24/11
	   01/31/11 RAG Added verified thr. 01/04/11 and unverified thr. 01/31/11
	   02/07/11 RAG Added verified thr. 01/07/11 and unverified thr. 02/07/11
	   02/14/11 RAG Added verified thr. 01/18/11 and unverified thr. 02/14/11
  	   02/21/11 RAG Added verified thr. 02/01/11 and unverified thr. 02/21/11
  	   02/28/11 RAG Added verified thr. 02/01/11 and unverified thr. 02/28/11
	   03/07/11 RAG Added verified thr. 02/09/11 and unverified thr. 03/04/11
	   03/14/11 RAG Added verified thr. 02/18/11 and unverified thr. 03/14/11
	   03/21/11 RAG Added verified thr. 03/01/11 and unverified thr. 03/20/11
	   03/28/11 RAG Added verified thr. 03/10/11 and unverified thr. 03/28/11
	   03/30/11	RAG Added Doc2011024920 for large Coop/Condominium group
	   04/04/11 RAG Added verified thr. 03/21/11 and unverified thr. 04/03/11
	   04/11/11 RAG Added verified thr. 03/23/11 and unverified thr. 04/11/11
	   04/18/11 RAG Added verified thr. 04/11/11 and unverified thr. 04/18/11
	   04/25/11 RAG Added verified thr. 04/19/11 and unverified thr. 04/25/11
	   05/02/11 RAG Added verified thr. 04/26/11 and unverified thr. 05/02/11
	   05/10/11 RAG Added verified thr. 05/04/11 and unverified thr. 05/10/11
	   05/16/11 RAG Added verified thr. 05/11/11 and unverified thr. 05/16/11
	   05/23/11 RAG Added verified thr. 05/17/11 and unverified thr. 05/23/11
	   05/31/11 RAG Added verified thr. 05/25/11 and unverified thr. 05/31/11
	   06/06/11 RAG Added verified thr. 05/31/11 and unverified thr. 06/06/11
	   06/13/11 RAG Added verified thr. 06/07/11 and unverified thr. 06/13/11
	   06/27/11 RAG Added verified thr. 06/21/11 and unverified thr. 06/27/11
	   07/05/11 RMP Added verified thr. 06/28/11 and unverified thr. 07/05/11
	   07/12/11 RMP Added verified thr. 07/07/11 and unverified thr. 07/12/11
	   07/19/11 RMP Added verified thr. 07/14/11 and unverified thr. 07/19/11
	   07/26/11 RMP Added verified thr. 07/21/11 and unverified thr. 07/26/11
	   08/01/11 RMP Added verified thr. 07/27/11 and unverified thr. 08/01/11
	   08/08/11 RMP Added verified thr. 08/02/11 and unverified thr. 08/08/11
	   08/15/11 RMP Added verified thr. 08/10/11 and unverified thr. 08/15/11
	   08/22/11 RMP Added verified thr. 08/15/11 and unverified thr. 08/22/11
 	   08/30/11 RMP Added verified thr. 08/24/11 and unverified thr. 08/30/11
	   09/07/11 RMP Added verified thr. 08/31/11 and unverified thr. 09/06/11
	   09/13/11 RMP Added verified thr. 09/09/11 and unverified thr. 09/13/11
	   09/19/11 RMP Added verified thr. 09/14/11 and unverified thr. 09/19/11
	   09/26/11 RMP Added verified thr. 09/20/11 and unverified thr. 09/26/11
	   10/04/11 RMP Added verified thr. 09/28/11 and unverified thr. 10/04/11
	   10/10/11 RMP Added verified thr. 10/04/11 and unverified thr. 10/10/11
	   10/17/11 RMP Added verified thr. 10/11/11 and unverified thr. 10/17/11
	   10/24/11 RMP Added verified thr. 10/14/11 and unverified thr. 10/24/11
	   10/31/11 RMP Added verified thr. 10/26/11 and unverified thr. 10/31/11
	   11/07/11 RMP Added verified thr. 11/01/11 and unverified thr. 11/07/11
	   11/14/11 RMP Added verified thr. 11/07/11 and unverified thr. 11/14/11
	   11/22/11 RMP Added verified thr. 11/17/11 and unverified thr. 11/22/11
	   11/28/11 RMP Added verified thr. 11/22/11 and unverified thr. 11/28/11
	   12/06/11 RMP Added verified thr. 12/04/11 and unverified thr. 12/06/11
	   12/19/11 RMP Added verified thr. 12/13/11 and unverified thr. 12/19/11
	   12/27/11 RMP Added verified thr. 12/19/11 and unverified thr. 12/27/11
	   01/10/12 RMP Added verified thr. 12/29/11 and unverified thr. 12/31/11
	   01/24/12 RMP Added verified thr. 12/31/11

**************************************************************************/

	%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
	%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

	** Define libraries **;
	%DCData_lib( ROD )
	%DCData_lib( RealProp )

	%Dup_document_list;

	%Read_foreclosures(
	  finalize= Y, 
	  revisions = %str(Added verified thr. 12/31/11 /*, unverified thr. 12/31/11 */ )  ,
	  year = 2011,
	  files = 

	/** Verified data (include all YTD files) **/
	   Foreclosures_2011_p1
	   Foreclosures_2011_p2
	   Foreclosures_2011_p3
	   Foreclosures_2011_p4
	   Foreclosures_2011_p5
	   Foreclosures_2011_p6
	   Foreclosures_2011_p7
	   Foreclosures_2011_p8	
	   Foreclosures_2011_p9
	   Foreclosures_2011_p10
	   Foreclosures_2011_p11
	   Foreclosures_2011_p12
	   Foreclosures_2011_p13
	   Foreclosures_2011_p14
	   Foreclosures_2011_p15
	   Foreclosures_2011_p16
	   Foreclosures_2011_p17
	   Foreclosures_2011_p18
 	   Foreclosures_2011_p19
	   Foreclosures_2011_p20
	   Foreclosures_2011_p21
	   Foreclosures_2011_p22
	   Foreclosures_2011_p23
	   Foreclosures_2011_p24
	   Foreclosures_2011_p25
	   Foreclosures_2011_p26
	   Foreclosures_2011_p27
	   Foreclosures_2011_p28
	   Foreclosures_2011_p29
	   Foreclosures_2011_p30
	   Foreclosures_2011_p31
	   Foreclosures_2011_p32
	   Foreclosures_2011_p33
	   Foreclosures_2011_p34
	   Foreclosures_2011_p35
	   Foreclosures_2011_p36
	   Foreclosures_2011_p37
	   Foreclosures_2011_p38
	   Foreclosures_2011_p39
	   Foreclosures_2011_p40
	   Foreclosures_2011_p41
	   Foreclosures_2011_p42
	   Foreclosures_2011_p43
	   Foreclosures_2011_p44
	   Foreclosures_2011_p45
	   Foreclosures_2011_p46
	   Foreclosures_2011_p47
	   Foreclosures_2011_p48
	   Foreclosures_2011_p49
	   Foreclosures_2011_p50
	   Foreclosures_2011_p51
	   Foreclosures_2011_p52
	   Foreclosures_2011_p53
	   Foreclosures_2011_p54
	   Foreclosures_2011_p55
	   Foreclosures_2011_p56
	   Foreclosures_2011_p57
	   Foreclosures_2011_p58
	   Foreclosures_2011_p59
	   Foreclosures_2011_p60
	   Foreclosures_2011_p61
	   Foreclosures_2011_p62
	   Foreclosures_2011_p63
	   Foreclosures_2011_p64
	   Foreclosures_2011_p65
	   Foreclosures_2011_p66
	   Foreclosures_2011_p67
	   Foreclosures_2011_p68
	   Foreclosures_2011_p69
	   Foreclosures_2011_p70
	   Foreclosures_2011_p71
	   Foreclosures_2011_p72
	   Foreclosures_2011_p73
	   Foreclosures_2011_p74
	   Foreclosures_2011_p75
	   Foreclosures_2011_p76
	   Foreclosures_2011_p77
	   Foreclosures_2011_p78
	   Foreclosures_2011_p79
	   Foreclosures_2011_p80
	   Foreclosures_2011_p81
	   Foreclosures_2011_p82
	   Foreclosures_2011_p83
	   Foreclosures_2011_p84
	   Foreclosures_2011_p85
	   Foreclosures_2011_p86
	   Foreclosures_2011_p87
	   Foreclosures_2011_p88
	   Foreclosures_2011_p89
	   Foreclosures_2011_p90
	   Foreclosures_2011_p91
	   Foreclosures_2011_p92
	   Foreclosures_2011_p93
	   Foreclosures_2011_p94
	   Foreclosures_2011_p95
	   Foreclosures_2011_p96

	/** New multiple lots **/
		/*New_multp_2011*/

	/** Randolf Towers Cooperative/Condominium **/
		Doc2011024920

	/** 2315 Lincoln Rd, NE**/
		Doc2011047056


	/** Unverified data (comment out all but the newest file) **/
		/* Foreclosures_2011_u1 */
		/* Foreclosures_2011_u2 */
		/* Foreclosures_2011_u3 */
		/* Foreclosures_2011_u4 */
		/* Foreclosures_2011_u5 */
		/* Foreclosures_2011_u6 */
		/* Foreclosures_2011_u7 */
		/* Foreclosures_2011_u8 */
		/* Foreclosures_2011_u9 */
		/* Foreclosures_2011_u10 */
		/* Foreclosures_2011_u11 */
		/* Foreclosures_2011_u12 */
		/* Foreclosures_2011_u13 */
		/* Foreclosures_2011_u14 */
		/* Foreclosures_2011_u15 */
		/* Foreclosures_2011_u16 */
		/* Foreclosures_2011_u17 */
		/* Foreclosures_2011_u18 */
		/* Foreclosures_2011_u19 */
		/* Foreclosures_2011_u20 */
		/* Foreclosures_2011_u21 */
		/* Foreclosures_2011_u22 */
		/* Foreclosures_2011_u23 */
		/* Foreclosures_2011_u24 */
		/* Foreclosures_2011_u25 */
		/* Foreclosures_2011_u26 */
		/* Foreclosures_2011_u27 */
		/* Foreclosures_2011_u28 */
		/* Foreclosures_2011_u29 */
		/* Foreclosures_2011_u30 */
		/* Foreclosures_2011_u31 */
		/* Foreclosures_2011_u32 */
		/* Foreclosures_2011_u33 */
		/* Foreclosures_2011_u34 */
		/* Foreclosures_2011_u35 */
		/* Foreclosures_2011_u36 */
		/* Foreclosures_2011_u37 */
		/* Foreclosures_2011_u38 */
		/* Foreclosures_2011_u39 */
		/* Foreclosures_2011_u40 */
		/* Foreclosures_2011_u41 */
		/* Foreclosures_2011_u42 */

		
	)
	run;
signoff;
