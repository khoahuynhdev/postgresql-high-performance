-- https://www.percona.com/blog/postgresql-partitioning-using-traditional-methods/
CREATE TABLE donors (id INT NOt NULL , name VARCHAR(20) , bloodgroup VARCHAR (15) , last_donated DATE , 
contact_num VARCHAR(10)) PARTITION BY LIST (left(upper(bloodgroup),3));

CREATE TABLE A_positive PARTITION of donors for VALUES IN ('A+ ');
CREATE TABLE A_negative PARTITION of donors for VALUES IN ('A- ');
CREATE TABLE B_positive PARTITION of donors for VALUES IN ('B+ ');
CREATE TABLE B_negative PARTITION of donors for VALUES IN ('B- ');
CREATE TABLE AB_positive PARTITION of donors for VALUES IN ('AB+');
CREATE TABLE AB_negative PARTITION of donors for VALUES IN ('AB-');
CREATE TABLE O_positive PARTITION of donors for VALUES IN ('O+ ');
CREATE TABLE O_negative PARTITION of donors for VALUES IN ('O- ');


INSERT INTO donors (id , name , bloodgroup , last_donated , contact_num) VALUES (generate_series(1, 10000) ,'user_' || trunc(random()*100) ,
(array['A+ group', 'A- group', 'O- group', 'O+ group','AB+ group','AB- group','B+ group','B- group'])[floor(random() * 8 + 1)] , '2022-01-01'::date + trunc(random() * 366 * 1)::int,
CAST(1000000000 + floor(random() * 9000000000) AS bigint));
