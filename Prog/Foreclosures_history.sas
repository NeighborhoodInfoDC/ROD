/**************************************************************************
 Program:  Foreclosures_history.sas
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
        03/24/10 LH - Updated to have episode reset for owner after more than  yrs between notices, instead of restarting old episode.
        04/19/10 LH - Updated to remove Foreclosure/REO records when bank is seller (property not entering FC).
        11/03/10 LH - Added macro to recode lender/servicer names.
        11/11/10 LH - Pre 1998 distressed sale in step 3 (took out no notices 05 accept),
                corrected banks selling property in step1 and made edits to reo in step4;
        12/22/10 LH - Expanded window around trustees deeds to OTR sales matches to +/- 60 days. Collapsed TDs that
                      follow eachother within 6 months with no intervening records. Simplified Ownercat code.
        01/23/11 LH - Added macro lists in step 3 and carried through multiple lots, doc number and sale type.
        	      Also added trustee's deeds in as separate sales records with REO - step 10.
	02/04/11 LH - Clean up trustees deeds as separate change of ownership - changed post_sale to owner after episode 
					  instead of owner after sale.
	03/03/11 LH - Owner type codes & reg expr 02-16-11.xls - Ran through year end 2010
    10/13/11 LH - Owner type codes & reg expr 09-28-11.xls - New UI_proptype - ran through q1 2011
	11/14/11 LH - Ran through q2 2011
	04/04/12 LH - Corrected code for Pre 1998 Sale. Ran through q3 2011. 
	08/21/12 LH - Started code to add NOD & Mediation Certs. Added 2010/12 geography. Ran through q1 2012. 
	11/20/12 LH - Ran through q2 2012. 
	04/25/13 LH - Ran through q4 2012. Updated to add 2013. Finished code to add NOD & Mediation Certs. 
**************************************************************************/
*%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas" /source2;
*%put _global_;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

%let data       = sales_master;
%let out        = Foreclosures_history;
%let RegExpFile = Owner type codes & reg expr 09-28-11.xls/*Owner type codes & reg expr LH.xls*/;
%let MaxExp     = 1000;
%let start_dt = '01jan1990'd;
%let end_dt   = '31dec2012'd;

%syslput MaxExp=&MaxExp;
%syslput data=&data;
%syslput out=&out;
%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;

options SORTPGM=SAS MSGLEVEL=I;

** Read in regular expressions **;

filename xlsfile dde "excel|&_dcdata_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;

data RegExp (compress=no);
  length OwnerCat_re $ 3 RegExp $ 1000;
  infile xlsfile missover dsd dlm='09'x;
  input OwnerCat_re RegExp;
  OwnerCat_re = put( 1 * OwnerCat_re, z3. );
  if RegExp = '' then stop;
  put OwnerCat_re= RegExp=;
run;


** Upload regular expressions **;

rsubmit ;

proc upload status=no
  data=RegExp
  out=RegExp (compress=no);

run;

data Who_owns;

            set realprop.&data;

   length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
   array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
   array a_re{*}     re1-re&MaxExp;

   ** Load & parse regular expressions **;
  if _n_ = 1 then do;
    i = 1;
   do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat_re;
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
    if prxmatch( a_re{i}, upcase( ownername_full ) ) then do;
      OwnerCat = a_OwnerCat{i};
      match = 1;
    end;

    i = i + 1;

  end;

  ** Assign codes for special cases **;

  if ownername_full ~= '' then do;

    ** Owner-occupied Single Family, Condo, and multifamily rental **;

    if ui_proptype='10' and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '010';

     if ui_proptype in ( '11', '13' ) and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '020';

    ** Cooperatives are owner-occupied (OwnerCat=20), unless special owner **;
    ** NOTE: PROBABLY NEED TO CHANGE THIS, MAYBE CREATE A SEPARATE OWNER CATEGORY FOR COOPS **;

    else if ui_proptype = '12' and OwnerCat in ( '', '030', '110' ) then do;
      OwnerCat = '020';
    end;

    else if OwnerCat in ( '', '030' ) then do;
      OwnerCat = '030';
    end;

  end;

  ** Separate corporate (110) into for profit & nonprofit by tax status **;

  if OwnerCat = '110' then do;
    if mix1txtype = 'TX' then OwnerCat = '115';
    else OwnerCat = '111';
  end;

  ownername_full = propcase( ownername_full );


  drop i match num_rexp regexp OwnerCat_re OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;

run;

/** Download final file **;


proc download status=no
  data=Who_owns
  out=Who_owns (label="Who owns the neighborhood analysis file, source &data");

run;
endrsubmit;*/


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
	Rod.Foreclosures_2011
	Rod.Foreclosures_2012
	Rod.Foreclosures_2013
  ;

  where  ( &start_dt <= filingdate <= &end_dt );

  **where ui_proptype in ( '10', '11' ) and ( &start_dt <= filingdate <= &end_dt );
  **where ui_proptype in ( '10', '11' ) and ui_instrument in ( 'F1' 'F5') and ( &start_dt <= filingdate <= &end_dt );

run;

data trusteedeed foreclose nod;
    set foreclosures;

year=year(filingdate);

*now in ROD (4/17/13) record says for this document number it is a NOD not a Mediation Cert.;
if  ui_instrument="M1" and DocumentNo="2012024599" then do; ui_instrument='D1'; Instrument="FORECL DEFAULT NOTE"; end;


    if ui_instrument in ('F1' 'F4')  then output foreclose;
    if ui_instrument = 'F5'   then output trusteedeed;
	if ui_instrument in ('D1' 'M1') then output nod;

    run;
proc sort data=who_owns;
by ssl saledate;
proc sort data=trusteedeed;
by ssl filingdate;
run;

data tdeed (compress=no );
    set trusteedeed ;
    by ssl filingdate;


     length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
   array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
   array a_re{*}     re1-re&MaxExp;

   ** Load & parse regular expressions **;
  if _n_ = 1 then do;
    i = 1;
   do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat_re;
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
    if prxmatch( a_re{i}, upcase( grantee ) ) then do;
      OwnerCat = a_OwnerCat{i};
      match = 1;
    end;

    i = i + 1;

  end;

if match=0 then ownercat=" ";

  grantee = propcase( grantee );

  drop i match num_rexp regexp OwnerCat_re OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;
run;
data trustee_sales (drop=tdeed_prp) who_owns_r (drop=ui_instrument grantee grantor xlot multiplelots tdeed_owncat tdeed_prp);
merge who_owns (in=a  rename=(saledate=filingdate))

      tdeed (in=b keep=ui_instrument ssl filingdate grantee grantor xlot multiplelots ui_proptype ownercat documentno /*added 04/24/13*/
                    rename=(ui_proptype=tdeed_prp ownercat=tdeed_owncat))
            ;
by ssl filingdate;

if a then sales=1;

%lender_history(grantee,granteeR);
%lender_history(ownername_full,ownerR);

if granteeR=" " then granteeR=grantee;
if ownerR=" " then ownerR=ownername_full;
                                                
if ui_proptype=" " and tdeed_prp ne " " then ui_proptype=tdeed_prp;

output trustee_sales;
if sales=1 then output who_owns_r;

run;

%macro names;
data trustee_sales_forecl;
    set trustee_sales foreclose nod;

format filingdate_R MMDDYY10. ownercat $owncat.;
length notice_lastname sale_lastname2 sale_lastname1 $70.;

if ui_instrument in ("F1" "F4" "M1" "D1") then notice_lastname = scan(grantee,1,' ');

%let owner=ownername ownname2;
%let number=1 2;
%do i = 1 %to 2;
%let name=%scan(&owner.,&i.," ");
%let num=%scan(&number.,&i.," ");
    if sales=1 and ownercat in('010' '020' '030') then do;
    *Suffix and last;
        if scan(&name.,-1) in ("I" "II" "III" "Jr." "Jr" "JR" "Sr" "Sr." "SR") then do;
                sale_lastname&num.=(scan(&name.,-2,' '));
        end;

        else if scan(&name.,-2) in ("MC" "VON") then do;
                    sale_lastname&num.=scan(&name.,-2)||" "||scan(&name.,-1);
                    end;
        else do;
        if length(Scan(&name.,-1))>1 then sale_lastname&num.=scan(&name.,-1);
        else sale_lastname&num.=scan(&name.,-2);

        end;
        if index(upcase(&name.), "TRUSTEE")>0 then sale_lastname&num.=" ";
    end;
%end;

sale_lastname1=propcase(sale_lastname1);
sale_lastname2=propcase(sale_lastname2);


*sales date incorrectly listed as 1/1/1901 when deed date is 01/04/2005;
if filingdate ='01jan1901'd and ssl="5147    0073" then filingdate='04jan2005'd;
filingdate_R=filingdate;
if filingdate in (.u .n) then filingdate_R=13879; *12/31/1997; *pre-1998 sales with no sales date;

year=year(filingdate);
    run;
%mend names;
%names;
proc sort data=trustee_sales_forecl;
by ssl filingdate_R DocumentNo; *added DocumentNo to sort on 04/17/13;
run;

%macro order;
data step1;
    set trustee_sales_forecl (where=(ssl ne " "));

length record_type $23. ;

*create order for obs w/in ssl;
    %let ord = 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36;
    %let ordlag =1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35;
    %do i = 1 %to 35;
    %let order = %scan(&ord.,&i., ' ');
    %let orderlag = %scan(&ordlag.,&i., ' ');

    ssl_lag=lag (ssl);
    if ssl ne ssl_lag then order=1;

    order_lag=lag(order);
    if order=. and order_lag=&orderlag. then order=&order.;
    order_lag=lag(order);

    %end;
*hard coding Document Number 2012135047 which was initially downloaded as notice of default but now says "FORECLOSURES" 
	--> ui_instrument= "F1"; 
if ui_instrument="D1" and documentno="2012135047" then ui_instrument="F1";  *ssl="5841  0040";

