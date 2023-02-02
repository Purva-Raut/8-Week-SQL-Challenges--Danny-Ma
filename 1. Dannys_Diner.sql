CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 
/*Check all tables are loaded*/
SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount FROM
(SELECT s.customer_id, p.product_id, p.price
FROM sales s
INNER JOIN menu p
ON s.product_id=p.product_id) AS table2
GROUP BY customer_id
ORDER BY customer_id;
--Ans:Customer A-76, B-74, C-36 amount
/*Explanation:I began by joining the 'sales' and the 'menu' table on a common column 'product_id' 
and formed a new table which has information of customer_id, product_id and price of each product.
Then I queried this newly formed table by summing the total price and grouped by customer_id to find out
total expenditure by each customer*/
--Queries: INNER JOIN,Subquery,GROUP BY

-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT (s.order_date)) as total_days
FROM sales s
GROUP BY s.customer_id
ORDER BY s.customer_id;
--Ans:Customer A-4, B-6, C-2 days
/*Explanation:Count of distinct dates will give me the no.of total days.
Group by is used to group the result for each customer*/
--Queries: DISTINCT,COUNT,GROUP BY

-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT* FROM(
SELECT customer_id, order_date, product_id,product_name
,RANK() OVER(PARTITION BY t.customer_id ORDER BY t.order_date) as rnk
FROM
    (SELECT s.customer_id, s.order_date, s.product_id,p.product_name
FROM sales s
INNER JOIN menu p
ON s.product_id=p.product_id) AS t) AS t2
WHERE rnk=1;
--Ans:The first item purchased is Customer A-curry and sushi, B-curry, C-ramen
/*Explanation: Subqueries are used twice to solve this question. Let's begin with the innermost query first
and then move outwards.
Step1: I began with joining sales and menu table as I wanted product_name to be displayed along with the 
other information.
Step2: As we want to find the first item/s ordered by each customer we need to use window function Rank or Dense rank
where we can order by the date and partion by customer(as we need information by each customer and on earliest date).
Step 3: We just need information for the first item so we input command to get information where rank is 1.
We have used DISTINCT to avoid duplicate results.
Note: Alias is mandatory for inner query tables.*/
--Queries: Double subquery, INNER JOIN, WINDOWS RANK/DENSE_RANK FUNCTION

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name AS most_purchased_item,COUNT(product_name) as purchased_times
FROM
(SELECT s.product_id,p.product_name
FROM sales s
INNER JOIN menu p
ON s.product_id=p.product_id) t
GROUP BY product_name
ORDER BY purchased_times DESC
LIMIT 1;
--Ans: The most purchased item on the menu is ramen and it is purchased 8 times till date.
/*Explanation: 1 subquery used.
Inner query: Joined sales and menu table to display the name of the product.
Outer query: Queried count of the product in the newly formed table and grouped by product,ordered decending 
by the times purchased and set limit to 1 as we need to display the most popular item only*/
--Queries:Subquery, INNER JOIN, GROUP BY, ORDER BY, LIMIT

-- 5. Which item was the most popular for each customer?
SELECT * FROM
(SELECT customer_id, product_name,total_orders
 ,DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY total_orders DESC) AS rnk
 FROM
 (SELECT s.customer_id,p.product_name,COUNT(s.product_id) as total_orders
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id
  GROUP BY s.customer_id,p.product_name
  ORDER BY s.customer_id)t)t2
  WHERE rnk=1;
--Ans: The most popular item for customer is as follows: A-ramen, B-sushi,curry,ramen, C-ramen
/*Explanation: 2 subqueries used.
Lets begin with and innermost and then move outwards.
Step1:Join tables sales and menu.Also count total products ordered grouping by the customer and product.
Now we can see the customer_id, product_name and number of orders for the product by respective customer.
Step2: Use windows function Rank/ Dense_rank to rank the most popular product.
Partition is by the customer and ordering by the maximum Number of orders
Step 3: As we need to display the most popular item use where calsue to display results where the rank is 1.*/
--Queries: Subquery, INNER JOIN, GROUP BY, ORDER BY DESC,COUNT

-- 6. Which item was purchased first by the customer after they became a member?
SELECT * FROM
(SELECT *,
RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM
(SELECT s.customer_id,s.order_date,s.product_id,p.product_name,m.join_date
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id
  INNER JOIN members m
  ON s.customer_id=m.customer_id
  WHERE order_date>=join_date)t) t2
WHERE rnk=1;
--Ans: Customer A and B are members and the first item purchased is A-curry, B-sushi
/*Explanation:2 subqueries used.
Lets start with the ineermost first and move outwards.
Step1: Join all the 3 tables on common columns and filter result to display data where order date
is equal to or greater than the joining date.
Step2:Use windows function Rank/Dense_rank to partition the data using the customer_id and order by the order_date.
Step3: Display only the data where rank is 1. This will display the first item purchased by each customer after 
becoming a member.*/
--Queries: Subquery, JOIN, comparative operator, RANK/DENSE_RANK

