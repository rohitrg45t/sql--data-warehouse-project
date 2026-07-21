USE dw_bronze;
-- Main Header

SELECT '============================================' AS Message;
SELECT 'loading Bronze layer' AS Message;
SELECT '============================================' AS Message;

SELECT '============================================' AS Message;
SELECT 'Loading CRM Tables' AS Message;
SELECT '============================================' AS Message;

SELECT '>> Truncating Table:dw_bronze.crm_cust_info' AS Message;

-- Record start time
SET @start_time = NOW();
-- First, empty the table so we don't duplicate rows from previous partial runs
TRUNCATE TABLE dw_bronze.crm_cust_info;

SELECT '>> Inserting Data Into:dw_bronze.crm_cust_info' AS Message;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE dw_bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
-- 1. Map columns to variables if they need validation, or directly to fields
(@v_cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, @cst_create_date)
-- 2. Apply logic to handle blanks before saving into the table field
SET cst_id = IF(@v_cst_id = '' OR @v_cst_id IS NULL, NULL, @v_cst_id);

-- Record end time and calculate duration
SET @end_time = NOW();
SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
-- Confirm it loaded successfully
SELECT * FROM dw_bronze.crm_cust_info;
SELECT COUNT(*) FROM dw_bronze.crm_cust_info;

-- table 2 --
SET @start_time = NOW();
SELECT '>> Truncating Table:dw_bronze.crm_prd_info' AS Message;
TRUNCATE TABLE dw_bronze.crm_prd_info;
SELECT '>> Inserting Data Into:dw_bronze.crm_prd_info' AS Message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE dw_bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(prd_id,prd_key,prd_nm,@v_prd_cost,prd_line,prd_start_dt,@prd_end_dt)
SET prd_cost = IF(@v_prd_cost = '' OR @v_prd_cost IS NULL, NULL, @v_prd_cost);
SET @end_time = NOW();
SELECT CONCAT('>> Load Duration:', TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
-- table3 --
SET @start_time = NOW();
SELECT '>> Truncating table:dw_bronze.crm_sales_details' AS Message;
TRUNCATE TABLE dw_bronze.crm_sales_details;

SELECT '>> Inserting Data Into:dw_bronze.crm_sales_details' AS Message;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE dw_bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,@v_sls_sales,sls_quantity,@v_sls_price)
SET sls_price = IF(@v_sls_price = '' OR @v_sls_price IS NULL,NULL,@v_sls_price),
    sls_sales = IF (@v_sls_sales = '' OR @v_sls_sales IS NULL,NULL,@v_sls_sales);
SELECT * FROM dw_bronze.crm_sales_details;
SELECT COUNT(*) FROM dw_bronze.crm_sales_details;
SET @end_time = NOW();
SELECT CONCAT('>> Loading Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
-- table 4 --
SET @start_time = NOW();
SELECT '============================================' AS Message;
SELECT 'Loading ERP Tables' AS Message;
SELECT '============================================' AS Message;

SELECT '>> Truncating Table:dw_bronze.erp_cust_az12' AS Message;
TRUNCATE TABLE dw_bronze.erp_cust_az12;

SELECT '>> Inserting Data Into:dw_bronze.erp_cust_az12' AS Message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE dw_bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(CID,BDATE,@v_GEN)
SET GEN = IF(@v_GEN = '' OR @v_GEN IS NULL,NULL,@v_GEN);
SELECT * from dw_bronze.erp_cust_az12;
SET @end_time = NOW();
SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
-- table 5 --
SET @start_time = NOW();
SELECT '>> Truncating Table:dw_bronze.erp_loc_a101' AS Message;
TRUNCATE TABLE dw_bronze.erp_loc_a101;

SELECT '>> Inserting Data Into:dw_bronze.erp_loc_a101' AS Message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE dw_bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
SELECT * from dw_bronze.erp_loc_a101;
SET @end_time = NOW();
SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;

-- table 6 --
SET @staart_time = NOW();
SELECT '>> Truncating Table:dw_bronze.erp_px_cat_g1v2'  AS Message;
TRUNCATE TABLE dw_bronze.erp_px_cat_g1v2;

SELECT '>> Inserting Data Into:dw_bronze.erp_px_cat_g1v2' AS Message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE dw_bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
-- SELECT * from dw_bronze.erp_px_cat_g1v2;
SET @end_time = NOW();
SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
