/**************************************************************************
 Program:  Read_foreclosures.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read multiple CSV files containing foreclosure data.

 Modifications:
  06/11/07 PAT Merge with Parcel_geo to add geographies for SSLs.
  11/13/07 PAT Upload file to Alpha before merging with Parcel_geo.
               Added finalize=, revisions= parameters.
  05/06/08 LMH Added code to merge in RealProp.Square_geo & Parcel_base 
  	       for proptype.
  06/30/08 LMH Added code for labeling data (by month). 
  09/24/08 PAT Added ui_proptype to freq vars.
               Finalize=N does not replace existing data set.
  10/31/08 PAT Strip invalid characters from SSL.
  11/24/08 PAT Remove duplicate records with same document no.
               %Read_one_foreclosure() now needs YEAR= parameter.
               Removed MONTH= parameter.
               Added summary table of no. of docs. at end.
  07/29/09 LH Added code to print list of records with square but 
  	       		unmatched parcel to check in ROD detail.
  08/06/09 LH Added code to run read_ssl_update_file macro and merge on update.
  01/07/10 LH  Macro added for document numbers that can be duplicates.
**************************************************************************/

/** Macro Read_foreclosures - Start Definition **/

%macro Read_foreclosures( files=, year=, month=, finalize=N, revisions=New file. );


  %let finalize = %upcase( &finalize );

  %if &finalize = Y %then %do;
    %note_mput( macro=Read_foreclosures, msg=Finalize=&finalize - Rod.Foreclosures_&year will be replaced. )
    %let out = Rod.Foreclosures_&year;
    %let out_nolib = Foreclosures_&year;
  %end;
  %else %do;
    %warn_mput( macro=Read_foreclosures, msg=Finalize=&finalize - Rod.Foreclosures_&year will NOT be replaced. )
    %let out = Foreclosures_&year;
    %let out_nolib = Foreclosures_&year;
  %end;

  %syslput year=&year;
  %syslput out=&out;
  %syslput out_nolib=&out_nolib;
  %syslput finalize=&finalize;
  %syslput revisions=&revisions;
  %syslput month=&month;

  ** Read individual files **;

  %let i = 1;
  %let f = %scan( &files, &i );
  
  %do %while ( &f ~= );
  
    %Read_one_foreclosure_file( file=&f, year=&year )
    
    %let i = %eval( &i + 1 );
    %let f = %scan( &files, &i );
  
  %end;
  
  ** Read ssl update file **;
  
  %Read_ssl_update_file;
  
  ** Read Coop Units File **;
  
  %read_coop_units_file;
  
  ** Combine raw files together **;
  
  data all_files (compress=no);
  
    set &files;
    
    ** Strip invalid characters from SSL **;
    
    ssl = translate( ssl, ' ', '`' );
    
    ** Delete docs. with invalid numbers **;
    
    if length( DocumentNo ) < 10 then do;
      %warn_put( macro=Read_foreclosures, 
                 msg="Invalid doc. no.  Record will be deleted: " DocumentNo= Verified= FilingDate= Instrument= ssl= Grantor= Grantee= )
      delete;
    end;
    
  run;
  
  ** Start submitting commands to remote server **;

  rsubmit;
  
  ** Upload data to Alpha **;
  
  proc upload status=no
    data=all_files 
    out=all_files (compress=no);

  run;
  
  proc upload status=no
    data=ssl_update
    out=ssl_update (compress=no);
  run;
  
  proc upload status=no
      data=coop_units
      out=coop_units (compress=no);
  run;
  
  ** Remove duplicate records **;

 
  proc sort data=all_files  ;
    by DocumentNo descending Verified descending FileDownloadDateTime ;

  data all_files (rename=(ssl=SSL_Raw multiplelots=MultipleLots_Raw)) ;
 
   set all_files;
   by DocumentNo descending Verified descending FileDownloadDateTime ;
   
   if DocumentNo in (&doc_list.) or first.DocumentNo ;

   
  run;
  
  ** Merge SSL update and Coop Units into records **;
  
  proc sort data=all_files;
    by DocumentNo;
    
  proc sort data=ssl_update;
    by DocumentNo;
   
  proc sort data=coop_units;
    by DocumentNo;
    
  data all_files_fix;
  merge all_files (in=a) 
        ssl_update (keep=ssl documentno MultipleLots update_notes ssl_update_flag update_checked)
        coop_units (keep=documentno unitno_coop update_coop update_coop_notes); *assumes not finding multiple lots in coop_units;
  if a;
  by DocumentNo;
  
  run;

  data all_files_fix2;
  	set all_files_fix;

  if ssl=" " then ssl=ssl_raw; 
  
  if missing ( MultipleLots ) then MultipleLots=MultipleLots_raw; 
  
  label 
  ssl_raw="SSL (square/suffix/lot) Identified in Raw Data"
  multiplelots_raw="Multiple Lots Identified in Raw Data";
  
  run;
  
  ** Merge with geographies **;
  
  proc sql;
    create table _read_forecl (label="Property foreclosure notices, &year, DC") as
    select all_files_fix2.*, geo.*, base.ssl, base.ui_proptype
    	from all_files_fix2 left join RealProp.Parcel_geo (drop=CJRTRACTBL) as geo on (all_files_fix2.ssl = geo.ssl)
    		           left join RealProp.Parcel_base as base on (all_files_fix2.ssl=base.ssl) 
    	   
    order by FilingDate, DocumentNo; 
  quit;
  run;
  
  ** Separate into Files with and w/o SSL **;
  
  proc sql;
    create table _read_forecl_a (label="Property foreclosure notices No SSL, &year, DC") as
    select *
    	from _read_forecl
    	   where ward2002 eq " ";
  quit;
  run;
  
  proc sql;
    create table _read_forecl_b (label="Property foreclosure notices SSL, &year, DC") as
    select *
    	from _read_forecl
    	   where ward2002 ne " ";
  quit;
  run;
  
   
  ** Merge in Square geo **;
  proc sql;
      create table _read_forecl_c (label="Property foreclosure notices Square, &year, DC") as
      select *
      	from _read_forecl_a (drop= Anc2002 Casey_nbr2003 Casey_ta2003 City Cluster2000
      	Cluster_tr2000 Eor Psa2004 Ward2002 Zip Geo2000 GeoBlk2000) as a 
      	left join RealProp.Square_geo (drop=CJRTRACTBL) as geo
      		on (a.square = geo.square)
      order by FilingDate, DocumentNo;
    quit;
  run;
  
  ** Merge all back together **;
   
  data &out (label="Property foreclosure notices, &year, DC");
       set _read_forecl_b _read_forecl_c;
   
  run;
 
  proc sort data=&out;
  by FilingDate DocumentNo;
  run;
  
  x "purge [DCDATA.ROD.DATA]&out_nolib..*";
  
  ** Check for duplicate documents **;

  title2 "**** DUPLICATE DOCUMENTS IN DATA SET ****";

  %Dup_check(
    data=&out,
    by=DocumentNo Instrument,
    id=FilingDate Verified FileDownloadDateTime SSL SSL_RAW,
    out=_dup_check,
    listdups=Y,
    count=dup_check_count,
    quiet=N,
    debug=N
  )
  
  title2;
  
  ** Print documents that did not match with parcel file **;
  
  proc print data=&out n='Total unmatched = ';
    where missing( ward2002 );
    id FilingDate DocumentNo;
    var Instrument ssl square lot xlot;
    title2 "**** UNMATCHED PARCELS (MISSING GEOGRAPHY) ****";
  run;
    
  ** Print documents that did match with square file but not with parcel file**;
    
    proc print data=&out n='Total to check = ';
      where missing( X_COORD ) and not( missing( ward2002 )) and missing ( update_checked );
      id FilingDate DocumentNo;
      var Instrument ssl square lot xlot ward2002 MultipleLots Verified update_checked;
      title2 "**** UNMATCHED PARCELS (CHECK SSL!) ****";
  run;
  title2;
  
  
    ** Print documents that are co-ops to check notice for unit or building**;
      
      proc print data=&out n='Total to check = ';
        where ui_proptype = '12' and missing ( update_coop );
        id FilingDate DocumentNo;
        var Instrument ssl ui_proptype ward2002 MultipleLots Verified update_coop ;
        title2 "**** CO-OP (CHECK FOR UNITS!) ****";
    run;
  title2;
  
  ** Basic file info **;

  %File_info( data=&out, printobs=5, freqvars=Verified Instrument UI_Instrument BookType MultipleLots ui_proptype ward2002 )

  proc tabulate data=&out format=comma15.0 noseps missing;
    class FilingDate Verified UI_Instrument;
    table 
      /** Pages **/
      UI_Instrument=' ',
      /** Rows **/
      all='Total' FilingDate='Filing date (by month)',
      /** Columns **/
      n='Number of notices' * ( all='Total' Verified='Verified?' )
      / condense;
    format FilingDate yymmd7.; 

  run;

  %if &finalize = Y %then %do;
  
    ** Register metadata **;
    
    %Dc_update_meta_file(
      ds_lib=Rod,
      ds_name=&out_nolib,
      creator_process=Foreclosures_&year..sas,
      restrictions=None,
      revisions=%str(&revisions)
    )
    
    run;
    
  %end;

  endrsubmit;

  ** End submitting commands to remote server **;

%mend Read_foreclosures;

/** End Macro Definition **/

