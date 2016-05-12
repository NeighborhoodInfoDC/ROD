/**************************************************************************
 Program:  Foreclosures_history_sales.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey & P. Tatian
 Created:  04/23/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create foreclosure history file with records for
 individual property foreclosure episodes.

 Modifications: 07/09/09 LH - Updated with Sales data through 3/31/09 and Foreclosures through 6/30/09 and expanded number available
							  for order variables.  Added proc freq to check order for future. 
		11/03/09 LH - Updated remaining issues - recoded commerical REO, lastnotice_date, added number of units for co-ops.
		03/24/10 LH - Updated to have episode reset for owner after more than 2 yrs between notices, instead of restarting old episode.
	    04/19/10 LH - Updated to remove Foreclosure/REO records when bank is seller (property not entering FC). 
	    09/14/10 LH - Modified Foreclosures_history to tract sales, foreclosure vs. reo vs. market. 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )



%let data       = sales_master;
%let out        = Foreclosures_history_sale;
%let RegExpFile = Owner type codes & reg expr LH.xls;
%let MaxExp     = 1000;
%let start_dt = '01jan1990'd;
%let end_dt   = '30jun2010'd;

%syslput MaxExp=&MaxExp;
%syslput data=&data;
%syslput out=&out;
%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;

proc format;
	value salecod
						           
1="Trustees Deed (matching sale) and REO"
2="Trustees Deed (matching sale) and Not REO"
3="Trustees Deed (no matching sale)"
4="Distressed Sale & REO"
5="Distressed Sale & not REO"
6="Market Sale (more than a year after last Fc notice)"
7="Market Sale - no previous fc episode"
8="REO Exit"
9="REO Transfer"
10="Buyer=Seller"
11="Other";

run;

options SORTPGM=SAS MSGLEVEL=I;

** Read in regular expressions **;

filename xlsfile dde "excel|&_dcdata_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;

data RegExp (compress=no);

  length OwnerCat $ 3 RegExp $ 1000;
  
  infile xlsfile missover dsd dlm='09'x;

  input OwnerCat RegExp;
  
  OwnerCat = put( 1 * OwnerCat, z3. );
  
  if RegExp = '' then stop;
  
  put OwnerCat= RegExp=;
  
run;

** Upload regular expressions **;

rsubmit ;

proc upload status=no
  data=RegExp 
  out=RegExp (compress=no);

run;

proc format;
	value salecod
						           
1="Trustees Deed (matching sale) and REO"
2="Trustees Deed (matching sale) and Not REO"
3="Trustees Deed (no matching sale)"
4="Distressed Sale & REO"
5="Distressed Sale & not REO"
6="Market Sale (more than a year after last Fc notice)"
7="Market Sale - no previous fc episode"
8="REO Exit"
9="REO Transfer"
10="Buyer=Seller"
11="Other";

run;
data sf_condo_dc (compress=no)
	 other (compress=no);
	 
  set realprop.sales_master;
  by ssl;

  retain Total 1;
  length OwnerDC 3;

  if address3 ~= '' then do;
  	if indexw( address3, 'DC' ) then OwnerDC=1;
  	else OwnerDC= 0;
  end;
  else OwnerDC = 9;


  *if ui_proptype in ('10' '11') and owner_occ_sale=1 then output sf_condo_dc;
  *else; output other;

  Label Total = 'Total'
  	  OwnerDC = 'DC-based owner';
  	  
run;
/*
data sf_condo_dc_10 (compress=no)
	 sf_condo_dc_un (compress=no);
 set sf_condo_dc;

by ssl;

length OwnerCat $3.;

if ownerDC and owner_occ_sale then Ownercat= '010'; 
label ownerCat='Owner type';

if ownerCat= '010' then output sf_condo_dc_10;
 else output sf_condo_dc_un;


run;*/
**Match regular expressions against owner data file sf_condo_dc_un**;

data other_coded (compress=no);
	set  other;
	by ssl sale_num;
   length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
label ownerCat='Owner type';
  array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
  array a_re{*}     re1-re&MaxExp;
  
  ** Load & parse regular expressions **;

  if _n_ = 1 then do;

    i = 1;

    do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat;
      a_re{i} = prxparse( regexp );
      if missing( a_re{i} ) then do;
        putlog "Error" regexp=;
        stop;
      end;
      i = i + 1;
    end;

    num_rexp = i - 1;

  end;

  i = 1;
  match = 0;

  do while ( i <= num_rexp and not match );
    if prxmatch( a_re{i}, ownername_full ) then do;
      OwnerCat = a_OwnerCat{i};
      ownername_full = propcase( ownername_full );
      match = 1;
    end;
    i = i + 1;
  end;

  if match=0 then OwnerCat='';

	**Owner-occupied Single Family;
	if match=0 and ui_proptype in('10' '11') and ownerDC and owner_occ_sale then Ownercat= '010'; 

  ** Cooperatives are owner-occupied (OwnerCat=20), unless special owner **;
  
  if ui_proptype = '12' and OwnerCat not in ( '040', '050', '060', '070', '080', '090', '100', '120', '130' )
  then do;
    OwnerCat = '020';
  end;
      
  else if OwnerCat = '' then do;
    OwnerCat = '030';
    *OwnerOcc = 0;
  end;

  if ownername_full=" " then ownercat='';
  drop i match num_rexp regexp OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;

run;

** Recombine **;

data Who_owns (compress=no);

  set other_coded;
by ssl;
   
  ** Assume OwnerDC=1 for government & quasi-gov. owners **;
  
  if OwnerCat in ( '040', '050', '060', '070' ) then OwnerDC = 1;
  
  ** All owner-occupied condos and apartment buildings in OwnerCat = 20 **;
  
  if ui_proptype in ('11' '12') and owner_occ_sale=1 and
	OwnerCat not in ( '040', '050', '060', '070', '080', '090', '100', '120', '130' ) then OwnerCat = '020';

  if ui_proptype in ('11' '12') and owner_occ_sale=1 and OwnerCat='030' then OwnerCat = '020';

  ** cannot figure out reg exp;
  if ownername_full="Dameon A Philpotts + Temple P Cooley" and ui_proptype='11' and owner_occ_sale then
  OwnerCat='020'; 
   else if ownername_full="Dameon A Philpotts + Temple P Cooley" and ui_proptype='11' then OwnerCat='030';

  ** William C Smith Apartment Buildings are not Other Individuals;
  if ui_proptype='13' and ownername_full in("WILLIAM C SMITH" "WILLIAM C SMITH + WILLIAM C SMITH JR") then Ownercat='110';

  ** Separate corporate (110) into for profit & nonprofit by tax status **;
  
  if OwnerCat = '110' then do;
    if mix1txtype = 'TX' then OwnerCat = '115';
    else OwnerCat = '111';
  end;
  
  ** Fixing '030' who are owneroccupied singlefamily homes **;
  if ui_proptype='10' and owner_occ_sale and OwnerCat='030' then OwnerCat='010'; 

  ** Duplicate OwnerCat variable for tables **;
  
  length OwnerCat_2 $ 3;
  
  OwnerCat_2 = OwnerCat;
  
  label OwnerCat_2 = 'Owner type (duplicate var)';
  

  ** Residential & non-residential land area for tables **;

  if ui_proptype in ( '10', '11', '12', '13' ) then landarea_res = landarea;
  else landarea_non = landarea;

      
run;


/** Download final file **;


proc download status=no
  data=Who_owns 
  out=Who_owns (label="Who owns the neighborhood analysis file, source &data");

run;
*/

%let start_yr = %sysfunc( year( &start_dt ) );
%let end_yr = %sysfunc( year( &end_dt ) );

data Foreclosures;

  set
	Rod.Foreclosures_1990
	Rod.Foreclosures_1991
	Rod.Foreclosures_1992
	Rod.Foreclosures_1993
	Rod.Foreclosures_1994
	Rod.Foreclosures_1995
  	Rod.Foreclosures_1996
    Rod.Foreclosures_1997
    Rod.Foreclosures_1998
    Rod.Foreclosures_1999
    Rod.Foreclosures_2000
    Rod.Foreclosures_2001 
    Rod.Foreclosures_2002 
    Rod.Foreclosures_2003 
    Rod.Foreclosures_2004 
    Rod.Foreclosures_2005
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007 
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009
    Rod.Foreclosures_2010
  ;
 
  where  ( &start_dt <= filingdate <= &end_dt ); 
  **where ui_proptype in ( '10', '11' ) and ( &start_dt <= filingdate <= &end_dt );
  **where ui_proptype in ( '10', '11' ) and ui_instrument in ( 'F1' 'F5') and ( &start_dt <= filingdate <= &end_dt );
  
