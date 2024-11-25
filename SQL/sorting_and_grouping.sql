
select * from users
select * from products

--part1
WITH AgeGroups AS (
  SELECT
    CASE
      WHEN age BETWEEN 0 AND 20 THEN 'Young'
      WHEN age BETWEEN 21 AND 49 THEN 'Adult'
      WHEN age > 50 THEN 'Old'
      ELSE 'Unknown'
    END AS age_group,
    city
  FROM users
)
SELECT
  city,
  age_group,
  COUNT(*) AS count_customers
FROM AgeGroups
GROUP BY
  city,
  age_group
ORDER BY
  city,
  count_customers DESC;
  
SELECT 
    ROUND(AVG(price)::numeric, 2) AS avg_price,
    category
FROM products
WHERE name LIKE '%Hair%' OR name LIKE '%Home%'
GROUP BY category;

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
		as max_delivery_difference
			from sellers, table_of_date_reg 
			where sellers.seller_id = table_of_date_reg.seller_id and seller_type = 'poor'
--			group by sellers.seller_id
			) as delivery_difference_table
--		where table_of_date_reg.seller_id = delivery_difference_table.seller_id
		where seller_type = 'poor'
)

select * from table_of_max_delivery_difference

select table_of_max_delivery_difference.*,
	
	(case when seller_type = 'poor' then extract(year from (age(now(),  date_reg))) * 12 + extract(month from (age(now(),  date_reg))) end) as month_from_registration

from table_of_max_delivery_difference 

--3
--в данном запросе под регистрацией не подразумевалась самая ранняя дата для продавца
SELECT
  seller_id,
  STRING_AGG(DISTINCT category, ' - ') AS category_pair
FROM sellers
WHERE
  EXTRACT(YEAR FROM date_reg) = 2022
GROUP BY
  seller_id
HAVING
  COUNT(DISTINCT category) = 2
  AND SUM(revenue) > 75000;

















