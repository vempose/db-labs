-- ** Part A: Database and Table Setup ** --
-- 1. Create database and tables
CREATE DATABASE advanced_lab;
\c advanced lab

CREATE TABLE employees
(
    emp_id     SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name  TEXT,
    department TEXT,
    salary     INT,
    hire_date  DATE,
    status     TEXT DEFAULT 'Active'
);

CREATE TABLE department
(
    dept_id    SERIAL PRIMARY KEY,
    dept_name  TEXT,
    budget     INT,
    manager_id INT
);

CREATE TABLE projects
(
    project_id   SERIAL PRIMARY KEY,
    project_name TEXT,
    dept_id      INT,
    start_date   DATE,
    end_date     DATE,
    budget       INT
);



-- ** Part B: Advanced INSERT Operations ** --
-- 2. INSERT with column specification
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('John', 'Smith', 'HR', 45000, '2018-03-15', 'Active'),
       ('Emily', 'Johnson', 'Finance', 60000, '2019-07-01', 'Active'),
       ('Michael', 'Williams', 'IT', 75000, '2017-11-20', 'Active'),
       ('Sarah', 'Brown', 'Marketing', 52000, '2020-02-10', 'Active'),
       ('David', 'Jones', 'Finance', 64000, '2016-05-25', 'Inactive'),
       ('Olivia', 'Garcia', 'IT', 80000, '2021-01-05', 'Active'),
       ('Daniel', 'Martinez', 'HR', 47000, '2018-09-14', 'Active'),
       ('Sophia', 'Davis', 'Sales', 55000, '2019-12-03', 'Active'),
       ('James', 'Lopez', 'IT', 72000, '2015-08-19', 'Inactive'),
       ('Isabella', 'Miller', 'Marketing', 51000, '2020-06-07', 'Active'),
       ('Ethan', 'Wilson', 'Finance', 66000, '2017-04-30', 'Active'),
       ('Mia', 'Anderson', 'Sales', 54000, '2021-10-22', 'Active'),
       ('Alexander', 'Thomas', 'IT', 78000, '2016-12-12', 'Inactive'),
       ('Charlotte', 'Taylor', 'HR', 46000, '2019-03-18', 'Active'),
       ('Benjamin', 'Moore', 'Finance', 69000, '2018-07-09', 'Active'),
       ('Amelia', 'Jackson', 'Marketing', 53000, '2020-09-25', 'Active'),
       ('Henry', 'White', 'Sales', 56000, '2017-05-14', 'Inactive'),
       ('Evelyn', 'Harris', 'HR', 48000, '2021-11-11', 'Active'),
       ('Lucas', 'Clark', 'IT', 81000, '2019-08-27', 'Active'),
       ('Harper', 'Lewis', 'Finance', 70000, '2016-02-29', 'Inactive');

--  3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, hire_date, salary, status)
VALUES ('Stanley', 'Matthews', 'IT', '2022-12-01', DEFAULT, DEFAULT);

-- 4. INSERT multiple rows in single statement
INSERT INTO department (dept_name, budget)
VALUES ('HR', 200000),
       ('Finance', 500000),
       ('IT', 750000),
       ('Marketing', 300000),
       ('Sales', 400000),
       ('Senior', 500000),
       ('Junior', 120000);

-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bill', 'Slips', 'Sales', 5000 * 1.1, current_date);

-- 6. INSERT from SELECT (subquery)
CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';


-- ** Part C: Complex UPDATE Operations ** --
-- 7. UPDATE with arithmetic expressions
UPDATE employees
SET salary = salary * 1.1;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees
SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 and 80000 THEN 'Senior'
                     ELSE 'Junior'
    END;

-- 10. UPDATE with DEFAULT
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE department
SET budget = sub.avg_salary * 1.2
FROM (SELECT department, avg(salary) as avg_salary
      FROM employees
      -- The GROUP BY department is needed because we're asking for the average salary per
      -- department, not just the overall average.
      GROUP BY department) AS sub
WHERE sub.department = department.dept_name;

-- 12. UPDATE multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';



-- ** Part D: Advanced DELETE Operations ** --
-- 13. DELETE with simple WHERE condition
DELETE
FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE
FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE
FROM department
WHERE dept_name NOT IN (SELECT DISTINCT department
                        FROM employees);

