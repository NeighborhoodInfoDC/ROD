/**************************************************************************
 Program:  Read_coop_units_file.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  04/02/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read CSV file with updates COOP Units after purchasing and 
 	       checking document on ROD Website. Based on Read_ssl_update_file.sas

 Modifications: 

**************************************************************************/

/** Macro Read_coop_units_file - Start Definition **/

%macro Read_coop_units_file;

  filename inf  "&_dcdata_path\ROD\prog\COOP Units.csv" lrecl=5000;
  
  ** Read updated ssl records from CSV file **;

  data coop_units (compress=no);
  
    infile inf dsd  missover firstobs=2;

    input
      _drop1 $
      DocumentNo :$10. @;
      
    if missing( DocumentNo ) then stop;
    
    input
      _drop2 $ 
      SSL :$17.
      _drop3 $ _drop4 $
      Multiplelots : 3.
      UnitNo_Coop :$12.
      Update_coop_notes :$100.
      ;
     
     if not( missing( UnitNo_Coop ) ) then COOP_unit_flag=1; 
     
          
     Update_COOP=1;
     
      
    label
      DocumentNo = "Document number"
      SSL = "Property identification number (square/suffix/lot)"
      UnitNo_Coop = "Cooperative Unit Number"
      MultipleLots = "Document applies to multiple lots (see xLot for detail)"
      Update_coop_Notes = "Notes from COOP Unit Update" 
      COOP_unit_Flag = "DocumentNo's COOP Unit was added to File"
      Update_COOP = "DocumentNo checked for COOP Unit" ;
      
    format  MultipleLots dyesno.;
    
    drop _drop: ;
    
  run;

 filename inf clear;

%mend Read_coop_units_file;

/** End Macro Definition **/


