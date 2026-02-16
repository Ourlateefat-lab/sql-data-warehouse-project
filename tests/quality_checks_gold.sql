/*
=====================================================================================
Quality Checks
=====================================================================================
Script Purpose:
	This script performs quality checks to validate the integrity, consistency and accuracy of the Gold layer. The checks ensure:
	-Uniqueness of surrogate keys in dimension tables.
	-Referential integrity between fact and dimension tables.
	-Validation of relationships in the data model for analytical purposes.

Usage Notes:
	-Run these checks after data loading gold Layer.
	-Investigate and resolve any discrepancies found during the checks.
=====================================================================================
*/

-- =============================================================================
-- Checking 'gold.dimension_customer'
-- =============================================================================
-- Check for uniqueness of Customer key in gold.dim_customers
-- Expectation: No results
SELECT
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- =============================================================================
-- Checking 'gold.product_key'
-- =============================================================================
-- Check for Uniqueness of Product key in gold.dim_products
-- Expectations: No results 
SELECT
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_Products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- =============================================================================
-- Checking 'gold.fact_sales'
-- =============================================================================
-- Checking the data model connectivity between fact and dimensions
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL
