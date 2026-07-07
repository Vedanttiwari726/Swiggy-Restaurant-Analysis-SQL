/*=========================================================
        FOOD DELIVERY ANALYTICS PROJECT
=========================================================*/

CREATE DATABASE food_delivery_analytics;
USE food_delivery_analytics;
show tables;

/* CHECK IMPORTED DATA */
SELECT *
FROM swiggy_cleaned_analytics_Dataset;
 /* DUPLICATE DATA */
SELECT
State,
City,
Order_Date,
Restaurant_Name,
Location,
Category,
Dish_Name,
Price_INR,
Rating,
Rating_Count,
COUNT(*) AS Duplicate_Count
FROM swiggy_cleaned_analytics_Dataset
GROUP BY
State,
City,
Order_Date,
Restaurant_Name,
Location,
Category,
Dish_Name,
Price_INR,
Rating,
Rating_Count
HAVING COUNT(*) > 1;

/*=========================================================
CREATE STAR SCHEMA
=========================================================*/

/* DIM DATE */

CREATE TABLE dim_date(
date_id INT AUTO_INCREMENT PRIMARY KEY,
Full_Date DATE,
Year INT,
Month INT,
Month_Name VARCHAR(20),
Quarter INT,
Day INT,
Week INT
);

/* DIM LOCATION */

CREATE TABLE dim_location(
location_id INT AUTO_INCREMENT PRIMARY KEY,
State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(100)
);

/* DIM RESTAURANT */

CREATE TABLE dim_restaurant(
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
Restaurant_Name VARCHAR(255)
);

/* DIM CATEGORY */

CREATE TABLE dim_category(
category_id INT AUTO_INCREMENT PRIMARY KEY,
Category VARCHAR(100)
);

/* DIM DISH */

CREATE TABLE dim_dish(
dish_id INT AUTO_INCREMENT PRIMARY KEY,
Dish_Name VARCHAR(255)
);

/* FACT TABLE */

CREATE TABLE fact_swiggy_orders(
order_id INT AUTO_INCREMENT PRIMARY KEY,

date_id INT,
location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,

Price_INR DECIMAL(10,2),
Rating DECIMAL(3,1),
Rating_Count INT,

FOREIGN KEY(date_id) REFERENCES dim_date(date_id),
FOREIGN KEY(location_id) REFERENCES dim_location(location_id),
FOREIGN KEY(restaurant_id) REFERENCES dim_restaurant(restaurant_id),
FOREIGN KEY(category_id) REFERENCES dim_category(category_id),
FOREIGN KEY(dish_id) REFERENCES dim_dish(dish_id)
);

/*=========================================================
INSERT DATA INTO DIMENSION TABLES
=========================================================*/

/* DIM DATE */

INSERT INTO dim_date
(Full_Date,Year,Month,Month_Name,Quarter,Day,Week)
SELECT DISTINCT
STR_TO_DATE(Order_Date,'%d-%m-%Y'),
YEAR(STR_TO_DATE(Order_Date,'%d-%m-%Y')),
MONTH(STR_TO_DATE(Order_Date,'%d-%m-%Y')),
MONTHNAME(STR_TO_DATE(Order_Date,'%d-%m-%Y')),
QUARTER(STR_TO_DATE(Order_Date,'%d-%m-%Y')),
DAY(STR_TO_DATE(Order_Date,'%d-%m-%Y')),
WEEK(STR_TO_DATE(Order_Date,'%d-%m-%Y'))
FROM swiggy_cleaned_analytics_Dataset;

/* DIM LOCATION */

INSERT INTO dim_location(State,City,Location)
SELECT DISTINCT
State,
City,
Location
FROM swiggy_cleaned_analytics_Dataset;

/* DIM RESTAURANT */

INSERT INTO dim_restaurant(Restaurant_Name)
SELECT DISTINCT
Restaurant_Name
FROM swiggy_cleaned_analytics_Dataset;

/* DIM CATEGORY */

INSERT INTO dim_category(Category)
SELECT DISTINCT
Category
FROM swiggy_cleaned_analytics_Dataset;

/* DIM DISH */

INSERT INTO dim_dish(Dish_Name)
SELECT DISTINCT
Dish_Name
FROM swiggy_cleaned_analytics_Dataset;

/*=========================================================
INSERT DATA INTO FACT TABLE
=========================================================*/

