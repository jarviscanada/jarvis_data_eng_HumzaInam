# SQL Query Reference Guide

## Overview
This guide contains SQL queries for a club management database system. The database tracks members, facilities, and bookings for a recreational club.

## Database Schema

### Table Structure
- **members**: Stores member information including contact details and referrals
- **facilities**: Contains club facilities with pricing and maintenance costs
- **bookings**: Records facility reservations made by members

### Table Setup (DDL)

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

**Key Relationships:**
- `members.recommendedby` → self-referencing foreign key to track member referrals
- `bookings.facid` → references `facilities.facid`
- `bookings.memid` → references `members.memid`

---

## Q1: Insert New Facility
**Problem:** Add a new spa facility to the facilities table.

**Solution:** We use the `INSERT` keyword to add data, the `INTO` keyword to select which table, followed by the column names we wish to insert into, and then the `VALUES` keyword to input the new data.

```sql
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) 
VALUES 
    (9, 'Spa', 20, 30, 100000, 800);
```

---

## Q2: Auto-generate Facility ID
**Problem:** Add the spa again, but automatically generate the next facid value.

**Solution:** We don't use `VALUES` since that's for constants. Here we use a subquery to retrieve the highest facid and add one to it, simulating auto-generation.

```sql
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT 
    (SELECT MAX(facid) + 1 FROM cd.facilities),
    'Spa', 20, 30, 100000, 800;
```

---

## Q3: Update Existing Data
**Problem:** Fix the initial outlay for the second tennis court (should be 10000, not 8000).

**Solution:** We use the `UPDATE` keyword to indicate we wish to update, then specify the table, use the `SET` keyword to set a column value, and use `WHERE` to target the specific row. We select by primary key (facid) rather than name to ensure we're updating the correct record.

```sql
UPDATE cd.facilities 
SET initialoutlay = 10000 
WHERE facid = 1;
```

---

## Q4: Update Based on Another Row
**Problem:** Make the second tennis court cost 10% more than the first one, without using constant values.

**Solution:** I used the `UPDATE` keyword to update the prices. PostgreSQL provides a `FROM` clause that allows us to generate values for use in the `SET` clause. This simplified version uses aliases (f1 for the second court, f2 for the first court) to reference both rows.

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

## Q5: Delete All Bookings
**Problem:** Delete all bookings from the bookings table.

**Solution:** We use the `DELETE` keyword followed by `FROM` to indicate which table. Because there are no conditions, we delete all values from that table.

```sql
DELETE FROM cd.bookings;
```

---

## Q6: Delete Specific Member
**Problem:** Remove member 37, who has never made a booking.

**Solution:** Similar to Q5, but here we add a `WHERE` clause to target only member 37.

```sql
DELETE FROM cd.members 
WHERE memid = 37;
```

---

## Q7: Filter Facilities by Cost
**Problem:** List facilities that charge members a fee less than 1/50th of the monthly maintenance cost.

**Solution:** Straightforward query ensuring membercost is greater than 0 and less than 1/50th of monthly maintenance.

```sql
SELECT facid, name, membercost, monthlymaintenance 
FROM cd.facilities 
WHERE 
    membercost > 0 
    AND membercost < monthlymaintenance / 50;
```

---

## Q8: Pattern Matching
**Problem:** List all facilities with 'Tennis' in their name.

**Solution:** We use the `LIKE` keyword to match a string pattern. The `%` symbols before and after 'Tennis' represent that there can be any characters (or none) before and after the phrase.

```sql
SELECT * 
FROM cd.facilities 
WHERE name LIKE '%Tennis%';
```

---

## Q9: Multiple ID Match
**Problem:** Retrieve facilities with ID 1 and 5 without using the OR operator.

**Solution:** The `IN` keyword allows us to match against a list of values.

```sql
SELECT * 
FROM cd.facilities 
WHERE facid IN (1, 5);
```

---

## Q10: Date Filtering
**Problem:** List members who joined after September 1st, 2012.

**Solution:** We use `WHERE` with date comparison operators.

```sql
SELECT memid, surname, firstname, joindate 
FROM cd.members
WHERE joindate >= '2012-09-01';
```

---

## Q11: Combining Results
**Problem:** Create a combined list of all surnames and facility names.

**Solution:** We use `UNION` to combine entries from both tables into a single result set. `UNION` removes duplicates; use `UNION ALL` to keep duplicates.

```sql
SELECT surname 
FROM cd.members
UNION
SELECT name 
FROM cd.facilities;
```

---

## Q12: Inner Join
**Problem:** List start times for bookings by members named 'David Farrell'.

**Solution:** We use aliases (bk for bookings, m for members) and perform an `INNER JOIN`, which returns only rows that have a match in both tables.

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

## Q13: Join with Date Range
**Problem:** List start times for tennis court bookings on September 21st, 2012, ordered by time.

**Solution:** We use `AS` to rename columns, `INNER JOIN` to match facility IDs, filter by facility name and date range, and order by start time.

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

## Q14: Left Outer Join
**Problem:** List all members with their recommenders (if any), ordered by surname and firstname.

