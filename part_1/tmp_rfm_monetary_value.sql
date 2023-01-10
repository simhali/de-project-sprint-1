with
u as (
		select  u.id as user_id, 
				case 
					when sum(o.payment) is null then 0
					else sum(o.payment)
				end
				as payment_sum
		from analysis.orders o 
		RIGHT join analysis.users u on u.id = o.user_id 
		where extract(year from o.order_ts) = 2022 and
		o.status = 4
		group by u.id 
		),
p as (
	select percentile_cont(0.2) WITHIN GROUP (ORDER BY payment_sum)
	from u)		
insert into analysis.tmp_rfm_monetary_value
select user_id,
	case 
		when payment_sum <= (select percentile_cont(0.2) WITHIN GROUP (ORDER BY payment_sum)
							  from u)	 
		then 1
		when payment_sum <= (select percentile_cont(0.4) WITHIN GROUP (ORDER BY payment_sum)
							  from u)	 
		then 2			
		when payment_sum <= (select percentile_cont(0.6) WITHIN GROUP (ORDER BY payment_sum)
							  from u)	 
		then 3	
		when payment_sum <= (select percentile_cont(0.8) WITHIN GROUP (ORDER BY payment_sum)
							  from u)	 
		then 4	
		else 5	
	end as monetary_value
from u