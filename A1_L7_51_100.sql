--Q51 - Find customers whose average order value is greater than the overall average order amount.
WITH customer_average AS (
    SELECT
        c.customer_id,
        c.customer_name,
        AVG(o.amount) AS average_order_value
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(average_order_value, 2) AS average_order_value
FROM customer_average
WHERE average_order_value > (
    SELECT AVG(amount)
    FROM orders
)
ORDER BY average_order_value DESC;

--Q52 - Find the highest-value individual order placed by each customer.
WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.amount,
        o.order_date,
        RANK() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.amount DESC
        ) AS order_rank
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id,
    amount,
    order_date
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;

--Q53 - Find the lowest-value individual order placed by each customer.
WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.amount,
        o.order_date,
        RANK() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.amount ASC
        ) AS order_rank
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id,
    amount,
    order_date
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;

--Q54 - Find the first order placed by each customer.
WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.amount,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date ASC, o.order_id ASC
        ) AS order_rank
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id,
    amount,
    order_date
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;

--Q55 - Find the most recent order placed by each customer.
WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.amount,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS order_rank
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id,
    amount,
    order_date
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;

--Q56 - Find the first and last order date for each customer.
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

--Q57 - Calculate the number of days between each customer's first and last orders.
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    CAST(
        julianday(MAX(o.order_date)) - julianday(MIN(o.order_date))
        AS INTEGER
    ) AS activity_days
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY activity_days DESC;

--Q58 - Find customers who ordered more than one distinct product.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.product_id) AS distinct_products
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_id) > 1
ORDER BY distinct_products DESC;

--Q59 - Find customers who purchased products from more than one category.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT p.category) AS distinct_categories
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY distinct_categories DESC;

--Q60 - Find customers who purchased at least one Electronics product using EXISTS.
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN products AS p
        ON p.product_id = o.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Electronics'
)
ORDER BY c.customer_name;

--Q61 - Find customers who never purchased a Furniture product using NOT EXISTS.
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN products AS p
        ON p.product_id = o.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Furniture'
)
ORDER BY c.customer_name;

--Q62 - Find customers who purchased products from both Electronics and Furniture.
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT CASE
            WHEN p.category IN ('Electronics', 'Furniture')
            THEN p.category
       END) = 2
ORDER BY c.customer_name;

--Q63 - Find customers who purchased Electronics but never purchased Furniture.
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN products AS p
        ON p.product_id = o.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Electronics'
)
AND NOT EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN products AS p
        ON p.product_id = o.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Furniture'
)
ORDER BY c.customer_name;

--Q64 - Rank customers based on total spending from highest to lowest.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(o.amount), 0) AS total_spending
    FROM customers AS c
    LEFT JOIN orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank
FROM customer_spending
ORDER BY spending_rank, customer_name;

--Q65 - Find the three customers with the highest total spending.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.amount) AS total_spending
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        total_spending,
        DENSE_RANK() OVER (
            ORDER BY total_spending DESC
        ) AS spending_rank
    FROM customer_spending
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    spending_rank
FROM ranked_customers
WHERE spending_rank <= 3
ORDER BY spending_rank, customer_name;

--Q66 - Find order count and total revenue for each product, including products with no orders.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_revenue
FROM products AS p
LEFT JOIN orders AS o
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC;

--Q67 - Find products that have never been ordered.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM products AS p
LEFT JOIN orders AS o
    ON o.product_id = p.product_id
WHERE o.order_id IS NULL
ORDER BY p.product_name;

--Q68 - Find products that have been ordered at least three times.
SELECT
    p.product_id,
    p.product_name,
    COUNT(o.order_id) AS order_count
FROM products AS p
JOIN orders AS o
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(o.order_id) >= 3
ORDER BY order_count DESC;

--Q69 - Calculate the average order amount associated with each product.
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(o.amount), 2) AS average_order_amount
FROM products AS p
JOIN orders AS o
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_order_amount DESC;

--Q70 - Rank all products based on total revenue.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank, product_name;

--Q71 - Rank each product by total revenue within its category.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    RANK() OVER (
        PARTITION BY category
        ORDER BY total_revenue DESC
    ) AS category_rank
FROM product_revenue
ORDER BY category, category_rank, product_name;

--Q72 - Find the two highest-revenue products in each category.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT *
FROM ranked_products
WHERE revenue_rank <= 2
ORDER BY category, revenue_rank, product_name;

--Q73 - Find the lowest-revenue product in each category.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue ASC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue
FROM ranked_products
WHERE revenue_rank = 1
ORDER BY category, product_name;

