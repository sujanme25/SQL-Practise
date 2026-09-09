--Q6 — Find the number of orders placed by each customer. Include customers who placed zero orders. Hint: Think carefully about which JOIN you need.
SELECT 
	C.customer_id,
	COUNT(O.order_id) as 'TOTAL ORDERS'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
	GROUP BY C.customer_id;

--Q7 — Find customers who placed more than 2 orders.
SELECT 
	C.customer_id,
	C.customer_name AS 'CUSTOMER',
	COUNT(O.order_id) as 'TOTAL_ORDERS'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
GROUP BY C.customer_id
HAVING TOTAL_ORDERS>=2;

--Q8 — Find the total amount spent by each customer. Include customers who have placed no orders.
SELECT 
	C.customer_id,
	C.customer_name AS 'CUSTOMER',
	O.amount as 'AMOUNT'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
GROUP BY C.customer_id;


--Q9 — Find the customer who spent the highest total amount.
SELECT 
	C.customer_id,
	C.customer_name AS 'CUSTOMER',
	SUM(O.amount) as 'TOTAL_AMOUNT'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
GROUP BY C.customer_id
ORDER BY TOTAL_AMOUNT DESC
LIMIT 1;

--Q10 — Find customers who never placed an order. This is an extremely common assessment pattern.
SELECT 
	C.customer_id,
	C.customer_name AS 'CUSTOMER',
	SUM(O.amount) as 'TOTAL_AMOUNT'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
GROUP BY C.customer_id
ORDER BY TOTAL_AMOUNT ASC
LIMIT 1;

--OR
SELECT 
	C.customer_id,
	C.customer_name AS 'CUSTOMER',
	SUM(O.amount) as 'TOTAL_AMOUNT'
FROM 
	orders AS O
	
RIGHT JOIN Customers AS C
	ON O.customer_id=C.customer_id
GROUP BY
	C.customer_id,
	C.customer_name
HAVING TOTAL_AMOUNT is NULL;
