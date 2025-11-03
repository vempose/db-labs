-- ** Part 1: Database Setup ** --
-- Task 1.1: Create Sample Tables
CREATE TABLE employees
(
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id  INT,
    salary   DECIMAL(10, 2)
);
CREATE TABLE departments
(
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);
CREATE TABLE projects
(
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id      INT,
    budget       DECIMAL(10, 2)
);

-- Task 1.2: Insert Sample Data
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (1, 'John Smith', 101, 50000),
       (2, 'Jane Doe', 102, 60000),
       (3, 'Mike Johnson', 101, 55000),
       (4, 'Sarah Williams', 103, 65000),
       (5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location)
VALUES (101, 'IT', 'Building A'),
       (102, 'HR', 'Building B'),
       (103, 'Finance', 'Building C'),
       (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES (1, 'Website Redesign', 101, 100000),
       (2, 'Employee Training', 102, 50000),
       (3, 'Budget Analysis', 103, 75000),
       (4, 'Cloud Migration', 101, 150000),
       (5, 'AI Research', NULL, 200000);



-- ** Part 2: CROSS JOIN Exercises ** --
-- Task 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
         CROSS JOIN departments d;
-- Question: How many rows? 5 employees * 4 departments = 20 rows.

-- Task 2.2: Alternative CROSS JOIN Syntax
-- a) Comma notation:
SELECT e.emp_name, d.dept_name
FROM employees e,
     departments d;
-- b) INNER JOIN with TRUE condition:
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON TRUE;

-- Task 2.3: Practical CROSS JOIN
SELECT e.emp_name, p.project_name
FROM employees e
         CROSS JOIN projects p;



-- ** Part 3: INNER JOIN Exercises ** --
-- Task 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Question: Returns 4 rows. Tom Brown is not included because his 'dept_id' is NULL, and INNER JOIN only returns
-- rows with a match in both tables.

-- Task 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);
-- Question: The 'dept_id' column is no longer duplicated. USING(dept_id) merges the join column into a single column
-- in the output, whereas ON keeps it separate for each aliased table.

-- Task 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
         NATURAL INNER JOIN departments;

-- Task 3.4: Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;



-- ** Part 4: LEFT JOIN Exercises ** --
-- Task 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Question: Tom Brown is included. The columns from the 'departments' table (dept_dept, dept_name)
-- are filled with NULL.

-- Task 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
         LEFT JOIN departments USING (dept_id);

-- Task 4.3: Find Unmatched Records
SELECT e.emp_name, e.dept_id
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Task 4.4: LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;



-- ** Part 5: RIGHT JOIN Exercises ** --
-- Task 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Task 5.2: Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Task 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;



-- ** Part 6: FULL JOIN Exercises ** --
-- Task 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Question: 'Marketing' (from departments) has NULL on the left (employee) side.
-- 'Tom Brown' (from employees) has NULL on the right (department) side.

-- Task 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Task 6.3: Find Orphaned Records
SELECT CASE
           WHEN e.emp_id IS NULL THEN 'Department without employees'
           WHEN d.dept_id IS NULL THEN 'Employee without department'
           ELSE 'Matched'
           END AS record_status,
       e.emp_name,
       d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;



-- ** Part 7: ON vs WHERE Clause ** --
-- Task 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Task 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Question: Compare the results of Query 1 and Query 2. Explain the difference.
/*
Query 1 (ON clause): query returns ALL employees from the left table (employees).
The condition 'd.location = 'Building A'' is applied during the join. Employees not in
'Building A' or with no department are still included, but their 'dept_name' will be NULL.

Query 2 (WHERE clause): This query filters the entire result set after the LEFT JOIN
is performed. The 'WHERE d.location = 'Building A'' condition filters out any rows where
the location is not 'Building A'. Since NULL or 'Building B' do not equal 'Building A',
those rows are removed.
*/

-- Task 7.3: ON vs WHERE with INNER JOIN
-- Query 1: INNER JOIN with ON filter
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- Query 2: INNER JOIN with WHERE filter
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Question: Is there any difference in results? Why or why not?
/*
No, there is no difference in the results for an INNER JOIN.
For an INNER JOIN, a filter condition in the ON clause is equivalent to a filter condition in
the WHERE clause.
*/


-- ** Part 8: Complex JOIN Scenarios ** --
-- Task 8.1: Multiple Joins with Different Types
SELECT d.dept_name,
       e.emp_name,
       e.salary,
       p.project_name,
       p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Task 8.2: Self Join
-- Add manager_id column
ALTER TABLE employees
    ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees
SET manager_id = 3
WHERE emp_id = 1;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 2;
UPDATE employees
SET manager_id = NULL
WHERE emp_id = 3;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 4;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 5;

-- Self join query
SELECT e.emp_name AS employee,
       m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Task 8.3: Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


-- ** Part 9: Lab Questions (Answers) ** --
/*
1. What is the difference between INNER JOIN and LEFT JOIN?
An INNER JOIN returns only the rows that have matching values in both tables.
A LEFT JOIN returns all rows from the left table, and the matched rows from the right table.

2. When would you use CROSS JOIN in a practical scenario?
You would use CROSS JOIN to generate a complete set of all possible combinations between two tables.

3. Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
For Outer Joins (like LEFT JOIN), ON filters the right table before joining, but still keeps all rows from the left table1.
WHERE filters the entire result after the join, which can remove rows the outer join was meant to preserve.
For Inner Joins, ON and WHERE are functionally the same, as both simply filter the final set of matched rows.

4. What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
The result will be 5 * 10 = 50.

5. How does NATURAL JOIN determine which columns to join on?
NATURAL JOIN automatically joins on all columns that have the exact same name in both tables.

6. Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
SELECT * FROM B RIGHT JOIN A ON A.id = B.id

7. What are the potential risks of using NATURAL JOIN?
The main risk is ambiguity: NATURAL JOIN automatically joins on all columns with the same name, which might include
columns you didn't intend to join on.

8. When should you use FULL OUTER JOIN instead of other join types?
Use FULL OUTER JOIN when you need all rows from both tables, including any rows that do not have a match in the other table.
*/