run;

data trusteedeed foreclose;
	set foreclosures; 

year=year(filingdate);
	if ui_instrument in ('F1' 'F4')  then output foreclose;
	if ui_instrument = 'F5'   then output trusteedeed;

	run;
proc sort data=who_owns;
by ssl saledate;
proc sort data=trusteedeed;
by ssl filingdate;
run;
data trustee_sales;
merge who_owns (in=a  rename=(saledate=filingdate))
	  
	  trusteedeed (in=b keep=ui_instrument ssl filingdate grantee grantor xlot multiplelots ui_proptype)
			;
by ssl filingdate;

if a then sales=1; 
run;

data trustee_sales_forecl;
	set trustee_sales foreclose;

format filingdate_R MMDDYY10. ownercat $owncat.;

*sales date incorrectly listed as 1/1/1901 when deed date is 01/04/2005;
if filingdate ='01jan1901'd and ssl="5147    0073" then filingdate='04jan2005'd;   
filingdate_R=filingdate;
if filingdate in (.u .n) then filingdate_R=13879; *12/31/1997; *pre-1998 sales with no sales date;

year=year(filingdate);
	run;

proc sort data=trustee_sales_forecl;
by ssl filingdate_R;
run;

%macro order;
data step1;
	set trustee_sales_forecl (where=(ssl ne " "));

length record_type $23. prev_record_grantee prev_record_grantor prev2_record_grantee prev2_record_grantor $80. 
		prev_record_accept prev_record_hstd prev2_record_accept prev2_record_hstd$2.
	   prev_record_owner prev2_record_owner $150. prev2_record_xlot prev_record_xlot $16. 
		prev_record_owncat prev2_record_owncat$3. prev_record_prp prev2_record_prp $38.; 

format prev_record_prp prev2_record_prp $UIPRTYP38.;

*create order for obs w/in ssl;
	%let ord =2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61;
	%let ordlag =1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60;
	%do i = 1 %to 60;
	%let order = %scan(&ord.,&i., ' ');
	%let orderlag = %scan(&ordlag.,&i., ' ');

	ssl_lag=lag (ssl);
	if ssl ne ssl_lag then order=1;

	order_lag=lag(order);
	if order=. and order_lag=&orderlag. then order=&order.;
	order_lag=lag(order);

	%end;

/**OLD CODE***create record type for each obs - recode to numeric/char. var with format at later date;
if ui_instrument="F1" then record_type="Notice";
else if ui_instrument="F4" then record_type="Cancellation";
else if ui_instrument="F5" and (acceptcode = "05" | ownercat in('120' '130')) then record_type="TD/Foreclosure Sale/REO";
else if ui_instrument="F5" and acceptcode ne "05" and sales =1 and ownercat not in ('120' '130') 
			then record_type="TD/Other Sale";
else if ui_instrument="F5" then record_type="Trustees Deed";
else if ui_instrument=" " and (acceptcode = "05" | ownercat in('120' '130')) and usecode ne '061' then record_type="Foreclosure Sale/REO";
else if ui_instrument=" " and (acceptcode = "05" | ownercat in('120' '130')) and usecode = '061' and filingdate not in (.U .N) then record_type="Other Sale";
else if ui_instrument=" " and (acceptcode = "05" | ownercat in('120' '130')) and usecode = '061' and filingdate in(.U .N) then record_type="Pre 1998 Sale";
else if ui_instrument=" " and acceptcode not in("05") and ownercat not in ('120' '130') and filingdate not in (.U .N) 
			then record_type="Other Sale";
else if filingdate in(.U .N) and ui_instrument=" " then record_type="Pre 1998 Sale";*/

*create record type for each obs - recode to numeric/char. var with format at later date;
if ui_instrument="F1" then record_type="Notice";
else if ui_instrument="F4" then record_type="Cancellation";
else if ui_instrument="F5" and ownercat in('120' '130') then record_type="TD/Foreclosure Sale/REO";
else if ui_instrument="F5" and sales =1 and ownercat not in ('120' '130') then record_type="TD/Other Sale";
else if ui_instrument="F5" then record_type="Trustees Deed";
else if ui_instrument=" " and ownercat in('120' '130') and usecode ne '061' then record_type="Foreclosure Sale/REO";
else if ui_instrument=" " and ownercat in('120' '130') and usecode = '061' and filingdate not in (.U .N) then record_type="Other Sale";
else if ui_instrument=" " and ownercat in('120' '130') and usecode = '061' and filingdate in(.U .N) then record_type="Pre 1998 Sale";
else if ui_instrument=" " and ownercat not in ('120' '130') and filingdate not in (.U .N) then record_type="Other Sale";
else if filingdate in(.U .N) and ui_instrument=" " then record_type="Pre 1998 Sale";

*assign owner/property episode end points - more in data step3 ;
if record_type in("TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed" "Foreclosure Sale/REO" "Other Sale" "Pre 1998 Sale") then end=1; 
*if order=1 and record_type not in("TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed" "Foreclosure Sale/REO") then end=.;
	*not true for sales data;
*create previous record variables to use in data step3 to assign previous sale;  
prev_record_type=lag(record_type);
prev_record_date=lag(filingdate_R);  
prev_record_grantee=lag(grantee); 
prev_record_grantor=lag(grantor);
prev_record_xlot=lag(xlot);
prev_record_multiplelots=lag(multiplelots); 
prev_record_price=lag(saleprice);
prev_record_owner=lag(ownername_full);
prev_record_accept=lag(acceptcode);
prev_record_ownocc=lag(owner_occ_sale);
prev_record_hstd=lag(hstd_code); 
prev_record_snum=lag(sale_num);
prev_record_owncat=lag(ownercat);
prev_record_aval=lag(assess_val); 
prev_record_units=lag(no_units);
prev_record_ownocct=lag(no_ownocct);
prev_record_mkt=lag(market_sale);
prev_record_prp=lag(ui_proptype); 
prev_record_priceX=lag(price_excluded);
prev_record_ratioX=lag(ratio_excluded);

if prev_record_type not in ("Notice" "Cancellation") then do;
			prev_record_grantee=" "; prev_record_grantor=" "; 
			prev_record_xlot=" ";  prev_record_multiplelots=.; end;

prev_record_days=filingdate_r-prev_record_date;

*create second previous record variables to use when TD has to be matched +/- 30 day range;
prev2_record_type=lag2(record_type);
prev2_record_date=lag2(filingdate_R);  
prev2_record_grantee=lag2(grantee); 
prev2_record_grantor=lag2(grantor);
prev2_record_xlot=lag2(xlot);
prev2_record_multiplelots=lag2(multiplelots); 
prev2_record_price=lag2(saleprice);
prev2_record_owner=lag2(ownername_full);
prev2_record_accept=lag2(acceptcode);
prev2_record_ownocc=lag2(owner_occ_sale);
prev2_record_hstd=lag2(hstd_code); 
prev2_record_snum=lag2(sale_num);
prev2_record_owncat=lag2(ownercat);
prev2_record_aval=lag2(assess_val); 
prev2_record_units=lag2(no_units);
prev2_record_ownocct=lag2(no_ownocct);
prev2_record_mkt=lag2(market_sale);
prev2_record_prp=lag2(ui_proptype); 
prev2_record_priceX=lag2(price_excluded);
prev2_record_ratioX=lag2(ratio_excluded);

*reset previous record variables if first obs for ssl;
if order=1 then do; prev_record_type=" "; prev_record_date=" " ; prev_record_grantee=" " ; prev_record_grantor=" "; 
					prev_record_price=.; prev_record_owner=" "; prev_record_accept=" "; prev_record_ownocc=.; 
					prev_record_hstd=" "; prev_record_days=.; prev_record_multiplelots=.; prev_record_xlot=" ";
					prev_record_snum=.; prev_record_owncat=" "; prev_recod_units=.; prev_record_ownocct=.;
					prev_record_mkt=.; prev_record_prp=" "; prev_record_priceX=.; prev_record_ratioX=.;
		   end;

