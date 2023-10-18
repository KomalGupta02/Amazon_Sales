-- Amazon September Sales Analysis
-- Questions and Answers

-- 1. List the total number of products found on Amazon.

SELECT
   COUNT(asin) AS "Total Products" 
FROM
   amazon_products;


-- 2. How much sales were made by Amazon in September?

SELECT
   SUM(round(price*boughtInLastMonth)) AS Sales 
FROM
   amazon_products;


-- 3. How many product categories are there on Amazon?

SELECT
   COUNT(id) AS "Product Categories" 
FROM
   amazon_categories;


-- 4. Name top 5 selling products in terms of sales. Are these products also "Best Seller" on Amazon?

SELECT
   title AS Product,
   category_name AS Category,
   round(price*boughtInLastMonth) AS Sales,
   CASE
      WHEN
         isBestSeller = 1 
      THEN
         'Yes' 
      ELSE
         'No' 
   END
   AS BestSellerStatus 
FROM
   amazon_products AS p 
   INNER JOIN
      amazon_categories AS c 
      ON p.category_id = c.id 
ORDER BY
   Sales DESC LIMIT 5;


-- 5. Name top 5 selling product categories.

SELECT
   category_name AS Category,
   SUM(round(price*boughtInLastMonth)) AS Sales 
FROM
   amazon_products AS p 
   INNER JOIN
      amazon_categories AS c 
      ON p.category_id = c.id 
GROUP BY
   category_name 
ORDER BY
   sales DESC LIMIT 5;


-- 6. Name top 5 selling products in terms of quantity. Are these products also "Best Seller" on Amazon?

SELECT
   title AS Product,
   category_name AS Category,
   round(price*boughtInLastMonth) AS Sales,
   boughtInLastMonth AS Quantity,
   CASE
      WHEN
         isBestSeller = 1 
      THEN
         'Yes' 
      ELSE
         'No' 
   END
   AS BestSellerStatus 
FROM
   amazon_products AS p 
   INNER JOIN
      amazon_categories AS c 
      ON p.category_id = c.id 
ORDER BY
   Quantity DESC LIMIT 5;


-- 7. How many products get 5-star rating on Amazon?

SELECT
   stars AS Ratings,
   COUNT(stars) AS "Product Count" 
FROM
   amazon_products 
WHERE
   stars = 5 
GROUP BY
   stars;


-- 8. Name the most reviewed product on Amazon. How many ratings the product has received? Is the product also an Amazon "Best Seller"?

SELECT
   title AS Product,
   category_name AS Category,
   reviews AS "No. Of Reviews",
   stars AS Ratings,
   CASE
      WHEN
         isBestSeller = 1 
      THEN
         'Yes' 
      ELSE
         'no' 
   END
   AS "Best Seller Status" 
FROM
   amazon_products p 
   INNER JOIN
      amazon_categories c 
      ON p.category_id = c.id 
ORDER BY
   reviews DESC LIMIT 1;


-- 9. Which product offers the highest discount? Name its product category. How much sales this product has made?

SELECT
   title AS Product,
   category_name AS Category,
   price AS Price,
   round(listPrice - price) AS Discount,
   round(price*boughtInLastMonth) AS Sales
FROM
   amazon_products p 
   INNER JOIN
      amazon_categories c 
      ON p.category_id = c.id 
ORDER BY
   Discount DESC LIMIT 1;



-- 10. How many products have "Best Seller" status on Amazon? How many of these products did not made any sales in September?

SELECT
   CASE
      WHEN
         isBestSeller = 1 
      THEN
         "Best Seller" 
      ELSE
         "Not a Best Seller" 
   END
   AS Status, COUNT(isBestSeller) AS "No. of Products" 
FROM
   amazon_products 
WHERE
   isBestSeller = 1 
GROUP BY
   isBestSeller;


SELECT
   CASE
      WHEN
         isBestSeller = 1 
      THEN
         "Best Seller" 
      ELSE
         "Not a Best Seller" 
   END
   AS Status , COUNT(isBestSeller) AS "No of Products not sold" 
FROM
   amazon_products 
WHERE
   isBestSeller = 1 
   AND boughtInLastMonth = 0 
GROUP BY
   isBestSeller;


-- 11. Which product category offers highest number of products on Amazon? How much sales this product category made in September? Which product is providing maximum contribution to the overall category sales? 

WITH prod_cat AS 
(
   SELECT
      category_name AS Category,
      COUNT(category_id) AS ProductCount,
      SUM(round(price*boughtInLastMonth)) AS Sales 
   FROM
      amazon_products AS p 
      INNER JOIN
         amazon_categories AS c 
         ON p.category_id = c.id 
   GROUP BY
      category_name 
   ORDER BY
      ProductCount DESC LIMIT 1 
)
SELECT
   Category,
   ProductCount,
   Sales,
   title AS Product,
   round(price*boughtInLastMonth) AS ProductSales 
FROM
   prod_cat AS pro 
   INNER JOIN
      amazon_categories c 
      ON c.category_name = pro.category 
   INNER JOIN
      amazon_products p 
      ON p.category_id = c.id 
ORDER BY
   ProductSales DESC LIMIT 1;


-- 12. How many products made over $1 Million in sales? What is the contribution of these products in overall sales?

WITH product AS
(
   SELECT
      COUNT(round(price*boughtInLastMonth)) AS ProductCount,
      SUM(round(price*boughtInLastMonth)) AS ProductSales 
   FROM
      amazon_products 
   WHERE
      round(price*boughtInLastMonth) > 1000000
)
,
total AS 
(
   SELECT
      SUM(round(price*boughtInLastMonth)) AS TotalSales 
   FROM
      amazon_products
)
SELECT
   *,
   round((ProductSales / TotalSales)*100, 2) AS Contribution 
FROM
   product,
   total;





