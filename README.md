# Olist E-Commerce Analytics — Project Documentation

## 1. Project Overview
Project Title

Olist E-Commerce Sales & Customer Analytics

Objective

The objective of this project was to analyze the Brazilian Olist e-commerce dataset and build an interactive business intelligence solution that provides insights into:

Overall sales and order performance
Customer purchasing behavior and retention
Product and category performance
Seller performance
Order fulfillment and delivery efficiency

The project transforms raw transactional data into an analytical data model and ultimately presents the findings through an interactive Power BI dashboard.

Business Questions

The analysis was designed to answer questions such as:

How much revenue is the business generating?
What is the overall order and delivery performance?
How many customers are repeat customers?
Which products and categories generate the most revenue?
Which sellers contribute the most revenue?
How efficiently are orders being delivered?
Where are the major delivery delays or variations occurring?


## 2. Dataset & Data Sources

The project uses the Brazilian Olist e-commerce dataset, consisting of multiple relational tables covering:

Orders
Customers
Order items
Products
Sellers
Payments
Reviews
Product category translations
Geolocation

Rather than directly connecting all raw tables to Power BI, the data was transformed into purpose-built analytical tables using PostgreSQL.

Data Preparation Approach

The workflow was:

Raw Olist Dataset → PostgreSQL Transformation → Analytical Data Model → DAX Measures → Power BI Dashboard



## 3. Data Model

The final Power BI model follows a simplified relational/star-like architecture.

Relationships
customer_level
      │
      ▼
order_level
      │
      ▼
order_item_fact
   ▲          ▲
   │          │
product_level seller_level

Relationships:

customer_level → order_level
order_level → order_item_fact
product_level → order_item_fact
seller_level → order_item_fact

All relationships use single-direction filtering.

Why this model?

The model avoids unnecessary direct relationships and prevents ambiguous filter paths.

For example, a direct relationship between customer_level and order_item_fact was deliberately avoided because customers can already reach order items through:

customer_level → order_level → order_item_fact

This keeps the model predictable and easier to maintain.



## 4. Power BI Dashboard

The final dashboard consists of four analytical pages.

### Page 1 — Executive Overview

Purpose: provide a high-level view of business performance.

Key elements:

Total Orders
Completed Orders
Total Revenue
Average Order Value
Total Customers
Delivered Order Rate
Revenue trend
Orders by status
Revenue by product category
Revenue by seller state
Revenue vs freight
Interactive slicers

This page is designed for management-level overview.

### Page 2 — Customer Analytics

Purpose: understand customer behavior and repeat purchasing.

Key elements:

Total Customers
Repeat Customers
Repeat Customer Rate
Average Orders per Active Customer
Average Spend per Active Customer
Customer distribution by completed orders
Customer purchase segments
Top customers by completed spend
Customer orders vs AOV
Repeat customer lifespan distribution

A major finding from the analysis is that the customer base is heavily concentrated around one-time purchasers, while repeat customers represent a relatively small proportion of active customers.

### Page 3 — Product & Seller Performance

Purpose: identify the products, categories and sellers driving marketplace performance.

Key elements:

Total Revenue
Total Units Sold
Distinct Products Sold
Distinct Sellers
Average Selling Price
Total Freight Revenue
Top product categories by revenue
Top product categories by units sold
Top products by revenue
Revenue by seller state
Top sellers by revenue
Seller revenue vs average selling price

This page enables comparison between marketplace participants and identifies high-performing categories, products and sellers.

### Page 4 — Order & Delivery Analytics

Purpose: evaluate order progression and fulfillment performance.

Key elements:

Total Orders
Completed Orders
Cancelled Orders
Delivered Order Rate
Average Delivery Days
Average Delivery Variance
Order status distribution
Delivery time trend
Delivery performance
Delivery time distribution
Average delivery time by seller state
Seller revenue vs delivery time

The delivery variance analysis distinguishes between:

Early → On Time → Late

which allows fulfillment performance to be analyzed rather than simply looking at average delivery time.



## 5. Key Business Insights

Based on the completed analysis:

Customer Behavior

The customer base is strongly dominated by one-time purchasers. Repeat customers represent only a small proportion of active customers, indicating a potential opportunity for customer retention and repeat-purchase strategies.

Repeat Customer Behavior

Among repeat customers, the average number of completed orders is approximately 2.11, showing that even repeat customers generally make only a small number of additional purchases.

Product Performance

Revenue is concentrated among certain product categories and individual products, allowing the business to identify its strongest product segments.

Seller Performance

Seller-level analysis highlights significant differences in revenue contribution, selling prices and order volumes across sellers.

Delivery Performance

Delivery variance provides a more meaningful fulfillment perspective because it accounts for the expected delivery date. Negative variance represents early delivery, while positive variance represents late delivery.



## 6. Tools & Technologies
Database & Data Transformation

PostgreSQL

Used for:

SQL transformations
Aggregation
Data cleaning
Analytical table creation
Validation
Relational modeling
Business Intelligence

Microsoft Power BI

Used for:

Data modeling
Interactive dashboards
Visualization
Filtering
Business analysis
Analytical Language

DAX

Used for:

KPI calculations
Business metrics
Dynamic dashboard calculations
Aggregations and ratios



## 7. End-to-End Workflow

The complete project workflow can be summarized as:

Olist Raw Dataset
        ↓
Data Exploration
        ↓
PostgreSQL
        ↓
Data Cleaning & Transformation
        ↓
Analytical Tables
        ↓
Data Validation
        ↓
Power BI Data Model
        ↓
DAX KPI Layer
        ↓
Interactive Dashboard
        ↓
Business Insights



## 8. Project Outcome

The project converts a large relational e-commerce dataset into a structured analytical solution capable of answering business questions across sales, customers, products, sellers and delivery performance.

The final solution demonstrates an end-to-end analytics workflow rather than simply creating visualizations from raw data.





