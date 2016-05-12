/**************************************************************************
 Program:  Foreclosure_summary_tbl_ann_1990_2007.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/11/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary table of foreclosure notices by ward.
               Annual.

 Modifications: CM & KP 2/1/2008
 
 Based on foreclosure_summary_tbl_ann.sas, Updated to include 1990-1999 and full year of 2007
 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

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
    /*Rod.Foreclosures_2000*/
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

options nodate nonumber missing='-';

ods rtf file="&_dcdata_path\rod\prog\Foreclosure_summary_tbl_ann.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=all_years format=comma12.0 noseps missing;
  where FilingDate < '31dec2007'd;
  class FilingDate UI_Instrument;
  class ward2002 / preloadfmt order=data;
  table
    /** Pages **/
    UI_Instrument=' '
    ,
    /** Rows **/
    all='D.C.'
    ward2002=' '
    ,
    /** Columns **/
    n='Number of Notices Issued' * (
    all='Total'
    FilingDate='By Year'
    )
    / /*box=_page_*/ printmiss;
  format FilingDate year4.0 ward2002 $wards.;
  title1 "Notices of Foreclosure by Type of Notice, Year of Issue, and Ward";
  title2 "Washington, D.C.";
  *footnote1 height=9pt "Note:  Notices issued during calendar year.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

