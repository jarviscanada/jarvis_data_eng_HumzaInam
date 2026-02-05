# Databricks notebook source
import dlt
import requests
from pyspark.sql.functions import *
from pyspark.sql.types import *

# COMMAND ----------
# Configuration
API_KEY = "YOUR_API_KEY" # Replace with your Alpha Vantage API key  
SYMBOLS = ["IBM", "AAPL", "MSFT", "GOOGL"]

# COMMAND ----------
@dlt.table(
    comment="Raw daily stock data from Alpha Vantage API",
    table_properties={"quality": "bronze"}
)
def bronze_stock_data():
    """Ingest raw stock data for multiple symbols"""
    all_data = []
    
    for symbol in SYMBOLS:
        url = f'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol={symbol}&apikey={API_KEY}'
        response = requests.get(url)
        data = response.json()
        
        if "Time Series (Daily)" in data:
            time_series = data["Time Series (Daily)"]
            for date, values in time_series.items():
                all_data.append({
                    "symbol": symbol,
                    "date": date,
                    "open": values["1. open"],
                    "high": values["2. high"],
                    "low": values["3. low"],
                    "close": values["4. close"],
                    "volume": values["5. volume"]
                })
    
    schema = StructType([
        StructField("symbol", StringType()),
        StructField("date", StringType()),
        StructField("open", StringType()),
        StructField("high", StringType()),
        StructField("low", StringType()),
        StructField("close", StringType()),
        StructField("volume", StringType())
    ])
    
    df = spark.createDataFrame(all_data, schema)
    return df.withColumn("ingestion_timestamp", current_timestamp())

# COMMAND ----------
@dlt.table(
    comment="Company metadata from Alpha Vantage",
    table_properties={"quality": "bronze"}
)
def bronze_company_info():
    """Ingest company overview data"""
    company_data = []
    
    for symbol in SYMBOLS:
        url = f'https://www.alphavantage.co/query?function=OVERVIEW&symbol={symbol}&apikey={API_KEY}'
        response = requests.get(url)
        data = response.json()
        
        if data:
            company_data.append({
                "symbol": data.get("Symbol", symbol),
                "name": data.get("Name"),
                "exchange": data.get("Exchange"),
                "sector": data.get("Sector"),
                "industry": data.get("Industry")
            })
    
    schema = StructType([
        StructField("symbol", StringType()),
        StructField("name", StringType()),
        StructField("exchange", StringType()),
        StructField("sector", StringType()),
        StructField("industry", StringType())
    ])
    
    df = spark.createDataFrame(company_data, schema)
    return df.withColumn("ingestion_timestamp", current_timestamp())