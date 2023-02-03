DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
--Check all the tables are uploaded and check if data cleaning is required 
SELECT * FROM runners;
--Data looks good
SELECT * FROM customer_orders;
--Need to replace 'null' word and blanks with NULL  in exclusions and extras column.
SELECT * FROM runner_orders;
--pickup_time — Remove 'null' word,blanks and replace with NULL
--pickup_time to DATETIME type
--distance — Remove ‘km’ ,'null' words ,blanks and replace with NULL
--distance to FLOAT type
--duration — Remove ‘minutes’,'null' words,blanks and replace with NULL
--duration to INT type
--cancellation — Remove 'null'words,blanks and replace with NULL
SELECT * FROM pizza_names;
--Data looks good
SELECT * FROM pizza_recipes;
--Data looks good
SELECT * FROM pizza_toppings;
--Data looks good

--Data Cleaning and Transformation
--Let's work on the customer_orders table
--We will create a temporary table with clean data and use this further in our analysis
DROP TABLE IF EXISTS customer_orders2;
CREATE TEMP TABLE customer_orders2 AS (
SELECT order_id,customer_id,pizza_id,
CASE
WHEN exclusions LIKE 'n%' OR exclusions='' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras LIKE 'n%' OR extras='' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders);
--Check customer_orders2 table
SELECT * FROM customer_orders2;

--Let's now work on the runner_orders table
--We will create a temporary table with clean data and use this further in our analysis
DROP TABLE IF EXISTS runner_orders2;
CREATE TEMP TABLE runner_orders2 AS(
SELECT order_id,runner_id,
CASE
    WHEN pickup_time LIKE 'n%' OR pickup_time ='' THEN NULL
    ELSE pickup_time
    END AS pickup_time,
CASE
    WHEN distance LIKE 'n%' OR distance='' THEN NULL 
    WHEN distance LIKE '%km' THEN TRIM ('km'FROM distance)
    ELSE distance
    END AS distance,
CASE
    WHEN duration LIKE 'n%'OR duration ='' THEN NULL
    WHEN duration LIKE '%min%' THEN TRIM ('minutes' FROM duration)
    ELSE duration
    END AS duration,
CASE
    WHEN cancellation LIKE 'n%'OR cancellation ='' THEN NULL
    ELSE cancellation
    END AS cancellation
FROM runner_orders);
--Check runner_orders2 table
SELECT * FROM runner_orders2;
--We are yet to change the column datatypes
ALTER TABLE runner_orders2
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::timestamp with time zone,
ALTER COLUMN distance TYPE FLOAT USING distance::float,
ALTER COLUMN duration TYPE INT USING duration::integer; 
--Check runner_orders2 table
SELECT * FROM runner_orders2;

--Data is cleaned and transformed :-)

--A.Pizza Metrics
--1. How many pizzas were ordered?
SELECT COUNT(order_id) AS Total_pizzas_ordered
FROM customer_orders2;
--Ans: 14 pizzas were ordered
--I did not use DISTINCT as there can be more than 1 pizza for the same order_id and we need count of total pizzas.

--2.How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) AS unique_customer_orders
FROM customer_orders2;
--Ans: There were 10 unique customer orders

--3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(order_id) AS successful_orders
FROM runner_orders2
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;
/*Ans: Runner_id 1 delivered 4 successful orders,Runner_id 2 delivered 3 successful orders,
Runner_id 3 delivered 1 successful order.
Explanation: We added a where clause to not count the cancelled orders*/

--4. How many of each type of pizza was delivered?
SELECT pizza_id,pizza_name, COUNT(order_id) AS total_pizzas_delivered
FROM
(SELECT c.order_id,c.pizza_id,pn.pizza_name,r.cancellation
FROM customer_orders2 c
INNER JOIN runner_orders2 r
ON c.order_id=r.order_id
INNER JOIN pizza_names pn
ON c.pizza_id=pn.pizza_id)t
WHERE cancellation IS NULL
GROUP BY pizza_id,pizza_name
ORDER BY pizza_id;
--Ans: Meatlovers pizzas delivered were 9 and Vegeterian pizzas delivered were 3.
/*I began by joining tables customer_orders2, runner_orders2and pizza_names on common columns and formed a new table
with all the required informed.Then I queried this new table and grouped by pizza_id and pizza_name to get a total
of orders for each pizza type. I have used a where clasue to not count the cancelled orders.*/
--Queries: Joins, subquery, group by, where clause

