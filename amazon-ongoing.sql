-- create product table
CREATE TABLE amazon_products (
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    discounted_price TEXT,
    actual_price TEXT,
    discount_percentage TEXT,
    rating TEXT,
    rating_count TEXT,
    about_product TEXT,
    user_id TEXT,
    user_name TEXT,
    review_id TEXT,
    review_title TEXT,
    review_content TEXT,
    img_link TEXT,
    product_link TEXT
);


-- Delete the rupee symbol and the ',' comma to make the analysis easier
update amazon_products
set discounted_price = replace(replace(discounted_price,'₹',''),',','')

update amazon_products
set actual_price= replace(replace(actual_price,'₹',''),',','')

-- Delete the ',' inside rating_count columns (replace with '')
update amazon_products
set rating_count= replace(rating_count, ',','')


-- Fix data types
-- change the data type into numeric format, for discounted_price, actual_price
alter table amazon_products
alter column discounted_price type "numeric"
using discounted_price::"numeric" 

ALTER TABLE amazon_products
ALTER COLUMN actual_price TYPE "numeric"
USING actual_price::"numeric"

-- We found there's '|' on rating, which need to be investigated
select distinct rating from amazon_products

select * from amazon_products
where rating='|'

-- Let the '|' become null as we don't have the rating value
update amazon_products 
set rating= NULL
where rating='|';

alter table amazon_products
alter column rating type "numeric"
using rating::"numeric";

-- Convert into integer type
alter table amazon_products
alter column rating_count type INTEGER
USING rating_count:: INTEGER

-- Convert the discount_percentage e.g. from 14% into 0.14
update amazon_products
set discount_percentage = replace(discount_percentage, '%','');

alter table amazon_products
alter COLUMN discount_percentage type "numeric"
using discount_percentage::"numeric";

update amazon_products
set discount_percentage= round(discount_percentage/100,2);

-- Check duplicates
SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    rating,
    rating_count,
    about_product,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    img_link,
    product_link,
    COUNT(*) AS cnt
FROM amazon_products
GROUP BY
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    rating,
    rating_count,
    about_product,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    img_link,
    product_link
HAVING COUNT(*) > 1;

-- Check missing values
-- There's 2 null values for rating_count
select count(*) as total_rows,
count(*) filter(where product_id is null or product_id=''),
count(*) filter (where product_name is null or product_name=''),
count(*) filter(where category is null or category=''),
count(*) filter (where discounted_price is null),
count(*) filter(where actual_price is null ),
count(*) filter (where discount_percentage is null),
COUNT(*) FILTER (WHERE rating IS NULL )   ,             
COUNT(*) FILTER (WHERE rating_count IS NULL ) as rating_count_null,    
count(*) filter( where about_product is null or about_product=''),
count(*) filter( where user_id is null or user_id=''),
count(*) filter( where user_name is null or user_name=''),
count(*) filter( where review_id is null or review_id=''),
COUNT(*) FILTER (WHERE review_title IS NULL OR review_title = ''),
COUNT(*) FILTER (WHERE review_content IS NULL OR review_content = ''),
COUNT(*) FILTER (WHERE img_link IS NULL OR img_link = ''),
COUNT(*) FILTER (WHERE product_link IS NULL OR product_link = '')
from amazon_products

-- The product ID with rating_count null values are : B0B94JPY2N, B0BQRJ3C47
-- Products with a null rating_count only appear once, so there is no value to reference, the null will remain as is.
select * from amazon_products
where rating_count is null


-- We found certain product_id have different rating_count
-- e.g. B098NS6PVG appears twice, once with 43994 and once with 43993 rating count
-- B09CMM3VGK appears twice, once with 1933 and once with 1934 rating count
-- We will use the maximum rating_count as it represent the latest or updated rating_count
with distinct_product_rate as (
select distinct product_id, rating_count
from amazon_products
order by product_id),
duplicate_product_rate_count as (
select product_id, count(product_id)
from distinct_product_rate
group by product_id
having count(product_id)>1)
select *
from distinct_product_rate
where product_id in (select product_id from duplicate_product_rate_count)



-- Split the category level, as it's originally seperated by | | |, we will divide the depth of category by using e.g. level 1, level 2, etc

-- we have 1 | to 6 |,
with split_count as (
select category, length (category)- length(replace(category,'|','')) as num_split
from amazon_products)
select min(num_split), max(num_split)
from split_count

