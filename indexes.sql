
-- what does pg do when use run analyze <table>
--
-- what is a bitmap scan?
--
-- index scan: scan the index but go to the table heap page to get the data
-- index only scan: same as index scan but never touch the table heap page -> a lot faster
-- composite index: indexes are built from left to right -> can use condition with a alone
--  - if we have composite (a,b) and we use condition with b -> PG will fallback to use seq scan
