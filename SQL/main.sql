-- counting rows 

select 'customers' as table_name, count(*) as row_count from customers
union all 
select 'orders', count(*) from orders 
union all 
select 'order_items', count(*) from order_items
union all 
select 'distinct orders',count(distinct order_id) from order_items
union all 
select 'payments', count(*) from payments
union all 
select 'distinct_payments', count(distinct order_id) from payments
union all 
select 'products', count(*) from products
union all 
select 'reviews', count(*) from reviews
union all 
select 'sellers', count(*) from sellers
union all 
select 'geolocation', count(*) from geolocation
union all 
select 'category_translation', count(*) from category_translation


-- identifying null values
select count(*) as total_rows,
count(order_id) as order_id,
count(customer_id) as customer_id,
count(order_purchase_timestamp) as order_purchase_timestamp,
count(order_status) as status,
count(order_approved_at) as approval_time,
count(order_delivered_carrier_date) as order_delivered_carrier_date,
count(order_delivered_customer_date) as order_delivered_customer_date,
count(order_estimated_delivery_date) as order_estimated_delivery_date
from orders;

-- some null order dates


select count(*) as total_rows,
count(product_category_name) as product_category,
count(product_name_lenght) as product_name_length,
count(product_description_lenght) as product_description_length,
count(product_photos_qty) as product_photos_quntity,
count(product_weight_g) as product_weight,
count(product_length_cm) as product_length,
count(product_height_cm) as product_height,
count(product_width_cm) as product_width
from products;

-- some null values 

select count(*) as total_rows,
count(product_id) as products,
count(seller_id) as sellers,
count(price) as price,
count(freight_value) as freight_value_count
from ecommerce.order_items

-- everything is perfect



select count(*) as total_reviews, 
count(review_score) as review_score,
count(review_comment_title) as review_title,
count(review_comment_message) as review_msg,
count(review_creation_date) as review_creation_date,
count(review_answer_timestamp) as review_answer_timestamp
from ecommerce.reviews;

-- title and msgs have null values


-- Checking duplicate values 
select distinct order_id from orders;
-- or 
select order_id, count(*) as occurences 
from orders
group by order_id having count(*) > 1;


select distinct customer_id from customers;
--  or 
select customer_id, count(*) as occurences 
from customers
group by customer_id having count(*) > 1;


select distinct product_id from products;
-- or 
select product_id, count(*) as occurences 
from products
group by product_id having count(*) > 1;


select distinct seller_id from sellers;
-- or 
select seller_id, count(*) as occurences 
from sellers
group by seller_id having count(*) > 1;



-- Checking Invalid numerical values 
select * from order_items where price<=0;
select * from order_items where freight_value<0;

select * from products where 
product_weight_g <=0 
or product_length_cm<=0
or product_height_cm<=0
or product_width_cm<=0
-- a product has a 0 weight


-- Checking invalid review score 
select * from reviews where review_score<1 or review_score>5 ;


-- Understanding orders statuses
select order_status, count(*) from orders group by order_status;



-- Checking payment types and stuffs
select distinct payment_type from payments;

select payment_type, sum(payment_value)  from payments group by payment_type;

select distinct payment_installments from payments;
select payment_installments from payments group by payment_installments;

select * from payments limit 5;

select * from payments where payment_installments > 20;

select payment_type, count(*) from payments group by payment_type;

select order_id, sum(payment_value) as total_value, payment_installments from payments group by order_id,payment_installments order by total_value desc limit 10;


-- Check timestamp consistency ---------------------------------
set search_path to ecommerce;

select * from orders limit 2;

--delivery before purchase
select count(*) from orders where order_delivered_customer_date< order_purchase_timestamp;
-- 0 orders

--approval before purchase 
select count(*) as order_approved_before_purchase from orders where order_approved_at < order_purchase_timestamp;
--0 orders

--customer delivery before carrier delivery
select count(*) from orders where order_delivered_customer_date < order_delivered_carrier_date;
-- 23 orders exist

--delivery to carrier before approval 
select count(*) from orders where order_delivered_carrier_date < order_approved_at;
-- 1359 rows exist

--delivery to customer before approval
select count(*) from orders where order_delivered_customer_date < order_approved_at;


--delivery to carrier before purchase 
select count(*) from orders where order_delivered_carrier_date < order_purchase_timestamp;
-- 166 rows exist

--delivery to customer before purchase
select count(*) from orders where order_delivered_customer_date < order_purchase_timestamp;
-- 0 orders





-- Analyzing missing delivery dates -------------------------------
select 
count(case when order_status = 'delivered' and order_delivered_customer_date is null then 1 end) as Delivered_but_date_missing,
count(case when order_status ='canceled' and order_delivered_customer_date is null then 1 end) as  Cancelled_orders,
count(case when order_status = 'approved' and order_delivered_customer_date is null then 1 end) as Approved_but_date_missing,
count(case when order_status = 'invoiced' and order_delivered_customer_date is null then 1 end) as Invoiced_but_date_missing,
count(case when order_status = 'shipped' and order_delivered_customer_date is null then 1 end) as Shipped_but_date_missing,
count(case when order_status = 'processing' and order_delivered_customer_date is null then 1 end) as Processing_but_date_missing,
count(case when order_status = 'unavailable' and order_delivered_customer_date is null then 1 end) as Unavailable_but_date_missing,
count(case when order_status = 'created' and order_delivered_customer_date is null then 1 end) as Created_but_date_missing
from orders;	

-- date is  missing from every type of order status

select count(*) from orders where order_status='canceled' and order_delivered_customer_date is null;
select count(*) from orders where order_status = 'delivered' and order_delivered_customer_date is null;