-- 16. DELETE with RETURNING clause
-- Firstly, we need to add some data to the projects table
INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('HR Onboarding System', 1, '2021-01-10', '2025-06-30', 50000),
       ('Finance Audit 2022', 2, '2022-03-01', '2022-09-30', 120000),
       ('Cloud Migration', 3, '2021-05-15', '2024-05-15', 250000),
       ('Marketing Campaign Q1', 4, '2022-01-01', '2022-03-31', 80000),
       ('Sales Expansion Europe', 5, '2021-09-01', '2022-08-31', 150000),
       ('HR Training Portal', 1, '2022-07-01', '2023-01-15', 60000),
       ('Financial Forecasting AI', 2, '2021-11-10', '2022-11-10', 180000),
       ('Cybersecurity Upgrade', 3, '2022-02-20', '2023-02-20', 300000),
       ('Brand Awareness 2022', 4, '2022-04-01', '2022-12-31', 95000),
       ('Sales CRM Integration', 5, '2021-06-01', '2022-02-28', 110000);
DELETE
FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;



-- ** Part E: Operations with NULL Values ** --
-- 17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('John', 'Wick', NULL, NULL);

-- 18. UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions
DELETE
FROM employees
WHERE salary IS NULL
   OR department IS NULL;



-- ** Part F: RETURNING Clause Operations ** --
-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name)
VALUES ('Alfred', 'Walker')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING
-- Add some employees
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Noah', 'King', 'IT', 77000, '2022-03-14', 'Active'),
       ('Liam', 'Scott', 'IT', 82000, '2021-12-01', 'Active'),
       ('Emma', 'Young', 'IT', 76000, '2023-05-20', 'Active'),
       ('Ava', 'Hall', 'IT', 85000, '2020-10-11', 'Inactive'),
       ('William', 'Allen', 'IT', 79000, '2022-08-25', 'Active');

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns
DELETE
FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;



-- ** Part G: Advanced DML Patterns  ** --
-- 23. Conditional INSERT
INSERT INTO employees (first_name, last_name)
SELECT 'Semen', 'Prostoy'
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE first_name = 'Semen'
                    AND last_name = 'Prostoy');

-- 24. UPDATE with JOIN logic using subqueries
-- NOTE: PostgreSQL’s execution order is different from the intuition:
-- 1) PostgreSQL starts with the FROM department d
-- 2) Then it applies the WHERE e.department = d.dept_name join condition, matching employees with departments
-- 3) Now, when it evaluates the SET clause (with CASE), the alias d already refers to the matching row from department.
UPDATE employees e
SET salary = salary *
             CASE
                 WHEN d.budget > 100000 THEN 1.1
                 ELSE 1.05
                 END
FROM department d
WHERE d.dept_name = e.department;

--  25. Bulk operations
WITH inserted AS (
    INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
        VALUES ('Liam', 'Scott', 'IT', 77000, '2023-09-01', 'Active'),
               ('Emma', 'Young', 'IT', 76000, '2023-09-02', 'Active'),
               ('Ava', 'Hall', 'Finance', 68000, '2023-09-03', 'Active'),
               ('William', 'Allen', 'Marketing', 59000, '2023-09-04', 'Active'),
               ('Sophia', 'Clark', 'Sales', 61000, '2023-09-05', 'Active')
        RETURNING emp_id, salary)
UPDATE employees e
SET salary = i.salary * 1.10
FROM inserted AS i
WHERE e.emp_id = i.emp_id;

-- 26. Data migration simulation
CREATE TABLE employee_archive AS
SELECT *
FROM employees
WHERE status = 'Inactive';
DELETE
FROM employees
WHERE emp_id IN (SELECT emp_id
                 FROM employee_archive);

--  27. Complex business logic
UPDATE projects
SET end_date = end_date + 30 -- by default, it means +30 days
WHERE budget > 50000 -- first condition
  AND dept_id IN ( -- second condition, checking if dept has more than 3 emp
    SELECT d.dept_id
    FROM department d
    WHERE (SELECT COUNT(*)
           FROM employees e
           WHERE e.department = d.dept_name) > 3);
