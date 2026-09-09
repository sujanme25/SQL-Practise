--Q101 - Find employees whose salary is above their department average but below the highest salary in their department.
--
-- Step 1: Calculate each department's average and maximum salary with window functions.
-- Step 2: Keep employee detail without collapsing rows through GROUP BY.
-- Step 3: Filter employees above the department average but below the department maximum.
--

WITH employee_salary_analysis AS (
    SELECT
        employee_id,
        employee_name,
        department,
        salary,
        AVG(salary) OVER (
            PARTITION BY department
        ) AS department_average,
        MAX(salary) OVER (
            PARTITION BY department
        ) AS department_maximum
    FROM employees
)
SELECT
    employee_id,
    employee_name,
    department,
    salary,
    ROUND(department_average, 2) AS department_average,
    department_maximum
FROM employee_salary_analysis
WHERE salary > department_average
  AND salary < department_maximum
ORDER BY department, salary DESC;


--Q102 - Find the median salary in each department.
--
-- Step 1: Sort salaries within each department and assign a row number.
-- Step 2: Count employees in each department to locate the middle row or rows.
-- Step 3: Average the middle value(s), which handles both odd and even department sizes.
--

WITH ranked_salaries AS (
    SELECT
        department,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department
            ORDER BY salary
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY department
        ) AS employee_count
    FROM employees
)
SELECT
    department,
    ROUND(AVG(salary), 2) AS median_salary
FROM ranked_salaries
WHERE row_num IN (
    CAST((employee_count + 1) / 2 AS INTEGER),
    CAST((employee_count + 2) / 2 AS INTEGER)
)
GROUP BY department
ORDER BY department;


--Q103 - Find each manager's direct and indirect reports using a recursive CTE.
--
-- Step 1: The anchor query finds every direct employee-manager relationship.
-- Step 2: The recursive query follows each report downward through additional hierarchy levels.
-- Step 3: Return every direct and indirect report with its hierarchy depth.
--

WITH RECURSIVE organisation AS (
    SELECT
        manager.employee_id AS manager_id,
        manager.employee_name AS manager_name,
        employee.employee_id AS report_id,
        employee.employee_name AS report_name,
        1 AS hierarchy_level
    FROM employees AS manager
    JOIN employees AS employee
        ON employee.manager_id = manager.employee_id

    UNION ALL

    SELECT
        organisation.manager_id,
        organisation.manager_name,
        employee.employee_id,
        employee.employee_name,
        organisation.hierarchy_level + 1
    FROM organisation
    JOIN employees AS employee
        ON employee.manager_id = organisation.report_id
)
SELECT
    manager_id,
    manager_name,
    report_id,
    report_name,
    hierarchy_level
FROM organisation
ORDER BY manager_id, hierarchy_level, report_id;


--Q104 - Find the total number of direct and indirect reports for each manager.
--
-- Step 1: Build all direct manager-report relationships in the anchor query.
-- Step 2: Recursively expand each manager's reporting tree.
-- Step 3: Count distinct descendants for each manager to avoid duplicate report counts.
--

WITH RECURSIVE organisation AS (
    SELECT
        manager.employee_id AS manager_id,
        manager.employee_name AS manager_name,
        employee.employee_id AS report_id
    FROM employees AS manager
    JOIN employees AS employee
        ON employee.manager_id = manager.employee_id

    UNION ALL

    SELECT
        organisation.manager_id,
        organisation.manager_name,
        employee.employee_id
    FROM organisation
    JOIN employees AS employee
        ON employee.manager_id = organisation.report_id
)
SELECT
    manager_id,
    manager_name,
    COUNT(DISTINCT report_id) AS total_reports
FROM organisation
GROUP BY manager_id, manager_name
ORDER BY total_reports DESC, manager_name;


--Q105 - Find the salary percentile of every employee within their department.
--
-- Step 1: Partition employees by department.
-- Step 2: Order salaries from low to high within each department.
-- Step 3: Use PERCENT_RANK() and convert the result to a percentage.
--

SELECT
    employee_id,
    employee_name,
    department,
    salary,
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY department
            ORDER BY salary
        ) * 100,
        2
    ) AS salary_percentile
FROM employees
ORDER BY department, salary DESC;


