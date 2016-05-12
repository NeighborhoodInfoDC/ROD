/**************************************************************************
 Program:  Update_geos_foreclosures_b.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/05/12
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description:  Update X_coord and Y_Coord vars in Foreclosures_yyyy 
 data sets for 1990 to 2011.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
/***%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;***/

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

/** Macro Run_all - Start Definition **/

%macro Run_all;

  %do year = 1990 %to 2011;

    %let fcl_ds = Foreclosures_&year;
    %let out = Rod.Foreclosures_&year._new;

    title2 "File = &fcl_ds";

    ** Merge with geographies **;
    
    proc sql;
      create table _read_forecl (label="Property foreclosure notices, &year, DC") as
      select fcl.*, geo.* 
      	from Rod.&fcl_ds (drop=x_coord y_coord) as fcl left join 
      	  RealProp.Parcel_geo (keep=ssl x_coord y_coord) as geo 
      	  on (fcl.ssl = geo.ssl)
      order by FilingDate, DocumentNo, ssl; 
    quit;
    run;

    ** Merge all back together **;
     
    data &out (label="Property foreclosure notices, &year, DC");
         set _read_forecl;
    run;
   
    proc sort data=&out;
      by FilingDate DocumentNo ssl;
    run;
    
    %File_info( data=&out, printobs=0, freqvars= )

    proc sort data=Rod.&fcl_ds out=&fcl_ds;
        by FilingDate DocumentNo ssl;
      run;

    proc compare base=&fcl_ds compare=&out maxprint=(40,32000)
        method=absolute criterion=50;
      id FilingDate DocumentNo ssl;
    run;

    /*
    proc print data=Rod.&fcl_ds n;
      where DocumentNo = '2011024920';
      id FilingDate DocumentNo;
      by FilingDate DocumentNo;
      var ssl ssl_update_flag ward2002;
      title2 "File = Rod.&fcl_ds";
    run;
    */

    /*
    proc print data=&out n;
      where DocumentNo = '2011024920';
      id FilingDate DocumentNo;
      by FilingDate DocumentNo;
      var ssl ssl_update_flag Parcel_geo_match ward2002;
      title2 "File = &out";
    run;
    */

    title2;

    run;
    
  %end;  /** End of %DO loop **/

%mend Run_all;

/** End Macro Definition **/

%Run_all

/***signoff;***/
