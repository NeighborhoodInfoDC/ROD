/**************************************************************************
 Program:  DISB.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  11/16/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create list of recent foreclosures with names and
 addresses.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
libname disb "D:\DCData\Libraries\ROD\Prog\DISB";

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

%let start_dt = '01jan2010'd;
%let end_dt   = '31dec2010'd;
%let month= Year;
%let yyyy= 2010;
%let mth= Yr;

******** DO NOT CHANGE BELOW THIS LINE ********;

%let foreclosure_dat = Foreclosures_2010;

%let file_date = %sysfunc( translate( %sysfunc( putn( &end_dt, yymmddd10. ) ), '_', '-' ) );

%put file_date = &file_date;

%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;
%syslput file_date=&file_date;
%syslput foreclosure_dat=&foreclosure_dat;

** Start submitting commands to remote server **;
rsubmit;
data Foreclosures;

  set
    Rod.foreclosures_2010
      (where= (ui_instrument in ('F1' 'F5') and ui_proptype =: '1')
       drop=casey_: city cluster2000 eor instrument lot psa2004 square x_coord y_coord multiplelots xlot booktype);
  by filingdate documentno;
  
  
run;  
  
proc sql noprint;
  create table Foreclosure_list as
  select * from 
    Foreclosures as f
    left join
    RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 mix1txtype hstd_code address: usecode) as p
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

if mix1txtype= "TA" then TaxAbate= "Yes";
 	else TaxAbate= "No";

if ui_instrument= "F5" then foreclosure_date = filingdate;
	else foreclosure_date=" ";

if ui_instrument= "F1" then foreclosure_notice= filingdate;
	else foreclosure_notice= " ";

if ui_proptype = '13' then do;
   		 if usecode in ( '023', '024' ) then new_proptype = '14';
    	else new_proptype = '15';
	 end;
	  else new_proptype = ui_proptype;

	
run;

** Add owner_occ_sale flag **;

%create_own_occ( inds=Foreclosure_list, outds=Foreclosure_list )

** Download data set **;

proc download status=no
  data=Foreclosure_list 
  out=disb.Foreclosure_list_&file_date;

run;

endrsubmit;

** End submitting commands to remote server **;


ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\DISB\Foreclosure_list_&yyyy..xls" style=minimal
      options(sheet_interval='page' );
	 

ods listing close;

ods tagsets.excelxp options( sheet_name="Foreclosure Report &yyyy. ");


proc format;
value $proptype
  "10" = "Single-family home"   
  "11" = "Condominium unit"   
  "12" = "Cooperative building"     
  "13" = "Rental apartment building"     
  "14" = "Rental Apartment Less than 5 Units"
  "15" = "Rental Apartment 5+ Units" 
  "20" = "Retail"     
  "21" = "Office"     
  "22" = "Parking garage/lot"     
  "23" = "Industrial"
  "24" = "Hotel/motel"    
  "29" = "Other"
  "30" = "Group quarters"
  "40" = "Garage"
  "50" = "Unimproved land"    
  "51" = "Vacant With structures"   
 "99" = "Unknown";
run; 


proc print data=disb.Foreclosure_list_&file_date. label noobs;
	where ui_instrument in ('F1' 'F5');
   var foreclosure_notice foreclosure_date DocumentNo new_proptype SSL PREMISEADD UnitNo_Coop
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor ui_instrument TaxAbate Verified;
  format Cluster_tr2000 $clus00f. zip $5. Ward2002 $1. ANC2002 $2. new_proptype $proptype. foreclosure_date MMDDYY10.
		geo2000 $GEO00B. cluster_tr2000 $CLUS00G. foreclosure_notice mmddyy10.;
  label 
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    foreclosure_notice = 'Foreclosure Notice Date'
    new_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
	UnitNo_Coop = 'Cooperative Unit No.'
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
    Grantor = 'Lender/servicer/agent'
	taxabate= 'Tax Abatement'
	foreclosure_date= 'Foreclosure Sale Date';
	title "Foreclosure List &month.";
	run;

ods tagsets.excelxp close;

ods listing;

run;
