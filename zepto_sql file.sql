drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountpercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedsellingprice NUMERIC(8,2),
weightINGms INTEGER,
outofStock BOOLEAN,
quantity INTEGER
);

---data exploration

--count of rows
select count(*) from zepto;

--sample data
select * from zepto
limit 10;

--null values
select * from zepto
where name is null
OR
category is null
OR
mrp is null
OR
discountpercent is null
OR
discountedSellingPrice is null
OR
weightInGms is null
OR
availablequantity is null
OR
outofStock is null
OR
quantity is null;

--different product categories
select distinct category
from zepto
order by category;

--product in stock vs out of stock
select outofStock, count(sku_id)
from zepto
group by outofStock;

--product names present multiple times
select name,count(sku_id)as "number of SKUs"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc;

--data cleaning

--product with price=0
select * from zepto 
where mrp=0 or discountedsellingprice=0;

delete from zepto
where mrp=0;

--convert paise to rupees
update zepto
set mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;

select mrp,discountedSellingPrice from zepto

--Q1. find the top 10 best value product based on discount percentage.
select distinct name,mrp,discountPercent
from zepto
order by discountPercent DESC
limit 10;

--Q2. what are the product with high mrp but out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outofstock=true AND mrp>300
ORDER BY mrp DESC;


--Q3. calculate the estimated revenue for each category
 SELECT category,
 SUM(discountedSellingPrice * AvailableQuantity) AS total_revenue
 FROM zepto
 GROUP By category
 ORDER BY total_revenue;
 
--Q4. find all product where mrp is greater than 1500rs and discount is less than 10%
SELECT DISTINCT name,mrp,discountPercent
from zepto
where mrp>500 AND discountPercent <10
order by mrp desc,discountPercent DESC;

--Q5. Identify the top 5 categories offering the highest average discount percentage.
select category,
AVG(discountpercent) AS avg_discount
from zepto
group by category
order by avg_discount DESC
limit 5;

--Q6. find the price per gram for products above 100g and sort by best value.
select distinct name,weightInGms,discountedSellingPrice,
Round(discountedSellingPrice/weightInGms,2) AS price_per_gram
from zepto
where weightInGms >=100
order by price_per_gram;

--Q7.group the products into categories like low, medium,bulk.
select distinct name,weightInGms,
case when weightInGms<1000 then 'low'
when weightInGms<5000 then 'Medium'
Else 'bulk'
end as weight_category
from zepto;

--Q8.what is the total inventory weight per category
select category,
sum(weightInGms * availablequantity) as total_weight
from zepto
group by category
order by total_weight;

--MY PROJECT QUERIES REAL TIME...

--Q1.Data cleaning Queries
-- Find products with missing values
SELECT *
FROM zepto
WHERE name IS NULL
OR category IS NULL
OR mrp IS NULL;

-- Find duplicate product names
SELECT name, COUNT(*)
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1;

-- Remove duplicate rows keeping first record
DELETE FROM zepto
WHERE sku_id NOT IN (
    SELECT MIN(sku_id)
    FROM zepto
    GROUP BY name
);

-- Find products with invalid prices
SELECT *
FROM zepto
WHERE mrp <= 0
OR discountedsellingprice <= 0;

-- Find products with discount greater than 100%
SELECT *
FROM zepto
WHERE discountpercent > 100;

--Q2. Business Analysis Queries

--find top 10 expensive products
SELECT name, mrp
FROM zepto
ORDER BY mrp DESC
LIMIT 10;

--find total revenue by category
SELECT category,
SUM(discountedsellingprice * availableQuantity) AS revenue
FROM zepto
GROUP BY category
ORDER BY revenue DESC;

--to find products out of stock
SELECT name, category
FROM zepto
WHERE outofstock = TRUE;

--Average Discount per Category
SELECT category,
AVG(discountpercent) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC;

--Highest Discounted Products
SELECT name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 20;

--Low Stock Products
SELECT name, availableQuantity
FROM zepto
WHERE availableQuantity < 10;

--Q3.Advanced Real-Time Queries

--to find Revenue Loss Due to Out-of-Stock
SELECT category,
SUM(discountedsellingprice * availableQuantity) AS potential_loss
FROM zepto
WHERE outofstock = TRUE
GROUP BY category
ORDER BY potential_loss DESC;

--why Discount Impact Analysis
SELECT category,
AVG(mrp - discountedsellingprice) AS avg_discount_amount
FROM zepto
GROUP BY category;

--what are Most Valuable Inventory
SELECT name,
(mrp * availableQuantity) AS inventory_value
FROM zepto
ORDER BY inventory_value DESC;

--Category with Maximum Products\
SELECT category,
COUNT(*) AS total_products
FROM zepto
GROUP BY category
ORDER BY total_products DESC;