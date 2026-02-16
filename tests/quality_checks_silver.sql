/*
=====================================================================================
Quality Checks
=====================================================================================
Script Purpose:
	This script performs various quality checks for data consistency,accuracy and 	standardization across the 'silver' schemas. It includes checks for:
	-Nulls or duplicate primary keys.
	-Unwanted spaces in string fields.
	-Data standardiztion and consistency.
	-Invalid date ranges and orders.
	-Data consistency between related fields

Usage Notes:
	-Run these checks after data loading Silver Layer.
	-Investigate and resolve any discrepancies found during the checks.
=====================================================================================
*/

-- ===========================================================================
-- Checking 'silver.crm_cust_info'
-- ===========================================================================
-- Check for NULL or Duplicates in Primary Key 
-- Expectation: No Result
SELECT
 cst_id,
 COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
	AND cst_id IS NULL

-- Check for Unwanted Spaces
-- Expectation: No Result
SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT 
	cst_marital_status
FROM silver.crm_cust_info

-- ===========================================================================
-- Checking 'silver.crm_prd_info'
-- ===========================================================================
-- Check for NULL or Duplicates in Primary Key 
-- Expectation: No Result
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 
	AND prd_id IS NULL

--Check for unwanted spaces
--Expectation: No Result
SELECT 
	prd_nm
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Result
SELECT 
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 
	OR prd_cost IS NULL

--Data Standardization and Consistency
SELECT DISTINCT 
	prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT 
	*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- ===========================================================================
-- Checking 'silver.crm_sales_details'
-- ===========================================================================
-- Check for Invalid Dates
-- Expectation: No Result
SELECT 
	NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101 
	OR sls_due_dt < 19000101

-- Check for Invalid Date Orders 
-- Expectation: No Result
SELECT 
	*
FROM silver.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt 
       OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero or Negative
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	ORDER BY sls_sales, sls_quantity, sls_price

-- ===========================================================================
-- Checking 'silver.erp_cust_az12'
-- ===========================================================================
-- Identify Out-of-Range Dates
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE()

--Date Standardization and Consistency
SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12

-- ===========================================================================
-- Checking 'silver.erp_loc_a101'
-- ==========================================================================
-- Data Consistency & Standardization
SELECT DISTINCT
	centry 
FROM silver.erp_loc_a101
ORDER BY centry

-- ===========================================================================
-- Checking 'silver.erp_loc_a101'
-- ==========================================================================
-- Check for unwanted spaces
-- Expectation: No Result
SELECT 
	*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintainance != TRIM(maintainance)

-- Data Standardization & Consistency
SELECT DISTINCT 
	maintainance
FROM bronze.erp_px_cat_g1v2
