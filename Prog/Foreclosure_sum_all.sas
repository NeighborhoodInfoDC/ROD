/**************************************************************************
 Program:  Foreclosure_sum_all.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  06/26/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary foreclosure data by all geographies.
 
 Modifications: 02/06/12 LH Updated for 2011
  09/01/12 PAT Create summaries for new geographies.
               Removed summaries for Casey_nbr2003 and Casey_ta2003.
  09/09/12 PAT Updated for new 2010/2012 geos.
               Switched to using geographies in Foreclosures_yyyy files,
               rather than remerging with Parcel_geo.
               Added declaration for local macro vars.
  02/06/12 LH	Updated for 2012.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

options SORTPGM=SAS MSGLEVEL=I;
 
rsubmit;

/** Change to N for testing, Y for final batch mode run **/
%let register = Y;

/** Update with information on latest file revision **/
/*%let revisions = %str(Verified thr. 12/31/11);*/
%let revisions = %str(Verified thr. 12/31/12);

/** Update with latest year of foreclosure notice data **/
%let end_yr = 2012;

/** First year of notice foreclosure data - SHOULD NOT BE CHANGED **/
%let start_yr =1995;


/** Macro Foreclosure_sum_geo - Start Definition **/

%macro Foreclosure_sum_geo( geo=, start_yr=, end_yr=, revisions=, register=N);

  %local sum_vars sum_vars_ssl sum_flag_ssl sum_vars_rates sum_vars_wf sum_vars_wt
         geosuf geodlbl geofmt type inst i j type1 inst1 var;

   %let register = %upcase( &register );
   
   %let sum_vars=
   forecl_sf forecl_condo forecl_sf_condo trustee_sf trustee_condo trustee_sf_condo
   ;
   
   %let sum_vars_ssl=
   forecl_ssl_sf forecl_ssl_condo forecl_ssl_sf_condo trustee_ssl_sf trustee_ssl_condo 
   trustee_ssl_sf_condo 
      ;
   
   %let sum_flag_ssl=
   flag_forecl_ssl_sf flag_forecl_ssl_condo flag_forecl_ssl_sf_condo 
   flag_trustee_ssl_sf flag_trustee_ssl_condo flag_trustee_ssl_sf_condo 
   ;
   
   %let sum_vars_rates=
   forecl_1Kpcl_sf forecl_1Kpcl_condo forecl_1Kpcl_sf_condo
   forecl_ssl_1Kpcl_sf forecl_ssl_1Kpcl_condo forecl_ssl_1Kpcl_sf_condo
   trustee_1Kpcl_sf trustee_1Kpcl_condo trustee_1Kpcl_sf_condo
   trustee_ssl_1Kpcl_sf trustee_ssl_1Kpcl_condo trustee_ssl_1Kpcl_sf_condo
   ;   
   
   
   %let sum_vars_wf = forecl_: ;
   %let sum_vars_wt = trustee_: ;
   
   
   %let geo = %upcase( &geo );
   
   %if %sysfunc( putc( &geo, $geoval. ) ) ~= %then %do;
   	%let geosuf = %sysfunc( putc( &geo, $geosuf. ) );
   	%let geodlbl = %sysfunc( putc( &geo, $geodlbl. ) );
	%let geofmt = %sysfunc( putc( &geo, $geoafmt. ) );
   %end;
   %else %do;
    	%err_mput( macro=Create_sum_geo, msg=Invalid or missing value of GEO= parameter (GEO=&geo). )
    	%goto exit_macro;
   %end;
   
  ** Combine Input data **;
   
  %Push_option( compress )
   
  options compress=no;
   
  data ALL_foreclosures;
   
   	set 
   	   %do i = &start_yr %to &end_yr;
   	     ROD.Foreclosures_&i
   	   %end;
   	;
   	by FilingDate; **Do I need anything here?**;
   
   *** Create indicator variables here ***;
   ***Number of Notices ***;
   
   notice_yr = year(FilingDate);
  
   
   %let type= forecl trustee;	  
   %let inst= F1 F5;
   %do j = 1 %to 2; 
   %let type1 = %scan(&type,&j., ' ');
   %let inst1= %scan(&inst,&j., ' ');
   
   
   
   if UI_Instrument ="&inst1" and ui_proptype="10"
   	then &type1._sf = 1;
  	else &type1._sf = 0;
   
   if UI_Instrument ="&inst1" and ui_proptype="11"
      	then &type1._condo = 1;
  	else &type1._condo = 0;
  
   if UI_Instrument ="&inst1" and ui_proptype in ("10" "11")
      	then &type1._sf_condo = 1;
  	else &type1._sf_condo = 0;
  
  	
   %end;
   
   
  run;
   
  ** SUMMARIZE FOR PARCEL LEVEL NOTICE INFO **;
   
  proc sort data=ALL_foreclosures;
  by notice_yr ssl;
   
  /*** REMOVED 09/09/12 ***
  proc summary data=all_foreclosures;
   by notice_yr ssl;
   var &sum_vars;
   output out=parcels_not  sum= &sum_flag_ssl;
   
  run;
   
  proc sql;
       create table Work.parcels_notice as
       select parcels_not.*, geo.*
       	from parcels_not left join RealProp.Parcel_geo (drop=CJRTRACTBL) 
       		as geo on (parcels_not.ssl = geo.ssl)
      	order by notice_yr; 
     quit;
  run;
  ***/
  
  proc summary data=all_foreclosures;
   by notice_yr ssl;
   id &geo;
   var &sum_vars;
   output out=parcels_notice (drop=_type_ _freq_)  sum= &sum_flag_ssl;
   
  run;

  data all_parcels_notice;
  	set parcels_notice;
  
     %let type= forecl trustee;	  
     %do j = 1 %to 2;    
     %let type1 = %scan(&type.,&j., ' ');
          
    
  	
     if flag_&type1._ssl_sf > 0 then &type1._ssl_sf = 1;
  	else &type1._ssl_sf = 0; 
  
     if flag_&type1._ssl_condo > 0 then &type1._ssl_condo = 1;
  	else &type1._ssl_condo = 0; 
     
     if flag_&type1._ssl_sf_condo > 0 then &type1._ssl_sf_condo = 1;
  	else &type1._ssl_sf_condo = 0; 
 
     %end;
     
  run;
  
  ** DENOMINATOR INFO = # of Parcels for geo unit & year **;
   
	  proc transpose data=realprop.num_units&geosuf out=sf;
		by &geo;
		var units_sf_1995-units_sf_&end_yr.;
		run;

		data sf2 (drop=year _name_ _label_);
			set sf (rename=(col1=parcel_sf));

			length year $4. notice_yr 3.;
			year=substr(_name_,10,4);
			notice_yr=year;

		run;

	  proc transpose data=realprop.num_units&geosuf out=condo;
		by &geo;
		var units_condo_1995-units_condo_&end_yr.;
		run;

		data condo2 (drop=year _name_ _label_);
				set condo (rename=(col1=parcel_condo));

			length year $4. notice_yr 3.;
			year=substr(_name_,13,4);
			notice_yr=year;

		run;

	  proc transpose data=realprop.num_units&geosuf out=sfcondo;
		by &geo;
		var units_sf_condo_1995-units_sf_condo_&end_yr.;
		run;

		data sfcondo2 (drop=year _name_ _label_);
			set sfcondo(rename=(col1=parcel_sf_condo));

			length year $4. notice_yr 3.;
			year=substr(_name_,16,4);
			notice_yr=year;
       run;

	proc sort data=sf2;
	by &geo notice_yr;
	run;

	proc sort data=condo2;
	by &geo notice_yr;
	run;

      proc sort data=sfcondo2;
	by &geo notice_yr;
	run;

	data parcels_geo;
        merge sf2 condo2 sfcondo2;
        by &geo notice_yr;
	run;
	
   ** Convert data to single obs. per geographic unit & year **;
   
   proc summary data=ALL_foreclosures nway completetypes;
   	class &geo / preloadfmt;
   	class notice_yr;
   	var &sum_vars;
   	output out=ALL_foreclosures_geo (drop=_type_ _freq_) sum=;
   	format &geo &geofmt;
   	
   proc summary data=all_parcels_notice nway completetypes;
      	class &geo / preloadfmt;
      	class notice_yr;
      	var &sum_vars_ssl;
      	output out=all_parcels_notice_geo (drop=_type_ _freq_) sum=;
   	format &geo &geofmt;
   	
   	
   proc summary data=parcels_geo nway completetypes;
      	class &geo / preloadfmt;
		class notice_yr;
      	var parcel_sf parcel_condo parcel_sf_condo;
      	output out=all_parcels_geo (drop=_type_ _freq_) sum=;
   	format &geo &geofmt;
   run;   	
   
  ** Merge Geo Sum Files **;
   	
   	data ALL_Foreclosures_geo1;
   	
   	merge
   	  ALL_Foreclosures_geo
   	  all_parcels_notice_geo
	  all_parcels_geo;
   	by &geo notice_yr;
   	    	
   	if parcel_sf > 0 then do;
        forecl_1Kpcl_sf = forecl_sf / parcel_sf * 1000;
        forecl_ssl_1Kpcl_sf = forecl_ssl_sf / parcel_sf * 1000;
        trustee_1Kpcl_sf = trustee_sf / parcel_sf * 1000;
        trustee_ssl_1Kpcl_sf = trustee_ssl_sf / parcel_sf * 1000;
      end;
   	
   	if parcel_condo > 0 then do;
        forecl_1Kpcl_condo = forecl_condo / parcel_condo * 1000;
        forecl_ssl_1Kpcl_condo = forecl_ssl_condo / parcel_condo * 1000;
        trustee_1Kpcl_condo = trustee_condo / parcel_condo * 1000;
        trustee_ssl_1Kpcl_condo = trustee_ssl_condo / parcel_condo * 1000;
      end;

      if parcel_sf_condo > 0 then do;
        forecl_1Kpcl_sf_condo = forecl_sf_condo / parcel_sf_condo * 1000;
        forecl_ssl_1Kpcl_sf_condo = forecl_ssl_sf_condo / parcel_sf_condo * 1000;
        trustee_1Kpcl_sf_condo = trustee_sf_condo / parcel_sf_condo * 1000;
        trustee_ssl_1Kpcl_sf_condo = trustee_ssl_sf_condo / parcel_sf_condo * 1000;
      end;
   	
   	label 
   	forecl_1Kpcl_sf="No. of Notices of Foreclosure Sale per 1000 Single Family Homes"
	forecl_1Kpcl_condo="No. of Notices of Foreclosure Sale per 1000 Condominiums"
	forecl_1Kpcl_sf_condo="No. of Notices of Foreclosure Sale per 1000 SF Homes & Condominiums"
	
	forecl_ssl_1Kpcl_sf="Foreclosure Rate per 1000 Single Family Homes"
	forecl_ssl_1Kpcl_condo="Foreclosure Rate per 1000 Condominiums"
	forecl_ssl_1Kpcl_sf_condo="Foreclosure Rate per 1000 SF Homes & Condominiums"
   	
   	trustee_1Kpcl_sf="No. of Notices of Trustee Deed Sale per 1000 Single Family Homes"
	trustee_1Kpcl_condo="No. of Notices of Trustee Deed Sale per 1000 Condominiums"
	trustee_1Kpcl_sf_condo="No. of Notices of Trustee Deed Sale per 1000 SF Homes & Condominiums"
   
   	trustee_ssl_1Kpcl_sf="No. of Single Family Homes with Notice of Trustee Deed Sale per 1000 Single Family Homes"
	trustee_ssl_1Kpcl_condo="No. of Condominiums with Notice of Trustee Deed Sale per 1000 Condominiums"
	trustee_ssl_1Kpcl_sf_condo="No. of SF Homes & Condos with Notice of Trustee Deed Sale per 1000 SF Homes & Condos"
   	
   	forecl_sf="No. of Notices of Foreclosure Sale - Single Family Homes" 
	forecl_condo="No. of Notices of Foreclosure Sale - Condominiums" 
	forecl_sf_condo="No. of Notices of Foreclosure Sale - Single Family Homes & Condominiums" 
	
	forecl_ssl_sf="No. of Single Family Homes with Notices of Foreclosure Sale" 
	forecl_ssl_condo="No. of Condominiums with Notices of Foreclosure Sale" 
	forecl_ssl_sf_condo="No. of SF Homes & Condominiums with Notices of Foreclosure Sale" 
	
	trustee_sf="No. of Notices of Trustee Deed Sale - Single Family Homes"
	trustee_condo="No. of Notices of Trustee Deed Sale - Condominiums"
	trustee_sf_condo="No. of Notices of Trustee Deed Sale - SF Homes & Condominiums"
	
   	trustee_ssl_sf="No. of Single Family Homes with Notice of Trustee Deed Sale"
   	trustee_ssl_condo="No. of Condominiums with Notice of Trustee Deed Sale"
   	trustee_ssl_sf_condo="No. of SF Homes & Condominiums with Notice of Trustee Deed Sale"
   	   	
   	parcel_sf="No. of Single Family Homes in Geo"
   	parcel_condo="No. of Condominiums in Geo"
   	parcel_sf_condo="No. of Single Family Homes & Condominiums in Geo"
   	
   	;  	
   	
   	
   	run;
   
      
   ** Transpose data by year **;
  
   %let var = &sum_vars &sum_vars_ssl &sum_vars_rates parcel_sf parcel_condo parcel_sf_condo;
   
   %super_transpose(
     data=ALL_Foreclosures_geo1,
     out=ALL_Foreclosures_geo_tr,
     var=&var,
     id=notice_yr,
     by=&geo,
     mprint=N
   )
  
   ** Recode missing Values to zero (0) **;  
   
   options spool;

   %Pop_option( Compress )
   
   data ROD.Foreclosures_sum&geosuf (label="Foreclosure Notices Summary, DC, &geodlbl" sortedby=&geo);
   
   	set ALL_Foreclosures_geo_tr;
   	
   	array a {*} &sum_vars_wf &sum_vars_wt;
   	
   	do i = 1 to dim( a );
   	  if missing( a{i} ) then a{i} = 0;
   	end;
   	
   	drop i;
   	
   run;
   
   x "purge [dcdata.rod.data]Foreclosures_sum&geosuf..*";
   
   proc datasets library=work kill memtype=(data);
   quit;

   %File_info( data=ROD.Foreclosures_sum&geosuf, printobs=0)
   
   %if &register = Y %then %do;
   	
   	** Register in metadata **;
   	
   	%Dc_update_meta_file(
   	  ds_lib=Rod,
   	  ds_name=Foreclosures_sum&geosuf,
   	  creator_process=Foreclosures_sum_all.sas,
   	  restrictions=None,
   	  revisions=%str(&revisions)
   	  
   	 )
   	 
   %end;
   
   %exitmacro:
   
%mend Foreclosure_sum_geo;

/** End Macro Definition **/


** Create summaries for all geos ***;

%Foreclosure_sum_geo( geo=city, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ward2002, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ward2012, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=geo2000, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=geo2010, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ANC2002, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ANC2012, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=CLUSTER_TR2000, start_yr=&start_yr, end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=EOR, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=PSA2004, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=PSA2012, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ZIP, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )

/***%Foreclosure_sum_geo( geo=GEOBLK2000, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )***/

run;

endrsubmit;

signoff;

