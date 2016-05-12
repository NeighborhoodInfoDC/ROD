/**************************************************************************
 Program:  Forecl_ssl_sex_tbl.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/15/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Tables for foreclosure by sex analysis.

 Modifications:
**************************************************************************/

***%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

proc format;
  value gendercl
    1 = 'Women-owned'
    2 = 'Men-owned'
    3 = 'Undet. individual'
    4 = 'Joint ownership'
    5 = 'Institution';
  value ownocc (notsorted)
    1 = 'Owner-occupied'
    0 = 'Absentee owner';
  value TimeLaps (notsorted)
    0 -< 365 = '< 1'
    365 -< 912.5 = '1 - 2.5'
    912.5 -< 1825 = '2.5 - 5'
    1825 -< 3650 = '5 - 10'
    3650 - high, . = '10+';
  value $homestd (notsorted)
    '1' = 'Owner-occ. exemption'
    '5' = 'Senior citizen exemption'
    other = 'No exemption';

proc freq data=Rod.Forecl_ssl_sex;
  where owner_occ_sale = 1;
  tables owner_occ_sale * hstd_code / missing list;
  format owner_occ_sale ownocc. ;
run;

proc tabulate data=Rod.Forecl_ssl_sex format=comma12.0 noseps missing;
  where gender_class in ( 1, 2 );
  class gender_class ui_proptype ward2002 cluster_tr2000 ;
  class owner_occ_sale TimeLapsedSF hstd_code / preloadfmt order=data;
  var total;
  table 
    /** Rows **/
    all='Total' 
    ui_proptype='By property type'
    owner_occ_sale='By occupancy'
    hstd_code='By homestead exemp.'
    ,
    /** Columns **/
    total='Properties with foreclosure notice' * 
    ( sum='Number' colpctsum='Percent' ) *
    gender_class=' '
  ;
  table 
    /** Rows **/
    all='Total' 
    TimeLapsedSF='By time in home (years)'
    ,
    /** Columns **/
    total='Properties with foreclosure notice' * 
    ( sum='Number' colpctsum='Percent' ) *
    gender_class=' '
  ;
  table 
    /** Rows **/
    all='Total' 
    ward2002='By ward'
    ,
    /** Columns **/
    total='Properties with foreclosure notice' * 
    ( sum='Number' colpctsum='Percent' ) *
    gender_class=' '
  ;
  table 
    /** Rows **/
    all='Total' 
    cluster_tr2000='By neighborhood cluster'
    ,
    /** Columns **/
    total='Properties with foreclosure notice' * 
    ( sum='Number' colpctsum='Percent' ) *
    gender_class=' '
  ;
  format gender_class gendercl. owner_occ_sale ownocc. TimeLapsedSF TimeLaps.;


run;
