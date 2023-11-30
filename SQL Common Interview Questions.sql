-- 1. 2nd or 3rd Highest salary using atleast 3 different queries.
# Using SubQuery- 2nd highest salary
SELECT MAX(SALARY) AS 2nd_HIGHEST_SALARY FROM EMPLOYEES
WHERE SALARY < (SELECT MAX(SALARY) FROM EMPLOYEES);

# Using SubQuery- 3rd highest salary
SELECT MAX(SALARY) AS 3rd_HIGHEST_SALARY FROM EMPLOYEES
WHERE SALARY < (SELECT MAX(SALARY) FROM EMPLOYEES
				WHERE SALARY < (SELECT MAX(SALARY) FROM EMPLOYEES));

# Using Limit and Offset- This will not work when we have multiple entries with same salary
SELECT SALARY AS 2nd_HIGHEST_SALARY FROM EMPLOYEES
ORDER BY SALARY DESC
LIMIT 1 OFFSET 1;

# Using Dense_Rank function
SELECT SALARY FROM (SELECT SALARY, DENSE_RANK() OVER (ORDER BY SALARY DESC) AS SALARY_RANK FROM EMPLOYEES) AS RANKED_SALARIES
WHERE SALARY_RANK = 2
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------

-- 2. Highest salary from each department
# Using group by and order by
SELECT DEPARTMENT_ID, MAX(SALARY) AS MAX_SALARY FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
ORDER BY MAX_SALARY DESC;

# Using Row_Number and Partition By function
SELECT DEPARTMENT_ID, SALARY FROM (SELECT DEPARTMENT_ID, SALARY, ROW_NUMBER() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY DESC) AS SALARY_RANK
FROM EMPLOYEES) AS RANKED_SALARIES
WHERE SALARY_RANK = 1;

------------------------------------------------------------------------------------------------------------------------------

-- 3. Second highest salary from each department
# Using subquery with group by
SELECT DEPARTMENT_ID, MAX(SALARY) AS SECOND_HIGHEST_SALARY FROM EMPLOYEES E1
WHERE SALARY < (SELECT MAX(SALARY) FROM EMPLOYEES E2
				WHERE E1.DEPARTMENT_ID = E2.DEPARTMENT_ID)
GROUP BY DEPARTMENT_ID;

# Using windows function
SELECT DEPARTMENT_ID, SALARY FROM (SELECT DEPARTMENT_ID, SALARY, ROW_NUMBER() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY DESC) AS SALARY_RANK
FROM EMPLOYEES) AS RANKED_SALARIES
WHERE SALARY_RANK = 2;

------------------------------------------------------------------------------------------------------------------------------

-- 4. Find the employee and manager from the same table using self join query
SELECT E1.EMPLOYEE_ID, CONCAT(E1.FIRST_NAME, " ", E1.LAST_NAME) AS FULL_NAME, E2.MANAGER_ID FROM EMPLOYEES E1
INNER JOIN EMPLOYEES E2
ON E1.EMPLOYEE_ID = E2.MANAGER_ID
GROUP BY FULL_NAME;

------------------------------------------------------------------------------------------------------------------------------

-- 5. Ranking function (Rank, Dense Rank and Row Number)
#RANK() OVER (ORDER BY SALARY DESC) AS SALARY_RANK: This assigns a rank to each row based on the salary in descending order.
												  -- Ties get the same rank, and the next rank is skipped.
#DENSE_RANK() OVER (ORDER BY SALARY DESC) AS DENSE_SALARY_RANK: Similar to RANK, but without skipping the next rank for ties.
												  -- Ties get the same rank, and the next rank is not skipped.
#ROW_NUMBER() OVER (ORDER BY SALARY DESC) AS SALARY_ROW_NUMBER: This function assigns a unique number to each row based on the salary in descending order.
												  -- It doesn't handle ties; each row gets a unique number.
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY,
    RANK() OVER (ORDER BY SALARY DESC) AS SALARY_RANK,
    DENSE_RANK() OVER (ORDER BY SALARY DESC) AS DENSE_SALARY_RANK,
    ROW_NUMBER() OVER (ORDER BY SALARY DESC) AS SALARY_ROW_NUMBER
