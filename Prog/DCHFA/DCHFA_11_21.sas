/**************************************************************************
 Program:  DCHFA_June30.sas
 Library:  ROD
 Project:  DC Foreclosures
 Author:   A. Williams
 Created:  11/12/09
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Create foreclosure data set to send to the DC Housing Finance Agency with Foreclosures
				as of June 30th, 2009
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
options  mprint symbolgen;


%let date= '30jun2009'd;
%let date2= 30Jun2009;
%let today= '12nov2009'd;

%DCData_lib( Rod )
%DCData_lib( RealProp )


/*Download foreclosure history file*/
rsubmit;


proc download data=rod.foreclosures_history out = rod.foreclosure_history;
run;

/*Download parcel base file*/
proc download data=realprop.parcel_base out = realprop.parcel_base;
run;

/*Download formats*/
proc download status=no
  inlib=RealProp 
  outlib=RealProp memtype=(catalog);
  select Formats; 
run;

proc download status=no
  inlib=ROD 
  outlib=ROD memtype=(catalog);
  select Formats; 
run;

endrsubmit;
signoff;

proc contents data= rod.foreclosure_history;
run;

/*Create foreclosure history file from alpha file*/
data foreclosure_history;
set rod.foreclosure_history;
	** Set episode dates **;
    where ui_proptype in ("12", "13");
    if not( missing( firstnotice_date ) ) then start_dt = firstnotice_date;
    else if not( missing( outcome_date ) ) then start_dt = outcome_date - 365;
    
    if not( missing( outcome_date ) ) then end_dt = outcome_date;
    else if not( missing( lastnotice_date ) ) then end_dt = lastnotice_date + 365;
    else if not( missing( firstnotice_date ) ) then end_dt = firstnotice_date + 365;
    
    if missing( start_dt ) or missing( end_dt ) then delete;
	

	adj_start_dt = intnx( "year", start_dt, 0, 'beginning');
    adj_end_dt = intnx( "year", end_dt, 0, 'beginning');

	format start_dt end_dt mmddyy10. adj_start_dt adj_end_dt mmddyy10.;

	run;

/*Create data set with foreclosures within a certain time period*/
data foreclosures_date;
	set foreclosure_history;
	where adj_start_dt >= '1jan2009'd or adj_end_dt >= '1jan2009'd;
	run;

proc sort data=foreclosures_date;
by start_dt;
run;
** Merge with Parcel base file to get addresses**;
proc sort data= foreclosures_date;
	by ssl;
	run;

proc sort data=realprop.parcel_base;
	by ssl;
	run;

data foreclosure_w_address;
	merge foreclosures_date (in=a) realprop.parcel_base (in=b);
	by ssl;
	if a=1 and b=1;
	run;

proc format;
value $proptyp
  "10" = "Single-family home"   
  "11" = "Condominium unit"   
  "12" = "Cooperative building"     
  "13" = "Rental apartment building"  
  "14" = "Apt Building--less than 5 units"
  "15" = "Apt Building--more than 5 units" 
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

** Reformat owner address into single field **;
data foreclosures_w_address2;
  set foreclosure_w_address;
  length owner_addr $ 500;
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );
	if end_dt> &today. then end_dt=" ";

  ** break out rental multifamily **;

  if ui_proptype = '13' then do;
  if usecode in ( '023', '024' ) then new_proptype = '14'; *this is apartment buildings with less than 5 units;
  else new_proptype = '15'; *this is apartment buildings with 5 or more units; 
  end;
  else new_proptype = ui_proptype;

format new_proptype $proptyp. prev_sale_ownocc dyesno. outcome_code outcome.;

run; 

proc sort data=foreclosures_w_address2 out=rod.dchfa_&date2. dupout= duplicate nodupkey;
by ssl;
run;

ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Lists\DCHFA_&date2..xls" style=minimal
      options(sheet_interval='page' );
	 

ods listing close;

ods tagsets.excelxp options( sheet_name="Foreclosures in process as of June 30th ");

proc print data=rod.dchfa_&date2. label noobs;
	var
	start_dt lastnotice_date  outcome_date
	outcome_code num_notice
	new_proptype SSL PREMISEADD Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
	prev_sale_ownocc lastnotice_grantee OWNERNAME OWNNAME2 owner_addr lastnotice_grantor
		;

	where ui_instrument in ('F1' 'F5');
	  label 

	Start_Dt= "Date of first notice"
	UI_instrument = 'Instrument'
    New_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    lastnotice_grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    prev_sale_ownocc = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    lastnotice_grantor = 'Lender/servicer/agent';


	title "test";
	run;

ods tagsets.excelxp close;

ods listing;

run;

