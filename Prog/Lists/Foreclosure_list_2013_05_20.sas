
/**************************************************************************
 Program:  Foreclosure_list_05_06_13.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   R. Pitingolo
 Created:  1/14/13
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create list of recent foreclosures with names and
 addresses.

 Modifications: ANW 7/20/10 Include whether or not property is more than 5 units
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

%let end_dt   = '20May2013'd;

%let previous_files =   Foreclosure_list_2013_01_14
						Foreclosure_list_2013_02_11
						Foreclosure_list_2013_02_20
						Foreclosure_list_2013_03_11
						Foreclosure_list_2013_03_18
						Foreclosure_list_2013_03_25
						Foreclosure_list_2013_04_01
						Foreclosure_list_2013_04_08
						Foreclosure_list_2013_04_15
						Foreclosure_list_2013_04_29
						Foreclosure_list_2013_05_06



					  
					   ;



******** DO NOT CHANGE BELOW THIS LINE ********;

%let start_dt = '01jan2013'd;
%let foreclosure_dat = Foreclosures_2013;

%let file_date = %sysfunc( translate( %sysfunc( putn( &end_dt, yymmddd10. ) ), '_', '-' ) );

%put file_date = &file_date;

%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;
%syslput file_date=&file_date;
%syslput previous_files=&previous_files;
%syslput foreclosure_dat=&foreclosure_dat;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=Rod 
  outlib=Work memtype=(data);
  select &previous_files;
run;

** Remove previously reported notices **;

data Prev_files;

  set &previous_files;

  keep filingdate documentno;

run;

proc sort data=Prev_files;
  by filingdate documentno;

data Foreclosures;

  merge
    Rod.&foreclosure_dat
      (where=(&start_dt <= filingdate <= &end_dt and ui_instrument in ('F1','D1','M1') and ui_proptype =: '1')
       drop=city cluster2000 eor instrument lot psa2004 square x_coord y_coord multiplelots xlot booktype)
    Prev_files (in=in_prev);
  by filingdate documentno;
  
  if not in_prev;
  
run;
    

proc sql noprint;
  create table Foreclosure_list as
  select * from 
    Foreclosures as f
    left join
    RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 hstd_code usecode address:) as p
    on f.ssl = p.ssl
  order by filingdate, documentno
;

run;

** Reformat owner address into single field **;

data Foreclosure_list;

  set Foreclosure_list;
  
  length owner_addr $ 500;
  
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );

run;

** Add owner_occ_sale flag **;

%create_own_occ( inds=Foreclosure_list, outds=Foreclosure_list )

** Download data set **;

proc download status=no
  data=Foreclosure_list 
  out=Rod.Foreclosure_list_&file_date;

run;

** Download formats **;

proc download status=no
  inlib=RealProp 
  outlib=RealProp memtype=(catalog);
  select Formats;

run;

endrsubmit;


ods path mystyles.template(update) sashelp.tmplmst(read);

proc template;
  define style template.minimal_mystyle;
  parent=styles.minimal;
    style _r from Data/
    htmlclass = '_r';
    style pagebreak from Data/
    htmlclass = 'pagebreak';
    style parskip from Data/
    htmlclass = 'parskip';
 	end;
	run;




** End submitting commands to remote server **;

ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Lists\Foreclosure_list_&file_date..xls" style=template.minimal_mystyle
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Notice of Foreclosure Sale");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('F1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp options( sheet_name="Foreclosure Default Notice");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('D1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp options( sheet_name="Foreclosure Mediation Certificate");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('M1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp options( sheet_name="Coop Notice of Foreclosure Sale");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('F1') and ui_proptype= "12";
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD UnitNo_Coop
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp options( sheet_name="Coop Foreclosure Default Notice");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('D1') and ui_proptype= "12";
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD UnitNo_Coop
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp options( sheet_name="Coop Foreclosure Mediation Certificate");
proc print data=Rod.Foreclosure_list_&file_date. label noobs;
  where ui_instrument in ('M1') and ui_proptype= "12";
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD UnitNo_Coop
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor   Verified;
  format Cluster_tr2000 $clus00f. zip $5.; 
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    ui_proptype = 'Property type' 
	usecode= 'Property use'
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;


ods tagsets.excelxp close;

ods listing;

run;

signoff;
