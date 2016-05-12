/**************************************************************************
 Program:  Prop_w_notice_tbl_2012_q3.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Properties w/foreclosure notice issued by type by year/qtr
 
 2012 Q3

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%let last_qtr = 3;
%let last_year = 2012;
%let data = Rod.Foreclosures_all_years;
%let end_date = '01nov2012'd;                   /** Used end of Oct here **/
%let path = &_dcdata_path\Rod\Prog\Quarterly;

** Annual totals **;

proc summary data=&data nway;
  where ui_instrument = 'F1' and ui_proptype in ( '10', '11', '12', '13' ) and filingdate < &end_date;
  class filingdate ssl;
  id ui_proptype;
  format filingdate year4.;
  output out=Prop_w_notice_year ;
run;

** Quarter totals **;

proc summary data=&data nway;
  where ui_instrument = 'F1' and ui_proptype in ( '10', '11', '12', '13' ) and filingdate < &end_date and
  1 <= qtr( filingdate ) <= &last_qtr.;
  class filingdate ssl;
  id ui_proptype;
  format filingdate year4.;
  output out=Prop_w_notice_qtr ;
run;

proc print data=Prop_w_notice_qtr (obs=100);
run;

proc format;
  value $prop
    '10' = 'Single-family homes'
    '11' = 'Condominium units'
    '12', '13' = 'Multifamily (Coops/Rental)';
run;

%fdate()

ods rtf file="&path\Prop_w_notice_&last_year._q&last_qtr..rtf" style=Styles.Rtf_arial_9pt;
ods html body="&path\Prop_w_notice_&last_year._q&last_qtr..html" style=Minimal;

options nodate nonumber;

proc tabulate data=Prop_w_notice_year format=comma10.0 noseps missing;
  class ui_proptype filingdate;
  table 
    /** Rows **/
    filingdate=' ',
    /** Columns **/
    ( n='Properties Issued a Notice of Foreclosure Sale' ) * ui_proptype=' '
    / box='Annual';
  format ui_proptype $prop. filingdate year4.;
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

proc tabulate data=Prop_w_notice_qtr format=comma10.0 noseps missing;
  class ui_proptype filingdate;
  table 
    /** Rows **/
    filingdate=' ',
    /** Columns **/
    ( n='Properties Issued a Notice of Foreclosure Sale' ) * ui_proptype=' '
    / box="First &last_qtr. Quarters";
  format ui_proptype $prop. filingdate year4.;

run;

ods _all_ close;
ods listing;

