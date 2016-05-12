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

** Read Ken's analysis vars **;

filename fimport "C:\DCData\Libraries\DISB\Raw\2008.01.03 Data for Loan Analysis.csv" lrecl=2000;

proc import out=LoanAnalysis
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;

run;

%File_info( data=LoanAnalysis, freqvars=category )

proc sql noprint;
  create table Forecl_ssl_sex_tbl2 as
  select * from LoanAnalysis (drop=FilingDate) as LA left join Rod.Forecl_ssl_sex as FS
  on LA.ssl = FS.ssl;
quit;

%File_info( data=Forecl_ssl_sex_tbl2, freqvars=category )

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

proc tabulate data=Forecl_ssl_sex_tbl2 format=comma12.0 noseps missing;
  where gender_class in ( 1, 2 );
  class gender_class category;
  var total;
  table 
    /** Rows **/
    all='Total' 
    category='By category'
    ,
    /** Columns **/
    total='Properties with foreclosure notice' * 
    ( sum='Number' colpctsum='Percent' ) *
    gender_class=' '
  ;
  format gender_class gendercl. owner_occ_sale ownocc. TimeLapsedSF TimeLaps.;


run;
