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
  07/29/09 LMH Added code to print list of records with square but 
  	       unmatched parcel to check in ROD detail.
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
  
  ** Combine files together **;
  
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
  
  ** Remove duplicate records **;

  proc sort data=all_files;
    by DocumentNo descending Verified descending FileDownloadDateTime;

  data all_files;
 
   set all_files;
   by DocumentNo descending Verified descending FileDownloadDateTime;
   
   if first.DocumentNo;
   
  run;
  
  ** Merge with geographies **;
  
  proc sql;
    create table _read_forecl (label="Property foreclosure notices, &year, DC") as
    select all_files.*, geo.*, base.ssl, base.ui_proptype
    	from all_files left join RealProp.Parcel_geo (drop=CJRTRACTBL) as geo on (all_files.ssl = geo.ssl)
    		       left join RealProp.Parcel_base as base on (all_files.ssl=base.ssl) 
    	   
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
    id=FilingDate Verified FileDownloadDateTime,
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
      where missing( X_COORD ) and not( missing( ward2002 ));
      id FilingDate DocumentNo;
      var Instrument ssl square lot xlot ward2002 MultipleLots Verified;
      title2 "**** UNMATCHED PARCELS (CHECK SSL!) ****";
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

