# Databricks notebook source
# MAGIC %md
# MAGIC # Stock Data DLT Pipeline - Master Notebook
# MAGIC 
# MAGIC This notebook orchestrates the entire medallion architecture pipeline:
# MAGIC - Bronze: Raw API ingestion
# MAGIC - Silver: Data cleansing and enrichment
# MAGIC - Gold: Business aggregations

# COMMAND ----------
# MAGIC %run ./bronze_ingestion

# COMMAND ----------
# MAGIC %run ./silver_transform

# COMMAND ----------
# MAGIC %run ./gold_aggregates