INSERT INTO fact_swiggy_orders
(
date_id,
location_id,
restaurant_id,
category_id,
dish_id,
Price_INR,
Rating,
Rating_Count
)

SELECT
dd.date_id,
dl.location_id,
dr.restaurant_id,
dc.category_id,
di.dish_id,
s.Price_INR,
s.Rating,
s.Rating_Count

FROM swiggy_cleaned_analytics_Dataset s

JOIN dim_date dd
ON dd.Full_Date=STR_TO_DATE(s.Order_Date,'%d-%m-%Y')

JOIN dim_location dl
ON dl.State=s.State
AND dl.City=s.City
AND dl.Location=s.Location

JOIN dim_restaurant dr
ON dr.Restaurant_Name=s.Restaurant_Name

JOIN dim_category dc
ON dc.Category=s.Category

JOIN dim_dish di
ON di.Dish_Name=s.Dish_Name;

/*=========================================================
CHECK STAR SCHEMA
=========================================================*/

SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
JOIN dim_location l
ON f.location_id=l.location_id
JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id
JOIN dim_category c
ON f.category_id=c.category_id
JOIN dim_dish di
ON f.dish_id=di.dish_id;

/*=========================================================
KPI
=========================================================*/

/* Total Orders */

SELECT
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

/* Total Revenue (INR Million) */

SELECT
CONCAT(
FORMAT(SUM(Price_INR)/1000000,2),
' INR Million'
) AS Total_Revenue
FROM fact_swiggy_orders;

/* Average Dish Price */

SELECT
CONCAT(
FORMAT(AVG(Price_INR),2),
' INR'
) AS Average_Dish_Price
FROM fact_swiggy_orders;

/* Average Rating */

SELECT
ROUND(AVG(Rating),2) AS Average_Rating
FROM fact_swiggy_orders;

/* Total Restaurants */

SELECT
COUNT(*) AS Total_Restaurants
FROM dim_restaurant;

/* Total Categories */

SELECT
COUNT(*) AS Total_Categories
FROM dim_category;

/* Total Dishes */

SELECT
COUNT(*) AS Total_Dishes
FROM dim_dish;

/* Total Cities */

SELECT
COUNT(DISTINCT City) AS Total_Cities
FROM dim_location;

/* Total States */

SELECT
COUNT(DISTINCT State) AS Total_States
FROM dim_location;

/* Highest Rated Dish */

