/**************************************************************************
 Program:  Foreclosure_sum_yr_tbl.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/04/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )

** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=ROD 
  outlib=ROD memtype=(data);
  select Foreclosures_sum_:;

run;

endrsubmit;

ods rtf file="D:\DCData\Libraries\ROD\Prog\Foreclosure_sum_yr_tbl.rtf" style=Styles.Rtf_arial_9pt;

title2 'SF Homes/Condos with Notice of Foreclosure Sale, 2000-2008';

proc tabulate data=Rod.Foreclosures_sum_city format=comma8.0 noseps missing;
  var forecl_ssl_sf_condo_2000-forecl_ssl_sf_condo_2008;
  class city;
  table 
    /** Rows **/
    city,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_sf_condo_2000='2000'
      forecl_ssl_sf_condo_2001='2001'
      forecl_ssl_sf_condo_2002='2002'
      forecl_ssl_sf_condo_2003='2003'
      forecl_ssl_sf_condo_2004='2004'
      forecl_ssl_sf_condo_2005='2005'
      forecl_ssl_sf_condo_2006='2006'
      forecl_ssl_sf_condo_2007='2007'
      forecl_ssl_sf_condo_2008='2008'
    )
  ;

run;


proc tabulate data=Rod.Foreclosures_sum_wd02 format=comma8.0 noseps missing;
  var forecl_ssl_sf_condo_2000-forecl_ssl_sf_condo_2008;
  class ward2002;
  table 
    /** Rows **/
    ward2002,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_sf_condo_2000='2000'
      forecl_ssl_sf_condo_2001='2001'
      forecl_ssl_sf_condo_2002='2002'
      forecl_ssl_sf_condo_2003='2003'
      forecl_ssl_sf_condo_2004='2004'
      forecl_ssl_sf_condo_2005='2005'
      forecl_ssl_sf_condo_2006='2006'
      forecl_ssl_sf_condo_2007='2007'
      forecl_ssl_sf_condo_2008='2008'
    )
  ;

run;

proc tabulate data=Rod.Foreclosures_sum_cltr00 format=comma8.0 noseps missing;
  var forecl_ssl_sf_condo_2000-forecl_ssl_sf_condo_2008;
  class cluster_tr2000;
  table 
    /** Rows **/
    cluster_tr2000,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_sf_condo_2000='2000'
      forecl_ssl_sf_condo_2001='2001'
      forecl_ssl_sf_condo_2002='2002'
      forecl_ssl_sf_condo_2003='2003'
      forecl_ssl_sf_condo_2004='2004'
      forecl_ssl_sf_condo_2005='2005'
      forecl_ssl_sf_condo_2006='2006'
      forecl_ssl_sf_condo_2007='2007'
      forecl_ssl_sf_condo_2008='2008'
    )
  ;
  format cluster_tr2000 $clus00s.;

run;



title2 'SF Homes/Condos with Trustee Deed Sale, 2000-2008';

proc tabulate data=Rod.Foreclosures_sum_city format=comma8.0 noseps missing;
  var trustee_ssl_sf_condo_2000-trustee_ssl_sf_condo_2008;
  class city;
  table 
    /** Rows **/
    city,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_sf_condo_2000='2000'
      trustee_ssl_sf_condo_2001='2001'
      trustee_ssl_sf_condo_2002='2002'
      trustee_ssl_sf_condo_2003='2003'
      trustee_ssl_sf_condo_2004='2004'
      trustee_ssl_sf_condo_2005='2005'
      trustee_ssl_sf_condo_2006='2006'
      trustee_ssl_sf_condo_2007='2007'
      trustee_ssl_sf_condo_2008='2008'
    )
  ;

run;


proc tabulate data=Rod.Foreclosures_sum_wd02 format=comma8.0 noseps missing;
  var trustee_ssl_sf_condo_2000-trustee_ssl_sf_condo_2008;
  class ward2002;
  table 
    /** Rows **/
    ward2002,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_sf_condo_2000='2000'
      trustee_ssl_sf_condo_2001='2001'
      trustee_ssl_sf_condo_2002='2002'
      trustee_ssl_sf_condo_2003='2003'
      trustee_ssl_sf_condo_2004='2004'
      trustee_ssl_sf_condo_2005='2005'
      trustee_ssl_sf_condo_2006='2006'
      trustee_ssl_sf_condo_2007='2007'
      trustee_ssl_sf_condo_2008='2008'
    )
  ;

run;

proc tabulate data=Rod.Foreclosures_sum_cltr00 format=comma8.0 noseps missing;
  var trustee_ssl_sf_condo_2000-trustee_ssl_sf_condo_2008;
  class cluster_tr2000;
  table 
    /** Rows **/
    cluster_tr2000,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_sf_condo_2000='2000'
      trustee_ssl_sf_condo_2001='2001'
      trustee_ssl_sf_condo_2002='2002'
      trustee_ssl_sf_condo_2003='2003'
      trustee_ssl_sf_condo_2004='2004'
      trustee_ssl_sf_condo_2005='2005'
      trustee_ssl_sf_condo_2006='2006'
      trustee_ssl_sf_condo_2007='2007'
      trustee_ssl_sf_condo_2008='2008'
    )
  ;
  format cluster_tr2000 $clus00s.;
  
run;

title2 'SF Homes/Condos with Notice of Foreclosure Sale per 1,000, 2000-2008';

