/**************************************************************************
 Program:  Foreclosure_summary_tbl_qtr.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/11/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary table of foreclosure notices by ward.
               Through most recent quarter.

 Modifications: 
  06/16/08 L Hendey Added More Data
  09/30/08 PAT  Updated for Q2 2008. Revised tables.
  10/31/08 PAT  Updated for Q3 2008.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%let qtr_cutoff = 3;
%let qtr_label  = Q1-Q3;

%syslput qtr_cutoff=&qtr_cutoff;
%syslput qtr_label=&qtr_label;

rsubmit;

data all_years (compress=no);

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
  ;
    
  where 0 < qtr( FilingDate ) <= &qtr_cutoff;
  
  Instrument = propcase( Instrument );

run;


proc download status=no
  data=all_years 
  out=all_years;

run;

proc download status=no
  data=REALPROP.parcel_geo 
  out=REALPROP.parcel_geo; 

run;
proc download status=no
  data=REALPROP.square_geo 
  out=REALPROP.square_geo; 

run;
endrsubmit;

%fdate()

proc format;
  value $wards (notsorted)
    '1' = 'Ward 1'
    '2' = 'Ward 2'
    '3' = 'Ward 3'
    '4' = 'Ward 4'
    '5' = 'Ward 5'
    '6' = 'Ward 6'
    '7' = 'Ward 7'
    '8' = 'Ward 8'
    ' ' = 'Unknown';
  value $uiprtyp (notsorted)
    '10' - '19' = 'Residential properties'
    '20' - '29' = 'Commericial properties'
    '30' - '89' = 'Other properties'
    '99', '  '  = 'Unknown property type';

value  $uiinst (notsorted)
  'F1' = 'Notice of foreclosure sale'
  'F2' = 'Condominium foreclosure'  
  'F3' = 'Notice of foreclosure assessment' 
  'F4' = 'Notice of foreclosure cancellation'   
  'F5' = 'Trustee deed sale';

options nodate nonumber missing='-';

ods rtf file="&_dcdata_path\rod\prog\Foreclosure_summary_tbl_qtr.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=all_years format=comma12.0 noseps missing;
  class FilingDate UI_Instrument;
  class ui_proptype ward2002 / preloadfmt order=data;
  table
    /** Pages **/
    FilingDate="&qtr_label" * ui_proptype=' '
    ,
    /** Rows **/
    all='Total'
    UI_Instrument=' '
    ,
    /** Columns **/
    n='Number of Notices Issued' * (
      all='D.C.'
      ward2002='By Ward'
    )
    / box=_page_ printmiss condense;
  format FilingDate year4.0 ward2002 $wards. ui_proptype $uiprtyp. ui_instrument $uiinst. ;
  title1 "Notices of Foreclosure by Quarter/Year of Issue, Type of Notice, and Ward";
  title2 "Washington, D.C.";
  footnote1 height=9pt "Note:  Notices issued in &qtr_label only.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (&fdate).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

proc tabulate data=all_years format=comma12.0 noseps missing;
  class FilingDate UI_Instrument;
  class ward2002 / preloadfmt order=data;
  table
    /** Pages **/
    FilingDate="&qtr_label" 
    ,
    /** Rows **/
    all='Total'
    UI_Instrument=' '
    ,
    /** Columns **/
    n='Number of Notices Issued' * (
      all='D.C.'
      ward2002='By Ward'
    )
    / box=_page_ printmiss condense;
  format FilingDate year4.0 ward2002 $wards. ui_proptype $uiprtyp. ui_instrument $uiinst. ;
  title1 "Notices of Foreclosure by Quarter/Year of Issue, Type of Notice, and Ward";
  title2 "Washington, D.C.";
  footnote1 height=9pt "Note:  Notices issued in &qtr_label only.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (&fdate).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;


**** Report no. of parcels with notices ****;