*create record type for each obs - recode to numeric/char. var with format at later date;
if ui_instrument="F1" then record_type="Notice";
else if ui_instrument="F4" then record_type="Cancellation";
else if ui_instrument="M1" then record_type="Mediation Certificate";
else if ui_instrument="D1" then record_type="Notice of Default";
else if ui_instrument="F5" and ownercat in('120' '130') then record_type="TD/Foreclosure Sale/REO";
else if ui_instrument="F5" and sales =1 and ownercat not in ('120' '130') then record_type="TD/Other Sale";
else if ui_instrument="F5" then record_type="Trustees Deed";
else if ui_instrument=" " and ownercat in('120' '130') and usecode ne '061' then record_type="Foreclosure Sale/REO";
else if ui_instrument=" " and ownercat in('120' '130') and usecode = '061' and filingdate not in (.U .N) then record_type="Other Sale";
else if ui_instrument=" " and ownercat in('120' '130') and usecode = '061' and filingdate in(.U .N) and 
	ownerpt_extractdat_first in(. .U .N .X)  then record_type="Pre 1998 Sale"; *no obs 4/4/12;
else if ui_instrument=" " and ownercat not in ('120' '130') and filingdate not in (.U .N) 
            then record_type="Other Sale";
else if filingdate in(.U .N)and ownerpt_extractdat_first in(. .U .N .X) and ui_instrument=" " then record_type="Pre 1998 Sale"; *no obs 4/4/12;
else if filingdate in(.U .N)and ownerpt_extractdat_first >= '26apr2001'd and ui_instrument=" " then record_type="Other Sale";

*assign owner/property episode end points - more in data step3 ;
if record_type in("TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed" "Foreclosure Sale/REO" "Other Sale" "Pre 1998 Sale") then end=1;
if order=1 and record_type not in("TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed" "Foreclosure Sale/REO") then end=.;


*hard coding where notice should have been recorded before sale/trustees deed but document number suggests 
otherwise and dates are the same (added 04/24/13) - requires breaking the datastep and resorting by order;
if ssl="0983    0039" and order =2 and record_type="Notice" then order=1;
if ssl="0983    0039" and order =1 and record_type="Trustees Deed" then order=2;
if ssl="3810    0123" and order =3 and record_type="Notice" then order=2;
if ssl="3810    0123" and order =2 and record_type="Trustees Deed" then order=3; 

run;
%mend order;
%order;
proc sort data=step1 out=step1a;
by ssl order;
run;

data step1b;
	set step1a; 

length prev_record_grantee prev_record_grantor $80. prev_record_accept prev_record_hstd $1.
       prev_record_owner prev_record_ownerR $150. prev_record_xlot $16. prev_record_owncat prev_record_towncat $3. 
		prev_record_prp prev2_record_prp $38. notice_lastname sale_lastname1 sale_lastname2 $70.;

format prev_record_prp prev2_record_prp $UIPRTYP38.;

*create previous record variables to use in data step3 to assign previous sale;
prev_record_type=lag(record_type);
prev_record_date=lag(filingdate_R);
prev_record_grantee=lag(grantee);
prev_record_granteeR=lag(granteeR);
prev_record_grantor=lag(grantor);
prev_record_xlot=lag(xlot);
prev_record_multiplelots=lag(multiplelots);
prev_record_doc=lag(documentno);
prev_record_gname=lag(notice_lastname);
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
prev_record_prp=lag(ui_proptype);
prev_record_sname1=lag(sale_lastname1);
prev_record_sname2=lag(sale_lastname2);
prev_record_stype=lag(saletype);
prev_record_ownerR=lag(ownerR);
prev_record_towncat=lag(tdeed_owncat);


if prev_record_type not in ("Notice" "Cancellation" "Trustees Deed" "Notice of Default" "Mediation Certificate") then do;
            prev_record_grantee=" "; prev_record_grantor=" ";
            prev_record_xlot=" ";  prev_record_multiplelots=.; prev_record_granteeR=" ";
            prev_record_gname=" "; prev_record_doc=" "; prev_record_towncat=" ";
end;

prev_record_days=filingdate_r-prev_record_date;

*create second previous record variables to use when TD has to be matched +/- 30 day range;
prev2_record_type=lag2(record_type);
prev2_record_date=lag2(filingdate_R);
prev2_record_grantee=lag2(grantee);
prev2_record_granteeR=lag2(granteeR);
prev2_record_grantor=lag2(grantor);
prev2_record_xlot=lag2(xlot);
prev2_record_multiplelots=lag2(multiplelots);
prev2_record_gname=lag2(notice_lastname);
prev2_record_doc=lag2(documentno);
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
prev2_record_prp=lag2(ui_proptype);
prev2_record_sname1=lag2(sale_lastname1);
prev2_record_sname2=lag2(sale_lastname2);
prev2_record_stype=lag2(saletype);
prev2_record_ownerR=lag2(ownerR);
prev2_record_towncat=lag2(tdeed_owncat);

*create third previous record variables to use when there are multiple Notices following a Med. Cert and a NOD (04/17/13);
prev3_record_type=lag3(record_type);
prev3_record_date=lag3(filingdate_R);
prev3_record_grantee=lag3(grantee);
prev3_record_granteeR=lag3(granteeR);
prev3_record_grantor=lag3(grantor);
prev3_record_xlot=lag3(xlot);
prev3_record_multiplelots=lag3(multiplelots);
prev3_record_gname=lag3(notice_lastname);
prev3_record_doc=lag3(documentno);
prev3_record_price=lag3(saleprice);
prev3_record_owner=lag3(ownername_full);
prev3_record_accept=lag3(acceptcode);
prev3_record_ownocc=lag3(owner_occ_sale);
prev3_record_hstd=lag3(hstd_code);
prev3_record_snum=lag3(sale_num);
prev3_record_owncat=lag3(ownercat);
prev3_record_aval=lag3(assess_val);
prev3_record_units=lag3(no_units);
prev3_record_ownocct=lag3(no_ownocct);
prev3_record_prp=lag3(ui_proptype);
prev3_record_sname1=lag3(sale_lastname1);
prev3_record_sname2=lag3(sale_lastname2);
prev3_record_stype=lag3(saletype);
prev3_record_ownerR=lag3(ownerR);
prev3_record_towncat=lag3(tdeed_owncat);

*reset previous record variables if first obs for ssl;
if order=1 then do; prev_record_type=" "; prev_record_date=.; prev_record_grantee=" " ; prev_record_grantor=" ";
                    prev_record_price=.; prev_record_owner=" "; prev_record_accept=" "; prev_record_ownocc=.;
                    prev_record_hstd=" "; prev_record_days=.; prev_record_multiplelots=.; prev_record_xlot=" ";
                    prev_record_snum=.; prev_record_owncat=" "; prev_recod_units=.; prev_record_ownocct=.;
                    prev_record_prp=" "; prev_record_granteeR=" ";  prev_record_gname=" "; prev_record_doc=" ";
                    prev_record_sname1=" "; prev_record_sname2=" "; prev_record_stype=" "; prev_record_aval=.;
					prev_record_ownerR=" "; prev_record_towncat=" ";
           end;

if order in (1 2) then do;
prev2_record_type=" "; prev2_record_date=.; prev2_record_grantee=" " ; prev2_record_grantor=" ";
                    prev2_record_price=.; prev2_record_owner=" "; prev2_record_accept=" "; prev2_record_ownocc=.;
                    prev2_record_hstd=" "; prev2_record_days=.; prev2_record_multiplelots=.; prev2_record_xlot=" ";
                    prev2_record_snum=.; prev2_record_owncat=" ";  prev2_record_units=.; prev2_record_ownocct=.;
                    prev2_record_prp=" "; prev2_record_granteeR=" "; prev2_record_gname=" "; prev2_record_doc=" ";
                    prev2_record_sname1=" "; prev2_record_sname2=" "; prev2_record_stype=" "; prev2_record_aval=.;
					prev2_record_ownerR=" "; prev2_record_towncat=" ";
           end;



if order in (1 2 3) then do;
prev3_record_type=" "; prev3_record_date=.; prev3_record_grantee=" " ; prev3_record_grantor=" ";
                    prev3_record_price=.; prev3_record_owner=" "; prev3_record_accept=" "; prev3_record_ownocc=.;
                    prev3_record_hstd=" "; prev3_record_days=.; prev3_record_multiplelots=.; prev3_record_xlot=" ";
                    prev3_record_snum=.; prev3_record_owncat=" ";  prev3_record_units=.; prev3_record_ownocct=.;
                    prev3_record_prp=" "; prev3_record_granteeR=" "; prev3_record_gname=" "; prev3_record_doc=" ";
                    prev3_record_sname1=" "; prev3_record_sname2=" "; prev3_record_stype=" "; prev3_record_aval=.;
					prev3_record_ownerR=" "; prev3_record_towncat=" ";
           end;

dayssinceEndDate=&end_dt.-filingdate_r;

run;



proc freq data=step1b;
title2 "step1";
tables record_type order;
run;

*resort to capture next record;
proc sort data=step1b out=step1sorted;
by descending ssl descending order;
run;

data step2;
    set step1sorted;

length next_record_type $23.;
format next_record_date MMDDYY10.;
next_record_type=lag(record_type);
next_record_date=lag(filingdate);
if next_record_type in("Trustees Deed" "TD/Other Sale" "TD/Foreclosure Sale/REO") then
next_record_tdgrantee=lag(granteeR);

daystonextrec=next_record_date-filingdate_r;
run;
proc sort data=step2 out=step2sorted;
by ssl order;
run;

***Variable lists need to be in specified order - order matches between lists***;

%let currentrodlist=filingdate grantee granteeR grantor xlot multiplelots documentno notice_lastname tdeed_owncat;**n=9;
%let prevrecRODlist=prev_record_date prev_record_grantee prev_record_granteeR prev_record_grantor prev_record_xlot
                    prev_record_multiplelots prev_record_doc prev_record_gname prev_record_towncat; **n=9;
%let prev2recRODlist=prev2_record_date prev2_record_grantee prev2_record_granteeR prev2_record_grantor prev2_record_xlot
                     prev2_record_multiplelots prev2_record_doc prev2_record_gname prev2_record_towncat; **n=9;
%let prev3recRODlist=prev3_record_date prev3_record_grantee prev3_record_granteeR prev3_record_grantor prev3_record_xlot
                     prev3_record_multiplelots prev3_record_doc prev3_record_gname prev3_record_towncat; **n=9;
