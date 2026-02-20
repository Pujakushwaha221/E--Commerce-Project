DESC customers;
DESC products;
DESC orders;
DESC orderdetails;

-- Market Segmentation Analysis 
SELECT location ,
            COUNT(customer_id)AS number_of_customers
FROM customers 
GROUP BY location 
ORDER BY number_of_customers DESC
LIMIT 3;          

-- Engagement Depth Analysis 
WITH order_summary AS (SELECT customer_id,
            COUNT(order_id)AS NumberOfOrders
FROM Orders 
GROUP BY customer_id )    
SELECT NumberOfOrders,
            COUNT(customer_id)AS CustomerCount
FROM order_summary
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders;

-- High Value Products 
SELECT product_id,
           AVG(quantity)AS AvgQuantity,
            SUM(quantity*price_per_unit)AS TotalRevenue
FROM orderdetails
GROUP BY product_id
HAVING AVG(quantity)=2
ORDER BY TotalRevenue DESC;

-- Category wise Customer Reach 
SELECT p.category,
            COUNT(DISTINCT o.customer_id)AS unique_customers
FROM Products AS p
JOIN orderdetails AS od 
ON p.product_id = od.product_id
JOIN orders AS o 
ON od.order_id = o.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;

-- Sales Trend Analysis 
WITH total_sales AS (SELECT 
           DATE_FORMAT(order_date,'%Y-%m')AS Month,
           SUM(total_amount)AS Present_month_value,
           LAG(SUM(total_amount)) OVER(ORDER BY DATE_FORMAT(order_date,'%Y-%m') )AS Previous_month_value
FROM orders
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY Month)
SELECT Month,
           Present_month_value AS TotalSales,
          ROUND((Present_month_value-Previous_month_value)/Previous_month_value *100,2)AS PercentChange
FROM total_sales; 

-- Average Order Value Fluctuation 
WITH OrderValue AS (
    SELECT 
    DATE_FORMAT(Order_date,"%Y-%m")AS Month,
    ROUND(AVG(total_amount),2) AS AvgOrderValue
    FROM Orders      
    group by Month
    ),
    ChangeinOrders AS (
    SELECT 
    Month,
    AvgOrderValue,
     (AvgOrderValue - LAG(AvgOrderValue)OVER(ORDER BY Month)) AS ChangeInValue
    FROM OrderValue
    )SELECT *
    FROM ChangeinOrders
    ORDER BY ChangeInValue DESC;
   
   -- Inventory Refresh rate 
   SELECT product_id,
           COUNT( order_id )AS SalesFrequency
FROM orderdetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;           

-- Low Engagement Products 
SELECT p.product_id,p.name as Name, COUNT( DISTINCT o.customer_id)AS UniqueCustomerCount
FROM Products AS p 
JOIN OrderDetails as od ON p.product_id=od.product_id
JOIN Orders as o ON od.order_id=o.order_id
JOIN Customers as c ON o.customer_id= c.customer_id
GROUP BY p.product_id,p.name
HAVING COUNT( DISTINCT o.customer_id)< (SELECT COUNT(customer_id) *0.4 FROM Customers);

-- Customer Acquisition Trends 
WITH customer_info AS (SELECT customer_id, MIN(order_date)AS First_Purchase_date
FROM Orders 
GROUP BY customer_id)
SELECT DATE_FORMAT(First_Purchase_date,'%Y-%m')AS FirstPurchaseMonth,
       COUNT(customer_id)AS TotalNewCustomers
FROM customer_info
GROUP BY  DATE_FORMAT(First_Purchase_date,'%Y-%m')
ORDER BY  DATE_FORMAT(First_Purchase_date,'%Y-%m');

-- Peak Sales Period Identification
SELECT DATE_FORMAT(order_date,'%Y-%m')AS Month,
            SUM(total_amount)AS TotalSales
FROM orders
GROUP BY Month
ORDER BY TotalSales DESC 
LIMIT 3;