/**************************************************************************
 Program:  UI_instrument.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/13/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create UI_instrument var.

 Modifications: Adding rcords for Notices of Default 01/26/12 RP
**************************************************************************/

/** Macro UI_instrument - Start Definition **/

%macro UI_instrument();

  ** UI_instrument **;
  
  length UI_instrument $ 2;
  
  select ( Instrument );
    when ( "NOTICE FORECLO SALE", "FORECLOSURES" )
      UI_instrument = 'F1';
    when ( "CONDO FORECLOSE REL" )
      UI_instrument = 'F2';
    when ( "NOTICE FORECL ASSESS" )
      UI_instrument = 'F3';
    when ( "NOTICE CANCEL FOREC" )
      UI_instrument = 'F4';
    when ( "TRUSTEES DEED" )
      UI_instrument = 'F5';
	 when ( "FORECL DEFAULT NOTE" )
      UI_instrument = 'D1';
	 when ( "FORECLOSE MEDIA CERT" )
      UI_instrument = 'M1';
    otherwise do;
      %err_put( macro=UI_instrument, 
                msg="Record is not a foreclosure and will be deleted: File=&file..csv " _n_= FilingDate= mmddyy10. Instrument= DocumentNo= )
      delete;
    end;
  end;
  
  label UI_Instrument = "Type of document (UI recode)";
  
  format UI_Instrument $uinstr.;

%mend UI_instrument;

/** End Macro Definition **/