if order in (1 2) then do; 
prev2_record_type=" "; prev2_record_date=" " ; prev2_record_grantee=" " ; prev2_record_grantor=" "; 
					prev2_record_price=.; prev2_record_owner=" "; prev2_record_accept=" "; prev2_record_ownocc=.; 
					prev2_record_hstd=" "; prev2_record_days=.; prev2_record_multiplelots=.; prev2_record_xlot=" ";
					prev2_record_snum=.; prev2_record_owncat=" ";  prev2_recod_units=.; prev2_record_ownocct=.;
					prev2_record_mkt=.; prev2_record_prp=" "; prev2_record_priceX=.; prev2_record_ratioX=.;
		   end;

dayssinceEndDate=&end_dt.-filingdate_r;

run;

%mend order;
%order;
proc freq data=step1;
title2 "step1";
tables record_type order;
run;

*resort to capture next record;
proc sort data=step1 out=step1sorted;
by descending ssl descending order;
run;

data step2;
	set step1sorted;

length next_record_type $23.;
format next_record_date MMDDYY10.;
next_record_type=lag(record_type);
next_record_date=lag(filingdate);

run; 
proc sort data=step2 out=step2sorted;
by ssl order;
run;


data step3;
 set step2sorted;
   by ssl; 

	length lastnotice_grantee lastnotice_grantor lastcancel_grantee lastcancel_grantor tdeed_grantee tdeed_grantor $80.
			prev_sale_owner post_sale_owner $70. lastnotice_xlot $16. prev_sale_owncat post_sale_owncat $3. 
			prev_sale_prp post_sale_prp $38.;
	retain firstnotice_date lastnotice_date  num_notice lastnotice_grantee lastnotice_grantor lastnotice_multiplelots lastnotice_xlot
		   prev_sale_hstd prev_sale_ownocc prev_sale_date prev_sale_price prev_sale_accept prev_sale_owner prev_sale_num prev_sale_owncat prev_sale_priceX prev_sale_ratioX 
		   prev_sale_aval prev_sale_ownocct prev_sale_units prev_record_days  num_sales post_sale_reo prev_sale_mkt prev_sale_prp 
		   firstcancel_date lastcancel_date num_cancel outcome_date outcome_code  
		   tdeed_date tdeed_grantee tdeed_grantor
		   post_sale_date post_sale_price post_sale_accept post_sale_owner post_sale_hstd post_sale_ownocc post_sale_num post_sale_owncat 
			post_sale_aval post_sale_mkt post_sale_prp post_sale_priceX post_sale_ratioX;
	format firstnotice_date lastnotice_date prev_record_date prev2_record_date outcome_date prev_sale_date tdeed_date
		   firstcancel_date lastcancel_date next_record_date post_sale_date MMDDYY10.
			prev_sale_accept post_sale_accept $accept. prev_sale_hstd post_sale_hstd $homestd. lastnotice_multiplelots 
			prev_sale_priceX prev_sale_ratioX post_sale_priceX post_sale_ratioX DYESNO.
			prev_sale_owncat post_sale_owncat $owncat. prev_sale_ownocc post_sale_ownocc prev_sale_mkt post_sale_mkt YESNO.
		    prev_sale_prp post_sale_prp $UIPRTYP38.;

*finish creating end points;
if last.ssl=1 then do; end=1; next_record_type=" "; next_record_date=.; end; 
daystonextrec=next_record_date-filingdate_r;

if record_type="Cancellation" and end=. and prev_record_type="Cancellation" and next_record_type not in("Cancellation" 
					"Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed") then end=1;  
if record_type="Cancellation" and end=. and prev_record_type="Notice" and next_record_type not in("Cancellation" 
					"Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed") then end=1;

*Creating new end point if notice is two years after last notice - episode resarts (added 02/04/10); 
if record_type="Notice" and next_record_type="Notice" and daystonextrec >=730 then end=1; 

*Reseting END for Trustees Deed if next record is a sale within 31 days (1 month);
if record_type="Trustees Deed" and next_record_type in ("Foreclosure Sale/REO" "Other Sale" "Pre 1998 Sale") and 0 <= daystonextrec <=31 then end=.;

*Reseting END for "Foreclosure Sale/REO" "Other Sale" if next record is a Trustees Deed within 31 days (1 month);
if record_type in ("Foreclosure Sale/REO" "Other Sale" "Pre 1998 Sale") and next_record_type = "Trustees Deed" and 0 <= daystonextrec <=31 then end=.;

*Resetting END for Trustees Deed if next record is a Trustees Deed on the same day;
if record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") and 
	next_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") and 
		filingdate=next_record_date then end=.;

*creating final data set variables;
if first.ssl then do; 
	firstnotice_date=. ; lastnotice_date=.; outcome_date=.; prev_sale_date=.; prev_sale_price=.; 
	firstcancel_date=.; lastcancel_date=.; 	num_notice=0 ; num_cancel=0; num_sales=0; num_tdeed=0;
	lastnotice_grantee=" "; lastnotice_grantor=" "; prev_sale_accept=" "; prev_sale_owner=" "; prev_sale_ownocc=.; prev_sale_aval=.;
	prev_sale_hstd=" "; outcome_code=.; lastnotice_multiplelots=.; lastnotice_xlot=" "; prev_sale_num=.; prev_sale_owncat=" ";
	tdeed_date=.; tdeed_grantee=" "; tdeed_grantor=" "; post_sale_date=.; post_sale_price=.; post_sale_accept=" "; post_sale_owner=" ";
	post_sale_hstd=" "; post_sale_ownocc=.; post_sale_num=.; post_sale_owncat=" "; post_sale_aval=.; post_sale_reo=.;  
	prev_sale_mkt=.; post_sale_mkt=.; prev_sale_prp=" "; post_sale_prp=" "; prev_sale_priceX=.; prev_sale_ratioX=.;
	post_sale_priceX=.; post_sale_ratioX=.;
end;

if ui_instrument="F5"  then do; tdeed_date=filingdate; 
							    tdeed_grantee=grantee;
							    tdeed_grantor=grantor;
								num_tdeed=num_tdeed + 1; end;
if ui_instrument="F5" and prev_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale")
	and num_tdeed > 1 then do; 
								tdeed_date=filingdate; 
							    tdeed_grantee=grantee;
							    tdeed_grantor=grantor; end;

if ui_instrument="F1" and firstnotice_date=. then firstnotice_date=filingdate;
if ui_instrument="F1" then num_notice=num_notice + 1; 

if ui_instrument="F4" and prev_record_type="Notice" and firstnotice_date ne . then do;
									    lastnotice_date=prev_record_date;
										lastnotice_grantee=prev_record_grantee;
										lastnotice_grantor=prev_record_grantor; 
										lastnotice_xlot=prev_record_xlot;
										lastnotice_multiplelots=prev_record_multiplelots; end;
if ui_instrument="F4" and firstcancel_date=.  then firstcancel_date=filingdate;
if ui_instrument="F4" then num_cancel=num_cancel + 1;

if sale_num ne . then num_sales=num_sales + 1; *for testing ;

if num_tdeed <=1 and prev_record_type in("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Pre 1998 Sale") then do;
										  prev_sale_date=prev_record_date;
										  prev_sale_price=prev_record_price;
										  prev_sale_accept=prev_record_accept;
										  prev_sale_owner=prev_record_owner; 
										  prev_sale_hstd=prev_record_hstd;
										  prev_sale_ownocc=prev_record_ownocc;
										  prev_sale_num=prev_record_snum;
										  prev_sale_owncat=prev_record_owncat;	
										  prev_sale_aval=prev_record_aval;             
										  prev_sale_ownocct=prev_record_ownocct;
										  prev_sale_units=prev_record_units;
										  prev_sale_mkt=prev_record_mkt;
										  prev_sale_prp=prev_record_prp;
										  prev_sale_priceX=prev_record_priceX;
										  prev_sale_ratioX=prev_record_ratioX;
																					end;

if end=. and record_type in("Other Sale" "Pre 1998 Sale" "Foreclosure Sale/REO" ) and next_record_type = "Trustees Deed" and (0 <= daystonextrec <=31)
								then do;  post_sale_date=prev_record_date;
										  post_sale_price=prev_record_price;
										  post_sale_accept=prev_record_accept;
										  post_sale_owner=prev_record_owner; 
										  post_sale_hstd=prev_record_hstd;
										  post_sale_ownocc=prev_record_ownocc;
										  post_sale_num=prev_record_snum;
										  post_sale_owncat=prev_record_owncat; 
										  post_sale_aval=prev_record_aval;
										  post_sale_ownocct=prev_record_ownocct;
										  post_sale_units=prev_record_units;
										  post_sale_mkt=prev_record_mkt;
										  post_sale_prp=prev_record_prp;
										  post_sale_priceX=prev_record_priceX;
										  post_sale_ratioX=prev_record_ratioX;
								end;

