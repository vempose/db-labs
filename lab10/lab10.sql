-- ** Part 1: Database Setup ** --
-- Create tables
CREATE TABLE accounts
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products
(
    id      SERIAL PRIMARY KEY,
    shop    VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price   DECIMAL(10, 2) NOT NULL
);

-- Insert sample data
INSERT INTO accounts (name, balance)
VALUES ('Alice', 1000.00),
       ('Bob', 500.00),
       ('Wally', 750.00);

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Coke', 2.50),
       ('Joe''s Shop', 'Pepsi', 3.00);



-- ** Part 2: Basic Transaction with COMMIT ** --
-- Task 1: Transfer money between accounts
BEGIN;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;

/* Q: What are the balances of Alice and Bob after the transaction?
A: Alice has 900.00, Bob has 600.00.

Q: Why is it important to group these two UPDATE statements in a single transaction?
A: To ensure atomicity; either both updates happen, or neither does.

Q: What would happen if the system crashed between the two UPDATE statements without a transaction?
A: Alice would lose money, but Bob wouldn't receive it, creating data inconsistency.
*/



-- ** Part 3: Using ROLLBACK ** --
-- Task 2: Undo changes with ROLLBACK
BEGIN;
UPDATE accounts
SET balance = 500.00
WHERE name = 'Alice';

-- Check the balance inside the transaction
SELECT *
FROM accounts
WHERE name = 'Alice';

-- Undo the mistake
ROLLBACK;

SELECT *
FROM accounts
WHERE name = 'Alice';

/* Q: What was Alice's balance after the UPDATE but before ROLLBACK?
A: 500.00 (visible only within the uncommitted transaction).

Q: What is Alice's balance after ROLLBACK?
A: It returns to the previous committed value (900.00).

Q: In what situations would you use ROLLBACK in a real application?
A: When an error occurs, a constraint is violated, or the user cancels the operation.
*/



-- ** Part 4: Working with SAVEPOINTS ** --
-- Task 3: Partial rollbacks
BEGIN;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';

-- Undo transfer to Bob
ROLLBACK TO my_savepoint;

-- Transfer to Wally instead
UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Wally';

COMMIT;

/* Q: After COMMIT, what are the balances of Alice, Bob, and Wally?
A: Alice: 800.00, Bob: 600.00, Wally: 850.00.

Q: Was Bob's account ever credited? Why or why not in the final state?
A: It was credited temporarily, but the change was undone by the ROLLBACK TO SAVEPOINT.

Q: What is the advantage of using SAVEPOINT over starting a new transaction?
A: It allows you to handle partial errors without losing all progress in the larger transaction.
*/



-- ** Part 5: Isolation Level Demonstration ** --
-- Task 4: Read Committed vs Serializable
-- Note: These scenarios require two concurrent terminal sessions.

-- Scenario A: READ COMMITTED
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- (Wait for Terminal 2 to update and commit)
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Scenario B: SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- (Wait for Terminal 2 to update and commit)
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

/* Q: In Scenario A, what data does Terminal 1 see before and after Terminal 2 commits?
A: It sees the old data first, then the new data after T2 commits (Non-repeatable read).

Q: In Scenario B, what data does Terminal 1 see?
A: It sees the same initial data both times, ignoring T2's changes until T1 commits/restarts.

Q: Explain the difference in behavior between READ COMMITTED and SERIALIZABLE.
A: Read Committed allows non-repeatable reads; (start_span)Serializable enforces strict isolation as if transactions
were sequential.
*/



-- ** Part 6: Phantom Read Demonstration ** --
-- Task 5: Repeatable Read
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
-- (Wait for T2 to insert new row)
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

/* Q: Does Terminal 1 see the new product inserted by Terminal 2?
A: No, because REPEATABLE READ (in Postgres) and SERIALIZABLE prevent seeing new rows (phantoms) during the transaction.

Q: What is a phantom read?
A: When a query returns a set of rows that changes (e.g., new rows appear) when executed twice in the same transaction.

Q: Which isolation level prevents phantom reads?
A: SERIALIZABLE (and REPEATABLE READ in PostgreSQL's implementation).
*/



-- ** Part 7: Dirty Read Demonstration ** --
-- Task 6: Read Uncommitted
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- (Wait for T2 to update but NOT commit)
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

/* Q: Did Terminal 1 see the price of 99.99? Why is this problematic?
A: In standard SQL yes, but Postgres maps Read Uncommitted to Read Committed, so usually no.
Seeing 99.99 is bad if T2 rolls back.

Q: What is a dirty read?
[span_16](start_span)A: Reading data that has been modified by another transaction but not yet committed.

Q: Why should READ UNCOMMITTED be avoided in most applications?
A: It compromises data integrity by exposing incomplete or temporary changes.
*/



-- ** Part 8: Independent Exercises ** --
-- Exercise 1: Conditional Transfer
BEGIN;
DO $$
DECLARE
    current_bal DECIMAL;
BEGIN
    SELECT balance INTO current_bal FROM accounts WHERE name = 'Bob';
    IF current_bal >= 200 THEN
        UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
        UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
    ELSE
        RAISE NOTICE 'Insufficient funds for Bob';
    END IF;
END $$;
COMMIT;

-- Exercise 2: Multiple Savepoints
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('MyShop', 'Tablet', 500.00);
SAVEPOINT sp_insert;
UPDATE products SET price = 600.00 WHERE product = 'Tablet';
SAVEPOINT sp_update;
DELETE FROM products WHERE product = 'Tablet';
ROLLBACK TO sp_insert; -- Undoes delete and update
COMMIT;

-- Exercise 3: Banking Scenario (Serializable)
-- To prevent concurrent withdrawals exceeding balance:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Check balance and withdraw logic here
COMMIT;

-- Exercise 4: Fix Sells MAX < MIN with Transactions
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT MAX(price), MIN(price) FROM products;
COMMIT;



-- ** Part 9: Self-Assessment Questions ** --
/*
Q1: Explain each ACID property.
A: Atomicity (all/none), Consistency (valid states), Isolation (concurrent separation), Durability (saved after crash).

Q2: Difference between COMMIT and ROLLBACK?
A: COMMIT saves changes permanently; ROLLBACK undoes them.

Q3: When would you use a SAVEPOINT?
A: To undo only part of a transaction without canceling the whole thing.

Q4: Compare the four SQL isolation levels.
A: Read Uncommitted (dirty reads allowed), Read Committed (no dirty reads), Repeatable Read (no changes to read rows),
Serializable (no phantoms/full isolation).

Q5: What is a dirty read?
A: Reading uncommitted data.

Q6: What is a non-repeatable read?
A: Rereading a row finds different data (modified by others).

Q7: What is a phantom read?
A: Rereading a range finds new/missing rows. Prevented by SERIALIZABLE.

Q8: READ COMMITTED vs SERIALIZABLE?
A: Read Committed allows more concurrency (less locking) but less isolation. Serializable is safer but slower.

Q9: How do transactions help consistency?
A: They ensure complex operations happen fully or not at all, preventing partial data updates.

Q10: What happens to uncommitted changes on crash?
A: They are lost (rolled back) to maintain consistency.
*/
