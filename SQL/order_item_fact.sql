set search_path to ecommerce;


select oi.order_id,oi.order_item_id,oi.product_id,oi.seller_id,ol.customer_unique_id,oi.price,oi.freight_value,oi.shipping_limit_date,
ol.order_status
from order_items oi left join 
order_level ol on 
oi.order_id = ol.order_id;


--validations

with order_item_fact as (
select oi.order_id,oi.order_item_id,oi.product_id,oi.seller_id,ol.customer_unique_id,oi.price,oi.freight_value,oi.shipping_limit_date,
ol.order_status
from order_items oi left join 
order_level ol on 
oi.order_id = ol.order_id
)
select count(distinct order_id)
from order_item_fact;

--creating table 
create table order_item_fact as
select oi.order_id,oi.order_item_id,oi.product_id,oi.seller_id,ol.customer_unique_id,oi.price,oi.freight_value,oi.shipping_limit_date,
ol.order_status
from order_items oi left join 
order_level ol on 
oi.order_id = ol.order_id;


ALTER TABLE order_item_fact
ADD PRIMARY KEY (order_id, order_item_id);