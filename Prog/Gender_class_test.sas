/**************************************************************************
 Program:  Gender_class_test.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/12/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Test name lists to classify foreclosure notices by
gender.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )

** Start submitting commands to remote server **;

rsubmit;

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

%let MaxExp = 200;

data A;

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
  
  if not is_group then do;
  
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

proc freq data=A;
  tables is_group * is_female * is_male / missing list;
run;

proc sort data=A out=A1 nodupkey;
  by name is_group is_female is_male;
  
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
  where not is_female and not is_male and not is_group;
  var name is_female is_male grantee;
  title2 'Unknown names';
run;

proc print data=A noobs;
  where is_group;
  var is_group grantee;
  title2 'Group owners';
run;

** Export unknown names for classification **;

data A1X;

  set A1 (keep=name is_female is_male is_group grantee);

  where not is_female and not is_male and not is_group;

  name = propcase( name );

run;

proc download status=no
  inlib=work 
  outlib=work memtype=(data);
  select A1X;

run;

endrsubmit;

** End submitting commands to remote server **;

filename fexport "&_dcdata_path\ROD\Prog\Unknown_names.csv" lrecl=1000;

proc export data=A1X
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

run;

signoff;
