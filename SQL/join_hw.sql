--part1
create table customers_new_3(
	customer_id smallint,
	name varchar(50)
)

select * from customers_new_3

create table orders_new_3(
	order_id smallint,
	customer_id smallint,
	order_date timestamp,
	shipment_date timestamp,
	order_ammount smallint,
	order_status varchar(15)
)

select * from orders_new_3 

--1
select c.customer_id, c.name, 
       max(o.shipment_date - o.order_date) as max_wait_time -- вычисляем максимальное время ожидания как разницу между датой отгрузки и датой заказа
from customers_new_3 c
join orders_new_3 o on c.customer_id = o.customer_id
group by c.customer_id, c.name
order by max_wait_time desc
limit 1;

--2
-- с помощью CTE
-- считаем количество заказов для каждого клиента
with CustomerOrderCounts as (
  select customer_id, count(*) AS order_count
  from orders_new_3
  group by customer_id
),
-- считаем среднее время ожидания доставки для каждого клиента
CustomerAvgWaitTimes as (
  select customer_id, avg(shipment_date - order_date) as avg_wait_time
  from orders_new_3
  group by customer_id
), 
-- считаем общую сумму заказов для каждого клиента
CustomerOrderTotals as (
  select customer_id, sum(order_ammount) as total_order_ammount
  from orders_new_3
  group by customer_id
)
select c.customer_id, c.name, coc.order_count, cawt.avg_wait_time, cot.total_order_ammount
from customers_new_3 c
join CustomerOrderCounts coc on c.customer_id = coc.customer_id
join CustomerAvgWaitTimes cawt on c.customer_id = cawt.customer_id
JOIN CustomerOrderTotals cot on c.customer_id = cot.customer_id
order by cot.total_order_ammount desc;

--3
select
  c.customer_id,
  c.name,
  count(*) as delayed_count, -- количество заказов с задержкой
  count(distinct case when o.order_status = 'Cancel' then o.order_id end) as cancelled_count, -- отменённые заказы
  sum (order_ammount) as total_ammount
from customers_new_3 as c
left join orders_new_3 as o
  on c.customer_id = o.customer_id
where
  o.shipment_date > DATE_ADD(o.order_date, INTERVAL '5' day) -- shipment date > order_date + 5
group by
  c.customer_id,
  c.name
 order by total_ammount desc
 
 
 --part2
 create table products(
 	product_id smallint,
 	product_name varchar(20),
 	product_category varchar(40)
 )
 
 select * from products
 
 create table orders_2(
 	order_date timestamp,
 	order_id smallint,
 	product_id smallint,
 	order_ammount int
 )
 
 select * from orders_2

 -- считаем общую сумму продаж для каждой категории продуктов
select p.product_category, sum(o.order_ammount) as total_sales
from orders_2 o
join products p on o.product_id = p.product_id
group by p.product_category;

-- ищем категорию продуктов с наибольшей суммой продаж
select product_category, sum(order_ammount) as total_sales
from orders_2 o
join products p on o.product_id = p.product_id
group by product_category
order by total_sales desc
limit 1; -- самая продаваемая категория

-- оставлено для проверки последнего запроса
--select p.product_category, p.product_name, sum(o.order_ammount) as total_sales
--from orders_2 o
--join Products p on o.product_id = p.product_id
--group by p.product_category, p.product_name
--order by p.product_category, total_sales desc;

-- находим продукт с наибольшей суммой продаж в одной категории
select p.product_category, p.product_name, sum(o.order_ammount) as total_sales
from orders_2 o
join products p on o.product_id = p.product_id
group by p.product_category, p.product_name
-- берем только те продукты, у которых сумма продаж равна максимальной сумме продаж в своей категории:
having sum(o.order_ammount) = (
  select max(total_sales)
  from (
  	-- вычисляем сумму продаж для каждого продукта
    select p.product_category, p.product_name, sum(o.order_ammount) as total_sales
    from orders_2 o
    join products p on o.product_id = p.product_id
    group by p.product_category, p.product_name
  ) as subquery
  where subquery.product_category = p.product_category
);









