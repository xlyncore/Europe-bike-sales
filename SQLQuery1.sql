SELECT * FROM bike_sales
---KPI---
SELECT 
    SUM(Revenue) AS total_revenue,
    SUM(Revenue) / COUNT(*) AS average_order_value,
    SUM(CASE WHEN Product_Category = 'Accessories' THEN Order_Quantity ELSE 0 END) AS total_accessories_sold,
    SUM(CASE WHEN Product_Category = 'Bikes' THEN Order_Quantity ELSE 0 END) AS total_bikes_sold,
    SUM(CASE WHEN Product_Category = 'Clothing' THEN Order_Quantity ELSE 0 END) AS total_clothing_sold,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Product_Category = 'Accessories' THEN Order_Quantity ELSE 0 END) / COUNT(*) AS avg_accessories_per_order,
    SUM(CASE WHEN Product_Category = 'Bikes' THEN Order_Quantity ELSE 0 END) / COUNT(*) AS avg_bikes_per_order,
    SUM(CASE WHEN Product_Category = 'Clothing' THEN Order_Quantity ELSE 0 END) / COUNT(*) AS avg_clothing_per_order
FROM bike_sales;


---Daily Trend For Total Orders---
SELECT 
    DATENAME(WEEKDAY, date) AS order_day, 
    COUNT(*) AS total_orders
FROM bike_sales
GROUP BY DATENAME(WEEKDAY, date), DATEPART(WEEKDAY, date)
ORDER BY DATEPART(WEEKDAY, date);


---Monthly Trend For Total Orders---
WITH MonthlyRevenue AS (
    SELECT 
        Year, 
        DATENAME(MONTH, date) AS order_month, 
        MONTH(date) AS month_number,
        SUM(Revenue) AS total_revenue,
        SUM(SUM(Revenue)) OVER (PARTITION BY Year) AS yearly_total
    FROM bike_sales
    GROUP BY Year, DATENAME(MONTH, date), MONTH(date)
)
SELECT 
    Year, 
    order_month, 
    month_number,
    total_revenue,
    yearly_total,
    ROUND((total_revenue * 100.0 / yearly_total), 2) AS percentage_of_year
FROM MonthlyRevenue
ORDER BY Year, month_number;


---% of Sales by Product Category---
WITH CategorySales AS (
    SELECT 
        product_category,
        SUM(unit_price * Order_Quantity) AS category_sales
    FROM bike_sales
    GROUP BY product_category
),
TotalSales AS (
    SELECT CAST(SUM(unit_price * Order_Quantity) AS DECIMAL(10,2)) AS total_sales FROM bike_sales
)
SELECT 
    c.product_category,
    c.category_sales,
    CAST((c.category_sales * 100.0) / t.total_sales AS DECIMAL(10,2)) AS sales_percentage
FROM CategorySales c
CROSS JOIN TotalSales t
ORDER BY sales_percentage DESC;


---% of Sales by SUB Category---
WITH SubCategorySales AS (
    SELECT 
        Sub_Category,
        SUM(Order_Quantity) AS subcategory_sales
    FROM bike_sales
    GROUP BY sub_category
),
TotalSales AS (
    SELECT CAST(SUM(Order_Quantity) AS DECIMAL(10,2)) AS total_sales 
    FROM bike_sales
)
SELECT 
    s.sub_category,
    s.subcategory_sales,
    CAST((s.subcategory_sales * 100.0) / t.total_sales AS DECIMAL(10,2)) AS sales_percentage
FROM SubCategorySales s
CROSS JOIN TotalSales t
ORDER BY sales_percentage DESC;


---% of Sales by Product---
WITH ProductSales AS (
    SELECT 
        product,
        SUM(order_quantity) AS product_sales
    FROM bike_sales
    GROUP BY product
),
TotalSales AS (
    SELECT CAST(SUM(order_quantity) AS DECIMAL(10,2)) AS total_sales 
    FROM bike_sales
)
SELECT 
    p.product,
    p.product_sales,
    CAST((p.product_sales * 100.0) / t.total_sales AS DECIMAL(10,2)) AS sales_percentage
FROM ProductSales p
CROSS JOIN TotalSales t
ORDER BY sales_percentage DESC;


---Total Product Sold---
SELECT 
    Product,
    Sub_Category,
    Product_Category,
    SUM(Revenue) AS total_revenue,
    SUM(Order_Quantity) AS total_quantity_sold,
    AVG(Revenue) AS avg_order_value
FROM bike_sales
GROUP BY Product, Sub_Category, Product_Category
ORDER BY total_quantity_sold DESC


---Top 5 Product by Revenue---
WITH RankedProducts AS (
    SELECT 
        Product_Category,
        Product,
        SUM(Revenue) AS total_revenue,
        RANK() OVER (PARTITION BY Product_Category ORDER BY SUM(Revenue) DESC) AS Rank
    FROM bike_sales
    GROUP BY Product_Category, Product
)
SELECT 
    Product_Category,
    Product,
    Total_Revenue,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Product_Category, Rank;


---Bottom 5 Product by Revenue---
WITH RankedProducts AS (
    SELECT 
        Product,
        SUM(Revenue) AS Total_Revenue,
        RANK() OVER (ORDER BY SUM(Revenue) ASC) AS Rank
    FROM bike_sales
    GROUP BY Product
)
SELECT 
    Product,
    Total_Revenue,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Rank;


---Top 5 Product by Quantity---
WITH RankedProducts AS (
    SELECT 
        Product_Category,
        Product,
        SUM(Order_Quantity) AS total_quantity,
        RANK() OVER (PARTITION BY Product_Category ORDER BY SUM(Order_Quantity) DESC) AS Rank
    FROM bike_sales
    GROUP BY Product_Category, Product
)
SELECT 
    Product_Category,
    Product,
    Total_Quantity,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Product_Category, Rank;


---Bottom 5 Product by Quantity---
WITH RankedProducts AS (
    SELECT 
        Product,
        SUM(Order_Quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(Order_Quantity) ASC) AS Rank
    FROM bike_sales
    GROUP BY Product
)
SELECT 
    Product,
    total_quantity,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Rank;



---Top 5 Product by Orders---
WITH RankedProducts AS (
    SELECT 
        Product_Category,
        Product,
        COUNT(*) AS total_orders,
        RANK() OVER (PARTITION BY Product_Category ORDER BY COUNT(*) DESC) AS Rank
    FROM bike_sales
    GROUP BY Product_Category, Product
)
SELECT 
    Product_Category,
    Product,
    Total_Orders,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Product_Category, Rank;


---Bottom 5 Product by Orders---
WITH RankedProducts AS (
    SELECT 
        Product,
        COUNT(*) AS total_orders,
        RANK() OVER (ORDER BY  COUNT(*) ASC) AS Rank
    FROM bike_sales
    GROUP BY Product
)
SELECT 
    Product,
    total_orders,
    Rank
FROM RankedProducts
WHERE Rank <= 5
ORDER BY Rank;


---By Age and Gender---
SELECT 
    Age_Group,
    Customer_Gender,
    Product_Category,
    Product,
    COUNT(*) AS Total_Orders,
    SUM(Order_Quantity) AS Total_Quantity
FROM bike_sales
GROUP BY Age_Group, Customer_Gender, Product_Category, Product
ORDER BY Total_Orders DESC;


---By Country and State---
SELECT 
    Country,
    State,
    SUM(Order_Quantity) AS Total_Orders
FROM bike_sales
GROUP BY Country, State
ORDER BY Total_Orders DESC;