-- There's no cases like e.g. Electronic||HomeAudio 
select category 
from amazon_products
where category like '%||%' or category like '|%' or category like '%|'


-- Check whether the rating is valid
select * from amazon_products where rating <0 or rating>5

/*
We will seperate the table for products and reviews. For products table it will consist of certain new columns such as
1. category: we will not modify the actual dataset. 'View' will be used for analysis later
2. rating_count_new: 
	some products appear more than once with different rating_count values
    due to data being scraped at different points in time.
    we take the MAX rating_count per product_id as it reflects the most recent data.
3. Extract the brand name from product_name

- This view excludes review-related columns (user_id, user_name, review_id, review_title, review_content).
- DISTINCT is applied to ensure no duplicate rows, as some products share the same product info
- but differ only in review columns -- those differences are removed here.

*/
--drop view clean_product


-- Note: the raw table amazon_products is retained for reference
-- in case a deeper investigation is needed for this specific product later.

create OR replace view clean_product as 
select distinct product_id, product_name,category, discounted_price, actual_price, discount_percentage,rating,rating_count,about_product,split_part(category,'|',1) as level1,
split_part(category,'|',2) as level2,
split_part(category,'|',3) as level3,
split_part(category,'|',4) as level4,
split_part(category,'|',5) as level5,
split_part(category,'|',6) as level6,
split_part(category,'|',7) as level7,
max(rating_count::INTEGER) over (partition by product_id) as rating_count_new,
lower(split_part(product_name,' ',1)) as brand
from amazon_products

-- Ensure no duplicates of rows with exact same value for all columns
select *, count(*) as cnt
from clean_product
group by product_id, product_name,category,discounted_price, actual_price, discount_percentage,rating,rating_count,about_product,level1,level2,level3,level4,level5,level6,level7,rating_count_new, brand
having count(*)>1

-- Validate the other columns 
-- e.g. same product_id but different product_name
-- None of rows have the same product_id but different product_name
-- Row 4 has been solved by statement above (product_id : B096MSW6CT)
--drop view clean_product_validate
create view clean_product_validate as (
select product_id, count(distinct product_name) as prod_name,count(distinct category) as cate, count(distinct discounted_price) as disc_price,  count(distinct actual_price) as actual_price, count(distinct discount_percentage) as disc_percent,  count(distinct rating) as rating, count(distinct rating_count) as rating_count, count(distinct about_product) as about_product,  count(distinct brand) as brand
from clean_product
group by product_id
having count(distinct product_name)>1 or 
		count(distinct category)>1 or 
		count(distinct discounted_price) >1 or   
		count(distinct actual_price) >1 or 
		count(distinct discount_percentage) >1 or 
		count(distinct rating) >1 or 
		count(distinct about_product) >1 or 
		count(distinct rating_count)>1 or 
		count(distinct brand)>1)

-- Check the problematic rows

-- In this product view, having multiple rows for the same product_id will mislead the analysis
-- (e.g. inflating counts, wrong averages for price and rating).

-- We identified 31 products with multiple rating_count values.
-- As rating_count increases over time when more customers submit ratings,
-- the record with the highest rating_count is assumed to be the most recent.
-- Therefore, the latest record is retained for each product.


select
    count(*) filter (where prod_name > 1) as diff_product_name,
    count(*) filter (where cate > 1) as diff_category,
    count(*) filter (where disc_price > 1) as diff_discount_price,
    count(*) filter (where actual_price > 1) as diff_actual_price,
    count(*) filter (where disc_percent > 1) as diff_discount_percent,
    count(*) filter (where rating > 1) as diff_rating,
    count(*) filter (where about_product > 1) as diff_about_product,
    count(*) filter (where rating_count > 1) as diff_rating_count,
    count(*) filter (where brand > 1) as diff_brand
from clean_product_validate;

-- We found that certain issues, e.g. same product_id etc but different about_product values (product_id : B07DJLFMPS,B083342NKJ,B08CF3D7QR)
with product_issues as (
select product_id, concat_ws(',', 
	case when disc_price>1 then 'disc_price' end,
	case when actual_price>1 then 'actual_price' end,
	case when disc_percent>1 then 'disc_percent' end,
	case when about_product>1 then 'about_product' end,
	case when rating_count>1 then 'rating_count' end) as issues
	from clean_product_validate
)
select issues, string_agg (product_id, ',')
from product_issues
group by issues