%let lastnoticelist=lastnotice_date lastnotice_grantee lastnotice_granteeR lastnotice_grantor lastnotice_xlot
                    lastnotice_multiplelots lastnotice_doc lastnotice_lastname lastnotice_owncat; **n=9;
%let lastcancellist=lastcancel_date lastcancel_grantee lastcancel_granteeR lastcancel_grantor lastcancel_xlot
                    lastcancel_multiplelots lastcancel_doc lastcancel_lastname lastcancel_owncat; **n=9;
%let firsttdeedlist=firsttdeed_date firsttdeed_grantee firsttdeed_granteeR firsttdeed_grantor firsttdeed_xlot
                    firsttdeed_multiplelots firsttdeed_doc firsttdeed_lastname firsttdeed_owncat; **n=9;
%let lasttdeedlist=lasttdeed_date lasttdeed_grantee lasttdeed_granteeR lasttdeed_grantor lasttdeed_xlot
                   lasttdeed_multiplelots lasttdeed_doc lasttdeed_lastname lasttdeed_owncat; **n=9;
%let lastNODlist=lastdefault_date lastdefault_grantee lastdefault_granteeR lastdefault_grantor lastdefault_xlot
                    lastdefault_multiplelots lastdefault_doc lastdefault_lastname lastdefault_owncat; **n=9;
%let lastmedlist=lastmediate_date lastmediate_grantee lastmediate_granteeR lastmediate_grantor lastmediate_xlot
                    lastmediate_multiplelots lastmediate_doc lastmediate_lastname lastmediate_owncat; **n=9;

%let currentsalelist=filingdate_R saleprice ownername_full ownerR acceptcode owner_occ_sale hstd_code sale_num ownercat
                     assess_val no_units no_ownocct ui_proptype sale_lastname1 sale_lastname2 saletype; **n=16;
%let prevrecSALElist=prev_record_date prev_record_price prev_record_owner prev_record_ownerR prev_record_accept prev_record_ownocc
                     prev_record_hstd prev_record_snum prev_record_owncat prev_record_aval prev_record_units
                     prev_record_ownocct prev_record_prp prev_record_sname1 prev_record_sname2 prev_record_stype; **n=16;
%let prev2recSALElist=prev2_record_date prev2_record_price prev2_record_owner prev2_record_ownerR prev2_record_accept prev2_record_ownocc
                      prev2_record_hstd prev2_record_snum prev2_record_owncat prev2_record_aval prev2_record_units
                      prev2_record_ownocct prev2_record_prp prev2_record_sname1 prev2_record_sname2 prev2_record_stype; **n=16;
%let prevsalelist=prev_sale_date prev_sale_price prev_sale_owner prev_sale_ownerR prev_sale_accept prev_sale_ownocc prev_sale_hstd
                  prev_sale_num prev_sale_owncat prev_sale_aval prev_sale_units prev_sale_ownocct prev_sale_prp
                  prev_sale_lastname1 prev_sale_lastname2 prev_sale_stype; **n=16;
%let postsalelist=post_sale_date post_sale_price post_sale_owner post_sale_ownerR post_sale_accept post_sale_ownocc post_sale_hstd
                  post_sale_num post_sale_owncat post_sale_aval post_sale_ownocct post_sale_units post_sale_prp
                  post_sale_lastname1 post_sale_lastname2 post_sale_stype; **n=16;

%let characterlist=post_sale_owner post_sale_ownerR post_sale_accept post_sale_hstd post_sale_owncat post_sale_prp post_sale_lastname1
                   post_sale_lastname2 post_sale_stype prev_sale_owner prev_sale_ownerR prev_sale_accept prev_sale_hstd prev_sale_owncat
                   prev_sale_prp prev_sale_lastname1 prev_sale_lastname2 prev_sale_stype lastnotice_grantee
                   lastnotice_granteeR lastnotice_grantor lastnotice_xlot lastnotice_doc lastnotice_lastname
                   lastcancel_grantee lastcancel_granteeR lastcancel_grantor lastcancel_xlot lastcancel_doc
                   lastcancel_lastname lasttdeed_grantee lasttdeed_granteeR lasttdeed_grantor lasttdeed_xlot
                   lasttdeed_doc lasttdeed_lastname firsttdeed_grantee firsttdeed_granteeR firsttdeed_grantor
                   firsttdeed_xlot firsttdeed_doc firsttdeed_lastname lasttdeed_owncat firsttdeed_owncat 
				   lastcancel_owncat lastnotice_owncat
				   lastdefault_grantee lastdefault_owncat
                   lastdefault_granteeR lastdefault_grantor lastdefault_xlot lastdefault_doc lastdefault_lastname
				   lastmediate_grantee lastmediate_owncat
                   lastmediate_granteeR lastmediate_grantor lastmediate_xlot lastmediate_doc lastmediate_lastname
	; **n=46; /***n=60;*/
%let numericlist=post_sale_date post_sale_price post_sale_ownocc post_sale_num post_sale_aval post_sale_ownocct
                 post_sale_units prev_sale_date prev_sale_price prev_sale_ownocc prev_sale_num prev_sale_aval
                 prev_sale_ownocct prev_sale_units lastnotice_date lastnotice_multiplelots lastcancel_date
                 lastcancel_multiplelots lasttdeed_date lasttdeed_multiplelots firsttdeed_date firsttdeed_multiplelots
				 lastdefault_date lastdefault_multiplelots lastmediate_date lastmediate_multiplelots; **n=22; /***n=26;*/

%macro Step3;
data step3;
 set step2sorted;
   by ssl;

    length lastnotice_grantee lastnotice_granteeR lastnotice_grantor lastcancel_grantee lastcancel_granteeR lastcancel_grantor
            firsttdeed_grantee firsttdeed_granteeR firsttdeed_grantor lasttdeed_grantee lasttdeed_granteeR lasttdeed_grantor 
			lastdefault_grantee lastdefault_granteeR lastdefault_grantor lastmediate_grantee lastmediate_granteeR lastmediate_grantor $80.
            prev_sale_owner post_sale_owner prev_sale_ownerR post_sale_ownerR lastnotice_lastname lasttdeed_lastname firsttdeed_lastname 
			lastcancel_lastname prev_sale_lastname1 prev_sale_lastname2 post_sale_lastname1 post_sale_lastname2
			lastdefault_lastname  lastmediate_lastname $70.
            lastnotice_xlot lastcancel_xlot lasttdeed_xlot firsttdeed_xlot lastdefault_xlot lastmediate_xlot  $16. 
			prev_sale_owncat post_sale_owncat
			lasttdeed_owncat firsttdeed_owncat lastnotice_owncat lastcancel_owncat lastdefault_owncat lastmediate_owncat $3.
            prev_sale_prp post_sale_prp $38. prev_sale_stype post_sale_stype $22.;
    retain firstnotice_date firstcancel_date num_notice num_cancel num_tdeed num_sales prev_record_days post_sale_reo
           outcome_date outcome_code prev_rule post_rule num_default num_mediate firstdefault_date firstmediate_date
           &prevsalelist. &postsalelist. &lastnoticelist. &lastNODlist. &lastmedlist. &lastcancellist. &lasttdeedlist. &firsttdeedlist.;
    format firstnotice_date lastnotice_date prev_record_date prev2_record_date outcome_date prev_sale_date firsttdeed_date
           lasttdeed_date firstcancel_date lastcancel_date next_record_date post_sale_date firstdefault_date firstmediate_date
			lastdefault_date lastmediate_date MMDDYY10.
           prev_sale_accept post_sale_accept $accept. prev_sale_hstd post_sale_hstd $homestd.
           lastnotice_multiplelots lastcancel_multiplelots lasttdeed_multiplelots firsttdeed_multiplelots lastdefault_multiplelots lastmediate_multiplelots DYESNO.
           prev_sale_owncat post_sale_owncat firsttdeed_owncat lasttdeed_owncat lastdefault_owncat lastmediate_owncat $owncat. 
			prev_sale_ownocc post_sale_ownocc YESNO.
           prev_sale_prp post_sale_prp $UIPRTYP38. prev_sale_stype post_sale_stype $SALETYP.;


*finish creating end points;
if last.ssl=1 then do; end=1; next_record_type=" "; next_record_date=.; daystonextrec=.; next_record_tdgrantee=" "; end;

if record_type="Cancellation" and end=. and prev_record_type="Cancellation" and next_record_type not in("Cancellation"
                    "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed") then end=1;
if record_type="Cancellation" and end=. and prev_record_type="Notice" and next_record_type not in("Cancellation"
                    "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed") then end=1;
if record_type="Cancellation" and end=. and prev_record_type="Notice" and next_record_type in("Notice" "Cancellation"
                    "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed")
	and daystonextrec gt 730 then end=1;
if record_type="Cancellation" and end=. and prev_record_type not in("Notice" "Cancellation") and daystonextrec gt 730
    then end=1;

*revising end for cancellation filed the same day as a distressed sale (added 04/24/13); 
if record_type="Cancellation" and end=1 and prev_record_type="Other Sale" and prev2_record_type="Notice" 
	and filingdate_r=prev_record_date then end=.; 

*revising end for notice filed on the same day as a distressed sale (added 04/24/13);  
if record_type="Notice" and prev_record_type="Other Sale" and num_notice > 0 and filingdate_r=prev_record_date
	and next_record_type not in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") then end=.;

*Creating new end point if notice of default is received and no new record for a year (added 04/17/13); 
if record_type="Notice of Default" and next_record_type not in("Mediation Certificate" "Notice of Default") 
			and daystonextrec >=365 then end=1; 

*Creating new end point if mediation certficate is received and notice of foreclosure sale never filed
			lender has 12 months from issuance to file for foreclosure sale but could request 6 month extension (added 04/17/13);
if record_type="Mediation Certificate" and next_record_type not in ("Mediation Certificate" "Notice") 
	and daystonextrec >=548 then end=1; 

*Creating new end point if received notice of foreclosure sale before law change and then later receives a NOD (added 04/23/13);
if record_type="Notice" and next_record_type ="Notice of Default"  and daystonextrec >= 30 then end=1; 
	*Put month date restriction looks like notice of foreclosure sale shouldnt have been filed;
 

