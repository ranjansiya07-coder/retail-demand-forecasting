CREATE DATABASE IF NOT EXISTS retail_forecasting;

USE retail_forecasting;

DROP TABLE IF EXISTS retail_forecasting.retail_data;

CREATE TABLE retail_forecasting.retail_data (
    Store INT,
    DayOfWeek INT,
    Date DATE,
    Sales INT,
    Customers INT,
    Open INT,
    Promo INT,
    StateHoliday VARCHAR(5),
    SchoolHoliday INT,
    StoreType VARCHAR(5),
    Assortment VARCHAR(5),
    CompetitionDistance DOUBLE,
    CompetitionOpenSinceMonth DOUBLE,
    CompetitionOpenSinceYear DOUBLE,
    Promo2 INT,
    Promo2SinceWeek DOUBLE,
    Promo2SinceYear DOUBLE,
    PromoInterval VARCHAR(20),
    Year INT,
    Month INT,
    Week INT,
    Quarter INT,
    IsWeekend INT,
    Lag_7 DOUBLE,
    Rolling_Mean_7 DOUBLE
);

LOAD DATA LOCAL INFILE '/Users/ranjansiya/Downloads/cleaned_retail_data.csv'
INTO TABLE retail_forecasting.retail_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM retail_forecasting.retail_data;

SELECT * FROM retail_data;
DESC retail_data;

-- =============================================
-- CAPSTONE PROJECT 2
-- RETAIL SALES FORECASTING
-- SQL ANALYSIS SECTION
-- Database: MySQL
-- Table: retail_data
-- =============================================


-- =============================================
-- SECTION 1: DATA UNDERSTANDING
-- =============================================

-- QUERY 1: TOTAL NUMBER OF RECORDS
-- OBJECTIVE:
-- To determine the total number of transactions available in the dataset.

SELECT COUNT(*) AS total_records
FROM retail_data;

/* INTERPRETATION:
The dataset contains 836,533 transactional records, indicating a large-scale retail dataset.
This volume of data is sufficient for performing robust exploratory analysis, trend identification, 
and reliable time-series forecasting.*/

-- QUERY 2: DATA RANGE OF THE DATASET
-- OBJECTIVE:
-- To understand the time span covered by the dataset.

SELECT 
    MIN(Date) AS start_date,
    MAX(Date) AS end_date
FROM retail_data;

/* INTERPRETATION:
The dataset covers a time period from January 8, 2013 to July 31, 2015, spanning approximately 2.5 years.
This duration is sufficient to capture seasonal patterns, promotional effects, and long-term sales trends, 
making it suitable for time-series forecasting analysis.*/

-- QUERY 3: TOTAL NUMBER OF SALES
-- OBJECTIVE:
-- To identify how many unique stores are included in the dataset.

SELECT COUNT(DISTINCT Store) AS total_stores
FROM retail_data;

/* INTERPRETATION:
The dataset includes sales data from 1,115 unique retail stores, 
providing a broad and diverse store-level representation.
This allows for comparative performance analysis, store ranking, and location-based sales pattern evaluation.*/

-- QUERY 4: TOTAL OVERALL SALES
-- OBJECTIVE:
-- To calculate the cumulative revenue generated across all stores during the entire time period.

SELECT SUM(Sales) AS total_sales
FROM retail_data;

/* INTERPRETATION:
The total cumulative revenue generated across all stores during the observed period is 5.82 billion.
This indicates a high-volume retail business with significant revenue flow, making performance optimization 
and accurate forecasting critical for strategic decision-making. */

-- QUERY 5: NULL VALUES CHECK
-- OBJECTIVE:
-- To verify data completeness and identify missing values in critical columns.

SELECT 
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN Customers IS NULL THEN 1 ELSE 0 END) AS null_customers,
    SUM(CASE WHEN CompetitionDistance IS NULL THEN 1 ELSE 0 END) AS null_competition_distance
FROM retail_data;

/* INTERPRETATION:
No missing values were identified in key business-critical columns such as Sales, Customers, and Competition Distance.
This indicates high data integrity and reduces the need for extensive imputation or data cleaning before analysis 
and modeling.*/

-- =============================================
-- SECTION 2: BUSINESS ANALYSIS
-- =============================================

-- QUERY 6: STORE-WISE TOTAL SALES
-- OBJECTIVE:
-- To analyze revenue contribution at the store level and identify high-performing stores.

SELECT 
    Store,
    SUM(Sales) AS total_sales
FROM retail_data
GROUP BY Store
ORDER BY total_sales DESC
LIMIT 3;

/* INTERPRETATION:
Store 262 emerged as the highest revenue-generating store with total sales of approximately 19.39 million, 
followed by Store 817 and Store 562.This indicates a significant performance variation across stores,
highlighting opportunities to analyze operational strategies, location advantages, 
or promotional effectiveness in top-performing outlets. */

-- QUERY 7: MONTHLY SALES TREND
-- OBJECTIVE:
-- To analyze how sales vary month-by-month and identify seasonality patterns.

SELECT 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    SUM(Sales) AS monthly_sales
FROM retail_data
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

/* INTERPRETATION:
Sales show a clear seasonal pattern with consistent spikes in December.
Mid-year months show relatively lower performance.
Overall, revenue remains stable with recurring year-end growth, indicating strong seasonality.*/

-- QUERY 8: YEAR-WISE TOTAL SALES
-- OBJECTIVE:
-- To compare overall annual performance and identify growth trend.

SELECT 
    YEAR(Date) AS Year,
    SUM(Sales) AS yearly_sales