-- Issue 1 : about_product
-- There's multiple about_product even if it's only one product_id 
-- Such as : B07DJLFMPS, B083342NKJ,B08CF3D7QR
-- Solution: we will choose the longest about_product description as it's likely represent the most complete information
select *, length(about_product) from clean_product
where product_id in (select product_id from clean_product_validate
where about_product >1 and product_id not in ('B096MSW6CT'))
order by product_id

-- Issue 2: disc_price, disc_percent, rating_count
-- In this specific case, the issue can be solved by the rating_count solution, where higher rating_count represent the latest records
select * from clean_product
where product_id in (select product_id
from clean_product_validate
where disc_price >1 and disc_percent >1 and rating_count>1
)
order by product_id

-- Issue 3: actual_price,disc_percent,about_product
-- Product ID: B096MSW6CT 
-- Product B096MSW6CT has different actual_price values across rows (1899 vs 999)
-- likely due to a price change between scraping sessions.
-- This is a known data quality issue and will be noted for analysis.
-- Please note, even though the actual_price is different, the discounted_price is the same across rows which make the impact of these differences smaller

-- Solution:
-- We keep the last occurrence of the record, as it contains the most complete
-- about_product description and is likely to represent the most recent version
-- of the product information in the dataset.
select * from clean_product
where product_id in (select product_id
from clean_product_validate
where actual_price >1 and disc_percent >1 and about_product>1
)
order by product_id


-- Issue 5 : disc_price, disc_percent
-- There's multiple discount_price and discount_percentage for certain products
-- e.g.B09MT84WV5, B0B5LVS732, B0B5B6PQCT
-- We will select the most recent record for each product based on rating_count.
-- A higher rating_count (e.g., 17833 vs 17831, or 140036 vs 140035) indicates a more updated snapshot of the product.
-- In addition, based on observed data patterns, newer records tend to appear in later rows within the dataset.
-- Therefore, when duplicates exist with similar rating_count, we use row position behavior as a supporting heuristic,
-- where later-occurring rows are treated as more recent.

-- Hence, we prioritize:
-- 1) Highest rating_count as primary indicator of recency
-- 2) If tied, use observed later-row pattern as secondary heuristic
select * from clean_product
where product_id in (select product_id
from clean_product_validate
where disc_price >1 and disc_percent >1
)
order by product_id


-- We identified 5 types of data quality issues.

-- Our primary rule is to retain the most recent record for each product.
-- A higher rating_count is treated as an indicator of a more recent snapshot,
-- as products generally accumulate reviews over time.

-- Applying this rule resolves all records with inconsistent rating_count values,
-- and also resolves most cases where discounted_price and discount_percentage differ,
-- as the newer record is retained.

-- For the remaining cases where rating_count is identical across duplicate records,
-- we retain the last occurrence in the dataset, based on the observed pattern that
-- later rows tend to represent more recent scraped values.

-- A small number of products also contain different about_product descriptions.
-- However, only 3 products are affected, and the about_product field is not used in the
-- main analysis. In most cases, the retained record already contains the more complete
-- product description. Therefore, no additional rule is applied specifically for
-- about_product differences.

-- Overall, the final cleaning rule is:
-- 1. Keep the record with the highest rating_count.
-- 2. If rating_count is tied, keep the last occurrence in the dataset.



-- Create products (table) from clean_product (view).
-- The view stays dynamic and keeps the transformation logic correct for any data,
-- while this table is a fixed dataset used for analysis.
create table products as 
select * from clean_product;

alter table products
add column num integer;

with row_serial as (
select ctid, row_number ()over (partition by product_id) as rn
from products)
update products p
set num= r.rn
from row_serial r
where p.ctid= r.ctid

-- Check number of deleted rows
with ranked as (
select *, row_number() over(partition by product_id order by rating_count desc, num desc) as ordered
from products)
select * from ranked 
where ordered>1

--Delete the unused rows from products table
with ranked as (
select ctid, row_number() over(partition by product_id order by rating_count desc, num desc) as ordered
from products)
delete from products
where ctid in (select ctid from ranked 
where ordered>1
)

-- Products table is clean

-- Ensure all products are inside products table, no product is accidentally deleted
select distinct product_id from clean_product
except
select product_id from products;



--
select count(*) from products


select * from clean_product
limit 5

select * from amazon_products 
limit 15;
