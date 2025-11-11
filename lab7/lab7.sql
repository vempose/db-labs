-- ** Part 2: Creating Basic Views ** --
-- Task 2.1: Simple View Creation
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Test the view
SELECT *
FROM employee_details;
-- Question: How many rows are returned? Why doesn't Tom Brown appear?
/*
4 rows are returned.
Tom Brown does not appear because his 'dept_id' is NULL, and the view uses an
INNER JOIN, which only includes rows with a non-null match in both tables.
*/

-- Task 2.2: View with Aggregation
CREATE VIEW dept_statistics AS
SELECT d.dept_name,
       COUNT(e.emp_id)            AS employee_count,
       COALESCE(AVG(e.salary), 0) AS avg_salary,
       COALESCE(MAX(e.salary), 0) AS max_salary,
       COALESCE(MIN(e.salary), 0) AS min_salary
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Test the view
SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;


-- Task 2.3: View with Multiple Joins
CREATE VIEW project_overview AS
WITH DeptEmpCounts AS (SELECT dept_id, COUNT(emp_id) AS team_size
                       FROM employees
                       GROUP BY dept_id)
SELECT p.project_name,
       p.budget,
       d.dept_name,
       d.location,
       COALESCE(dec.team_size, 0) AS team_size
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN DeptEmpCounts dec ON d.dept_id = dec.dept_id;

-- Test the view
SELECT *
FROM project_overview;


-- Task 2.4: View with Filtering
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

-- Test the view
SELECT *
FROM high_earners;
-- Question: What happens when you query this view? Can you see all high-earning employees?
/*
The view returns Jane Doe (60000) and Sarah Williams (65000).
Yes, all employees with a salary strictly greater than 55,000 are visible.
*/



-- ** Part 3: Modifying and Managing Views ** --
-- Task 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name,
       e.salary,
       d.dept_name,
       d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
           END AS salary_grade
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Test the replaced view
SELECT *
FROM employee_details;


-- Task 3.2: Rename a View
    ALTER VIEW high_earners RENAME TO top_performers;

-- Verify
SELECT *
FROM top_performers;


-- Task 3.3: Drop a View
CREATE VIEW temp_view AS
SELECT emp_name, salary
FROM employees
WHERE salary < 50000;

-- (SELECT * FROM temp_view;)
DROP VIEW temp_view;



-- ** Part 4: Updatable Views ** --
-- Task 4.1: Create an Updatable View
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;


-- Task 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

-- Verify the update
SELECT *
FROM employees
WHERE emp_name = 'John Smith';
-- Question: Did the underlying table get updated?
/*
Yes, the 'employees' base table was updated. The 'salary' for 'John Smith' is now 52000.
*/


-- Task 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

-- Verify the insert
SELECT *
FROM employees;
-- Question: Was the insert successful? Check the employees table.
/*
Yes, the insert was successful. The new row for 'Alice Johnson' was added to the
underlying 'employees' table.
*/


-- Task 4.4: View with CHECK OPTION
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Try to insert an employee from a different department
-- This should fail
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- Question: What error message do you receive? Why?
/*
Error: "new row violates check option for view "it_employees""
This fails because the 'WITH LOCAL CHECK OPTION' enforces the view's WHERE clause
(dept_id = 101) for all INSERT and UPDATE operations. The new row's 'dept_id' (103)
does not meet this condition.
*/


-- ** Part 5: Materialized Views ** --
-- Task 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COUNT(DISTINCT e.emp_id)     AS total_employees,
       COALESCE(SUM(e.salary), 0)   AS total_salaries,
       COUNT(DISTINCT p.project_id) AS total_projects,
       COALESCE(SUM(p.budget), 0)   AS total_project_budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

-- Query the materialized view
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;


-- Task 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- Query before refresh
SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;
-- Refresh
REFRESH MATERIALIZED VIEW dept_summary_mv;
-- Query after refresh
SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;
-- Question: What's the difference before and after refresh?
/*
Before refresh, the IT department (101) row shows the old data (total_employees = 2, total_salaries = 107000.00).
After the refresh, the data is updated to reflect the new employee (total_employees = 3, total_salaries = 161000.00).
*/


-- Task 5.3: Concurrent Refresh
CREATE UNIQUE INDEX ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- Question: What's the advantage of CONCURRENTLY option?
/*
The advantage of 'REFRESH CONCURRENTLY' is that it updates the materialized view
without taking an exclusive lock on it. This allows other database sessions to
read (SELECT) from the view *while* it is being refreshed, preventing downtime.
It requires a UNIQUE INDEX to operate.
*/


-- Task 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
WITH DeptEmpCounts AS (SELECT dept_id, COUNT(emp_id) AS team_size
                       FROM employees
                       GROUP BY dept_id)
