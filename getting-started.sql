-- run this to cleanup
-- VACUUM VERBOSE ANALYZE


-- \c dellstore2;

-- size of db
SELECT pg_size_pretty(pg_database_size('dellstore2'));

-- Timing overhead

-- \timing

SELECT count(*) FROM customers; -- 3.714ms

explain analyze select count(*) from customers; -- 5.480ms

-- running
-- Aggregate  (cost=578.29..578.30 rows=1 width=8) (actual time=5.049..5.050 rows=1 loops=1)
--   ->  Index Only Scan using customers_pkey on customers  (cost=0.29..528.29 rows=20000 width=0) (actual time=0.019..2.815 rows=20000 loops=1)
--         Heap Fetches: 0
-- Planning Time: 0.081 ms
-- Execution Time: 5.075 ms
-- (5 rows)

-- running count query again
SELECT count(*) FROM customers; -- 2.478ms

-- hot and cold cache behavior
-- this represents hot cache behavior, meaning that the data needed for the query
-- was already in either the database or OS caches

-- you can look at how long a query against the entire db takes as a way to measure
-- the effectiveness transfer rate for that table
select pg_size_pretty(cast(pg_relation_size('customers') / 3.714 * 1000 as int8)) as bytes_per_second; -- 1027MB

-- getting a 1027 Mbps is respectable

-- testing against real data sets need to be very careful to regconize whether their data is already in the cache or not.
