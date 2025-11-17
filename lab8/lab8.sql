-- ** Part 1: Database Setup ** --
-- Create tables
CREATE TABLE departments
(
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);
CREATE TABLE employees
(
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id  INT,
    salary   DECIMAL(10, 2),
    FOREIGN KEY (dept_id) REFERENCES departments (dept_id)
);
CREATE TABLE projects
(
    proj_id   INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget    DECIMAL(12, 2),
    dept_id   INT,
    FOREIGN KEY (dept_id) REFERENCES departments (dept_id)
);

-- Insert sample data 
INSERT INTO departments
VALUES (101, 'IT', 'Building A'),
       (102, 'HR', 'Building B'),
       (103, 'Operations', 'Building C');
INSERT INTO employees
VALUES (1, 'John Smith', 101, 50000),
       (2, 'Jane Doe', 101, 55000),
       (3, 'Mike Johnson', 102, 48000),
       (4, 'Sarah Williams', 102, 52000),
       (5, 'Tom Brown', 103, 60000);
INSERT INTO projects
VALUES (201, 'Website Redesign', 75000, 101),
       (202, 'Database Migration', 120000, 101),
       (203, 'HR System Upgrade', 50000, 102);



-- ** Part 2: Creating Basic Indexes ** --
-- Exercise 2.1: Create a Simple B-tree Index 
CREATE INDEX emp_salary_idx ON employees (salary);

-- Verify the index was created 
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

/* Q: How many indexes exist on the employees table?
Answer: There are 2 indexes: 'employees_pkey'.
*/

-- Exercise 2.2: Create an Index on a Foreign Key 
CREATE INDEX emp_dept_idx ON employees (dept_id);

-- Test the index usage 
SELECT *
FROM employees
WHERE dept_id = 101;

/* Q: Why is it beneficial to index foreign key columns?
Answer: It improves performance for JOIN operations and queries filtering by the foreign key. 
*/

-- Exercise 2.3: View Index Information 
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/* Q: List all the indexes you see. Which ones were created automatically?
Answer: Automatic indexes are 'departments_pkey', 'employees_pkey', and 'projects_pkey'. 
*/


-- ** Part 3: Multicolumn Indexes ** --
-- Exercise 3.1: Create a Multicolumn Index 
CREATE INDEX emp_dept_salary_idx ON employees (dept_id, salary);

-- Test the multicolumn index 
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101
  AND salary > 52000;

/* Q: Would this index be useful for a query that only filters by salary (without dept_id)?
Answer: No, because the index is sorted by dept_id first. 
*/

-- Exercise 3.2: Understanding Column Order 
CREATE INDEX emp_salary_dept_idx ON employees (salary, dept_id);

-- Query 1: Filters by dept_id first 
SELECT *
FROM employees
WHERE dept_id = 102
  AND salary > 50000;
-- Query 2: Filters by salary first 
SELECT *
FROM employees
WHERE salary > 50000
  AND dept_id = 102;

/* Q: Does the order of columns in a multicolumn index matter?
Answer: Yes. The leftmost column in the index definition is the primary sort key. 
*/


-- ** Part 4: Unique Indexes ** --
-- Exercise 4.1: Create a Unique Index 
ALTER TABLE employees
    ADD COLUMN email VARCHAR(100);

UPDATE employees
SET email = 'john.smith@company.com'
WHERE emp_id = 1;

UPDATE employees
SET email = 'jane.doe@company.com'
WHERE emp_id = 2;

UPDATE employees
SET email = 'mike.johnson@company.com'
WHERE emp_id = 3;

UPDATE employees
SET email = 'sarah.williams@company.com'
WHERE emp_id = 4;

UPDATE employees
SET email = 'tom.brown@company.com'
WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees (email);

-- Test the uniqueness constraint (This will fail) 
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

/* Q: What error message did you receive?
Answer: A unique constraint violation error due duplicate key value.
*/

-- Exercise 4.2: Unique Index vs UNIQUE Constraint 
ALTER TABLE employees
    ADD COLUMN phone VARCHAR(20) UNIQUE;

-- View the indexes 
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
  AND indexname LIKE '%phone%';

/* Q: Did postgresql automatically create an index? What type of index?
Answer: Yes, postgresql automatically creates a unique index for UNIQUE constraints. 
*/


-- ** Part 5: Indexes and Sorting ** --
-- Exercise 5.1: Create an Index for Sorting 
CREATE INDEX emp_salary_desc_idx ON employees (salary DESC);