--5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,pizza_name,COUNT(pizza_id) AS total_orders
FROM 
(SELECT c.customer_id,c.pizza_id,pn.pizza_name
FROM customer_orders2 c
INNER JOIN pizza_names pn
ON c.pizza_id=pn.pizza_id)t
GROUP BY customer_id,pizza_name
ORDER BY Customer_id;
--Ans:101-M2-V1, 102-M2-V1, 103-M3-V1, 104-M3-V1, 105-V1
/*Subquery used.
I began by joining customer_order2 and pizaa_names tables on column col.
Queried this new table abd grouped by 1st bu customer id and then by pizza name and counted pizza_ids 
falling under group and subgroup*/
--Queries: JOin, subquery, Group by using 2 columns

--6.What was the maximum number of pizzas delivered in a single order?
SELECT * FROM runner_orders2;
SELECT * FROM customer_orders2;

SELECT COUNT(order_id) as max_pizzas_delivered_in_single_order
FROM 
(SELECT c.order_id,r.cancellation
FROM customer_orders2 c
INNER JOIN runner_orders2 r
ON c.order_id=r.order_id)t
WHERE cancellation IS NULL
GROUP BY order_id
ORDER BY max_pizzas_delivered_in_single_order DESC
LIMIT 1;
--Ans. The maximum pizzas delivered in a single order are 3
/*Explanation: Subquery used.
JOin tables customer_orders2(contain information of no. of pizzas per order ) and 
runner_orders2(contains information ofcancelled orders)on common col.
Query the joined table count total orders and group by order id. Order by clause is used to order the 
result in descending order and limit 1 to get the maximum no. of pizzas delivered.*/

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS pizzas_with_change,
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS pizzas_without_change
FROM 
(SELECT c.order_id,c.customer_id,c.exclusions,c.extras,r.cancellation
FROM customer_orders2 c
INNER JOIN runner_orders2 r
ON c.order_id=r.order_id)t
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;
--Ans: customer_id, with_change, without_change: 101-0-2, 102-0-3, 103-3-0, 104-2-1, 105-1-0
/*Explanation: Join customer and runner table in order to avoid cancelled orders which we specify in the where clause.
For with Change- either exclusions or extras must be not null-Give such orders 1 and sum all of them.Sum(case)
For without change- BOth exclusions and extras must be null-Give such orders 1 and sum all of them.Sum(case)
Use group by clause on customer_id.
Queries: Join, subquery, sum of case, group by*/

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(order_id) AS pizzas_with_exclusions_and_extras
FROM
(SELECT c.order_id,c.exclusions, c.extras,r.cancellation
FROM customer_orders2 c
INNER JOIN runner_orders2 r
ON c.order_id=r.order_id)t
WHERE cancellation IS NULL AND exclusions IS NOT NULL AND extras IS NOT NULL;
--Ans. ONly 1 pizza delievered that had both exclusions and extras
/*Explanation:Join customer and runner table in order to avoid cancelled orders which we specify in the where clause.
Also provide 2 more conditions in WHERE clause that say exclusions and extras must not be null. 
Use AND logical operator as all the conditions should be met.*/

--9.What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day, COUNT(order_id) AS pizza_count
FROM customer_orders2
GROUP BY hour_of_day
ORDER BY hour_of_day;
/*ANS:Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm),21 (9:00 pm) and 23 (11:00 pm)
Lowest volume of pizza ordered is at 11 (11:00 am) and 19 (7:00 pm).*/
--Queries: Extract(hour from [col])/ can use DATEPART(HOUR,[col]) in other SQL environments.

--10. What was the volume of orders for each day of the week?
SELECT to_char(order_time ,'Day') AS day_of_week, COUNT(order_id) AS pizza_count
FROM customer_orders2
GROUP BY day_of_week;
--Ans: Wed5, Thu3, Fri1, Sat5. Wednesdays & Saturdays are surely busy days of the week for the pizza place.
--Queries: to_char(order_time,'Day')/can use dayname(order_time) in other SQL environments.

