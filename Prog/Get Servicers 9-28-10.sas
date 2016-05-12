/**************************************************************************
 Program:  Get Servicers.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   L Hendey
 Created: 09/28/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a SAS View with all foreclosure notice files. and pull servicer names
	to find GMAC etc.

 Modifications: 
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )


** Start submitting commands to remote server **;

rsubmit;

proc download status=no
  inlib=Rod 
  outlib=Rod memtype=(data);
  select Foreclosures_:;

run;

endrsubmit;

** End submitting commands to remote server **;

data ROD.Foreclosures_1999_2010 / view=ROD.Foreclosures_1999_2010;

  set
    Rod.Foreclosures_1999
    Rod.Foreclosures_2000
    Rod.Foreclosures_2001 
    Rod.Foreclosures_2002 
    Rod.Foreclosures_2003 
    Rod.Foreclosures_2004 
    Rod.Foreclosures_2005
    Rod.Foreclosures_2006
    Rod.Foreclosures_2007 
    Rod.Foreclosures_2008
    Rod.Foreclosures_2009
    Rod.Foreclosures_2010
  ;

  length grantor_r $200;

  notice_yr=year(filingdate);
  grantor_r=propcase(grantor);
  %lendernames;
run;
proc freq data=rod.foreclosures_1999_2010;
where grantor_recode=" " and grantor ne " " and ui_instrument="F1" and notice_yr ge 2006;
tables grantor_r;
run;
proc freq data=rod.Foreclosures_1999_2010;
where ui_instrument="F1" and notice_yr ge 2007 and ui_proptype in ('10' '11' '12' '13');
tables  Grantor*notice_yr  Grantor_recode*notice_yr  /nopct nocol norow;
run;
ods rtf file="D:\DCDATA\Libraries\ROD\Prog\Servicers_07_10.rtf";
proc freq data=rod.Foreclosures_1999_2010;
where ui_instrument="F1" and notice_yr ge 2007 and ui_proptype in ('10' '11' '12' '13');
tables  Grantor*notice_yr /nopct nocol norow;
run;
ods rtf close;
ods rtf file="D:\DCDATA\Libraries\ROD\Prog\Servicers_10_06.rtf";
proc freq data=rod.Foreclosures_1999_2010;
where ui_instrument="F1" and notice_yr ge 2007 and ui_proptype in ('10' '11' '12' '13');
tables  Grantor_recode*notice_yr  /nopct nocol norow missprint;
run;
ods rtf close;
data servicers;
	set rod.Foreclosures_1999_2010;

/*where ui_instrument="F1" and notice_yr ge 2007 and ui_proptype in ('10' '11' '12' '13')
and Grantor in("Gmac Mo Gage Inc" "Gmac Morgtage Llc" "Gmac Mortaaae Llc" "Gmac Mortagage Llc" 
"Gmac Mortgage" "Gmac Mortgage Corporation" "Gmac Mortgage Inc" "Gmac Mortgage Llc" 
"Gmac Mortgage Llc /Homecomings" "Gmac Mortgage Llc Homecomings" "Gmac Mortgage Llc/ Homecomings"
"Gmac Mortgage Llc/Homecomings" "Gmac Mortgage, Inc." "Gmac Mortgage, Llc" 
"Gmac Mortgage/Homecomings")*/

where ui_instrument="F1" and notice_yr ge 2007 and ui_proptype in('10' '11' '12' '13')
	and Grantor_recode in("GMAC" "Litton Loan Servicing" "Aurora Loan Services" "Bank of America"  "JPMorgan Chase"
	"Citi" "Countrywide" "National City" "PNC Bank" "US Bank" "Wachovia" "Washington Mutual" "Wells Fargo" "World Savings"
"Residential Capital, LLC" "HSBC");


run;



%let end_dt   = '30Sep2010'd;
%let start_dt = '01jan2007'd;
%let foreclosure_dat = Foreclosures_2010;

%let file_date = %sysfunc( translate( %sysfunc( putn( &end_dt, yymmddd10. ) ), '_', '-' ) );

%put file_date = &file_date;

rsubmit;
%syslput start_dt=&start_dt;
%syslput end_dt=&end_dt;
%syslput file_date=&file_date;
%syslput previous_files=&previous_files;
%syslput foreclosure_dat=&foreclosure_dat;

