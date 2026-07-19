/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- DROP table and 
DROP DATABASE IF EXISTS dw_bronze;
DROP DATABASE IF EXISTS dw_silver;
DROP DATABASE IF EXISTS dw_gold;

-- create  databases
CREATE DATABASE dw_bronze;
CREATE DATABASE dw_silver;
CREATE DATABASE dw_gold;


