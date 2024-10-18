SELECT * FROM ORDERS;
SELECT * FROM CUSTOMERS;

Q1.Total Revenue (order value)
   SELECT SUM(ORDER_TOTAL) AS TOTAL_REVENUE 
   FROM ORDERS;

Q2. Total Revenue (order value) by top 25 Customers
    SELECT TOP 25 CUSTOMER_KEY , TOTAL_REVENUE
	FROM (SELECT CUSTOMER_KEY, SUM(ORDER_TOTAL) AS TOTAL_REVENUE
	      FROM ORDERS
	      GROUP BY CUSTOMER_KEY) AS SubQuery
	ORDER BY TOTAL_REVENUE DESC;

Q3. Total number of orders
    SELECT  COUNT(*) AS TOTAL_ORDER_NUMBER
	FROM ORDERS;

Q4. Total orders by top 10 customers
    SELECT TOP 10 CUSTOMER_KEY, TOTAL_ORDERS 
	FROM (SELECT C.CUSTOMER_KEY, SUM(O.ORDER_TOTAL) AS TOTAL_ORDERS
	      FROM ORDERS O
	      ,CUSTOMERS C
	      WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	      GROUP BY C.CUSTOMER_KEY) AS SubQuery
	ORDER BY TOTAL_ORDERS  DESC;

Q5. Number of customers ordered once
    SELECT COUNT(CUSTOMER_KEY) AS NUMBER_OF_CUSTOMERS
	FROM (SELECT CUSTOMER_KEY, COUNT(*)  AS ORDER_NUMBER 
	      FROM ORDERS
	      GROUP BY CUSTOMER_KEY ) AS SubQuery 
	WHERE ORDER_NUMBER = 1;

Q6. Number of customers ordered multiple times
    SELECT COUNT(CUSTOMER_KEY) AS CUSTOMERS_ORDERED_MULTIPLES
	FROM (SELECT CUSTOMER_KEY, COUNT(*) AS TOTAL_ORDER
	      FROM ORDERS
	      GROUP BY CUSTOMER_KEY) AS SubQuery
    WHERE TOTAL_ORDER > 1;

Q7. Number of customers referred to other customers
   SELECT COUNT(CUSTOMER_ID) AS NUMBER_OF_CUSTOMERS
   FROM CUSTOMERS
   WHERE REFERRED_OTHER_CUSTOMERS <> 0

Q8.Which Month have maximum Revenue?  
   SELECT TOP 1 MONTHS, MAX_REVENUE
   FROM 
       (SELECT FORMAT(ORDER_DATE,'MMMM') AS MONTHS, MAX(ORDER_TOTAL) AS MAX_REVENUE
        FROM ORDERS
        GROUP BY FORMAT(ORDER_DATE,'MMMM') 
		) AS SubQuery
   ORDER BY  MAX_REVENUE DESC;

Q9. Number of customers are inactive (that have not ordered in the last 60 days)

--- Step 1: Find customers who ordered in last 60 days
   WITH RecentOrders AS (
      SELECT DISTINCT CUSTOMER_KEY
      FROM Orders
      WHERE ORDER_DATE >= DATEADD(day, -60, '2024-08-07')
  ),

-- Step 2: Find all customers
   AllCustomers AS (
      SELECT CUSTOMER_KEY
      FROM Customers
  )

-- Step 3: Find inactive customers by excluding those with recent orders
   SELECT COUNT(*) AS InactiveCustomers
   FROM AllCustomers
   WHERE CUSTOMER_KEY NOT IN (SELECT CUSTOMER_KEY FROM RecentOrders);


Q10. Growth Rate  (%) in Orders (from Nov’15 to July’16)

 --- Count orders in November 2015
   WITH OrdersNov2015 AS (
      SELECT COUNT(*) AS OrderCount
      FROM Orders
      WHERE ORDER_DATE >= '2015-11-01' AND ORDER_DATE < '2015-12-01'
   ),

-- Count orders in July 2016
   OrdersJul2016 AS (
     SELECT COUNT(*) AS OrderCount
     FROM Orders
     WHERE ORDER_DATE >= '2016-07-01' AND ORDER_DATE < '2016-08-01'
   )

