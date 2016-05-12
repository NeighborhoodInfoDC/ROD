/**************************************************************************
 Program:  Update_geos_foreclosures.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/01/12
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Foreclosures_yyyy data sets to include new
 geos: Anc2012, Psa2012, Geo2010, GeoBlk2010, Ward2012.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
/***%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;***/

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%let geo_list_orig = Anc2002 Casey_nbr2003 Casey_ta2003 City Cluster2000 
                     Cluster_tr2000 Eor Psa2004 Ward2002 Zip Geo2000 GeoBlk2000;

%let geo_list_new = Anc2002 Anc2012 City Cluster2000 Cluster_tr2000 Eor 
                    Psa2004 Psa2012 Ward2002 Ward2012 Zip Geo2000 Geo2010 GeoBlk2000 GeoBlk2010;

/** Macro Run_all - Start Definition **/

%macro Run_all;

  %do year = 1990 %to 2012;

    %let fcl_ds = Foreclosures_&year;
    %let out = Rod.Foreclosures_&year._new;

    title2 "File = &fcl_ds";

    ** Merge with geographies **;
    
    proc sql;
      create table _read_forecl (label="Property foreclosure notices, &year, DC") as
      select fcl.*, geo.* 
      	from Rod.&fcl_ds (drop=&geo_list_orig) as fcl left join 
      	  RealProp.Parcel_geo (keep=ssl &geo_list_new) as geo 
      	  on (fcl.ssl = geo.ssl)
      order by FilingDate, DocumentNo, ssl; 
    quit;
    run;

    /*
    proc print data=_read_forecl n;
      where DocumentNo = '2011024920';
      id FilingDate DocumentNo;
      by FilingDate DocumentNo;
      var ssl ssl_update_flag ward2002;
      title2 "File = _read_forecl";
    run;
    */
    
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
        	from _read_forecl_a (drop=&geo_list_new) as a 
        	left join RealProp.Square_geo (keep=square &geo_list_new) as geo
        		on (a.square = geo.square)
        order by FilingDate, DocumentNo, ssl;
      quit;
    run;

    /*
    proc print data=_read_forecl_c n;
      where DocumentNo = '2011024920';
      id FilingDate DocumentNo;
      by FilingDate DocumentNo;
      var ssl ssl_update_flag ward2002;
      title2 "File = _read_forecl_c";
    run;
    */

    ** Merge all back together **;
     
    data &out (label="Property foreclosure notices, &year, DC");
         set _read_forecl_b (in=in_b) _read_forecl_c;
         if in_b then Parcel_geo_match = 1;
         else Parcel_geo_match = 0;
         
         label Parcel_geo_match = 'Record matched to Parcel_geo';
         
         format Parcel_geo_match dyesno.;
         
    run;
   
    proc sort data=&out;
      by FilingDate DocumentNo ssl;
    run;
    
    %File_info( data=&out, printobs=0, freqvars=Parcel_geo_match ward2002 ward2012 Anc2012 Psa2012 Geo2010 )

    proc sort data=Rod.&fcl_ds out=&fcl_ds;
        by FilingDate DocumentNo ssl;
      run;

    proc compare base=&fcl_ds compare=&out maxprint=(40,32000);
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
