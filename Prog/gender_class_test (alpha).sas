/**************************************************************************
 Program:  Gender_class_test.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/07/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Test name lists to classify foreclosure notices by gender.

 Modifications:
**************************************************************************/

%include "[dcdata]Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

/** Macro Name_clean - Start Definition **/

%macro Name_clean( name );

  upcase( left( compress( &name, " ,-.'`/\" ) ) )

%mend Name_clean;

/** End Macro Definition **/

** Create lookup formats for female, male names **;

/** Macro Make_name_fmt - Start Definition **/

%macro Make_name_fmt( type );

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

%Make_name_fmt( female )
%Make_name_fmt( male )

** Classify foreclosure notices by gender **;

data A;

  set 
    Rod.Foreclosures_2001 (keep=grantee ui_instrument)
    Rod.Foreclosures_2002 (keep=grantee ui_instrument)
    Rod.Foreclosures_2003 (keep=grantee ui_instrument)
    Rod.Foreclosures_2004 (keep=grantee ui_instrument)
    Rod.Foreclosures_2005 (keep=grantee ui_instrument)
    Rod.Foreclosures_2006 (keep=grantee ui_instrument)
    Rod.Foreclosures_2007 (keep=grantee ui_instrument)
  ;

  where ui_instrument = 'F1';

  ** Given name (assumes last name is listed first) **;

  length name $ 80;

  i = 2;
  name = "-";

  do until ( length( name ) > 1 or name = "" );

    name = %name_clean( scan( grantee, i, ' ' ) );
    
    i = i + 1;
  
  end;

  ** Gender **;

  length is_female is_male 3;

  is_female = 1 * put( name, $female. );
  is_male = 1 * put( name, $male. );

  drop i;

run;

proc freq data=A;
  tables is_female * is_male / missing list;
run;

proc sort data=A out=A1 nodupkey;
  by name is_female is_male;
  
proc print data=A1 noobs;
  where is_female and not is_male;
  var name is_female is_male grantee;
  title2 'Female names';
run;

proc print data=A1 noobs;
  where not is_female and is_male;
  var name is_female is_male grantee;
  title2 'Male names';
run;

proc print data=A1 noobs;
  where is_female and is_male;
  var name is_female is_male grantee;
  title2 'Ambiguous names';
run;

proc print data=A1 noobs;
  where not is_female and not is_male;
  var name is_female is_male grantee;
  title2 'Unknown names';
run;

** Export unknown names for classification **;

data A1X;

  set A1 (keep=name is_female is_male grantee);

  where not is_female and not is_male;

  name = propcase( name );

run;

filename fexport "[dcdata.rod.prog]Unknown_names.csv" lrecl=1000;

proc export data=A1X
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;