FROM retail_data
GROUP BY YEAR(Date)
ORDER BY Year;

/* INTERPRETATION:
Sales in 2014 were slightly lower than 2013, indicating marginal decline.
2015 shows lower total revenue since it contains only partial-year data (up to July).
Overall, the business maintains stable multi-billion annual revenue performance.*/

-- QUERY 9: PROMOTION IMPACT ON SALES
-- OBJECTIVE:
-- To analyze whether promotional activities significantly influence sales performance.

SELECT 
    Promo,
    COUNT(*) AS transactions,
    SUM(Sales) AS total_sales,
    ROUND(AVG(Sales),2) AS avg_sales
FROM retail_data
GROUP BY Promo;

/* INTERPRETATION:
Stores running promotions generated significantly higher average sales (₹8,228) compared to non-promo days (₹5,930).
This indicates that promotional activities substantially boost revenue and play a critical role in sales performance.*/

-- QUERY 10: WEEKEND vs WEEKDAY SALES
-- OBJECTIVE:
-- To analyze whether sales behavior differs between weekends and weekdays.

SELECT 
    IsWeekend,
    COUNT(*) AS transactions,
    SUM(Sales) AS total_sales,
    ROUND(AVG(Sales),2) AS avg_sales
FROM retail_data
GROUP BY IsWeekend;

/* INTERPRETATION:
Weekdays generate higher average sales (₹7,173) compared to weekends (₹5,936).
This suggests that retail demand is stronger during weekdays, possibly due to consistent shopping patterns
rather than weekend-driven spikes.*/
 
-- QUERY 11: STORE TYPE PERFORMANCE
-- OBJECTIVE:
-- To evaluate sales performance across different store types.

SELECT 
    StoreType,
    COUNT(*) AS transactions,
    SUM(Sales) AS total_sales,
    ROUND(AVG(Sales),2) AS avg_sales
FROM retail_data
GROUP BY StoreType
ORDER BY total_sales DESC;

/*INTERPRETATION:
Store Type ‘a’ contributes the highest total revenue due to large transaction volume.
However, Store Type ‘b’ records the highest average sales (₹10,253), 
indicating stronger per-transaction performance despite lower transaction count.
This suggests that different store formats drive revenue through either volume or higher-value transactions.*/

-- =============================================
-- SECTION 3: ADVANCED SQL ANALYTICS
-- =============================================

-- QUERY 12: STORE RANKING USING WINDOW FUNCTION
-- OBJECTIVE:
-- To rank stores based on total sales using analytical functions.

SELECT * FROM (
SELECT 
    Store,
    SUM(Sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS store_rank
FROM retail_data
GROUP BY Store)t
WHERE store_rank <=10;

/* INTERPRETATION:
Using the RANK() window function, stores were ranked based on total revenue contribution.
Store 262 holds the top position, generating the highest sales, followed by Stores 817 and 562.
Revenue distribution indicates performance concentration among the top-performing outlets.*/

-- QUERY 13: RUNNING TOTAL OF MONTHLY SALES
-- OBJECTIVE:
-- To analyze cumulative revenue growth over time.

WITH monthly_sales AS (
    SELECT 
        YEAR(Date) AS Year,
        MONTH(Date) AS Month,
        SUM(Sales) AS total_sales
    FROM retail_data
    GROUP BY YEAR(Date), MONTH(Date)
)
SELECT 
    Year,
    Month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY Year, Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM monthly_sales;

/* INTERPRETATION:
The running total analysis shows a steady cumulative revenue increase over time, 
reflecting stable business performance. No major revenue shocks or abrupt declines are observed,
indicating consistent operational stability. */

-- QUERY 14: MONTH - OVER - MONTH GROWTH %
-- OBJECTIVE:
-- To measure monthly percentage growth in sales and identify acceleration or slowdown trends.
WITH monthly_sales AS (
    SELECT 
        YEAR(Date) AS Year,
        MONTH(Date) AS Month,
        SUM(Sales) AS total_sales
    FROM retail_data
    GROUP BY YEAR(Date), MONTH(Date)
)
SELECT 
    Year,
    Month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY Year, Month) AS previous_month_sales,
    CONCAT(
        ROUND(
            (total_sales - LAG(total_sales) OVER (ORDER BY Year, Month))
            / LAG(total_sales) OVER (ORDER BY Year, Month) * 100,
        2),
    '%') AS mom_growth_percent
FROM monthly_sales;

/* INTERPRETATION:
Month-over-month growth analysis reveals significant seasonal volatility, 
with strong positive spikes during year-end months and moderate declines at the beginning of subsequent years.
This pattern reinforces the presence of recurring seasonal demand cycles in the retail business.*/

-- QUERY 15: 3-MONTH MOVING AVERAGE
-- OBJECTIVE:
-- To smooth monthly volatility and observe the underlying sales trend.

WITH monthly_sales AS (
    SELECT 
        YEAR(Date) AS Year,
        MONTH(Date) AS Month,
        SUM(Sales) AS total_sales
    FROM retail_data
    GROUP BY YEAR(Date), MONTH(Date)
)

SELECT 
    Year,
    Month,
    total_sales,
    ROUND(
        AVG(total_sales) OVER (
            ORDER BY Year, Month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3_months
FROM monthly_sales;

/* INTERPRETATION:
The 3-month moving average smooths short-term volatility and confirms a stable long-term revenue trend with recurring 
seasonal peaks.This supports the presence of predictable demand cycles, beneficial for time-series forecasting models.*/



 


