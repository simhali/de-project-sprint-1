with
ord as (
	select user_id,
		sum(payment) as payment
	from analysis.orders o 
	where extract(year from o.order_ts) = 2022 and
		o.status = 4
	group by user_id 
	),
uo as (
		select  u.id as user_id, 
				case 
					when ord.payment is null then 0
					else ord.payment
				end
				as payment_sum
		from analysis.users u 
		left  join ord on u.id = ord.user_id 
		)	
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
select user_id,
	   ntile (5) over (order by payment_sum) as monetary_value
from uo;