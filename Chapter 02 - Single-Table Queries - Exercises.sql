---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 02 - Single-Table Queries
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1 
-- Return orders placed in June 2015
-- Tables involved: TSQLV4 database, Sales.Orders table

-- Desired output:
orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
10555       2015-06-02 71          6
10556       2015-06-03 73          2
10557       2015-06-03 44          9
10558       2015-06-04 4           1
10559       2015-06-05 7           6
10560       2015-06-06 25          8
10561       2015-06-06 24          2
10562       2015-06-09 66          1
10563       2015-06-10 67          2
10564       2015-06-10 65          4
...

(30 row(s) affected)

--Answer
USE TSQLV4;

SELECT orderid, orderdate, custid, empid
From Sales.Orders
Where orderdate >= '20150601'
AND orderdate <= '20150630';

/* Explanation -> The key here is the USE keyword and we are calling on TSQLV4. We are selecting from 4 columns
and from SALES.ORDER and it is a range of June 1st, 2015 to June 30th, 2015. */



-----------------------------------------------------------------------

-- 2 
-- Return orders placed on the last day of the month
-- Tables involved: Sales.Orders table

-- Desired output:
orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
10269       2014-07-31 89          5
10317       2014-09-30 48          6
10343       2014-10-31 44          4
10399       2014-12-31 83          8
10432       2015-01-31 75          3
10460       2015-02-28 24          8
10461       2015-02-28 46          1
10490       2015-03-31 35          7
10491       2015-03-31 28          8
10522       2015-04-30 44          4
...

(26 row(s) affected)
-- Answer
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

/* Explanation -> The EOMONTH method will catch the end-of-the-month; this is important because some months end on the 30th amd 31st 
and pesky February ends on the 28th or 29th. */

----------------------------------------------------------------------------

-- 3 
-- Return employees with last name containing the letter 'e' twice or more
-- Tables involved: HR.Employees table

-- Desired output:
empid       firstname  lastname
----------- ---------- --------------------
4           Yael       Peled
5           Sven       Mortensen

(2 row(s) affected)
-- Answer

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%'

/* Explanation -> I need to select from the employee id and the names. The %e%e% is the syntax that catches the letter e at least
twice. */



-----------------------------------------------------------------------------

-- 4 
-- Return orders with total value(qty*unitprice) greater than 10000
-- sorted by total value
-- Tables involved: Sales.OrderDetails table

-- Desired output:
orderid     totalvalue
----------- ---------------------
10865       17250.00
11030       16321.90
10981       15810.00
10372       12281.20
10424       11493.20
10817       11490.70
10889       11380.00
10417       11283.20
10897       10835.24
10353       10741.60
10515       10588.50
10479       10495.60
10540       10191.70
10691       10164.80

(14 row(s) affected)
--Answer

SELECT orderid, SUM(qty*unitprice) AS total
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000
ORDER BY total DESC;



/*Explanation -> The key here is the HAVING keyword which will catch the orders that have a total value of greater than 10,000.
DESC will sort in Descending Order. */



---------------------------------------------------------------------------------
-- 5
-- Write a query against the HR.Employees table that returns employees
-- with a last name that starts with a lower case letter.
-- Remember that the collation of the sample database
-- is case insensitive (Latin1_General_CI_AS).
-- For simplicity, you can assume that only English letters are used
-- in the employee last names.
-- Tables involved: Sales.OrderDetails table

-- Desired output:
empid       lastname
----------- --------------------

(0 row(s) affected)
--Answer
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';


/* Explanation -> The COLLATE keyword will put things in proper order and Latin1_General_CS_AS will revert the string after the
LIKE keyword in a case insensitive set of characters. I needed to include all the lower-case letters. There was no such case of 
this hiccup when I executed the code. */



--------------------------------------------------------------------------------

-- 6
-- Explain the difference between the following two queries

-- Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

-- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

-- Answer