-- Calculate the growth rate
    SELECT 
       (Jul2016.OrderCount - Nov2015.OrderCount) * 100.0 / Nov2015.OrderCount AS GrowthRatePercentage
    FROM 
       OrdersNov2015 AS Nov2015,
       OrdersJul2016 AS Jul2016;

Q11.Growth Rate (%) in Revenue (from Nov'15 to July'16)

  -- Sum revenue in November 2015
    WITH RevenueNov2015 AS (
      SELECT SUM(ORDER_TOTAL) AS TotalRevenue
      FROM Orders
      WHERE ORDER_DATE >= '2015-11-01' AND ORDER_DATE < '2015-12-01'
    ),

-- Sum revenue in July 2016
    RevenueJul2016 AS (
      SELECT SUM(ORDER_TOTAL) AS TotalRevenue
      FROM Orders
      WHERE ORDER_DATE >= '2016-07-01' AND ORDER_DATE < '2016-08-01'
   )

-- Calculate the growth rate
    SELECT 
       ((Jul2016.TotalRevenue - Nov2015.TotalRevenue) * 100.0 / Nov2015.TotalRevenue) AS GrowthRatePercentage
    FROM 
      RevenueNov2015 AS Nov2015,
      RevenueJul2016 AS Jul2016;
 


Q12. What is the percentage of Male customers exists?
    SELECT 
      (COUNT(CASE WHEN Gender = 'M' THEN 1 END) * 100.0 / COUNT(*)) AS PercentageOfMaleCustomers
    FROM CUSTOMERS;

Q13. Which location have maximum customers?
    SELECT TOP 1 LOCATION
    FROM (
        SELECT LOCATION, COUNT(CUSTOMER_ID) AS NUMBER_OF_CUSTOMERS
        FROM CUSTOMERS 
        GROUP BY LOCATION) AS SubQuery
   ORDER BY NUMBER_OF_CUSTOMERS DESC;

Q14. How many orders are returned?
     SELECT count(*) as NUMBER_OF_ORDERS_RETURNED
	 FROM ORDERS
	 WHERE ORDER_TOTAL < 0;

Q15. Which Acquisition channel is more efficient in terms of customer acquisition?
     SELECT TOP 1 ACQUIRED_CHANNEL, COUNT(ACQUIRED_CHANNEL) AS COUNT_OF_ACQUIRED_CHANNEL
	 FROM CUSTOMERS
	 GROUP BY ACQUIRED_CHANNEL
	 ORDER BY COUNT_OF_ACQUIRED_CHANNEL DESC;

Q16. Which location having more orders with discount amount?
     SELECT TOP 1 LOCATION 
	 FROM 
	    ( SELECT C.LOCATION, COUNT(ORDER_NUMBER) AS MAX_ORDER_NUMBER
	      FROM ORDERS O
	     ,CUSTOMERS C
	      WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	      AND O.DISCOUNT <> 0
	      GROUP BY C.LOCATION
      )  AS Subquery
	 ORDER BY MAX_ORDER_NUMBER DESC;

Q17. Which location having maximum orders delivered in delay?
     SELECT TOP 1  LOCATION
	 FROM (SELECT LOCATION , COUNT(ORDER_NUMBER) AS NUMBER_OF_ORDERS
	       FROM ORDERS O,
	       CUSTOMERS C
	       WHERE O.DELIVERY_STATUS  = 'LATE'
	       GROUP BY LOCATION
	 )AS Subquery
	 ORDER BY NUMBER_OF_ORDERS DESC;


Q18. What is the percentage of customers who are males acquired by APP channel?  
    SELECT(COUNT(CASE WHEN GENDER ='M' AND ACQUIRED_CHANNEL ='APP' THEN 1 END) / 100 * COUNT(*)) AS
	   PercentageOfMaleCustomersAcquiredByAPP
	FROM CUSTOMERS;

Q19. What is the percentage of orders got canceled? 
     SELECT(COUNT(CASE WHEN ORDER_STATUS = 'CANCELLED' THEN 1 END) * 100/ COUNT(*)) AS 
	      PercentageOfOrdersGotCancelled
	 FROM ORDERS;

Q20. What is the percentage of orders done by happy customers?

