# Club Management Database System

## Introduction

This project is a comprehensive SQL query reference guide for a club management database system built with PostgreSQL. The database is designed to manage a recreational club's operations, tracking member information, facility details, and booking records. Users of this system include club administrators who need to query member data, analyze facility usage, manage bookings, and generate reports on club activities. The project demonstrates various SQL concepts including data manipulation (INSERT, UPDATE, DELETE), complex queries with joins, aggregate functions, window functions, and advanced filtering techniques. Key technologies used include PostgreSQL for database management, SQL for querying and data manipulation, and Git for version control. The database schema consists of three interconnected tables with foreign key relationships to maintain data integrity and enable complex relational queries for business intelligence and operational needs.

---

## SQL Queries

###### Table Setup (DDL)

The database uses a schema named `cd` (club data) with three main tables. The **members** table stores member information with a self-referencing foreign key for tracking referrals. The **facilities** table contains club amenities with pricing for members and guests. The **bookings** table records reservations linking members to facilities with timestamp and slot information.

```sql
-- Create schema
CREATE SCHEMA cd;

-- Members table
CREATE TABLE cd.members (
  memid integer PRIMARY KEY,
  surname VARCHAR(200) NOT NULL,
  firstname VARCHAR(200) NOT NULL,
  address VARCHAR(300) NOT NULL,
  zipcode integer NOT NULL,
  telephone VARCHAR(20) NOT NULL,
  recommendedby integer REFERENCES cd.members(memid) ON DELETE SET NULL,
  joindate timestamp NOT NULL
);

-- Facilities table
CREATE TABLE cd.facilities (
  facid integer PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  membercost numeric NOT NULL,
  guestcost numeric NOT NULL,
  initialoutlay numeric NOT NULL,
  monthlymaintenance numeric NOT NULL
);

-- Bookings table
CREATE TABLE cd.bookings (
  bookid integer PRIMARY KEY,
  facid integer NOT NULL REFERENCES cd.facilities(facid),
  memid integer NOT NULL REFERENCES cd.members(memid),
  starttime timestamp NOT NULL,
  slots integer NOT NULL
);
```

---

###### Question 1: Insert New Facility

Add a new spa facility to the facilities table with specific values for all columns.

**Explanation:** We use the `INSERT` keyword to add data, the `INTO` keyword to select which table, followed by the column names we wish to insert into, and then the `VALUES` keyword to input the new data.

```sql
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) 
VALUES 
    (9, 'Spa', 20, 30, 100000, 800);
```

---

###### Question 2: Auto-generate Facility ID

Add the spa again, but automatically generate the next facid value rather than specifying it as a constant.

**Explanation:** We don't use `VALUES` since that's for constants. Here we use a subquery to retrieve the highest facid and add one to it, simulating auto-generation.

```sql
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT 
    (SELECT MAX(facid) + 1 FROM cd.facilities),
    'Spa', 20, 30, 100000, 800;
```

---

###### Question 3: Update Existing Data

Fix the initial outlay for the second tennis court (should be 10000, not 8000).

**Explanation:** We use the `UPDATE` keyword to indicate we wish to update, then specify the table, use the `SET` keyword to set a column value, and use `WHERE` to target the specific row. We select by primary key (facid) rather than name to ensure we're updating the correct record.

```sql
UPDATE cd.facilities 
SET initialoutlay = 10000 
WHERE facid = 1;
```

---

###### Question 4: Update Based on Another Row

Make the second tennis court cost 10% more than the first one, without using constant values so the statement can be reused.

**Explanation:** PostgreSQL provides a `FROM` clause that allows us to generate values for use in the `SET` clause. This simplified version uses aliases (f1 for the second court, f2 for the first court) to reference both rows.

```sql
-- Original approach with subqueries
UPDATE cd.facilities 
SET 
    membercost = (
        SELECT membercost * 1.1 
        FROM cd.facilities 
        WHERE facid = 0
    ), 
    guestcost = (
        SELECT guestcost * 1.1 
        FROM cd.facilities 
        WHERE facid = 0
    ) 
WHERE facid = 1;

-- Simplified approach using FROM clause
UPDATE cd.facilities f1 
SET 
    membercost = f2.membercost * 1.1, 
    guestcost = f2.guestcost * 1.1 
FROM 
    cd.facilities f2 
WHERE 
    f1.facid = 1 
    AND f2.facid = 0;
```

---

###### Question 5: Delete All Bookings

Delete all bookings from the bookings table as part of a database clearout.

**Explanation:** We use the `DELETE` keyword followed by `FROM` to indicate which table. Because there are no conditions, we delete all values from that table.

