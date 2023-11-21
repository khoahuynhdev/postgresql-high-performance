
-- what does pg do when use run analyze <table>
--
-- what is a bitmap scan?
--
-- index scan: scan the index but go to the table heap page to get the data
-- index only scan: same as index scan but never touch the table heap page -> a lot faster