*Creating new end point if notice is two years after last notice - episode resarts (added 02/04/10);
if record_type="Notice" and next_record_type="Notice" and daystonextrec >=730 then end=1;

*Resetting END for Trustees Deed if next record is a Trustees Deed on the same day;
if record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") and
    next_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") and
        filingdate=next_record_date then end=.;

*Resetting END for Trustees Deed if next record is a Trustees Deed on w/in 6 months days;
if record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") and
    next_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale")
    and 0 <= daystonextrec <=180  then end=.;

tdmatchprev=.;
tdmatchpost=.;

*Resetting END for "Foreclosure Sale/REO" "Other Sale" if next record is a Trustees Deed within 60 days (2 month);
if record_type in("Foreclosure Sale/REO" "Other Sale") and next_record_type= "Trustees Deed"  and 
	0 <= daystonextrec <=60 then do; end=.; tdmatchprev=1; end;

*Reseting END for Trustees Deed if next record is a sale within 60 days (2 month);
if tdmatchprev=. and record_type="Trustees Deed" and next_record_type in ("Foreclosure Sale/REO" "Other Sale")
		and 0 <= daystonextrec <=30 then do; end=.; tdmatchpost=1; end;

if ssl="0553W   0039" and Record_type="Trustees Deed" and order=13 then end=.;*exception but td grantee matches new owner;
if ssl="0553W   0039" and Record_type="Trustees Deed" and order=14 then end=1;
if ssl="5564    0065" and Record_type="Trustees Deed" and order=11 then end=1;
if ssl="5564    0065" and Record_type="Other Sale" and order=10 then end=.;
if ssl="5564    0065" and Record_type="Trustees Deed" and order=9 then end=.;


*creating final data set variables;
if first.ssl then do;
    num_notice=0 ; num_cancel=0; num_sales=0; num_tdeed=0; num_default=0; num_mediate=0; prev_rule=.;  post_rule=.; firstnotice_date=. ;
    firstcancel_date=.; outcome_date=.; post_sale_reo=.;
    %do i=1 %to 26; %let num=%scan(&numericlist.,&i.," "); &num.=.; %end;
    %do j=1 %to 60; %let char=%scan(&characterlist.,&j.," "); &char.=" "; %end;
end;

if ui_instrument="F5" then num_tdeed=num_tdeed + 1;

