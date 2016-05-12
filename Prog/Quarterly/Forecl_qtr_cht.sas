 filename lognew "&_dcdata_path\ROD\Prog\Quarterly\Forecl_qtr_cht.log";
 filename outnew "&_dcdata_path\ROD\Prog\Quarterly\Forecl_qtr_cht.lst";
 proc printto print=outnew log=lognew new;
 run;
/**************************************************************************
 Program:  Forecl_qtr_cht.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create data for quarterly foreclosure chart
 (inventory, starts, sales, distressed sales, avoided).

 Modifications: 02/5/10 L Hendey Modified for ROD Quarterly and included end of qtr inventory
				6/22/10 L Hendey Added Renter/Owner Household code and Senior Code
**************************************************************************/


%let suffix = &val_suffix.;
%let end_dt = &val_end.;

proc format ;
	value $ptype

	10='Owner-Occupied Single-Family Home or Condominium'
	11='Renter-Occupied Single-Family Home or Condominium'
	12='Cooperative Building'
	14='Rental Apartment Building - Less than 5 Units'
	15='Rental Apartment Building - 5 or More Units';


	value senr

	1="All Owner-Occupied Properties"
	2="Low- to Moderate-Income Elderly Owner-Occupied Properties";
run;

***** Summarize data for chart quarterly indicators *****;

proc summary data=ROD.Foreclosures_qtr_&suffix. nway;
  where prev_sale_prp in ( '10', '11' );
  class report_dt;
  var in_foreclosure_beg foreclosure_start foreclosure_sale distressed_sale foreclosure_avoided in_foreclosure_end;
  output out=Chart (drop=_type_ _freq_) sum=;
run;

	proc print data=Chart;
	  id report_dt;
	run;

	data Csv_out (compress=no);

	  length year_fmt $ 4;

	  set Chart;
	  
	  if qtr( report_dt ) = 1 then year_fmt = put( year( report_dt ), 4. );
	  else year_fmt = "";
	  
	  drop report_dt;
	  
	run;

	filename fexport "&_dcdata_path\ROD\Prog\Quarterly\Foreclosures_qtr_&suffix..csv" lrecl=1000;

	proc export data=Csv_out
	    outfile=fexport
	    dbms=csv replace;
	run;
	filename fexport clear;
	run;


*********Renter/Owner Household Count***************;
			rsubmit;
			proc download data=realprop.parcel_base out=realprop.parcel_base;
			run;
			endrsubmit;

			proc sort data=realprop.parcel_base out=parcel_base;
			by ssl;
			proc sort data=rod.foreclosures_qtr_&suffix. out=foreclosures_qtr_&suffix.;
			by ssl;
			data qtr_units;
			merge foreclosures_qtr_&suffix. (in=a) parcel_base (in=b keep=ssl no_units);
			if a;
			by ssl;

			num_units_foreclosure=.;

			foreclosure_end=.;
			if in_foreclosure_end=1 then foreclosure_end=1;

			*new code assumes that one unit of co-op '12' is in foreclosure;
			if in_foreclosure_end=1 then do;
			if new_proptype in ('10' '11')  then num_units_foreclosure=1;
			if new_proptype='12' then num_units_foreclosure=1;
			if new_proptype='14' then num_units_foreclosure=3;
			if new_proptype='15' then num_units_foreclosure=5;

			end;

			if in_foreclosure_end=1 then do;
			if new_proptype in ('10' '11') then num_units_max=1;
			if new_proptype='12' then num_units_max=1;
			if new_proptype='14' then num_units_max=3;
			if new_proptype='15' then num_units_max=33;

			end;
	
			run;
			proc summary data=qtr_units nway;
			  where prev_sale_prp in ('12' '13');
			  class report_dt new_proptype;
			  var foreclosure_end num_units_foreclosure num_units_max;
			  output out=Chart (drop=_type_ _freq_) sum=;
			run;
			proc summary data=qtr_units nway;
			  where prev_sale_prp in ('10' '11');
			  class report_dt prev_sale_ownocc;
			  var foreclosure_end num_units_foreclosure num_units_max;
			  output out=Chart_tenure (drop=_type_ _freq_) sum=;
			run;
			data chart_tenure2;
				set chart_tenure;
			if prev_sale_ownocc=1 then new_proptype='10' ; *sfcondo owners;
			if prev_sale_ownocc=0 then new_proptype='11' ; *sfcondo renters;
			run;
			proc sort data=chart_tenure2;
			by report_dt new_proptype;
			data chart1;
				merge chart chart_tenure2;
				by report_dt new_proptype ;

				length year_fmt $ 4;
			  
			  if qtr( report_dt ) = 1 then year_fmt = put( year( report_dt ), 4. );
			  else year_fmt = "";
			run;

