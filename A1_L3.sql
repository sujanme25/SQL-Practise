--Q11 — Find employees whose salary is greater than the overall average salary.
SELECT 
	salary AS 'SALARY',
	employee_name AS 'NAME'
FROM employees
WHERE
	salary> (SELECT 
	AVG(salary)FROM employees);

--Q12 — Find employees whose salary is greater than their department's average salary. This is harder.
--Think: Employee salary fi compare with average salary of that employee's department.
SELECT 
	E.employee_name AS 'Employee_NAME',
	E.salary AS 'SALARY',
	E.department AS 'Department'
FROM 
	employees AS E
WHERE
	salary> (SELECT 
	AVG(salary)FROM employees as E2
	WHERE E2.department=E.department);	

--Q13 — Find the third-highest salary. Try solving it without manually specifying a salary value.
SELECT 
	E.employee_name AS 'Employee_NAME',
	E.salary AS 'SALARY'
FROM 
	employees AS E
order by salary desc
limit 1 offset 2;

--OR
SELECT
	employee_name,
	salary
FROM (
	SELECT
	employee_name, 
	salary,
	DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees) t
WHERE salary_rank = 3;