if end=1 and record_type in("Other Sale" "Pre 1998 Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale") then do;
 										  post_sale_date=filingdate;
										  post_sale_price=saleprice;
										  post_sale_accept=acceptcode;
										  post_sale_owner=ownername_full; 
										  post_sale_hstd=hstd_code;
										  post_sale_ownocc=owner_occ_sale;
										  post_sale_num=sale_num;
										  post_sale_owncat=ownercat;			
										  post_sale_aval=assess_val;      
 										  post_sale_ownocct=no_ownocct;
										  post_sale_units=no_units;	
										  post_sale_mkt=market_sale;
										  post_sale_prp=ui_proptype;
										  post_sale_priceX=price_excluded;
										  post_sale_ratioX=ratio_excluded;
									end;

if end=1 and ui_instrument="F1" then do; lastnotice_date=filingdate;
										 lastnotice_grantee=grantee;
										 lastnotice_grantor=grantor;
										 lastnotice_xlot=prev_record_xlot;
										 lastnotice_multiplelots=prev_record_multiplelots; 		
										 prev_sale_prp=ui_proptype;		
								end;

if end=1 and record_type = "Notice" and prev_record_type="Notice" and 
	prev2_record_type in ("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Pre 1998 Sale") then do;
		 								  prev_sale_date=prev2_record_date;
										  prev_sale_price=prev2_record_price;
										  prev_sale_accept=prev2_record_accept;
										  prev_sale_owner=prev2_record_owner; 
										  prev_sale_hstd=prev2_record_hstd;
										  prev_sale_ownocc=prev2_record_ownocc;
										  prev_sale_num=prev2_record_snum;
										  prev_sale_owncat=prev2_record_owncat;	
										  prev_sale_aval=prev2_record_aval;             
										  prev_sale_ownocct=prev2_record_ownocct;
										  prev_sale_units=prev2_record_units;
										  prev_sale_mkt=prev2_record_mkt;
										  prev_sale_prp=prev2_record_prp;
										  prev_sale_priceX=prev2_record_priceX;
										  prev_sale_ratioX=prev2_record_ratioX;
																								      end;

if end=1 and ui_instrument="F4" then do; lastcancel_date=filingdate;
										 lastcancel_grantee=grantee;
										 lastcancel_grantor=grantor; 
										 lastnotice_xlot=prev_record_xlot;
										 lastnotice_multiplelots=prev_record_multiplelots;
										 prev_sale_prp=ui_proptype; 
								end;

if end=1 and lastnotice_date=. and prev_record_type="Notice" and record_type ne "Notice"  then do; 
										lastnotice_date=prev_record_date;
										lastnotice_grantee=prev_record_grantee;
										lastnotice_grantor=prev_record_grantor; 
										lastnotice_xlot=prev_record_xlot;
										lastnotice_multiplelots=prev_record_multiplelots;    end;

if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Foreclosure Sale/REO" "Other Sale")
and prev_record_type= "Trustees Deed" and prev2_record_type="Notice" then do; 
										lastnotice_date=prev2_record_date;
										lastnotice_grantee=prev2_record_grantee;
										lastnotice_grantor=prev2_record_grantor; 
										lastnotice_xlot=prev2_record_xlot;
										lastnotice_multiplelots=prev2_record_multiplelots;    end;

if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Trustees Deed")
and prev_record_type in("Foreclosure Sale/REO" "Other Sale") and prev2_record_type="Notice" then do; 
										lastnotice_date=prev2_record_date;
										lastnotice_grantee=prev2_record_grantee;
										lastnotice_grantor=prev2_record_grantor; 
										lastnotice_xlot=prev2_record_xlot;
										lastnotice_multiplelots=prev2_record_multiplelots;    end;

if end=1 and lastcancel_date=. and firstcancel_date ne . and prev_record_type="Cancellation" and record_type not in("Cancellation") 
										then do; lastcancel_date=prev_record_date; 
												 lastcancel_grantor=prev_record_grantor;
												 lastcancel_grantee=prev_record_grantee; 
												 lastnotice_xlot=prev_record_xlot;
												 lastnotice_multiplelots=prev_record_multiplelots; 
										end;

*create outcome code 1=in foreclosure 2=property sold, foreclosed 3=property sold, distressed sale, 4=property sold, foreclosure avoided,
					 5=No sale, foreclosure avoided, 6=cancellation and outcome date - calculate reo/not in step4; 

if end=1 and num_notice gt 0 then daysfromlastnotice=filingdate_r-lastnotice_date;

if end=1 and record_type ="Pre 1998 Sale" and num_notice~=0 and 0 <=daysfromlastnotice <= 365 then do; outcome_code=3; outcome_date=filingdate;  end;
if end=1 and record_type ="Pre 1998 Sale" and num_notice~=0 and daysfromlastnotice > 365 then do; outcome_code=4; outcome_date=lastnotice_date+365;  end;
if end=1 and record_type="Pre 1998 Sale" and num_notice = 0 then do; outcome_code=.n; outcome_date=.n; end;
if end=1 and record_type="Notice" and dayssinceEndDate lt 365 then do; outcome_code=1; outcome_date=.n; end;
if end=1 and record_type="Notice" and dayssinceEndDate ge 365 then do; outcome_code=5; outcome_date=lastnotice_date+365; end;
if end=1 and record_type in ("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") then do; 
												outcome_code=2; outcome_date=tdeed_date; end;
if end=1 and record_type ="Foreclosure Sale/REO" then do; outcome_code=3; outcome_date=filingdate;  end;
if end=1 and record_type ="Other Sale" and 0 <=daysfromlastnotice <= 365 then do; outcome_code=3; outcome_date=filingdate;  end;
if end=1 and record_type ="Other Sale" and daysfromlastnotice > 365 then do; outcome_code=4; outcome_date=lastnotice_date+365;  end;
if end=1 and record_type ="Other Sale" and num_notice=0 then do; outcome_code=.n; outcome_date=.n; end;
if end=1 and record_type ="Cancellation" then do; outcome_code=6; outcome_date=lastcancel_date;  end;

*Reseting record type & outcome if record is a sale marked as Foreclosure in RealProp but actually bank was seller not purchaser;
if end=1 and num_notice=0  and record_type="Foreclosure Sale/REO" and next_record_type ne "Trustees Deed" and prev_sale_owncat in("040" "050" "120" "130")
and post_sale_accept="05" then do; record_type="Other Sale"; outcome_code=.n; outcome_date=.n;  end;
if end=1 and num_notice=0  and record_type="Foreclosure Sale/REO" and next_record_type ne "Trustees Deed" and prev_sale_owncat in("040" "050" "120" "130")
and post_sale_owncat in("040" "050" "120" "130") then do; record_type="Other Sale"; outcome_code=.n; outcome_date=.n;  end;


if end=1 then do; output; /*and firstnotice_date ~=.*/
	firstnotice_date=. ; lastnotice_date=.; outcome_date=.; prev_sale_date=.; prev_sale_price=.; 
	firstcancel_date=.; lastcancel_date=.; 	num_notice=0 ; num_cancel=0; num_tdeed=0;
	lastnotice_grantee=" "; lastnotice_grantor=" "; prev_sale_accept=" "; prev_sale_owner=" "; prev_sale_ownocc=.; prev_sale_aval=.;
	prev_sale_ownocct=.; prev_sale_units=.; prev_sale_mkt=.; prev_sale_prp=" "; prev_sale_priceX=.; prev_sale_ratioX=.;
	prev_sale_hstd=" "; outcome_code=.; lastnotice_multiplelots=.; lastnotice_xlot=" "; prev_sale_num=.; prev_sale_owncat=" ";
	tdeed_date=.; tdeed_grantee=" "; tdeed_grantor=" "; post_sale_date=.; post_sale_price=.; post_sale_accept=" "; post_sale_owner=" ";
	post_sale_hstd=" "; post_sale_ownocc=.; post_sale_num=.; post_sale_owncat=" "; post_sale_aval=.;  post_sale_ownocct=.; 
	post_sale_units=.; post_sale_reo=.;  post_sale_mkt=.; post_sale_prp=" "; post_sale_priceX=.; post_sale_ratioX=.;
