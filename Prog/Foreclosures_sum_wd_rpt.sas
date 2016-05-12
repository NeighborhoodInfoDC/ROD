	/**************************************************************************
 Program:  Foreclosures_sum_wd_rpt.sas
 Library:  Rod
 Project:  NeighborhoodInfo DC
 Author:   L Hendey
 Created:  05/11/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create a ward table over time for DISB.

 Modifications: 6/09/10 L Hendey Added 2010 data.
				2/06/12 L Hendey Added 2011 data
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
** Define libraries **;
%DCData_lib( ROD )

rsubmit;
proc download data=rod.foreclosures_sum_wd02 out=rod.foreclosures_sum_wd02;
run;
proc download data=rod.foreclosures_sum_city out=rod.foreclosures_sum_city;
run;
endrsubmit; 


****Numbers;

data forecl;
	set rod.foreclosures_sum_wd02;

keep ward2002 forecl_ssl_sf_condo_1999 forecl_ssl_sf_condo_2000 forecl_ssl_sf_condo_2001 forecl_ssl_sf_condo_2002
forecl_ssl_sf_condo_2003 forecl_ssl_sf_condo_2004 forecl_ssl_sf_condo_2005 forecl_ssl_sf_condo_2006 forecl_ssl_sf_condo_2007
forecl_ssl_sf_condo_2008 forecl_ssl_sf_condo_2009 forecl_ssl_sf_condo_2010 forecl_ssl_sf_condo_2011;
run;
data forecl_city;
	set rod.foreclosures_sum_city;

keep city forecl_ssl_sf_condo_1999 forecl_ssl_sf_condo_2000 forecl_ssl_sf_condo_2001 forecl_ssl_sf_condo_2002
forecl_ssl_sf_condo_2003 forecl_ssl_sf_condo_2004 forecl_ssl_sf_condo_2005 forecl_ssl_sf_condo_2006 forecl_ssl_sf_condo_2007
forecl_ssl_sf_condo_2008 forecl_ssl_sf_condo_2009 forecl_ssl_sf_condo_2010 forecl_ssl_sf_condo_2011;
run;
 
proc transpose data= forecl_city out=f_city;
id city;
run;

proc transpose data= forecl out=wd_forecl;
id ward2002;
run;

data wd_forecl_City;
merge f_city wd_forecl;
by _name_;
run;

 ;

 filename xout dde  "Excel|D:\DCDATA\Libraries\ROD\Prog\[Foreclosure by Ward Trend.xls]Numbers!R4C2:R16C10"
 lrecl=1000 notab;

  data _null_;
    file xout;
        set wd_forecl_city ;

    put Washington__D_C_ '09'x ward_1 '09'x  ward_2 '09'x ward_3 '09'x ward_4 '09'x ward_5 '09'x ward_6 '09'x ward_7 '09'x ward_8 '09'x;
 
  run;
  filename xout clear;


data trustee;
	set rod.foreclosures_sum_wd02;

keep ward2002 trustee_ssl_sf_condo_1999 trustee_ssl_sf_condo_2000 trustee_ssl_sf_condo_2001 trustee_ssl_sf_condo_2002 
trustee_ssl_sf_condo_2003 trustee_ssl_sf_condo_2004 trustee_ssl_sf_condo_2005 trustee_ssl_sf_condo_2006 trustee_ssl_sf_condo_2007 
trustee_ssl_sf_condo_2008 trustee_ssl_sf_condo_2009 trustee_ssl_sf_condo_2010 trustee_ssl_sf_condo_2011;
run;
  
proc transpose data= trustee out=wd_trustee;
id ward2002;
run;
data trustee_city;
	set rod.foreclosures_sum_city;

keep city trustee_ssl_sf_condo_1999 trustee_ssl_sf_condo_2000 trustee_ssl_sf_condo_2001 trustee_ssl_sf_condo_2002 
trustee_ssl_sf_condo_2003 trustee_ssl_sf_condo_2004 trustee_ssl_sf_condo_2005 trustee_ssl_sf_condo_2006 trustee_ssl_sf_condo_2007 
trustee_ssl_sf_condo_2008 trustee_ssl_sf_condo_2009 trustee_ssl_sf_condo_2010 trustee_ssl_sf_condo_2011;
run;
  
proc transpose data= trustee_city out=t_city;
id city;
run;

data wd_trustee_City;
merge t_city wd_trustee;
by _name_;
run;

 filename xout dde  "Excel|D:\DCDATA\Libraries\ROD\Prog\[Foreclosure by Ward Trend.xls]Numbers!R21C2:R33C10"
  lrecl=1000 notab;
  data _null_;
    file xout;
        set wd_trustee_city ;

    put Washington__D_C_ '09'x ward_1 '09'x  ward_2 '09'x ward_3 '09'x ward_4 '09'x ward_5 '09'x ward_6 '09'x ward_7 '09'x ward_8 '09'x;
 
  run;
  filename xout clear;

  ****Rates;

  
data forecl_r;
	set rod.foreclosures_sum_wd02;

keep ward2002 forecl_ssl_1kpcl_sf_condo_1999 forecl_ssl_1kpcl_sf_condo_2000 forecl_ssl_1kpcl_sf_condo_2001 forecl_ssl_1kpcl_sf_condo_2002
forecl_ssl_1kpcl_sf_condo_2003 forecl_ssl_1kpcl_sf_condo_2004 forecl_ssl_1kpcl_sf_condo_2005 forecl_ssl_1kpcl_sf_condo_2006 forecl_ssl_1kpcl_sf_condo_2007
forecl_ssl_1kpcl_sf_condo_2008 forecl_ssl_1kpcl_sf_condo_2009 forecl_ssl_1kpcl_sf_condo_2010 forecl_ssl_1kpcl_sf_condo_2011;
run;
data forecl_city_r;
	set rod.foreclosures_sum_city;

keep city forecl_ssl_1kpcl_sf_condo_1999 forecl_ssl_1kpcl_sf_condo_2000 forecl_ssl_1kpcl_sf_condo_2001 forecl_ssl_1kpcl_sf_condo_2002
forecl_ssl_1kpcl_sf_condo_2003 forecl_ssl_1kpcl_sf_condo_2004 forecl_ssl_1kpcl_sf_condo_2005 forecl_ssl_1kpcl_sf_condo_2006 forecl_ssl_1kpcl_sf_condo_2007
forecl_ssl_1kpcl_sf_condo_2008 forecl_ssl_1kpcl_sf_condo_2009 forecl_ssl_1kpcl_sf_condo_2010 forecl_ssl_1kpcl_sf_condo_2011;
run;
 
proc transpose data= forecl_city_r out=fr_city;
id city;
run;

proc transpose data= forecl_r out=wd_foreclr;
id ward2002;
run;

data wd_foreclr_City;
merge fr_city wd_foreclr;
by _name_;
run;

 ;

 filename xout dde  "Excel|D:\DCDATA\Libraries\ROD\Prog\[Foreclosure by Ward Trend.xls]Rates!R4C2:R16C10"
 lrecl=1000 notab;

  data _null_;
    file xout;
        set wd_foreclr_city ;

    put Washington__D_C_ '09'x ward_1 '09'x  ward_2 '09'x ward_3 '09'x ward_4 '09'x ward_5 '09'x ward_6 '09'x ward_7 '09'x ward_8 '09'x;
 
  run;
  filename xout clear;


data trustee_r;
	set rod.foreclosures_sum_wd02;

keep ward2002 trustee_ssl_1kpcl_sf_condo_1999 trustee_ssl_1kpcl_sf_condo_2000 trustee_ssl_1kpcl_sf_condo_2001 trustee_ssl_1kpcl_sf_condo_2002 
trustee_ssl_1kpcl_sf_condo_2003 trustee_ssl_1kpcl_sf_condo_2004 trustee_ssl_1kpcl_sf_condo_2005 trustee_ssl_1kpcl_sf_condo_2006 trustee_ssl_1kpcl_sf_condo_2007 
trustee_ssl_1kpcl_sf_condo_2008 trustee_ssl_1kpcl_sf_condo_2009 trustee_ssl_1kpcl_sf_condo_2010  trustee_ssl_1kpcl_sf_condo_2011 ;
run;
  
proc transpose data= trustee_R out=wd_trustee_r;
id ward2002;
run;
data trustee_city_r;
	set rod.foreclosures_sum_city;

keep city trustee_ssl_1kpcl_sf_condo_1999 trustee_ssl_1kpcl_sf_condo_2000 trustee_ssl_1kpcl_sf_condo_2001 trustee_ssl_1kpcl_sf_condo_2002 
trustee_ssl_1kpcl_sf_condo_2003 trustee_ssl_1kpcl_sf_condo_2004 trustee_ssl_1kpcl_sf_condo_2005 trustee_ssl_1kpcl_sf_condo_2006 trustee_ssl_1kpcl_sf_condo_2007 
trustee_ssl_1kpcl_sf_condo_2008 trustee_ssl_1kpcl_sf_condo_2009  trustee_ssl_1kpcl_sf_condo_2010 trustee_ssl_1kpcl_sf_condo_2011 ;
run;
  
proc transpose data= trustee_city_r out=tr_city;
id city;
run;

data wd_trusteeR_City;
merge tr_city wd_trustee_r;
by _name_;
run;

 filename xout dde  "Excel|D:\DCDATA\Libraries\ROD\Prog\[Foreclosure by Ward Trend.xls]Rates!R21C2:R33C10"
  lrecl=1000 notab;
  data _null_;
    file xout;
        set wd_trusteer_city ;

    put Washington__D_C_ '09'x ward_1 '09'x  ward_2 '09'x ward_3 '09'x ward_4 '09'x ward_5 '09'x ward_6 '09'x ward_7 '09'x ward_8 '09'x;
 
  run;
  filename xout clear;
