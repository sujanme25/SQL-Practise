
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;

-- 1. Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    manager_id INT NULL
);

INSERT INTO employees (employee_id, employee_name, department, salary, manager_id) VALUES
(1, 'John', 'IT', 70000, 5),
(2, 'Sarah', 'HR', 40000, 6),
(3, 'Mike', 'IT', 75000, 5),
(4, 'David', 'Sales', 55000, 7),
(5, 'Robert', 'IT', 80000, NULL),
(6, 'Lisa', 'HR', 80000, NULL),
(7, 'James', 'Sales', 80000, NULL),
(8, 'Emma', 'IT', 75000, 5),
(9, 'Olivia', 'IT', 85000, 5),
(10, 'Noah', 'IT', 65000, 5),
(11, 'Sophia', 'HR', 55000, 6),
(12, 'Liam', 'HR', 45000, 6),
(13, 'Ava', 'Sales', 62000, 7),
(14, 'William', 'Sales', 58000, 7),
(15, 'Mason', 'Finance', 90000, NULL),
(16, 'Isabella', 'Finance', 72000, 15),
(17, 'Lucas', 'Finance', 72000, 15),
(18, 'Mia', 'Marketing', 68000, NULL),
(19, 'Ethan', 'Marketing', 50000, 18),
(20, 'Charlotte', 'Marketing', 75000, 18);

-- 2. Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO customers (customer_id, customer_name, city) VALUES
(1, 'Alex', 'Kathmandu'),
(2, 'Sarah', 'Biratnagar'),
(3, 'John', 'Birganj'),
(4, 'David', 'Pokhara'),
(5, 'Priya', 'Butwal'),
(6, 'Rohan', 'Sydney'),
(7, 'Emily', 'Melbourne'),
(8, 'Daniel', 'Brisbane'),
(9, 'Aisha', 'Perth'),
(10, 'Benjamin', 'Adelaide'),
(11, 'Harper', 'Canberra'),
(12, 'Jack', 'Townsville'),
(13, 'Grace', 'Gold Coast'),
(14, 'Samuel', 'Hobart'),
(15, 'Ella', 'Darwin');

-- 3. Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products (product_id, product_name, category, price) VALUES
(10, 'Laptop', 'Electronics', 60000),
(11, 'Headphones', 'Electronics', 3000),
(12, 'Chair', 'Furniture', 5000),
(13, 'Desk', 'Furniture', 10000),
(14, 'Monitor', 'Electronics', 25000),
(15, 'Keyboard', 'Electronics', 2000),
(16, 'Mouse', 'Electronics', 1500),
(17, 'Bookshelf', 'Furniture', 12000),
(18, 'Sofa', 'Furniture', 45000),
(19, 'Tablet', 'Electronics', 35000),
(20, 'Printer', 'Electronics', 10000),
(21, 'Coffee Table', 'Furniture', 8000);

-- 4. Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    amount DECIMAL(10,2),
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO orders (order_id, customer_id, product_id, amount, order_date) VALUES
(101, 1, 10, 500, '2026-01-05'),
(102, 2, 11, 800, '2026-01-06'),
(103, 1, 12, 300, '2026-01-08'),
(104, 3, 10, 1200, '2026-01-10'),
(105, 1, 11, 700, '2026-01-15'),
(106, 4, 13, 400, '2026-01-20'),
(107, 2, 10, 600, '2026-01-22'),
(108, 1, 13, 900, '2026-02-01'),
(109, 5, 14, 1000, '2026-02-10'),
(110, 6, 15, 600, '2026-02-15'),
(111, 7, 16, 450, '2026-02-18'),
(112, 8, 19, 2200, '2026-03-03'),
(113, 9, 18, 3100, '2026-03-07'),
(114, 10, 17, 1800, '2026-03-12'),
(115, 11, 20, 950, '2026-03-22'),
(116, 12, 21, 600, '2026-04-05'),
(117, 13, 10, 2700, '2026-04-09'),
(118, 14, 14, 1100, '2026-04-19'),
(119, 15, 11, 750, '2026-04-22'),
(120, 6, 19, 2100, '2026-05-01'),
(121, 7, 10, 3200, '2026-05-11'),
(122, 8, 18, 2900, '2026-05-18'),
(123, 2, 20, 850, '2026-05-22'),
(124, 3, 17, 1600, '2026-06-05'),
(125, 4, 21, 700, '2026-06-12'),
(126, 5, 10, 4100, '2026-06-18'),
(127, 1, 19, 2300, '2026-06-25'),
(128, 7, 18, 3400, '2026-07-02'),
(129, 9, 14, 1200, '2026-07-09'),
(130, 10, 15, 500, '2026-07-15'),
(131, 11, 16, 450, '2026-07-22'),
(132, 12, 20, 1050, '2026-08-03'),
(133, 13, 19, 2800, '2026-08-14'),
(134, 14, 10, 3500, '2026-08-18'),
(135, 15, 21, 800, '2026-08-29');

-- Verify that the tables were created
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
