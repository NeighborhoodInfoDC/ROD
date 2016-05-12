/**************************************************************************
 Program:  Print_ssl.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/18/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Print data for a single SSL.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( ROD )
%DCData_lib( RealProp )

%let ssl = '3048    0805';

title2 'File = RealProp.Parcel_base';

data _null_;
  set RealProp.Parcel_base;
  where ssl in ( &ssl );
  file print;
  put / '--- ' ssl= ' -----------------';
  put (_all_) (= /);
run;


title2 'File = Rod.Foreclosures_history';

data _null_;
  set Rod.Foreclosures_history;
  where ssl in ( &ssl );
  file print;
  put / '--- ' ssl= ' -----------------';
  put (_all_) (= /);
run;


title2 'File = Rod.Foreclosures_history';

proc print data=Rod.Foreclosures_history;
  where ssl in ( &ssl );
  by ssl;
  id order;
  var firstnotice_date lastnotice_date tdeed_date prev_sale_date post_sale_date next_sale_date outcome_date outcome_code2;
  format post_sale_date mmddyy10.;
run;

title2 'File = RealProp.Sales_master';

proc print data=RealProp.Sales_master;
  where ssl in ( &ssl );
  by ssl;
  id sale_num;
  var saledate saleprice ownername_full acceptcode owner_occ_sale;
run;

title2 'File = Rod.Foreclosures_all_years';

proc print data=Rod.Foreclosures_all_years;
  where ssl in ( &ssl );
  by ssl;
  id filingdate;
  var ui_instrument grantee grantor; 
run;


