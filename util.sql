-- run this to cleanup
-- VACUUM VERBOSE ANALYZE


-- \c dellstore2;

-- size of db
SELECT pg_size_pretty(pg_database_size('dellstore2'));

-- Timing overhead

-- \timing

SELECT count(*) FROM customers;
