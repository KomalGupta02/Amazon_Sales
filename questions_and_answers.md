# Amazon September Sales Analysis
## Questions and Answers

**1.**  List the total number of products found on Amazon.

````sql
SELECT
   COUNT(asin) AS "Total Products" 
FROM
   amazon_products;
````  

**Results:**

|Total Products|
|--------------|
|1,426,336     |


**2.** How much sales were made by Amazon in September?

````sql
SELECT
   SUM(round(price*boughtInLastMonth)) AS Sales 
FROM
   amazon_products;
````

**Results:**

|Sales        |
|-------------|
|4,650,746,745|


**3.** How many product categories are there on Amazon?

```sql
SELECT
   COUNT(id) AS "Product Categories" 
FROM
   amazon_categories;
```

**Results:**

|Product Categories|
|------------------|
|248               |


**4.** Name top 5 selling products in terms of sales. Are these products also "Best Seller" on Amazon?

````sql
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
````

**Results:**

|Product                                                                                                                                     |Category                        |Sales    |BestSellerStatus|
|--------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|---------|----------------|
|PlayStation 5 Console (PS5)                                                                                                                 |Video Games                     |4,999,900|No              |
|Xbox Series X                                                                                                                               |Video Games                     |4,899,900|Yes             |
|Nespresso Capsules VertuoLine, Medium and Dark Roast Coffee, Variety Pack, Stormio, Odacio, Melozio, 30 Count, Brews 7.77 Fl Oz (Pack of 3 )|Kitchen & Dining                |3,750,000|No              |
|Dyson V8 Cordless Vacuum Cleaner                                                                                                            |Janitorial & Sanitation Supplies|3,024,000|No              |
|Nespresso Capsules VertuoLine, Melozio, Medium Roast Coffee, Coffee Pods, Brews 7.77 Fl Ounce (VERTUOLINE ONLY), 10 Count (Pack of 3)       |Kitchen & Dining                |3,000,000|No              |


**5.** Name top 5 selling product categories.

````sql
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
````

**Results:**

|Category                   |Sales      |
|---------------------------|-----------|
|Kitchen & Dining           |267,189,588|
|Hair Care Products         |152,940,692|
|Home Storage & Organization|138,604,614|
|Toys & Games               |135,393,889|
|Industrial & Scientific    |130,196,200|


**6.**  How many products made over $1 Million in sales? What is the contribution of these products in overall sales?

````sql
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
````

**Results:**

|ProductCount|ProductSales|TotalSales   |Contribution|
|------------|------------|-------------|------------|
|101         |165,778,923 |4,650,746,745|3.56        |

**7.** How many products get 5-star rating on Amazon?

````sql
SELECT
   stars AS Ratings,
   COUNT(stars) AS "Product Count" 
FROM
   amazon_products 
WHERE
   stars = 5 
GROUP BY
   stars;
````

**Results:**

|Ratings|Product Count|
|-------|-------------|
|5      |94,839       |


**8.** Name the most reviewed product on Amazon. How many ratings the product has received? Is the product also an Amazon "Best Seller"?


````sql
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
````

**Results:**

|Product                                                                  |Category|NoOfReviews|Ratings|BestSellerStatus|
|-------------------------------------------------------------------------|--------|-------------|-------|------------------|
|essence  Lash Princess False Lash Effect Mascara  Gluten & Cruelty Free|Makeup  |346,563      |4.3    |Yes               |



**9.** Which product offers the highest discount? Name its product category. How much sales this product has made?

````sql
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
````

**Results:**

|Product                                                        |Category                                   |Price |Discount|Sales|
|---------------------------------------------------------------|-------------------------------------------|------|--------|-----|
|PRO2-500 500 Watt Adjustable Temperature 5/8" Hot Melt Glue Gun|Industrial Adhesives, Sealants & Lubricants|201.99|797     |0    |



**10.** How many products have "Best Seller" status on Amazon? How many of these products did not made any sales in September?

````sql
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
````

**Results:**

|Status     |No. of Products|
|-----------|---------------|
|Best Seller|8,520          |


````sql
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
````

**Results:**

|Status     |No of Products not sold|
|-----------|-----------------------|
|Best Seller|1,738                  |


**11.** Which product category offers highest number of products on Amazon? How much sales this product category made in September? Which product is providing maximum contribution to the overall category sales? 

```sql
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
```

**Results:**

|Category       |ProductCount|Sales    |Product                                                    |ProductSales|
|---------------|------------|---------|-----------------------------------------------------------|------------|
|Girls' Clothing|28,619      |6,757,788|Girls' Cool Comfort Ankle, 12-Pair Pack Fashion Liner Socks|75,000      |










