/**************************************************************************
 Program:  Forecl_ssl_sex.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/13/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Merge property sales and foreclosure notice data.
 Add gender classification for property owner.
 Merge of foreclosure and sales based on code written by Beata Bajaj.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

rsubmit;

%macro printssl( data= );
proc print data=&data;
  where ssl in ( '0028    2094', '0015    2177' );
  id ssl;
  by ssl;
  title2 "File = &data";
run;
title2;
%mend;

******************Step1. Foreclosure Notice File*;

*From the foreclosure files, select only the notices of foreclosure sale (ui_instrument = 'F1') filed between Jan 2005 and Dec 2007;

data foreclosures_0507 (compress=no);

	set /*rod.foreclosures_2005 rod.foreclosures_2006*/ rod.foreclosures_2007;

	where not( missing( ssl ) ) and ui_instrument = 'F1' and '01jan2005'd <= filingdate <= '31dec2007'd;
	
	drop instrument square lot booktype;

run;

proc sort data=foreclosures_0507;
	by ssl filingdate;
run;

*One notice per SSL*;

data firstnotice_0507;
	***set foreclosures_0507;
	merge 
	  foreclosures_0507 (in=inA)
  	  RealProp.parcel_base (keep=ssl premiseadd ui_proptype ownername ownname2 address1 address2 address3 hstd_code);
	by ssl;

	if inA and first.ssl;

      length owneraddress $ 40;

      if address2 = '' then owneraddress = address1;
      else owneraddress = address2;
      
      drop address1 address2;
      
run;

******************Step2. Property and Sales Files*;

data parcel_link_sale (compress=no);

/*
	merge 
	  RealProp.sales_master;
	by ssl;
*/	
	set RealProp.sales_master;

	if ui_proptype in ( '10', '11' ) and not( missing( saledate ) );
	
      length owneraddress $ 40;

      if address2 = '' then owneraddress = address1;
      else owneraddress = address2;
      
	keep ssl saledate saleprice ownername ownname2 owneraddress address3 market_sale owner_occ_sale hstd_code;
	
run;


******************Step3. Link first Foreclosure Notice to pre-dating Sales Records based on SSL, and Filing and Sales Dates*;

*We want to match only the sales prior to the foreclosure notice.  So, in addition to SSL, need to use
*SALEDATE and FILINGDATE as part of the match, to determine which sales record should be kept for each property.;

proc sql;
	create table firstnotice_link_predatingsales
	as select *, sum(filingdate,-saledate) as TimeLapsedSF
	from 
	  /*RealProp.sales_master (keep=ssl saledate saleprice ownername ownname2 market_sale owner_occ_sale) as s, */
	  parcel_link_sale as s,
	  firstnotice_0507 as f
	/** Where sales precede notice filing dates and property type is SF or condo **/
	where s.ssl = f.ssl and filingdate >= saledate;
quit;

/*
%File_info( data=firstnotice_link_predatingsales, contents=n, stats=, printobs=5, freqvars=ui_proptype owner_occ_sale )
%printssl( data=firstnotice_link_predatingsales )
*/

/*
proc print data=firstnotice_link_predatingsales;
  where missing( saledate );
run;
*/

*Calculate minimum time lapsed between sale and filing date (where minimum time indicates most recent sale before foreclosure notice);

proc sql;
	create table firstnotice_link_predatingsales2
	as select *, min (TimeLapsedSF) as MinTimeLapsedSF
	from firstnotice_link_predatingsales
	group by ssl, filingdate, documentno;
quit;

/*
%File_info( data=firstnotice_link_predatingsales2, contents=n, stats=, printobs=5, freqvars=ui_proptype owner_occ_sale )
%printssl( data=firstnotice_link_predatingsales2 )
*/

******************Step4. Create the final data set of first Foreclosure Notices with their most recent pre-dating Sales Record*;

*Retain only those Foreclosure-to-Sales matches where the most recent Sale pre-dates the Notice;

