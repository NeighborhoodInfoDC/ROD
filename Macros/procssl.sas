PROC IMPORT OUT= WORK.SSL_UPDATE 
            DATAFILE= "D:\DCData\Libraries\ROD\Prog\SSL Update.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