---STEP 1:- Identify happy customers

    WITH HappyCustomers
	AS(
       SELECT CUSTOMER_KEY
	   FROM CUSTOMERS C
	   WHERE REFERRED_OTHER_CUSTOMERS = 1
   ),

---STEP 2:- Filter Orders By Happy Customer

   OrdersByHappyCustomers AS
   (
    SELECT O.ORDER_NUMBER
	FROM HappyCustomers H
	, ORDERS O
	WHERE H.CUSTOMER_KEY = O.CUSTOMER_KEY
  )

---STEP 3:- Calculate the percentage

   SELECT
    (COUNT(O.ORDER_NUMBER) * 100/ (SELECT COUNT(*) FROM ORDERS O))
    AS PercentageOfHappyCustomers
   from OrdersByHappyCustomers O;


Q21. Which Location having maximum customers through reference? 
     SELECT TOP 1 LOCATION 
	 FROM (
	       SELECT LOCATION, COUNT(CUSTOMER_ID) AS MAX_CUSTOMERS
	       FROM CUSTOMERS
	       WHERE REFERRED_OTHER_CUSTOMERS <> 0
		   GROUP BY LOCATION
     ) AS Subquery
	 ORDER BY MAX_CUSTOMERS DESC;
	 
Q22. What is order_total value of male customers who are belongs to Chennai and Happy customers?
     SELECT SUM(ORDER_TOTAL) AS TOTAL_ORDER
	 FROM ORDERS O
	 , CUSTOMERS C
	 WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	 AND C.GENDER = 'M'
	 AND C.LOCATION = 'CHENNAI'
	 AND C.REFERRED_OTHER_CUSTOMERS <> 0;

Q23. Which month having maximum order value from male customers belongs to Chennai?
     SELECT TOP 1 MONTHS
	 FROM (
	       SELECT FORMAT(O.ORDER_DATE,'MMMM') AS MONTHS , MAX(O.ORDER_TOTAL) AS TOTAL_ORDER
	       FROM ORDERS O
	      ,CUSTOMERS C
	       WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	       AND C.GENDER ='M'
	       AND C.LOCATION ='Chennai'
		   GROUP BY  FORMAT(O.ORDER_DATE,'MMMM') 
	) AS SubQuery
	ORDER BY TOTAL_ORDER DESC;

Q24. Prepare at least 5 additional analysis on your own? 
---A. Order Trends Over Time
   SELECT FORMAT(ORDER_DATE,'MMMM') AS MONTHS , SUM(ORDER_TOTAL) AS TOTAL_ORDERS
   FROM ORDERS O
   , CUSTOMERS C
   WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY 
   GROUP BY FORMAT(ORDER_DATE,'MMMM')
   ORDER BY TOTAL_ORDERS;

---B.Customer Lifetime Value (CLV) Analysis
   SELECT C.CUSTOMER_KEY , SUM(O.ORDER_TOTAL) AS TOTAL_ORDER
   FROM CUSTOMERS C,
   ORDERS O
   WHERE C.CUSTOMER_KEY = O.CUSTOMER_KEY
   GROUP BY C.CUSTOMER_KEY

---C. Gender-Based Purchasing Behavior
  SELECT C.GENDER, SUM(O.ORDER_TOTAL) AS TOTAL_ORDER
  FROM CUSTOMERS C,
  ORDERS O
  WHERE C.CUSTOMEr_KEY = O.CUSTOMER_KEY
  GROUP BY C.GENDER

---D.MALE-Based Purchasing Behavior
  SELECT C.GENDER, SUM(O.ORDER_TOTAL) AS TOTAL_ORDER
  FROM ORDERS O
  , CUSTOMERS C
  WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
  AND C.GENDER = 'F'
  GROUP BY C.GENDER