SELECT
d.Dish_Name,
ROUND(AVG(f.Rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_dish d
ON f.dish_id=d.dish_id
GROUP BY d.Dish_Name
ORDER BY Average_Rating DESC
LIMIT 1;

/* Highest Revenue Restaurant */

SELECT
r.Restaurant_Name,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id
GROUP BY r.Restaurant_Name
ORDER BY Total_Revenue DESC
LIMIT 1;

/*=========================================================
DEEP DIVE BUSINESS ANALYSIS
=========================================================*/

/* MONTHLY ORDER TRENDS */

SELECT
d.Year,
d.Month,
d.Month_Name,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year,
d.Month,
d.Month_Name
ORDER BY
d.Year,
d.Month;

/* MONTHLY REVENUE TRENDS */

SELECT
d.Year,
d.Month,
d.Month_Name,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year,
d.Month,
d.Month_Name
ORDER BY
d.Year,
d.Month;

/* QUARTERLY ORDER TRENDS */

SELECT
d.Year,
d.Quarter,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year,
d.Quarter
ORDER BY
d.Year,
d.Quarter;

/* QUARTERLY REVENUE TRENDS */

SELECT
d.Year,
d.Quarter,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year,
d.Quarter
ORDER BY
d.Year,
d.Quarter;

/* YEARLY ORDER TRENDS */

SELECT
d.Year,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year
ORDER BY
d.Year;

/* YEARLY REVENUE TRENDS */

SELECT
d.Year,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
d.Year
ORDER BY
d.Year;

/* ORDERS BY DAY OF WEEK */

SELECT
DAYNAME(d.Full_Date) AS Day_Name,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
DAYOFWEEK(d.Full_Date),
DAYNAME(d.Full_Date)
ORDER BY
DAYOFWEEK(d.Full_Date);

/* TOP 10 CITIES BY ORDERS */

SELECT
l.City,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l
ON f.location_id=l.location_id
GROUP BY
l.City
ORDER BY
Total_Orders DESC
LIMIT 10;

/* TOP 10 CITIES BY REVENUE */

SELECT
l.City,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
ON f.location_id=l.location_id
GROUP BY
l.City
ORDER BY
Total_Revenue DESC
LIMIT 10;

/* TOP STATES BY REVENUE */

SELECT
l.State,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
ON f.location_id=l.location_id
GROUP BY
l.State
ORDER BY
Total_Revenue DESC;

/*=========================================================
TOP 10 RESTAURANTS BY ORDERS
=========================================================*/

SELECT
r.Restaurant_Name,
COUNT(*) AS Total_Orders,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id
GROUP BY
r.Restaurant_Name
ORDER BY
Total_Orders DESC,
Total_Revenue DESC
LIMIT 10;

/*=========================================================
TOP 10 RESTAURANTS BY REVENUE
=========================================================*/

SELECT
r.Restaurant_Name,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id
GROUP BY
r.Restaurant_Name
ORDER BY
Total_Revenue DESC
LIMIT 10;

/*=========================================================
TOP CATEGORIES BY ORDERS
=========================================================*/

SELECT
c.Category,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category c
ON f.category_id=c.category_id
GROUP BY
c.Category
ORDER BY
Total_Orders DESC;

/*=========================================================
TOP CATEGORIES BY REVENUE
=========================================================*/

SELECT
c.Category,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_category c
ON f.category_id=c.category_id
GROUP BY
c.Category
ORDER BY
Total_Revenue DESC;

/*=========================================================
MOST ORDERED DISHES
=========================================================*/

SELECT
d.Dish_Name,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_dish d
ON f.dish_id=d.dish_id
GROUP BY
d.Dish_Name
ORDER BY
Total_Orders DESC
LIMIT 10;

/*=========================================================
TOP REVENUE GENERATING DISHES
=========================================================*/

SELECT
d.Dish_Name,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_dish d
ON f.dish_id=d.dish_id
GROUP BY
d.Dish_Name
ORDER BY
Total_Revenue DESC
LIMIT 10;

/*=========================================================
CUISINE PERFORMANCE
=========================================================*/

SELECT
c.Category AS Cuisine,
COUNT(*) AS Total_Orders,
ROUND(AVG(f.Rating),2) AS Average_Rating,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_category c
ON f.category_id=c.category_id
GROUP BY
c.Category
ORDER BY
Total_Orders DESC;

/*=========================================================
TOTAL ORDERS BY PRICE RANGE
=========================================================*/

SELECT
CASE
WHEN Price_INR<200 THEN 'Below ₹200'
WHEN Price_INR BETWEEN 200 AND 499 THEN '₹200-₹499'
WHEN Price_INR BETWEEN 500 AND 999 THEN '₹500-₹999'
ELSE '₹1000+'
END AS Price_Range,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders
GROUP BY Price_Range
ORDER BY
MIN(Price_INR);

/*=========================================================
RATING OF MOST ORDERED DISHES
=========================================================*/

SELECT
d.Dish_Name,
ROUND(AVG(f.Rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_dish d
ON f.dish_id=d.dish_id
GROUP BY
d.Dish_Name
ORDER BY
COUNT(*) DESC
LIMIT 10;

/*=========================================================
TOP RATED RESTAURANTS
=========================================================*/

SELECT
r.Restaurant_Name,
ROUND(AVG(f.Rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id
GROUP BY
r.Restaurant_Name
ORDER BY
Average_Rating DESC
LIMIT 10;

/*=========================================================
TOP RATED CITIES
=========================================================*/

SELECT
l.City,
ROUND(AVG(f.Rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_location l
ON f.location_id=l.location_id
GROUP BY
l.City
ORDER BY
Average_Rating DESC
LIMIT 10;

/*=========================================================
TOP RATED STATES
=========================================================*/

SELECT
l.State,
ROUND(AVG(f.Rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_location l
ON f.location_id=l.location_id
GROUP BY
l.State
ORDER BY
Average_Rating;

SELECT
COUNT(*) AS FactRows,
COUNT(date_id) AS DateIDs
FROM fact_swiggy_orders;

SELECT
MIN(date_id),
MAX(date_id)
FROM fact_swiggy_orders;

SELECT
MIN(date_id) AS Min_Date_ID,
MAX(date_id) AS Max_Date_ID
FROM fact_swiggy_orders;
select* from fact_swiggy_orders;