data notice_link_sale_w_own_occ notice_link_sale_no_own_occ (drop=owner_occ_sale);

	***set firstnotice_link_predatingsales2;
	
	merge 
	  firstnotice_0507 (in=inA)
	  firstnotice_link_predatingsales2 (in=inB);
	by ssl;
	
	** Save SF & condo parcels only **;
	if ui_proptype in ( '10', '11' );
	
	** Number of owners **;
	if OWNNAME2 = "" then Num_owners = 1;
	else Num_owners = 2;
	
	length Observation Year_Notice Year_Sale TimeIntSF TimeIntSFfmt 8.;

	observation = 1;

	if inA and ( not( inB ) or TimeLapsedSF = MinTimeLapsedSF );
	***if TimeLapsedSF = MinTimeLapsedSF;

	year_notice = year(filingdate);
	year_sale = year(saledate);

	TimeIntSF = TimeLapsedSF / 182.5;

	if timeintsf <= 1 then timeintsffmt = 1;
	else if 1 < timeintsf <= 2 then timeintsffmt = 2;
	else if 2 < timeintsf <= 3 then timeintsffmt = 3;
	else if 3 < timeintsf <= 4 then timeintsffmt = 4;
	else if 4 < timeintsf <= 5 then timeintsffmt = 5;
	else if 5 < timeintsf <= 6 then timeintsffmt = 6;
	else if 6 < timeintsf <= 7 then timeintsffmt = 7;
	else if 7 < timeintsf <= 8 then timeintsffmt = 8;
	else if 8 < timeintsf <= 9 then timeintsffmt = 9;
	else if 9 < timeintsf <= 10 then timeintsffmt = 10;
	else if 10 < timeintsf <= 11 then timeintsffmt = 11;
	else if 11 < timeintsf <= 12 then timeintsffmt = 12;
	else if 12 < timeintsf <= 13 then timeintsffmt = 13;
	else if 13 < timeintsf <= 14 then timeintsffmt = 14;
	else if 14 < timeintsf <= 15 then timeintsffmt = 15;
	else if 15 < timeintsf <= 16 then timeintsffmt = 16;
	else if 16 < timeintsf <= 17 then timeintsffmt = 17;
	else if 17 < timeintsf <= 18 then timeintsffmt = 18;
	else if 18 < timeintsf <= 19 then timeintsffmt = 19;
	else if 19 < timeintsf <= 20 then timeintsffmt = 20;
	else if 20 < timeintsf then timeintsffmt = 21;

   if not indexw( address3, 'DC' ) then owner_occ_sale = 0;

   ** Separate obs. with missing owner_occ_sale **;
   
   if missing( owner_occ_sale ) then output notice_link_sale_no_own_occ;
   else output notice_link_sale_w_own_occ;

	label
		year_sale = "Year of sale"
		year_notice = "Year of foreclosure notice"
		timelapsedsf = "Number of Days lapsed between date of Foreclosure Notice and preceding Property Sale"
		timeintsf = "Number of 6-month time intervals lapsed between date of Foreclosure Notice and preceding Property Sale"
		timeintsffmt = "Time lapsed between date of Foreclosure Notice and preceding Property Sale"
		;

  drop MinTimeLapsedSF;
  
run;

** Fill in missing owner_occ_sale **;

%DC_geocode(
  data=notice_link_sale_no_own_occ,
  out=premise_geo,
  staddr=premiseadd,
  id=ssl,
  ds_label=,
  keep_geo=,
  geo_match=N,
  block_match=N,
  listunmatched=N
)

%DC_geocode(
  data=notice_link_sale_no_own_occ,
  out=owneraddress_geo,
  staddr=owneraddress,
  id=ssl,
  ds_label=,
  keep_geo=,
  geo_match=N,
  block_match=N,
  listunmatched=N
)

** Merge standardized addresses & create owner-occ. sale flag **;

data notice_new_own_occ;

  merge
    notice_link_sale_no_own_occ
    premise_geo (keep=ssl premiseadd_std)
    owneraddress_geo (keep=ssl owneraddress_std);
  by ssl;

  length owner_occ_sale 3;

  if ( premiseadd_std = owneraddress_std or hstd_code in ( '1', '5' ) ) then
      owner_occ_sale = 1;
  else owner_occ_sale = 0;

  drop premiseadd_std owneraddress_std;

run;

** Recombine files **;

data notice_link_sale;

  set notice_new_own_occ notice_link_sale_w_own_occ;
  by ssl;
  
run;

%Dup_check(
  data=notice_link_sale,
  by=ssl,
  id=filingdate documentno saledate ownername grantee
)

/*
%printssl( data=notice_link_sale )
*/

run;

**** Classify properties by gender ****;

/** Macro Name_clean - Start Definition **/