proc tabulate data=Rod.Foreclosures_sum_city format=comma8.0 noseps missing;
  var forecl_ssl_1kpcl_sf_condo_2000-forecl_ssl_1kpcl_sf_condo_2008;
  class city;
  table 
    /** Rows **/
    city,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_1kpcl_sf_condo_2000='2000'
      forecl_ssl_1kpcl_sf_condo_2001='2001'
      forecl_ssl_1kpcl_sf_condo_2002='2002'
      forecl_ssl_1kpcl_sf_condo_2003='2003'
      forecl_ssl_1kpcl_sf_condo_2004='2004'
      forecl_ssl_1kpcl_sf_condo_2005='2005'
      forecl_ssl_1kpcl_sf_condo_2006='2006'
      forecl_ssl_1kpcl_sf_condo_2007='2007'
      forecl_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;

run;


proc tabulate data=Rod.Foreclosures_sum_wd02 format=comma8.0 noseps missing;
  var forecl_ssl_1kpcl_sf_condo_2000-forecl_ssl_1kpcl_sf_condo_2008;
  class ward2002;
  table 
    /** Rows **/
    ward2002,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_1kpcl_sf_condo_2000='2000'
      forecl_ssl_1kpcl_sf_condo_2001='2001'
      forecl_ssl_1kpcl_sf_condo_2002='2002'
      forecl_ssl_1kpcl_sf_condo_2003='2003'
      forecl_ssl_1kpcl_sf_condo_2004='2004'
      forecl_ssl_1kpcl_sf_condo_2005='2005'
      forecl_ssl_1kpcl_sf_condo_2006='2006'
      forecl_ssl_1kpcl_sf_condo_2007='2007'
      forecl_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;

run;

proc tabulate data=Rod.Foreclosures_sum_cltr00 format=comma8.0 noseps missing;
  var forecl_ssl_1kpcl_sf_condo_2000-forecl_ssl_1kpcl_sf_condo_2008;
  class cluster_tr2000;
  table 
    /** Rows **/
    cluster_tr2000,
    /** Columns **/
    sum=' ' * (
      forecl_ssl_1kpcl_sf_condo_2000='2000'
      forecl_ssl_1kpcl_sf_condo_2001='2001'
      forecl_ssl_1kpcl_sf_condo_2002='2002'
      forecl_ssl_1kpcl_sf_condo_2003='2003'
      forecl_ssl_1kpcl_sf_condo_2004='2004'
      forecl_ssl_1kpcl_sf_condo_2005='2005'
      forecl_ssl_1kpcl_sf_condo_2006='2006'
      forecl_ssl_1kpcl_sf_condo_2007='2007'
      forecl_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;
  format cluster_tr2000 $clus00s.;

run;



title2 'SF Homes/Condos with Trustee Deed Sale per 1,000, 2000-2008';

proc tabulate data=Rod.Foreclosures_sum_city format=comma8.0 noseps missing;
  var trustee_ssl_1kpcl_sf_condo_2000-trustee_ssl_1kpcl_sf_condo_2008;
  class city;
  table 
    /** Rows **/
    city,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_1kpcl_sf_condo_2000='2000'
      trustee_ssl_1kpcl_sf_condo_2001='2001'
      trustee_ssl_1kpcl_sf_condo_2002='2002'
      trustee_ssl_1kpcl_sf_condo_2003='2003'
      trustee_ssl_1kpcl_sf_condo_2004='2004'
      trustee_ssl_1kpcl_sf_condo_2005='2005'
      trustee_ssl_1kpcl_sf_condo_2006='2006'
      trustee_ssl_1kpcl_sf_condo_2007='2007'
      trustee_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;

run;


proc tabulate data=Rod.Foreclosures_sum_wd02 format=comma8.0 noseps missing;
  var trustee_ssl_1kpcl_sf_condo_2000-trustee_ssl_1kpcl_sf_condo_2008;
  class ward2002;
  table 
    /** Rows **/
    ward2002,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_1kpcl_sf_condo_2000='2000'
      trustee_ssl_1kpcl_sf_condo_2001='2001'
      trustee_ssl_1kpcl_sf_condo_2002='2002'
      trustee_ssl_1kpcl_sf_condo_2003='2003'
      trustee_ssl_1kpcl_sf_condo_2004='2004'
      trustee_ssl_1kpcl_sf_condo_2005='2005'
      trustee_ssl_1kpcl_sf_condo_2006='2006'
      trustee_ssl_1kpcl_sf_condo_2007='2007'
      trustee_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;

run;

proc tabulate data=Rod.Foreclosures_sum_cltr00 format=comma8.0 noseps missing;
  var trustee_ssl_1kpcl_sf_condo_2000-trustee_ssl_1kpcl_sf_condo_2008;
  class cluster_tr2000;
  table 
    /** Rows **/
    cluster_tr2000,
    /** Columns **/
    sum=' ' * (
      trustee_ssl_1kpcl_sf_condo_2000='2000'
      trustee_ssl_1kpcl_sf_condo_2001='2001'
      trustee_ssl_1kpcl_sf_condo_2002='2002'
      trustee_ssl_1kpcl_sf_condo_2003='2003'
      trustee_ssl_1kpcl_sf_condo_2004='2004'
      trustee_ssl_1kpcl_sf_condo_2005='2005'
      trustee_ssl_1kpcl_sf_condo_2006='2006'
      trustee_ssl_1kpcl_sf_condo_2007='2007'
      trustee_ssl_1kpcl_sf_condo_2008='2008'
    )
  ;
  format cluster_tr2000 $clus00s.;
  
run;

ods rtf close;

signoff;
