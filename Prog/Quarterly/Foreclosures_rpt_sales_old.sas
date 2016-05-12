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
**************************************************************************/


proc format;
	value salecod
						           
1="Trustees Deed (matching sale) and REO"
2="Trustees Deed (matching sale) and Not REO"
3="Trustees Deed (no matching sale)"
4="Distressed Sale & REO"
5="Distressed Sale & not REO"
6="Market Sale (more than a year after last Fc notice)"
7="Market Sale - no previous fc episode"
8="REO Exit"
9="REO Transfer"
10="Buyer=Seller"
11="Other";


run;

%let suffix = &val_suffix.;
%let end_dt = &val_end.;

rsubmit;
proc download data=realprop.square_geo 
	out=realprop.square_geo;
run;
endrsubmit; 


data sale_qtr;
	set rod.foreclosures_history_sale;

	where prev_sale_prp in ('10','11');

format adj_sale_date  mmddyy10.;
length total_sale sale_td_reo sale_td_oth sale_td_nomatch sale_d_reo sale_d_oth sale_mkt_fc sale_mkt_oth sale_other
		sale_reo_exit sale_reo_trans sale_buyeqsell total_sale2 3
		square $4.;

adj_sale_date=intnx( "qtr", post_sale_date, 0, 'end' );

if post_sale_date=. and outcome_date ne . then adj_sale_date=intnx( "qtr", outcome_date, 0, 'end' );

if sale_code ne . then total_sale = 1;
if sale_code not in (. 10) then total_sale2=1; *no buyer=seller;

if sale_code ne . then do;
	if sale_code=1 then sale_td_reo=1; else sale_td_reo=0;
	if sale_code=2 then sale_td_oth=1; else sale_td_oth=0;
	if sale_code=3 then sale_td_nomatch=1; else sale_td_nomatch=0;
	if sale_code=4 then sale_d_reo=1; else sale_d_reo=0; 
	if sale_code=5 then sale_d_oth=1; else sale_d_oth=0; 
	if sale_code=6 then sale_mkt_fc=1; else sale_mkt_fc=0;
	if sale_code=7 then sale_mkt_oth=1; else sale_mkt_oth=0;
	if sale_code=8 then sale_reo_exit=1; else sale_reo_exit=0;
	if sale_code=9 then sale_reo_trans=1; else sale_reo_trans=0;
	if sale_code=10 then sale_buyeqsell=1; else sale_buyeqsell=0;
	if sale_code=11 then sale_other=1; else sale_other=0;
end;

square=substr(ssl,1,4);

run;
** Separate into Files with and w/o geo **;
  
  proc sql;
    create table _read_forecl_a  as
    select *
    	from sale_qtr
    	   where ward2002 eq " ";
  quit;
  run;
  
  proc sql;
    create table _read_forecl_b as
    select *
    	from  sale_qtr
    	   where ward2002 ne " ";
  quit;
  run;
  
   
  ** Merge in Square geo **;
  proc sql;
      create table _read_forecl_c as
      select *
      	from _read_forecl_a (drop= Anc2002 Casey_nbr2003 Casey_ta2003 City Cluster2000
      	Cluster_tr2000 Eor Psa2004 Ward2002 Zip Geo2000 GeoBlk2000) as a 
      	left join RealProp.Square_geo (drop=CJRTRACTBL) as geo
      		on (a.square = geo.square)
      order by  adj_sale_date;
    quit;
  run;
  
  ** Merge all back together **;
   
  data  sale_qtrs ;
       set _read_forecl_b _read_forecl_c;
   
  run;
 
proc freq data=sale_qtrs;
where sale_other=1 & adj_sale_date='31mar2010'd;
tables post_sale_accept;
run;

proc print data=sale_qtr;
where sale_code=3 and adj_sale_date='31dec2005'd;
var ssl prev_sale_date prev_sale_owner outcome_date tdeed_grantee next_sale_date next_sale_owner;
run;

/** Macro Geo - Start Definition **/

%macro Geo( geo=, geosuf= );
proc sort data=sale_qtrs;
by &geo. adj_sale_date ;
proc summary data=sale_qtrs;
by &geo. adj_sale_date;
var total_sale total_sale2 sale_td_reo sale_td_oth sale_td_nomatch sale_d_reo sale_d_oth sale_mkt_fc sale_mkt_oth sale_other
	sale_reo_exit sale_reo_trans sale_buyeqsell;
output out=sale_qtr_sum sum=;
run;

data sale_qtr_sum_&geosuf.;
	set sale_qtr_sum (where=(&geo. ne " "));

