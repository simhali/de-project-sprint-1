with
u as (
		select  u.id as user_id, 
				case 
					when COUNT(order_id) is null then 0
					else COUNT(order_id)
				end as orders_count
		from analysis.orders o 
		RIGHT join analysis.users u on u.id = o.user_id 
		where extract(year from o.order_ts) = 2022 and
		o.status = 4
		group by u.id 
		),
p as (
	select percentile_cont(0.2) WITHIN GROUP (ORDER BY orders_count)
	from u)		
insert into analysis.tmp_rfm_frequency
select user_id,
	case 
		when orders_count <= (select percentile_cont(0.2) WITHIN GROUP (ORDER BY orders_count)
							  from u)	 
		then 1
		when orders_count <= (select percentile_cont(0.4) WITHIN GROUP (ORDER BY orders_count)
							  from u)	 
		then 2			
		when orders_count <= (select percentile_cont(0.6) WITHIN GROUP (ORDER BY orders_count)
							  from u)	 
		then 3	
		when orders_count <= (select percentile_cont(0.8) WITHIN GROUP (ORDER BY orders_count)
							  from u)	 
		then 4	
		else 5	
	end as frequency
from u