end; 

run;

proc freq data=step3;
title2 "step3";
tables outcome_code record_type /missprint;
format outcome_code outcome.;
run;

%macro order2;
data step4 ;
	set step3 (drop=order ssl_lag);

*assigning reo for govt owned properties;

if post_sale_owncat ne " " and post_sale_reo=. then post_sale_reo=0;

if post_sale_reo=0 then do;
if prev_sale_owncat in ('010' '020' '030' '110' '115' '') and post_sale_owncat in ('040' '050' '120' '130') and tdeed_date ne . then do;
															record_type="TD/Foreclosure Sale/REO";
															outcome_code=2; 
														    outcome_date=tdeed_date; 
															post_sale_reo=1;						 end;
if prev_sale_owncat in ('010' '020' '030' '110' '115' '') and post_sale_owncat in ('040' '050' '120' '130') and tdeed_date= . 
			and num_notice > 0 then do;
														    record_type="Foreclosure Sale/REO"; 
															outcome_code=3;
															outcome_date=filingdate; 
															post_sale_reo=1; 						end;
else if prev_sale_owncat in ('010' '020' '030' '110' '115') and post_sale_owncat in ('040' '050' '120' '130') and tdeed_date= . 
			and post_sale_accept = '05' then do;
														    record_type="Foreclosure Sale/REO"; 
															outcome_code=3;
															outcome_date=filingdate; 
															post_sale_reo=1; 			end;
else if prev_sale_owncat in ('010' '020' '030' '110' '115') and post_sale_owncat in ('040' '050' '120' '130') and tdeed_date= . 
			and prev_sale_prp in ('10' '11' '12' '13') and post_sale_owner ne "National Gallery Of Art" then do;
														    record_type="Foreclosure Sale/REO"; 
															outcome_code=3;
															outcome_date=filingdate; 
															post_sale_reo=1; 			end;
*government purchase;
if post_sale_accept='06' and record_type="Foreclosure Sale/REO" and num_notice=0 then do; record_type="Other Sale"; 
											post_sale_reo=0;
											outcome_code=.n;
											outcome_date=.;
											end;
*buyer=seller;
if post_sale_accept='03' and num_notice=0 and record_type="Foreclosure Sale/REO" then do; record_type="Other Sale"; 
											outcome_code=.n;
											outcome_date=.;
											end;
if prev_sale_owner="Banneker Court Llc" and post_sale_owner="District Of Columbia" then do; record_type="Other Sale"; 
										    post_sale_reo=0;
											outcome_code=.n;
											outcome_date=.;
											end;

*correcting record type for close to tdeed date sales "matches";
if tdeed_date ne . and record_type="Other Sale" and post_sale_reo in (. 0) then do; record_type="TD/Other Sale"; 
							outcome_code=2; 
							outcome_date=tdeed_date; end;
if tdeed_date ne . and record_type="Other Sale" and post_sale_reo=1 then do; record_type="TD/Foreclosure Sale/REO"; 
							outcome_code=2; 
							outcome_date=tdeed_date; end;
if tdeed_date ne . and record_type="Foreclosure Sale/REO" then do; 
				   record_type="TD/Foreclosure Sale/REO"; 
				   outcome_code=2; 
				   outcome_date=tdeed_date; 			 end;
if prev_record_type ="Other Sale" and record_type = "Trustees Deed" and (0 <= prev_record_days <=31) then do; 
																   record_type="TD/Other Sale"; 
																   outcome_code=2; 
																   outcome_date=tdeed_date; 		   end;
if prev_record_type ="Foreclosure Sale/REO" and record_type = "Trustees Deed" and (0 <= prev_record_days <=31) then do;
																   record_type="TD/Foreclosure Sale/REO";  
																   outcome_code=2; 
																   outcome_date=tdeed_date; 				  end;


end;	

*correcting for residential property that is transferred between banks/gse; 
if post_sale_prp in ('10' '11' '12' '13') and prev_sale_owncat in ('120' '130') and post_sale_owncat in ('120' '130')
	then post_sale_reo=1; 

 *dropping observations with no foreclosure notice/sale in owner/property episode; 
*if outcome_code=.n then delete;
*if post_sale_num=1 and filingdate=.n then delete;

if record_type not in ("Trustees Deed"  "TD/Foreclosure Sale/REO" "TD/Other Sale") then do; 
									tdeed_grantee=" "; tdeed_date=.n; tdeed_grantor=" "; end;


%let ord =2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61;
%let ordlag =1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60;
%do i = 1 %to 60;
%let order = %scan(&ord.,&i., ' ');
%let orderlag = %scan(&ordlag.,&i., ' ');

ssl_lag=lag (ssl);
if ssl ne ssl_lag then order=1;

order_lag=lag(order);
if order=. and order_lag=&orderlag. then order=&order.;
order_lag=lag(order);

%end;

*fix prev sale for multiple episodes of notices only;
lag_sale_num=lag(prev_sale_num); 
lag_sale_type=lag(prev_sale_type);
lag_sale_date=lag(prev_sale_date);  
lag_sale_price=lag(prev_sale_price);
lag_sale_owner=lag(prev_sale_owner);
lag_sale_accept=lag(prev_sale_accept);
lag_sale_ownocc=lag(prev_sale_ownocc);
lag_sale_hstd=lag(prev_sale_hstd); 
lag_sale_owncat=lag(prev_sale_owncat);
lag_sale_aval=lag(prev_sale_aval); 
lag_sale_units=lag(prev_sale_units);
lag_sale_ownocct=lag(prev_sale_ownocct);
lag_sale_mkt=lag(prev_sale_mkt);
lag_sale_prp=lag(prev_sale_prp);
lag_sale_priceX=lag(prev_sale_priceX);
lag_sale_ratioX=lag(prev_sale_ratioX);

lag2_sale_num=lag2(prev_sale_num); 
lag2_sale_type=lag2(prev_sale_type);
lag2_sale_date=lag2(prev_sale_date);  
lag2_sale_price=lag2(prev_sale_price);
lag2_sale_owner=lag2(prev_sale_owner);
lag2_sale_accept=lag2(prev_sale_accept);
lag2_sale_ownocc=lag2(prev_sale_ownocc);
lag2_sale_hstd=lag2(prev_sale_hstd); 
lag2_sale_owncat=lag2(prev_sale_owncat);
lag2_sale_aval=lag2(prev_sale_aval); 
lag2_sale_units=lag2(prev_sale_units);
lag2_sale_ownocct=lag2(prev_sale_ownocct);
lag2_sale_mkt=lag2(prev_sale_mkt);
lag2_sale_prp=lag2(prev_sale_prp);
lag2_sale_priceX=lag2(prev_sale_priceX);
lag2_sale_ratioX=lag2(prev_sale_ratioX);

lag3_sale_num=lag3(prev_sale_num); 
lag3_sale_type=lag3(prev_sale_type);
lag3_sale_date=lag3(prev_sale_date);  
lag3_sale_price=lag3(prev_sale_price);
lag3_sale_owner=lag3(prev_sale_owner);
lag3_sale_accept=lag3(prev_sale_accept);
lag3_sale_ownocc=lag3(prev_sale_ownocc);
lag3_sale_hstd=lag3(prev_sale_hstd); 
lag3_sale_owncat=lag3(prev_sale_owncat);
lag3_sale_aval=lag3(prev_sale_aval); 
lag3_sale_units=lag3(prev_sale_units);
lag3_sale_ownocct=lag3(prev_sale_ownocct);
lag3_sale_mkt=lag3(prev_sale_mkt);
lag3_sale_prp=lag3(prev_sale_prp);
lag3_sale_priceX=lag3(prev_sale_priceX);
lag3_sale_ratioX=lag3(prev_sale_ratioX);

if prev_sale_num = . and record_type="Notice" and lag_sale_num ne . and order ne 1 then do; 
												prev_sale_type=lag_sale_type;
												prev_sale_date=lag_sale_date;  
												prev_sale_price=lag_sale_price;
												prev_sale_owner=lag_sale_owner;
												prev_sale_accept=lag_sale_accept;
												prev_sale_ownocc=lag_sale_ownocc;
												prev_sale_hstd=lag_sale_hstd; 
												prev_sale_num=lag_sale_num;
												prev_sale_owncat=lag_sale_owncat;
												prev_sale_aval=lag_sale_aval; 
												prev_sale_units=lag_sale_units;
												prev_sale_ownocct=lag_sale_ownocct;
												prev_sale_mkt=lag_sale_mkt;
												prev_sale_prp=lag_sale_prp;
												prev_sale_priceX=lag_sale_priceX;
												prev_sale_ratioX=lag_sale_ratioX;
																end; 	

