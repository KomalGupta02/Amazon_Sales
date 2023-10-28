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

WITH products AS
(
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
      AS BestSellerStatus, DENSE_RANK() OVER( 
   ORDER BY
      round(price*boughtInLastMonth) DESC) AS rankk 
   FROM
      amazon_products AS p 
      INNER JOIN
         amazon_categories AS c 
         ON p.category_id = c.id 
   ORDER BY
      sales DESC
)
SELECT
   Product,
   Category,
   Sales,
   BestSellerStatus 
FROM
   products 
WHERE
   rankk <= 5 ;
   
   
-- 5. Name top 5 selling product categories.

WITH category AS
(
   SELECT
      category_name AS Category,
      SUM(round(price*boughtInLastMonth)) AS Sales,
      DENSE_RANK() OVER( 
   ORDER BY
      SUM(round(price*boughtInLastMonth)) DESC) AS rankk 
   FROM
      amazon_products AS p 
      INNER JOIN
         amazon_categories AS c 
         ON p.category_id = c.id 
   GROUP BY
      category_name 
   ORDER BY
      sales DESC
)
SELECT
   Category,
   Sales 
FROM
   category 
WHERE
   rankk <= 5;


-- 6. How many products made over $1 Million in sales? What is the contribution of these products in overall sales?

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

WITH product AS
(
   SELECT
      title AS Product,
      category_name AS Category,
      reviews AS NoOfReviews,
      stars AS Ratings,
      CASE
         WHEN
            isBestSeller = 1 
         THEN
            'Yes' 
         ELSE
            'no' 
      END
      AS BestSellerStatus , DENSE_RANK() OVER( 
   ORDER BY
      reviews DESC) AS rankk 
   FROM
      amazon_products p 
      INNER JOIN
         amazon_categories c 
         ON p.category_id = c.id 
   ORDER BY
      reviews DESC
)
SELECT
   Product,
   Category,
   NoOfReviews,
   Ratings,
   BestSellerStatus
FROM
   product 
WHERE
   rankk = 1;


-- 9. Which product offers the highest discount? Name its product category. How much sales this product has made?

WITH product AS
(
   SELECT
      title AS Product,
      category_name AS Category,
      price AS Price,
      round(listPrice - price) AS Discount,
      round(price*boughtInLastMonth) AS Sales,
      DENSE_RANK() OVER( 
   ORDER BY
      round(listPrice - price) DESC) AS rankk 
   FROM
      amazon_products p 
      INNER JOIN
         amazon_categories c 
         ON p.category_id = c.id 
   ORDER BY
      discount DESC
)
SELECT
   Product,
   Category,
   Price,
   Discount,
   Sales 
FROM
   product 
WHERE
   rankk = 1;


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

WITH category AS 
(
   SELECT
      category_name AS Category,
      COUNT(category_id) AS ProductCount,
      SUM(round(price*boughtInLastMonth)) AS Sales,
      DENSE_RANK() OVER ( 
   ORDER BY
      COUNT(category_id) DESC) AS category_rank 
   FROM
      amazon_products AS p 
      INNER JOIN
         amazon_categories AS c 
         ON p.category_id = c.id 
   GROUP BY
      category_name 
   ORDER BY
      ProductCount DESC LIMIT 5 
)
,
product AS
(
   SELECT
      Category,
      ProductCount,
      Sales,
      title AS Product,
      round(price*boughtInLastMonth) AS ProductSales,
      category_rank,
      DENSE_RANK() OVER ( 
   ORDER BY
      round(price*boughtInLastMonth) DESC) AS product_rank 
   FROM
      category AS cat 
      INNER JOIN
         amazon_categories c 
         ON c.category_name = cat.category 
      INNER JOIN
         amazon_products p 
         ON p.category_id = c.id 
   WHERE
      category_rank = 1 
   ORDER BY
      ProductSales DESC LIMIT 5
)
SELECT
   Category,
   ProductCount,
   Sales,
   Product,
   ProductSales 
FROM
   product 
WHERE
   product_rank = 1;















