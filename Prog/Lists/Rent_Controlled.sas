/**************************************************************************
 Program:  Rent_Controlled.sas
 Library:  ROD
 Project:  DC Foreclosures
 Author:   A. Williams
 Created:  12/03/09
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Creates rent controlled buildings/units database
 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
options  mprint symbolgen;

%DCData_lib( Rod )
%DCData_lib( RealProp )

libname data "D:\DCData\Libraries\ROD\Data";

rsubmit;

/*Download parcel base file*/
proc download data=realprop.parcel_base out = realprop.parcel_base;
run;

proc download data=realprop.parcel_geo out = realprop.parcel_geo;
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

/**************************************************
**************************************************
1. Restrict to Rental units that are not tax exempt 
(Exclude commercial, hotel properties, condos, single-family, coops, etc)
**************************************************/;
data rental_1;
	set realprop.Parcel_base;
	where ui_proptype = "13";
	if MIX2TXTYPE = "TX" or MIX1TXTYPE = "TX";
	run;

/**************************************************
**************************************************
2. Merge on Camarespt file (obtained from Peter Tatian) to get the AYB (Actual year built)
	2.1. Exclude properties built after Dec. 31, 1975
**************************************************/;
data Camarespt (keep= ssl ayb);
	set data.Camarespt;
	run;

proc sort data= camarespt;
	by ssl;
	run;

data camacommpt;
	set data.camacommpt;
	run;

proc sort data= camacommpt;
	by ssl;
	run;

proc sort data= rental_1;
	by ssl;
	run;

data rental_2;
	merge camarespt (in=a)  camacommpt (in=c) rental_1 (in=b);
	by ssl;
	if b=1;
	/*2.1 Restrict to buildings built before 1976*/
	if 0 < ayb < 1976; 
	run;



/**************************************************
**************************************************
3. Merge on Assisted units--obtained from Peter
	3.1. Exclude properties receiving a federal or district subsidy
**************************************************/;

proc format;
value progcat
 
   1 = 'Public Housing only'
    2 = 'Section 8 only'
    9 = 'Section 8 and other subsidies'
    3 = 'LIHTC only'
    8 = 'LIHTC and Tax Exempt Bond only'
    4 = 'HOME only'
    5 = 'CDBG only'
    6 = 'HPTF only'
    7, 10 = 'All other combinations';
	run;

data Assisted_units (keep= ssl ProgCat subsidized);
	set data.Assisted_units;
	subsidized= 1;
	format progcat progcat.;
	run;

proc sort data=assisted_units;
	by ssl;

data rental_3;
	merge rental_2 (in=a) assisted_units (in=b);
	if a;
	by ssl;
	run;

data rental_4;
	set rental_3;
	where subsidized ne 1;
	if subsidized ne 1 then subsidized=0;
	run;


/**************************************************
**************************************************
4. Exclude rental units owned by a person who own 4 units or less
**************************************************/;

*Create new dummy variable to indicate if property is greater than 5;
data rental_4_1;
set rental_4;
if usecode in ("025" "021" "022" "015") then units5=1;
else units5=0;
run;

proc sort data= rental_4_1;
by ownername;
run;

*For smaller properties, we need to summarize by owner to see if they own more than 4;
proc summary data=rental_4_1;
by ownername;
var _numeric_;
where usecode in ("023" "024");
output out= rental_4_2 (keep=ownername _Freq_);
run;

data rental_4_3 (Drop= _freq_);
set rental_4_2;
where _freq_ ge 5; *assign units5=1 to only properties were the owner owns 5 or more properties;
units5=1;
run;

proc sort data=rental_4_3;
by ownername;
run;

*Merge small property list back on to bigger one so that we have the updated values for the units5 variable;
data rental_4_4;
merge rental_4_1 (in=a) rental_4_3(in=b);
by ownername;
run;

** Reformat owner address into single field **;
data rental_5;
	set rental_4_4;
	where units5=1;
  length owner_addr $ 500;
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );
run;


/**************************************************
**************************************************
5. Merge with OCTO's rental unit address database to get unit addresses and counts
**************************************************/;


/**************************************************
**************************************************
6. Add on property address, ward, ANC, neighborhood cluster, and census tract
**************************************************/;
proc sort data= realprop.parcel_geo;
by ssl;
run;

proc sort data= rental_5;
by ssl;
run;

data rental_6;
merge rental_5 (in=a) realprop.parcel_geo (in=b keep= ssl ANC2002 Ward2002  Cluster2000  geo2000 Cluster_tr2000 zip) ;
by ssl;
if a=1 and b=1;
run;




ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Lists\Rent_Control.xls" style=minimal
      options(sheet_interval='page' );
	 
ods listing close;
ods tagsets.excelxp options( sheet_name="DC Rent Controlled Foreclosed Properties");


proc format;
value $proptype
  "10" = "Single-family home"   
  "11" = "Condominium unit"   
  "12" = "Cooperative building"     
  "13" = "Rental apartment building"     
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


proc print data=rental_6 label noobs;
  var SSL saledate usecode ui_proptype PREMISEADD Zip ANC2002 Ward2002   geo2000 Cluster_tr2000  ayb MIX1TXTYPE MIX2TXTYPE 
      OWNERNAME OWNNAME2 owner_addr hstd_code    ;
  format ui_proptype $proptype. usecode $usecode. ;
  label 
   
    ayb = 'Year Built'
	ui_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    OWNERNAME = '1st owner name (from OTR)'
    OWNNAME2 = '2nd owner name (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
	owner_addr = 'Owner Address';
	title "Rent Controlled";
	
	run;

ods tagsets.excelxp close;

ods listing;

run;
