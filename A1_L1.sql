--Q1 — Find all employees whose salary is greater than n70,000.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary>70000;
--Q11 — Find all employees whose salary is less than n70,000.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary<70000;

--Q12 — Find all employees whose salary is between 50000 to 70000.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary BETWEEN 50000 AND 70000;
	
--Q13 — Find all employees whose salary is between 30000 to 50000.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary BETWEEN 30000 AND 50000;
	
--Q14 — Find AVG Salary.
SELECT 
	AVG(salary) AS 'AVG SALARY'
FROM employees;

--Q15 — Find all employees whose salary is less than avg salary.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary> (SELECT 
	AVG(salary)FROM employees);

--Q16 — Find all employees whose salary is less than avg salary.	
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary< (SELECT 
	AVG(salary)FROM employees);
--Q2 — Find the highest salary from the employees table.
SELECT 
	employee_name AS 'NAME',
	MAX(salary) AS 'MAX SALARY'
FROM employees;

--Q3 — Find the second-highest salary. Don't simply use LIMIT 1 OFFSET 1. Try solving it using a subquery.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary< (SELECT 
	MAX(salary)FROM employees);

--Q4 — Find the average salary of employees in each department.
SELECT 
	department AS 'DEPT',
	AVG(salary) AS 'AVG'
FROM employees
GROUP BY department;

--Q5 — Find departments where the average salary is greater than n60,000.
SELECT 
	department AS 'DEPT',
	AVG(salary) AS 'AVG'
FROM employees
GROUP BY department
HAVING AVG(salary)>60000;
