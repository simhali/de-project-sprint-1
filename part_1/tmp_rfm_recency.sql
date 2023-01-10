with 
lo as (
	select max(order_ts) as last_order_ts,
		user_id 
	from orders o 
	where extract(year from o.order_ts) = 2022 and
		o.status = 4
	group by user_id 
	),
jlo as (
	select u.id as user_id ,
		lo.last_order_ts
	from users u left join lo on u.id=lo.user_id
	),
ud as (
	select user_id,
			extract (day from current_date -  last_order_ts) as days_count
	from jlo
	)
insert into analysis.tmp_rfm_recency 
select user_id,
	case 
		when days_count <= (select percentile_cont(0.2) WITHIN GROUP (ORDER BY days_count)
							  from ud)	 
		then 1
		when days_count <= (select percentile_cont(0.4) WITHIN GROUP (ORDER BY days_count)
							  from ud)	 
		then 2			
		when days_count <= (select percentile_cont(0.6) WITHIN GROUP (ORDER BY days_count)
							  from ud)	 
		then 3	
		when days_count <= (select percentile_cont(0.8) WITHIN GROUP (ORDER BY days_count)
							  from ud)	 
		then 4	
		else 5	
	end as recency
from ud