**Solution:** We use a `LEFT OUTER JOIN` to keep all members, even those without a recommender. The left join keeps every row from m1 (main members table) and attempts to match each member with their recommender. For members without a recommender, the join keeps the m1 row and fills recommender columns with NULL.

```sql
SELECT m1.firstname, m1.surname, m2.firstname, m2.surname 
FROM cd.members m1
LEFT OUTER JOIN cd.members m2 
    ON m2.memid = m1.recommendedby 
ORDER BY m1.surname, m1.firstname;
```

---

## Q15: Self-Referencing Join with Distinct
**Problem:** List all members who have recommended another member, with no duplicates.

**Solution:** A self-referencing inner join with the `DISTINCT` keyword to select only unique entries.

```sql
SELECT DISTINCT m1.firstname, m1.surname 
FROM cd.members m1 
INNER JOIN cd.members m2 
    ON m1.memid = m2.recommendedby
ORDER BY m1.surname, m1.firstname;
```

---

## Q16: Subquery Alternative to Join
**Problem:** List all members with their recommender, using no joins.

**Solution:** We use concatenation to group firstname and surname into a name column. For the recommender, we use a subquery instead of a join, with a `WHERE` clause to ensure the recommender memid corresponds to the member they recommended.

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

## Q17: Aggregate Function with Group By
**Problem:** Count the number of recommendations each member has made, ordered by member ID.

**Solution:** We use the `COUNT` aggregate function which operates after `GROUP BY`. We group by the recommendedby column, exclude nulls with `WHERE`, and order by recommendedby.

```sql
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

---

## Q18: Sum with Group By
**Problem:** List the total number of slots booked per facility, sorted by facility ID.

**Solution:** We group by facid, sum the slots per group, and order by facid.

```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

---

## Q19: Filtered Aggregation
**Problem:** List total slots booked per facility in September 2012, sorted by number of slots.

**Solution:** Similar to Q18, but we add a `WHERE` clause to filter for September 2012 and order by the sum of slots.

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

## Q20: Extract Date Components
**Problem:** List total slots booked per facility per month in 2012, sorted by facility ID and month.

**Solution:** We use the `EXTRACT` keyword to extract date components from a timestamp datatype.

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

## Q21: Count Distinct
**Problem:** Find the total number of members (including guests) who have made at least one booking.

**Solution:** We use `COUNT` with `DISTINCT` to count only unique members.

```sql
SELECT COUNT(DISTINCT memid) 
FROM cd.bookings;
```

---

## Q22: Minimum with Group By
**Problem:** List each member's name, ID, and their first booking after September 1st, 2012, ordered by member ID.

**Solution:** We use `MIN` to find the earliest booking date with `WHERE` to ensure it's after September 1st, 2012. We perform an `INNER JOIN` to list only members who have booked, then apply `GROUP BY` and `ORDER BY`.

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

## Q23: Window Function Basics
**Problem:** List member names with each row containing the total member count, ordered by join date.

**Solution:** We introduce window functions using the `OVER()` keyword. Here, `OVER()` contains nothing, which means the window includes all rows, giving us the same total count on each row.

```sql
SELECT COUNT(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;
```

---

## Q24: Row Numbering
**Problem:** Produce a numbered list of members ordered by join date.

**Solution:** We use `ROW_NUMBER()` with `OVER(ORDER BY joindate)` to create sequential numbers based on join date, even though member IDs may not be sequential.

```sql
SELECT 
    ROW_NUMBER() OVER(ORDER BY joindate), 
    firstname, 
    surname
FROM cd.members
ORDER BY joindate;
```

---

## Q25: Ranking with Ties
**Problem:** Output the facility ID with the highest number of slots booked, including all ties.

**Solution:** We use a subquery with the `RANK()` window function. The window range is ordered by the sum of slots descending, grouped by facility ID. We then filter for rank = 1 to get the highest (including ties).

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

## Q26: String Concatenation
**Problem:** Format member names as 'Surname, Firstname'.

**Solution:** We use `||` to concatenate strings, with any literal characters (like ', ') in quotes.

```sql
SELECT surname || ', ' || firstname AS name
FROM cd.members;
```

---

## Q27: Regular Expression Matching
**Problem:** Find telephone numbers containing parentheses, sorted by member ID.

**Solution:** `~` is PostgreSQL's regex operator. `[()]` is a regex character class that matches any phone number containing at least one parenthesis.

```sql
SELECT memid, telephone 
FROM cd.members 
WHERE telephone ~ '[()]'
ORDER BY memid;
```

---

## Q28: Substring and Grouping
**Problem:** Count how many members have surnames starting with each letter, sorted alphabetically.

**Solution:** We use `SUBSTR()` to get the first letter of the surname, `COUNT(*)` as the aggregate function, `GROUP BY` to create groups based on that first letter, and `ORDER BY` to sort alphabetically.

```sql
SELECT 
    SUBSTR(m.surname, 1, 1) AS letter, 
    COUNT(*) AS count 
FROM cd.members m
GROUP BY letter
ORDER BY letter;
```
