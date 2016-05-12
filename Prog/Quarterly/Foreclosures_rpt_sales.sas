 filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt_sales.log";
 filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_rpt_sales.lst";
 proc printto print=outnew log=lognew new;
 run;
/**************************************************************************
 Program:  Foreclosures_qtr_sales.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create quarterly & yearly foreclosure data sets for 
 generating summary tables.

 Modifications: 2/5/10 L Hendey - Adjusted for Quarterly ROD 
				4/14/10 L Hendey - Added variables to output including prev_sale_ownocc and reo.
				4/26/10 L Hendey - Added ANC to output
				9/15/10 L Hendey - Modified for Sales 
 		        2/05/11 L Hendey - Modified for Sales_Master_forecl
 				12/9/11 R Grace - Updated file paths to include quarterly folder
**************************************************************************/


%let suffix = &val_suffix.;
%let end_dt = &val_end.;

rsubmit;
proc download data=realprop.sales_master_forecl 
	out=sales_master_forecl;
run;
endrsubmit; 


data sale_qtr;
	set sales_master_forecl;

	where ui_proptype in ('10','11');

format adj_sale_date  mmddyy10.;
length total_sale total_sale_sht sale_mkt sale_reo_enter sale_fc_noreo sale_d_noreo sale_reo_exit sale_oth_nm 3;

adj_sale_date=intnx( "qtr", saledate, 0, 'end' );


if sale_code ne . then total_sale = 1;
if sale_code_sht ne . then total_sale_sht=1; *no buyer=seller;

if sale_code_sht ne . then do;
	if sale_code_sht=1 then sale_mkt=1; else sale_mkt=0;
	if sale_code_sht=2 then sale_reo_enter=1; else sale_reo_enter=0;
	if sale_code_sht=3 then sale_fc_noreo=1; else sale_fc_noreo=0;
	if sale_code_sht=4 then sale_d_noreo=1; else sale_d_noreo=0; 
	if sale_code_sht=5 then sale_reo_exit=1; else sale_reo_exit=0; 
	if sale_code_sht=6 then sale_oth_nm=1; else sale_oth_nm=0;
	
end;


run;

 
proc freq data=sale_qtr;
title1 "Accept code for other non-market sales";
where sale_oth_nm=1 and sale_code ne 10 and adj_sale_date=&end_dt.;
tables acceptcode;
run;


/** Macro Geo - Start Definition **/

%macro Geo( geo=, geosuf= );
proc sort data=sale_qtr;
by &geo. adj_sale_date ;
proc summary data=sale_qtr;
by &geo. adj_sale_date;
var total_sale total_sale_sht sale_mkt sale_reo_enter sale_fc_noreo sale_d_noreo sale_reo_exit sale_oth_nm;
output out=sale_qtr_sum sum=;
run;

data sale_qtr_sum_&geosuf.;
	set sale_qtr_sum (where=(&geo. ne " "));

pct_sale_mkt=(sale_mkt/total_sale_sht)*100;
pct_sale_reo_enter=(sale_reo_enter/total_sale_sht)*100;
pct_sale_fc_noreo=(sale_fc_noreo/total_sale_sht)*100;
pct_sale_d_noreo=(sale_d_noreo/total_sale_sht)*100;
pct_sale_reo_exit=(sale_reo_exit/total_sale_sht)*100;
pct_sale_oth_nm=(sale_oth_nm/total_sale_sht)*100;


run;

%mend;

%Geo( geo=ward2002, geosuf=wd02 )

%Geo( geo=cluster_tr2000, geosuf=cltr00 )

%Geo( geo=city, geosuf=city )

** Add wards to cluster file, resort **;

data sale_qtr_sum_cltr00;

  set sale_qtr_sum_cltr00;

  ** Cluster ward var **;
  
  length ward2002 $ 1;
  
  ward2002 = put( cluster_tr2000, $cl0wd2f. );
  
  label ward2002 = 'Ward (cluster-based)';
  
run;

** Merge transposed data together **;

