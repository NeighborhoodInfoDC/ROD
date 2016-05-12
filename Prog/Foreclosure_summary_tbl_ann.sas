/**************************************************************************
 Program:  Foreclosure_summary_tbl_ann.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/11/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary table of foreclosure notices by ward.
               Annual.

 Modifications:	05/06/07 LH: added additional years of data.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

rsubmit;

data all_years_a (compress=no);

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
  ;
    
  *Instrument = propcase( Instrument );

run;

proc sort data=all_years_a;
  by ssl;

data all_years (compress=no);

  merge all_years_a (in=in1) RealProp.Parcel_base (keep=ssl ui_proptype);
  by ssl;
  
  if in1;
  
run;

proc freq data=all_years;
  tables ui_proptype;
run;

proc download status=no
  data=all_years 
  out=all_years;

run;

endrsubmit;

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

options nodate nonumber missing='-';

ods rtf file="&_dcdata_path\rod\prog\Foreclosure_summary_tbl_ann.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=all_years format=comma12.0 noseps missing;
  *where ui_proptype  =: '1';
  class FilingDate UI_Instrument;
  class ui_proptype ward2002 / preloadfmt order=data;
  table
    /** Pages **/
    UI_Instrument=' ' * ui_proptype=' '
    ,
    /** Rows **/
    all='D.C.\~Total'
    ward2002=' '
    ,
    /** Columns **/
    n='Number of Notices Issued by Year' * (
    all='Total'
    FilingDate=' '
    )
    / /*box=_page_*/ printmiss;
  format FilingDate year4.0 ward2002 $wards. ui_proptype $uiprtyp.;
  title1 "Notices of Foreclosure by Type of Notice, Year of Issue, and Ward";
  title2 "Washington, D.C.";
  footnote1 height=9pt "Note:  Notices issued during calendar year.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