-- Test with an ORDER BY query 
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

/* Q: How does this index help with ORDER BY queries?
Answer: It allows the database to retrieve data already sorted, avoiding a separate sort operation. 
*/

-- Exercise 5.2: Index with NULL Handling 
CREATE INDEX proj_budget_nulls_first_idx ON projects (budget NULLS FIRST);

-- Test the index 
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;



-- ** Part 6: Indexes on Expressions ** --
-- Exercise 6.1: Create a Function-Based Index 
CREATE INDEX emp_name_lower_idx ON employees (LOWER(emp_name));

-- Test the expression index 
SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

/* Q: Without this index, how would postgresql search for names case-insensitively?
Answer: It would have to perform a sequential scan and compute the LOWER function for every row. 
*/

-- Exercise 6.2: Index on Calculated Values 
ALTER TABLE employees
    ADD COLUMN hire_date DATE;
UPDATE employees
SET hire_date = '2020-01-15'
WHERE emp_id = 1;

UPDATE employees
SET hire_date = '2019-06-20'
WHERE emp_id = 2;

UPDATE employees
SET hire_date = '2021-03-10'
WHERE emp_id = 3;

UPDATE employees
SET hire_date = '2020-11-05'
WHERE emp_id = 4;

UPDATE employees
SET hire_date = '2018-08-25'
WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees (EXTRACT(YEAR FROM hire_date));

-- Test the index 
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;



-- ** Part 7: Managing Indexes ** --
-- Exercise 7.1: Rename an Index 
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

-- Verify the rename 
SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

-- Exercise 7.2: Drop Unused Indexes 
DROP INDEX emp_salary_dept_idx;

/* Q: Why might you want to drop an index?
Answer: Indexes take up space and slow down INSERT/UPDATE/DELETE operations. 
*/

-- Exercise 7.3: Reindex 
REINDEX INDEX employees_salary_index;



-- ** Part 8: Practical Scenarios ** --
-- Exercise 8.1: Optimize a Slow Query 
-- Optimizing for WHERE salary > 50000
CREATE INDEX emp_salary_filter_idx ON employees (salary) WHERE salary > 50000;

-- Exercise 8.2: Partial Index 
CREATE INDEX proj_high_budget_idx ON projects (budget) WHERE budget > 80000;

-- Test the partial index 
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

/* Q: What's the advantage of a partial index compared to a regular index?
Answer: It is smaller and faster because it only indexes rows that match the condition. 
*/

-- Exercise 8.3: Analyze Index Usage 
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

/* Q: Does the output show an "Index Scan" or a "Seq Scan"? What does this tell you?
Answer: It often shows Seq Scan on small tables because scanning the whole table is faster than using an index. 
*/


-- ** Part 9: Index Types Comparison ** --
-- Exercise 9.1: Create a Hash Index 
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

-- Test the hash index 
SELECT *
FROM departments
WHERE dept_name = 'IT';

/* Q: When should you use a HASH index instead of a B-tree index?
Answer: Only for equality comparisons (=). It cannot be used for range queries or sorting. 
*/

-- Exercise 9.2: Compare Index Types 
CREATE INDEX proj_name_btree_idx ON projects (proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality search (Both can be used) 
SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

-- Range search (Only B-tree can be used) 
SELECT *
FROM projects
WHERE proj_name > 'Database';


-- ** Part 10: Cleanup and Best Practices ** --
-- Exercise 10.1: Review All Indexes 
SELECT schemaname, tablename, indexname, PG_SIZE_PRETTY(PG_RELATION_SIZE(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/* Q: Which index is the largest? Why?
Answer: Usually indexes on text columns or compound indexes are largest. 
*/

-- Exercise 10.2: Drop Unnecessary Indexes 
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3: Document Your Indexes 
CREATE OR REPLACE VIEW index_documentation AS
SELECT tablename, indexname, indexdef, 'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT *
FROM index_documentation;



-- ** Summary Questions ** --
/*
Q: What is the default index type in postgresql?
A: B-tree

Q: Name three scenarios where you should create an index:
A: Frequently queried columns (WHERE), Foreign Keys (JOINs), and Columns used in ORDER BY.

Q: Name two scenarios where you should NOT create an index:
A: On every single column (waste of space) and on rarely queried columns.

Q: What happens to indexes when you INSERT, UPDATE, or DELETE data?
A: They slow down the write operations because the index must also be updated.

Q: How can you check if a query is using an index?
A: Use the EXPLAIN command.
*/