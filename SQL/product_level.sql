set search_path to ecommerce;

select count(*) as total_products,
count(distinct product_id) as unique_products
from products;

select count(distinct product_id) as product_with_orders
from order_items;



--product id in product_level 
select distinct product_id
from order_items ;

--total orders 

select product_id, count(distinct order_id) as total_orders
from order_items
group by product_id;

-- avg, min and max  orders
select min(total_orders) as min_orders,
max(total_orders) as max_orders,
round(avg(total_orders),2) as avg_orders
from(
select product_id, count(distinct order_id) as total_orders
from order_items
group by product_id
);


--total_units_sold and adding into the table
select product_id,
count(distinct order_id) as total_orders,
count(order_item_id) as total_units_sold 
from order_items 
group by product_id;


--distinct customers 
select oi.product_id, 
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers
from order_items oi
inner join order_level o 
on oi.order_id = o.order_id
group by oi.product_id;


-- adding total revenue and total_frieght revenue
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue
from order_items oi
inner join order_level o 
on oi.order_id = o.order_id
group by oi.product_id;


--adding avg price and avg freight value
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value
from order_items oi
inner join order_level o 
on oi.order_id = o.order_id
group by oi.product_id;



--adding 5 product dimensions
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value
from order_items oi
inner join order_level o 
on oi.order_id = o.order_id
group by oi.product_id;



-----finalizing 
with product_sales as (
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value
from order_items oi
join order_level o 
on oi.order_id = o.order_id
group by oi.product_id
), product_dim as (
select product_id,
coalesce(
	ct.product_category_name_english,
   	CASE
        WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
            THEN 'Portable Kitchen & Food Preparers'
        WHEN p.product_category_name = 'pc_gamer'
            THEN 'Gaming PC'
    END,
    p.product_category_name
) as product_category,
p.product_weight_g,
p.product_length_cm,
p.product_height_cm,
p.product_width_cm
from products p
left join category_translation ct 
on p.product_category_name= ct.product_category_name
)
select ps.product_id,
ps.total_orders,
ps.total_units_sold,
ps.distinct_customers,
ps.total_revenue,
ps.total_freight_revenue,
ps.average_selling_price,
ps.average_freight_value,
pd.product_category,
pd.product_weight_g,
pd.product_length_cm,
pd.product_height_cm,
pd.product_width_cm
from product_sales ps 
join product_dim pd
on ps.product_id = pd.product_id;



--cleaning and validation 
select * from (
with product_sales as (
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value
from order_items oi
join order_level o 
on oi.order_id = o.order_id
group by oi.product_id
), product_dim as (
select product_id,
coalesce(
	ct.product_category_name_english,
   	CASE
        WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
            THEN 'Portable Kitchen & Food Preparers'
        WHEN p.product_category_name = 'pc_gamer'
            THEN 'Gaming PC'
    END,
    p.product_category_name
) as product_category,
p.product_weight_g,
p.product_length_cm,
p.product_height_cm,
p.product_width_cm
from products p
left join category_translation ct 
on p.product_category_name= ct.product_category_name
)
select ps.product_id,
ps.total_orders,
ps.total_units_sold,
ps.distinct_customers,
ps.total_revenue,
ps.total_freight_revenue,
ps.average_selling_price,
ps.average_freight_value,
pd.product_category,
pd.product_weight_g,
pd.product_length_cm,
pd.product_height_cm,
pd.product_width_cm
from product_sales ps 
join product_dim pd
on ps.product_id = pd.product_id
)
where total_revenue >=0 and total_freight_revenue >=0;


-- 2 rows having null product dim 
--- 610 null categories


--creating the final product_level table  
create table product_level as
with product_sales as (
select oi.product_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct o.customer_unique_id) as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value
from order_items oi
join order_level o 
on oi.order_id = o.order_id
group by oi.product_id
), product_dim as (
select product_id,
coalesce(
	ct.product_category_name_english,
   	CASE
        WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
            THEN 'Portable Kitchen & Food Preparers'
        WHEN p.product_category_name = 'pc_gamer'
            THEN 'Gaming PC'
    END,
    p.product_category_name
) as product_category,
p.product_weight_g,
p.product_length_cm,
p.product_height_cm,
p.product_width_cm
from products p
left join category_translation ct 
on p.product_category_name= ct.product_category_name
)
select ps.product_id,
ps.total_orders,
ps.total_units_sold,
ps.distinct_customers,
ps.total_revenue,
ps.total_freight_revenue,
ps.average_selling_price,
ps.average_freight_value,
pd.product_category,
pd.product_weight_g,
pd.product_length_cm,
pd.product_height_cm,
pd.product_width_cm
from product_sales ps 
join product_dim pd
on ps.product_id = pd.product_id;




--checking the table 
select count(*) from product_level;


--adding primary key 
alter table product_level 
add primary key(product_id);