FROM HR.EMPLOYEES;

------------------------------------------------------------------------------------------------------------------------------

-- 6. Complex join queries
#A. Write a SQL query to find those employees whose department is located at ‘Toronto’. Return first name, last name, employee ID, job ID.
SELECT FIRST_NAME, LAST_NAME, EMPLOYEE_ID, JOB_ID, EMPLOYEES.DEPARTMENT_ID, CITY FROM EMPLOYEES
RIGHT JOIN DEPARTMENTS
ON DEPARTMENTS.DEPARTMENT_ID = EMPLOYEES.DEPARTMENT_ID
INNER JOIN LOCATIONS
ON LOCATIONS.LOCATION_ID = DEPARTMENTS.LOCATION_ID
WHERE LOCATIONS.CITY = 'TORONTO';

#B. Write a SQL query to find employees who work in departments located in the United Kingdom. Return first name.
SELECT EMPLOYEE_ID, FIRST_NAME, COUNTRY_NAME FROM EMPLOYEES
INNER JOIN DEPARTMENTS
ON DEPARTMENTS.DEPARTMENT_ID=EMPLOYEES.DEPARTMENT_ID
INNER JOIN LOCATIONS
ON DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID
INNER JOIN COUNTRIES
ON COUNTRIES.COUNTRY_ID=LOCATIONS.COUNTRY_ID
WHERE COUNTRY_NAME='UNITED KINGDOM';

#C. Write a SQL query find the employees who report to a manager based in the United States. Return first name, last name.
SELECT FIRST_NAME, LAST_NAME, COUNTRY_ID FROM EMPLOYEES
INNER JOIN DEPARTMENTS
ON DEPARTMENTS.MANAGER_ID=EMPLOYEES.MANAGER_ID
INNER JOIN LOCATIONS
ON DEPARTMENTS.LOCATION_ID=DEPARTMENTS.LOCATION_ID
WHERE LOCATIONS.COUNTRY_ID='US';

#D. Write a SQL query to search for employees who receive such a salary, which is the maximum salary for salaried employees, 
	-- hired between January 1st, 1987 and December 31st, 1999. Return employee ID, first name, last name, salary, department name and city.
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY, HIRE_DATE, DEPARTMENTS.DEPARTMENT_NAME, LOCATIONS.CITY FROM EMPLOYEES
INNER JOIN DEPARTMENTS
ON EMPLOYEES.DEPARTMENT_ID=DEPARTMENTS.DEPARTMENT_ID
INNER JOIN LOCATIONS
ON DEPARTMENTS.LOCATION_ID=LOCATIONS.LOCATION_ID
WHERE EMPLOYEES.HIRE_DATE BETWEEN '1987-01-01' AND '1999-12-31' AND
SALARY = (SELECT MAX(SALARY) FROM EMPLOYEES);

#E. write a SQL query to find full name (first and last name), job title, start and end date of last jobs of employees 
-- who did not receive commissions.
SELECT CONCAT(FIRST_NAME," ", LAST_NAME) AS EMPLOYEE_NAME, JOB_TITLE, H.* FROM EMPLOYEES AS E
JOIN (SELECT MAX(START_DATE), MAX(END_DATE), EMPLOYEE_ID FROM JOB_HISTORY GROUP BY EMPLOYEE_ID) AS H
ON E.EMPLOYEE_ID = H.EMPLOYEE_ID
JOIN JOBS AS J
ON E.JOB_ID = J.JOB_ID
WHERE E.COMMISSION_PCT IS NULL;

------------------------------------------------------------------------------------------------------------------------------

-- 7. Complex sub queries
#A. Write a SQL query to find those employees who work in a department where the employee’s first name contains the letter 'T'.
	-- Return employee ID, first name and last name.
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, DEPARTMENT_ID FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES WHERE FIRST_NAME LIKE '%T%');

#B. Write a SQL query to find those employees who earn more than the average salary and work in the same department as an employee whose 
	-- first name contains the letter 'J'. Return employee ID, first name and salary.