if ui_instrument="F5" and firsttdeed_date=. then do;
        %do k=1 %to 9; %let firsttdeed=%scan(&firsttdeedlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &firsttdeed.=&currentrod.; %end;
                                                 end;

if ui_instrument="F5" and prev_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Other Sale"
"Foreclosure Sale/REO") and num_tdeed > 1 then do;
        %do k=1 %to 9; %let lasttdeed=%scan(&lasttdeedlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lasttdeed.=&currentrod.; %end;
                                          end;

if end=1 and ui_instrument="F5" and num_tdeed=1 then do;
        %do k=1 %to 9; %let lasttdeed=%scan(&lasttdeedlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lasttdeed.=&currentrod.; %end;
                                                end;
if end=1 and firsttdeed_date ne . and num_tdeed=1 and lasttdeed_date = . then do;
		   %do k=1 %to 9; %let lasttdeed=%scan(&lasttdeedlist.,&k.," "); %let firsttdeed=%scan(&firsttdeedlist.,&k.," ");
                            &lasttdeed.=&firsttdeed.; %end;
                                                end;
/*Does this make sense??
if end=1 and prev_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Other Sale"
"Foreclosure Sale/REO") and num_tdeed=1 then do;
        %do k=1 %to 8; %let lasttdeed=%scan(&lasttdeedlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lasttdeed.=&currentrod.; %end;  end;*/

if ui_instrument="F1" and firstnotice_date=. then firstnotice_date=filingdate;
if ui_instrument="F1" then num_notice=num_notice + 1;

if ui_instrument="F4" and prev_record_type="Notice" and firstnotice_date ne . then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prevrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastnotice.=&prevrod.; %end;
                                                                             end;
if ui_instrument="D1" then num_default=num_default + 1;
if ui_instrument="D1" and firstdefault_date=. then firstdefault_date=filingdate;

if ui_instrument="M1" then num_mediate=num_mediate + 1; 
if ui_instrument="M1" and firstmediate_date=. then firstmediate_date=filingdate;  

if ui_instrument="F4" and firstcancel_date=.  then firstcancel_date=filingdate;
if ui_instrument="F4" then num_cancel=num_cancel + 1;

if sale_num ne . then num_sales=num_sales + 1; *for testing ;

if end=. and ui_instrument="F5" and prev_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale")
    and num_tdeed > 1 and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2rod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2rod.; %end;
                                                     end;

if end=. and ui_instrument="F5" and next_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale")
    and prev_record_type="Other Sale" and  0 <=  prev_record_days < 60 and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2rod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2rod.; %end;
                                                                                                      end;

 if end=. and ui_instrument="F5" and next_record_type in("Other Sale" "Foreclosure Sale/REO") and 0 <= daystonextrec < 60
    and prev_record_type="Notice" then do;
            %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prevrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastnotice.=&prevrod.; %end;
                                  end;

if order=2 and ssl="5565    2082" and ui_instrument="F4" then do;
        %do k=1 %to 9; %let lastcancel=%scan(&lastcancellist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastcancel.=&currentrod.; %end;
                                                        end;
/*why doesnt this work?
if end=. and lastcancel_date=. and firstcancel_date ne . and prev2_record_type="Cancellation" and prev_record_type="Notice"
    and record_type="Notice" and next_record_type in ("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO"
            "TD/Other Sale" "Pre 1998 Sale" "Trustees Deed") then do;
        %do k=1 %to 8; %let lastcancel=%scan(&lastcancellist.,&k.," "); %let prev2rod=%scan(&prev2recRODlist.,&k.," ");
                            &lastcancel.=&prev2rod.; %end;
                                            end;
*/
if end=. and record_type in ("Notice" "Notice of Default") and prev_record_type in ("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO"
            "TD/Other Sale" "Pre 1998 Sale") then do;
    %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prevrecsale=%scan(&prevrecSALElist.,&l.," ");
                            &prevsale.=&prevrecsale.; %end;
                            prev_rule=1;     end;

if record_type in("TD/Other Sale" "Pre 1998 Sale" "Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO")
then do;
    %do l=1 %to 16; %let postsale=%scan(&postsalelist.,&l.," "); %let currentsale=%scan(&currentsalelist.,&l.," ");
                            &postsale.=&currentsale.; %end;
                post_rule=2; end;

if prev_sale_date=. and num_tdeed <=1 and prev_record_type in("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO"
"TD/Other Sale" "Pre 1998 Sale") and prev_sale_num=. and post_Sale_num ne 1 then do;
        %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prevrecsale=%scan(&prevrecSALElist.,&l.," ");
                            &prevsale.=&prevrecsale.; %end;
                                                             prev_rule=3; end;

if prev_sale_date=. and num_tdeed <=1 and prev2_record_type in("Other Sale" "Foreclosure Sale/REO")
    and prev_record_type="Trustees Deed" and post_Sale_num ne 1 then do;
        %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prev2recsale=%scan(&prev2recSALElist.,&l.," ");
                            &prevsale.=&prev2recsale.; %end;
                                                    prev_rule=4; end;
if end=1 and ui_instrument="F1" and prev_record_type in ("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO"
"TD/Other Sale" "Pre 1998 Sale") then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastnotice.=&currentrod.; %end;
          %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prevrecsale=%scan(&prevrecSALElist.,&l.," ");
                            &prevsale.=&prevrecsale.; %end;
                                prev_rule=6; end;

if end=1 and ui_instrument="D1" and prev_record_type in ("Other Sale" "Foreclosure Sale/REO" "TD/Foreclosure Sale/REO"
"TD/Other Sale" "Pre 1998 Sale") then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastdefault.=&currentrod.; %end;
          %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prevrecsale=%scan(&prevrecSALElist.,&l.," ");
                            &prevsale.=&prevrecsale.; %end;
                                prev_rule=6.5; end;

if end=1 and ui_instrument="F1" and lastnotice_date=. then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastnotice.=&currentrod.; %end;
                            prev_sale_prp=ui_proptype;
                                end;

if end=1 and record_type = "Notice" and prev_record_type="Notice" and prev2_record_type in ("Other Sale"
"Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Pre 1998 Sale") then do;
        %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prev2recsale=%scan(&prev2recSALElist.,&l.," ");
                            &prevsale.=&prev2recsale.; %end;
                                                                    prev_rule=5; end;

if end=1 and record_type = "Notice of Default" and prev_record_type="Notice of Default" and prev2_record_type in ("Other Sale"
"Foreclosure Sale/REO" "TD/Foreclosure Sale/REO" "TD/Other Sale" "Pre 1998 Sale") then do;
        %do l=1 %to 16; %let prevsale=%scan(&prevsalelist.,&l.," "); %let prev2recsale=%scan(&prev2recSALElist.,&l.," ");
                            &prevsale.=&prev2recsale.; %end;
                                                                    prev_rule=5.5; end;

if end=1 and ui_instrument="D1" then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastdefault.=&currentrod.; %end;
                            prev_sale_prp=ui_proptype;
                                end;

if end=1 and ui_instrument="M1" then do;
        %do k=1 %to 9; %let lastmediate=%scan(&lastmedlist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastmediate.=&currentrod.; %end;
                            prev_sale_prp=ui_proptype;
                                end;

if end=1 and ui_instrument="F4" then do;
        %do k=1 %to 9; %let lastcancel=%scan(&lastcancellist.,&k.," "); %let currentrod=%scan(&currentrodlist.,&k.," ");
                            &lastcancel.=&currentrod.; %end;
                            prev_sale_prp=ui_proptype;
                                end;

if end=1 and ui_instrument="F4" and prev_record_type="Notice" and lastnotice_date=. then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastnotice.=&prevrecrod.; %end;
                                                             end;

if end=1 and firstnotice_date ne . and lastnotice_date=. and prev_record_type="Notice" and record_type ne "Notice"  then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastnotice.=&prevrecrod.; %end;
                                                                                       end;
if end=1 and firstnotice_date ne . and lastnotice_date=. and record_type in("Notice of Default" "Mediation Certificate") and prev_record_type in("Notice of Default" "Mediation Certificate") 
and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2recrod.; %end;
							   end;

if end=1 and lastmediate_date=. and prev_record_type="Mediation Certificate" and record_type ne "Mediation Certificate"  then do;
        %do k=1 %to 9; %let lastmediate=%scan(&lastmedlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastmediate.=&prevrecrod.; %end;
                                                                                          end;
if end=1 and lastdefault_date=. and prev_record_type="Notice of Default" and record_type ne "Notice of Default"  then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastdefault.=&prevrecrod.; %end;
                                                                                          end;

if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Foreclosure Sale/REO" "Other Sale")
and prev_record_type= "Trustees Deed" and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2recrod.; %end;
                                                                     end;

if end=1 and lastdefault_date=. and firstdefault_date ne . and record_type in("Notice")
and prev_record_type= "Mediation Certificate" and prev2_record_type="Notice of Default" then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastdefault.=&prev2recrod.; %end;
                                                                     end;

if end=1 and lastdefault_date=. and firstdefault_date ne . and record_type in("Notice")
and prev_record_type="Notice" and prev2_record_type= "Mediation Certificate" and prev3_record_type="Notice of Default" then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prev3recrod=%scan(&prev3recRODlist.,&k.," ");
                            &lastdefault.=&prev3recrod.; %end;
                                                                     end;

if end=1 and lastdefault_date=. and firstdefault_date ne . and record_type in("Trustees Deed" "TD/Foreclosure Sale/REO"
"TD/Other Sale")and prev_record_type="Notice" and prev2_record_type= "Mediation Certificate" and prev3_record_type="Notice of Default" then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prev3recrod=%scan(&prev3recRODlist.,&k.," ");
                            &lastdefault.=&prev3recrod.; %end;
                                                                     end;
if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Trustees Deed")
and prev_record_type in("Foreclosure Sale/REO" "Other Sale" ) and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2recrod.; %end;
                                                                                             end;

if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Trustees Deed" "TD/Foreclosure Sale/REO"
"TD/Other Sale") and prev_record_type in("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale")
and num_tdeed > 1 and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2recrod.; %end;
                                                 end;

if end=1 and lastnotice_date=. and firstnotice_date ne . and record_type in("Other Sale") and prev_record_type in("Notice of Default")
and prev2_record_type="Notice" then do;
        %do k=1 %to 9; %let lastnotice=%scan(&lastnoticelist.,&k.," "); %let prev2recrod=%scan(&prev2recRODlist.,&k.," ");
                            &lastnotice.=&prev2recrod.; %end;
                                                 end;

if end=1 and lastcancel_date=. and firstcancel_date ne . and prev_record_type="Cancellation" and
    record_type not in("Cancellation") then do;
        %do k=1 %to 9; %let lastcancel=%scan(&lastcancellist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastcancel.=&prevrecrod.; %end;
                                        end;

if end=1 and lastcancel_date=. and firstcancel_date ne . and prev2_record_type="Cancellation" and prev_record_type ne "Cancellation"
    and record_type not in("Cancellation") then do;
        %do k=1 %to 9; %let lastcancel=%scan(&lastcancellist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastcancel.=&prevrecrod.; %end;
                                            end;

if end=1 and lastdefault_date=. and firstdefault_date ne . and prev_record_type="Notice of Default" and
    record_type not in("Notice of Default") then do;
        %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastdefault.=&prevrecrod.; %end;
                                        end;

if end=1 and lastdefault_date=. and firstdefault_date ne . and prev2_record_type="Notice of Default" and prev_record_type ne "Notice of Default"
    and record_type not in("Notice of Default") then do;
      %do k=1 %to 9; %let lastdefault=%scan(&lastNODlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastdefault.=&prevrecrod.; %end;
                                        end;

if end=1 and lastmediate_date=. and firstmediate_date ne . and prev_record_type="Mediation Certificate" and
    record_type not in("Mediation Certificate") then do;
        %do k=1 %to 9; %let lastmediate=%scan(&lastmedlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastmediate.=&prevrecrod.; %end;
                                        end;

if end=1 and lastmediate_date=. and firstmediate_date ne . and prev2_record_type="Mediation Certificate" and prev_record_type ne "Mediation Certificate"
    and record_type not in("Mediation Certificate") then do;
      %do k=1 %to 9; %let lastmediate=%scan(&lastmedlist.,&k.," "); %let prevrecrod=%scan(&prevrecRODlist.,&k.," ");
                            &lastmediate.=&prevrecrod.; %end;
                                        end;

*create outcome code 
		1=in foreclosure 
		2=property sold, foreclosed 
		3=property sold, distressed sale (property was in foreclosure or in default in last year), 
		4=property sold, foreclosure avoided,
        5=No sale, foreclosure avoided, 
	    6=cancellation, 
		7=In Default, 
		8=property sold, default cured
		9=no sale, default cured
										and outcome date - calculate reo/not in step4;

if end=1 and num_notice gt 0 then daysfromlastnotice=filingdate_r-lastnotice_date;
if end=1 and num_default gt 0 then daysfromlastdefault=filingdate_r-lastdefault_date;
if end=1 and num_mediate gt 0 then daysfromlastmediate=filingdate_r-lastmediate_date;

if end=1 and record_type in ("Other Sale" "Pre 1998 Sale") and num_notice~=0 and 0 <=daysfromlastnotice <= 365 then do; outcome_code=3; outcome_date=filingdate;  end;
if end=1 and record_type in ("Other Sale" "Pre 1998 Sale") and num_notice~=0 and daysfromlastnotice > 365 then do; outcome_code=4; outcome_date=lastnotice_date+365;  end;
if end=1 and record_type ="Other Sale"  and num_default~=0 and 0 <=daysfromlastdefault <= 365 then do; outcome_code=3; outcome_date=filingdate;  end;
if end=1 and record_type ="Other Sale" and num_default~=0 and daysfromlastdefault > 365 then do; outcome_code=8; outcome_date=lastdefault_date+365;  end;

if end=1 and record_type in ("Other Sale" "Pre 1998 Sale") and num_notice = 0 and num_default=0 then do; outcome_code=.n; outcome_date=.n; end;

if end=1 and record_type="Notice" and dayssinceEndDate lt 365  then do; outcome_code=1; outcome_date=.n; end; 
if end=1 and record_type="Notice" and dayssinceEndDate ge 365 then do; outcome_code=5; outcome_date=lastnotice_date+365; end;
if end=1 and record_type in ("Trustees Deed" "TD/Foreclosure Sale/REO" "TD/Other Sale") then do;
                                                outcome_code=2; outcome_date=firsttdeed_date; end;

if end=1 and record_type in("Other Sale" "Foreclosure Sale/REO") and prev_record_type in("Trustees Deed")
    and 0 <= prev_record_days <=60 and outcome_code=. then do; outcome_code=2; outcome_date=firsttdeed_date; end;
if end=1 and record_type ="Foreclosure Sale/REO" then do; outcome_code=3; outcome_date=filingdate;  end;

if end=1 and record_type ="Cancellation" then do; outcome_code=6; outcome_date=lastcancel_date;  end;

if end=1 and record_type ="Notice of Default" and daysfromlastdefault > 365 then do; outcome_code=9; outcome_date=lastdefault_date+365; end;
if end=1 and record_type ="Notice of Default" and 0 <=daysfromlastdefault <= 365 then do; outcome_code=7; outcome_date=.n; end;
if end=1 and record_type ="Mediation Certificate" and daysfromlastmediate > 548 then do; outcome_code=9; outcome_date=lastmediate_date+548; end;
if end=1 and record_type ="Mediation Certificate" and 0 <=daysfromlastmediate <= 548 then do; outcome_code=7; outcome_date=.n; end;


*Reseting record type & outcome if record is a sale marked as Foreclosure in RealProp but actually bank was seller not purchaser;
if end=1 and num_notice=0  and record_type="Foreclosure Sale/REO" and next_record_type ne "Trustees Deed" and prev_sale_owncat in("040" "050" "120" "130")
and post_sale_accept="05" then do; record_type="Other Sale"; outcome_code=.n; outcome_date=.n; ; end;
if end=1 and num_notice=0  and record_type="Foreclosure Sale/REO" and next_record_type ne "Trustees Deed" and prev_sale_owncat in("040" "050" "120" "130")
and post_sale_owncat in("040" "050" "120" "130") then do; record_type="Other Sale"; outcome_code=.n; outcome_date=.n; ; end;

*put in post_sale_owner for episodes ending in foreclosure avoided. post_sale_owner should only be missing for 
those still in the foreclosure inventory or in active default;

if end=1 and outcome_code=5 and record_type="Notice" then do; 
    %do l=1 %to 16; %let postsale=%scan(&postsalelist.,&l.," "); %let prevsale=%scan(&prevsalelist.,&l.," ");
                            &postsale.=&prevsale.; %end;
                post_rule=7; end;

if end=1 and outcome_code=6 and record_type="Cancellation" then do; 
    %do l=1 %to 16; %let postsale=%scan(&postsalelist.,&l.," "); %let prevsale=%scan(&prevsalelist.,&l.," ");
                            &postsale.=&prevsale.; %end;
                post_rule=7; end;

if end=1 and outcome_code=9 and record_type in("Notice of Default" "Mediation Certificate") then do; 
    %do l=1 %to 16; %let postsale=%scan(&postsalelist.,&l.," "); %let prevsale=%scan(&prevsalelist.,&l.," ");
                            &postsale.=&prevsale.; %end;
                post_rule=8; end;


if end=1 then do; output; /*and firstnotice_date ~=.*/
    num_notice=0 ; num_cancel=0; num_sales=0; num_tdeed=0; num_default=0; num_mediate=0; prev_rule=.;  post_rule=.; firstnotice_date=. ;
    firstcancel_date=.; firstdefault_date=.; firstmediate_date=.; outcome_date=.; post_sale_reo=.;
    %do i=1 %to 26; %let num=%scan(&numericlist.,&i.," "); &num.=.; %end;
    %do j=1 %to 60; %let char=%scan(&characterlist.,&j.," "); &char.=" "; %end;
end;
run;
%mend step3;
%step3;

proc freq data=step3;
title2 "step3";
tables outcome_code record_type /missprint;
format outcome_code outcome.;
run;
proc sort data=step3;
by ssl filingdate_R;

%macro order2;
data step4 ;
    set step3 (drop=order ssl_lag);

*correcting record type for close to tdeed date sales "matches";
if firsttdeed_date ne . and record_type="Other Sale" then do; record_type="TD/Other Sale";
                            outcome_code=2;
                            outcome_date=firsttdeed_date; end;

if firsttdeed_date ne . and record_type="Foreclosure Sale/REO" then do;
                   record_type="TD/Foreclosure Sale/REO";
                   outcome_code=2;
                   outcome_date=firsttdeed_date;             end;

if prev_record_type ="Other Sale" and record_type = "Trustees Deed" and (0 <= prev_record_days <=60) then do;
                                                                   record_type="TD/Other Sale";
                                                                   outcome_code=2;
                                                                   outcome_date=firsttdeed_date;           end;
if prev_record_type ="Foreclosure Sale/REO" and record_type = "Trustees Deed" and (0 <= prev_record_days <=60) then do;
                                                                   record_type="TD/Foreclosure Sale/REO";
                                                                   outcome_code=2;
                                                                   outcome_date=firsttdeed_date;                  end;

%let ord = 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26;
%let ordlag =1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25;
%do i = 1 %to 25;
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
lag_sale_date=lag(prev_sale_date);
lag_sale_price=lag(prev_sale_price);
lag_sale_owner=lag(prev_sale_owner);
lag_sale_ownerR=lag(prev_sale_ownerR);
lag_sale_accept=lag(prev_sale_accept);
lag_sale_ownocc=lag(prev_sale_ownocc);
lag_sale_hstd=lag(prev_sale_hstd);
lag_sale_owncat=lag(prev_sale_owncat);
lag_sale_aval=lag(prev_sale_aval);
lag_sale_units=lag(prev_sale_units);
lag_sale_ownocct=lag(prev_sale_ownocct);
lag_sale_prp=lag(prev_sale_prp);
lag_sale_stype=lag(prev_sale_stype);
lag_sale_lname1=lag(prev_sale_lastname1);
lag_sale_lname2=lag(prev_sale_lastname2);

lag2_sale_num=lag2(prev_sale_num);
lag2_sale_date=lag2(prev_sale_date);
lag2_sale_price=lag2(prev_sale_price);
lag2_sale_owner=lag2(prev_sale_owner);
lag2_sale_ownerR=lag2(prev_sale_ownerR);
lag2_sale_accept=lag2(prev_sale_accept);
lag2_sale_ownocc=lag2(prev_sale_ownocc);
lag2_sale_hstd=lag2(prev_sale_hstd);
lag2_sale_owncat=lag2(prev_sale_owncat);
lag2_sale_aval=lag2(prev_sale_aval);
lag2_sale_units=lag2(prev_sale_units);
lag2_sale_ownocct=lag2(prev_sale_ownocct);
lag2_sale_prp=lag2(prev_sale_prp);
lag2_sale_stype=lag2(prev_sale_stype);
lag2_sale_lname1=lag2(prev_sale_lastname1);
lag2_sale_lname2=lag2(prev_sale_lastname2);

lag3_sale_num=lag3(prev_sale_num);
lag3_sale_date=lag3(prev_sale_date);
lag3_sale_price=lag3(prev_sale_price);
lag3_sale_owner=lag3(prev_sale_owner);
lag3_sale_ownerR=lag3(prev_sale_ownerR);
lag3_sale_accept=lag3(prev_sale_accept);
lag3_sale_ownocc=lag3(prev_sale_ownocc);
lag3_sale_hstd=lag3(prev_sale_hstd);
lag3_sale_owncat=lag3(prev_sale_owncat);
lag3_sale_aval=lag3(prev_sale_aval);
lag3_sale_units=lag3(prev_sale_units);
lag3_sale_ownocct=lag3(prev_sale_ownocct);
lag3_sale_prp=lag3(prev_sale_prp);
lag3_sale_stype=lag3(prev_sale_stype);
lag3_sale_lname1=lag3(prev_sale_lastname1);
lag3_sale_lname2=lag3(prev_sale_lastname2);


if prev_sale_num = . and record_type in("Notice" "Cancellation" "Notice of Default" "Mediation Certificate") and lag_sale_num ne . and order ne 1 then do;
                                                prev_sale_date=lag_sale_date;
                                                prev_sale_price=lag_sale_price;
                                                prev_sale_owner=lag_sale_owner;
												prev_sale_ownerR=lag_sale_ownerR;
                                                prev_sale_accept=lag_sale_accept;
                                                prev_sale_ownocc=lag_sale_ownocc;
                                                prev_sale_hstd=lag_sale_hstd;
                                                prev_sale_num=lag_sale_num;
                                                prev_sale_owncat=lag_sale_owncat;
                                                prev_sale_aval=lag_sale_aval;
                                                prev_sale_units=lag_sale_units;
                                                prev_sale_ownocct=lag_sale_ownocct;
                                                prev_sale_prp=lag_sale_prp;
                                                prev_sale_stype=lag_sale_stype;
                                                prev_sale_lastname1=lag_sale_lname1;
                                                prev_sale_lastname2=lag_sale_lname2;
                                                                end;

if prev_sale_num = . and record_type  in("Notice" "Cancellation" "Notice of Default" "Mediation Certificate") and lag_sale_num = . and lag2_sale_num ne . and order not in(1 2) then do;
                                                prev_sale_date=lag2_sale_date;
                                                prev_sale_price=lag2_sale_price;
                                                prev_sale_owner=lag2_sale_owner;
												prev_sale_ownerR=lag2_sale_ownerR;
                                                prev_sale_accept=lag2_sale_accept;
                                                prev_sale_ownocc=lag2_sale_ownocc;
                                                prev_sale_hstd=lag2_sale_hstd;
                                                prev_sale_num=lag2_sale_num;
                                                prev_sale_owncat=lag2_sale_owncat;
                                                prev_sale_aval=lag2_sale_aval;
                                                prev_sale_units=lag2_sale_units;
                                                prev_sale_ownocct=lag2_sale_ownocct;
                                                prev_sale_prp=lag2_sale_prp;
                                                prev_sale_stype=lag2_sale_stype;
                                                prev_sale_lastname1=lag2_sale_lname1;
                                                prev_sale_lastname2=lag2_sale_lname2;
                                                                end;

if prev_sale_num = . and record_type in("Notice" "Cancellation" "Notice of Default" "Mediation Certificate") and lag_sale_num = . and lag2_sale_num = . and lag3_sale_num ne .
                                                                                            and order not in(1 2 3) then do;
                                                prev_sale_date=lag3_sale_date;
                                                prev_sale_price=lag3_sale_price;
                                                prev_sale_owner=lag3_sale_owner;
												prev_sale_ownerR=lag3_sale_ownerR;
                                                prev_sale_accept=lag3_sale_accept;
                                                prev_sale_ownocc=lag3_sale_ownocc;
                                                prev_sale_hstd=lag3_sale_hstd;
                                                prev_sale_num=lag3_sale_num;
                                                prev_sale_owncat=lag3_sale_owncat;
                                                prev_sale_aval=lag3_sale_aval;
                                                prev_sale_units=lag3_sale_units;
                                                prev_sale_ownocct=lag3_sale_ownocct;
                                                prev_sale_prp=lag3_sale_prp;
                                                prev_sale_stype=lag3_sale_stype;
                                                prev_sale_lastname1=lag3_sale_lname1;
                                                prev_sale_lastname2=lag3_sale_lname2;
                                                                end;

if prev_sale_num=. and record_type in("TD/Foreclosure Sale/REO" "TD/Other Sale" "Trustees Deed" "Foreclosure Sale/REO") and lag_sale_num ne . and order ne 1 then do;
                                                prev_sale_date=lag_sale_date;
                                                prev_sale_price=lag_sale_price;
                                                prev_sale_owner=lag_sale_owner;
												prev_sale_ownerR=lag_sale_ownerR;
                                                prev_sale_accept=lag_sale_accept;
                                                prev_sale_ownocc=lag_sale_ownocc;
                                                prev_sale_hstd=lag_sale_hstd;
                                                prev_sale_num=lag_sale_num;
                                                prev_sale_owncat=lag_sale_owncat;
                                                prev_sale_aval=lag_sale_aval;
                                                prev_sale_units=lag_sale_units;
                                                prev_sale_ownocct=lag_sale_ownocct;
                                                prev_sale_prp=lag_sale_prp;
                                                prev_sale_stype=lag_sale_stype;
                                                prev_sale_lastname1=lag_sale_lname1;
                                                prev_sale_lastname2=lag_sale_lname2;
                                                                end;


*fix previous sale owner for record preceeded by an unmatched trustees deed which we are now considering
change of ownership 2/3/11;
if record_type="Trustees Deed" and outcome_code=2 and post_sale_owner=" " then do;
			post_sale_owner=lasttdeed_grantee;
			post_sale_date=lasttdeed_date;
			post_sale_num=(prev_sale_num*1) + 0.5;
			post_sale_price=.u;
			post_sale_ownerR=lasttdeed_granteeR;
			post_sale_accept=.u;
			post_sale_ownocc=.u;
			post_sale_hstd=.u;
			post_sale_owncat=lasttdeed_owncat;
			post_sale_prp=prev_sale_prp;
			post_sale_aval=prev_sale_prp;
			post_sale_ownocct=prev_sale_ownocct;
		    post_sale_units=prev_sale_units;
			post_sale_lastname1=" ";
			post_sale_lastname2=" ";
			post_sale_stype=" ";

end;

prev_record_new=lag(record_type);
prev_new_owner=lag(post_sale_owner);
lag_outcome=lag(outcome_code);
lag_post_num=lag(post_sale_num);
lag_post_date=lag(post_sale_date);
lag_post_price=lag(post_sale_price);
lag_post_owner=lag(post_sale_owner);
lag_post_ownerR=lag(post_sale_ownerR);
lag_post_accept=lag(post_sale_accept);
lag_post_ownocc=lag(post_sale_ownocc);
lag_post_hstd=lag(post_sale_hstd);
lag_post_owncat=lag(post_sale_owncat);
lag_post_aval=lag(post_sale_aval);
lag_post_units=lag(post_sale_units);
lag_post_ownocct=lag(post_sale_ownocct);
lag_post_prp=lag(post_sale_prp);
lag_post_stype=lag(post_sale_stype);
lag_post_lname1=lag(post_sale_lastname1);
lag_post_lname2=lag(post_sale_lastname2);

if order=1 then do; prev_record_new=" ";prev_new_owner=" "; end;

if order ne 1 and prev_record_new="Trustees Deed" and lag_outcome=2 and prev_new_owner ne " " then do;

		prev_sale_num=lag_post_num;
		prev_sale_date=lag_post_date;
		prev_sale_price=lag_post_price;
		prev_sale_owner=lag_post_owner;
		prev_sale_ownerR=lag_post_ownerR;
		prev_sale_accept=lag_post_accept;
		prev_sale_ownocc=lag_post_ownocc;
		prev_sale_hstd=lag_post_hstd;
		prev_sale_owncat=lag_post_owncat;
		prev_sale_aval=lag_post_aval;
		prev_sale_units=lag_post_units;
		prev_sale_ownocct=lag_post_ownocct;
		prev_sale_prp=lag_post_prp;
		prev_sale_stype=lag_post_stype;
		prev_sale_lastname1=lag_post_lname1;
		prev_sale_lastname2=lag_post_lname2;

	end;

if prev_sale_num ne . and outcome_code in(5 6) and  post_sale_num= . then do;
												post_sale_num=prev_sale_num;
                                                post_sale_date=prev_sale_date;
                                                post_sale_price=prev_sale_price;
                                                post_sale_owner=prev_sale_owner;
												post_sale_ownerR=prev_sale_ownerR;
                                                post_sale_accept=prev_sale_accept;
                                                post_sale_ownocc=prev_sale_ownocc;
                                                post_sale_hstd=prev_sale_hstd;
                                                post_sale_num=prev_sale_num;
                                                post_sale_owncat=prev_sale_owncat;
                                                post_sale_aval=prev_sale_aval;
                                                post_sale_units=prev_sale_units;
                                                post_sale_ownocct=prev_sale_ownocct;
                                                post_sale_prp=prev_sale_prp;
                                                post_sale_stype=prev_sale_stype;
                                                post_sale_lastname1=prev_sale_lastname1;
                                                post_sale_lastname2=prev_sale_lastname2;
                                                                end;

if order ne 1 and record_type="Foreclosure Sale/REO" and num_notice=0 and post_sale_owncat in("040" "050" "120" "130")
and lag_outcome=2 then do; record_type="Other Sale"; outcome_code=.n; outcome_date=.n; ; end;
run;
%mend;
%order2;

proc freq data=step4;
title2 "step4";
tables outcome_code record_type post_sale_num/missprint;
format outcome_code outcome.;
run;
data step4a;
	set step4;

*assigning reo for bank & govt owned properties;

if post_sale_owncat ne " " and outcome_code not in(1 5 6 7 9) and post_sale_reo=. then post_sale_reo=0;


if post_sale_reo=0 then do;
if prev_sale_owncat in ('010' '020' '030' '110' '115' '') and post_sale_owncat in ('040' '050' '120' '130') and firsttdeed_date ne . then do;
                                                            record_type="TD/Foreclosure Sale/REO";
                                                            outcome_code=2;
                                                            outcome_date=firsttdeed_date;
                                                            post_sale_reo=1;                         end;
if prev_sale_owncat in ('010' '020' '030' '110' '115' '') and post_sale_owncat in ('040' '050' '120' '130') and firsttdeed_date= .
            and num_notice > 0 then do;
                                                            record_type="Foreclosure Sale/REO";
                                                            outcome_code=3;
                                                            outcome_date=filingdate;
                                                            post_sale_reo=1;                        end;
else if prev_sale_owncat in ('010' '020' '030' '110' '115') and post_sale_owncat in ('040' '050' '120' '130') and firsttdeed_date= .
            and post_sale_accept = '05' then do;
                                                            record_type="Foreclosure Sale/REO";
                                                            outcome_code=3;
                                                            outcome_date=filingdate;
                                                            post_sale_reo=1;            end;
else if prev_sale_owncat in ('010' '020' '030' '110' '115') and post_sale_owncat in ('040' '050' '120' '130') and firsttdeed_date= .
            and prev_sale_prp in ('10' '11' '12' '13') and post_sale_owner ne "National Gallery Of Art" then do;
                                                            record_type="Foreclosure Sale/REO";
                                                            outcome_code=3;
                                                            outcome_date=filingdate;
                                                            post_sale_reo=1;            end;
end;
*government purchase;
if post_sale_accept='06' and record_type="Foreclosure Sale/REO" and num_notice=0 then do; record_type="Other Sale";
                                            outcome_code=.n;
                                            outcome_date=.;
                                            end;
*buyer=seller;
if post_sale_accept='03' and num_notice=0 and record_type="Foreclosure Sale/REO" then do; record_type="Other Sale";
                                            outcome_code=.n;
                                            outcome_date=.;
                                            end;
if prev_sale_owner="Banneker Court Llc" and post_sale_owner="District Of Columbia" then do; record_type="Other Sale";
                                            outcome_code=.n;
                                            outcome_date=.;
                                            end;

*correcting record type for close to tdeed date sales "matches";
if firsttdeed_date ne . and record_type="Other Sale" and post_sale_reo=1 then do; record_type="TD/Foreclosure Sale/REO";
                            outcome_code=2;
                            outcome_date=firsttdeed_date; end;

**finish reo;
if outcome_code in (2 8) and post_sale_owncat in ('120' '130') then post_Sale_reo=1;
if outcome_code in (2 3 8) and post_sale_owncat=" " and post_sale_num ne . and post_sale_reo=. then post_sale_reo=.U;
if outcome_code in (1 4 5 6 7 9) then post_sale_reo=.;

 *dropping observations with no foreclosure notice/sale in owner/property episode;
if outcome_code=.n then delete;
if post_sale_num=1 and filingdate=.n then delete;

if record_type not in ("Trustees Deed"  "TD/Foreclosure Sale/REO" "TD/Other Sale") then do;
                                    firstdeed_grantee=" "; firsttdeed_granteeR=" "; firsttdeed_date=.n; firsttdeed_grantor=" ";
                                    lasttdeed_grantee=" "; lasttdeed_granteeR=" "; lasttdeed_date=.n; lasttdeed_grantor=" ";end;


if prev_sale_prp=" " then prev_sale_prp=ui_proptype;

keep ssl filingdate_R filingdate ui_instrument num_notice  year firstnotice_date &lastnoticelist. &firsttdeedlist. &lasttdeedlist. &lastcancellist.
    num_tdeed firstcancel_date  num_cancel num_sales outcome_date  outcome_code  post_sale_reo lag_sale_num lag2_sale_num
    &prevsalelist. &postsalelist. &lastNODlist. &lastmedlist. firstdefault_date firstmediate_date num_default num_mediate
record_type prev_record_type next_record_type end prev_record_days order;
run;



proc freq data=step4a;
title2 "step4a";
tables outcome_code order post_sale_reo post_sale_reo*record_type post_sale_Num prev_sale_prp num_default/missprint;
format outcome_code outcome.  ;
run;
/*check for records that should have a previous sale that do not;
proc print data=step4;
var ssl record_type outcome_code filingdate_r prev_sale_num order num_sales ;
where  record_type="Notice" and prev_sale_num=. and num_sales ne 0;
run;
*/
**joining sales master file again to get next sale after foreclosure;

data who_owns_R2;
	set who_owns_r;
rename filingdate=saledate;
run;

proc sql;
       create table Work.step5 as
       select step4a.*, sales.*
     from step4a left join who_owns_r2
            as sales on (step4a.ssl = sales.ssl)
 	
     having saledate gt filingdate_R
	;
     quit;
  run;
  proc sort data=step5;
  by ssl  saledate;
**sorting to removing additional sales if more than one after foreclosure;
proc sort data=step5 nodupkey out=step6;
by ssl order ;
run;
%macro step7;
data step7;
 set step6 (keep=saledate saleprice acceptcode hstd_code ownername_full owner_occ_sale sale_num ownercat ASSESS_VAL 
				 ssl order no_units no_ownocct ui_proptype ownername ownname2 saletype ownerR);

%let owner=ownername ownname2;
%let number=1 2 ;
%do i = 1 %to 2;
%let name=%scan(&owner.,&i.," ");
%let num=%scan(&number.,&i.," ");
    if ownercat in('010' '020' '030') then do;
    *Suffix and last;
        if scan(&name.,-1) in ("I" "II" "III" "Jr." "Jr" "JR" "Sr" "Sr." "SR") then do;
                sale_lastname&num.=(scan(&name.,-2,' '));
        end;

        else if scan(&name.,-2) in ("MC" "VON") then do;
                    sale_lastname&num.=scan(&name.,-2)||" "||scan(&name.,-1);
                    end;
        else do;
        if length(Scan(&name.,-1))>1 then sale_lastname&num.=scan(&name.,-1);
        else sale_lastname&num.=scan(&name.,-2);

        end;
        if index(upcase(&name.), "TRUSTEE")>0 then sale_lastname&num.=" ";
    end;
%end;

sale_lastname1=propcase(sale_lastname1);
sale_lastname2=propcase(sale_lastname2);


rename saledate=next_sale_date
saleprice=next_sale_price
acceptcode=next_sale_accept
hstd_code=next_sale_hstd
ownername_full=next_sale_owner
owner_occ_sale=next_sale_ownocc
sale_num=next_sale_num
ownercat=next_sale_owncat
assess_val=next_sale_aval
no_units=next_sale_units
no_ownocct=next_sale_ownocct
ui_proptype=next_sale_prp
saletype=next_sale_stype
sale_lastname1=next_sale_lastname1
sale_lastname2=next_sale_lastname2
ownerR=next_sale_ownerR;
run;
%mend step7;
%step7;
proc sort data=step7;
by ssl order;
proc sort data=step4a;
by ssl order;
data step8;
merge step4a (in=a ) step7  ;
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
merge step8 (in=a drop=lastnotice_granteeR firsttdeed_lastname lasttdeed_lastname lastcancel_granteeR lastcancel_lastname
					   lastnotice_owncat lastcancel_owncat ownername ownname2 lastdefault_granteeR lastmediate_granteeR
					   lastdefault_owncat lastmediate_owncat lastdefault_lastname lastmediate_lastname)
      parcel_base (in=b keep=ssl usecode ownerpt_extractdat_last)
      parcel_geo (in=c keep=ssl Anc2002 Casey_nbr2003 Casey_ta2003 City Cluster2000
                                     Cluster_tr2000 Eor Geo2000 GeoBlk2000 Psa2004 Ward2002 X_COORD Y_COORD
                                     Zip geo2010 geoblk2010 ward2012 anc2012 psa2012);
if a;
by ssl;

if b then pb_flag=1;
if c then pg_flag=1;
if num_notice gt 0 then firsttolast_days=lastnotice_date-firstnotice_date;


format next_sale_date MMDDYY10. next_sale_owncat $owncat. next_sale_accept $accept. next_sale_hstd $homestd. next_sale_ownocc YESNO.
       next_sale_prp $UIPRTYP38.  next_sale_stype $SALETYP.;

label
pb_flag="Observation is in Parcel_base"
pg_flag="Observation is in Parcel_geo"
firsttolast_days="Number of days between first and last notice of foreclosure"
num_notice ="Number of notices of foreclosure sale"
num_tdeed="Number of notices of trustees deed sale on same date"
firstnotice_date="Date of first notice of foreclosure"
lastnotice_date="Date of last notice of foreclosure"
lastnotice_grantee="Grantee - last notice of foreclosure"
lastnotice_grantor="Grantor - last notice of foreclosure"
lastnotice_multiplelots="Last notice of foreclosure sale applies to multiple lots"
lastnotice_xlot="Last notice of foreclosure original property lot (not reformatted)"
lastnotice_doc="Last notice of foreclosure document number"
lastnotice_lastname="Last name of grantee on last notice of foreclosure sale"
firsttdeed_date="Date of first trustee's deed notice"
firsttdeed_grantee="Grantee - first trustee's deed notice"
firsttdeed_granteeR="Grantee - first trustee's deed notice - Recoded"
firsttdeed_grantor="Grantor - first trustee's deed notice"
firsttdeed_multiplelots="First trustee's deed sale applies to multiple lots"
firsttdeed_xlot="First trustee's deed original property lot (not reformatted)"
firsttdeed_doc="First trustee's deed document number"
firsttdeed_owncat="Owner type of first trustee's deed grantee"
lasttdeed_date="Date of last trustee's deed notice"
lasttdeed_grantee="Grantee - last trustee's deed notice"
lasttdeed_granteeR="Grantee - last trustee's deed notice - Recoded"
lasttdeed_grantor="Grantor - last trustee's deed notice"
lasttdeed_multiplelots="Last trustee's deed sale applies to multiple lots"
lasttdeed_xlot="Last trustee's deed original property lot (not reformatted)"
lasttdeed_doc="Last trustee's deed document number"
lasttdeed_owncat="Owner type of last trustee's deed grantee"
prev_sale_date="Date of sale prior to notice"
prev_sale_price="Price of sale prior to notice"
prev_sale_accept="Acceptance code of sale prior to notice"
prev_sale_owner="Owner name prior to notice"
prev_sale_ownerR="Owner name prior to notice - Recoded"
prev_sale_hstd="Homestead flag of sale prior to notice"
prev_sale_ownocc="Owner-occupied sale prior to notice"
prev_sale_num="Number of sale prior to notice"
prev_sale_owncat="Owner type of sale prior to notice"
prev_sale_aval="Assessed value at sale prior to notice"
prev_sale_units="Number of available cooperative units of sale prior to notice"
prev_sale_ownocct="Number of occupied cooperative units of sale prior to notice"
prev_sale_prp="UI property type of sale prior to notice"
prev_sale_lastname1="Last Name of Owner 1 of sale prior to notice"
prev_sale_lastname2="Last Name of Owner 2 of sale prior to notice"
prev_sale_stype="Sale type of sale prior to notice"
outcome_date="Date of outcome"
outcome_code="Outcome code"
firstcancel_date="Date of first notice of cancellation"
lastcancel_date="Date of last notice of cancellation"
lastcancel_grantee="Grantee - last notice of cancellation"
lastcancel_grantor="Grantor - last notice of cancellation"
lastcancel_multiplelots="Last notice of cancellation applies to multiple lots"
lastcancel_xlot="Last notice of cancellation original property lot (not reformatted)"
lastcancel_doc="Last notice of cancellation document number"
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
next_sale_lastname1="Last Name of Owner 1 of sale after outcome"
next_sale_lastname2="Last Name of Owner 2 of sale after outcome"
next_sale_stype="Sale type of sale after outcome"
next_sale_ownerR="Owner name of sale after outcome - Recoded"
post_sale_date="Date of sale - owner after foreclosure episode"
post_sale_price="Price of sale- owner after foreclosure episode"
post_sale_accept="Acceptance code of sale - owner after foreclosure episode"
post_sale_owner="Owner name of sale - owner after foreclosure episode"
post_sale_hstd="Homestead flag of sale - owner after foreclosure episode"
post_sale_ownocc="Owner-occupied sale - owner after foreclosure episode"
post_sale_num="Number of sale - owner after foreclosure episode"
post_sale_owncat="Owner type of sale - owner after foreclosure episode"
post_sale_aval="Assessed value at sale - owner after foreclosure episode"
post_sale_units="Number of available cooperative units of sale - owner after fc episode"
post_sale_ownocct="Number of occupied cooperative units of sale - owner after fc episode"
post_sale_prp="UI property type of sale - owner after foreclosure episode"
post_sale_lastname1="Last Name of Owner 1 of sale - owner after foreclosure episode"
post_sale_lastname2="Last Name of Owner 2 of sale - owner after foreclosure episode"
post_sale_stype="Sale type of sale - owner after foreclosure episode"
post_sale_ownerR="Owner name of sale - owner after foreclosure episode - Recoded"
firstdefault_date="Date of first notice of default"  
firstmediate_date="Date of first mediation certificate"   
num_mediate="Number of mediation certificates"
num_default="Number of notices of default"
lastdefault_date="Date of last notice of default"        
lastdefault_doc="Last notice of default document number"         
lastdefault_grantee="Grantee - last notice of default"     
lastdefault_grantor="Grantor - last notice of default"     
lastdefault_multiplelots="Last notice of default applies to multiple lots"
lastdefault_xlot="Last notice of default original property lot (not reformatted)"    
lastmediate_date="Date of last mediation certificate"        
lastmediate_doc="Last mediation certificate document number"          
lastmediate_grantee="Grantee - last mediation certificate"      
lastmediate_grantor="Grantor - last mediation certificate"     
lastmediate_multiplelots="Last mediation certificate applies to multiple lots"
lastmediate_xlot="Last mediation certificate original property lot (not reformatted)"
;


lastnotice_grantor=upcase(lastnotice_grantor);

run;

proc sort data=step9;
by ssl order;
run;
data last_grantor (compress=no keep=lastnotice_grantor ownercat ssl order);
    set step9;
    by ssl order;

     length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
   retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
   array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
   array a_re{*}     re1-re&MaxExp;

   ** Load & parse regular expressions **;
  if _n_ = 1 then do;
    i = 1;
   do until ( eof );
      set RegExp end=eof;
      a_OwnerCat{i} = OwnerCat_re;
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
    if prxmatch( a_re{i}, upcase( lastnotice_grantor ) ) then do;
      OwnerCat = a_OwnerCat{i};
      match = 1;
    end;

    i = i + 1;

  end;

if match=0 then ownercat=" ";

  lastnotice_grantor = propcase( lastnotice_grantor );

  drop i match num_rexp regexp OwnerCat_re OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;


run;
proc sort data=last_grantor;
by ssl order;
proc sort data=step9;
by ssl order;
data step10;
merge step9 last_grantor (keep=ownercat ssl order rename=(ownercat=lastnotice_grantor_owncat));
by ssl order;

outcome_code2=.;
if outcome_code=1 then outcome_code2=1;
if outcome_code=2 and post_sale_reo=1 then outcome_code2=2;
if outcome_code=2 and post_sale_reo in (. .u 0) then outcome_code2=3;
if outcome_code=3 and post_sale_reo=1 then outcome_code2=4;
if outcome_code=3 and post_sale_reo in (. .u 0) then outcome_code2=5;
if outcome_code=3 and record_type="Pre 1998 Sale" then outcome_code2=6;
if outcome_code=4 then outcome_code2=7;
if outcome_code=5 then outcome_code2=8;
if outcome_code=6 then outcome_code2=9;
if outcome_code=7 then outcome_code2=10;
if outcome_code=8 then outcome_code2=11;
if outcome_code=9 then outcome_code2=12;

format outcome_code outcome. outcome_code2 outcomII. lastnotice_grantor_owncat
    ;
run;

proc freq data=step10;
tables outcome_code2 post_sale_num;
run;

data rod.&out (label="Foreclosure history, DC" drop=end lag_sale_num lag2_sale_num num_sales sortedby=ssl order);
    set step10;


%lender_history(lastnotice_grantor,lastnotice_grantorR);

if lastnotice_grantorR=" " then lastnotice_grantorR=lastnotice_grantor;


label outcome_code2="Detailed outcome code"
Year="Year of filing/sales date"
filingdate_R="Filing/Sales date - recoded missing"
order="Order of record within ssl"
post_sale_reo="Property is held by bank/mrtg company etc after sale/foreclosure"
prev_record_days="Days from original previous record within ssl"
prev_record_type="Original previous record type within ssl"
next_record_type="Following record type within ssl"
lastnotice_grantor_owncat="Owner type of last notice of foreclosure grantor"
lastnotice_grantorR="Grantor - last notice of foreclosure - Recoded"
;

run;

x "purge [DCDATA.ROD.DATA]&out.*";

%File_info( data=rod.&out, freqvars=outcome_code outcome_code2 post_sale_reo record_type )

run;


endrsubmit;
