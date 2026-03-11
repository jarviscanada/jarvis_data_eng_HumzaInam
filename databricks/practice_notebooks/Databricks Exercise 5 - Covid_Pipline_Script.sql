 -- Humza Inam
 -- Databricks Exercise 5 - Covid Pipeline Script
 
 CREATE OR REFRESH STREAMING TABLE covid_bronze
 COMMENT "New covid data incrementally ingested from cloud object storage landing zone";

 CREATE FLOW covid_bronze_ingest_flow AS
 INSERT INTO covid_bronze BY NAME
 SELECT 
     Last_Update,
     Country_Region,
     Confirmed,
     Deaths,
     Recovered
 FROM STREAM read_files(
     -- replace with the catalog/schema you are using:
     "/Volumes/workspace/default/covid_data_volume/",
     format => "csv",
     header => true
 );

  CREATE OR REFRESH MATERIALIZED VIEW covid_silver(
 CONSTRAINT valid_country_region EXPECT (Country_Region IS NOT NULL) ON VIOLATION FAIL UPDATE
 )
 COMMENT "Formatted and filtered data for analysis."
 AS
 SELECT
     TO_DATE(Last_Update, 'MM/dd/yyyy') as Report_Date,
     Country_Region,
     Confirmed,
     Deaths,
     Recovered
 FROM covid_bronze;

  CREATE OR REFRESH MATERIALIZED VIEW covid_gold
 COMMENT "Aggregated daily data for the US with total counts."
 AS
 SELECT
     Report_Date,
     sum(Confirmed) as Total_Confirmed,
     sum(Deaths) as Total_Deaths,
     sum(Recovered) as Total_Recovered
 FROM covid_silver
 WHERE Country_Region = 'US'
 GROUP BY Report_Date;