```sql
DELETE FROM cd.bookings;
```

---

###### Question 6: Delete Specific Member

Remove member 37, who has never made a booking, from the database.

**Explanation:** Similar to Q5, but here we add a `WHERE` clause to target only member 37.

```sql
DELETE FROM cd.members 
WHERE memid = 37;
```

---

###### Question 7: Filter Facilities by Cost

Produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost.

**Explanation:** Straightforward query ensuring membercost is greater than 0 and less than 1/50th of monthly maintenance.

```sql
SELECT facid, name, membercost, monthlymaintenance 
FROM cd.facilities 
WHERE 
    membercost > 0 
    AND membercost < monthlymaintenance / 50;
```

---

###### Question 8: Pattern Matching

Produce a list of all facilities with the word 'Tennis' in their name.

**Explanation:** We use the `LIKE` keyword to match a string pattern. The `%` symbols before and after 'Tennis' represent that there can be any characters (or none) before and after the phrase.

```sql
SELECT * 
FROM cd.facilities 
WHERE name LIKE '%Tennis%';
```

---

###### Question 9: Multiple ID Match

Retrieve the details of facilities with ID 1 and 5 without using the OR operator.

**Explanation:** The `IN` keyword allows us to match against a list of values.

```sql
SELECT * 
FROM cd.facilities 
WHERE facid IN (1, 5);
```

---

###### Question 10: Date Filtering

Produce a list of members who joined after the start of September 2012. Return the memid, surname, firstname, and joindate.

**Explanation:** We use `WHERE` with date comparison operators to filter by dates.

```sql
SELECT memid, surname, firstname, joindate 
FROM cd.members
WHERE joindate >= '2012-09-01';
```

---

###### Question 11: Combining Results

Produce a combined list of all surnames and all facility names.

**Explanation:** We use `UNION` to combine entries from both tables into a single result set. `UNION` removes duplicates; use `UNION ALL` to keep duplicates.

```sql
SELECT surname 
FROM cd.members
UNION
SELECT name 
FROM cd.facilities;
```

---

###### Question 12: Inner Join

Produce a list of the start times for bookings by members named 'David Farrell'.

**Explanation:** We use aliases (bk for bookings, m for members) and perform an `INNER JOIN`, which returns only rows that have a match in both tables.

```sql
SELECT bk.starttime 
FROM cd.bookings bk
INNER JOIN cd.members m 
    ON m.memid = bk.memid
WHERE 
    m.firstname = 'David' 
    AND m.surname = 'Farrell';
```

---

###### Question 13: Join with Date Range

Produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'. Return a list of start time and facility name pairings, ordered by the time.

**Explanation:** We use `AS` to rename columns, `INNER JOIN` to match facility IDs, filter by facility name and date range, and order by start time.

```sql
SELECT bk.starttime AS start, f.name 
FROM cd.bookings bk 
INNER JOIN cd.facilities f 
    ON f.facid = bk.facid
WHERE 
    f.name LIKE '%Tennis Court%' 
    AND bk.starttime >= '2012-09-21' 
    AND bk.starttime < '2012-09-22'
ORDER BY bk.starttime;
```

---

###### Question 14: Left Outer Join

Output a list of all members, including the individual who recommended them (if any). Ensure that results are ordered by surname, then firstname.

**Explanation:** We use a `LEFT OUTER JOIN` to keep all members, even those without a recommender. The left join keeps every row from m1 (main members table) and attempts to match each member with their recommender. For members without a recommender, the join keeps the m1 row and fills recommender columns with NULL.

```sql
SELECT m1.firstname, m1.surname, m2.firstname, m2.surname 
FROM cd.members m1
LEFT OUTER JOIN cd.members m2 
    ON m2.memid = m1.recommendedby 
ORDER BY m1.surname, m1.firstname;
```

---

###### Question 15: Self-Referencing Join with Distinct

Output a list of all members who have recommended another member. Ensure that there are no duplicates in the list, and that results are ordered by surname, then firstname.

**Explanation:** A self-referencing inner join with the `DISTINCT` keyword to select only unique entries.

```sql
SELECT DISTINCT m1.firstname, m1.surname 
FROM cd.members m1 
INNER JOIN cd.members m2 
    ON m1.memid = m2.recommendedby
ORDER BY m1.surname, m1.firstname;
```

---

###### Question 16: Subquery Alternative to Join

Produce a list of all members, along with their recommender, using no joins.

**Explanation:** We use concatenation to group firstname and surname into a name column. For the recommender, we use a subquery instead of a join, with a `WHERE` clause to ensure the recommender memid corresponds to the member they recommended.