if prev_sale_num = . and record_type="Notice" and lag_sale_num = . and lag2_sale_num ne . and order not in(1 2) then do; 
												prev_sale_type=lag2_sale_type;
												prev_sale_date=lag2_sale_date;  
												prev_sale_price=lag2_sale_price;
												prev_sale_owner=lag2_sale_owner;
												prev_sale_accept=lag2_sale_accept;
												prev_sale_ownocc=lag2_sale_ownocc;
												prev_sale_hstd=lag2_sale_hstd; 
												prev_sale_num=lag2_sale_num;
												prev_sale_owncat=lag2_sale_owncat;
												prev_sale_aval=lag2_sale_aval; 
												prev_sale_units=lag2_sale_units;
												prev_sale_ownocct=lag2_sale_ownocct;
												prev_sale_mkt=lag2_sale_mkt;
												prev_sale_prp=lag2_sale_prp;
												prev_sale_priceX=lag2_sale_priceX;
												prev_sale_ratioX=lag2_sale_ratioX;
																end; 	

if prev_sale_num = . and record_type="Notice" and lag_sale_num = . and lag2_sale_num = . and lag3_sale_num ne . 
																							and order not in(1 2 3) then do; 
												prev_sale_type=lag3_sale_type;
												prev_sale_date=lag3_sale_date;  
												prev_sale_price=lag3_sale_price;
												prev_sale_owner=lag3_sale_owner;
												prev_sale_accept=lag3_sale_accept;
												prev_sale_ownocc=lag3_sale_ownocc;
												prev_sale_hstd=lag3_sale_hstd; 
												prev_sale_num=lag3_sale_num;
												prev_sale_owncat=lag3_sale_owncat;
												prev_sale_aval=lag3_sale_aval; 
												prev_sale_units=lag3_sale_units;
												prev_sale_ownocct=lag3_sale_ownocct;
												prev_sale_mkt=lag3_sale_mkt;
												prev_sale_prp=lag3_sale_prp;
												prev_sale_priceX=lag3_sale_priceX;
												prev_sale_ratioX=lag3_sale_ratioX;
																end; 	
if prev_sale_num=. and record_type in("TD/Foreclosure Sale/REO" "TD/Other Sale") and lag_sale_num ne . and order ne 1 then do; 
												prev_sale_type=lag_sale_type;
												prev_sale_date=lag_sale_date;  
												prev_sale_price=lag_sale_price;
												prev_sale_owner=lag_sale_owner;
												prev_sale_accept=lag_sale_accept;
												prev_sale_ownocc=lag_sale_ownocc;
												prev_sale_hstd=lag_sale_hstd; 
												prev_sale_num=lag_sale_num;
												prev_sale_owncat=lag_sale_owncat;
												prev_sale_aval=lag_sale_aval; 
												prev_sale_units=lag_sale_units;
												prev_sale_ownocct=lag_sale_ownocct;
												prev_sale_prp=lag_sale_prp;
												prev_sale_priceX=lag_sale_priceX;
												prev_sale_ratioX=lag_sale_ratioX;
																end; 	
if prev_sale_prp=. then prev_sale_prp=ui_proptype;

keep ssl filingdate_R filingdate ui_instrument num_notice  year firstnotice_date lastnotice_date lastnotice_grantee lastnotice_grantor
	tdeed_date tdeed_grantee tdeed_grantor num_tdeed
	prev_sale_date prev_sale_price prev_sale_accept prev_sale_owner prev_sale_hstd prev_sale_ownocc prev_sale_num prev_sale_owncat prev_sale_aval 
	prev_sale_units prev_sale_ownocct prev_sale_mkt prev_sale_prp prev_sale_priceX prev_sale_ratioX
	
	post_sale_date post_sale_price post_sale_accept post_sale_owner post_sale_hstd post_sale_ownocc post_sale_num post_sale_owncat post_sale_aval
	post_sale_units post_sale_ownocct post_sale_mkt post_sale_prp post_sale_priceX post_sale_ratioX
	outcome_date  outcome_code  post_sale_reo lag_sale_num lag2_sale_num 
	firstcancel_date lastcancel_date lastcancel_grantee lastcancel_grantor num_cancel num_sales 
	record_type prev_record_type next_record_type end prev_record_days order lastnotice_xlot lastnotice_multiplelots;
run;
%mend;
%order2;

proc freq data=step4;
title2 "step4";
tables outcome_code order post_sale_reo post_sale_reo*record_type/missprint;
format outcome_code outcome.  ;
run;

proc sort data=step4; 
by ssl order;
data step5_new (drop=ssl_lag) ;
	set step4;

prev_sale_reo=.;
ssl_lag=lag(ssl);

prev_sale_reo=lag(post_sale_reo); 
if ssl~=ssl_lag then prev_sale_reo=.; 
if outcome_code in (1 5 6) then delete;

outcome_code2=.;
if outcome_code=1 then outcome_code2=1;
if outcome_code=2 and post_sale_reo=1 then outcome_code2=2;
if outcome_code=2 and post_sale_reo in (. 0) then outcome_code2=3;
if outcome_code=3 and post_sale_reo=1 then outcome_code2=4;
if outcome_code=3 and post_sale_reo in (. 0) then outcome_code2=5;
if outcome_code=3 and record_type="Pre 1998 Sale" then outcome_code2=6;
if outcome_code=4 then outcome_code2=7;
if outcome_code=5 then outcome_code2=8;
if outcome_code=6 then outcome_code2=9; 

sale_code=.;

if post_sale_num ne . and outcome_code=2 & post_sale_reo=1 then sale_code=1; *Trustees Deed (matching sale) and REO;
else if post_sale_num ne . and outcome_code=2 & post_sale_reo in (. 0) then sale_code=2; *Trustees Deed (matching sale) and No REO;
else if post_sale_num=. and outcome_code=2 then sale_code=3; *Trustees Deed (no matching sale);
else if post_sale_num ne . and outcome_code=3 & post_sale_reo=1 then sale_code=4; *Distressed Sale & REO;
else if post_sale_num ne . and outcome_code=3 & post_sale_reo in (. 0) then sale_code=5; *Distressed Sale (not REO);
else if post_sale_num ne . and prev_sale_reo=1 and outcome_code=.n and post_sale_owncat not in('120' '130')
												then sale_code=8; *REO exit;
else if post_sale_num ne . and prev_sale_reo=1 and outcome_code=.n and post_sale_owncat in('120' '130')
												then sale_code=9; *REO Transfer;
else if post_sale_num ne . and outcome_code=.n and post_sale_accept='03' then sale_code=10; *buyer=seller;
else if post_sale_num ne . and outcome_code=4 and (post_sale_mkt=1 or post_sale_accept="01")
												then sale_code=6; *Market Sale (more than a year after last Fc notice);
else if post_sale_num ne . and outcome_code=4 and post_sale_price not in (. 0) then sale_code=6;
	*considering all othersales with price not zero as mkt - will add exclusions later;
else if post_sale_num ne . and outcome_code=.n and (post_sale_mkt=1 or post_sale_accept="01") 
												then sale_code=7; *Market Sale - no previous fc episode;
else if post_sale_num ne . and outcome_code=.n and post_sale_price not in (. 0) then sale_code=7; 

else if post_sale_num ne . and outcome_code=.n and (post_sale_mkt~=1 and post_sale_accept~="01")
									            then sale_code=11; *Other;
else if post_sale_num ne . and outcome_code=4 and (post_sale_mkt~=1 and post_sale_accept~="01")
									            then sale_code=11; *Other;

format outcome_code outcome. outcome_code2 outcomII. sale_code salecod.;
run;
title2 "step 5 new";
proc freq data=step5_new;
tables sale_code sale_code*outcome_code post_sale_mkt*outcome_code sale_code*post_sale_accept/missprint;
run;
title2 "step 5 new - 2003 and later";
proc freq data=step5_new;
where filingdate_r gt '01jan2003'd;
tables sale_code sale_code*outcome_code post_sale_mkt*outcome_code sale_code*post_sale_accept/missprint;
run;