SELECT EMPLOYEE_ID, FIRST_NAME, SALARY, DEPARTMENT_ID FROM EMPLOYEES
WHERE (SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES)) AND
(DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES WHERE FIRST_NAME LIKE '%J%'));

#C. Write a query to display the employee id, name, SalaryDrawn, AvgCompare (salary - the average salary of all employees) and
	-- the SalaryStatus column with a title HIGH and LOW respectively for those employees whose salary is more than and less than
	-- the average salary of all employees
SELECT EMPLOYEE_ID, FIRST_NAME, SALARY AS SALARY_DRAWN,
ROUND((SALARY - (SELECT AVG(SALARY) FROM EMPLOYEES)), 2) AS AVG_COMPARE,
CASE WHEN SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES) THEN 'HIGH'
	 ELSE 'LOW'
     END SALARY_STATUS FROM EMPLOYEES;
     
#D. Write a SQL query find the employees who report to a manager based in the United States. Return first name, last name.
SELECT FIRST_NAME, LAST_NAME FROM EMPLOYEES
WHERE MANAGER_ID IN (SELECT MANAGER_ID FROM EMPLOYEES
					WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM DEPARTMENTS
					WHERE LOCATION_ID IN (SELECT LOCATION_ID FROM LOCATIONS
					WHERE COUNTRY_ID='US')));

#E. Write a SQL query to find all employees whose department is located in London. Return first name, last name, salary, and department ID.
SELECT FIRST_NAME, LAST_NAME, SALARY, DEPARTMENT_ID FROM EMPLOYEES
WHERE DEPARTMENT_ID = ALL (SELECT DEPARTMENT_ID FROM DEPARTMENTS
						   WHERE LOCATION_ID = (SELECT LOCATION_ID FROM LOCATIONS
												WHERE CITY='LONDON'));
                                                
------------------------------------------------------------------------------------------------------------------------------
                                                
-- 8. The order of SQL clauses
#Syandard order of cluase in sql queries
SELECT column1, column2, ., ., .,
FROM table1
JOIN table2 ON table1.column = table2.column
WHERE condition
GROUP BY column1
HAVING condition
ORDER BY column1 ASC/DESC, column2 ASC/DESC, ...
LIMIT 1 OFFSET 2;

------------------------------------------------------------------------------------------------------------------------------

-- 9. What are NVL and NVL2 functions?
# The NVL function in Oracle is used to replace a null value with a specified default value.
# The NVL2 function in Oracle is used to return one value if a specified expression is not null and another value if the expression is null.
# NLV and NVL2 are not available in MySQL, instead we can use "COALESCE".
SELECT COMMISSION_PCT, COALESCE(COMMISSION_PCT, 0) AS NEW_COMMISSION_PCT FROM EMPLOYEES;

SELECT COMMISSION_PCT, CASE WHEN COMMISSION_PCT IS NOT NULL THEN COMMISSION_PCT ELSE 0
END AS NEW_COMMISSION_PCT FROM EMPLOYEES;

------------------------------------------------------------------------------------------------------------------------------

-- 10. What is Surrogate key and how it works?
# A surrogate key is like a tag or label that we give to each row in a database table to uniquely identify it.
-- This tag is generated by the system and doesn't carry any real-world meaning. It's just a way for the computer to keep track of different rows easily.
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_NAME VARCHAR(50),
    PLACE VARCHAR(50));
-- Here customer_id is surrogate key, which is unique and doesnt carry any real world meaning.
------------------------------------------------------------------------------------------------------------------------------

-- 11. What are Facts and dimension and their types.
# Facts: Facts are quantitative data that can be measured and analyzed.
		 -- They represent the business metrics or measures around which an organization wants to analyze and make decisions.
		 -- They are usually Numeric values, mathematics operations cn be performed.
		 -- Examples: sales amount, quantity sold, profit, revenue, etc.
	-- Types of Facts:
		 -- Additive Facts: Measures that can be summed up across all dimensions.
			-- Example: sales amount is additive because you can sum it across products, regions, and time periods.
		 -- Semi-Additive Facts: Measures that can be summed up across some dimensions but not all.
			-- Example: inventory levels can be summed up across products but not across time.
		 -- Non-Additive Facts: Measures that cannot be summed up.
			--  Example: Ratios, percentages, and averages.
