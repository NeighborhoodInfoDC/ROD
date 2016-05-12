/**************************************************************************
 Program:  Read_one_foreclosure_file.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/15/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read foreclosure data from a CSV file.

 Modifications: 
   05/02/08 L Hendey - Added code to loop if data is not on every line.
   06/16/08 L Hendey - Compress Square for '-/'
   11/23/08 PAT  Added FileDownloadDateTime (date/time of CSV file).
   11/24/08 PAT  Added Year to Raw file folder path.
**************************************************************************/

/** Macro Read_one_foreclosure_file - Start Definition **/

%macro Read_one_foreclosure_file( file=, year= );

  %Get_file_date( &_dcdata_path\ROD\raw\&year\&file..csv )

  filename inf  "&_dcdata_path\ROD\raw\&year\&file..csv" lrecl=1000;
  
  ** Determine whether verified or unverified data **;
  
  data _null_;
  
    infile inf dsd stopover firstobs=1 obs=1;
    
    length buff $ 1000;
    
    input buff;
    
    if indexw( upcase( buff ), "UNVERIFIED" ) then 
      call symput( '_fcl_verified', '0' );
    else
      call symput( '_fcl_verified', '1' );
      
  run;  

  ** Read foreclosure notice records from CSV file **;

  data &file (compress=no);
  
    retain FileDownloadDateTime &filedatetime Verified &_fcl_verified;

    infile inf dsd stopover firstobs=7;

    input
      FilingDate :mmddyy10. @;
      
    if missing( FilingDate ) then stop;
    
    input
      _drop1 $ _drop2 $ _drop3 $ _drop4 $ _drop5 $
      _dropBookType :$10.
      Instrument :$40.
      DocumentNo :$10.
      Grantor :$80.
      Grantee :$80.
      _drop6 $
      Square :$8.
      xLot :$16.
    ;
    
    ** Recoded vars **;
    
    %UI_instrument()
    
    %BookType()
    
    ** Reformat grantor and grantee names **;
    
    Grantor = propcase( Grantor );
    Grantee = propcase( Grantee );
    
    ** Reformat square number **;
    
    square = upcase( square );
    square = compress( square, '.-/ ' );
    
    if length( square ) > 0 then do;
    
      if index( square, "PAR" ) = 0 and index( square, "RES" ) = 0 and index( square, "RT" ) = 0 then do;
      
        _i = indexc( square, "ABCDEFGHIJKLMNOPQRSTUVWXYZ" );
        
        if _i > 0 then do;
          _suffix = substr( square, _i, 1 );
          put _n_= DocumentNo= _i= square= _suffix= ;
          square = compress( square, "ABCDEFGHIJKLMNOPQRSTUVWXYZ" );
        end;
        else do;
          _suffix = "";
        end;
        
        _nsquare = input( square, 8. );
        
        if _nsquare > 0 then        
          square = trim( left( put( _nsquare, z4. ) ) ) || _suffix;
        
        if _i > 0 then put _n_= DocumentNo= _i= square= _suffix= ;

      end;
      else do;
      
        %warn_put( macro=Read_one_foreclosure_file, msg="Non-numeric square number: File=&file..csv " _n_= DocumentNo= square= )
        
      end;
      
    end;
      
    ** Reformat lot number **;
    
    length Lot $ 8 MultipleLots 3;
    
    _i = indexc( xlot, "-,&" );
    
    if _i > 0 then do;
    
      ** Use only first of multiple lots **;
    
      put _n_= DocumentNo= _i= square= xlot= ;
      
      lot = substr( xlot, 1, _i - 1 );

      lot = put( input( lot, 8. ), z4. );
      
      MultipleLots = 1;
      
    end;
    else do;

      lot = put( input( xlot, 8. ), z4. );
      
      MultipleLots = 0;
      
    end;

    lot = compress( lot, '. ' );
    
    if _i > 0 then put _n_= DocumentNo= _i= square= lot= MultipleLots= Grantee=;
    
    ** Create SSL number **;
    
    if length( square ) > 1 and length( lot ) > 1 then do;
    
      _i = length( square ) + length( lot );
      
      length SSL $ 17;
      
      SSL = trim( square ) || repeat( ' ', 12 - ( _i + 1 ) ) || lot;
      
    end;
    
    if _drop6 ~= "" then input _drop1;
    
    ** Labels and formats **;
    
    label
      Instrument = "Type of document"
      FilingDate = "Filing date"
      DocumentNo = "Document number"
      Grantor = "Grantor (eg. lender)"
      Grantee = "Grantee (eg. borrower)"
      Square = "Property square/suffix"
      xLot = "Original property lot (not reformatted)"
      Lot = "Property lot"
      SSL = "Property identification number (square/suffix/lot)"
      MultipleLots = "Document applies to multiple lots (see xLot for detail)"
      FileDownloadDateTime = "Date/time of download from ROD web site (UI)"
      Verified = "Has ROD verified data entry for this record? (UI)";

    format FilingDate mmddyy10. MultipleLots Verified dyesno. FileDownloadDateTime datetime.;
    
    drop _i _drop: _suffix _nsquare;
    
  run;

  filename inf clear;

%mend Read_one_foreclosure_file;

/** End Macro Definition **/


