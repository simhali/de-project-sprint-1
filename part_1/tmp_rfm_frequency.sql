with
ord_c as (
		select  user_id, 
				COUNT(order_id) as orders_count
		from analysis.orders o 
		where extract(year from order_ts) = 2022 and
		status = 4
		group by user_id
		),
uo as (
		select  u.id as user_id, 
				case 
					when ord_c.orders_count is null then 0
					else ord_c.orders_count
				end
				as orders_count
		from analysis.users u 
		left  join ord_c on u.id = ord_c.user_id 
		)		
insert into analysis.tmp_rfm_frequency (user_id, frequency)
select user_id,
	   ntile (5) over (order by orders_count) as frequency
from uo;