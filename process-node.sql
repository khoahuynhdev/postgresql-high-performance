EXPLAIN SELECT ctid, customerid
FROM customers
WHERE ctid = '(0,1)';

-- Tid Scan on customers  (cost=0.00..4.01 rows=1 width=10)
--  TID Cond: (ctid = '(0,1)'::tid)
-- Note that seq scan must read through all the dead rows in a table,
-- but will not include them in its output

-- Index Scan

EXPLAIN ANALYSE SELECT * FROM customers WHERE customerid=1000;

-- Index Scan using customers_pkey on customers  (cost=0.29..8.30 rows=1 width=268) (actual time=0.852..0.853 rows=1 loops=1)
-- Index Cond: (customerid = 1000)
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
-- this look through all records with seq scan

EXPLAIN ANALYZE SELECT max(customerid) FROM customers;
-- this use index scan


-- HASH AGGREGATE
EXPLAIN ANALYZE SELECT products.category, count(*) FROM products GROUP BY products.category ORDER BY category;

-- UNIQUE
-- appear when using DISTINCT and when UNION is eliminating duplicates in its output
EXPLAIN ANALYZE SELECT DISTINCT(zip) FROM customers WHERE customers.customerid BETWEEN 50 AND 1000;

-- APPEND
EXPLAIN ANALYZE SELECT * FROM customers WHERE state='MA' UNION SELECT * FROM customers WHERE state='MD';

-- Subquery conversion and IN lists
EXPLAIN ANALYZE SELECT * FROM orders WHERE customerid IN (SELECT customerid FROM customers where state='MD');
-- This one is stuck doing a on each table simply because there are no indexes useful here. If they were, the rewritten form might execute quite quickly.

-- CTE scan

EXPLAIN ANALYZE WITH monthlysales AS
     (SELECT EXTRACT(year FROM orderdate) AS year,
     EXTRACT(month FROM orderdate) AS month,
     sum(netamount) AS sales
     FROM orders GROUP BY year,month)
    SELECT year,SUM(sales) AS sales FROM monthlysales GROUP BY year;


-- NESTED LOOP
EXPLAIN ANALYSE SELECT * FROM products,customers;
-- it's producing 200 million output rows, 15p

EXPLAIN ANALYSE SELECT * FROM products,customers WHERE products.prod_id > 1000 AND customers.customerid < 10000;
-- with index scan, 30s

-- NESTED LOOP with hash join
EXPLAIN ANALYZE SELECT * FROM orders,orderlines;

EXPLAIN ANALYZE SELECT * FROM orders,orderlines WHERE orderlines.orderid=1000 AND orders.orderid=orderlines.orderid;

-- Merged JOIN
-- A requires that both its input sets are sorted.
-- it then scans through the two in that sorted order,
-- generally moving one row at a time through both tables as
-- the join column values changes

EXPLAIN ANALYZE SELECT C.customerid,sum(netamount) FROM customers C, orders O WHERE C.customerid=O.customerid GROUP BY C.customerid;
-- my engine juse hash join

-- MATERIALIZE node

-- HASH semi and anti-join
-- get all products that never had an order
EXPLAIN ANALYZE SELECT prod_id,title FROM products p WHERE NOT EXISTS (SELECT 1 FROM orderlines ol WHERE ol.prod_id=p.prod_id);
-- divive query use anti-join optimization

-- Forcing join order
SELECT * FROM cust_hist h INNER JOIN products p ON (h.prod_id=p.prod_id) INNER JOIN customers c ON (h.customerid=c.customerid);
-- this is identical to using implcit join with where
SELECT * FROM cust_hist h,products p,customers c WHERE h.prod_id=p.prod_id
AND h.customerid=c.customerid;

-- the query optimizer is free to choose plan to EXECUTE
-- howerver, it doesn't have to be the case

SET join_collapse_limit = 8;
SELECT * FROM cust_hist h INNER JOIN products p ON (h.prod_id=p.prod_id) INNER JOIN customers c ON (h.customerid=c.customerid);
-- read more about join_collapse_limit here
-- https://www.postgresql.org/docs/11/explicit-joins.html

-- Join removal
SELECT * FROM products LEFT JOIN inventory ON products.prod_id=inventory.prod_id;
-- run with hash join

EXPLAIN ANALYZE SELECT products.title FROM products LEFT JOIN inventory ON products.prod_id=inventory.prod_id;
-- run with no join at all
-- there are 3 sensible requirements for this logic to kick in
-- A left join js happening
-- a Unique index exists for the join column
-- none of the information in the candidate table to remove is used anywhere

-- @TODO research GEQO genetic query optimizer

