/**************************************************************************
 Program:  Temp.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/13/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )

/** Macro Name_clean - Start Definition **/

%macro Name_clean( name );

  upcase( left( compress( &name, " ,-.'`/\" ) ) )

%mend Name_clean;

/** End Macro Definition **/


data;

    grantee = 'A/K/A Copeland Nichole';
    grantee_clean = %name_clean( grantee );
    put grantee= grantee_clean=;

    ** Extract given name (assumes last name is listed first, skip one letter initials) **;

    length name $ 80;

    i = 2;
    name = "-";
    
    if %name_clean( scan( grantee, 1, ' ' ) ) in ( 'AKA' ) then i = i + 1;

    do until ( length( name ) > 1 or name = "" );

      name = %name_clean( scan( grantee, i, ' ' ) );
      put i= name= ;
      
      i = i + 1;
    
    end;
    
run;

proc print;




run;
