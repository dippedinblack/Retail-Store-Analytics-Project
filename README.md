# Retail Store Sales Analytics Project (SQL & Tableau)

## Project Overview  
This project leverages the well-known **Superstore dataset** (modified for recency) to deliver insights into sales, profit margins, discounts, returns, and customer growth.  

The analysis combines **SQL** for data cleaning, modeling, and KPI calculations with **Tableau** for visualization and interactive dashboards. The dataset consists of ~10,000 rows, with dates adjusted to ensure relevance.  



## Project Objectives  
The project aims to generate **actionable insights** into the company’s sales performance, profitability, and customer behavior to support informed strategic decision-making.  



## Exploration Questions  
- Which product categories and sub-categories are most profitable?  
- How do returns affect net sales and margins?  
- Who are the top 10 customers in each segment, and what drives their value?  
- How do discounts correlate with sales volume and profit margin?  
- How has the customer base grown year-over-year?  



## Tools and Technologies  
- **Excel** – dataset source and initial formatting  
- **PostgreSQL** – data preparation, normalization, and analysis  
- **Tableau** – visualization and dashboarding  



## Approach  
1. The dataset was obtained from Tableau in Excel format. Dates, quantitative measures, and product names were standardized to match SQL syntax.  
2. The dataset was uploaded into **PostgreSQL** for preparation and manipulation. It was normalized into four tables — **order_items**, **orders**, **products**, and **customers** — to ensure consistency.  
3. A comprehensive SQL analysis was conducted to examine KPIs, sales and profit performance, product performance, customer behavior, and shipping/operational efficiency.  
4. The cleaned and transformed dataset was then connected to **Tableau**, where two dashboards were built:  
   - **Sales Dashboard**  
   - **Customers Dashboard**  
   Both dashboards included a **year-selection parameter**.  



## Dashboards Description  

### Sales Dashboard  
- **KPIs:** Total Sales, Total Profits, Total Returns (in value), CY vs PY trends, YoY Growth Rate  
- **Horizontal Bar Chart:** Sales and Profits by Sub-Category (Top & Bottom performers)  
- **Histogram:** Distribution of Sales and Profits across discount levels  

### Customers Dashboard  
- **KPIs:** Total Customers, Total Orders, Avg. Sales per Customer, CY vs PY trends, YoY Growth Rate  
- **Vertical Bar Chart:** Sales and Profits by Customer Segment  
- **Scatter Plot:** Cities categorized by Sales and Profit to identify high- and low-performing regions  



## Key Insights (CY 2024 vs PY 2023)  

1. **Sales increased by 14.77% YoY**, but profits declined slightly by -1.86%. Sales peak in October–November and dip in January.  
2. **Returns rose significantly** compared to PY, with California reporting the highest volume. However, no strong correlation was found between returns and either delivery time or discounts.  
3. **Top 5 sub-categories by sales:** Phones, Chairs, Binders, Storage, and Tables. Interestingly, Tables, despite being a top seller recorded one of the lowest profits, while Accessories and Copiers ranked 6th and 7th by sales but had the highest profits. 
4. **Discount analysis:**  Higher discount levels (>20%) did not drive expected sales volumes and were unprofitable. No-discount sales generated the highest revenue and profit, while 20% discounts yielded balanced sales and profitability.
5. **Customer growth:** Both customer count and orders rose YoY, with **average sales per customer also improving**. Growth accelerated from August, peaking in November.  
6. **Segment performance:**  The Consumer segment generated the highest sales and profits, followed by Corporate and then Home Office.
7. **City-level performance:**  Out of all cities, 131 contributed low sales and low profits, while 31 cities achieved both high sales and high profits. Another 32 cities performed strongly in either sales or profit, but not both.
8. **Shipping:**  Standard shipping mode accounted for the highest number of orders — and also the highest returns. Contrary to common belief, longer delivery times correlated with fewer returns compared to shorter delivery times.
   
## Files Included  

## 📂 Files Included  

- [README.md](README.md) → Provides a description of the project  
- [sales 2.csv](sales%202.csv) → Raw dataset of retail store sales  
- [store sales database create queries.sql](store%20sales%20database%20create%20queries.sql) → SQL queries for creating data tables to ensure data consistency  
- [store sales eda.sql](store%20sales%20eda.sql) → SQL queries for exploratory data analysis (EDA)  
- [store sales analysis.sql](store%20sales%20analysis.sql) → SQL queries for project data analysis  
- [database design diagram.pdf](database%20design%20diagram.pdf) → Database design diagram  
- [sales dashboard.png](sales%20dashboard.png) → Sales dashboard with all visualizations  
- [customer dashboard.png](customer%20dashboard.png) → Customer dashboard with all visualizations  
 