proc print data=step5_new;
where sale_code=. & filingdate_r gt '01jan2003'd;
var ssl filingdate_R post_sale_num outcome_code record_type post_sale_reo post_sale_price post_sale_prp post_sale_owncat post_sale_mkt post_sale_accept;
run;
proc print data=step5_new;
where prev_sale_reo=1 & filingdate_r gt '01jan2003'd;
var ssl sale_code filingdate_R post_sale_num outcome_code num_notice prev_sale_reo prev_sale_owncat prev_sale_owner record_type post_sale_reo post_sale_owncat post_sale_mkt post_sale_accept;
run;
proc sort data=step5_new;
  by post_Sale_prp year;

proc univariate data= step5_new noprint;
where sale_code in (6 7); *"market" sales only;
  by post_Sale_prp year;
  var post_sale_price;
  output out=Sales_ptiles 
    n=_freq_
    p1=saleprice_p1  
    p99=saleprice_p99 ;
run;

proc print data=Sales_ptiles;
  by post_Sale_prp;
  id year;
  var _freq_ saleprice_p:  ;
  title2 'Sales exclusion criteria';
run;

data step5_new2;

  merge step5_new Sales_ptiles;
  by post_Sale_prp year;

  length post_sale_priceX 3;

  if saleprice_p1 <= post_sale_price <= saleprice_p99 then post_sale_priceX = 0;
  else post_sale_priceX = 1;

  run;

/*check for records that should have a previous sale that do not;
proc print data=step4;
var ssl record_type outcome_code filingdate_r prev_sale_num order num_sales ;
where  record_type="Notice" and prev_sale_num=. and num_sales ne 0;
run;
*/
**joining sales master file again to get next sale after foreclosure;
proc sql;
       create table Work.step5 as
       select step5_new2.*, sales.*
	 from step5_new2 left join who_owns 
       		as sales on (step5_new2.ssl = sales.ssl)
      	
	 having saledate gt filingdate_R; 
     quit;
  run;
**sorting to removing additional sales if more than one after foreclosure;
proc sort data=step5 nodupkey out=step6;
by ssl order ;
run;
data step7;
 set step6 (keep=saledate saleprice acceptcode hstd_code ownername owner_occ_sale sale_num 
				ownercat ASSESS_VAL ssl order no_units no_ownocct market_sale ui_proptype price_excluded ratio_excluded);
rename saledate=next_sale_date
saleprice=next_sale_price
acceptcode=next_sale_accept
hstd_code=next_sale_hstd
ownername=next_sale_owner
owner_occ_sale=next_sale_ownocc
sale_num=next_sale_num
ownercat=next_sale_owncat
assess_val=next_sale_aval
no_units=next_sale_units
no_ownocct=next_sale_ownocct
market_sale=next_sale_mkt
ui_proptype=next_sale_prp
price_excluded=next_sale_priceX
ratio_excluded=next_sale_ratioX;

run;

proc sort data=step7;
by ssl order;
proc sort data=step5_new;
by ssl order;
data step8;
merge step5_new (in=a ) step7  ;
if a;
by ssl order;
run;

proc sort data=step8;
by ssl;
proc sort data=realprop.parcel_base out=parcel_base;
by ssl;
proc sort data=realprop.parcel_geo out=parcel_geo;
by ssl;
data step9;
merge step8 (in=a) parcel_base (in=b keep=ssl usecode ownerpt_extractdat_last)
	  parcel_geo (in=c keep=ssl Anc2002 Casey_nbr2003 Casey_ta2003 City Cluster2000
                                     Cluster_tr2000 Eor Geo2000 GeoBlk2000 Psa2004 Ward2002 X_COORD Y_COORD
									 Zip);
if a;
by ssl; 

if b then pb_flag=1;
if c then pg_flag=1;
if num_notice gt 0 then firsttolast_days=lastnotice_date-firstnotice_date;  

format next_sale_owncat $owncat. next_sale_prp $UIPRTYP38. next_sale_priceX next_sale_ratioX DYesNO.;

label
pb_flag="Observation is in Parcel_base"
pg_flag="Observation is in Parcel_geo"
firsttolast_days="Number of days between first and last notice of foreclosure"
num_notice ="Number of notices of foreclosure sale"
firstnotice_date="Date of first notice of foreclosure"
lastnotice_date="Date of last notice of foreclosure" 
lastnotice_grantee="Grantee - last notice of foreclosure"
lastnotice_grantor="Grantor - last notice of foreclosure"
lastnotice_multiplelots="Document applies to multiple lots (see xLot for detail)"
lastnotice_xlot="Last notice of foreclosure original property lot (not reformatted)"
tdeed_date="Date of trustee's deed notice"
tdeed_grantee="Grantee - trustee's deed notice"
tdeed_grantor="Grantor - trustee's deed notice"
num_tdeed="Number of notices of trustees deed sale on same date"
prev_sale_date="Date of sale prior to notice"
prev_sale_price="Price of sale prior to notice"
prev_sale_accept="Acceptance code of sale prior to notice"
prev_sale_owner="Owner name prior to notice"
prev_sale_hstd="Homestead flag of sale prior to notice"
prev_sale_ownocc="Owner-occupied sale prior to notice"
prev_sale_num="Number of sale prior to notice"
prev_sale_owncat="Owner type of sale prior to notice"
prev_sale_aval="Assessed value at sale prior to notice"
prev_sale_units="Number of available cooperative units of sale prior to notice"
prev_sale_ownocct="Number of occupied cooperative units of sale prior to notice"
prev_sale_mkt="Previous Sale was Single-Family/Condo and Market Sale"
prev_sale_reo="Property was Previously Real Estate Owned"
prev_sale_prp="UI property type of previous sale"
prev_sale_priceX="Market sale prior to notice excluded based on price"
prev_sale_ratioX="Market sale prior to notice excluded based on price/appraised value ratio" 
outcome_date="Date of outcome"
outcome_code="Outcome code"
firstcancel_date="Date of first notice of cancellation"
lastcancel_date="Date of last notice of cancellation" 
lastcancel_grantee="Grantee - last notice of cancellation"
lastcancel_grantor="Grantor - last notice of cancellation"
num_cancel="Number of notices of cancellation"
record_type="Current record type" 
next_sale_date="Date of sale after outcome"
next_sale_price="Price of sale after outcome"
next_sale_accept="Acceptance code of sale after outcome"
next_sale_hstd="Homestead flag of sale after outcome"
next_sale_owner="Owner name of sale after outcome"
next_sale_ownocc="Owner-occupied sale after outcome"
next_sale_num="Number of sale after outcome"
next_sale_owncat="Owner type of sale after outcome"
next_sale_aval="Assessed value at sale after outcome"
next_sale_units="Number of available cooperative units of sale after outcome"
next_sale_ownocct="Number of occupied cooperative units of sale after outcome"
next_sale_prp="UI property type of sale after outcome"
next_sale_mkt="Sale after outcome is single fam. home/condo market sale"
next_sale_priceX="Market sale after outcome excluded based on price"
next_sale_ratioX="Market sale after outcome excluded based on price/appraised value ratio" 
post_sale_date="Date of sale after notice"
post_sale_price="Price of sale after notice"
post_sale_accept="Acceptance code of sale after notice"
post_sale_owner="Owner name of sale after notice"
post_sale_hstd="Homestead flag of sale after notice"
post_sale_ownocc="Owner-occupied sale after notice"
post_sale_num="Number of sale after notice"
post_sale_owncat="Owner type of sale after notice"
post_sale_aval="Assessed value at sale after notice"
post_sale_units="Number of available cooperative units of sale after notice"
post_sale_ownocct="Number of occupied cooperative units of sale after notice"
post_sale_prp="UI property type of sale after notice"
post_sale_mkt="Sale after notice is single fam. home/condo market sale"
post_sale_priceX="Market sale after notice excluded based on price"
post_sale_ratioX="Market sale after notice excluded based on price/appraised value ratio" 
sale_code="Type of Sale";

tdeed_grantee=upcase(tdeed_grantee);
lastnotice_grantor=upcase(lastnotice_grantor); 



run;

