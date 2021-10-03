EXPLAIN SELECT ctid, customerid
FROM customers
WHERE ctid = '(0,1)';

-- Tid Scan on customers  (cost=0.00..4.01 rows=1 width=10)
--   TID Cond: (ctid = '(0,1)'::tid)
-- Note that seq scan must read through all the dead rows in a table,
-- but will not include them in its output

-- Index Scan

EXPLAIN ANALYSE SELECT * FROM customers WHERE customerid=1000;

-- Index Scan using customers_pkey on customers  (cost=0.29..8.30 rows=1 width=268) (actual time=0.852..0.853 rows=1 loops=1)
--   Index Cond: (customerid = 1000)
-- the main component to the cost here are two random page reads (4.0 each, making a total of 8.0)
-- both the index block and the database row is in

-- Bitmap heap and index scans

EXPLAIN ANALYSE SELECT customerid, username
FROM customers
WHERE customerid < 10000 AND username < 'user100';

-- my engine didn't perform bitmap scan


-- Processing nodes
-- Sort: appear when there are order by
EXPLAIN ANALYZE SELECT customerid FROM customers ORDER BY zip;
SHOW work_mem; -- 4MB
-- Sort operation can either execute in memory using quicksort algorithms if they are expected to fit, or will be swapped to disk to use external merge sort

EXPLAIN ANALYZE SELECT customerid FROM customers WHERE customerid BETWEEN 50 AND 10000 LIMIT 10;
-- Limit  (cost=0.29..0.60 rows=10 width=4) (actual time=0.014..0.016 rows=10 loops=1)
--  ->  Index Only Scan using customers_pkey on customers  (cost=0.29..315.31 rows=9951 width=4) (actual time=0.013..0.014 rows=10 loops=1)
--        Index Cond: ((customerid >= 50) AND (customerid <= 10000))
--        Heap Fetches: 0

-- the on the customers table could have an output with as many as rows. But because the limit was reached after only
-- rows, that's all the node was a/sked to produce. The action where an upper node asks for a row from one of its children is referred to as it pulling one from it.

-- Offsets: when offset is added to the query, it isn't handled by its own node type. it's handled as a different form of limit
EXPLAIN ANALYZE SELECT customerid FROM customers OFFSET 1234 LIMIT 10;

-- AGGREGATE
EXPLAIN ANALYZE SELECT max(zip) FROM customers;
