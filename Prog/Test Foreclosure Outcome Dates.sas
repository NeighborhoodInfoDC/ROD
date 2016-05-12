/**************************************************************************
	 Program:  Test Foreclosure Outcome Dates.sas
	 Library:  ROD
	 Project:  NeighborhoodInfo DC
	 Author:   R. Pitingolo
	 Created:  06/11/12
	 Version:  SAS 9.2
	 Environment:  Windows XP
	 
	 Description:  Tests different outcomes based on various date adjustments.

	 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

%DCData_lib( ROD )


data hist;
	set rod.Foreclosures_history_ ;

	/*if outcome_code = 5 then new_outcome_date = lastnotice_date + 730;
		else new_outcome_date = outcome_date ;*/

	format new_outcome_date mmddyy10.;

	if lastnotice_date > '17nov09'd then do;

		m0y1DO = intnx('day', outcome_date, 0) ;
		m1y1DO = intnx('day', outcome_date, 30) ;
		m2y1DO = intnx('day', outcome_date, 61) ;
		m3y1DO = intnx('day', outcome_date, 91) ;
		m4y1DO = intnx('day', outcome_date, 122) ;
		m5y1DO = intnx('day', outcome_date, 152) ;
		m6y1DO = intnx('day', outcome_date, 182) ;
		m7y1DO = intnx('day', outcome_date, 212) ;
		m8y1DO = intnx('day', outcome_date, 243) ;
		m9y1DO = intnx('day', outcome_date, 273) ;
		m10y1DO = intnx('day', outcome_date, 304) ;
		m11y1DO = intnx('day', outcome_date, 335) ;
		m0y2DO = intnx('day', outcome_date, 365) ;
		format  m0y1DO m1y1DO m2y1DO m3y1DO m4y1DO m5y1DO m6y1DO m7y1DO 
				m8y1DO m9y1DO m10y1DO m11y1DO m0y2DO date9.;

		if outcome_code = 5 and m0y1DO > '30sep11'd then outcome_m0y1 = 1;
			else outcome_m0y1 = outcome_code;

		if outcome_code = 5 and m1y1DO > '30sep11'd then outcome_m1y1 = 1;
			else outcome_m1y1 = outcome_code;

		if outcome_code = 5 and m2y1DO > '30sep11'd then outcome_m2y1 = 1;
			else outcome_m2y1 = outcome_code;

		if outcome_code = 5 and m3y1DO > '30sep11'd then outcome_m3y1 = 1;
			else outcome_m3y1 = outcome_code;

		if outcome_code = 5 and m4y1DO > '30sep11'd then outcome_m4y1 = 1;
			else outcome_m4y1 = outcome_code;

		if outcome_code = 5 and m5y1DO > '30sep11'd then outcome_m5y1 = 1;
			else outcome_m5y1 = outcome_code;

		if outcome_code = 5 and m6y1DO > '30sep11'd then outcome_m6y1 = 1;
			else outcome_m6y1 = outcome_code;

		if outcome_code = 5 and m7y1DO > '30sep11'd then outcome_m7y1 = 1;
			else outcome_m7y1 = outcome_code;

		if outcome_code = 5 and m8y1DO > '30sep11'd then outcome_m8y1 = 1;
			else outcome_m8y1 = outcome_code;

		if outcome_code = 5 and m9y1DO > '30sep11'd then outcome_m9y1 = 1;
			else outcome_m9y1 = outcome_code;

		if outcome_code = 5 and m10y1DO > '30sep11'd then outcome_m10y1 = 1;
			else outcome_m10y1 = outcome_code;

		if outcome_code = 5 and m11y1DO > '30sep11'd then outcome_m11y1 = 1;
			else outcome_m11y1 = outcome_code;

		if outcome_code = 5 and m0y2DO > '30sep11'd then outcome_m0y2 = 1;
			else outcome_m0y2 = outcome_code;

	end;

	if outcome_code ^= . and outcome_m0y1 = . then outcome_m0y1 = outcome_code;
	if outcome_code ^= . and outcome_m1y1 = . then outcome_m1y1 = outcome_code;
	if outcome_code ^= . and outcome_m2y1 = . then outcome_m2y1 = outcome_code;
	if outcome_code ^= . and outcome_m3y1 = . then outcome_m3y1 = outcome_code;
	if outcome_code ^= . and outcome_m4y1 = . then outcome_m4y1 = outcome_code;
	if outcome_code ^= . and outcome_m5y1 = . then outcome_m5y1 = outcome_code;
	if outcome_code ^= . and outcome_m6y1 = . then outcome_m6y1 = outcome_code;
	if outcome_code ^= . and outcome_m7y1 = . then outcome_m7y1 = outcome_code;
	if outcome_code ^= . and outcome_m8y1 = . then outcome_m8y1 = outcome_code;
	if outcome_code ^= . and outcome_m9y1 = . then outcome_m9y1 = outcome_code;
	if outcome_code ^= . and outcome_m10y1 = . then outcome_m10y1 = outcome_code;
	if outcome_code ^= . and outcome_m11y1 = . then outcome_m11y1 = outcome_code;
	if outcome_code ^= . and outcome_m0y2 = . then outcome_m0y2 = outcome_code;

	new_outcome_date = outcome_date;

run;

%let outcomelist = outcome_m0y1 outcome_m1y1 outcome_m2y1 outcome_m3y1 outcome_m4y1 outcome_m5y1
				   outcome_m6y1 outcome_m7y1 outcome_m8y1 outcome_m9y1 outcome_m10y1 outcome_m11y1;
%let dropvars = m0y1DO m1y1DO m2y1DO m3y1DO m4y1DO m5y1DO m6y1DO m7y1DO m8y1DO m9y1DO m10y1DO
				m11y1DO m0y2DO;


proc freq data = hist;
	tables outcome_code &outcomelist.outcome_m0y2 ;
	format outcome_code &outcomelist. outcome_m0y2 outcome.;
run;

data rod.Foreclosures_history ;
	set hist (drop = outcome_code outcome_date &outcomelist. &dropvars.);
	outcome_code = outcome_m0y2;
	if outcome_code = 1 then outcome_date = .n;
		else outcome_date = new_outcome_date;

	format outcome_code outcome.;
	format outcome_date mmddyy10.;
	drop outcome_m0y2;
run;