--Q74 - Find products whose total revenue is greater than the average product revenue.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue
FROM product_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM product_revenue
)
ORDER BY total_revenue DESC;

--Q75 - Calculate each product's percentage contribution to total revenue.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    ROUND(
        total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER (), 0),
        2
    ) AS revenue_percentage
FROM product_revenue
ORDER BY total_revenue DESC;

--Q76 - Find the number of products in each category.
SELECT
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;

--Q77 - Calculate the average product price for each category.
SELECT
    category,
    ROUND(AVG(price), 2) AS average_price
FROM products
GROUP BY category
ORDER BY average_price DESC;

--Q78 - Find the minimum and maximum product price in each category.
SELECT
    category,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM products
GROUP BY category;

--Q79 - Calculate order count, total revenue and average order amount for each category.
SELECT
    p.category,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_revenue,
    ROUND(AVG(o.amount), 2) AS average_order_amount
FROM products AS p
LEFT JOIN orders AS o
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

--Q80 - Find the category generating the highest total revenue.
WITH category_revenue AS (
    SELECT
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    category,
    total_revenue
FROM category_revenue
WHERE total_revenue = (
    SELECT MAX(total_revenue)
    FROM category_revenue
);

--Q81 - Rank product categories according to total revenue.
WITH category_revenue AS (
    SELECT
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    category,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM category_revenue
ORDER BY revenue_rank;

--Q82 - Find categories whose total revenue is greater than average category revenue.
WITH category_revenue AS (
    SELECT
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    category,
    total_revenue
FROM category_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM category_revenue
)
ORDER BY total_revenue DESC;

--Q83 - Calculate each category's percentage contribution to overall revenue.
WITH category_revenue AS (
    SELECT
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    category,
    total_revenue,
    ROUND(
        total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER (), 0),
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY total_revenue DESC;

--Q84 - Find the most expensive product in each category.
WITH ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        price,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS price_rank
    FROM products
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM ranked_products
WHERE price_rank = 1
ORDER BY category, product_name;

--Q85 - Find the product with the second-highest distinct price in each category.
WITH ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        price,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS price_rank
    FROM products
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM ranked_products
WHERE price_rank = 2
ORDER BY category, product_name;

--Q86 - Find total order count and total sales for each year-month.
SELECT
    strftime('%Y-%m', order_date) AS sales_month,
    COUNT(order_id) AS order_count,
    SUM(amount) AS total_sales
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY sales_month;

--Q87 - Calculate the average order amount for each year-month.
SELECT
    strftime('%Y-%m', order_date) AS sales_month,
    ROUND(AVG(amount), 2) AS average_order_value
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY sales_month;

--Q88 - Find the highest-value order in each month.
WITH ranked_orders AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        amount,
        order_date,
        strftime('%Y-%m', order_date) AS sales_month,
        RANK() OVER (
            PARTITION BY strftime('%Y-%m', order_date)
            ORDER BY amount DESC
        ) AS amount_rank
    FROM orders
)
SELECT
    sales_month,
    order_id,
    customer_id,
    product_id,
    amount,
    order_date
FROM ranked_orders
WHERE amount_rank = 1
ORDER BY sales_month;

--Q89 - Find the lowest-value order in each month.
WITH ranked_orders AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        amount,
        order_date,
        strftime('%Y-%m', order_date) AS sales_month,
        RANK() OVER (
            PARTITION BY strftime('%Y-%m', order_date)
            ORDER BY amount ASC
        ) AS amount_rank
    FROM orders
)
SELECT
    sales_month,
    order_id,
    customer_id,
    product_id,
    amount,
    order_date
FROM ranked_orders
WHERE amount_rank = 1
ORDER BY sales_month;

--Q90 - Rank months based on total sales from highest to lowest.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    sales_month,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM monthly_sales
ORDER BY sales_rank, sales_month;

--Q91 - Calculate cumulative sales across successive months.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    sales_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales
FROM monthly_sales
ORDER BY sales_month;

--Q92 - Show each month's sales together with the previous month's sales.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    sales_month,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY sales_month
    ) AS previous_month_sales
FROM monthly_sales
ORDER BY sales_month;

--Q93 - Calculate the numerical sales difference from the previous month.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
),
monthly_comparison AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    total_sales - previous_month_sales AS sales_change
FROM monthly_comparison
ORDER BY sales_month;

