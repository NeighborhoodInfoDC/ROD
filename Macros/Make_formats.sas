/**************************************************************************
 Program:  Make_formats.sas
 Library:  ROD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/20/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create formats for ROD data.

 Modifications:
  04/24/09 PAT Added formats for Foreclosures_history outcome vars.
  05/08/09 PAT Updated outcomII value 6 label.
  07/09/09 LH  Added owncat format.
  01/26/12 RP  Added D1 and M1 to the $uinstr format.
6/24/2016  MC  Updated $uinstr formats to match new ROD data format; added L1, L2 and D2
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 
** Define libraries **;
%DCData_lib( ROD )

proc format library=ROD;
  value $uinstr
	'F1' = 'Notice of foreclosure'
	'F2' = 'Notice of condominium foreclosure'
	'F3' = 'Notice of foreclosure assessment'
	'F4' = 'Notice of foreclosure cancellation'
	'F5' = 'Trustees deed sale'
	'F6' = 'Foreclosure release notice'
	'F7' = 'Foreclosure affidavit'
	'D1' = 'Notice of default'
	'D2' = 'Notice of default cancellation'
	'M1' = 'Mediation certificate'
	'L1' = 'Lis pendens'
	'L2' = 'Lis pendens release'
	;
  value $booktyp
    'G' = 'General'
    'L' = 'Land'
    'O' = 'OPR'
  ;

  value outcomII

	1="In foreclosure"
	2="Property sold, foreclosed, REO"
	3="Property sold, foreclosed, Other"
	4="Property sold, distressed sale, REO"
	5="Property sold, distressed sale, Other"
	6="Property sold, distressed sale, Pre 1998"
	7="Property sold, foreclosure avoided"
	8="No sale, foreclosure avoided"
	9="Cancellation"
	.n="No notices before regular sale";
	
  value outcome
	1="In foreclosure"
	2="Property sold, foreclosed"
	3="Property sold, distressed sale"
	4="Property sold, foreclosure avoided"
	5="No sale, foreclosure avoided"
	6="Cancellation"
	.n="No notices before regular sale";

	 value $OwnCat
    '010' = 'Single-family owner-occupied'
    '020' = 'Multifamily owner-occupied'
    '030' = 'Other individuals'
    '040' = 'DC government'
    '050' = 'US government'
    '060' = 'Foreign governments'
    '070' = 'Quasi-public entities'
    '080' = 'Community development corporations/organizations'
    '090' = 'Private universities, colleges, schools'
    '100' = 'Churches, synagogues, religious'
    '110' = 'Corporations, partnership, LLCs, LLPs, associations'
    '111' = 'Nontaxable corporations, partnerships, associations'
    '115' = 'Taxable corporations, partnerships, associations'
	'120' = 'Government-Sponsored Enterprise'
	'130' = 'Banks, Lending, Mortgage and Servicing Companies'
    ;
	
run;

proc catalog catalog=ROD.Formats;
  modify uinstr (desc="Instrument type (UI recode)") / entrytype=formatc;
  modify booktyp (desc="Book type") / entrytype=formatc;
  modify outcomII (desc="UI foreclosure outcomes (detailed)") / entrytype=format;
  modify outcome (desc="UI foreclosure outcomes (summary)") / entrytype=format;
  contents;
quit;

