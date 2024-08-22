Create database bbproject;
use bbproject;

create table basket(
id int, product varchar (75), category varchar (75), sub_category varchar (75), brand varchar (50),
sale_price int, market_price int, `type` varchar(75), rating double, `description` varchar (500));

/* The basket table procure the product recrods of bigbasket portal
The follwing will explain the analysis process with sql queries soving
different questions generating suitable reports*/

/* What are the total no of brands available in big basket ?*/
select count(distinct brand) `Total brands in big basket`
from basket;

/*What are the total categories of product available in big basket ?*/
select count(distinct category) `Total categories in big basket products`
from basket;

/* What are the total sub categories of product available in Big Basket ?*/
select count(distinct sub_category) `Total sub-categories in big basket products`
from basket;

/* What are the top 5 categories of product can be mentioned from the data ?*/
select category, round(avg(rating),2) `Average Rating`
from basket
group by category
order by `Average Rating` desc
limit 5;

/*What are the top 10 sub categories of product can be mentioned from the data ?*/
select sub_category, round(avg(rating),2) `Average Rating`
from basket
group by sub_category
order by `Average Rating` desc
limit 10;

/* Present the description of most costly product */
select id, product, market_price, `description`
from basket
order by market_price desc
limit 1;

/* What are the top 3 costly products in the big basket list ?*/
select id, product, market_price
from basket
order by market_price desc
limit 3;

/* Show most costly product of each category from the list of data*/
-- in order to figure out this the use pf common table expression is necessary
-- then join it with original table
with cte as(
select category, max(market_price) as `Maximum Price`
from basket
group by category)
select c.category as `Category`, b.product `Product`, c.`Maximum Price`
from cte c inner join basket b on c.`Maximum Price` = b.market_price
order by category asc;

/* what are the most costly product of each sub category, provide top 3 names */
with cte as(
select sub_category, product, market_price, 
dense_rank() over(partition by sub_category order by market_price desc) Rnk
from basket)
select sub_category `Sub Category`, Product, market_price as `Market Price`
from cte
where Rnk <=3;

/* what is the most discounted product name */
-- For this query it is necessary to ceate additional colum for discount calculation
alter table basket
add column discount int;

-- in order to update values in ths empty column first it is necessary to shut down the safe update mode
set sql_safe_updates = 0;

update basket
set discount = market_price - sale_price;

select product, discount
from basket
order by discount desc
limit 1;

/* create report on most discounted product of each category */
with c as(
select category, product, discount, dense_rank() over(partition by category order by discount desc) Rnk
from basket)
select category, product, discount
from c
where Rnk = 1
order by category asc;

/*Figure out which brand has most product */
select brand, count(product) as `total product`
from basket
group by brand
order by `total product` desc
limit 1;

/* which category has most product and what is the percentage of this out of all products*/
select category, count(product) `Total Product` 
from basket
group by category
order by `Total Product` desc
limit 1; 
select (7867/count(product))*100 `percentage of presence out of all products`
from basket;

/* which category has least product */
select category, count(product) `Total Product` 
from basket
group by category
order by `Total Product` asc
limit 1; 

/*which subcategory has most product*/
select sub_category, count(product) `Total Product` 
from basket
group by sub_category
order by `Total Product` desc
limit 1; 

/*which brand has most subcategory of products*/
select brand, count(sub_category) `Total Sub Category`
from basket
group by brand
order by `Total Sub Category` desc
limit 1;

/* How much product contains under Fresho Brand?*/
Select count(product) `Products under Fresho`
from basket
where brand = "Fresho";

/*Show top 3 products from each category*/
with c as(
select category, product, rating, dense_rank() over(partition by category order by rating desc) Rnk
from basket)
select *
from c
where Rnk <=3
order by category asc;