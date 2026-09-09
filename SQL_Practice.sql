-- SQL Assessment Practice Dataset
-- MySQL-compatible setup for Q1-Q25

DROP DATABASE IF EXISTS sql_assessment_practice;
CREATE DATABASE sql_assessment_practice;
USE sql_assessment_practice;

-- 1. Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    manager_id INT NULL
);

INSERT INTO employees (employee_id, employee_name, department, salary, manager_id) VALUES
(1, 'John', 'IT', 60000, 5),
(2, 'Sarah', 'HR', 50000, 6),
(3, 'Mike', 'IT', 75000, 5),
(4, 'David', 'Sales', 45000, 7),
(5, 'Robert', 'IT', 90000, NULL),
(6, 'Lisa', 'HR', 70000, NULL),
(7, 'James', 'Sales', 80000, NULL),
(8, 'Emma', 'IT', 75000, 5);

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
(5, 'Priya', 'Butwal');

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
(13, 'Desk', 'Furniture', 10000);

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
(108, 1, 13, 900, '2026-02-01');

-- Verify that the tables were created
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
