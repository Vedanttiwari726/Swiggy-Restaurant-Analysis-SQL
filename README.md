# 🍽️ Swiggy Restaurant Analysis using MySQL

## 📌 Project Overview

This project analyzes Swiggy restaurant data using MySQL. The project follows a simple data warehouse approach by creating dimension and fact tables and then performing SQL analysis to generate business insights.

---

## 📂 Dataset

The dataset contains the following fields:

- Restaurant Name
- Cuisine
- Rating
- Number of Ratings
- Average Price
- Number of Offers
- Offer Name
- Area
- Pure Veg
- Location

---

## 🛠️ Tools Used

- MySQL 8.0
- MySQL Workbench

---

## 🗄️ Database Design

The project includes:

- `swiggy_data` (Main Table)
- `dim_restaurant`
- `dim_cuisine`
- `dim_location`
- `dim_offer`
- `fact_restaurant`

The data is organized into dimension tables and a fact table for better analysis.

---

## 📚 SQL Concepts Used

- CREATE DATABASE
- CREATE TABLE
- ALTER TABLE
- INSERT DATA (via import)
- INNER JOIN
- GROUP BY
- ORDER BY
- Aggregate Functions (COUNT, SUM, AVG, MAX)
- CASE Statement
- LIMIT

---

## 📊 Key Performance Indicators (KPIs)

- Total Restaurants
- Average Rating
- Average Price
- Total Offers

---

## 📈 Business Analysis Performed

- Top 10 Rated Restaurants
- Cuisine Performance Analysis
- Location Performance Analysis
- Pure Veg vs Non Veg Restaurants
- Restaurants with Maximum Offers
- Price Range Analysis
- Average Rating by Price Range
- Top Offer Names

---

## 📸 SQL Output

![SQL Query Results](screenshots/sql_analysis_outputs.png)

---

## 📁 Project Structure

```
Swiggy-Restaurant-Analysis-SQL/
│
├── README.md
├── Swiggy_Restaurant_Analysis_MySQL.sql
├── swiggy_dataset.csv
└── screenshots/
    └── sql_analysis_outputs.png
```

---

## ▶️ How to Run

1. Create the database in MySQL.
2. Import the Swiggy dataset into `swiggy_data`.
3. Execute the SQL script.
4. Run the KPI and business analysis queries.

---

## 🎯 Skills Demonstrated

- SQL
- Database Design
- Data Modeling
- Data Analysis
- Business Insight Generation

---

## 👤 Author

**Vedant Tiwari**
