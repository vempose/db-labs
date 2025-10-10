-- ** Part 1: CHECK Constraints ** --
-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees
(
    employee_id SERIAL PRIMARY KEY,
    first_name  TEXT,
    last_name   TEXT,
    age         INT CHECK (age BETWEEN 18 AND 65),
    salary      NUMERIC CHECK (salary > 0)
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog
(
    product_id     SERIAL PRIMARY KEY,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings
(
    booking_id     SERIAL PRIMARY KEY,
    check_in_date  DATE,
    check_out_date DATE CHECK (check_out_date > check_in_date),
    num_guests     INT CHECK (num_guests BETWEEN 1 AND 10)
);

-- Task 1.4: Testing CHECK Constraints
-- Valid: Age is 30 (18-65), Salary is $60k ( > 0)
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Alice', 'Smith', 30, 60000.00);
-- Valid: Edge case for Age (65), Salary is positive
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Bob', 'Johnson', 65, 120000.50);
-- Valid: regular_price > 0, discount_price > 0, discount_price < regular_price
INSERT INTO products_catalog (product_name, regular_price, discount_price)
VALUES ('Laptop Pro', 1500.00, 1200.00);
-- Valid: All conditions met for a low-cost item
INSERT INTO products_catalog (product_name, regular_price, discount_price)
VALUES ('Mouse Pad', 10.99, 5.00);
-- Valid: Check-out date is after check-in, num_guests is between 1 and 10
INSERT INTO bookings (check_in_date, check_out_date, num_guests)
VALUES ('2023-12-01', '2023-12-05', 4);
-- Valid: Check-out date is one day after check-in, min guests
INSERT INTO bookings (check_in_date, check_out_date, num_guests)
VALUES ('2024-06-15', '2024-06-16', 1);
-- 1. Violates CHECK (age BETWEEN 18 AND 65) - Age is 17 (too young)
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Charlie', 'Brown', 17, 50000.00);
-- 2. Violates CHECK (salary > 0) - Salary is negative
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Fiona', 'Chen', 28, -1000.00);
-- 3. Violates CONSTRAINT valid_discount (discount_price < regular_price) - Discount is GREATER than regular price
INSERT INTO products_catalog (product_name, regular_price, discount_price)
VALUES ('Overly Discounted', 100.00, 150.00);
-- 4. Violates CHECK (check_out_date > check_in_date) - Check-out date is the same as check-in
INSERT INTO bookings (check_in_date, check_out_date, num_guests)
VALUES ('2023-11-10', '2023-11-10', 2);
-- 5. Violates CHECK (num_guests BETWEEN 1 AND 10) - Too many guests (11)
INSERT INTO bookings (check_in_date, check_out_date, num_guests)
VALUES ('2024-08-01', '2024-08-10', 11);



-- ** Part 2: NOT NULL Constraints ** --
-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers
(
    customer_id       INT  NOT NULL,
    email             TEXT NOT NULL,
    phone             TEXT NOT NULL,
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory
(
    item_id      INT       NOT NULL,
    item_name    TEXT      NOT NULL,
    quantity     INT       NOT NULL CHECK (quantity >= 0),
    unit_price   NUMERIC   NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
-- Valid 1: All NOT NULL fields provided, quantity (500) >= 0, unit_price (19.99) > 0
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (101, 'Widget A', 500, 19.99, NOW());
-- Valid 2: Edge case where Quantity is 0, all other constraints met
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (102, 'Service Kit', 0, 55.00, NOW());
-- Violates NOT NULL constraint on item_name (NULL is attempted in a NOT NULL column)
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (103, NULL, 10, 5.00, NOW());
-- Violates CHECK (quantity >= 0) - Quantity is negative
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (104, 'Defective Batch', -5, 12.00, NOW());
-- Violates CHECK (unit_price > 0) - Unit price is 0 (must be strictly greater than 0)
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (105, 'Promotional Item', 100, 0.00, NOW());



-- ** Part 3: UNIQUE Constraints ** --
-- Task 3.1: Single Column UNIQUE
CREATE TABLE users
(
    user_id    INT,
    username   TEXT UNIQUE,
    email      TEXT UNIQUE,
    created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments
(
    enrollment_id INT,
    student_id    INT,
    course_code   TEXT,
    semester      TEXT,
    UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE Constraints
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users
    ADD CONSTRAINT unique_email UNIQUE (email);
-- Testing
INSERT INTO users (user_id, username, email, created_at)
VALUES (1, 'Alex', 'alex@gmail.com', NOW());
-- Duplicate username
INSERT INTO users (user_id, username, email, created_at)
VALUES (2, 'Alex', 'superalex@gmail.com', NOW());
-- Duplicate email
INSERT INTO users (user_id, username, email, created_at)
VALUES (3, 'John', 'alex@gmail.com', NOW());



-- ** Part 4: PRIMARY KEY Constraints ** --
-- Task 4.1: Single Column Primary Key
CREATE TABLE departments
(
    dept_id   INT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location  TEXT
);
-- Testing
-- Violates PRIMARY KEY constraint on dept_id (10 already exists)
INSERT INTO departments (dept_id, dept_name, location)
VALUES (10, 'HR', 'Chicago');
-- Violates NOT NULL constraint on dept_id (PRIMARY KEY implies NOT NULL)
INSERT INTO departments (dept_id, dept_name, location)
VALUES (NULL, 'Research', 'Boston');
-- Violates NOT NULL constraint on dept_name
INSERT INTO departments (dept_id, dept_name, location)
VALUES (40, NULL, 'Seattle');

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses
(
    student_id      INT,
    course_id       INT,
    enrollment_date DATE,
    grade           TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3: Comparison Exercise
/*
Primary Key (PK) vs. Unique Key (UK)
A PK is the single, official identifier for a row and must be NOT NULL. A UK just ensures
uniqueness across values in a column but can usually accept a NULL.

Single-Column vs. Composite PK
Use a single-column PK (like an auto-ID) whenever possible - it's simpler. Use a composite
PK only when uniqueness depends on the combination of two or more fields, commonly in tables
linking two other entities.

Why Only One PK?
A table is limited to one PK because it must have one, fixed, official address for
Foreign Keys to reference. It can have multiple UKs because many different columns
(e.g., email, username) might need to be unique, even though they aren't the primary
identifier.
*/


-- ** Part 5: FOREIGN KEY Constraints ** --
-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept
(
    emp_id    INT PRIMARY KEY,
    emp_name  TEXT NOT NULL,
    dept_id   INT REFERENCES departments,
    hire_date DATE
);
-- ** departments ** (Setup data for Foreign Key to reference)
INSERT INTO departments (dept_id, dept_name, location)
VALUES (10, 'Sales', 'New York');
INSERT INTO departments (dept_id, dept_name, location)
VALUES (20, 'Marketing', 'London');
INSERT INTO departments (dept_id, dept_name, location)
VALUES (30, 'IT', NULL);
-- Valid 1: References existing dept_id 10
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1001, 'Alice Johnson', 10, '2022-01-15');
-- Valid 2: References existing dept_id 20
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1002, 'Bob Williams', 20, '2023-05-20');
-- Valid 3: dept_id is nullable (optional constraint), and here we omit it (NULL)
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1003, 'Charlie Davis', NULL, '2024-10-01');
-- Attempts to insert an employee with dept_id 99, which does not exist in the departments table.
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1004, 'Diana Prince', 99, '2021-11-01');
-- Violates PRIMARY KEY constraint on emp_id (1001 already exists)
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1001, 'Eve Adams', 30, '2023-01-01');
-- Violates NOT NULL constraint on emp_name
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1005, NULL, 30, '2023-01-01');

-- Task 5.2: Multiple Foreign Keys
CREATE TABLE authors
(
    author_id   INT PRIMARY KEY,
    author_name TEXT NOT NULL,
    country     TEXT
);
CREATE TABLE publishers
(
    publisher_id   INT PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city           TEXT
);
CREATE TABLE books
(
    book_id          INT PRIMARY KEY,
    title            TEXT NOT NULL,
    author_id        INT REFERENCES authors,
    publisher_id     INT REFERENCES publishers,
    publication_year INT,
    isbn             TEXT UNIQUE
);
INSERT INTO authors (author_id, author_name, country)
VALUES (1, 'Jane Austen', 'UK'),
       (2, 'Gabriel Garcia Marquez', 'Colombia'),
       (3, 'Toni Morrison', 'USA'),
       (4, 'Haruki Murakami', 'Japan');
INSERT INTO publishers (publisher_id, publisher_name, city)
VALUES (101, 'Penguin Classics', 'New York'),
       (102, 'Vintage Books', 'London'),
       (103, 'Scribner', 'New York');
INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES (1001, 'Pride and Prejudice', 1, 101, 1813, '978-0141439518'),
       (1002, 'One Hundred Years of Solitude', 2, 102, 1967, '978-0241968581'),
       (1003, 'Beloved', 3, 103, 1987, '978-1400033416'),
       (1004, 'Kafka on the Shore', 4, 102, 2002, '978-0099496970'),
       (1005, 'Emma', 1, 101, 1815, '978-0141439525');

-- Task 5.3: ON DELETE Options
CREATE TABLE categories
(
    category_id   INT PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk
(
    product_id   INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INT REFERENCES categories ON DELETE RESTRICT
);
CREATE TABLE orders
(
    order_id   INT PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items
(
    item_id    INT PRIMARY KEY,
    order_id   INT REFERENCES orders ON DELETE CASCADE,
    product_id INT REFERENCES products_fk,
    quantity   INT CHECK (quantity > 0)
);
-- Setup
INSERT INTO categories
VALUES (1, 'Electronics'),
       (2, 'Apparel');
INSERT INTO products_fk
VALUES (101, 'Laptop', 1),
       (102, 'T-Shirt', 2);
INSERT INTO orders
VALUES (100, '2024-10-01'),
       (200, '2024-10-05');
INSERT INTO order_items
VALUES (1, 100, 101, 1),
       (2, 100, 102, 2),
       (3, 200, 101, 1);
-- Test 1: ON DELETE RESTRICT (Should Fail)
-- Attempting to delete Category 1 (Electronics) fails because Product 101 is linked.
SELECT '--- Test 1: DELETE RESTRICT (Category 1) ---' AS test_info;
DELETE
FROM categories
WHERE category_id = 1;
-- Test 2: ON DELETE CASCADE (Order 100 and its items)
-- Delete Order 100, which has two linked items (item_id 1 and 2).
SELECT '--- Test 2: ON DELETE CASCADE (Order 100 - Before) ---' AS test_info;
SELECT item_id, order_id
FROM order_items
WHERE order_id = 100;
DELETE
FROM orders
WHERE order_id = 100;
SELECT '--- Test 2: ON DELETE CASCADE (Order 100 - After) ---' AS test_info;
SELECT item_id, order_id
FROM order_items
WHERE order_id = 100;



-- ** Part 6: Practical Application ** --
-- Task 6.1: E-commerce Database Design