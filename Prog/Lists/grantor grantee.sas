
/*Download foreclosure files*/
%macro download (year);
proc download data=rod.foreclosures_&year. out = rod.foreclosures_&year.;
run;

data foreclosures_&year.;
set rod.foreclosures_&year.;
run;

proc sort data=foreclosures_&year.;
by ssl;
run;
%mend download;

%download (1997);
%download (1998);
%download (1998);
%download (2000);
%download (2001);
%download (2002);
%download (2003);
%download (2004);
%download (2005);
%download (2006);
%download (2007);
%download (2008);
%download (2009);
***********************************************************;

**Add on grantor/grantee info**;

*append foreclosure files;
data foreclosures_all;
set rod.foreclosures_1997;
run;

%macro append (year);
proc append base=foreclosures_all data= rod.foreclosures_&year.;
run;
%mend append;

%append (1998);
%append (1998);
%append (2000);
%append (2001);
%append (2002);
%append (2003);
%append (2004);
%append (2005);
%append (2006);
%append (2007);
%append	(2008);
%append	(2009);


proc sort data=foreclosures_all;
by ssl;
run;



* Merge foreclosure files with foreclosure history/parcel file;
data foreclosures (keep= ssl pb_flag start_dt end_dt prev_sale_date filingdate grantor grantee) nota;
	merge foreclosures_w_address (in=a)  foreclosures_all (in=b) ;
	by ssl;
	if a=1 and b=1 then output foreclosures;
	if a=1 and b=0 then output nota;
	run;

proc summary data=foreclosures;
by ssl;
var  pb_flag;
output out= test sum=;
run;

* Remove notices that were issued before the previous sale date before we select the notices;
data foreclosures_2 noprev ;
	set foreclosures;
	where start_dt < &date. and end_dt > &date.;
	if start_dt >= prev_sale_date then output foreclosures_2;
	else output noprev;
	run;

* Add the Count variable to pull the first 3 notices;
proc sort data=foreclosures_2;
	by ssl descending FilingDate;
	run;

data foreclosures_count;
	retain count;
	set foreclosures_2;
	by ssl descending filingdate;
	if first.ssl=1 then count=1;
	if count le 3 then output;
	count=count+1;
	run;

*Transpose the file with the count so that we have the grantor and grantee variables across top by ssl;
proc transpose data=foreclosures_count out= foreclosures_grantor prefix= grantor;
	by ssl;
	id count;
	var grantor;
	run;

proc transpose data=foreclosures_count out= foreclosures_grantee prefix= grantee;
	by ssl;
	id count;
	var grantee;
	run;

*Merge the grantor and grantee files by ssl;

proc sort data= foreclosures_grantee;
by ssl;
run;

proc sort data= foreclosures_grantor;
by ssl;
run;

data grantor_grantee no;
merge  foreclosures_grantee (in=b) foreclosures_grantor (in=c);
by ssl;
if b=1 and c=1 then output grantor_grantee;
run;

*Merge the grantor_grantee file back onto the original foreclosure history/parcel file--
Note: the ssl's with the start date before the previous sale date will be deleted;

data Foreclosures_grant bnota  anotb (keep= ssl start_dt prev_sale_date);
merge foreclosures_w_address (in=a) grantor_grantee (in=b) ;
if a=1 and b=1 then output Foreclosures_grant;
else if b=1 and a=0 then output bnota;
else if a=1 and b=0 then output anotb;
by ssl;
run;

data DCHFA_&start_dt.;
set Foreclosures_grant;
if start_dt =< prev_sale_date then delete;
run;






