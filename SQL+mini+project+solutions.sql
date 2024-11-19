
# MINI PROJECT 1

-- 1.	Import the csv file to a table in the database.

SELECT * FROM icc.`icc test batting figures (1)`;
select Player from icc.`icc test batting figures (1)`;
use  icc;
#2.	Remove the column 'Player Profile' from the table.
alter table icc.`icc test batting figures (1)` drop column `Player Profile`;



#3.	Extract the country name and player names from the given data and store it in separate columns for further usage
alter table icc.`icc test batting figures (1)` add column country_name varchar(20);

set sql_safe_updates=0;

update icc.`icc test batting figures (1)`
set country_name=substr(Player, position('(' in Player) + 1, length(Player) - position('(' in Player) - 2);

alter table icc.`icc test batting figures (1)` add column player_name varchar(75);

update icc.`icc test batting figures (1)`
set player_name=substr(Player, 1, position('(' in Player) - 1);

select * from icc.`icc test batting figures (1)`;

#4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage
alter table icc.`icc test batting figures (1)` add column start_year int;
update icc.`icc test batting figures (1)`
set start_year=substr(Span, 1, length(Span)-position('-' in Span));

alter table icc.`icc test batting figures (1)` add column end_year int;
update icc.`icc test batting figures (1)`
set end_year=substr(Span,6,4);
     
#5.	The column 'HS' has the highest score scored by the player so far in any given match. 
#The column also has details if the player had completed the match in a NOT OUT status. 
#Extract the data and store the highest runs and the NOT OUT status in different columns.
SELECT
  SUBSTRING_INDEX(HS, '*', 1) AS HighestRuns,
  CASE WHEN HS LIKE '%*' THEN 'Yes' ELSE 'No' END AS NotOut
FROM icc.`icc test batting figures (1)`;

# 6.	Using the data given, considering the players who were active in the year of 2019, create a
# set of batting order of best 6 players using the selection criteria of those
# who have a good average score across all matches for India.

alter table icc.`icc test batting figures (1)` rename column Avg to average;
select Player,avg(average) as Avgscore from icc.`icc test batting figures (1)`
where Span like '%2019%'and country_name in ('INDIA') group by Player order by Avgscore desc limit 6;



#7.	Using the data given, considering the players who were active in the year of 2019, create a set of
# batting order of best 6 players using the selection criteria of 
#those who have the highest number of 100s across all matches for India.

alter table icc.`icc test batting figures (1)` rename column Avg to average;
select Player,count(*) as centuries  from icc.`icc test batting figures (1)`
where Span like '%2019%'and country_name in ('INDIA') and 100>0 group by Player order by centuries desc limit 6;

-- 8.	Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using 2 selection criteria of your own for India.

select player, HS from icc.`icc test batting figures (1)`
where Span like '%2019%'and country_name in ('INDIA')
group by player,HS
having HS > 150
order by HS desc
limit 6;

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, 
-- considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of 
-- those who have a good average score across all matches for South Africa.
create or replace view Batting_Order_GoodAvgScorers_SA as
select player, average from icc.`icc test batting figures (1)`
where Span like '%2019%'and (country_name = 'SA' or country_name = 'ICC/SA')
group by player, average
order by average desc
limit 6;
select * from Batting_Order_GoodAvgScorers_SA;

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, 
-- considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of 
-- those who have highest number of 100s across all matches for South Africa.
create or replace view Batting_Order_HighestCenturyScorers_SA as
select player, '100' from icc.`icc test batting figures (1)`
where Span like '%2019%' and (country_name = 'SA' or country_name = 'ICC/SA')
order by '100' desc
limit 6; 
select * from Batting_Order_HighestCenturyScorers_SA;

-- 11.	Using the data given, Give the number of player_played for each country.
select * from icc.`icc test batting figures (1)`;

select country_name, count(player) as total_players from icc.`icc test batting figures (1)`
group by country_name
order by total_players desc;

-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent

-- Fetching the number of players who played for ASIAN countries
select country_name, count(player) as total_asian_players from icc.`icc test batting figures (1)`
where country_name IN ('INDIA','ICC/INDIA','PAK','INDIA/PAK','ICC/PAK','SL','ICC/SL','PAK','BDESH') 
group by country_name
order by total_asian_players desc;

-- Fetching the number of players who played for NON-ASIAN countries
select country_name, count(player) as total_nonasian_players from icc.`icc test batting figures (1)`
where country_name  IN ('AUS','ICC/SA','SA','AUS/SA','ICC/WI','NZ','ICC/NZ','ZIM','WI','ENG', 'AUS/ENG') 
group by country_name
order by total_nonasian_players desc;


# MINI PROJECT  2
use Supply_chain;

#1.	Company sells the product at different discounted rates. Refer actual product price in product table and
# selling price in the order item table. Write a query to find out total amount saved in each order then display the orders from highest
# to lowest amount saved. 
SELECT 
    ProductName,
    SUM(actual_price) actual_rate,
    SUM(discounted_price) with_discount,
    SUM(Quantity) total_quantity,
    SUM(discount) total_discount,
    SUM(total_discount) net_discount
