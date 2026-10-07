set search_path to ecommerce;


select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend
from order_level
group by customer_unique_id;


-- another approach : using case 
select customer_unique_id,
count(order_id) as total_orders,
count(
		case when order_status = 'delivered' then order_id
		end
) as completed_orders,
sum(total_order_value) as total_spend,
sum(
	case when order_status = 'delivered' then total_order_value end
) as completed_spend
from order_level
group by customer_unique_id;




-- Calculating Average order value : aov

with c as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend
from order_level
group by customer_unique_id
) 
select
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
Round(completed_spend/nullif(completed_orders,0),2) as completed_aov
from c;




--finding number of rows where completed orders is 0 
with c as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend
from order_level
group by customer_unique_id
) 
select
count(*)
from c
where completed_orders = 0;

-- finding max avg_order_value 
with c as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend
from order_level
group by customer_unique_id
) 
select
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
Round(completed_spend/nullif(completed_orders,0),2) as completed_aov
from c
order by completed_aov desc nulls last limit 1;


-- to do the same using  max() , we'll have to adjust this in another cte


-- first order and last order 
with c as (
select 
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
completed_aov,
first_order_date,
last_order_date,
(last_order_date - first_order_date) as customer_lifespan_days
from (
with customer_level as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend,
min(order_date) as first_order_date,
max(order_date) as last_order_date
from order_level
group by customer_unique_id
)
select customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
ROUND(completed_spend/Nullif(completed_orders,0),2) as completed_aov,
first_order_date,
last_order_date
from customer_level
)
)
select 
count(*) filter( where total_orders =1 ) as one_time_customer,
count(*) filter( where total_orders>1) as repeat_customer,
count(*) filter(where total_orders>1 and customer_lifespan_days=0 ) as same_day_repeat_customer
from 
c;


--- understand whether those 848 same-day repeat customers are actually meaningful repeat purchases or simply customers who generated multiple orders during the same shopping session/process.
with c as (
select 
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
completed_aov,
first_order_date,
last_order_date,
(last_order_date - first_order_date) as customer_lifespan_days
from (
with customer_level as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend,
min(order_date) as first_order_date,
max(order_date) as last_order_date
from order_level
group by customer_unique_id
)
select customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
ROUND(completed_spend/Nullif(completed_orders,0),2) as completed_aov,
first_order_date,
last_order_date
from customer_level
)
)
select 
min(total_orders) as min_orders,
max(total_orders) as max_orders,
round(avg(total_orders),2) as avg_orders
from 
c
where total_orders>1 
and customer_lifespan_days = 0;



---customer order frequency/category
with c as (
select 
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
completed_aov,
first_order_date,
last_order_date,
(last_order_date - first_order_date) as customer_lifespan_days
from (
with customer_level as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend,
min(order_date) as first_order_date,
max(order_date) as last_order_date
from order_level
group by customer_unique_id
)
select customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
ROUND(completed_spend/Nullif(completed_orders,0),2) as completed_aov,
first_order_date,
last_order_date
from customer_level
)
)
select 
 	case 
	 	when total_orders = 1 then 'One-time'
		else 'Repeat'
	end as customer_type,
	count(*) as customers,
	Round(avg(completed_spend),2) as avg_completed_spend,
	Round(avg(completed_aov),2) as avg_completed_aov
from
c
group by 1 
order by 1;

--finding how many users have completed orders
select 
customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
completed_aov,
first_order_date,
last_order_date,
(last_order_date - first_order_date) as customer_lifespan_days
from (
with customer_level as (
select customer_unique_id,
count(order_id) as total_orders,
count(order_id) filter(where order_status = 'delivered') as completed_orders,
sum(total_order_value) as total_spend,
sum(total_order_value) filter(where order_status = 'delivered') as completed_spend,
min(order_date) as first_order_date,
max(order_date) as last_order_date
from order_level
group by customer_unique_id
)
select customer_unique_id,
total_orders,
completed_orders,
total_spend,
completed_spend,
ROUND(completed_spend/Nullif(completed_orders,0),2) as completed_aov,
first_order_date,
last_order_date
from customer_level





