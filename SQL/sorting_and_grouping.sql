
select * from users
select * from products

--part1
with AgeGroups as (
  select
    case
      when age between 0 and 20 then 'Young'
      when age between 21 and 49 then 'Adult'
      when age > 50 then 'Old'
      ELSE 'Unknown'
    end as age_group,
    city
  from users
)
select
  city,
  age_group,
  count(*) as count_customers
from AgeGroups
group by
  city,
  age_group
order by
  city,
  count_customers DESC;
  
select 
    round(avg(price)::numeric, 2) as avg_price,
    category
from products
where name like '%Hair%' or name like '%Home%'
group by category;

--part 2
create table sellers(
	seller_id smallint,
	category varchar(20),
	date_reg date,
	date date,
	revenue int,
	rating smallint,
	delivery_days smallint
)

--1
select * from sellers

create view table_of_total_categ_and_revenue as(
		select seller_id, 
		count(distinct case when category != 'Bedding' then category end) as total_categ,
		avg(case when category != 'Bedding' then rating end) as avg_rating,
		sum(case when category != 'Bedding' then revenue end) as total_revenue
		from 
			sellers
		group by seller_id 
		order by seller_id
	)
	
select * from table_of_total_categ_and_revenue
	
create view table_of_seller_type as(
	select seller_id,
		total_categ,
		avg_rating,
		total_revenue,
		(case 
			when total_revenue > 50000 and total_categ > 1 then 'rich' 
			when total_revenue < 50000 and total_categ > 1 then 'poor' 
			else 'noname_seller' end) as seller_type
	from 
		table_of_total_categ_and_revenue
)

select * from table_of_seller_type

--в данном запросе под датой регистрации продавца подразумевалась самая ранняя дата
create view table_of_date_reg as(
		select table_of_seller_type.*, date_reg_table.date_reg
			
		from 
			table_of_seller_type, (select seller_id, min(case when category != 'Bedding' then date_reg end) as date_reg
				 from sellers
				group by seller_id) as date_reg_table
			where table_of_seller_type.seller_id  = date_reg_table.seller_id
)

select * from table_of_date_reg

--2

create view table_of_max_delivery_difference as(
	select table_of_date_reg.*, delivery_difference_table.max_delivery_difference
	from 
		table_of_date_reg, (select 
		max(case when category != 'Bedding' and seller_type = 'poor' then delivery_days end) - min(case when category != 'Bedding' and seller_type = 'poor'  then delivery_days end)
		as max_delivery_difference --считаем максимальную разницу в доставке
			from sellers, table_of_date_reg 
			where sellers.seller_id = table_of_date_reg.seller_id and seller_type = 'poor'
			) as delivery_difference_table
		where seller_type = 'poor'
)

select * from table_of_max_delivery_difference

select table_of_max_delivery_difference.*,
	
	-- считаем количество месяцев, прошедших с момента самой ранней даты регистрации
	(case when seller_type = 'poor' then extract(year from (age(now(),  date_reg))) * 12 + extract(month from (age(now(),  date_reg))) end) as month_from_registration

from table_of_max_delivery_difference 

--3
--в данном запросе под регистрацией не подразумевалась самая ранняя дата для продавца
select
  seller_id,
  string_agg(distinct category, ' - ') as category_pair
from sellers
where
  extract(year from date_reg) = 2022
group by
  seller_id
having
  count(distinct category) = 2
  and sum(revenue) > 75000;

