---E.MALE-Based Purchasing Behavior
 SELECT C.GENDER, SUM(O.ORDER_TOTAL) AS TOTAL_ORDER_TOTAL
 FROM ORDERS O,
 CUSTOMERS C
 WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
 AND C.GENDER = 'M'
 GROUP BY C.GENDER 

 Q25. What are number of discounted orders ordered by female customers who were acquired by website from Bangalore delivered on time?
     SELECT COUNT(*) AS NUMBER_OF_DISCOUNTED_ORDERS
     FROM ORDERS O,
     CUSTOMERS C
     WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
     AND C.GENDER = 'F'
     AND O.DISCOUNT <> 0
     AND C.LOCATION = 'BANGALORE'
     AND C.ACQUIRED_CHANNEL ='WEBSITE'
     AND O.DELIVERY_STATUS = 'ON_TIME'

 Q26. Number of orders by month based on order status (Delivered vs. canceled vs. etc.)
      SELECT FORMAT(O.ORDER_DATE,'MMMM') AS MONTHS, O.ORDER_STATUS , COUNT(*) AS NUMBER_OF_ORDERS_BY_MONTHS 
	  FROM ORDERS O,
	  CUSTOMERS C
	  WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	  GROUP BY FORMAT(O.ORDER_DATE,'MMMM'), O.ORDER_STATUS

Q27. Number of orders by month based on delivery status
     SELECT FORMAT(O.ORDER_DATE,'MMMM') AS MONTHS, O.DELIVERY_STATUS
	 FROM ORDERS O,
	 CUSTOMERS C
	 WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
	 GROUP BY FORMAT(O.ORDER_DATE,'MMMM'), O.DELIVERY_STATUS 

Q28. Month-on-month growth in OrderCount and Revenue (from Nov’15 to July’16)

-- Calculate order count and total revenue for each month
WITH MonthlyData AS (
    SELECT YEAR(ORDER_DATE) AS OrderYear,
           MONTH(ORDER_DATE) AS OrderMonth,
           COUNT(*) AS OrderCount,
           SUM(ORDER_TOTAL) AS TotalRevenue
    FROM Orders
    WHERE ORDER_DATE >= '2015-11-01' 
      AND ORDER_DATE < '2016-08-01'
    GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
  --  ORDER BY OrderYear, OrderMonth
),
-- Calculate Month-on-Month Growth
MonthlyGrowth AS (
    SELECT OrderMonth, 
           OrderCount, 
           TotalRevenue,
           LAG(OrderCount) OVER (ORDER BY OrderMonth) AS Previous_Order_Count,
           LAG(TotalRevenue) OVER (ORDER BY OrderMonth) AS Previous_Total_Revenue
    FROM MonthlyData
)
-- Calculate growth percentage
SELECT OrderMonth, 
       OrderCount, 
       TotalRevenue,
       (OrderCount - Previous_Order_Count) / Previous_Order_Count * 100.0 AS Order_Count_Growth_Percentage,
       (TotalRevenue - Previous_Total_Revenue) / Previous_Total_Revenue * 100.0 AS Revenue_Growth_Percentage
FROM MonthlyGrowth
WHERE Previous_Order_Count IS NOT NULL;


Q29. Month-wise split of total order value of the top 50 customers 
     (The top 50 customers need to identified based on their total order value)

--- Step 1: Identify the top 50 customers by total order value
WITH TOP_5_CUSTOMERS AS( 
 SELECT TOP 50 CUSTOMER_KEY,SUM(ORDER_TOTAL) AS Total_Order_Value
 FROM ORDERS
 GROUP BY CUSTOMER_KEY
 ORDER BY Total_Order_Value DESC
 ),
----- Step 2: Calculate the monthly order value for the top 50 customers
MonthlyOrderValue AS (
    SELECT 
        FORMAT(ORDER_DATE,'MMMM') AS Order_Month,
        CUSTOMER_KEY,
        SUM(ORDER_TOTAL) AS Monthly_Order_Value
    FROM ORDERS
    WHERE CUSTOMER_KEY IN (SELECT CUSTOMER_KEY FROM TOP_5_CUSTOMERS)
    GROUP BY FORMAT(ORDER_DATE,'MMMM'), CUSTOMER_KEY
)
SELECT Order_Month, SUM(Monthly_Order_Value) AS Total_Monthly_Order_Value
FROM MonthlyOrderValue
GROUP BY Order_Month
ORDER BY ORDER_MONTH