pct_sale_td_reo=(sale_td_reo/total_sale)*100;
pct_sale_td_oth=(sale_td_oth/total_sale)*100;
pct_sale_td_nomatch=(sale_td_nomatch/total_sale)*100;
pct_sale_d_reo=(sale_d_reo/total_sale)*100;
pct_sale_d_oth=(sale_d_oth/total_sale)*100;
pct_sale_mkt_fc=(sale_mkt_fc/total_sale)*100;
pct_sale_mkt_oth=(sale_mkt_oth/total_sale)*100;
pct_sale_reo_exit=(sale_reo_exit/total_sale)*100;
pct_sale_reo_trans=(sale_reo_trans/total_sale)*100;
pct_sale_buyeqsell=(sale_buyeqsell/total_sale)*100; 
pct_sale_other=(sale_other/total_sale)*100;

pct2_sale_td_reo=(sale_td_reo/total_sale2)*100;
pct2_sale_td_oth=(sale_td_oth/total_sale2)*100;
pct2_sale_td_nomatch=(sale_td_nomatch/total_sale2)*100;
pct2_sale_d_reo=(sale_d_reo/total_sale2)*100;
pct2_sale_d_oth=(sale_d_oth/total_sale2)*100;
pct2_sale_mkt_fc=(sale_mkt_fc/total_sale2)*100;
pct2_sale_mkt_oth=(sale_mkt_oth/total_sale2)*100;
pct2_sale_reo_exit=(sale_reo_exit/total_sale2)*100;
pct2_sale_reo_trans=(sale_reo_trans/total_sale2)*100;
pct2_sale_other=(sale_other/total_sale2)*100;

pct_market=pct_sale_mkt_fc + pct_sale_mkt_oth;
pct_reo=pct_sale_td_reo + pct_sale_td_nomatch + pct_sale_d_reo + pct_sale_reo_trans;
pct_td=pct_sale_td_reo + pct_sale_td_oth + pct_sale_td_nomatch;
pct_d=pct_sale_d_reo + pct_sale_d_oth;
pct_other=pct_sale_other + pct_sale_buyeqsell;

pct2_market=pct2_sale_mkt_fc + pct2_sale_mkt_oth;
pct2_reo=pct2_sale_td_reo + pct2_sale_td_nomatch + pct2_sale_d_reo + pct2_sale_reo_trans;
pct2_td=pct2_sale_td_reo + pct2_sale_td_oth + pct2_sale_td_nomatch;
pct2_d=pct2_sale_d_reo + pct2_sale_d_oth;


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
**** Write data to Excel table ****;

/** Macro Output- Start Definition **/

%macro Output_table( start_row=, end_row=, sheet= );

  filename xout dde  "excel|D:\DCData\Libraries\ROD\Prog\[DC Forecl Sale Wd Cls &suffix..xls]&sheet!R&start_row.C1:R&end_row.C17" 
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
      total_sale '09'x 
      pct_market '09'x 
      pct_reo '09'x 
      pct_sale_td_oth '09'x 
      pct_sale_d_oth '09'x
	  pct_sale_reo_exit '09'x
      pct_other '09'x 
      
      ;
      
    if last.ward2002 then put;
    
  run;

  filename xout clear;

%mend Output_table;

/** End Macro Definition **/

options missing='-';

** Write table **;

%Output_table( 
  sheet = Includes Buyer=Seller,
  start_row = 8, 
  end_row = 63
)
%macro Output_table( start_row=, end_row=, sheet= );

  filename xout dde  "excel|D:\DCData\Libraries\ROD\Prog\[DC Forecl Sale Wd Cls &suffix..xls]&sheet!R&start_row.C1:R&end_row.C17" 
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
      total_sale2 '09'x 
      pct2_market '09'x 
      pct2_reo '09'x 
      pct2_sale_td_oth '09'x 
      pct2_sale_d_oth '09'x
	  pct2_sale_reo_exit '09'x
      pct2_sale_other '09'x 
      
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

  keep adj_sale_date city total_sale pct_: total_sale2 pct2_:;
  
run;

filename fexport "&_dcdata_path\Rod\Prog\Foreclosures_sale_city_&suffix..csv" lrecl=1000;

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
  
  where  adj_sale_date ='30jun2010'd and _name_ not in("_TYPE_" "_FREQ_" "sale_td_reo" "sale_td_oth" "sale_td_nomatch" "sale_d_reo" 
														"sale_d_oth" "sale_mkt_fc" "sale_mkt_oth" "sale_other" "sale_reo_exit" 
													    "sale_reo_trans" "sale_buyeqsell");

  keep adj_sale_date _name_ ward: ;
  
run;


filename fexport "&_dcdata_path\Rod\Prog\Foreclosures_sale_wd_&suffix..csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;


**cluster only output;
data Csv_out(compress=no);

  set Sale_qtr_sum_cltr00;
  
  where  adj_sale_date ='30jun2010'd ;

    keep adj_sale_date  Cluster_tr2000 total_sale pct_: total_sale2 pct2_: ward2002;
run;


filename fexport "&_dcdata_path\Rod\Prog\Foreclosures_sale_cls_&suffix..csv" lrecl=1000;

proc export data=Csv_out
    outfile=fexport
    dbms=csv replace;

run;

proc printto;
run;
