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
    when ( "FORECLOSURE NOTICE" )
      UI_instrument = 'F1';
    when ( "CONDO FORECLOSURE NOTICE" )
      UI_instrument = 'F2';
	when ( "CONDO FORECLOSURE RELEASE" )
      UI_instrument = 'F3';
    when ( "FORECLOSURE NOTICE OF CANCELLATION" )
      UI_instrument = 'F4';
    when ( "TRUSTEES DEED" )
      UI_instrument = 'F5';
	  when ( "FORECLOSURE RELEASE NOTICE" )
	  UI_instrument = 'F6';
	  when ( "FORECLOSURE AFFIDAVIT" )
	  UI_instrument = 'F7';
	 when ( "FORECLOSURE DEFAULT NOTICE" )
      UI_instrument = 'D1';
	 when ( "FORECLOSURE CANCELLATION OF DEFAULT" )
      UI_instrument = 'D2';
	 when ( "FORECLOSURE MEDIATION CERTIFICATE" )
      UI_instrument = 'M1';
	 when ( "LIS PENDENS" )
      UI_instrument = 'L1';
	 when ( "LIS PENDENS RELEASE" )
      UI_instrument = 'L2';
    otherwise do;
      %err_put( macro=UI_instrument, 
                msg="Record is not a foreclosure and will be deleted: File=&file..csv " _n_= Filingdate= mmddyy10. Instrument= DocumentNo= )
      delete;
    end;
  end;
  
  label UI_Instrument = "Type of document (UI recode)";
  
  format UI_Instrument $uinstr.;

%mend UI_instrument;

/** End Macro Definition **/

