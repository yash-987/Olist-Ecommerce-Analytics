select distinct seller_id from sellers;
select distinct seller_id from order_items;

--does every seller existt in order_items table?
SELECT COUNT(*) AS sellers_without_orders
FROM sellers s
LEFT JOIN order_items oi
    ON s.seller_id = oi.seller_id
WHERE oi.seller_id IS NULL;



-- seller_id, total_orders and units sold
select seller_id,
count(distinct order_id) as total_orders,
count(order_item_id) as total_units_sold
from order_items
group by seller_id;

--distinct_customers total revenue and total freight value
select oi.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct ol.customer_unique_id)  as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue
from order_items oi
join order_level  ol
on oi.order_id = ol.order_id
group by seller_id;


--avg selling price,avg freight value, avg revenue per order
select oi.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct ol.customer_unique_id)  as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value,
round(sum(oi.price)/count(distinct oi.order_id),2) as average_revenue_per_order
from order_items oi
join order_level  ol
on oi.order_id = ol.order_id
group by seller_id;


--seller dimensions
with seller_metrics as(
select oi.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct ol.customer_unique_id)  as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value,
round(sum(oi.price)/count(distinct oi.order_id),2) as average_revenue_per_order
from order_items oi
join order_level  ol
on oi.order_id = ol.order_id
group by seller_id
), seller_dim as(
select seller_id,
seller_city,
seller_state
from sellers
)
select 
sm.seller_id,
sd.seller_city,
sd.seller_state,
sm.total_orders,
sm.total_units_sold,
sm.distinct_customers,
sm.total_revenue,
sm.total_freight_revenue,
sm.average_selling_price,
sm.average_freight_value,
sm.average_revenue_per_order
from 
	seller_metrics sm
	join 
	seller_dim sd
				on sm.seller_id = sd.seller_id;


--cleaning
select *
from(
with seller_metrics as(
select oi.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct ol.customer_unique_id)  as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value,
round(sum(oi.price)/count(distinct oi.order_id),2) as average_revenue_per_order
from order_items oi
join order_level  ol
on oi.order_id = ol.order_id
group by seller_id
), seller_dim as(
select seller_id,
seller_city,
seller_state
from sellers
)
select 
sm.seller_id,
sd.seller_city,
sd.seller_state,
sm.total_orders,
sm.total_units_sold,
sm.distinct_customers,
sm.total_revenue,
sm.total_freight_revenue,
sm.average_selling_price,
sm.average_freight_value,
sm.average_revenue_per_order
from 
	seller_metrics sm
	join 
	seller_dim sd
				on sm.seller_id = sd.seller_id
)
where average_freight_value = Round((total_freight_revenue / total_units_sold),2);



-- creating the table 
create table seller_level as 
with seller_metrics as(
select oi.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.order_item_id) as total_units_sold,
count(distinct ol.customer_unique_id)  as distinct_customers,
sum(oi.price) as total_revenue,
sum(oi.freight_value) as total_freight_revenue,
round(avg(oi.price),2) as average_selling_price,
round(avg(oi.freight_value),2) as average_freight_value,
round(sum(oi.price)/count(distinct oi.order_id),2) as average_revenue_per_order
from order_items oi
join order_level  ol
on oi.order_id = ol.order_id
group by seller_id
), seller_dim as(
select seller_id,
seller_city,
seller_state
from sellers
)
select 
sm.seller_id,
sd.seller_city,
sd.seller_state,
sm.total_orders,
sm.total_units_sold,
sm.distinct_customers,
sm.total_revenue,
sm.total_freight_revenue,
sm.average_selling_price,
sm.average_freight_value,
sm.average_revenue_per_order
from 
	seller_metrics sm
	join 
	seller_dim sd
				on sm.seller_id = sd.seller_id;


-- adding pkey 
alter table seller_level 
add primary key(seller_id);