Q30. Total Revenue, total orders by each location
   SELECT C.LOCATION, SUM(O.ORDER_TOTAL) AS TOTAL_ORDER, COUNT(ORDER_NUMBER) AS TOTAL_ORDERS
   FROM ORDERS O
  , CUSTOMERS C
  WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
  GROUP BY C.LOCATION


Q31. Total revenue, total orders by customer gender
  SELECT C.GENDER, SUM(O.ORDER_TOTAL) AS TOTAL_ORDER, COUNT(O.ORDER_NUMBER) AS TOTAL_ORDERS
  FROM ORDERS O
  , CUSTOMERS C
  WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
  GROUP BY C.GENDER


Q32. Which location of customers cancelling orders maximum
SELECT TOP 1 LOCATION 
FROM (SELECT C.LOCATION , COUNT(*) AS MAX_ORDER_CANCELLATION
      FROM ORDERS O
      ,CUSTOMERS C
      WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
      AND O.ORDER_STATUS = 'CANCELLED'
      GROUP BY C.LOCATION
	  ) AS SubQuery
ORDER BY MAX_ORDER_CANCELLATION DESC;

Q33. Total customers, Revenue, Orders by each Acquisition channel?

---USING SIMPLE SELECT QUERY:-
SELECT C.ACQUIRED_CHANNEL, SUM(ORDER_TOTAL) AS REVENUE, COUNT(ORDER_NUMBER) AS COUNT_OF_ORDERS, COUNT(CUSTOMER_ID) AS TOTAL_NUMBER_OF_CUSTOMERS
FROM ORDERS O,
CUSTOMERS C
WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY 
GROUP BY C.ACQUIRED_CHANNEL

---USING WITH CLAUSE:-(CTE FUNCTION)
WITH CTE AS 
(
  SELECT C.ACQUIRED_CHANNEL, SUM(ORDER_TOTAL) AS TOTAL_ORDER, COUNT(ORDER_NUMBER) AS NUMBER_OF_ORDERS, COUNT(C.CUSTOMER_ID) AS NUMBER_OF_CUSTOMERS 
  FROM ORDERS O
  , CUSTOMERS C
  WHERE O.CUSTOMER_KEY = O.CUSTOMER_KEY
  GROUP BY C.ACQUIRED_CHANNEL
) 

SELECT ACQUIRED_CHANNEL, TOTAL_ORDER, NUMBER_OF_ORDERS, NUMBER_OF_CUSTOMERS 
FROM CTE
ORDER BY ACQUIRED_CHANNEL;


Q34. Which acquisition channel is good in terms of revenue generation, maximum orders, repeat purchasers?
SELECT C.ACQUIRED_CHANNEL, MAX(ORDER_TOTAL), 
FROM ORDERS O,
CUSTOMERS C
WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY C.ACQUIRED_CHANNEL

Q35. Prepare at least 5 additional analysis on your own? 
---A. Order Count by Customer Different Location
SELECT C.LOCATION, COUNT(ORDER_NUMBER) AS NUMBER_OF_ORDERS
FROM ORDERS O,
CUSTOMERS C
WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY C.LOCATION

---B.Customer Acquisition Channel Performance:
SELECT C.ACQUIRED_CHANNEL, COUNT(O.ORDER_NUMBER) AS NUMBER_OF_ORDERS
FROM ORDERS O
, CUSTOMERS C
WHERE O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY C.ACQUIRED_CHANNEL

---C. ORDER NUMBER WITH NULL DELIVERY STATUS:
SELECT O.ORDER_NUMBER
FROM ORDERS O,
CUSTOMERS C
WHERE O.CUSTOMER_KEY = O.CUSTOMER_KEY
AND O.DELIVERY_STATUS IS NULL
GROUP BY O.ORDER_NUMBER;

---D.COUNT OF MALE & FEMALE WHO REFERRED OTHER CUSTOMERS:
SELECT GENDER, COUNT(*) AS COUNT_OF_GENDER
FROM CUSTOMERS
WHERE REFERRED_OTHER_CUSTOMERS <> 0
GROUP BY GENDER 

--- E. ORDER NUMBER THAT ARE CANCELLED
SELECT ORDER_NUMBER 
FROM ORDERS
WHERE ORDER_STATUS = 'CANCELLED'
GROUP BY ORDER_NUMBER 
































 