%macro Name_clean( name );

  upcase( left( compress( &name, " ,-.'`/\" ) ) )

%mend Name_clean;

/** End Macro Definition **/

** Create lookup formats for female, male names **;

/** Macro Make_name_fmt - Start Definition **/

%macro Make_name_fmt( type );

  proc upload status=no
    infile="D:\DCData\Libraries\ROD\Prog\&type._names.txt"
    outfile="[dcdata.rod.prog]&type._names.txt";
  run;

  filename inf "[dcdata.rod.prog]&type._names.txt" lrecl=256;

  *options obs=200;

  data &type (compress=no);

    infile inf dsd missover;

    length name $ 80;

    input name;

    name = %name_clean( name );

    if length( name ) <= 1 then delete;

    if name = 'OF' then delete;

  run;

  filename inf clear;

  proc sort data=&type out=&type (compress=no) nodupkey;
    by name;

  %Data_to_format(
    FmtLib=work,
    FmtName=$&type,
    Data=&type,
    Value=name,
    Label='1',
    OtherLabel='0',
    Print=N,
    Contents=N
    )

%mend Make_name_fmt;

/** End Macro Definition **/

** Upload name lists and create formats **;

%Make_name_fmt( female )
%Make_name_fmt( male )

** Classify foreclosure notices by gender **;

%let MaxExp = 100;    %** Maximum number of regular expressions **;

data Forecl_ssl_sex;

  length u_grantee RegExp $ 500;

  retain re1-re&MaxExp num_rexp;

  ** Load & parse regular expressions **;

  array a_re{*} re1-re&MaxExp;
  
  infile datalines dsd eof=exit_loop;
  
  if _n_ = 1 then do;

    i = 1;

    do while ( 1 );
      input RegExp;
      put i= RegExp=;
      a_re{i} = prxparse( RegExp );
      if missing( a_re{i} ) then do;
        putlog "Error" regexp=;
        stop;
      end;
      i = i + 1;
    end;

    exit_loop:
    
    num_rexp = i - 1;
    put num_rexp= ;

  end;

  set notice_link_sale;

  u_grantee = upcase( grantee );

  ** Check for group owners (partnership, corporations, etc.) **;
  
  i = 1;
  is_group = 0;
  
  *put 'PRE LOOP: ' _n_ = i= num_rexp= is_group= ;

  do while ( i <= num_rexp and not is_group );
    *put _n_= i= u_grantee= is_group= ;
    if prxmatch( a_re{i}, u_grantee ) then do;
      is_group = 1;
      *put is_group= grantee= ;
    end;
    i = i + 1;
  end;
  
  ** Determine gender for individual owners **;
  
  if not( is_group ) and num_owners = 1 then do;
  
    ** Extract given name (assumes last name is listed first, skip one letter initials) **;

    length name $ 80;

    i = 2;
    name = "-";
    
    if %name_clean( scan( grantee, 1, ' ' ) ) in ( 'AKA' ) then i = i + 1;

    do until ( length( name ) > 1 or name = "" );

      name = %name_clean( scan( grantee, i, ' ' ) );
      
      i = i + 1;
    
    end;
    
    ** Gender **;

    length is_female is_male 3;

    is_female = 1 * put( name, $female. );
    is_male = 1 * put( name, $male. );
    
  end;

  ** Gender class var. **;
  
  if not is_group then do;
    if num_owners = 1 then do;
      if is_female and not is_male then gender_class = 1;
      else if is_male and not is_female then gender_class = 2;
      else gender_class = 3;
    end;
    else 
      gender_class = 4;
  end;
  else
    gender_class = 5;
  
  label
    gender_class = 'Ownership gender classification';
  
  drop i u_grantee RegExp re1-re&MaxExp num_rexp;

  datalines;
/\bL?\s*L\s*(C|P)\b/
/\bASS(O|0)C/
/\b(INC\b|INCORP)/
/\bLTD\b/
/\bCORP/
/\bPARTNERS/
/\bCOMPANY\b/
/\bTRUST\b/
/\bGROUP\b/
/\bINVEST/
/\bCONTRACT/
/\bBANK$/
/\bBANK OF\b/
/\bSAVINGS BANK\b/
/\bCOMMERCE BANK\b/
/\bMUTUAL BANK\b/
/\bNATIONAL BANK\b/
/\bCHURCH OF\b/
/\bDEVELOPMENT\b/
/\bMORTGAGE\b/
/\bREALTY\b/
/\bFINANCIAL\b/
/\bLIMITED\b/
/\bMANAGEMENT\b/
/\bESTATE OF\b/
/\bINTERNATIONAL\b/
/\bPROPERTIE?S\b/
/\bPLAZA\b/
/\bCENTER\b/
/[A-Z].* (CHURCH|CRCH|CH)\b/
/[A-Z].* SYNAGOG(UE|)[^A-Z].*/
/[A-Z].* TEMPLE[^A-Z].*/
/[A-Z].* CATHEDRAL[^A-Z].*/
/[A-Z].* CONGREGATION[^A-Z].*/
/[A-Z].* BAPTIST\b/
/[A-Z].* METHODIST/
/\bHOLDINGS S\s*A\b/
/^[\s0-9]+$/
;

run;

proc download status=no
  data=Forecl_ssl_sex 
  out=Rod.Forecl_ssl_sex;

run;

endrsubmit;

%File_info( data=Rod.Forecl_ssl_sex, printobs=5, freqvars=ui_proptype owner_occ_sale Num_owners gender_class )

proc freq data=Rod.Forecl_ssl_sex;
  tables year_sale * year_notice / missing nocum nopercent nocol norow;
run;

proc freq data=Rod.Forecl_ssl_sex;
  tables is_group * num_owners * is_female * is_male * gender_class / missing list nocum;
run;

signoff;
