--Q26
SELECT
department,
COUNT(*) AS employee_count
FROM employees
GROUP BY department;
 
--Q27
SELECT
department,
SUM(salary) AS total_salary
FROM employees
GROUP BY department;
 
--Q28
SELECT
department,
COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 4;
 
--Q29
SELECT
employee_id,
employee_name,
department,
salary
FROM employees
WHERE manager_id IS NULL;
 
--Q30
SELECT
m.employee_id AS manager_id,
m.employee_name AS manager_name,
COUNT(e.employee_id) AS direct_reports
FROM employees m
JOIN employees e
ON e.manager_id = m.employee_id
GROUP BY
m.employee_id,
m.employee_name;
 
--Q31
SELECT
m.employee_id,
m.employee_name,
COUNT(e.employee_id) AS direct_reports
FROM employees m
JOIN employees e
ON e.manager_id = m.employee_id
GROUP BY
m.employee_id,
m.employee_name
HAVING COUNT(e.employee_id) >= 3;
 
--Q32
SELECT
department,
MIN(salary) AS minimum_salary,
MAX(salary) AS maximum_salary
FROM employees
GROUP BY department;
 
--Q33
SELECT
department,
MAX(salary) - MIN(salary) AS salary_range
FROM employees
GROUP BY department;
 
--Q34
SELECT
department,
COUNT(*) AS employee_count,
SUM(salary) AS total_salary,
AVG(salary) AS average_salary
FROM employees
GROUP BY department;
 
--Q35
SELECT
department,
AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) >
(
SELECT AVG(salary)
FROM employees
);
 
--Q36
SELECT
e.employee_name AS employee,
e.salary AS employee_salary,
m.employee_name AS manager,
m.salary AS manager_salary
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id;
 
--Q37
SELECT
e.employee_name AS employee,
m.employee_name AS manager,
e.salary - m.salary AS salary_difference
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id;
 
--Q38
SELECT
e.employee_name,
e.salary,
m.employee_name AS manager,
m.salary AS manager_salary
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id
WHERE e.salary >= (m.salary * 0.9);
 
--Q39
SELECT
employee_name,
department,
salary,
CASE
WHEN salary >= 75000 THEN 'High'
WHEN salary >= 55000 THEN 'Medium'
ELSE 'Low'
END AS salary_band
FROM employees;
 
--Q40
SELECT
employee_name,
department,
salary,
RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS salary_rank
FROM employees;
 
--Q41
WITH ranked_salary AS (
SELECT
employee_name,
department,
salary,
DENSE_RANK() OVER (
PARTITION BY department
ORDER BY salary
) AS salary_rank
FROM employees
)
SELECT *
FROM ranked_salary
WHERE salary_rank = 1;
 
--Q42
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
SELECT *
FROM ranked_salary
WHERE salary_rank <= 3;
 
--Q43
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
department,
employee_name,
salary
FROM ranked_salary
WHERE salary_rank = 1;
 
--Q44
SELECT
employee_name,
department,
salary,
LAG(salary) OVER (
PARTITION BY department
ORDER BY salary DESC
) AS previous_salary
FROM employees;
 
--Q45
SELECT
employee_name,
department,
salary,
SUM(salary) OVER (
PARTITION BY department
ORDER BY salary DESC
) AS running_salary_total
FROM employees;
 
--Q46
SELECT
c.customer_id,
c.customer_name,
COUNT(o.order_id) AS total_orders,
COALESCE(SUM(o.amount),0) AS total_spending
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name;
 
--Q47
WITH customer_orders AS (
SELECT
c.customer_id,
c.customer_name,
COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
)
SELECT
customer_id,
customer_name,
order_count,
CASE
WHEN order_count >= 3 THEN 'Frequent'
WHEN order_count >= 1 THEN 'Occasional'
ELSE 'No Orders'
END AS customer_type
FROM customer_orders;
 
--Q48
SELECT
c.customer_id,
c.customer_name,
COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
HAVING COUNT(o.order_id) >= 3;
 
--Q49
SELECT
c.customer_id,
c.customer_name,
COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
HAVING COUNT(o.order_id) = 1;
 
--Q50
SELECT
c.customer_id,
c.customer_name,
AVG(o.amount) AS average_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name;