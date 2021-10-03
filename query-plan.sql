-- EXPLAIN output is organized into a series of plan nodes
-- eg: looking at tables, scanning them, looking things up with an index
-- or take output from lower-level ones and operate

EXPLAIN ANALYZE select * from customers;

-- Seq Scan on customers  (cost=0.00..688.00 rows=20000 width=268) (actual time=0.008..2.619 rows=20000 loops=1)
-- Planning Time: 0.068 ms
-- Execution Time: 4.290 ms
-- (3 rows)

-- cost=0.00..688.00: the first cost here is the startup cost of the node. that's how much work is estimated before this node produces its first row of output
-- in this case, that's zero because a 'seq scan' immediately return rows
-- a sort operation is an example of something that instead takes a while to return a single row
-- the second estimated cost is that of running the entire node until it completes.

-- row=20000: the number of rows this node expects to output if it runs to completion
-- width=268: the estimated average number of bytes each row output by this node will contain. EG: 20000 rows of 268 bytes each means this node expects to produces 5,360,000 bytes of output. this is slightly larger than the table itself (3.8MB) becasue it includes the overhead of how tuples are stored in memory when executing in a plan

-- The actual figures show how well this query really ran

-- actual time=0.0008..2.619: it took 0.0008 to start producing output. Once thing started, it took 2.619 ms to execute this plan node in total
-- rows=20000: as expected, the plan output 20000 rows. if the number is different, it means the optimizer made a bad decision
-- loops=1: some nodes, such as ones doing joins, execute more than one. In that case the loops will be larger than 1, and the actual time and row values shown will be per loop, NOT THE TOTAL. You will have to do the math


EXPLAIN ANALYSE SELECT * FROM customers;
-- Seq Scan on customers  (cost=0.00..688.00 rows=20000 width=268) (actual time=0.007..1.927 rows=20000 loops=1)


-- basic cost computation

-- seq_page_cost: how long it takes to read a single database page from the disk when
-- the expectation is you'll be reading several next to one another, cost of 1.0

-- random_page_cost: the cost when the rows involved are expected to be scattered across the disk at random, default to 4.0

-- cpu_tuple_cost: how much it costs to process a single row of data. default is 0.01

-- cpu_index_tuple_cost: the cost to process an index entry during an index scan. default is 0.005, lower than
-- what is cost to process a row because rows have a lot more header information (such as the visibility xmin and xmax)

-- cpu_operator_cost: the expected cost to process a simple operation or function eg: adding two numbers. default is 0.0025

SELECT
     relpages,
     current_setting('seq_page_cost') AS seq_page_cost,
     relpages *
       current_setting('seq_page_cost')::decimal AS page_cost,
     reltuples,
     current_setting('cpu_tuple_cost') AS cpu_tuple_cost,
     reltuples *
       current_setting('cpu_tuple_cost')::decimal AS tuple_cost
   FROM pg_class WHERE relname='customers';

-- relpages | seq_page_cost | page_cost | reltuples | cpu_tuple_cost | tuple_cost
-- 488 		| 1 			| 488		| 20000		| 0.01			 | 200

-- adding page_cost (488) to tuple_cost (200) equals cost show by explain