# Dimensions: Dimensions are descriptive data elements that provide context to the facts. They are the categories by which we want to analyze and filter the facts.
		-- Qualitative attributes that provide context to quantitative measures.
		-- Examples: time, geography, product, customer, etc.
	-- Types of Dimensions:
		-- Conformed Dimensions: Dimensions that are shared and consistent across multiple data marts or data warehouses in an organization.
			-- Example: a common date dimension used across various data marts.
		-- Junk Dimensions: Dimensions that contain flags or indicators rather than descriptive attributes.
			-- Example: a flag indicating whether a customer has made a purchase in a given time period.
		-- Role-Playing Dimensions: Dimensions that are used multiple times in a fact table, but each instance represents a different role.
			-- Example: a date dimension used for order date and ship date in the same fact table.
		-- Slowly Changing Dimensions (SCD): Dimensions that change slowly over time. There are three types of SCDs:
			-- Type 1 SCD: Overwrites old data with new data.
			-- Type 2 SCD: Adds a new row to the dimension table to represent the change.
			-- Type 3 SCD: Creates a new column in the dimension table to store the new data, preserving the old value.
            
------------------------------------------------------------------------------------------------------------------------------

-- 12. Write a query to find the cumulative summation of employees salary
SELECT EMPLOYEE_ID, SALARY, SUM(SALARY) OVER (ORDER BY EMPLOYEE_ID) AS CUMULATIVE_SALARY FROM EMPLOYEES;

------------------------------------------------------------------------------------------------------------------------------

-- 13. Write a query find the manager’s id of all the employees?
SELECT E1.EMPLOYEE_ID, E1.MANAGER_ID, CONCAT(E2.FIRST_NAME, " ", E2.LAST_NAME) AS MANAGER_NAME FROM EMPLOYEES E1
JOIN EMPLOYEES E2 ON E1.MANAGER_ID = E2.EMPLOYEE_ID;

------------------------------------------------------------------------------------------------------------------------------

-- 14. Write a query find the credit card is valid or not?
# Dont have credit card database so lets check phone number is valid or not.
SELECT PHONE_NUMBER,
CASE WHEN PHONE_NUMBER REGEXP '^[0-9]{10}$' THEN 'Valid' ELSE 'Invalid'
END AS VALIDATION_STATUS FROM EMPLOYEES;

------------------------------------------------------------------------------------------------------------------------------

-- 15. Write a query to find the duplicate with different ways?
# Using Groupy By Having and Count
SELECT FIRST_NAME, COUNT(*) FROM EMPLOYEES
GROUP BY FIRST_NAME
HAVING COUNT(*) > 1;

# uning Row_Number
SELECT FIRST_NAME FROM (SELECT FIRST_NAME, ROW_NUMBER() OVER (PARTITION BY FIRST_NAME ORDER BY EMPLOYEE_ID) AS ROW_NUM FROM EMPLOYEES) AS NUMBERED_ROWS
WHERE ROW_NUM > 1;

------------------------------------------------------------------------------------------------------------------------------

-- 16. What are the ways to improve the performance of the query?
# Use Indexing: Index the columns used in WHERE, JOIN, and ORDER BY clauses.
# Optimize Database Design: Organize your database efficiently, and choose the right data types.
# Write Efficient Queries: Keep queries simple and use the EXPLAIN statement to check their efficiency.
# Limit Results: Only retrieve the columns you need, and use LIMIT for result set size.
# Optimize Joins: Prefer INNER JOIN over OUTER JOIN, and limit the number of joins.
# Partition Large Tables: Divide large tables into smaller partitions for better performance.
# Update Statistics: Regularly update table statistics for better query optimization.
# Upgrade MySQL: Keep your MySQL version up-to-date for performance improvements.
# Avoid SELECT * : Select only the necessary columns to reduce data processing.

------------------------------------------------------------------------------------------------------------------------------

-- 17. Get all employee detail from Employeess table whose “FirstName” not start with any single character between ‘a-p’
SELECT FIRST_NAME FROM EMPLOYEES
WHERE NOT (FIRST_NAME REGEXP '^[A-Pa-p]');