--Q106 - Divide employees in each department into three salary groups using NTILE().
--
-- Step 1: Partition employees by department.
-- Step 2: Sort salaries from highest to lowest.
-- Step 3: Use NTILE(3) to distribute employees into three salary groups.
--

SELECT
    employee_id,
    employee_name,
    department,
    salary,
    NTILE(3) OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_group
FROM employees
ORDER BY department, salary_group, salary DESC;


--Q107 - Find customers whose spending increased with every successive order.
--
-- Step 1: Use LAG() to retrieve each customer's previous order amount.
-- Step 2: Count orders that did not increase compared with the preceding order.
-- Step 3: Return customers with multiple orders and zero non-increasing movements.
--

WITH customer_order_sequence AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        amount,
        LAG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_amount
    FROM orders
),
customer_movements AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(
            CASE
                WHEN previous_amount IS NOT NULL
                 AND amount <= previous_amount
                THEN 1
                ELSE 0
            END
        ) AS non_increasing_orders
    FROM customer_order_sequence
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cm.total_orders
FROM customer_movements AS cm
JOIN customers AS c
    ON c.customer_id = cm.customer_id
WHERE cm.total_orders > 1
  AND cm.non_increasing_orders = 0
ORDER BY c.customer_name;


--Q108 - Find the longest gap in days between consecutive orders for each customer.
--
-- Step 1: Use LAG() to retrieve each customer's previous order date.
-- Step 2: Calculate the day gap between consecutive orders with julianday().
-- Step 3: Rank gaps from largest to smallest for each customer.
-- Step 4: Return all longest-gap ties.
--

WITH order_sequence AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM orders
),
calculated_gaps AS (
    SELECT
        customer_id,
        previous_order_date,
        order_date,
        CAST(
            julianday(order_date) -
            julianday(previous_order_date)
            AS INTEGER
        ) AS gap_days
    FROM order_sequence
    WHERE previous_order_date IS NOT NULL
),
ranked_gaps AS (
    SELECT
        customer_id,
        previous_order_date,
        order_date,
        gap_days,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY gap_days DESC
        ) AS gap_rank
    FROM calculated_gaps
)
SELECT
    c.customer_id,
    c.customer_name,
    rg.previous_order_date,
    rg.order_date,
    rg.gap_days AS longest_gap_days
FROM ranked_gaps AS rg
JOIN customers AS c
    ON c.customer_id = rg.customer_id
WHERE rg.gap_rank = 1
ORDER BY longest_gap_days DESC, c.customer_name;


--Q109 - Find customers who purchased every product category available in the products table.
--
-- Step 1: Join customers to their purchased product categories.
-- Step 2: Count distinct categories purchased by each customer.
-- Step 3: Compare that count with the total number of categories available.
--

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT p.category) = (
    SELECT COUNT(DISTINCT category)
    FROM products
)
ORDER BY c.customer_name;


--Q110 - Find customers who purchased every product in the Electronics category.
--
-- Step 1: Start with each customer.
-- Step 2: Search for any Electronics product that the customer has not purchased.
-- Step 3: Keep customers for whom no missing Electronics product exists.
--

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM products AS p
    WHERE p.category = 'Electronics'
      AND NOT EXISTS (
          SELECT 1
          FROM orders AS o
          WHERE o.customer_id = c.customer_id
            AND o.product_id = p.product_id
      )
)
ORDER BY c.customer_name;


--Q111 - Find each customer's longest streak of consecutive months containing at least one order.
--
-- Step 1: Reduce orders to one row per customer and active month.
-- Step 2: Convert each month to a continuous numeric value and assign row numbers.
-- Step 3: Subtract row number from month number to identify consecutive-month islands.
-- Step 4: Measure each streak, rank it per customer and return the longest streak.
--

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        strftime('%Y-%m', order_date) AS order_month,
        CAST(strftime('%Y', order_date) AS INTEGER) * 12
        + CAST(strftime('%m', order_date) AS INTEGER)
            AS month_number
    FROM orders
),
numbered_months AS (
    SELECT
        customer_id,
        order_month,
        month_number,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY month_number
        ) AS sequence_number
    FROM customer_months
),
month_groups AS (
    SELECT
        customer_id,
        order_month,
        month_number - sequence_number AS streak_group
    FROM numbered_months
),
customer_streaks AS (
    SELECT
        customer_id,
        MIN(order_month) AS streak_start,
        MAX(order_month) AS streak_end,
        COUNT(*) AS streak_length
    FROM month_groups
    GROUP BY customer_id, streak_group
),
ranked_streaks AS (
    SELECT
        customer_id,
        streak_start,
        streak_end,
        streak_length,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY streak_length DESC
        ) AS streak_rank
    FROM customer_streaks
)
SELECT
    c.customer_id,
    c.customer_name,
    rs.streak_start,
    rs.streak_end,
    rs.streak_length