SELECT p.project_name,
       p.budget,
       d.dept_name,
       COALESCE(dec.team_size, 0) AS assigned_employees_count
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN DeptEmpCounts dec ON d.dept_id = dec.dept_id
WITH NO DATA;

-- Try to query it
SELECT *
FROM project_stats_mv;
-- Question: What error do you get? How do you fix it?
/*
Error: "materialized view "project_stats_mv" has not been populated"
You fix it by populating the view with data using the REFRESH command:
REFRESH MATERIALIZED VIEW project_stats_mv;
*/


-- ** Part 6: Database Roles ** --
-- Task 6.1: Create Basic Roles
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user WITH LOGIN PASSWORD 'report456';

-- View all roles
SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';


-- Task 6.2: Role with Specific Attributes
CREATE ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';


-- Task 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;


-- Task 6.4: Create Group Roles
-- 1. Create group roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
-- 2. Create individual users
CREATE ROLE hr_user1 WITH LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 WITH LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 WITH LOGIN PASSWORD 'fin001';
-- 3. Assign users to teams
GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
-- 4. Grant privileges to teams
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


-- Task 6.5: Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Task 6.6: Modify Role Attributes
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;


-- ** Part 7: Advanced Role Management ** --
-- Task 7.1: Role Hierarchies
-- 1. Create parent role and grant privileges
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
-- 2. Create child roles
CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';
-- 3. Grant membership
GRANT read_only TO junior_analyst, senior_analyst;
-- 4. Grant additional privileges
GRANT INSERT, UPDATE ON employees TO senior_analyst;


-- Task 7.2: Object Ownership
-- 1. Create role
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';
-- 2. Transfer view ownership
    ALTER VIEW dept_statistics OWNER TO project_manager;
-- 3. Transfer table ownership
ALTER TABLE projects
    OWNER TO project_manager;

-- Check ownership
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';
-- (And for views)
SELECT viewname, viewowner
FROM pg_views
WHERE schemaname = 'public'
  AND viewname = 'dept_statistics';


-- Task 7.3: Reassign and Drop Roles
-- 1. Create role
CREATE ROLE temp_owner WITH LOGIN;
-- 2. Create table
CREATE TABLE temp_table
(
    id INT
);
-- 3. Transfer ownership
ALTER TABLE temp_table
    OWNER TO temp_owner;
-- 4. Reassign all objects owned by temp_owner to postgres
REASSIGN OWNED BY temp_owner TO postgres;
-- 5. Drop all objects owned by temp_owner (will do nothing now, but good practice if reassign wasn't used)
DROP OWNED BY temp_owner;
-- 6. Drop the temp_owner role
DROP ROLE temp_owner;


-- Task 7.4: Row-Level Security with Views
-- Create HR view
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;
-- Grant to HR team
GRANT SELECT ON hr_employee_view TO hr_team;
-- Create Finance view
CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;
-- Grant to Finance team
GRANT SELECT ON finance_employee_view TO finance_team;



-- ** Part 8: Practical Scenarios ** --
-- Task 8.1: Department Dashboard View
CREATE VIEW dept_dashboard AS
WITH DeptStats AS (SELECT d.dept_id,
                          d.dept_name,
                          d.location,
                          COUNT(DISTINCT e.emp_id)     AS employee_count,
                          COALESCE(AVG(e.salary), 0)   AS avg_salary,
                          COUNT(DISTINCT p.project_id) AS project_count,
                          COALESCE(SUM(p.budget), 0)   AS total_project_budget
                   FROM departments d
                            LEFT JOIN employees e ON d.dept_id = e.dept_id
                            LEFT JOIN projects p ON d.dept_id = p.dept_id
                   GROUP BY d.dept_id, d.dept_name, d.location)
SELECT dept_name,
       location,
       employee_count,
       ROUND(avg_salary, 2) AS avg_salary,
       project_count,
       total_project_budget,
       CASE
           WHEN employee_count = 0 THEN 0
           ELSE ROUND(total_project_budget / employee_count, 2)
           END              AS budget_per_employee
FROM DeptStats;

-- Test the view
SELECT *
FROM dept_dashboard;


-- Task 8.2: Audit View
-- Add column
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Create view
CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
           END AS approval_status
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- Test the view
SELECT *
FROM high_budget_projects;


-- Task 8.3: Create Access Control System
-- Level 1: Viewer
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2: Entry
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3: Analyst
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4: Manager
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Create Users
CREATE ROLE alice WITH LOGIN PASSWORD 'alice123';
CREATE ROLE bob WITH LOGIN PASSWORD 'bob123';
CREATE ROLE charlie WITH LOGIN PASSWORD 'charlie123';

-- Assign Users to Roles
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;