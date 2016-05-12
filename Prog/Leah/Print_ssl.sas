%let ssl = '0069    0225';

data _null_;
  set Rod.FORECLOSURE_SALES_COLLAPSE;
  where ssl in ( &ssl );
  file print;
  put / '--- ' ssl= ' -----------------';
  put (_all_) (= /);
run;


proc print data=Rod.FORECLOSURE_SALES_COLLAPSE;
  where ssl in ( &ssl );
  by ssl;
  id order;
  var firstnotice_date lastnotice_date tdeed_date prev_sale_date post_sale_date next_sale_date outcome_date outcome_code2;
  format post_sale_date mmddyy10.;
run;

proc print data=RealProp.Sales_master;
  where ssl in ( &ssl );
  by ssl;
  id sale_num;
  var saledate saleprice ownername_full acceptcode owner_occ_sale;
run;

proc print data=Foreclosures;
  where ssl in ( &ssl );
  by ssl;
  id filingdate;
  var ui_instrument grantee grantor; 
run;
