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
SELECT c.customer_id, c.name, 
       MAX(o.shipment_date - o.order_date) AS max_wait_time
FROM customers_new_3 c
JOIN orders_new_3 o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY max_wait_time DESC
LIMIT 1;

--2
WITH CustomerOrderCounts AS (
  SELECT customer_id, COUNT(*) AS order_count
  FROM orders_new_3
  GROUP BY customer_id
), CustomerAvgWaitTimes AS (
  SELECT customer_id, AVG(shipment_date - order_date) AS avg_wait_time
  FROM orders_new_3
  GROUP BY customer_id
), CustomerOrderTotals AS (
  SELECT customer_id, SUM(order_ammount) AS total_order_amount
  FROM orders_new_3
  GROUP BY customer_id
)
SELECT c.customer_id, c.name, coc.order_count, cawt.avg_wait_time, cot.total_order_amount
FROM customers_new_3 c
JOIN CustomerOrderCounts coc ON c.customer_id = coc.customer_id
JOIN CustomerAvgWaitTimes cawt ON c.customer_id = cawt.customer_id
JOIN CustomerOrderTotals cot ON c.customer_id = cot.customer_id
ORDER BY cot.total_order_amount DESC;

--3
SELECT
  c.customer_id,
  c.name,
  COUNT(*) AS delayed_count,
  COUNT(DISTINCT case when o.order_status = 'Cancel' then o.order_id end) AS cancelled_count,
  sum (order_ammount) as total_ammount
FROM customers_new_3 AS c
left JOIN orders_new_3 AS o
  ON c.customer_id = o.customer_id
WHERE
  o.shipment_date > DATE_ADD(o.order_date, INTERVAL '5' DAY)
GROUP BY
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

SELECT p.product_category, SUM(o.order_ammount) AS total_sales
FROM orders_2 o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_category;

SELECT product_category, SUM(order_ammount) AS total_sales
FROM orders_2 o
JOIN Products p ON o.product_id = p.product_id
GROUP BY product_category
ORDER BY total_sales DESC
LIMIT 1;

--SELECT p.product_category, p.product_name, SUM(o.order_ammount) AS total_sales
--FROM orders_2 o
--JOIN Products p ON o.product_id = p.product_id
--GROUP BY p.product_category, p.product_name
--ORDER BY p.product_category, total_sales DESC;

SELECT p.product_category, p.product_name, SUM(o.order_ammount) AS total_sales
FROM Orders_2 o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_category, p.product_name
HAVING SUM(o.order_ammount) = (
  SELECT MAX(total_sales)
  FROM (
    SELECT p.product_category, p.product_name, SUM(o.order_ammount) AS total_sales
    FROM Orders_2 o
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY p.product_category, p.product_name
  ) AS subquery
  WHERE subquery.product_category = p.product_category
);









