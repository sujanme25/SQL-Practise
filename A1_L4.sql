--Q14 — Rank employees based on salary from highest to lowest. Output: employee_name | salary | salary_rank. Use RANK().
SELECT
	employee_name,
	salary,
	DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

--OR
SELECT
	employee_name,
	salary,
	RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

--OR
SELECT
	employee_name,
	salary,
	ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

--Q15 — Find the highest-paid employee in each department. Try using RANK() and PARTITION BY.
SELECT
	employee_name,
	salary,
	department
FROM (SELECT 
	employee_name,
	salary, 
	department,
	ROW_NUMBER() OVER (
		PARTITION BY department
			ORDER BY salary DESC
		) AS salary_rank
FROM employees)
WHERE salary_rank = 1;

--Q16 — Find the top 2 highest-paid employees in each department. This is a very good assessment question.
SELECT
	employee_name,
	salary,
	department
FROM (SELECT 
	employee_name,
	salary, 
	department,
	ROW_NUMBER() OVER (
		PARTITION BY department
			ORDER BY salary DESC
		) AS salary_rank
FROM employees)
WHERE salary_rank = 1 OR salary_rank = 2;

--OR
SELECT
	employee_name,
	salary,
	department
FROM (
	SELECT
	employee_name,
	salary,
	department,
DENSE_RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS salary_rank
FROM employees
) ranked_employees
WHERE salary_rank <= 2;
--Q17 — Find employees who have the same salary. Look at the data carefully — there is a duplicate salary.
SELECT
	e1.employee_name,
	e1.salary,
	e1.department
FROM employees e1
JOIN employees e2
ON e1.salary = e2.salary
AND e1.employee_id <> e2.employee_id;

--OR
SELECT
	employee_name,
	salary,
	department
FROM employees
WHERE salary IN (
SELECT salary
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1
);