--Q94 - Calculate month-over-month sales growth percentage.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
),
monthly_comparison AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    ROUND(
        (total_sales - previous_month_sales) * 100.0 /
        NULLIF(previous_month_sales, 0),
        2
    ) AS growth_percentage
FROM monthly_comparison
ORDER BY sales_month;

--Q95 - Find the month with the highest total sales.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    sales_month,
    total_sales
FROM monthly_sales
WHERE total_sales = (
    SELECT MAX(total_sales)
    FROM monthly_sales
);

--Q96 - Find the most frequently ordered product category for each customer.
WITH customer_category_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        p.category,
        COUNT(*) AS category_order_count
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY c.customer_id, c.customer_name, p.category
),
ranked_categories AS (
    SELECT
        customer_id,
        customer_name,
        category,
        category_order_count,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY category_order_count DESC
        ) AS category_rank
    FROM customer_category_orders
)
SELECT
    customer_id,
    customer_name,
    category,
    category_order_count
FROM ranked_categories
WHERE category_rank = 1
ORDER BY customer_id, category;

--Q97 - Find the category in which each customer spent the most.
WITH customer_category_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        p.category,
        SUM(o.amount) AS category_spending
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY c.customer_id, c.customer_name, p.category
),
ranked_categories AS (
    SELECT
        customer_id,
        customer_name,
        category,
        category_spending,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY category_spending DESC
        ) AS category_rank
    FROM customer_category_spending
)
SELECT
    customer_id,
    customer_name,
    category,
    category_spending
FROM ranked_categories
WHERE category_rank = 1
ORDER BY customer_id, category;

--Q98 - Identify customers whose cumulative contribution falls within the first 50% of revenue.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.amount) AS total_spending
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
revenue_contribution AS (
    SELECT
        customer_id,
        customer_name,
        total_spending,
        SUM(total_spending) OVER (
            ORDER BY total_spending DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(total_spending) OVER () AS overall_revenue
    FROM customer_spending
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    ROUND(cumulative_revenue * 100.0 / overall_revenue, 2)
        AS cumulative_revenue_percentage
FROM revenue_contribution
WHERE cumulative_revenue * 100.0 / overall_revenue <= 50
ORDER BY total_spending DESC, customer_id;

--Q99 - Show each employee's salary, department average, difference from average and department salary rank.
WITH employee_analysis AS (
    SELECT
        employee_id,
        employee_name,
        department,
        salary,
        AVG(salary) OVER (
            PARTITION BY department
        ) AS department_average_salary,
        DENSE_RANK() OVER (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS department_salary_rank
    FROM employees
)
SELECT
    employee_id,
    employee_name,
    department,
    salary,
    ROUND(department_average_salary, 2) AS department_average_salary,
    ROUND(salary - department_average_salary, 2)
        AS difference_from_department_average,
    department_salary_rank
FROM employee_analysis
ORDER BY department, department_salary_rank, employee_name;

--Q100 - Create a comprehensive customer analytics report.
WITH customer_aggregates AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        COUNT(o.order_id) AS total_orders,
        COUNT(DISTINCT o.product_id) AS distinct_products,
        COUNT(DISTINCT p.category) AS distinct_categories,
        COALESCE(SUM(o.amount), 0) AS total_spending,
        COALESCE(AVG(o.amount), 0) AS average_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM customers AS c
    LEFT JOIN orders AS o
        ON o.customer_id = c.customer_id
    LEFT JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY c.customer_id, c.customer_name, c.city
),
latest_orders AS (
    SELECT
        customer_id,
        amount AS latest_order_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS order_rank
    FROM orders
),
customer_report AS (
    SELECT
        ca.customer_id,
        ca.customer_name,
        ca.city,
        ca.total_orders,
        ca.distinct_products,
        ca.distinct_categories,
        ca.total_spending,
        ca.average_order_value,
        ca.first_order_date,
        ca.last_order_date,
        lo.latest_order_amount
    FROM customer_aggregates AS ca
    LEFT JOIN latest_orders AS lo
        ON lo.customer_id = ca.customer_id
       AND lo.order_rank = 1
)
SELECT
    customer_id,
    customer_name,
    city,
    total_orders,
    distinct_products,
    distinct_categories,
    total_spending,
    ROUND(average_order_value, 2) AS average_order_value,
    first_order_date,
    last_order_date,
    latest_order_amount,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank,
    ROUND(
        total_spending * 100.0 /
        NULLIF(SUM(total_spending) OVER (), 0),
        2
    ) AS revenue_contribution_percentage
FROM customer_report
ORDER BY spending_rank, customer_name;