FROM
    (SELECT 
        ProductName,
            SupplierId,
            T1.UnitPrice actual_price,
            T2.UnitPrice discounted_price,
            Quantity,
            T1.UnitPrice - T2.UnitPrice discount,
            T1.UnitPrice * Quantity - T2.UnitPrice * Quantity total_discount
    FROM
        product T1
    JOIN orderitem T2 ON T1.Id = T2.ProductId) T
GROUP BY ProductName
ORDER BY SUM(total_discount) DESC;

#2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
#a. List few products that he should choose based on demand.


select p.ProductName,oi.productID, COUNT(oi.orderId) as total_orders
from  orderitem oi
join product p on oi.ProductId = p.Id
group by oi.ProductId
order by total_orders desc
limit 5;

# b. Who will be the competitors for him for the products suggested in above questions.
SELECT CompanyName from Supplier S 
JOIN Product T2 ON T2.SupplierId = S.Id 
WHERE ProductName IN
(
SELECT ProductName FROM
(SELECT ProductId, ProductName, SupplierId,
            SUM(T2.UnitPrice) actual_price,
            SUM(T1.UnitPrice) discount,
            SUM(Quantity) total_quantity,
            Package
    FROM orderitem T1
    JOIN product T2 ON T2.Id = T1.ProductId
    GROUP BY ProductId
    ORDER BY SUM(Quantity) DESC
    LIMIT 5) R);
    
#3.	Create a combined list to display customers and suppliers details considering the following criteria 
#1 Both customer and supplier belong to the same country
#2	Customer who does not have supplier in their country
#3●	Supplier who does not have customer in their country

CREATE TABLE IF NOT EXISTS DATA11
SELECT * FROM 
(SELECT CustomerId, concat(FirstName,' ',LastName) AS cust_name, 
T1.City cust_city, T1.Country cust_country,
T5.CompanyName, T5.ContactName supplier_name, T5.City supp_city, T5.Country supp_country 
FROM customer T1 JOIN orders T2 ON T2.CustomerId=T1.Id
JOIN orderitem T3 ON T3.OrderId=T2.Id
JOIN product T4 ON T4.Id=T3.ProductId
JOIN supplier T5 ON T5.Id=T4.SupplierId
) R11;

SELECT * FROM DATA11;

-- ● Both customer and supplier belong to the same country
select cust_name, supplier_name, supp_City, supp_country
from DATA11 where cust_name<>supplier_name and cust_country=supp_country; 

-- ● Customer who does not have supplier in their country
select cust_name, cust_country, supplier_name, supp_Country
from DATA11 where supp_Country<>cust_country;

SELECT * FROM customer
WHERE Country NOT IN 
(SELECT Country FROM supplier);


-- ● Supplier who does not have customer in their country 
select cust_name, cust_country, supplier_name, supp_Country
from DATA11 where supplier_name<>cust_name;

SELECT * FROM supplier 
WHERE Country NOT IN
(SELECT Country FROM customer);



#4.	Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products and write a
# query on this view to find out top 2 suppliers (using windows function)
# in each country by total sales done by the products.

create view v1 as 
select ProductId, ProductName, CompanyName, totalsales 
from (select ProductId, count(ProductId) over (partition by ProductId) as totalsales
from orderitem)t
inner join Product p ON p.Id=t.ProductId 
inner join Supplier s ON s.Id=p.SupplierId
group by ProductId
order by ProductId;

select * from v1;

create or replace view v1 as 
select ProductId, ProductName, CompanyName, Country, totalsales,
DENSE_RANK() OVER(PARTITION BY Country ORDER BY totalsales) as rn
from (select ProductId, count(ProductId) over(partition by ProductId) totalsales from orderitem)t 
inner join Product p ON p.Id=t.ProductId 
inner join Supplier s ON s.Id=p.SupplierId
group by ProductId
order by rn;

select * from v1;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT *, 
DENSE_RANK() OVER(PARTITION BY Country ORDER BY COUNRY_TOT_AMNT DESC) 'RANK'
FROM(SELECT ContactName, ProductName, SUM(total_amount) COUNRY_TOT_AMNT, Country
FROM (SELECT CompanyName, ContactName,  ProductName, SUM(T2.UnitPrice) actual, 
SUM(T3.UnitPrice) discount, SUM(TotalAmount) total_amount, Country
 FROM supplier T1 JOIN product T2 ON T1.Id = T2.SupplierId 
 JOIN orderitem T3 ON T3.ProductId = T2.Id 
 JOIN orders T4 ON T4.Id = T3.OrderId
 GROUP BY ContactName ORDER BY SUM(TotalAmount) DESC) R1
 GROUP BY Country) R2 LIMIT 2;
 
# 5.	Find out for which products, UK is dependent on other countries for the supply. 
-- List the countries which are supplying these products in the same list.

select * from supplier s JOIN product p ON s.Id=p.SupplierId;

select ProductName, Country from
(select ProductName, Country from supplier s join product p ON p.SupplierId=s.Id) R1
where ProductName NOT IN 
(select ProductName from supplier s JOIN product p ON p.SupplierId=s.Id 
where Country LIKE 'UK');