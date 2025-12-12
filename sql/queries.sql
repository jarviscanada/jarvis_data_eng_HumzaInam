-- ============================================
-- TABLE SETUP (DDL)
-- ============================================

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


-- ============================================
-- DATA MANIPULATION QUERIES
-- ============================================

-- Q1: Insert New Facility
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) 
VALUES 
    (9, 'Spa', 20, 30, 100000, 800);


-- Q2: Auto-generate Facility ID
INSERT INTO cd.facilities 
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT 
    (SELECT MAX(facid) + 1 FROM cd.facilities),
    'Spa', 20, 30, 100000, 800;


-- Q3: Update Existing Data
UPDATE cd.facilities 
SET initialoutlay = 10000 
WHERE facid = 1;


-- Q4: Update Based on Another Row (Original)
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

-- Q4: Update Based on Another Row (Simplified)
UPDATE cd.facilities f1 
SET 
    membercost = f2.membercost * 1.1, 
    guestcost = f2.guestcost * 1.1 
FROM 
    cd.facilities f2 
WHERE 
    f1.facid = 1 
    AND f2.facid = 0;


-- Q5: Delete All Bookings
DELETE FROM cd.bookings;


-- Q6: Delete Specific Member
DELETE FROM cd.members 
WHERE memid = 37;


-- Q7: Filter Facilities by Cost
SELECT facid, name, membercost, monthlymaintenance 
FROM cd.facilities 
WHERE 
    membercost > 0 
    AND membercost < monthlymaintenance / 50;


-- Q8: Pattern Matching
SELECT * 
FROM cd.facilities 
WHERE name LIKE '%Tennis%';


-- Q9: Multiple ID Match
SELECT * 
FROM cd.facilities 
WHERE facid IN (1, 5);


-- Q10: Date Filtering
SELECT memid, surname, firstname, joindate 
FROM cd.members
WHERE joindate >= '2012-09-01';


-- Q11: Combining Results
SELECT surname 
FROM cd.members
UNION
SELECT name 
FROM cd.facilities;


-- Q12: Inner Join
SELECT bk.starttime 
FROM cd.bookings bk
INNER JOIN cd.members m 
    ON m.memid = bk.memid
WHERE 
    m.firstname = 'David' 
    AND m.surname = 'Farrell';


-- Q13: Join with Date Range
SELECT bk.starttime AS start, f.name 
FROM cd.bookings bk 
INNER JOIN cd.facilities f 
    ON f.facid = bk.facid
WHERE 
    f.name LIKE '%Tennis Court%' 
    AND bk.starttime >= '2012-09-21' 
    AND bk.starttime < '2012-09-22'
ORDER BY bk.starttime;


-- Q14: Left Outer Join
SELECT m1.firstname, m1.surname, m2.firstname, m2.surname 
FROM cd.members m1
LEFT OUTER JOIN cd.members m2 
    ON m2.memid = m1.recommendedby 
ORDER BY m1.surname, m1.firstname;


-- Q15: Self-Referencing Join with Distinct
SELECT DISTINCT m1.firstname, m1.surname 
FROM cd.members m1 
INNER JOIN cd.members m2 
    ON m1.memid = m2.recommendedby
ORDER BY m1.surname, m1.firstname;


-- Q16: Subquery Alternative to Join
SELECT DISTINCT  
    m1.firstname || ' ' || m1.surname AS member,
    (SELECT m2.firstname || ' ' || m2.surname 
     FROM cd.members m2 
     WHERE m2.memid = m1.recommendedby
    ) AS recommender
FROM cd.members m1
ORDER BY member;


-- Q17: Aggregate Function with Group By
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;


-- Q18: Sum with Group By
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;


-- Q19: Filtered Aggregation
SELECT facid, SUM(slots) AS "Total Slots" 
FROM cd.bookings 
WHERE 
    starttime >= '2012-09-01' 
    AND starttime < '2012-10-01' 
GROUP BY facid 
ORDER BY SUM(slots);


-- Q20: Extract Date Components
SELECT 
    facid, 
    EXTRACT(MONTH FROM starttime) AS month, 
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, month
ORDER BY facid, month;


-- Q21: Count Distinct
SELECT COUNT(DISTINCT memid) 
FROM cd.bookings;


-- Q22: Minimum with Group By
SELECT m.surname, m.firstname, m.memid, MIN(b.starttime) AS starttime
FROM cd.members m
INNER JOIN cd.bookings b 
    ON b.memid = m.memid
WHERE starttime >= '2012-09-01'
GROUP BY m.surname, m.firstname, m.memid
ORDER BY m.memid;


-- Q23: Window Function Basics
SELECT COUNT(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;


-- Q24: Row Numbering
SELECT 
    ROW_NUMBER() OVER(ORDER BY joindate), 
    firstname, 
    surname
FROM cd.members
ORDER BY joindate;


-- Q25: Ranking with Ties
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


-- Q26: String Concatenation
SELECT surname || ', ' || firstname AS name
FROM cd.members;


-- Q27: Regular Expression Matching
SELECT memid, telephone 
FROM cd.members 
WHERE telephone ~ '[()]'
ORDER BY memid;


-- Q28: Substring and Grouping
SELECT 
    SUBSTR(m.surname, 1, 1) AS letter, 
    COUNT(*) AS count 
FROM cd.members m
GROUP BY letter
ORDER BY letter;
