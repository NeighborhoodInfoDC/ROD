PROC IMPORT OUT= WORK.RAW 
            DATAFILE= "D:\DCData\Libraries\ROD\Prog\COOP Units.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