proc upload data=servicers out=work.servicers;
run;

proc sql noprint;
  create table Foreclosure_servicers as
  select * from 
    servicers as f
    left join
    RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 hstd_code usecode address:) as p
    on f.ssl = p.ssl
  order by filingdate, documentno
;

run;

** Reformat owner address into single field **;

data Foreclosure_servicers;

  set Foreclosure_servicers;
  
  length owner_addr $ 500;
  
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );

run;

** Add owner_occ_sale flag **;

%create_own_occ( inds=Foreclosure_servicers, outds=Foreclosure_servicers )

** Download data set **;
proc download data=foreclosure_servicers out=rod.foreclosure_servicers;
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

ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Servicer_list_&file_date..xls" style=template.minimal_mystyle
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Notice of foreclosure sale");

proc print data=Rod.Foreclosure_servicers label noobs;
  where ui_instrument in ('F1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor Grantor_recode  Verified;
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
    Grantor = 'Lender/servicer/agent'
	Grantor_recode='Lender/servicer/agent Recoded';

run;

ods tagsets.excelxp close;

ods listing;

run;

data history;
	set rod.foreclosures_history;
where /*ssl in( "3672    0060" "5870    0073" "4062    0202" "5045    0012" "1810    0017" "5881    0039" "3732    0113"
"5764    0040" "1043    0829" "0986    0064" "0615    0061" "0341    2150" "0540    2239" "5725    0009" "5971    0802" "0281    2286" 
"3266    0045" "1087    0053" "5627    0003" "5361    0845" "5368    0006" "3266    0045" "5361    0845" "3931    0043" "0777    0039" 
"2958    0005" "5938    0076" "2887    0316" "5938    0076" "0777    0039" "4488    0025" "2703    0064" "2887    0316" "5270    0020"
"3384    0159" "4540    0262" "0777    0039" "4488    0025" "2887    0316" "2703    0064" "5938    0076" "0788    0043" "2992    0035" 
"3535    0030" "1241    0131" "5043    2029" "0521    0016" "4506    0114" "3220    2007" "3570    0053" "0245    2066" "1089    0106" 
"5939    0014" "5233    0804" "5002    0072" "2862    0066" "0754    0088" "0973    0051" "1241    0131" "5000S   0043" "5198W   0069"
"0025    2045" "0245    2224" "3265    0196" "3535    0030" "2906    0839" "5960    0030" "5043    2029" "0528    2055" "0357    0069"
"5662    0833" "5395    0805" "0777    0865" "1074    0058" "2745A   0064" "4052    0133" "0484    2071" "3937    0057" "5347    0003"
"0360    0050" "0245    2066" "3570    0053" "0862    0146" "5520    2005" "1074    0058" "0358    2040" "0754    0088" "5176    0938"
"4530    0025" "0973    0051" "1241    0131" "5000S   0043" "5198W   0069" "0025    2045" "3214    0108" "2725    0019" "2937    0009" 
"2860    0055" "5618S   0010" "2992    0077" "2920    0023" "3105    0107" "3100    2018" "5777    0532" "3713    0063" "4054    0098"
"3935    0825" "5043    2029" "0777    0039" "0553W   0816" "2770    0813" "0313    2023" "5132    0136" "2888    0089" "5597    0015"
"3198    0131" "3150    0027" "4060    0255" "6148    0036" "5153    0813" "6126    0051" "1053    0045" "5960    0030" "0151    2118"
"4320    0040" "0358    2154" "1301    0560" "1047    0052" "0237    2007" "0360    0050" "1056    0039" "2866    0068" "1241    0131"
"3208    0059" "2727N   0028" "5133    0176" "3146    0045" "2837    2040" "1819    2196" "0546    2113" "1756    0818" "3001    0079" 
"3645    2061" "3010    0187" "1857    2050" "0878    0156" "3937    0057" "4516    0027" "1807    2028" "2884    0820" "3163    0034"    
"5349S   0006" "2990    0065" "0313    2023" "4062    0211" "3105    0107" "5133    0176" "5431    0058" "5618S   0010" "5410    0026" 
"2866    0068" "5464    0044" "0521    0016" "3710    0162" "0358    2154" "5922    0112" "3332    0012" "2807    0002" "1834    0032"
"0777    0039" "4120    0010" "5637    0090" "0484    2041" "5364    0851" "3777    0004" "1066    0054" "2965    0010" "5243    0833" 
"0517    2519" "5043    2029" "4445    0127" "1301    0560" "5523    0029" "2770    0813" "3145    0045" "4546    0150" "4062    0076" 
"5939    0014" "5390    0816" "5922    0112" "4055    0844" "1034    2016" "5043    2029" "1819    2196" "4127    0819" "2827S   0060" 
"3114    2002" "3744    0085" "3621    0035" "4052    0133" "5115    0163" "5151    0025" "3309    0086" "5637    0090" "1601    2967" 
"5102    0806" "3621    0035" "3642    2005" "3710    0162" "4445    0127" "4060    0149" "1047    0052" "5142    0094" "0190    2050"
"2884    0820" "4120    0010" "3220    2007" "3398    0001" "6003E   0809" "0236    2013" "5153    0813" "3145    0045" "3234    0028" 
"3211    0128" "0242N   2021" "1043    0829" "0517    2519" "5206    0027" "3303    0076" "0878    0156" "1601    2967" "3713    0045" 
"4062    0076" "1601    2967" "1819    2196" "0862    0146" "1819    2196" "1857    2050" "0862    0146" "0281    2320" "0886    0062" 
"3114    2001" "4055    0844" "0777    0039" "3001    0079" "4112    0851" "4112    0851" "5390    0816" "5215    0031" "5684    0134" 
"1301    0560" "0519    0042" "2884    0820" "5115    0163" "0236    2049" "5777    0532" "3220    2007" "0894    0803")
and */ lastnotice_date gt '01jan2005'd;
*var ssl firstnotice_date lastnotice_date lastnotice_grantor lastnotice_grantee prev_sale_owner post_sale_owner post_sale_date outcome_code;
run;


proc sql noprint;
  create table Foreclosure_servicers_history as
  select * from 
    ROD.Foreclosure_servicers as f
    full join
    work.history (keep=ssl firstnotice_date lastnotice_date num_notice lastnotice_grantee lastnotice_grantor
prev_sale_owner post_sale_owner post_sale_date outcome_code outcome_date) as p on f.ssl = p.ssl
	having firstnotice_date <= filingdate <=lastnotice_date
  order by filingdate, documentno

;
quit;
run;
proc sort data=rod.foreclosure_servicers out=foreclosure_servicers2;
by documentno;
data rod.foreclosure_servicers_history;
merge foreclosure_servicers_history (in=a) foreclosure_servicers2 (in=b);
by documentno;
if a or b;
run;

ods tagsets.excelxp file="D:\DCData\Libraries\ROD\Prog\Servicer_list_&file_date..xls" style=template.minimal_mystyle
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Notice of foreclosure sale with outcomes");

proc print data=Rod.Foreclosure_Servicers_history  label noobs;
  where ui_instrument in ('F1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor Grantor_recode  Verified
 outcome_code outcome_date firstnotice_date lastnotice_date num_notice 
prev_sale_owner post_sale_owner post_sale_date ;
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
    Grantor = 'Lender/servicer/agent'
	Grantor_recode='Lender/servicer/agent Recoded'
	outcome_code='Foreclosure Outcome' 
	outcome_date='Date of Foreclosure Outcome'
	firstnotice_date= 'Date of First Notice Filed'
	lastnotice_date= 'Date of Last Notice Filed' 
	num_notice='Number of Notices Filed'
	post_sale_owner='New owner after property sold'
	post_sale_date='Date of Sale';

run;
ods tagsets.excelxp options( sheet_name="Notice of foreclosure sale");

proc print data=Rod.Foreclosure_Servicers label noobs;
  where ui_instrument in ('F1')and ui_proptype ne "12";;
  var FilingDate DocumentNo ui_proptype usecode SSL PREMISEADD 
      Zip Ward2002 Anc2002 Geo2000 Cluster_tr2000 
      owner_occ_sale Grantee OWNERNAME OWNNAME2 owner_addr hstd_code Grantor Grantor_recode Verified ;
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
    Grantor = 'Lender/servicer/agent'
	Grantor_recode='Lender/servicer/agent Recoded';

run;
ods tagsets.excelxp close;

ods listing;

