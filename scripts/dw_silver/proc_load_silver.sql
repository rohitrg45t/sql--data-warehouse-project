/*
===============================================================================
Stored Procedure: Load Silver Layer(Bronze - > Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL(Extract,Transform,Load) process to
    populate the 'silver' schema/database tables from the 'Bronze' schema.
  Action Performed:
    - Truncates Silver tables.
    - Inserts traansformed and cleansed data from Bronze into silver tables.

Parameters:
    None.
    This stored procedure doesnot accept any parameters or return any values.

Usage Examples:
    CALL dw_silver.load_silver();
===============================================================================
*/



DROP PROCEDURE IF EXISTS dw_silver.load_silver;

DELIMITER //
CREATE PROCEDURE dw_silver.load_silver()
    BEGIN
    -- Declare error handler variables
       DECLARE error_code INT;
       DECLARE error_msg TEXT;
    -- Define the Handler(act as BEGIN CATCH of mysql server)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      -- Get error msg and Error number
      GET DIAGNOSTICS CONDITION 1
         error_code = MYSQL_ERRNO,
         error_msg = MESSAGE_TEXT;
         
    -- Print error details
    SELECT '=================================================='AS Message;
    SELECT ' ERROR OCCURRED DURING LOADING SILVER LAYER' AS Message;
    SELECT CONCAT('Error Code:',error_code) AS Error_Details;
    SELECT CONCAT('MESSAGE',error_msg) AS Error_Details;
    SELECT '==================================================' AS Message;
    
    END;

    SET @batch_start_time = NOW();
    SELECT '============================================' AS Message;
    SELECT 'loading Silver layer' AS Message;
    SELECT '============================================' AS Message;
    
    SELECT '============================================' AS Message;
    SELECT 'Loading CRM Tables' AS Message;
    SELECT '============================================' AS Message;

    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.crm_cust_info' AS Message;
    TRUNCATE TABLE dw_silver.crm_cust_info;
    SELECT 'Inserting data into: dw_silver.crm_cust_info' AS Message;
    INSERT INTO dw_silver.crm_cust_info(
           cst_id,
           cst_key,
           cst_firstname,
           cst_lastname,
           cst_marital_status,
           cst_gndr,
           cst_create_date
           )
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
    FROM dw_bronze.crm_cust_info
    ) t WHERE flag_last = 1;

    -- Record end time and duration
    SET @end_time = NOW();
    SELECT CONCAT('>> load duration:',TIMESTAMPDIFF(second,@start_time,@end_time),'second') AS Message;
    
    SELECT * FROM dw_silver.crm_cust_info;
    
    -- TABLE 2 --CRM product information
    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.crm_prd_info' AS Message;
    TRUNCATE TABLE dw_silver.crm_prd_info;
    SELECT 'Inserting data into: dw_silver.crm_prd_info' AS Message;
    INSERT INTO dw_silver.crm_prd_info(
          prd_id,
          cat_id,
          prd_key,
          prd_nm,
          prd_cost,
          prd_line,
          prd_start_dt,
          prd_end_dt
    )
    SELECT prd_id,
        REPLACE (SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
        SUBSTRING(prd_key,7) AS prd_key,
        prd_nm,
        IFNULL(prd_cost,0) AS prd_cost,
        CASE WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
             WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
             WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
             WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
             ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),INTERVAL 1 DAY) AS DATE) AS prd_end_dt
    FROM dw_bronze.crm_prd_info;
    -- Record end time and calculate duration
    SET @end_time = NOW();
    SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'second') AS Message;	
    
    -- Table3 -- crm_sales_details
    
    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.crm_sales_details' AS Message;
    TRUNCATE TABLE dw_silver.crm_sales_details;
    SELECT 'Inserting data into: dw_silver.crm_sales_details' AS Message;
    INSERT INTO dw_silver.crm_sales_details(
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          sls_order_dt,
          sls_ship_dt,
          sls_due_dt,
          sls_sales,
          sls_quantity,
          sls_price
      )
    SELECT 
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
    
          CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
               ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR),'%Y%m%d')
          END AS sls_order_dt,
          CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
               ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR),'%Y%m%d')
          END AS sls_ship_dt,
          CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
               ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR),'%Y%m%d')
          END AS sls_due_dt,
          CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price ) * sls_quantity
               THEN sls_quantity * ABS(sls_price)
               ELSE sls_sales
          END AS sls_sales,
          sls_quantity,
          CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity,0)
               ELSE sls_price
          END AS sls_price 
      FROM dw_bronze.crm_sales_details;
      
      -- Record end time and calculate duration
    SET @end_time = NOW();
    SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
  
      -- table 4 -- erp_cust_az12
    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.erp_cust_az12' AS Message;
    TRUNCATE TABLE dw_silver.erp_cust_az12;
    SELECT 'Inserting data into: dw_silver.erp_cust_az12' AS Message;
    INSERT INTO dw_silver.erp_cust_az12(
        cid,
        bdate,
        gen
     )
    SELECT 
           CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
                ELSE cid
           END AS cid,
           CASE WHEN bdate > CURDATE() THEN NULL
                ELSE bdate
           END AS bdate,
           CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                ELSE 'n/a'
           END AS gen
    FROM dw_bronze.erp_cust_az12;
    
    SELECT * FROM dw_silver.erp_cust_az12;
    -- Record end time and calculate duration
    SET @end_time = NOW();
    SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
    
    
    -- table 5 -- erm_loc_a101
    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.erp_loc_a101' AS Message;
    TRUNCATE TABLE dw_silver.erp_loc_a101;
    SELECT 'Inserting data into: dw_silver.erp_loc_a101' AS Message;
    
    INSERT INTO dw_silver.erp_loc_a101(
            cid,
            cntry
        )
    SELECT 
        REPLACE(cid,'-','_') AS cid,
        CASE WHEN UPPER(TRIM(cntry)) LIKE '%DE%' THEN 'Germany'
             WHEN UPPER(TRIM(cntry)) LIKE '%US%' OR UPPER(TRIM(cntry)) LIKE 'USA%' THEN 'United Kingdom'
             WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN  'n/a'
             ELSE TRIM(cntry)
        END AS cntry
    FROM dw_bronze.erp_loc_a101;
    
    SELECT DISTINCT cntry FROM dw_silver.erp_loc_a101;
    -- Record end time and calculate duration
    SET @end_time = NOW();
    SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
    
      
    -- table 6 -- erp_px_cat_g1v2
    SET @start_time = NOW();
    SELECT 'truncating table: dw_silver.erp_px_cat_g1v2' AS Message;
    TRUNCATE TABLE dw_silver.erp_px_cat_g1v2;
    SELECT 'Inserting data into: dw_silver.erp_px_cat_g1v2' AS Message;
    INSERT INTO dw_silver.erp_px_cat_g1v2(
         id,
         cat,
         subcat,
         maintenance
     )
    SELECT 
        id,
        cat ,
        subcat,
        maintenance
    FROM dw_bronze.erp_px_cat_g1v2;
    
    -- Record end time and calculate duration
    SET @end_time = NOW();
    SELECT CONCAT('>> Load Duration:',TIMESTAMPDIFF(SECOND,@start_time,@end_time),'seconds') AS Message;
    
    SELECT 'Loading silver layer is completed' AS Message;
    -- record all the silver layer load time 
    SET @batch_end_time = NOW();
    SELECT CONCAT('>> Total Load duration:',TIMESTAMPDIFF(SECOND,@batch_start_time,@batch_end_time),'seconds') AS Message;

END //
DELIMITER ;