------------------------------------------------------------------------------------------------------------------------------

-- 18. Write a SQL Query find number of employees according to commission_pct category, null and non_null, whose hire_date is between 01/01/1990 to 31/12/1995.
#Database not contains any gender columns so lets consider commission_pct.
SELECT CASE WHEN COMMISSION_PCT IS NULL THEN 'NO_COMMISSION' ELSE 'COMMISSION'
END AS COMMISSION_CATEGORY, COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEES
WHERE HIRE_DATE BETWEEN '1995-01-01' AND '1999-12-31'
GROUP BY COMMISSION_CATEGORY;

------------------------------------------------------------------------------------------------------------------------------

-- 19. How to fetch alternate records (even rows) from a table?
SELECT * FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY EMPLOYEE_ID) AS ROWNUMBER FROM EMPLOYEES) AS NUMBERED_ROW
WHERE ROWNUMBER % 2 = 0;

------------------------------------------------------------------------------------------------------------------------------

-- 20. Get Student/EMPLOYEES details from Student/EMPLOYEES table whose first name ends with ‘n’
SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE '%N';

------------------------------------------------------------------------------------------------------------------------------

-- 21. Get Student/EMPLOYEES details from Student/EMPLOYEES table whose first name starts with ‘J’ and name contains 4 letters.
SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE 'J%' AND LENGTH(FIRST_NAME)=4;

------------------------------------------------------------------------------------------------------------------------------

-- 22. Get Student/EMPLOYEES details from Student/EMPLOYEES table whose Fee/SALARY between 5000 and 8000.
SELECT * FROM EMPLOYEES
WHERE SALARY BETWEEN 5000 AND 8000;

------------------------------------------------------------------------------------------------------------------------------

-- 23. Get Student/EMPLOYEES details from Student/EMPLOYEES table whose name is ‘LEX’ and ‘BRUCE’.
SELECT * FROM EMPLOYEES
WHERE FIRST_NAME ='LEX' OR FIRST_NAME= 'BRUCE';

------------------------------------------------------------------------------------------------------------------------------

-- 24. How to find out the duplicate records from table?
SELECT EMPLOYEE_ID, FIRST_NAME, COUNT(*) FROM EMPLOYEES
GROUP BY FIRST_NAME
HAVING COUNT(*) > 1;

------------------------------------------------------------------------------------------------------------------------------

-- 25. How to find out the nth highest salary from a table?
SELECT SALARY FROM (SELECT SALARY, DENSE_RANK() OVER (ORDER BY SALARY DESC) AS SALARY_RANK FROM EMPLOYEES) AS RANKED_SALARIES
WHERE SALARY_RANK = 9
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------

-- 26. What will be the output of below queries:
#a. Select * from t_name where rownum=1;
-- It will return me a first row of the table. But this is not the standard way to see the first row from the table.
-- In MySQL DBMS system we use ORDER BY and then the LIMIT 1 to see the first row.

#b. Select * from t_name where rownum<=1;
-- Again it just used to retrieve 1st row. But this is not supported keyword in MySQL.

#c. Select * from t_name where rownum=2;
-- Used to retrive 2nd row from table.

#d. Select * from t_name where rownum>1;
-- Used to retrive all rows except 1st row.

------------------------------------------------------------------------------------------------------------------------------

-- 27. What will happen if I will write like
-- A. Create table t_name as select * from t_name2;

# A new table named t_name is created with the same columns and data types as the t_name2 table.
# All the rows from the t_name2 table are copied into the newly created t_name table.

-- B. Will all the constraint or index will come to the new table same like the old table?
# The new table (t_name) will inherit the indexes defined on the columns in t_name2.
# Primary key constraints and unique constraints on columns will also be inherited.
# The AUTO_INCREMENT attribute for primary key columns is retained in the new table.
# Foreign key constraints, Check constraints and These database objects are not copied to the new table.

------------------------------------------------------------------------------------------------------------------------------

-- 28. How to find out the 2nd row of a table.
SELECT * FROM EMPLOYEES
GROUP BY EMPLOYEE_ID
LIMIT 1 OFFSET 1;