data ROD.Forecl_sale_cluster_tbl_&suffix.;

  set sale_qtr_sum_city sale_qtr_sum_wd02 sale_qtr_sum_cltr00;
  
  ** Remove noncluster areas **;
  
  if cluster_tr2000 = '99' then delete;

run;

proc sort data=ROD.Forecl_sale_cluster_tbl_&suffix.;
  by adj_sale_date ward2002 cluster_tr2000;
run;

%File_info( data=ROD.Forecl_sale_cluster_tbl_&suffix., printobs=0 )

proc print data=ROD.Forecl_sale_cluster_tbl_&suffix.;
  id city ward2002 cluster_tr2000;
  title2 "File = Table";
run;
title2;

data file_output;
	set ROD.Forecl_sale_cluster_tbl_&suffix.;

if ward2002=" " and city=" " and cluster_tr2000=" " then delete;

run;

proc sort data=file_output;
by ward2002 cluster_tr2000;
run;
**** Write data to Excel table ****; ***BUYER=SELLER EXCLUDED;

/** Macro Output- Start Definition **/

%macro Output_table( start_row=, end_row=, sheet= );

  filename xout dde  "excel|D:\DCData\Libraries\ROD\Prog\Quarterly\[DC Forecl Sale Wd Cls &suffix..xls]&sheet!R&start_row.C1:R&end_row.C17" 
    lrecl=1000 notab;

  data _null_;

    file xout;
    
    set file_output (where=( adj_sale_date =&end_dt.));
    by ward2002;
    
    cluster_num = input( cluster_tr2000, 2. );
    
    if ward2002 = '' then 
      put 'Washington, D.C. Total' '09'x '09'x '09'x '09'x @;
    else if Cluster_tr2000 = '' then 
      put ward2002 '09'x '09'x '09'x '09'x @;
    else
      put '09'x cluster_num '09'x '09'x Cluster_tr2000 $clus00s. '09'x @;
      
    put  
      total_sale_sht '09'x 
      pct_sale_mkt '09'x 
      pct_sale_reo_enter '09'x 
      pct_sale_fc_noreo '09'x 
      pct_sale_d_noreo '09'x
      pct_sale_reo_exit '09'x
      pct_sale_oth_nm '09'x 
      
      ;
      
    if last.ward2002 then put;
    
  run;

  filename xout clear;

%mend Output_table;

/** End Macro Definition **/

options missing='-';

** Write table **;

%Output_table( 
  sheet = Sales by Cluster,
  start_row = 8, 
  end_row = 63
)


proc sort data=sale_qtr_sum_city;
by adj_sale_date;

*city trend output;
data Csv_out(compress=no);

  set sale_qtr_sum_city;
  
  where  '31dec2002'd < adj_sale_date <= &end_dt.;

  keep adj_sale_date city total_: pct_: ;
  
run;

filename fexport "&_dcdata_path\Rod\Prog\Quarterly\Foreclosures_sale_city_&suffix..csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

***ward only output;
proc sort data=sale_qtr_sum_wd02;
by adj_sale_date;
proc transpose data=Sale_qtr_sum_wd02 out=wd2002;
id ward2002;
by adj_sale_date;
run;
data Csv_out(compress=no);

  set wd2002;
  
  where  adj_sale_date = &end_dt. and _name_ not in("_TYPE_" "_FREQ_" "sale_mkt" "sale_reo_enter" "sale_fc_noreo" "sale_d_noreo" 
							"sale_reo_exit" "sale_oth_nm");

  keep adj_sale_date _name_ ward: ;
  
run;


filename fexport "&_dcdata_path\Rod\Prog\Quarterly\Foreclosures_sale_wd_&suffix..csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;


**cluster only output;
data Csv_out(compress=no);

  set Sale_qtr_sum_cltr00;
  
  where  adj_sale_date =&end_dt.;

    keep adj_sale_date  Cluster_tr2000 total_: pct_: ward2002;
run;


filename fexport "&_dcdata_path\Rod\Prog\Quarterly\Foreclosures_sale_cls_&suffix..csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

proc printto;
run;