select order_status,order_delivered_customer_date
from orders
where order_delivered_customer_date is null 
group by order_status,order_delivered_customer_date;

select order_status, count(*) as order_by_status from orders group by order_status; 



--Calculating Delivery Time ----------------------------------------------------------------------------------------------
select AVG(order_delivered_customer_date::date - order_purchase_timestamp::date) as delivery_time from orders;
--AVERAGE DELIVERY TIME - 12 DAYS.

select 
count(case when order_delivered_customer_date::date <order_estimated_delivery_date::date and  order_delivered_customer_date is not null then 1 end) as orders_delivered_before_estimated_delivery_time,
count(case when order_delivered_customer_date::date> order_estimated_delivery_date::date and  order_delivered_customer_date is not null then 1 end) as orders_delivered_Late,
count(case when order_delivered_customer_date::date = order_estimated_delivery_date::date and  order_delivered_customer_date is not null then 1 end )  as orders_onTime,
count(case when order_delivered_customer_date is not null then 1 end) as total_orders_delivered
from orders;
--88649 orders arrived early, 6535 late, and 1292 on time


--percentage of orders that arrived late 
select count(*) as late_deliveres 
from orders 
where order_delivered_customer_date::date> order_estimated_delivery_date::date 
and order_delivered_customer_date is not null 
and order_estimated_delivery_date is not null;


select Round(100 * count(*) filter(
where order_delivered_customer_date::date> order_estimated_delivery_date::date
)/count(*),2
)
from orders
where order_delivered_customer_date is not null 
and order_estimated_delivery_date is not null;
-- 6 percent of late deliveries 



-- Referential Integrity ---------------------------------------------------

-- order items whose order_id doesn't exist in the orders table.
select o.order_id, oi.order_id 
from orders o right join order_items oi
on o.order_id = oi.order_id
where o.order_id is null ;

--count
select count(*) as total_orphan_records 
from orders o right join order_items oi 
on o.order_id = oi.order_id
where o.order_id is null ;


--- order items whose product_id doesn't exist in the products table.
select p.product_id, oi.product_id as product_id_in_order_items
from products p
right join order_items oi
on p.product_id = oi.product_id
where p.product_id is null;

--count 
select count(*) as total_orphan_record 
from order_items oi
left join products p 
on oi.product_id = p.product_id
where p.product_id is null;


-- order items whose seller_id doesn't exist in the sellers table.
select oi.seller_id as seller_id_in_order_items, s.seller_id as seller_id_in_sellers
from order_items oi
left join sellers s
on oi.seller_id = s.seller_id
where s.seller_id is null;

--count
select count(*) as total_orphan_record 
from order_items oi
left join sellers s
on oi.seller_id = s.seller_id
where s.seller_id is null;


-- order items whose customer_id doesn't exist in the customers table.
select o.customer_id as customer_in_orderTable,
c.customer_id as customer_in_customerTable 
from orders o
left join customers c
on o.customer_id = c.customer_id
where c.customer_id is null;

--count 
select count(*) as total_orphan_record
from orders o
left join customers c
on o.customer_id = c.customer_id
where c.customer_id is null;




---------Analyzing customer_id vs customer_unique_id

select 
count(distinct customer_id),
count(distinct customer_unique_id) 
from customers;

select count(distinct customer_unique_id) as total_unique_customers 
from customers;
-- for actual customer retention and analysis we'll use distinct customer_unique_id 




--Identifying repeat customers-------------------------------
select customer_unique_id, count( customer_id) as records
from customers
group by customer_unique_id 
having count(customer_id) > 1;

-- count
select count(*) from (
select customer_unique_id, count(*) from customers 
group by customer_unique_id  
having count(customer_id) > 1
);




-- Check category translation---------------------------------------------------------------------
select count(distinct product_category_name) from products;
--73 unique product category exist 

-- How many product categories exist?
select count(distinct p.product_category_name) as Product_table, count(distinct c.product_category_name) as Category_translation_table
from products p 
left join category_translation c
on p.product_category_name = c.product_category_name


-- out of 73, 71 exist


-- How many have English translations?
select distinct p.product_category_name, c.product_category_name,c.product_category_name_english
from products p 
left join category_translation c
on p.product_category_name = c.product_category_name
where p.product_category_name is not null
and c.product_category_name_english is not null;


--count
select count(distinct p.product_category_name) as total_product_categories_in_Product_Table,
count(distinct c.product_category_name_english) as English_translations
from products p 
left join category_translation c
on p.product_category_name = c.product_category_name
--71 have translations


-- Are there categories without translations?
select distinct p.product_category_name, c.product_category_name,c.product_category_name_english
from products p 
left join category_translation c
on p.product_category_name = c.product_category_name
where p.product_category_name is not null
and c.product_category_name_english is null;
-- yes 2 categories 
--count 
select count(*) as categories_without_translation
from (
select distinct p.product_category_name, c.product_category_name,c.product_category_name_english
from products p 
left join category_translation c
on p.product_category_name = c.product_category_name
where p.product_category_name is not null
and c.product_category_name_english is null
);


select count(distinct p.product_category_name) as total_products_categories,
count(distinct case when c.product_category_name_english is null then p.product_category_name end) as categories_without_translation
from products p
left join category_translation c
on p.product_category_name = c.product_category_name


-- Data Quality and Understanding -------------------------------
SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'canceled'
    ) AS cancelled_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_dates,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date >
              order_estimated_delivery_date
    ) AS late_deliveries

FROM ecommerce.orders;