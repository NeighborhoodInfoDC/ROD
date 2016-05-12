/**************************************************************************
 Program:  Foreclosure_summary_tbl.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/11/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary table of foreclosure notices by ward.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

%let date_cutoff = '01apr2007'd;

data all_years (compress=no);

  set 
    Rod.Foreclosures_2005
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007;
    
  where FilingDate < &date_cutoff;
  
  Instrument = propcase( Instrument );

run;

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

ods rtf file="&_dcdata_path\rod\prog\Foreclosure_summary_tbl.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=all_years format=comma12.0 noseps missing;
  class FilingDate Instrument;
  class ward2002 / preloadfmt order=data;
  table
    /** Pages **/
    FilingDate=' '
    ,
    /** Rows **/
    all='Total'
    Instrument=' '
    ,
    /** Columns **/
    n='Number of Notices Issued' * (
      all='D.C.'
      ward2002='By Ward'
    )
    / box=_page_ printmiss;
  format FilingDate year4.0 ward2002 $wards.;
  title1 "Notices of Foreclosure by Year of Issue, Type of Notice, and Ward";
  title2 "Washington, D.C.";
  footnote1 height=9pt "Note:  Data for 2007 are through 1st quarter only.";
  footnote2 height=9pt "Source:  D.C. Recorder of Deeds public records tabulated by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org).";
  footnote3 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

run;

ods rtf close;

