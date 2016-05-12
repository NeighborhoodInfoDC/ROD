/**************************************************************************
 Program:  Foreclosure_list.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/10/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create list of recent foreclosures with names and
addresses.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

%let start_dt = '01oct2008'd;
%let end_dt   = '24nov2008'd;

%let file_date = %sysfunc( translate( %sysfunc( putn( &end_dt, yymmddd10. ) ), '_', '-' ) );

%put file_date = &file_date;

%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;
%syslput file_date=&file_date;

** Start submitting commands to remote server **;

rsubmit;

proc sql noprint;
  create table Foreclosure_list as
  select * from 
    Rod.Foreclosures_2008 
      (where=(&start_dt <= filingdate <= &end_dt and ui_instrument in ('F1') and ui_proptype =: '1')
       drop=casey_: city cluster2000 eor instrument lot psa2004 square x_coord y_coord multiplelots xlot booktype)
      as f
    left join
    RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 hstd_code address:) as p
    on f.ssl = p.ssl
  order by filingdate, documentno
;

run;

data Foreclosure_list;

  set Foreclosure_list;
  
  length owner_addr $ 500;
  
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );

run;

proc download status=no
  data=Foreclosure_list 
  out=Rod.Foreclosure_list_&file_date;

run;

endrsubmit;

** End submitting commands to remote server **;

ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Foreclosure_list_&file_date..xls" style=minimal
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Notice of foreclosure sale");

proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('F1');
  var FilingDate DocumentNo ui_proptype SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor Verified;
  format Cluster_tr2000 $clus00f.;
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp close;

ods listing;

run;

signoff;
