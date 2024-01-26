/*Super Store exploratory data analysis

Skills used: joins, window functions, aggregate functions, CTE's


*/


USE storedata;

-- Sale trends over a 3 year period
SELECT 
YEAR(Order_date)  AS Yr,
Category,
COUNT(Row_id) AS Num_Orders

FROM products
GROUP BY 1,2
ORDER BY 1;

-- product performance by categoty

SELECT
COUNT(*) AS TotalRows
FROM products;

SELECT 
Category,
COUNT(Row_id) AS Num_of_Orders,
ROUND((COUNT(Row_id)/9994)*100,2) AS Total_percent_orders

FROM Products
GROUP BY Category
ORDER BY 2 DESC
;



-- Best performing products by Sub_category

WITH Performance_by_category_and_sub AS (

SELECT 
Sub_category,
Category,
COUNT(Row_id) AS Num_of_Orders
FROM Products
GROUP BY Sub_category, Category
ORDER BY 2 DESC)

SELECT
Sub_category, 
Category,
Num_of_Orders,
SUM(Num_of_Orders) OVER (PARTITION BY Category) AS Category_total

FROM Performance_by_category_and_sub
GROUP BY Category, Sub_category, Num_of_Orders;




-- Prefferedd shipment mode by order
SELECT

Ship_mode AS Shipment_mode,
COUNT(DISTINCT Order_id) AS Num_orders

 FROM orders
 GROUP BY 1
 ORDER BY 2 DESC;



-- Shipment modes by Customer_Segments
SELECT 

customerinfo.Segment,
COUNT(DISTINCT CASE WHEN orders.Ship_mode = 'Second Class' THEN orders.Row_id END) AS Second_class_shipment,
COUNT(DISTINCT CASE WHEN orders.Ship_mode = 'Same Day' THEN orders.Row_id END) AS Same_day_shipment,
COUNT(DISTINCT CASE WHEN orders.Ship_mode = 'Standard Class' THEN orders.Row_id END) AS Standard_shipment,
COUNT(DISTINCT CASE WHEN orders.Ship_mode = 'First Class' THEN orders.Row_id END) AS First_class_shipment

FROM orders
	LEFT JOIN customerinfo
		ON orders.Row_id = customerinfo.Row_id
        
GROUP BY 1;

-- Order processing time
WITH avg_time AS (

SELECT 
products.Category,
DATEDIFF(orders.Ship_date, orders.Order_date) AS Order_processing_span
FROM orders
	LEFT JOIN products
		ON products.Row_id = orders.Row_id
)

SELECT 
Category,
MIN(Order_processing_span) AS Min_processing_days,
MAX(Order_processing_span) AS Max_processing_days,
AVG(Order_processing_span) AS Average_processing_days

FROM avg_time
GROUP BY 1;


-- Drill down on office supplies
SELECT

YEAR(Order_date) AS YR,
Sub_category,
COUNT(Row_id) AS num_sales


FROM products
WHERE Category = 'Office Supplies'
GROUP BY 1,2
ORDER BY 1,2;

SELECT 

monthname(Order_date),
Sub_category,
MIN(COUNT(Row_id)),
MAX(COUNT(Row_id))

FROM products 
WHERE Category = 'Office Supplies'
GROUP BY 2