```sql
SELECT DISTINCT  
    m1.firstname || ' ' || m1.surname AS member,
    (SELECT m2.firstname || ' ' || m2.surname 
     FROM cd.members m2 
     WHERE m2.memid = m1.recommendedby
    ) AS recommender
FROM cd.members m1
ORDER BY member;
```

---

###### Question 17: Aggregate Function with Group By

Produce a count of the number of recommendations each member has made. Order by member ID.

**Explanation:** We use the `COUNT` aggregate function which operates after `GROUP BY`. We group by the recommendedby column, exclude nulls with `WHERE`, and order by recommendedby.

```sql
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

---

###### Question 18: Sum with Group By

Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.

**Explanation:** We group by facid, sum the slots per group, and order by facid.

```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

---

###### Question 19: Filtered Aggregation

Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.

**Explanation:** Similar to Q18, but we add a `WHERE` clause to filter for September 2012 and order by the sum of slots.

```sql
SELECT facid, SUM(slots) AS "Total Slots" 
FROM cd.bookings 
WHERE 
    starttime >= '2012-09-01' 
    AND starttime < '2012-10-01' 
GROUP BY facid 
ORDER BY SUM(slots);
```

---

###### Question 20: Extract Date Components

Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

**Explanation:** We use the `EXTRACT` keyword to extract date components from a timestamp datatype.

```sql
SELECT 
    facid, 
    EXTRACT(MONTH FROM starttime) AS month, 
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, month
ORDER BY facid, month;
```

---

###### Question 21: Count Distinct

Find the total number of members (including guests) who have made at least one booking.

**Explanation:** We use `COUNT` with `DISTINCT` to count only unique members.

```sql
SELECT COUNT(DISTINCT memid) 
FROM cd.bookings;
```

---

###### Question 22: Minimum with Group By

Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.

**Explanation:** We use `MIN` to find the earliest booking date with `WHERE` to ensure it's after September 1st, 2012. We perform an `INNER JOIN` to list only members who have booked, then apply `GROUP BY` and `ORDER BY`.

```sql
SELECT m.surname, m.firstname, m.memid, MIN(b.starttime) AS starttime
FROM cd.members m
INNER JOIN cd.bookings b 
    ON b.memid = m.memid
WHERE starttime >= '2012-09-01'
GROUP BY m.surname, m.firstname, m.memid
ORDER BY m.memid;
```

---

###### Question 23: Window Function Basics

Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.

**Explanation:** We introduce window functions using the `OVER()` keyword. Here, `OVER()` contains nothing, which means the window includes all rows, giving us the same total count on each row.

```sql
SELECT COUNT(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;
```

---

###### Question 24: Row Numbering

Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.

**Explanation:** We use `ROW_NUMBER()` with `OVER(ORDER BY joindate)` to create sequential numbers based on join date, even though member IDs may not be sequential.

```sql
SELECT 
    ROW_NUMBER() OVER(ORDER BY joindate), 
    firstname, 
    surname
FROM cd.members
ORDER BY joindate;
```

---

###### Question 25: Ranking with Ties

Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.

**Explanation:** We use a subquery with the `RANK()` window function. The window range is ordered by the sum of slots descending, grouped by facility ID. We then filter for rank = 1 to get the highest (including ties).

```sql
SELECT facid, total 
FROM (
    SELECT 
        facid, 
        SUM(slots) AS total, 
        RANK() OVER(ORDER BY SUM(slots) DESC) AS rank 
    FROM cd.bookings 
    GROUP BY facid
) AS ranked
WHERE rank = 1;
```

---

###### Question 26: String Concatenation

Output the names of all members, formatted as 'Surname, Firstname'.

**Explanation:** We use `||` to concatenate strings, with any literal characters (like ', ') in quotes.

```sql
SELECT surname || ', ' || firstname AS name
FROM cd.members;
```

---

###### Question 27: Regular Expression Matching

Find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.

**Explanation:** `~` is PostgreSQL's regex operator. `[()]` is a regex character class that matches any phone number containing at least one parenthesis.

```sql
SELECT memid, telephone 
FROM cd.members 
WHERE telephone ~ '[()]'
ORDER BY memid;
```

---

###### Question 28: Substring and Grouping

Produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.

**Explanation:** We use `SUBSTR()` to get the first letter of the surname, `COUNT(*)` as the aggregate function, `GROUP BY` to create groups based on that first letter, and `ORDER BY` to sort alphabetically.

```sql
SELECT 
    SUBSTR(m.surname, 1, 1) AS letter, 
    COUNT(*) AS count 
FROM cd.members m
GROUP BY letter
ORDER BY letter;
```