FROM ranked_streaks AS rs
JOIN customers AS c
    ON c.customer_id = rs.customer_id
WHERE rs.streak_rank = 1
ORDER BY rs.streak_length DESC, c.customer_name;


--Q112 - Find each customer's most frequently purchased product and return all tied products.
--
-- Step 1: Count how often each customer purchased each product.
-- Step 2: Rank product counts within each customer.
-- Step 3: Use RANK() so all tied favourite products are returned.
--

WITH customer_product_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        p.product_id,
        p.product_name,
        COUNT(*) AS purchase_count
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        customer_id,
        customer_name,
        product_id,
        product_name,
        purchase_count,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY purchase_count DESC
        ) AS product_rank
    FROM customer_product_orders
)
SELECT
    customer_id,
    customer_name,
    product_id,
    product_name,
    purchase_count
FROM ranked_products
WHERE product_rank = 1
ORDER BY customer_id, product_name;


--Q113 - Compare each product's revenue with its category's average product revenue.
--
-- Step 1: Calculate total revenue for every product, including zero-revenue products.
-- Step 2: Calculate average product revenue within each category with a window function.
-- Step 3: Show each product's difference from its category average.
--

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM products AS p
    LEFT JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
product_comparison AS (
    SELECT
        product_id,
        product_name,
        category,
        total_revenue,
        AVG(total_revenue) OVER (
            PARTITION BY category
        ) AS category_average_revenue
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    ROUND(category_average_revenue, 2)
        AS category_average_revenue,
    ROUND(
        total_revenue - category_average_revenue,
        2
    ) AS difference_from_category_average
FROM product_comparison
ORDER BY category, total_revenue DESC;


--Q114 - Find products required to reach the first 80% of revenue within each category.
--
-- Step 1: Calculate revenue for each sold product.
-- Step 2: Order products by revenue within category and compute cumulative revenue.
-- Step 3: Calculate total category revenue and the prior cumulative boundary.
-- Step 4: Include products needed to cross the 80 percent revenue threshold.
--

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(o.amount) AS total_revenue
    FROM products AS p
    JOIN orders AS o
        ON o.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
pareto_analysis AS (
    SELECT
        product_id,
        product_name,
        category,
        total_revenue,
        SUM(total_revenue) OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC, product_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(total_revenue) OVER (
            PARTITION BY category
        ) AS category_revenue
    FROM product_revenue
),
revenue_boundaries AS (
    SELECT
        *,
        cumulative_revenue - total_revenue
            AS previous_cumulative_revenue
    FROM pareto_analysis
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    ROUND(
        cumulative_revenue * 100.0 /
        NULLIF(category_revenue, 0),
        2
    ) AS cumulative_percentage
FROM revenue_boundaries
WHERE previous_cumulative_revenue
      < category_revenue * 0.80
ORDER BY category, total_revenue DESC;


--Q115 - Find months where sales were higher than both the previous and following months.
--
-- Step 1: Aggregate orders into monthly sales totals.
-- Step 2: Use LAG() and LEAD() to retrieve adjacent-month totals.
-- Step 3: Keep months higher than both their previous and following months.
--

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
        ) AS previous_month_sales,
        LEAD(total_sales) OVER (
            ORDER BY sales_month
        ) AS following_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    following_month_sales
FROM monthly_comparison
WHERE total_sales > previous_month_sales
  AND total_sales > following_month_sales
ORDER BY sales_month;


--Q116 - Generate a complete monthly calendar and include months with zero sales.
--
-- Step 1: Generate every month between the earliest and latest order using a recursive CTE.
-- Step 2: Aggregate the real orders by month.
-- Step 3: LEFT JOIN the calendar to sales so missing months remain visible.
-- Step 4: Replace missing counts and sales with zero.
--

WITH RECURSIVE month_calendar AS (
    SELECT
        date(MIN(order_date), 'start of month')
            AS month_start
    FROM orders

    UNION ALL

    SELECT
        date(month_start, '+1 month')
    FROM month_calendar
    WHERE month_start < (
        SELECT
            date(MAX(order_date), 'start of month')
        FROM orders
    )
),
monthly_sales AS (
    SELECT
        date(order_date, 'start of month')
            AS month_start,
        COUNT(*) AS order_count,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY date(order_date, 'start of month')
)
SELECT
    strftime('%Y-%m', mc.month_start) AS sales_month,
    COALESCE(ms.order_count, 0) AS order_count,
    COALESCE(ms.total_sales, 0) AS total_sales
FROM month_calendar AS mc
LEFT JOIN monthly_sales AS ms
    ON ms.month_start = mc.month_start
ORDER BY mc.month_start;


--Q117 - Calculate a three-month moving average of monthly sales.
--
-- Step 1: Generate a complete month calendar so missing months are represented.
-- Step 2: Aggregate sales and replace missing monthly totals with zero.
-- Step 3: Average the current month and two preceding rows to create a three-month moving average.
--

WITH RECURSIVE month_calendar AS (
    SELECT
        date(MIN(order_date), 'start of month')
            AS month_start
    FROM orders

    UNION ALL

    SELECT
        date(month_start, '+1 month')
    FROM month_calendar
    WHERE month_start < (
        SELECT
            date(MAX(order_date), 'start of month')
        FROM orders
    )
),
monthly_sales AS (
    SELECT
        date(order_date, 'start of month')
            AS month_start,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY date(order_date, 'start of month')
),
complete_monthly_sales AS (
    SELECT
        mc.month_start,
        COALESCE(ms.total_sales, 0) AS total_sales
    FROM month_calendar AS mc
    LEFT JOIN monthly_sales AS ms
        ON ms.month_start = mc.month_start
)
SELECT
    strftime('%Y-%m', month_start) AS sales_month,
    total_sales,
    ROUND(
        AVG(total_sales) OVER (
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM complete_monthly_sales
ORDER BY month_start;


--Q118 - Find the smallest group of highest-spending customers required to reach at least 50% of total revenue.
--
-- Step 1: Calculate total spending for each customer.
-- Step 2: Sort customers by spending and calculate cumulative and overall revenue.
-- Step 3: Calculate the cumulative amount before each customer.
-- Step 4: Keep the smallest leading group needed to reach or cross 50 percent.
--

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
cumulative_spending AS (
    SELECT
        customer_id,
        customer_name,
        total_spending,
        SUM(total_spending) OVER (
            ORDER BY total_spending DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(total_spending) OVER () AS total_revenue
    FROM customer_spending
),
revenue_boundary AS (
    SELECT
        *,
        cumulative_revenue - total_spending
            AS previous_cumulative_revenue
    FROM cumulative_spending
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    ROUND(
        cumulative_revenue * 100.0 /
        NULLIF(total_revenue, 0),
        2
    ) AS cumulative_revenue_percentage
FROM revenue_boundary
WHERE previous_cumulative_revenue
      < total_revenue * 0.50
ORDER BY total_spending DESC, customer_id;


--Q119 - Find pairs of customers who purchased exactly the same distinct set of products.
--
-- Step 1: Create distinct customer-product pairs.
-- Step 2: Generate each unique pair of customers with a CROSS JOIN.
-- Step 3: Use EXCEPT in both directions to detect any product-set difference.
-- Step 4: Return pairs for which neither customer has a product missing from the other set.
--

WITH customer_products AS (
    SELECT DISTINCT
        customer_id,
        product_id
    FROM orders
),
customer_pairs AS (
    SELECT
        c1.customer_id AS customer_1_id,
        c2.customer_id AS customer_2_id
    FROM customers AS c1
    CROSS JOIN customers AS c2
    WHERE c1.customer_id < c2.customer_id
),
matching_pairs AS (
    SELECT
        cp.customer_1_id,
        cp.customer_2_id
    FROM customer_pairs AS cp
    WHERE EXISTS (
        SELECT 1
        FROM customer_products
        WHERE customer_id = cp.customer_1_id
    )
    AND EXISTS (
        SELECT 1
        FROM customer_products
        WHERE customer_id = cp.customer_2_id
    )
    AND NOT EXISTS (
        SELECT product_id
        FROM customer_products
        WHERE customer_id = cp.customer_1_id

        EXCEPT

        SELECT product_id
        FROM customer_products
        WHERE customer_id = cp.customer_2_id
    )
    AND NOT EXISTS (
        SELECT product_id
        FROM customer_products
        WHERE customer_id = cp.customer_2_id

        EXCEPT

        SELECT product_id
        FROM customer_products
        WHERE customer_id = cp.customer_1_id
    )
)
SELECT
    c1.customer_id AS customer_1_id,
    c1.customer_name AS customer_1,
    c2.customer_id AS customer_2_id,
    c2.customer_name AS customer_2
FROM matching_pairs AS mp
JOIN customers AS c1
    ON c1.customer_id = mp.customer_1_id
JOIN customers AS c2
    ON c2.customer_id = mp.customer_2_id
ORDER BY customer_1_id, customer_2_id;


--Q120 - Build an RFM-style customer segmentation report.
--
-- Step 1: Use the latest order date in the data as the recency reference date.
-- Step 2: Calculate recency, frequency and monetary metrics for every customer.
-- Step 3: Score active customers into thirds with NTILE(3).
-- Step 4: Reattach customers with no orders and assign zero scores.
-- Step 5: Combine the scores and classify each customer into an RFM segment.
--

WITH reference_date AS (
    SELECT
        MAX(order_date) AS latest_order_date
    FROM orders
),
customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        MAX(o.order_date) AS last_order_date,
        CASE
            WHEN MAX(o.order_date) IS NULL THEN NULL
            ELSE CAST(
                julianday(rd.latest_order_date) -
                julianday(MAX(o.order_date))
                AS INTEGER
            )
        END AS recency_days,
        COUNT(o.order_id) AS frequency,
        COALESCE(SUM(o.amount), 0) AS monetary_value
    FROM customers AS c
    CROSS JOIN reference_date AS rd
    LEFT JOIN orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city,
        rd.latest_order_date
),
active_customer_scores AS (
    SELECT
        customer_id,
        4 - NTILE(3) OVER (
            ORDER BY recency_days
        ) AS recency_score,
        NTILE(3) OVER (
            ORDER BY frequency
        ) AS frequency_score,
        NTILE(3) OVER (
            ORDER BY monetary_value
        ) AS monetary_score
    FROM customer_metrics
    WHERE frequency > 0
),
rfm_report AS (
    SELECT
        cm.customer_id,
        cm.customer_name,
        cm.city,
        cm.last_order_date,
        cm.recency_days,
        cm.frequency,
        cm.monetary_value,
        COALESCE(acs.recency_score, 0)
            AS recency_score,
        COALESCE(acs.frequency_score, 0)
            AS frequency_score,
        COALESCE(acs.monetary_score, 0)
            AS monetary_score
    FROM customer_metrics AS cm
    LEFT JOIN active_customer_scores AS acs
        ON acs.customer_id = cm.customer_id
)
SELECT
    customer_id,
    customer_name,
    city,
    last_order_date,
    recency_days,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score
        + frequency_score
        + monetary_score AS total_rfm_score,
    CASE
        WHEN frequency = 0
            THEN 'No Orders'
        WHEN recency_score = 3
         AND frequency_score = 3
         AND monetary_score = 3
            THEN 'Champion'
        WHEN recency_score >= 2
         AND frequency_score >= 2
            THEN 'Loyal'
        WHEN recency_score = 3
         AND frequency_score = 1
            THEN 'New Customer'
        WHEN recency_score = 1
         AND frequency_score >= 2
            THEN 'At Risk'
        ELSE 'Developing'
    END AS customer_segment
FROM rfm_report
ORDER BY
    total_rfm_score DESC,
    monetary_value DESC,
    customer_name;
