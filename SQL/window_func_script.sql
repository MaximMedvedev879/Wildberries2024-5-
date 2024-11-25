create table Salary(
	id smallint,
	first_name varchar(20),
	last_name varchar(20),
	salary smallint,
	industry varchar(50)
)

select * from Salary

-- создаем временную таблицу с максимальными зарплатами по отделам
with max_salary_per_industry as (
    select 
        industry, 
        max(salary) as max_salary
    from 
        Salary
    group by 
        industry
)
-- получаем список сотрудников с максимальной зарплатой в каждом отделе
select 
    s.first_name, 
    s.last_name, 
    s.salary, 
    s.industry, 
   	s.first_name as name_highest_sal
from
    Salary s
join 
    max_salary_per_industry m
on
    s.industry = m.industry and s.salary = m.max_salary;

-- создаем временную таблицу с минимальными зарплатами по отделам
with min_salary_per_industry as (
    select 
        industry, 
        min(salary) as min_salary
    from 
        Salary
    group by 
        industry
)
-- получаем список сотрудников с минимальной зарплатой в каждом отделе
select 
    s.first_name, 
    s.last_name, 
    s.salary, 
    s.industry, 
    concat() (s.first_name) as name_lowest_sal
from 
    Salary s
join
    min_salary_per_industry m
on 
    s.industry = m.industry and s.salary = m.min_salary;

-- используем оконную функцию для определения максимальной зарплаты в каждом отделе
select
    first_name,
    last_name, 
    salary,
    industry,
    first_value(first_name) over (
    	partition by industry order by 
    	salary desc
    	) AS name_highest_sal
from
    Salary

-- используем оконную функцию для определения минимальной зарплаты в каждом отделе
select 
    first_name, 
    last_name, 
    salary, 
    industry, 
    first_value(first_name) over (
        partition by industry 
        order by salary asc     
    ) as name_lowest_sal
from 
    Salary
    
    
--part2
create table shops (SHOPNUMBER int,
	CITY varchar(10),
	ADDRESS varchar(30)
)

create table goods (ID_GOOD int,
	CATEGORY varchar(20),
	GOOD_NAME varchar(50),
	PRICE int
)

create table sales (DATE varchar(10),
	SHOPNUMBER int,
	ID_GOOD int,
	QTY int
)

--1
with SalesWithShopInfo as (
    select
        s.DATE,
        s.SHOPNUMBER,
        s.ID_GOOD,
        s.QTY,
        g.PRICE,
        sh.CITY,
        sh.ADDRESS
    from sales s
    join goods g on s.ID_GOOD = g.ID_GOOD
    join shops sh on s.SHOPNUMBER = sh.SHOPNUMBER
    where s.DATE = '1/2/2016' -- почему-то во время конвертации поменялись местами месяцы и дни, но это не получилось исправить, поэтому было принято решение для условия задать дату в таком виде
),
SalesSummary as (
  select
    DATE,
    SHOPNUMBER,
    CITY,
    ADDRESS,
    QTY,
    PRICE,
    SUM(QTY) over (partition by SHOPNUMBER) as SUM_QTY, -- суммарное количество проданных товаров для каждого магазина
    SUM(QTY * PRICE) over (partition by SHOPNUMBER) as SUM_QTY_PRICE -- суммарная выручка для каждого магазина
  from SalesWithShopInfo
)
select distinct
    DATE,
    SHOPNUMBER,
    CITY,
    ADDRESS,
    SUM_QTY,
    SUM_QTY_PRICE
from SalesSummary;

--2
-- вычисление ежедневной выручки по категориям товаров
with DailySalesByCategory as (
    select
        s.DATE as DATE_,
        sh.CITY,
        SUM(s.QTY * g.PRICE) as DAILY_SALES
    from sales s
    join goods g on s.ID_GOOD = g.ID_GOOD
    join shops sh on s.SHOPNUMBER = sh.SHOPNUMBER
    where g.CATEGORY = 'ЧИСТОТА'
    group by s.DATE, sh.CITY
),

-- вычисление общей ежедневной выручки и доли выручки каждого города
TotalDailySales as (
    select
        DATE_,
        CITY,
        DAILY_SALES,
        SUM(DAILY_SALES) over (partition by DATE_) as TOTAL_DAILY_SALES -- общая ежедневная выручка по всем городам
    from DailySalesByCategory
)
select
    DATE_,
    CITY,
    DAILY_SALES * 1.0 / TOTAL_DAILY_SALES as SUM_SALES_REL -- доля выручки города от общей ежедневной выручки
from TotalDailySales;

