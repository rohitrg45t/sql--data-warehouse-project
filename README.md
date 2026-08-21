# sql--data-warehouse-project
building a modern data warehouse with SQL Server, including ETL processes, data modeling and analytics

# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
<img width="1544" height="912" alt="data_architecture" src="https://github.com/user-attachments/assets/5ba13c21-fe45-4e86-a05b-1fb4daea783c" />

---
1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
.
## 📖 Project Overview
This project involves:

Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.
Data Modeling: Developing fact and dimension tables optimized for analytical queries.
Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.
🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:

* SQL Development
* Data Architect
* Data Engineering
* ETL Pipeline Developer
* Data Modeling
* Data Analytics
---
## 🚀 Project Requirements
Building the Data Warehouse (Data Engineering)
Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

Specifications
Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
Data Quality: Cleanse and resolve data quality issues prior to analysis.
Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
Scope: Focus on the latest dataset only; historization of data is not required.
Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.
BI: Analytics & Reporting (Data Analysis)
Objective
Develop SQL-based analytics to deliver detailed insights into:

Customer Behavior
Product Performance
Sales Trends
These insights empower stakeholders with key business metrics, enabling strategic decision-making.

For more details, refer to docs/requirements.md.

---
## Key Engineering Features and MYSQL Nuances
* *Medallion Architecture Implementation:*
  * *Bronze Layer:* Ingests raw CSV source data as-is, preserving the original grain and structure. Because MySQL restricts LOAD DATA INFILE inside routine bodies, bulk ingestion is structured via standalone batch execution scripts (load_bronze.sql).
  * *Silver Layer:* Cleans and normalizes data hygiene issues—handling whitespace trimming, missing values with COALESCE fallback chains (e.g., fallback logic from CRM to ERP master records), and standardizing code formats. Wrapped inside a robust stored procedure (load_silver).
  * *Gold Layer:* Exposes consumption-ready dimensional models using *SQL Views* (dim_customers, dim_products, fact_sales). Views provide zero storage overhead and real-time reflection of Silver transformations.
* *Advanced Error Handling & Diagnostics:*
  * The Silver layer stored procedure implements custom exception tracking using DECLARE EXIT HANDLER FOR SQLEXCEPTION combined with GET DIAGNOSTICS to capture MySQL error numbers and detailed execution messages gracefully.
* *Dimensional Modeling:*
  * Created surrogate primary keys using window functions (ROW_NUMBER() OVER()) and integrated business keys to ensure clean relational integrity between dimension entities and transactional facts.
---
## Tech Stack
* *Database Engine:* MySQL 8.0
* *Management Tool:* MySQL Workbench
* *Version Control:* Git & GitHub
* *Core Concepts:* ETL Pipelines, Star Schema, Data Hygiene, Exception Handling, Medallion Architecture

---
## REPOSITORY STRUCTURE
```text
sql data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```
---