proc sort data=step9;
by ssl order;
run;
data last_grantor (compress=no keep=lastnotice_grantor ownercat ssl order);
	set step9;
	by ssl order;

   length OwnerCat1-OwnerCat&MaxExp $ 3;
   retain  OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;

  array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
  array a_re{*}     re1-re&MaxExp;
  
  ** Load & parse regular expressions **;

  if _n_ = 1 then do;

    i = 1;

    do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat;
      a_re{i} = prxparse( regexp );
      if missing( a_re{i} ) then do;
        putlog "Error" regexp=;
        stop;
      end;
      i = i + 1;
    end;

    num_rexp = i - 1;

    *put num_rexp= a_re{1}= a_re{2}=;

  end;

  i = 1;
  match = 0;

  do while ( i <= num_rexp and not match );
    if prxmatch( a_re{i}, lastnotice_grantor ) then do;
      OwnerCat = a_OwnerCat{i};
      lastnotice_grantor = propcase( lastnotice_grantor );
      match = 1;
    end;
    i = i + 1;
  end;

  drop i match num_rexp regexp OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;
if match=0 then ownercat=" ";
run;

data td_grantee (compress=no keep=ownercat tdeed_grantee ssl order  );
	set step9;
	by ssl order;

   length OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;

  array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
  array a_re{*}     re1-re&MaxExp;
  
  ** Load & parse regular expressions **;

  if _n_ = 1 then do;

    i = 1;

    do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat;
      a_re{i} = prxparse( regexp );
      if missing( a_re{i} ) then do;
        putlog "Error" regexp=;
        stop;
      end;
      i = i + 1;
    end;

    num_rexp = i - 1;

    *put num_rexp= a_re{1}= a_re{2}=;

  end;

  i = 1;
  match = 0;

  do while ( i <= num_rexp and not match );
    if prxmatch( a_re{i}, tdeed_grantee ) then do;
      OwnerCat = a_OwnerCat{i};
      tdeed_grantee = propcase( tdeed_grantee );
      match = 1;
    end;
    i = i + 1;
  end;
if match=0 then ownercat=" ";
  drop i match num_rexp regexp OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;

run;

proc sort data=td_grantee;
by ssl order;
proc sort data=last_grantor;
by ssl order;
proc sort data=step9;
by ssl order;
data step10;
merge step9 td_grantee (keep=ownercat ssl order rename=(ownercat=tdeed_grantee_owncat)) 
			   last_grantor (keep=ownercat ssl order rename=(ownercat=lastnotice_grantor_owncat));
by ssl order;
label lastnotice_grantor_owncat="Owner type of last notice of foreclosure grantor"
	  tdeed_grantee_owncat="Owner type of trustees deed notice grantee";

 /*creating second outcome code to break out reo properties.;  
if record_type="Trustees Deed" and tdeed_grantee_owncat in ('040' '050' '120' '130') and ownerpt_extractdat_last~=.
 and ownerpt_extractdat_last > outcome_date	then post_sale_reo=1; */

outcome_code2=.;
if outcome_code=1 then outcome_code2=1;
if outcome_code=2 and post_sale_reo=1 then outcome_code2=2;
if outcome_code=2 and post_sale_reo in (. 0) then outcome_code2=3;
if outcome_code=3 and post_sale_reo=1 then outcome_code2=4;
if outcome_code=3 and post_sale_reo=0 then outcome_code2=5;
if outcome_code=3 and record_type="Pre 1998 Sale" then outcome_code2=6;
if outcome_code=4 then outcome_code2=7;
if outcome_code=5 then outcome_code2=8;
if outcome_code=6 then outcome_code2=9; 

format outcome_code outcome. outcome_code2 outcomII. lastnotice_grantor_owncat  tdeed_grantee_owncat $OWNCAT.;
run;
/*ods tagsets.excelxp file="D:\DCDATA\Libraries\RealProp\Prog\Spellchecknames.xls" style=styles.minimal_mystyle options(sheet_interval='page' );
ods tagsets.excelxp options( sheet_name="spellcheck");
proc print data=who_owns;
where ownercat in ('040' '050' '120' '130');
var sale_num ssl saledate ownercat ownername_full;

run;
ods tagsets.excelxp close;*/

filename inf  "D:\DCDATA\Libraries\RealProp\Prog\REALPROP\prog\SpellCheckNames.csv" lrecl=5000;
  
  ** Read updated ssl records from CSV file **;

  data SpellCheckNames (compress=no);
  
    infile inf dsd  missover firstobs=2;

    input
      _drop1 $
      post_sale_num : 1. 
      ssl :$17.
       _drop2 $ 
	  ownercat : $3.
      ownername_full :$150.
      ownername_fullR :$150.
         ;
       drop _drop: ;
    
  run;

 filename inf clear;
proc sort data=SpellCheckNames;
by ssl post_sale_num;
proc sort data=step10;
by ssl post_sale_num;
data rod.&out (label="Foreclosure/Sales History, DC" drop=end lag_sale_num lag2_sale_num num_sales pv_owner ps_owner 
												ns_owner ln_grantor td_grantee ownername_fullR);
merge step10 (in=a) SpellCheckNames (in=b keep=ssl post_sale_num ownername_fullR);
by ssl post_sale_num;
if a;

pv_owner=propcase(prev_sale_owner);
ps_owner=propcase(post_sale_owner);
ns_owner=propcase(next_sale_owner);
ln_grantor=propcase(lastnotice_grantor);
td_grantee=propcase(tdeed_grantee);

%lender_history; 

if b then do;
	if post_sale_ownerR=" " then post_sale_ownerR=ownername_fullR;
	end;

if prev_sale_ownerR=" " then prev_sale_ownerR=prev_sale_owner;
if post_sale_ownerR=" " then post_sale_ownerR=post_sale_owner;
if next_sale_ownerR=" " then next_sale_ownerR=next_sale_owner;
if lastnotice_grantorR=" " then lastnotice_grantorR=lastnotice_grantor;
if tdeed_granteeR=" " then tdeed_granteeR=tdeed_granteeR;

label outcome_code2="Detailed outcome code"
Year="Year of filing/sales date"
filingdate_R="Filing/Sales date - recoded missing"
order="Order of record within ssl"
post_sale_reo="Property is held by bank/mrtg company etc after sale/foreclosure"
prev_record_days="Days from original previous record within ssl" 
prev_record_type="Original previous record type within ssl"
next_record_type="Following record type within ssl"
prev_sale_ownerR="Owner name prior to notice - Recoded"
post_sale_ownerR="Owner name of sale after notice - Recoded"
next_sale_ownerR="Owner name of sale after outcome - Recoded"
lastnotice_grantorR="Grantor - last notice of foreclosure - Recoded"
tdeed_granteeR="Grantee - trustee's deed notice - Recoded";
run;

%File_info( data=rod.&out, freqvars=outcome_code outcome_code2 sale_code post_sale_reo record_type)
run;



****Create REO History File only;
proc sort data=rod.&out out=step11;
by ssl;
data step12;

	set step11;
by ssl;

if first.ssl then do; ever_reo=0; ever_notice=0; ever_td=0; ever_reo_2003=0; ever_td_2003=0;  end;

retain ever_reo ever_notice ever_td ever_reo_2003 ever_td_2003;

if post_sale_reo=1 then ever_reo=ever_reo + 1;

if num_notice >0 then ever_notice=ever_notice +1 ;

if tdeed_date not in (. .n .u) or record_type in("TD/Other Sale" "Trustees Deed" "TD/Foreclosure Sale/REO") 
				then ever_td=ever_td + 1;

if tdeed_date >= '01jan2003'd then ever_td_2003 = ever_td_2003 + 1;
if post_sale_date >= '01jan2003'd and post_sale_reo=1 then ever_reo_2003=ever_reo_2003 + 1;

label ever_reo = "Property was in REO in the past"
	  ever_notice = "Property received a notice of foreclosure sale in the past"
	  ever_td="Property was foreclosed upon in the past"
	  ever_td_2003="Property was foreclosed upon after 2003"
	  ever_reo_2003="Property was in REO after 2003";

run;
proc freq data=step12;
tables ever_reo ever_notice ever_td ever_td_2003 ever_reo_2003;
run;

data rod.reo_sales_history;
set step12;

where ever_reo >= 1 or ever_notice >=1 or ever_td >=1;

run; 
%File_info( data=rod.reo_sales_history, freqvars=sale_code ever_reo ever_notice ever_td ever_td_2003 ever_reo_2003)

proc print data=step12;
where ever_td_2003 > 5;
var ssl post_sale_date tdeed_date ever_td_2003;
run;
