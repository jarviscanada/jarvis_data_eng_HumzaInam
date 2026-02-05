# Databricks notebook source
import dlt
from pyspark.sql.functions import *
from pyspark.sql.types import *

# COMMAND ----------
@dlt.table(
    comment="Cleaned and typed stock data",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("valid_prices", "open > 0 AND close > 0")
def silver_stock_data():
    """Clean and transform bronze stock data"""
    return (
        dlt.read("bronze_stock_data")
        .withColumn("trading_date", to_date(col("date")))
        .withColumn("open", col("open").cast("double"))
        .withColumn("high", col("high").cast("double"))
        .withColumn("low", col("low").cast("double"))
        .withColumn("close", col("close").cast("double"))
        .withColumn("volume", col("volume").cast("bigint"))
        .withColumn("daily_return", (col("close") - col("open")) / col("open") * 100)
        .withColumn("price_range", col("high") - col("low"))
        .select(
            "symbol",
            "trading_date",
            "open",
            "high",
            "low",
            "close",
            "volume",
            "daily_return",
            "price_range",
            "ingestion_timestamp"
        )
    )

# COMMAND ----------
@dlt.table(
    comment="Enriched stock data with company info",
    table_properties={"quality": "silver"}
)
def silver_enriched_stock():
    """Join stock data with company metadata"""
    return (
        dlt.read("silver_stock_data")
        .join(
            dlt.read("bronze_company_info"),
            "symbol",
            "left"
        )
        .select(
            col("symbol"),
            col("trading_date"),
            col("open"),
            col("high"),
            col("low"),
            col("close"),
            col("volume"),
            col("daily_return"),
            col("price_range"),
            col("name").alias("company_name"),
            col("exchange"),
            col("sector"),
            col("industry")
        )
    )