-- 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT* FROM
(SELECT *,
RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
FROM
(SELECT s.customer_id,s.order_date,s.product_id,p.product_name,m.join_date
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id
  LEFT JOIN members m
  ON s.customer_id=m.customer_id
  WHERE order_date<join_date )t) t2
WHERE rnk=1;
/*Ans: Customer A and B are members and the last item purchased just before becoming members is 
A-sushi,curry, B-sushi*/
/*Explanation: 2 subqueries used.
Lets start with the ineermost first and move outwards.
Step 1:Join all the 3 tables on common columns and filter result to display data where order date
is lesser than the joining date as the customers were not members then.
Step2:Use windows function Rank/Dense_rank to partition the data using the customer_id and 
order by the order_date descending as we need latest date just before becoming a member.
Step3: Display only the data where rank is 1 to give the desired result.*/
--Queries: Subquery, JOIN, comparative operator, RANK/DENSE_RANK

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT customer_id,COUNT(DISTINCT(product_id)) AS total_items, SUM(price) AS total_amount
FROM
(SELECT s.customer_id,s.order_date,s.product_id,p.product_name,p.price,m.join_date
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id
  LEFT JOIN members m
  ON s.customer_id=m.customer_id
  WHERE s.order_date<m.join_date) t
GROUP BY customer_id
ORDER BY customer_id;
--The total items and amount spent before they became a member is as follows: A-2-25, B-2-40
/*Explanation: 1 Subquery used.
Inner query: Joined all the 3 tables on the common columns and filtered data where order_data is lesser than the
membership joining date.
Outer query:Used aggregate functions to count total items and sum total amount grouped by each customer*/
--Queries: Subquery, Join, Group by, Aggregate functions-count, sum, Distinct

/* 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
how many points would each customer have?*/
SELECT customer_id,SUM(points) AS total_points
FROM
(SELECT *,
 CASE
 WHEN product_name=LOWER('sushi') THEN price*10*2
 ELSE price*10
 END AS points
 FROM 
 (SELECT s.customer_id,s.product_id,p.product_name,p.price
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id) t)t2
GROUP BY customer_id
ORDER BY customer_id ;
--Ans:The total points for each customer is A-860, B-940, C-360
/*Explanation: I have used 2 subqueries. Lets start with the innermost and then move outwards.
Step1: Join sales and menu table on common columns.
Step2: Use case statement to add a new points columns filling in the desired critera.
Step3: Sum the total points and group by each customer.*/
--Queries:join, case-when-then-else-end, group by

/*10. In the first week after a customer joins the program (including their join date) they earn 2x points
on all items, not just sushi - how many points do customer A and B have at the end of January?*/
SELECT customer_id,SUM(points) AS total_points
FROM
(SELECT *,
 CASE
 WHEN product_name=LOWER('sushi') THEN price*10*2
 WHEN order_date BETWEEN JOIN_date and offer_date THEN price*10*2
 ELSE price*10
 END AS points
 FROM
 (SELECT s.customer_id,s.order_date,s.product_id,p.product_name,p.price,m.join_date,m.join_date+6 AS offer_date
  FROM sales s
  INNER JOIN menu p
  ON s.product_id=p.product_id
  INNER JOIN members m
  ON s.customer_id=m.customer_id
  WHERE s.order_date<='2021-01-31')t)t2
GROUP BY customer_id
ORDER BY customer_id ;
--Ans: Total points for the customer as per the criteria is A-1370, B-820
/*Explanation: 
Understand criteria to meet:
1.We need data only for the month on January
2.When order_date is between the join_date (including) and Offer validity date (join_date+6), points=price*20
3.If order_date is before join_date or after the 1st week of joining then points for sushi=price*20 else price*10
2 subqueries used.
Step1: JOin all 3 tables and limit data until end of January.
Step2:Case when then else for desired criteria
Step3:Summing of points and group by the customer_id*/
--Queries:JOIN,subquery, CASE, GROUP by,Can use DATEADD in other SQL environment.

--Bonus Questions:
--1.JOIN tables
SELECT customer_id,order_date,product_name,price,
CASE
WHEN order_date>=join_date THEN 'Y'
ELSE 'N'
END AS member
FROM
(SELECT s.customer_id,s.order_date,p.product_name,p.price,m.join_date
FROM sales s
INNER JOIN menu p
ON s.product_id=p.product_id
LEFT JOIN members m
ON s.customer_id=m.customer_id
ORDER BY s.customer_id,s.order_date, p.product_name)t;

/*2.Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
for the records when customers are not yet part of the loyalty program.*/
SELECT customer_id,order_date,product_name,price,member,
CASE
WHEN member='N' THEN NULL
ELSE
DENSE_RANK()OVER(PARTITION BY customer_id,member ORDER BY order_date)
END AS ranking
FROM
(SELECT customer_id,order_date,product_name,price,
CASE
WHEN order_date>=join_date THEN 'Y'
ELSE 'N'
END AS member
FROM
(SELECT s.customer_id,s.order_date,p.product_name,p.price,m.join_date
FROM sales s
INNER JOIN menu p
ON s.product_id=p.product_id
LEFT JOIN members m
ON s.customer_id=m.customer_id
ORDER BY s.customer_id,s.order_date, p.product_name)t)t2;