--3
-- ранжирование товаров по продажам в каждом магазине и за каждый день
with RankedSales as (
    select
        s.DATE as DATE_,
        s.SHOPNUMBER,
        s.ID_GOOD,
        SUM(s.QTY) as TOTAL_QTY, -- общее количество проданных товаров
        ROW_NUMBER() over (partition by s.DATE, s.SHOPNUMBER order by SUM(s.QTY) desc) as rn -- ранг товара в рамках дня и магазина
    from sales s
    group by s.DATE, s.SHOPNUMBER, s.ID_GOOD
)
select
    DATE_,
    SHOPNUMBER,
    ID_GOOD
from RankedSales
where rn <= 3 --выбираем топ 3
order by DATE_, SHOPNUMBER, rn;

--4
-- вычисление ежедневной выручки для каждого магазина и категории товаров в Санкт-Петербурге
with DailySales as (
    select
        s.DATE as DATE_,
        s.SHOPNUMBER,
        g.CATEGORY,
        SUM(s.QTY * g.PRICE) as DAILY_SALES -- суммарная выручка за день для данного магазина и категории
    from sales s
    join goods g on s.ID_GOOD = g.ID_GOOD
    join shops sh on s.SHOPNUMBER = sh.SHOPNUMBER
    where sh.CITY = 'СПб'
    group by s.DATE, s.SHOPNUMBER, g.CATEGORY
)
select
    DATE_,
    SHOPNUMBER,
    CATEGORY,
    LAG(DAILY_SALES, 1, 0) over (partition by SHOPNUMBER, CATEGORY order by DATE_) as PREV_SALES -- выручка за предыдущий день
from DailySales
order by SHOPNUMBER, CATEGORY, DATE_;

 --part3
-- Создание таблицы query

create table query (
    searchid smallint,
    year smallint,
    month smallint,
    day smallint,
    userid smallint,
    ts bigint,
    devicetype varchar(20),
    deviceid smallint,
    query varchar(100)
);

-- вставка данных в таблицу query
insert into query (searchid, year, month, day, userid, ts, devicetype, deviceid, query) values
(1, 2024, 10, 26, 1, 1698387200, 'android', 1, 'к'),
(2, 2024, 10, 26, 1, 1698387260, 'android', 1, 'ку'),
(3, 2024, 10, 26, 1, 1698387320, 'android', 1, 'куп'),
(4, 2024, 10, 26, 1, 1698387380, 'android', 1, 'купить'),
(5, 2024, 10, 26, 1, 1698387440, 'android', 1, 'купить кур'),
(6, 2024, 10, 26, 1, 1698387500, 'android', 1, 'купить куртку'),
(7, 2024, 10, 26, 2, 1698387200, 'ios', 2, 'пальто'),
(8, 2024, 10, 26, 2, 1698387800, 'ios', 2, 'зимнее пальто'),
(9, 2024, 10, 26, 3, 1698387200, 'android', 3, 'шуба'),
(10, 2024, 10, 26, 3, 1698387260, 'android', 3, 'шубы'),
(11, 2024, 10, 26, 3, 1698388000, 'android', 3, 'меховые шубы'),
(12, 2024, 10, 26, 4, 1698387200, 'android', 4, 'шапка мужская'),
(13, 2024, 10, 26, 4, 1698387300, 'android', 4, 'шапка зимняя'),
(14, 2024, 10, 26, 4, 1698390600, 'android', 4, 'зимние шапки мужские'),
(15, 2024, 10, 26, 5, 1698387200, 'android', 5, 'сапоги'),
(16, 2024, 10, 26, 5, 1698387800, 'android', 5, 'зимние сапоги'),
(17, 2024, 10, 26, 6, 1698387200, 'android', 6, 'рукавицы'),
(18, 2024, 10, 26, 7, 1698387600, 'ios', 7, 'перчатки'),
(19, 2024, 10, 26, 8, 1698387200, 'android', 8, 'платок'),
(20, 2024, 10, 26, 8, 1698388400, 'android', 8, 'теплый платок');

-- запрос для определения is_final
with RankedQueries as (
    select
        q.*,
        LEAD(ts, 1, null) over (partition by userid, deviceid order by ts) as next_ts,  -- время следующего запроса
        LEAD(query, 1, null) over (partition by userid, deviceid order by ts) as next_query -- текст следующего запроса
    from query q
),
-- определеник, является ли текущий запрос финальным в сессии
CalculatedIsFinal as (
  select
    *,
    case
        when next_ts is null then 1
        when next_ts - ts > 180 then 1 -- = 180 секунд
        when next_query is not null and LENGTH(next_query) < LENGTH(query) and next_ts - ts > 60 then 2 -- 60 секунд
        else 0
    end as is_final
from RankedQueries
)
select 
    year, month, day, userid, ts, devicetype, deviceid, query, next_query, is_final
from CalculatedIsFinal
where day = 26 and devicetype = 'android' and is_final in (1, 2)
order by userid, ts;


