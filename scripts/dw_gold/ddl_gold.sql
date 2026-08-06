 CREATE VIEW dw_gold.dim_products AS 
    SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_id,pn.prd_start_dt) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
	pc.cat AS category,
    pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date

    FROM dw_silver.crm_prd_info pn
    LEFT JOIN dw_silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL;
