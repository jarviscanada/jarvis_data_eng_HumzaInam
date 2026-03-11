# Databricks notebook source
import dlt
from pyspark.sql.functions import *
from pyspark.sql.window import Window

# COMMAND ----------
@dlt.table(
    comment="Daily stock summary with key metrics",
    table_properties={"quality": "gold"}
)
def gold_daily_stock_summary():
    """Aggregated daily metrics per stock"""
    return (
        dlt.read("silver_enriched_stock")
        .groupBy(
            "symbol",
            "trading_date",
            "company_name",
            "exchange",
            "sector",
            "industry"
        )
        .agg(
            first("open").alias("open"),
            max("high").alias("high"),
            min("low").alias("low"),
            last("close").alias("close"),
            sum("volume").alias("total_volume"),
            avg("daily_return").alias("avg_daily_return"),
            ((last("close") - first("open")) / first("open") * 100).alias("price_change_pct")
        )
        .orderBy(desc("trading_date"), "symbol")
    )

# COMMAND ----------
@dlt.table(
    comment="7-day moving average metrics per stock",
    table_properties={"quality": "gold"}
)
def gold_moving_averages():
    """Calculate rolling 7-day averages"""
    window_spec = Window.partitionBy("symbol").orderBy("trading_date").rowsBetween(-6, 0)

    return (
        dlt.read("gold_daily_stock_summary")
        .withColumn("ma_7_close", avg("close").over(window_spec))
        .withColumn("ma_7_volume", avg("total_volume").over(window_spec))
        .withColumn("ma_7_return", avg("avg_daily_return").over(window_spec))
        .select(
            "symbol",
            "trading_date",
            "company_name",
            "sector",
            "close",
            "ma_7_close",
            "total_volume",
            "ma_7_volume",
            "avg_daily_return",
            "ma_7_return"
        )
    )

# COMMAND ----------
@dlt.table(
    comment="Sector-level performance summary",
    table_properties={"quality": "gold"}
)
def gold_sector_performance():
    """Aggregate performance by sector"""
    return (
        dlt.read("gold_daily_stock_summary")
        .groupBy("sector", "trading_date")
        .agg(
            avg("close").alias("avg_close_price"),
            sum("total_volume").alias("sector_volume"),
            avg("price_change_pct").alias("avg_price_change_pct"),
            count("symbol").alias("num_stocks")
        )
        .orderBy(desc("trading_date"), "sector")
    )