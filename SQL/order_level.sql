set search_path to ecommerce;

select o.order_id,o.customer_id,
o.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date,
oi.item_count,
oi.item_value,
oi.freight,
oi.products_count,
oi.sellers_count
from (
select o.order_id,o.customer_id,
c.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date
from orders o
join customers c
on o.customer_id = c.customer_id
)as o 
left join(
select
order_id ,count(distinct order_item_id) as item_count,
sum(price) as item_value,
sum(freight_value) as freight,
count(distinct product_id) as products_count,
count(distinct seller_id) as sellers_count
from order_items
group by order_id
) as oi
on o.order_id = oi.order_id;



--aggregated payments
select order_id, 
sum(payment_value) as total_payment_value,
count(payment_sequential) payment_count
from payments group  by order_id;


--joining with order-level

select oc.order_id, 
oc.customer_id, 
oc.customer_unique_id,
oc.order_status,
oc.order_purchase_timestamp,
oc.order_estimated_delivery_date,
oc.order_delivered_customer_date,
oc.item_count,
oc.item_value,
oc.freight,
oc.products_count,
oc.sellers_count,
p.total_payment_value,
p.payment_count
from (
select o.order_id,o.customer_id,
o.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date,
oi.item_count,
oi.item_value,
oi.freight,
oi.products_count,
oi.sellers_count
from (
select o.order_id,o.customer_id,
c.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date
from orders o
join customers c
on o.customer_id = c.customer_id
)as o 
left join(
select
order_id ,count(distinct order_item_id) as item_count,
sum(price) as item_value,
sum(freight_value) as freight,
count(distinct product_id) as products_count,
count(distinct seller_id) as sellers_count
from order_items
group by order_id
) as oi
on o.order_id = oi.order_id
) AS oc
left join (
select order_id, 
sum(payment_value) as total_payment_value,
count(payment_sequential) payment_count
from payments group  by order_id
) AS p
on oc.order_id = p.order_id;


--reviews 
select order_id, ROUND(avg(review_score),2) from reviews
group by order_id;



--joining
select 
oc.order_id, 
oc.customer_id, 
oc.customer_unique_id,
oc.order_status,
oc.order_purchase_timestamp,
oc.order_estimated_delivery_date,
oc.order_delivered_customer_date,
oc.item_count,
oc.total_item_value,
oc.total_freight_value,
oc.distinct_products_count,
oc.distinct_sellers_count,
oc.total_payment_value,
oc.payment_count,
r.review_score,
r.review_count
from (
select oc.order_id, 
oc.customer_id, 
oc.customer_unique_id,
oc.order_status,
oc.order_purchase_timestamp,
oc.order_estimated_delivery_date,
oc.order_delivered_customer_date,
oc.item_count,
oc.total_item_value,
oc.total_freight_value,
oc.distinct_products_count,
oc.distinct_sellers_count,
p.total_payment_value,
p.payment_count
from (
select o.order_id,o.customer_id,
o.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date,
oi.item_count,
oi.total_item_value,
oi.total_freight_value,
oi.distinct_products_count,
oi.distinct_sellers_count
from (
select o.order_id,o.customer_id,
c.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date
from orders o
join customers c
on o.customer_id = c.customer_id
)as o 
left join(
select
order_id ,count(distinct order_item_id) as item_count,
sum(price) as total_item_value,
sum(freight_value) as total_freight_value,
count(distinct product_id) as distinct_products_count,
count(distinct seller_id) as distinct_sellers_count
from order_items
group by order_id
) as oi
on o.order_id = oi.order_id
) AS oc
left join (
select order_id, 
sum(payment_value) as total_payment_value,
count(payment_sequential) payment_count
from payments group  by order_id
) AS p
on oc.order_id = p.order_id
) as oc
left join (
select order_id, 
ROUND(avg(review_score),2) as review_score,
count(review_id) as review_count
from reviews
group by order_id
) as r
on oc.order_id = r.order_id;


--creating the same table using cte 
create table order_level as with oc as (
select o.order_id,o.customer_id,
c.customer_unique_id,
o.order_status,
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
o.order_delivered_customer_date
from orders o
left join customers c
on o.customer_id = c.customer_id
), 

oi AS (
select
order_id ,count(distinct order_item_id) as item_count,
sum(price) as total_item_value,
sum(freight_value) as total_freight_value,
count(distinct product_id) as distinct_products_count,
count(distinct seller_id) as distinct_sellers_count
from order_items
group by order_id
),

p as (
select order_id, 
sum(payment_value) as total_payment_value,
count(payment_sequential) payment_count
from payments 
group by order_id
),

r as (
select order_id, 
ROUND(avg(review_score),2) as review_score,
count(review_id) as review_count
from reviews
group by order_id
)

select
oc.order_id,
oc.customer_id, 
oc.customer_unique_id,
oc.order_status,
oc.order_purchase_timestamp,
oc.order_purchase_timestamp::date as order_date,
Extract( year from oc.order_purchase_timestamp) as order_year,
Extract (month from oc.order_purchase_timestamp) as order_month,
TO_CHAR(oc.order_purchase_timestamp,'YYYY-MM') as order_year_month,
TO_CHAR(oc.order_purchase_timestamp,'day') as order_day_of_week,
oc.order_estimated_delivery_date,
oc.order_delivered_customer_date,
(oc.order_delivered_customer_date::date - oc.order_purchase_timestamp::date )as delivery_days,
(oc.order_delivered_customer_date::date - oc.order_estimated_delivery_date::date) as delivery_delay_days,
case 
	when (oc.order_delivered_customer_date::date - oc.order_estimated_delivery_date::date) > 0 then 'Late'
	when (oc.order_delivered_customer_date::date - oc.order_estimated_delivery_date::date) < 0 then 'Early'
	when (oc.order_delivered_customer_date::date - oc.order_estimated_delivery_date::date) = 0 then 'On Time'
	when (oc.order_status = 'delivered' and oc.order_delivered_customer_date is null ) then 'Delivery Data Missing'
Else 'Not Delivered'
End as Delivery_status,
oi.item_count,
oi.total_item_value,
oi.total_freight_value,
(oi.total_item_value+oi.total_freight_value) as total_order_value,
oi.distinct_products_count,
oi.distinct_sellers_count,
p.total_payment_value,
p.payment_count,
r.review_score,
r.review_count

from

oc left join oi
	on oc.order_id = oi.order_id

left join p 
	on oc.order_id = p.order_id
	
left join r
	on oc.order_id = r.order_id

-- 8 orders with delivered status but no delivery dates
-- 6 orders with canceled status but delivery dates
--0 orders with delivery status late and delivery date

------------------------------------------
-- set search_path to ecommerce;
-- with A as (select order_id,
-- order_status,
-- (order_delivered_customer_date::date - order_purchase_timestamp::date )as delivery_days,
-- (order_delivered_customer_date::date - order_estimated_delivery_date::date) as delivery_delay_days,
-- case 
-- 	when (order_delivered_customer_date::date - order_estimated_delivery_date::date) > 0 then 'Delay'
-- 	when (order_delivered_customer_date::date - order_estimated_delivery_date::date) < 0 then 'Early'
-- 	when (order_delivered_customer_date::date - order_estimated_delivery_date::date) = 0 then 'On Time'
-- Else 'Not Delivered'
-- End as Delivery_status
-- from orders
-- )
-- select * from A where delivery_days>100;
	
set search_path to ecommerce;

alter table order_level 
add primary key(order_id);

--