SELECT * FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY EMPLOYEE_ID) AS ROW_NUM FROM EMPLOYEES) AS NUMBERED_ROWS
WHERE ROW_NUM = 2;

------------------------------------------------------------------------------------------------------------------------------

-- 29. All types of joins.
#1. INNER JOIN: Returns only the rows with matching values in both tables.
				-- Rows without matches are excluded from the result.
#2. LEFT JOIN (or LEFT OUTER JOIN): Returns all rows from the left table and the matching rows from the right table.
				-- If there's no match, NULL values are used for columns from the right table.
#3. RIGHT JOIN (or RIGHT OUTER JOIN): Returns all rows from the right table and the matching rows from the left table.
				-- If there's no match, NULL values are used for columns from the left table.
#4. FULL JOIN (or FULL OUTER JOIN): Returns all rows when there's a match in either the left or the right table.
				-- If there's no match, NULL values are used for columns from the table without a match.
#5. CROSS JOIN: Generates the Cartesian product of rows from both tables, creating all possible combinations of rows.
#6. SELF JOIN: Joins a table with itself. Useful for comparing rows within the same table.

------------------------------------------------------------------------------------------------------------------------------

-- 30. Should have good knowledge of ‘WITH’ keyword. So many queries were there on with clause.
# This keyword is not supported in MYSQL.
# In general with is used to create temperory result. This can be achieved by SUBQUERY in MySQL.

------------------------------------------------------------------------------------------------------------------------------

-- 31. How to insert records into multiple tables using single select statements.
INSERT INTO table1 (column1, column2, . . . )
SELECT columnA, columnB, . . .
FROM source_table;

-- Create sample tables
CREATE TABLE employees (
	employee_id INT,
    employee_name VARCHAR(255),
    salary DECIMAL(10, 2));

CREATE TABLE employee_backup (
    employee_id INT,
    employee_name VARCHAR(255),
    salary DECIMAL(10, 2));

-- Insert records into both tables from a source table
INSERT INTO employees (employee_id, employee_name, salary)
SELECT employee_id, employee_name, salary
FROM source_table;

INSERT INTO employee_backup (employee_id, employee_name, salary)
SELECT employee_id, employee_name, salary
FROM source_table;

------------------------------------------------------------------------------------------------------------------------------

-- 32. Syntax for how to create constraints on a table.
# We can create constraints on a table during its creation or alter an existing table to add constraints
# 1. Primary Key Constraint:
CREATE TABLE table_name ( column1 datatype PRIMARY KEY, column2 datatype, ...);

# 2. Foreign Key Constraint:
CREATE TABLE table_name1 (column1 datatype PRIMARY KEY, ...);

CREATE TABLE table_name2 (column1 datatype, foreign_key_column datatype,
						  FOREIGN KEY (foreign_key_column) REFERENCES table_name1(column1));
                          
# 3. Unique Constraint:
CREATE TABLE table_name (column1 datatype UNIQUE, column2 datatype,...);

# 4. Check Constraint:
CREATE TABLE table_name ( datatype, column2 datatype CHECK (column2 > 0),...);

# 5. Not Null Constraint:
CREATE TABLE table_name (column1 datatype NOT NULL, column2 datatype,...);

# 6. Composite (Multiple Column) Constraints:
CREATE TABLE table_name (column1 datatype,column2 datatype,PRIMARY KEY (column1, column2),..);

-- Adding Constraints to Existing Table:
# 7. Adding Primary Key:
ALTER TABLE table_name ADD PRIMARY KEY (column1);

# 8. Adding Foreign Key:
ALTER TABLE table_name ADD CONSTRAINT fk_name
FOREIGN KEY (foreign_key_column) REFERENCES referenced_table(referenced_column);

# 9. Adding Unique Constraint:
ALTER TABLE table_name ADD CONSTRAINT unique_constraint_name UNIQUE (column1);

# 10. Adding Check Constraint:
ALTER TABLE table_name ADD CHECK (column2 > 0);

# 11. Adding Not Null Constraint:
ALTER TABLE table_name MODIFY COLUMN column1 datatype NOT NULL;
-- ----------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------