/**************************************************************************
 Program:  Read_ssl_update_file.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  08/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read CSV file with updates to SSL that were on detail screen on ROD website.

 Modifications: 

**************************************************************************/

/** Macro Read_ssl_update_file - Start Definition **/

%macro Read_ssl_update_file;

  filename inf  "&_dcdata_path\ROD\prog\SSL Update.csv" lrecl=7000;
  
  ** Read updated ssl records from CSV file **;

  data ssl_update (compress=no);
  
    infile inf dsd  missover firstobs=2;

    input
      _drop1 $
      DocumentNo :$10. @;
      
    if missing( DocumentNo ) then stop;
    
    input
      _drop2 $
      SSL_prev :$17.
      _drop3 $ _drop4 $ _drop5 $  _drop6 $
      SSL :$17.
      _drop7 $
      Multiplelots : 3.
      Update_notes :$100.
      ;
     
     if not( missing( ssl ) ) then SSL_update_flag=1; 
     
     if missing ( ssl ) then ssl=ssl_prev; 
     
     Update_checked=1;
     
      
    label
      DocumentNo = "Document number"
      SSL = "Property identification number (square/suffix/lot)"
      SSL_prev = "SSL (square/suffix/lot) before Update"
      MultipleLots = "Document applies to multiple lots (see xLot for detail)"
      Update_Notes = "Notes from SSL Update" 
      SSL_Update_Flag = "DocumentNo's SSL was updated from raw data"
      Update_Checked = "DocumentNo checked for updated SSL" ;
      
    format  MultipleLots dyesno.;
    
    drop _drop: ;
    
  run;

 filename inf clear;

%mend Read_ssl_update_file;

/** End Macro Definition **/


