drop  view analysis.orders;

create view analysis.orders as
select o2.order_id ,
	order_ts,
	user_id,
	bonus_payment,
	payment,
	cost,
	bonus_grant,
	st.status_id as status
from production.orders o2
join (
		select order_id,
		status_id,
		row_number () over (partition by order_id order by dttm desc) as num
	   from production.orderstatuslog o
	) st on st.order_id = o2.order_id 
where st.num = 1;