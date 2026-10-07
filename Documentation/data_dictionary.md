## SQL Data Transformation

PostgreSQL was used as the primary data preparation and transformation layer.

The raw transactional tables were analyzed, cleaned, aggregated, validated, and converted into analytical tables.

Final Analytical Tables
order_level

Grain: 1 row = 1 order

Contains order-level information including:

Order ID
Customer
Order status
Order dates
Delivery information
Order value
Freight
Review information

Primary Key: order_id

This table serves as the central order-level analytical table.

customer_level

Grain: 1 row = 1 customer

Contains:

Total orders
Completed orders
Total spend
Completed spend
Completed AOV
First order date
Last order date
Customer lifespan

Primary Key: customer_unique_id

This table was designed specifically for customer-level behavioral analysis.

product_level

Grain: 1 row = 1 product

Contains:

Product category
Product dimensions
Total orders
Units sold
Distinct customers
Revenue
Freight revenue
Average selling price
Average freight value

Primary Key: product_id

Product category translations were incorporated into the analytical table, including fallback mappings for unmatched categories.

seller_level

Grain: 1 row = 1 seller

Contains:

Seller location
Total orders
Units sold
Distinct customers
Revenue
Freight revenue
Average selling price
Average freight value
Average revenue per order

Primary Key: seller_id

order_item_fact

Grain: 1 row = 1 order item

Contains:

Order ID
Order item ID
Product ID
Seller ID
Customer ID
Item price
Freight value
Shipping limit date
Order status

Composite Primary Key: (order_id, order_item_id)

This table acts as the transactional fact table connecting orders with products and sellers.

A separate order-item fact table was necessary because product and seller information exists at the item level, while customers and order information exist at the order level.



## Data Validation

Validation was performed throughout the SQL transformation process to ensure analytical reliability.

Key checks included:

Primary-key uniqueness
Row counts
Missing values
Referential integrity
Revenue reconciliation
Freight reconciliation
Duplicate detection
Product and seller relationship validation
Order/item relationship validation
Delivery-date consistency
Order-status consistency

Examples:

order_level contains 99,441 orders
customer_level contains 96,096 customers
product_level contains 32,951 products
seller_level contains 3,095 sellers
order_item_fact contains 112,650 order-item records

The validations confirmed that the analytical tables were structurally consistent before being loaded into Power BI.



## DAX & KPI Layer

DAX was used in Power BI to create reusable analytical measures.

Order KPIs
Total Orders
Completed Orders
Cancelled Orders
Delivered Order Rate
Revenue KPIs
Total Revenue
Total Freight Revenue
Total Sales Value
Average Order Value
Customer KPIs
Total Customers
Repeat Customers
Repeat Customer Rate
Average Orders per Active Customer
Average Spend per Active Customer
Product KPIs
Total Units Sold
Distinct Products Sold
Average Selling Price
Seller KPIs
Distinct Sellers
Average Freight Value
Delivery KPIs
Average Delivery Days
Average Delivery Variance

For delivery variance:

Actual Delivery Days − Estimated Delivery Days

Therefore:

Negative = delivered early
Zero = delivered on time
Positive = delivered late