/**************************************************************************
 Program:  Foreclosure_forweb
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/16/2017
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = rod; /* Library of the summary data to be transposed */
%let outfolder = foreclosures; /* Name of folder where output CSV will be saved */
%let sumdata = foreclosures_sum; /* Summary dataset name (without geo suffix) */
%let start = 1995; /* Start year */
%let end = 2013; /* End year */
%let keepvars = forecl_ssl_sf_condo forecl_ssl_1kpcl_sf_condo trustee_ssl_sf_condo trustee_ssl_1kpcl_sf_condo; /* Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

label forecl_ssl_sf_condo = "SF homes/condos receiving foreclosure notice";
label forecl_ssl_1kpcl_sf_condo = "Foreclosure notice rate per 1,000";
label trustee_ssl_sf_condo = "SF homes/condos receiving trustee deed sale notice";
label trustee_ssl_1kpcl_sf_condo = "Trustee deed sale rate per 1,000";

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);
			 
%web_transpose(&library., &outfolder., &sumdata., &geo., &start., &end., &keepvars. );

/* Load transposed data, create indicators for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;

/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo._metadata..csv";
	proc print data =&sumdata._&geo._metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo..csv";
	proc print data =&sumdata._&geo._long_allyr noobs;
	run;
ods csv close


%mend csv_create;
%csv_create (tr10);
%csv_create (tr00);
%csv_create (anc12);
%csv_create (wd02);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);