ods tagsets.excelxp file="&_dcdata_path\ROD\prog\Quarterly\Foreclosures_tenure_senior_&suffix..xls"  style=styles.minimal_mystyle options(sheet_interval='page' );
		ods tagsets.excelxp options( sheet_name="Households Min");
		proc tabulate data=chart1 format=8.0;
				where '01jan2003'd <= report_dt <= &end_dt.;
				var num_units_foreclosure;
				format new_proptype $ptype. ;
				class report_dt new_proptype;
				table report_dt=' ',
					 num_units_foreclosure=' '*(new_proptype=" "*SUM=' '*f=comma10. all='Total Households');
			    run;
	ods tagsets.excelxp options( sheet_name="Households Max");
		proc tabulate data=chart1 format=8.0;
				where '01jan2003'd <= report_dt <= &end_dt.;
				var num_units_max;
				format new_proptype $ptype. ;
				class report_dt new_proptype;
				table report_dt=' ',
					 num_units_max=' '*(new_proptype=" "*SUM=' '*f=comma10. all='Total Households');
			    run;
*****Seniors Affected by Foreclosure*******;
	data qtr;
			set Rod.Foreclosures_qtr_&suffix.;
			report_year=year(report_dt); 
		
			foreclosure_end=.;
			if in_foreclosure_end=1 then foreclosure_end=1;
		run;
		** Summarize data for chart **;
			proc summary data=qtr nway;
			  where prev_sale_prp in ( '10', '11') & prev_sale_hstd='5';
			  class report_dt ;
			  var foreclosure_end ;
			  output out=Chart_senior (drop=_type_ _freq_) sum=;
			run;
			proc summary data=qtr nway;
			  where prev_sale_prp in ( '10', '11');
			  class report_dt prev_sale_ownocc;
			  var foreclosure_end;
			  output out=Chart_own (drop=_type_ _freq_) sum=;
			run;

			data chart_owner ;
			  set Chart_own (where=(prev_sale_ownocc=1));
			  owner_type=1;
			  run;
			  data chart_senior2;
			  	set chart_senior;
			  owner_type=2;
			  run;
			data chart_owner_senior;
				merge chart_owner chart_senior2;
				by report_dt owner_type;

			run;
ods tagsets.excelxp options( sheet_name="Seniors") ; 
		proc tabulate data=chart_owner_senior format=8.0;
		where '01jan2003'd <= report_dt <= &end_dt.;
		var foreclosure_end;
		format owner_type senr. ;
		class report_dt owner_type;
		table report_dt=' ',
			 foreclosure_end=' '*(owner_type=" "*SUM=' '*f=comma10. );
	    run;


	ods tagsets.excelxp close;

/* Code to get % of seniors in all property (in foreclosure or not);

	rsubmit;
*proc contents data=realprop.parcel_base;run;
data getseniors;
	set realprop.parcel_base (where=( in_last_ownerpt = 1));

sale_num=1;

keep ssl saledate sale_num ui_proptype premiseadd address1 address2 usecode hstd_code ;

run;

%create_own_occ( inds=getseniors, outds=getseniors2, inlib=work, outlib=work );

run;


proc freq data=getseniors2;
tables owner_occ_sale*hstd_code/missprint;
run;
endrsubmit;*/

proc printto;
run;
