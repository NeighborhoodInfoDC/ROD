/**************************************************************************
 Program:  BookType.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/13/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to recode BookType var.

 Modifications:
**************************************************************************/

/** Macro BookType - Start Definition **/

%macro BookType();

  length BookType $ 1;
  
  select ( _dropBookType );
    when ( 'GEN' ) BookType = 'G';
    when ( 'LAN' ) BookType = 'L';
    when ( 'OPR' ) BookType = 'O';
    when ( 'UNK', '' ) BookType = '';
    otherwise do;
      %err_put( macro=BookType, 
                msg="Invalid BookType: File=&file..csv " _n_= FilingDate= mmddyy10. BookType= Instrument= DocumentNo= )
    end;
  end;
  
  label BookType = "Book type";
  
  format BookType $booktyp.;

%mend BookType;

/** End Macro Definition **/

