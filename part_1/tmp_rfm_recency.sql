with 
lo as (
	select max(order_ts) as last_order_ts,
		user_id 
	from analysis.orders o 
	where extract(year from o.order_ts) = 2022 and
		o.status = 4
	group by user_id 
	),
jlo as (
	select u.id as user_id ,
		lo.last_order_ts
	from analysis.users u left join lo on u.id=lo.user_id
	),
ud as (
	select user_id,
			extract (day from current_date -  last_order_ts) as days_count
	from jlo
	)
insert into analysis.tmp_rfm_recency (user_id, recency)
select user_id,
	ntile (5) over (order by days_count desc) as recency
from ud
