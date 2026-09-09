-- https://github.com/Imranshariff42/SQL-assessment-practise/blob/main/assessment_questions.md

--Q18 — Top-selling product — Find the top-selling product in each category based on total sales amount.
--Think about: JOIN fi GROUP BY fi SUM fi RANK / ROW_NUMBER fi PARTITION BY.
SELECT
product_id,
product_name,
category,
price,
total_sales
FROM (
SELECT
P.product_id,
P.product_name,
P.category,
P.price,
SUM(O.amount) AS total_sales,
RANK() OVER (
PARTITION BY P.category
ORDER BY SUM(O.amount) DESC
) AS sales_rank
FROM products AS P
JOIN orders AS O
ON O.product_id = P.product_id
GROUP BY
P.product_id,
P.product_name,
P.category,
P.price
) ranked_products
WHERE sales_rank = 1;

--OR

WITH CTE AS (
SELECT
p.product_name,
p.category,
SUM(o.amount) AS total_sale,
ROW_NUMBER() OVER (
 p.category
ORDER BY SUM(o.amount) DESC --Not ORDER BY we have used PARTITION BY because we want to rank inside each category.
) AS top_seller
FROM orders AS o
RIGHT JOIN products AS p
ON o.product_id = p.product_id
GROUP BY p.product_name, p.category
)
SELECT *
FROM CTE
WHERE top_seller = 1;

--Q19 — Customer spending — Find customers whose total spending is greater than the average customer spending.
--Think: customer fi total spending fi average of those totals.
SELECT
	c.customer_id,
	c.customer_name,
	SUM(o.amount) AS 'total_spend'
FROM customers AS c
JOIN orders as o
	ON o.customer_id = c.customer_id
GROUP BY c.customer_id,c.customer_name
Having SUM(o.amount)> (SELECT
	AVG(o.amount) AS 'AVG_spend'
FROM orders as o
GROUP BY customer_id);

--OR
WITH total_amount AS (
SELECT
c.customer_id,
c.customer_name,
SUM(o.amount) AS total_spending
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
GROUP BY
c.customer_id,
c.customer_name
)
SELECT *
FROM total_amount
WHERE total_spending >
(
SELECT AVG(total_spending)
FROM total_amount
);
--Q20 — Manager comparison — Find employees whose salary is greater than their manager's salary. You'll need a SELF JOIN.
SELECT e1.employee_name as employe,e1.employee_id as emp_id,
		e2.employee_name as manager, e2.employee_id as mag_id
FROM employees as e1
JOIN employees as e2
on e1.manager_id=e2.employee_id
where e1.salary > e2.salary;

--CHECKING---
SELECT
	e1.employee_name,
	e1.salary,
	e2.employee_name AS manager,
	e2.salary AS manager_salary
FROM employees e1
JOIN employees e2
ON e1.manager_id = e2.employee_id; --No employee have salary greater than manager.

--Q21 — No orders — Find customers who haven't placed any orders. Solve it two ways:
-- LEFT JOIN
-- NOT EXISTS
SELECT
	c.customer_id,
	c.customer_name,
	o.customer_id,
	o.amount
FROM customers AS c
LEFT JOIN orders as o
	ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;

--OR
SELECT
customer_id,
customer_name
FROM customers
WHERE customer_id NOT IN (
SELECT customer_id
FROM orders
);

--OR

SELECT
c.customer_id,
c.customer_name
FROM customers AS c
WHERE NOT EXISTS (
SELECT 1
FROM orders AS o
WHERE o.customer_id = c.customer_id
);

--Q22 — Category revenue — Find total revenue for each product category. Expected: category | total_revenue
SELECT
	P.category,
	SUM(o.amount) AS 'total_revenue'
FROM products AS P
JOIN orders AS o
	ON o.product_id=P.product_id
GROUP BY P.category;

--Using a Window Function
WITH category_revenue AS (
SELECT
p.category,
SUM(o.amount) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category
)
SELECT
category,
total_revenue,
RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_revenue;


--Highest revenue category

WITH category_revenue AS (
SELECT
p.category,
SUM(o.amount) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category
)
SELECT *
FROM category_revenue
WHERE total_revenue = (
SELECT MAX(total_revenue)
FROM category_revenue
)
--Show only categories whose revenue is greater than 10,000
SELECT
	p.category,
	SUM(o.amount) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category
HAVING SUM(o.amount) > 10000;

--Q23 — Monthly sales — Find total sales for each month. Expected: month | total_sales
--You will need to extract the month from order_date.
SELECT
	strftime('%m', order_date) AS 'month',
	SUM(amount) AS 'total_sales'
FROM orders
GROUP BY month;

--OR

WITH sales_month AS (
SELECT
amount,
strftime('%m', order_date) AS month_num
FROM orders
)
SELECT
CASE month_num
WHEN '01' THEN 'January'
WHEN '02' THEN 'February'
WHEN '03' THEN 'March'
WHEN '04' THEN 'April'
WHEN '05' THEN 'May'
WHEN '06' THEN 'June'
WHEN '07' THEN 'July'
WHEN '08' THEN 'August'
WHEN '09' THEN 'September'
WHEN '10' THEN 'October'
WHEN '11' THEN 'November'
WHEN '12' THEN 'December'
END AS month_name,
SUM(amount) AS total_sales
FROM sales_month
GROUP BY month_num
ORDER BY month_num;

--Q24 — Duplicate salaries — Find the salaries that occur more than once. Expected: salary
--The data contains 75000 more than once.
--Think: GROUP BY + HAVING COUNT(*) > 1.
SELECT
	salary
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1;

--OR
SELECT
employee_name,
salary,
COUNT(*) OVER (PARTITION BY salary) AS salary_count
FROM employees;

--Q25 — Second-highest salary per department — Find the second-highest salary in each department.
WITH ranked_salary AS (
SELECT
employee_name,
department,
salary,
DENSE_RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS salary_rank
FROM employees
)
SELECT
employee_name,
department,
salary
FROM ranked_salary
WHERE salary_rank = 2;

--OR
SELECT
employee_name,
department,
salary
FROM employees e
WHERE salary =
(
SELECT MAX(salary)
FROM employees
WHERE department = e.department
AND salary <
(
SELECT MAX(salary)
FROM employees
WHERE department = e.department
)
);
FROM employees
GROUP BY salary