/*The main difference is query 1 uses the WHERE keyword which in SQL means you are filtering data.
Whilst query 2 uses the HAVING keyword which filters based on an aggregate function; in this case the MAX function. */



----------------------------------------------------------------------------------------

-- 7 
-- Return the three ship countries with the highest average freight for orders placed in 2015
-- Tables involved: Sales.Orders table

-- Desired output:
shipcountry     avgfreight
--------------- ---------------------
Austria         178.3642
Switzerland     117.1775
Sweden          105.16

(3 row(s) affected)
--Answer
SELECT TOP (3) shipcountry, AVG(freight) AS freightmean
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate <= '20150131'
GROUP BY shipcountry
ORDER BY freightmean DESC;


/* Explanation -> The key here is TOP (3) which returns the top based on the AVG(average) keyword and within the range of May 1st
2015 and May 31st 2015. We also need to group it by country from where it is shipped. */


----------------------------------------------------------------------------------------------

-- 8 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

-- Desired output:
custid      orderdate  orderid     rownum
----------- ---------- ----------- --------------------
1           2015-08-25 10643       1
1           2015-10-03 10692       2
1           2015-10-13 10702       3
1           2016-01-15 10835       4
1           2016-03-16 10952       5
1           2016-04-09 11011       6
2           2014-09-18 10308       1
2           2015-08-08 10625       2
2           2015-11-28 10759       3
2           2016-03-04 10926       4
...

(830 row(s) affected)
--Answer
SELECT custid, orderdate, orderid,
	ROW_NUMBER() OVER(PARTITION by custid ORDER BY orderdate, orderid) AS rownumber
FROM SALES.Orders
ORDER BY custid, rownumber;

/*Explanation -> The key to this snippet is the PARTITION keyword which will order the customer id
information based first on the order date and if there is a matching order date, the next separator will be the 
order id number. This makes sense because the earlier order id number would precede the later one even if the dates are the same. */


---------------------------------------------------------------------------------

-- 9
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table

-- Desired output:
empid       firstname  lastname             titleofcourtesy           gender
----------- ---------- -------------------- ------------------------- -------
1           Sara       Davis                Ms.                       Female
2           Don        Funk                 Dr.                       Unknown
3           Judy       Lew                  Ms.                       Female
4           Yael       Peled                Mrs.                      Female
5           Sven       Mortensen            Mr.                       Male
6           Paul       Suurs                Mr.                       Male
7           Russell    King                 Mr.                       Male
8           Maria      Cameron              Ms.                       Female
9           Patricia   Doyle                Ms.                       Female

(9 row(s) affected)
--Answer

SELECT empid, firstname, lastname, titleofcourtesy,
	CASE titleofcourtesy
		WHEN 'Mr.' THEN 'Male'
		WHEN 'Ms.' THEN 'Female'
		WHEN 'Mrs.' THEN 'Female'
		ELSE 'Unknown'
	END AS gender
	FROM HR.Employees;

/* Explanation -> This snippet runs through the column of titleofcourtesy and then appropriately matches the gender 
and then create a new gender column. The WHEN and THEN is influential with this assignment. */


---------------------------------------------------------------------------------------
-- 10
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULLs sort first
-- Tables involved: Sales.Customers table

-- Desired output:
custid      region
----------- ---------------
55          AK
10          BC
42          BC
45          CA
37          Co. Cork
33          DF
71          ID
38          Isle of Wight
46          Lara
78          MT
...
1           NULL
2           NULL
3           NULL
4           NULL
5           NULL
6           NULL
7           NULL
8           NULL
9           NULL
11          NULL
...

(91 row(s) affected)
--Answer

SELECT custid, region
FROM Sales.Customers
ORDER BY
	CASE WHEN region IS NULL THEN 1 ELSE 0 END, region;

/*Explanation-> This snippet will select from customer id and region and sort the nulls so that they are assigned a customer id starting at
1 and then in ascending order but this is only done after sorting the non-null values. */





------------------------------------------------------------------