data all_years1;
  set all_years;

 if UI_Instrument ="F1" and ui_proptype in ("10" "11" "12" "13" "19")  then notice_fs_res=1;
 if UI_Instrument ="F5" and ui_proptype in ("10" "11" "12" "13" "19")  then notice_td_res=1;
 if ui_proptype in ("10" "11" "12" "13" "19") then notice_all_res=1;
 if UI_Instrument ="F1" then notice_fs=1;
 if UI_Instrument ="F5" then notice_td=1;
 notice_all=1;
 
 notice_year=year(FilingDate);
 
 run;
 
 proc sort data=all_years1;
 by notice_year ssl;
 
 proc summary data=all_years1;
 by notice_year ssl;
 var notice_all notice_fs notice_td notice_all_res notice_fs_res notice_td_res;
 output out=all_years_ssl sum=;
 
 run;
 
 data all_years_ssl1;
  set all_years_ssl;
  
  if notice_all ge 1 then Snotice_all=1;
  if notice_fs ge 1 then Snotice_fs=1;
  if notice_td ge 1 then Snotice_td=1;
  if notice_all_res ge 1 then Snotice_all_res=1;
  if notice_fs_res ge 1 then Snotice_fs_res=1;
  if notice_td_res ge 1 then Snotice_td_res=1; 
  
  label Snotice_fs_res="Notice of Foreclosure Sale, Residential Parcels"
  	Snotice_td_res="Notice of Trustee Deed Sale, Residential Parcels"
  	Snotice_all_res="All Notices, Residential Parcels";
  
 run;
 
 proc sort data=all_years_ssl1;
 by ssl;
 proc sort data=realprop.parcel_geo;
 by ssl;
 data allyears_sslgeo;
 merge all_years_ssl1 (in=a) realprop.parcel_geo (keep=ssl ward2002);
 if a;
 by ssl;
 
 run;
 data square (drop=ward2002);
 	set allyears_sslgeo;
 where ward2002=" ";
 length square $8.;
 square=substr(ssl,1,8);
 run;
 data ssl;
 	set allyears_sslgeo;
 where ward2002 ne " ";
 length square $8.;
 square=substr(ssl,1,8);
 run;
 proc sort data=square;
 by square;
 proc sort data=realprop.square_geo;
 by square;
 data square_merge;
 merge square (in=a ) realprop.square_geo (keep=square ward2002);
 if a;
 by square;
 run;
 
 data allyears_geo;
 set ssl square_merge;
 run;
proc freq data=allyears_geo;
where Snotice_all=1;
tables notice_year;
run;
 
 proc sort data=allyears_geo ;
 by notice_year ward2002 ;
 run;
 
 proc format;
   value total
     1 = '\b TOTAL';
 run;
 
 ods rtf file="&_dcdata_path\rod\prog\Foreclosure_summary_tbl_qtr_ssl.rtf" style=Styles.Rtf_arial_9pt;
 
 ** Residential parcels, notice of foreclosure sale **;
 
 proc tabulate data=allyears_geo format=comma12.0 noseps missing;
   class Notice_year Snotice_fs_res ;
   class ward2002 / preloadfmt order=data;
   where Snotice_fs_res=1;
   table
      /** Rows **/
     Notice_year="\b &qtr_label" 
     Snotice_fs_res=' '
     ,
     /** Columns **/
     n='Number of Residential Parcels with Notices of Foreclosure Sale Issued' * (
       all='D.C.'
       ward2002=' '
     )
     / box=_page_ printmiss;
   format ward2002 $wards. Snotice_fs_res total.;
   title1 "Parcels with Notices of Foreclosure Sale by Quarter/Year of Issue and Ward";
   title2 "Washington, D.C.";
   footnote1 height=9pt "Note:  Notices issued in &qtr_label only.";
   footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (&fdate).";
   footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
 
run;

** Residential parcels, notice of trustee deed sale **;

proc tabulate data=allyears_geo format=comma12.0 noseps missing;
   class Notice_year Snotice_td_res ;
   class ward2002 / preloadfmt order=data;
   where Snotice_td_res=1;
   table
      /** Rows **/
     Notice_year="&qtr_label" 
     Snotice_td_res=' '
     ,
     /** Columns **/
     n='Number of Residential Parcels with Notices of Trustee Deed Sale Issued' * (
       all='D.C.'
       ward2002=' '
     )
     / box=_page_ printmiss;
   format ward2002 $wards. Snotice_td_res total.;
   title1 "Parcels with Notices of Trustee Deed Sale by Quarter/Year of Issue and Ward";
   title2 "Washington, D.C.";
   footnote1 height=9pt "Note:  Notices issued in &qtr_label only.";
   footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (&fdate).";
   footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
 
run;

ods rtf close;
