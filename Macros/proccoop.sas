PROC IMPORT OUT= WORK.COOP_UNITS 
            DATAFILE= "D:\DCData\Libraries\ROD\Prog\COOP_Units.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
