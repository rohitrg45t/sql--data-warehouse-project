/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================


-- TABLE 1
SELECT DISTINCT cst_marital_status
FROM dw_bronze.crm_cust_info;

-- Quality check for silver
-- Rerun the queries of bronze for silver layer


-- CHECK FOR NULLS or Duplicates in primary key
-- expectation : no result
SELECT cst_id,COUNT(*)
FROM dw_silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
SELECT *
FROM dw_silver.crm_cust_info
WHERE cst_id = 29466 AND cst_gndr = 'M';
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER  BY cst_create_date DESC) AS flag_last
FROM dw_silver.crm_cust_info
WHERE cst_id = 29466;

SELECT *
FROM(SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER  BY cst_create_date DESC) AS flag_last
FROM dw_silver.crm_cust_info) t WHERE flag_last != 1; 
SELECT *
FROM(SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM dw_silver.crm_cust_info
) t WHERE flag_last = 1 AND cst_id = 29466;
-- ORDER BY cst_firstname DESC;  


-- Check for unnwanted spaces
-- Expected : No result
SELECT cst_firstname
FROM dw_silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM dw_silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM dw_silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- solution query for that
SELECT cst_id,cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN cst_marital_status = 'S' THEN 'Single'
     WHEN cst_marital_status = 'M' THEN 'Married'
     ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM (SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM dw_silver.crm_cust_info
) t WHERE flag_last = 1;

-- Data standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM dw_silver.crm_cust_info;


-- ===================================================================
-- TABLE 2 - crm_prd_info
-- ===================================================================
-- check for NULLs or Duplicates in primary key
-- expected : no result
SELECT prd_id,
COUNT(*)
FROM dw_bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- CHECK FOR UNWNATED SPACES
-- Expectation: no results
SELECT prd_nm
FROM dw_bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- CHECKS FOR NEGATIVE OR NULL VALUES
-- Expectation: no result
SELECT prd_cost
FROM dw_bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization and consistency
SELECT DISTINCT prd_line
FROM dw_bronze.crm_prd_info;

-- Check for invalid date Orders
SELECT *
FROM dw_bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
USE dw_bronze;

SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
DATE_SUB(
LEAD (prd_start_dt) OVER (PARTITION BY  prd_key ORDER BY prd_start_dt),INTERVAL 1 DAY) AS prd_end_dt_test,
prd_end_dt
FROM dw_bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509');

SELECT * FROM dw_bronze.crm_prd_info;


-- ==================================================================
-- TABLE 3 -- crm_sales_details
-- =================================================================

SELECT * FROM dw_bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_quantity,
sls_price
FROM dw_bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT sls_prd_key FROM dw_silver.crm_prd_info);

SELECT sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_quantity,
sls_price
FROM dw_bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM dw_silver.crm_cust_info);

-- TABLE 3 -- crm_sales_details

-- check for Invalid Dates
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM dw_bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LENGTH(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;

-- Check for invalid Date Orders
SELECT * FROM dw_bronze.crm_sales_details
WHERE sls_due_dt < sls_ship_dt OR sls_ship_dt < sls_order_dt;

-- check Data Consistency :between Sales,Quantity and price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL,Zero, or Negative.
SELECT DISTINCT
sls_sales AS old_sales,
sls_quantity,
sls_price AS old_price,
CASE WHEN  sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)  
     THEN  sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN  sls_sales / NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price
FROM dw_bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales,sls_quantity,sls_price;


-- ===========================================================
-- table 4 -- erp_cust_az12
-- ===========================================================

SELECT 
cid,
bdate,
gen
FROM dw_bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

SELECT * FROM dw_silver.crm_cust_info;

SELECT 
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
     ELSE cid
END AS cid,
bdate,
gen
FROM dw_bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
      ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM dw_silver.crm_cust_info);

-- IDENTIFY Out- OF- Range Dates
SELECT DISTINCT 
bdate
 -- CASE WHEN bdate > CURDATE() THEN NULL
-- ELSE bdate
--   END AS bdate
FROM dw_bronze.erp_cust_az12
WHERE bdate <= '1924-01-01' OR bdate > CURDATE();

-- data standardization ans consistency
SELECT DISTINCT gen
FROM dw_bronze.erp_cust_az12;

SELECT gen,
CASE WHEN gen != TRIM(gen) THEN TRIM(gen) 
     ELSE gen
 END AS gen,    
CASE WHEN gen ='M' THEN 'Male'
     WHEN gen = 'F' THEN 'Female'
     ELSE gen
END AS gen_new
FROM dw_bronze.erp_cust_az12;

SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
     WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     ELSE 'n/a'
END AS gen
FROM dw_bronze.erp_cust_az12;

-- =========================================================
-- Table 5 -- erp_loc_a101
-- ==========================================================

SELECT * FROM erp_loc_a101;

SELECT cid ,
REPLACE (cid,'-','') AS cid_new,
cntry
FROM dw_bronze.erp_loc_a101;

SELECT cst_key FROM dw_silver.crm_cust_info;

SELECT 
REPLACE (cid,'-','') AS cid_new,
cntry
FROM dw_bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM dw_silver.crm_cust_info);

-- Data standardization and Consistency
SELECT DISTINCT cntry 
FROM dw_bronze.erp_loc_a101
ORDER BY cntry;

SELECT DISTINCT cntry AS cntry_old,
CASE 
     WHEN TRIM(cntry) IN('US','USA') THEN 'United Kingdom'
     WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM dw_bronze.erp_loc_a101;


-- =========================================================
-- table 6 -- erp_px_cat_g1v2
-- =========================================================

SELECT *  FROM dw_bronze.erp_px_cat_g1v2;

SELECT cat_id FROM dw_silver.crm_prd_info;

SELECT id,
      cat,
      subcat,
      maintenance
FROM dw_bronze.erp_px_cat_g1v2;

-- check for unwanted spaces
SELECT 
   id,
   cat ,
   subcat,
   maintenance
FROM dw_bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR  maintenance != TRIM(maintenance);

-- Data standardization and Consistency
SELECT DISTINCT 
     cat
 FROM dw_bronze.erp_px_cat_g1v2;
 
 
