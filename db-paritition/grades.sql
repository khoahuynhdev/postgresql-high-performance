CREATE TABLE grades_org (
  id serial not null
  g int not null
);

INSERT INTO grades_org(g) select floor(random() * 100) from generate_series (0, 10000000);

create index grades_org_index on grades_org(g);

-- this will be fast since we alredy have indexes
explain analyse select count(*) from grades_org where g = 30;

-- this will use parallel indedx scan and aggregate, no heap fetches
explain analyse select count(*) from grades_org where g between 30 and 35;

-- create the main table for partition
create table grades_parts(id serial not null, g int not null) partition by range(g);

-- create partition tables
create table g0025 (like grades_parts including indexes);
create table g2550 (like grades_parts including indexes);
create table g5075 (like grades_parts including indexes);
create table g75100 (like grades_parts including indexes);

-- attach partition table to main table
alter table grades_parts attach partition g0025 for values from (0) to (25);
alter table grades_parts attach partition g2550 for values from (25) to (50);
alter table grades_parts attach partition g5075 for values from (50) to (75);
alter table grades_parts attach partition g75100 for values from (75) to (100);

-- insert data into grades_parts FROM grades_org_index
-- line by line
insert into grades_parts SELECT * from grades_org;


-- we have the data
select Count(*) from grades_parts;
select Max() from grades_parts;

-- now we create the index
create index grades_parts_index on grades_parts(g);

-- check size of the relation 
select pg_relation_size(oid), relname from pg_class order by pg_relation_size(oid) desc;

-- make sure this value is always 'ON'
show enable_partition_pruning;

-- Pros
-- 1. Improves query performance when accessing a single partition
-- 2. Sequential scan vs Scattered Index scan
-- 3. Easy bulk loading
-- 4. Archive old data that are barely accessed into cheap storage

-- Cons
-- 1. Updates that move rows from a partition to another (slow or fail sometimes) eg: move one row from one partition to other partitions
-- 2. Inefficient queries could accidentally scan all partitions resulting in slower performance
-- 3. Schema changes can be challenging (DBMS could manage it through)

