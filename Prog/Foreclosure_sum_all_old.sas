/**************************************************************************
 Program:  Foreclosure_sum_all.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  05/09/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Summary foreclosure data by all geographies.
 
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

rsubmit;

%let revisions = New file.;
%let register = N;
%let end_yr = 2007;
%let start_yr =1990;

/**Macro Foreclosure_sum_geo - Start Definition **/

%macro Foreclosure_sum_geo( geo=, start_yr=, end_yr=, revisions=, register=N);

   %let register = %upcase( &register);
   
   %let sum_vars=
   forecl_ntc_sale forecl_ntc_sale_res forecl_ntc_sale_com forecl_ntc_sale_oth 
   forecl_ntc_sale_sf forecl_ntc_sale_condo forecl_ntc_sale_coop forecl_ntc_sale_apt 
   forecl_trd forecl_trd_res forecl_trd_com forecl_trd_oth 
   forecl_trd_sf forecl_trd_condo forecl_trd_coop forecl_trd_apt forecl_ntc_cancel
   ;
   
   %let sum_vars_ssl=
   forecl_ntc_sale_ssl forecl_ntc_sale_res_ssl forecl_ntc_sale_com_ssl forecl_ntc_sale_oth_ssl
   forecl_ntc_sale_sf_ssl forecl_ntc_sale_condo_ssl forecl_ntc_sale_coop_ssl forecl_ntc_sale_apt_ssl
   forecl_trd_ssl forecl_trd_res_ssl forecl_trd_com_ssl forecl_trd_oth_ssl 
   forecl_trd_sf_ssl forecl_trd_condo_ssl forecl_trd_coop_ssl forecl_trd_apt_ssl forecl_ntc_cancel_ssl
   ;
   
   %let sum_flag_ssl=
   flag_ntc_sale_ssl flag_ntc_sale_res_ssl flag_ntc_sale_com_ssl flag_ntc_sale_oth_ssl 
   flag_ntc_sale_sf_ssl flag_ntc_sale_condo_ssl flag_ntc_sale_coop_ssl flag_ntc_sale_apt_ssl 
   flag_trd_ssl flag_trd_res_ssl flag_trd_com_ssl flag_trd_oth_ssl 
   flag_trd_sf_ssl flag_trd_condo_ssl flag_trd_coop_ssl flag_trd_apt_ssl flag_ntc_cancel_ssl
   ;
   
   %let sum_vars_rates=
   forecl_ntc_1Kpcl forecl_ntc_res_1Kpcl forecl_ntc_com_1Kpcl forecl_ntc_oth_1Kpcl
   forecl_ntc_sf_1Kpcl forecl_ntc_condo_1Kpcl forecl_ntc_coop_1Kpcl forecl_ntc_apt_1Kpcl
   forecl_ntcssl_1Kpcl forecl_ntcssl_res_1Kpcl forecl_ntcssl_com_1Kpcl forecl_ntcssl_oth_1Kpcl
   forecl_ntcssl_sf_1Kpcl forecl_ntcssl_condo_1Kpcl forecl_ntcssl_coop_1Kpcl forecl_ntcssl_apt_1Kpcl
   forecl_trd_1Kpcl forecl_trd_res_1Kpcl forecl_trd_com_1Kpcl forecl_trd_oth_1Kpcl
   forecl_trd_sf_1Kpcl forecl_trd_condo_1Kpcl forecl_trd_coop_1Kpcl forecl_trd_apt_1Kpcl
   forecl_trdssl_1Kpcl forecl_trdssl_res_1Kpcl forecl_trdssl_com_1Kpcl forecl_trdssl_oth_1Kpcl
   forecl_trdssl_sf_1Kpcl forecl_trdssl_condo_1Kpcl forecl_trdssl_coop_1Kpcl forecl_trdssl_apt_1Kpcl 
   ;   
   
   
   %let sum_vars_wf = Forecl_: ;
   
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
  
   notice_yr = year(FilingDate);
   notice = 1;
   
   %let type= ntc_sale trd;	  
   %let inst= F1 F5;
   %do j = 1 %to 2; 
   %let type1 = %scan(&type,&j., ' ');
   %let inst1= %scan(&inst,&j., ' ');
   
   
   
   if UI_Instrument ="&inst1" then forecl_&type1 = 1;
   	else forecl_&type1. = 0;
   
   if UI_Instrument ="&inst1" and ui_proptype in ("10" "11" "12" "13" "19") 
	then forecl_&type1._res = 1;
  	else forecl_&type1._res = 0;
  	
   if UI_Instrument ="&inst1" and ui_proptype in ("20" "21" "22" "23" "24" "29") 
	then forecl_&type1._com = 1;
	else forecl_&type1._com = 0;
  
   if UI_Instrument ="&inst1" and ui_proptype in ("30" "40" "50" "51") 
	then forecl_&type1._oth = 1;
	else forecl_&type1._oth = 0;
   
   if UI_Instrument ="&inst1" and ui_proptype="10"
   	then forecl_&type1._sf = 1;
  	else forecl_&type1._sf = 0;
   
    if UI_Instrument ="&inst1" and ui_proptype="11"
      	then forecl_&type1._condo = 1;
  	else forecl_&type1._condo = 0;
  
   if UI_Instrument ="&inst1" and ui_proptype="12"
      	then forecl_&type1._coop = 1;
  	else forecl_&type1._coop = 0;
  
   if UI_Instrument ="&inst1" and ui_proptype="13"
        then forecl_&type1._apt = 1;
  	else forecl_&type1._apt = 0;
  	
   %end;
   
   if UI_Instrument ="F4" then forecl_ntc_cancel = 1; 
   	else forecl_ntc_cancel = 0;
   
  run;
   
  ** SUMMARIZE FOR PARCEL LEVEL NOTICE INFO **;
   
  proc sort data=ALL_foreclosures;
  by notice_yr ssl;
   
  proc summary data=all_foreclosures;
   by notice_yr ssl;
   var notice &sum_vars;
   output out=parcels_not  sum= flag_ntc_ssl &sum_flag_ssl;
   
  run;
   
  proc sql;
       create table Work.parcels_notice as
       select parcels_not.*, geo.*
       	from parcels_not left join RealProp.Parcel_geo (drop=CJRTRACTBL) 
       		as geo on (parcels_not.ssl = geo.ssl)
      	order by notice_yr; 
     quit;
  run;
  
  data all_parcels_notice;
  	set parcels_notice;
  
     %let type= ntc_sale trd;	  
     %do j = 1 %to 2;    
     %let type1 = %scan(&type.,&j., ' ');
          
    
  	
     if flag_ntc_ssl > 0 then forecl_notices_ssl = 1; else forecl_notices_ssl = 0;
  
     if flag_&type1._ssl > 0 then forecl_&type1._ssl = 1; 
  	else forecl_&type1._ssl = 0; 
  
     if flag_&type1._res_ssl > 0 then forecl_&type1._res_ssl = 1;
  	else forecl_&type1._res_ssl = 0;
  	
     if flag_&type1._com_ssl > 0 then forecl_&type1._com_ssl = 1; 
  	else forecl_&type1._com_ssl = 0;
  	
     if flag_&type1._oth_ssl > 0 then forecl_&type1._oth_ssl = 1;
  	else forecl_&type1._oth_ssl = 0; 
     
     if flag_&type1._sf_ssl > 0 then forecl_&type1._sf_ssl = 1;
  	else forecl_&type1._sf_ssl = 0; 
  
     if flag_&type1._condo_ssl > 0 then forecl_&type1._condo_ssl = 1;
  	else forecl_&type1._condo_ssl = 0; 
     
     if flag_&type1._coop_ssl > 0 then forecl_&type1._coop_ssl = 1;
  	else forecl_&type1._coop_ssl = 0; 
  	
     if flag_&type1._apt_ssl > 0 then forecl_&type1._apt_ssl = 1;
  	else forecl_&type1._apt_ssl = 0; 
  
     %end;
      if flag_ntc_cancel_ssl > 0 then forecl_ntc_cancel_ssl = 1; 
   	else forecl_ntc_cancel_ssl = 0;
     
  run;
  
   
   ** DENOMINATOR INFO = # of Parcels for geo unit & year **;
   
   data parcels ;
   	set REALPROP.parcel_base;
   
        allparcels = 1;
   
	if ui_proptype in ("10" "11" "12" "13" "19") then parcel_res = 1;
		else parcel_res = 0;

	if ui_proptype = "10" then parcel_sf = 1; else parcel_sf = 0;

	if ui_proptype = "11" then parcel_condo = 1; else parcel_condo = 0;

	if ui_proptype = "12" then parcel_coop = 1; else parcel_coop = 0;
		
   	if ui_proptype = "13" then parcel_apt = 1; else parcel_apt = 0;
   
        if ui_proptype in ("20" "21" "22" "23" "24" "29") then parcel_com = 1;
         	else parcel_com = 0;
   
        if ui_proptype in ("30" "40" "50" "51") then parcel_oth = 1;
        	else parcel_oth = 0;
    
   run;
   
   ** Merge geo info to parcel;
   
     proc sql;
          create table Work.parcels_geo as
          select parcels.*, geo.*
          	from parcels left join RealProp.Parcel_geo (drop=CJRTRACTBL X_COORD Y_COORD) 
          		as geo on (parcels.ssl = geo.ssl)
         	; 
        quit;
     run;
  
   
   ** Convert data to single obs. per geographic unit & year **;
   
   proc summary data=ALL_foreclosures nway completetypes;
   	class &geo / preloadfmt;
   	class notice_yr;
   	var &sum_vars;
   	output out=ALL_foreclosures_geo sum=;
   	format &geo &geofmt;
   	
   proc summary data=all_parcels_notice nway completetypes;
      	class &geo / preloadfmt;
      	class notice_yr;
      	var &sum_vars_ssl;
      	output out=all_parcels_notice_geo sum=;
   	format &geo &geofmt;
   	
   	
   proc summary data=parcels_geo nway completetypes;
      	class &geo / preloadfmt;
      	var allparcels parcel_res parcel_com parcel_oth parcel_sf parcel_condo parcel_coop parcel_apt;
      	output out=all_parcels_geo sum=;
   	format &geo &geofmt;
   	
   
  ** Merge Geo Sum Files **;
   	
   	data ALL_Foreclosures_geo1;
   	
   	merge
   	  ALL_Foreclosures_geo
   	  all_parcels_notice_geo;
   	by &geo notice_yr;
   	
   	run;
   	
   	data ALL_Foreclosures_geo;
   	
   	merge
   	  ALL_Foreclosures_geo1
          all_parcels_geo;
   	  by &geo;
   	  
   	
   	forecl_ntc_1Kpcl=forecl_ntc_sale / allparcels * 1000;
   	forecl_ntc_res_1Kpcl=forecl_ntc_sale_res / parcel_res * 1000;
   	forecl_ntc_com_1Kpcl=forecl_ntc_sale_com / parcel_com * 1000;
   	forecl_ntc_oth_1Kpcl=forecl_ntc_sale_oth / parcel_oth * 1000;
   	forecl_ntc_sf_1Kpcl=forecl_ntc_sale_sf / parcel_sf * 1000;
   	forecl_ntc_condo_1Kpcl=forecl_ntc_sale_condo / parcel_condo * 1000;
   	forecl_ntc_coop_1Kpcl=forecl_ntc_sale_coop / parcel_coop * 1000;
   	forecl_ntc_apt_1Kpcl=forecl_ntc_sale_apt / parcel_apt * 1000;
   	forecl_ntcssl_1Kpcl=forecl_ntc_sale_ssl / allparcels * 1000;
	forecl_ntcssl_res_1Kpcl=forecl_ntc_sale_res_ssl / parcel_res * 1000;
	forecl_ntcssl_com_1Kpcl=forecl_ntc_sale_com_ssl / parcel_com * 1000;
   	forecl_ntcssl_oth_1Kpcl=forecl_ntc_sale_oth_ssl / parcel_oth * 1000;
   	forecl_ntcssl_sf_1Kpcl=forecl_ntc_sale_sf_ssl / parcel_sf * 1000;
	forecl_ntcssl_condo_1Kpcl=forecl_ntc_sale_condo_ssl / parcel_condo * 1000;
	forecl_ntcssl_coop_1Kpcl=forecl_ntc_sale_coop_ssl / parcel_coop * 1000;
   	forecl_ntcssl_apt_1Kpcl=forecl_ntc_sale_apt_ssl / parcel_apt * 1000;
   	forecl_trd_1Kpcl=forecl_trd/ allparcels * 1000;
	forecl_trd_res_1Kpcl=forecl_trd_res / parcel_res * 1000;
	forecl_trd_com_1Kpcl=forecl_trd_com / parcel_com * 1000;
   	forecl_trd_oth_1Kpcl=forecl_trd_oth / parcel_oth * 1000;
   	forecl_trd_sf_1Kpcl=forecl_trd_sf / parcel_sf * 1000;
	forecl_trd_condo_1Kpcl=forecl_trd_condo / parcel_condo * 1000;
	forecl_trd_coop_1Kpcl=forecl_trd_coop / parcel_coop * 1000;
   	forecl_trd_apt_1Kpcl=forecl_trd_apt / parcel_apt * 1000;
   	forecl_trdssl_1Kpcl=forecl_trd_ssl/ allparcels * 1000;
	forecl_trdssl_res_1Kpcl=forecl_trd_res_ssl / parcel_res * 1000;
	forecl_trdssl_com_1Kpcl=forecl_trd_com_ssl / parcel_com * 1000;
   	forecl_trdssl_oth_1Kpcl=forecl_trd_oth_ssl / parcel_oth * 1000;
   	forecl_trdssl_sf_1Kpcl=forecl_trd_sf_ssl / parcel_sf * 1000;
	forecl_trdssl_condo_1Kpcl=forecl_trd_condo_ssl / parcel_condo * 1000;
	forecl_trdssl_coop_1Kpcl=forecl_trd_coop_ssl / parcel_coop * 1000;
   	forecl_trdssl_apt_1Kpcl=forecl_trd_apt_ssl / parcel_apt * 1000;
   	
   	label 
   	forecl_ntc_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Parcels"
   	forecl_ntc_res_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Residential Parcels"
   	forecl_ntc_com_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Commercial Parcels"
   	forecl_ntc_oth_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Other Parcels"
   	forecl_ntc_sf_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Single Family Homes"
	forecl_ntc_condo_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Condominiums"
	forecl_ntc_coop_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Cooperative Bldgs."
   	forecl_ntc_apt_1Kpcl="No. of Notices of Foreclosure Sale per 1000 Rental Apartment Bldgs."
   	forecl_ntcssl_1Kpcl="No. of Parcels with Notice of Foreclosure Sale per 1000 Parcels"
   	forecl_ntcssl_res_1Kpcl="No. of Parcels with Notice of Foreclosure Sale per 1000 Residential Parcels"
   	forecl_ntcssl_com_1Kpcl="No. of Parcels with Notice of Foreclosure Sale per 1000 Commercial Parcels"
   	forecl_ntcssl_oth_1Kpcl="No. of Parcels with Notice of Foreclosure Sale per 1000 Other Parcels"
   	forecl_ntcssl_sf_1Kpcl="No. of Single Family Homes with Notice of Foreclosure Sale per 1000 Single Family Homes"
	forecl_ntcssl_condo_1Kpcl="No. of Condominiums with Notice of Foreclosure Sale per 1000 Condominiums"
	forecl_ntcssl_coop_1Kpcl="No. of Cooperative Bldgs. with Notice of Foreclosure Sale per 1000 Cooperative Bldgs."
   	forecl_ntcssl_apt_1Kpcl="No. of Rental Apartment Bldgs. with Notice of Foreclosure Sale per 1000 Rental Apt. Bldgs."
   	forecl_trd_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Parcels"
   	forecl_trd_res_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Residential Parcels"
   	forecl_trd_com_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Commercial Parcels"
   	forecl_trd_oth_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Other Parcels"
   	forecl_trd_sf_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Single Family Homes"
	forecl_trd_condo_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Condominiums"
	forecl_trd_coop_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Cooperative Bldgs."
   	forecl_trd_apt_1Kpcl="No. of Notices of Trustee Deed Sale per 1000 Rental Apartment Bldgs."
   	forecl_trdssl_1Kpcl="No. of Parcels with Notice of Trustee Deed Sale per 1000 Parcels"
   	forecl_trdssl_res_1Kpcl="No. of Parcels with Notice of Trustee Deed Sale per 1000 Residential Parcels"
   	forecl_trdssl_com_1Kpcl="No. of Parcels with Notice of Trustee Deed Sale per 1000 Commercial Parcels"
   	forecl_trdssl_oth_1Kpcl="No. of Parcels with Notice of Trustee Deed Sale per 1000 Other Parcels"
   	forecl_trdssl_sf_1Kpcl="No. of Single Family Homes with Notice of Trustee Deed Sale per 1000 Single Family Homes"
	forecl_trdssl_condo_1Kpcl="No. of Condominiums with Notice of Trustee Deed Sale per 1000 Condominiums"
	forecl_trdssl_coop_1Kpcl="No. of Cooperative Bldgs. with Notice of Trustee Deed Sale per 1000 Cooperative Bldgs."
   	forecl_trdssl_apt_1Kpcl="No. of Rental Apartment Bldgs. with Notice of Trustee Deed Sale per 1000 Rental Apt. Bldgs."
   	
   	forecl_ntc_sale="No. of Notices of Foreclosure Sale"
	forecl_ntc_sale_res="No. of Notices of Foreclosure Sale - Residential Parcels" 
	forecl_ntc_sale_com="No. of Notices of Foreclosure Sale - Commercial Parcels" 
	forecl_ntc_sale_oth="No. of Notices of Foreclosure Sale - Other Parcels" 
	forecl_ntc_sale_sf="No. of Notices of Foreclosure Sale - Single Family Homes" 
	forecl_ntc_sale_condo="No. of Notices of Foreclosure Sale - Condominiums" 
	forecl_ntc_sale_coop="No. of Notices of Foreclosure Sale - Cooperative Bldgs." 
        forecl_ntc_sale_apt="No. of Notices of Foreclosure Sale - Rental Apartment Bldgs." 
	forecl_ntc_sale_ssl="No. of Parcels with Notices of Foreclosure Sale"
	forecl_ntc_sale_res_ssl="No. of Residential Parcels with Notices of Foreclosure Sale" 
	forecl_ntc_sale_com_ssl="No. of Commercial Parcels with Notices of Foreclosure Sale" 
	forecl_ntc_sale_oth_ssl="No. of Other Parcels with Notices of Foreclosure Sale" 
	forecl_ntc_sale_sf_ssl="No. of Single Family Homes with Notices of Foreclosure Sale" 
	forecl_ntc_sale_condo_ssl="No. of Condominiums with Notices of Foreclosure Sale" 
	forecl_ntc_sale_coop_ssl="No. of Cooperative Bldgs. with Notices of Foreclosure Sale" 
	forecl_ntc_sale_apt_ssl="No. of Rental Apartment Bldgs. with Notices of Foreclosure Sale" 
	forecl_trd="No. of Notices of Trustee Deed Sale"
	forecl_trd_res="No. of Notices of Trustee Deed Sale - Residential Parcels"
	forecl_trd_com="No. of Notices of Trustee Deed Sale - Commerical Parcels"
	forecl_trd_oth="No. of Notices of Trustee Deed Sale - Other Parcels"
	forecl_trd_sf="No. of Notices of Trustee Deed Sale - Single Family Homes"
	forecl_trd_condo="No. of Notices of Trustee Deed Sale - Condominiums"
	forecl_trd_coop="No. of Notices of Trustee Deed Sale - Cooperative Bldgs."
	forecl_trd_apt="No. of Notices of Trustee Deed Sale - Rental Apartment Bldgs."
	forecl_trd_ssl="No. of Parcels with Notice of Trustee Deed Sale"
	forecl_trd_res_ssl="No. of Residential Parcels with Notice of Trustee Deed Sale"
	forecl_trd_com_ssl="No. of Commercial Parcels with Notice of Trustee Deed Sale"
   	forecl_trd_oth_ssl="No. of Other Parcels with Notice of Trustee Deed Sale"
   	forecl_trd_sf_ssl="No. of Single Family Homes with Notice of Trustee Deed Sale"
   	forecl_trd_condo_ssl="No. of Condominiums with Notice of Trustee Deed Sale"
   	forecl_trd_coop_ssl="No. of Cooperative Bldgs. with Notice of Trustee Deed Sale"
   	forecl_trd_apt_ssl="No. of Rental Apartment Bldgs. with Notice of Trustee Deed Sale"
   	
   	forecl_ntc_cancel="No. of Notices of Foreclosure Cancellation"
   	forecl_ntc_cancel_ssl="No. of Parcels with Notices of Foreclosure Cancellation"
   	
   	allparcels="No. of Parcels in Geo"
   	parcel_res="No. of Residential Parcels in Geo"
   	parcel_com="No. of Commerical Parcels in Geo"
   	parcel_oth="No. of Other Parcels in Geo"
   	parcel_sf="No. of Single Family Homes in Geo"
   	parcel_condo="No. of Condominiums in Geo"
   	parcel_coop="No. of Cooperative Buildings in Geo"
   	parcel_apt="No. of Rental Apartment Buildings in Geo"
   	
   	;  	
   	
   	
   	run;
   
      
   ** Transpose data by year **;
 
  
   %let var = &sum_vars &sum_vars_ssl &sum_vars_rates allparcels parcel_res parcel_com parcel_oth
   parcel_sf parcel_condo parcel_coop parcel_apt;
   
   %super_transpose(
     data=ALL_Foreclosures_geo,
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
   	
   	array a {*} &sum_vars_wf;
   	
   	do i = 1 to dim( a );
   	  if missing( a{i} ) then a{i} = 0;
   	end;
   	
   	drop i;
   	
   run;
   
   x "purge [dcdata.rod.data]Foreclosures_sum&geosuf..*";
   
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


*options mlogic mprint symbolgen;
  
%Foreclosure_sum_geo( geo=GEOBLK2000, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=city, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ward2002, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=geo2000, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ANC2002, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=CASEY_NBR2003, start_yr=&start_yr, end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=CASEY_TA2003, start_yr=&start_yr, end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=CLUSTER_TR2000, start_yr=&start_yr, end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=EOR, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=PSA2004, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )
%Foreclosure_sum_geo( geo=ZIP, start_yr=&start_yr,end_yr=&end_yr, revisions=&revisions, register=&register )

run;

endrsubmit;


signoff;

   


