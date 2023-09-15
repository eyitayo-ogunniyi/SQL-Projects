CREATE TABLE hr_data (
	id varchar(50),
	first_name varchar(50),
	last_name varchar(50),	
	birthdate text,	
	gender varchar(50),
	race varchar(50),	
	department varchar(50),	
	jobtitle varchar(50),
	location varchar(50),	
	hire_date text,
	termdate text,
	location_city varchar(50),	
	location_state	varchar(50)
)

-- Selecting all data
SELECT *
FROM hr_data
WHERE location = 'Headquarters';

-- DATA CLEANING
-- Renaming id column
ALTER TABLE hr_data
RENAME COLUMN id to emp_id;

-- renaming birthdate column
ALTER TABLE hr_data
RENAME COLUMN birthdate to birth_date;

-- renaming jobtitle column
ALTER TABLE hr_data
RENAME COLUMN jobtitle to job_title;

-- renaming termdate column
ALTER TABLE hr_data
RENAME COLUMN termdate to term_date;

-- checking for duplicate
SELECT emp_id, count(*)
FROM hr_data
GROUP BY emp_id
HAVING count(*) > 1;

-- Changing birth date datatype
UPDATE hr_data
SET birth_date = CASE WHEN birth_date LIKE '%/%' THEN TO_DATE(birth_date, 'mm/dd/YY')
	WHEN birth_date LIKE '%-%' THEN TO_DATE(birth_date, 'mm-dd-YY')
	END;
	
ALTER TABLE hr_data
ALTER COLUMN birth_date TYPE DATE
USING birth_date::date;

-- Exploring the birth date column
SELECT min(birth_date), max(birth_date)
FROM hr_data;

DELETE FROM hr_data 
WHERE birth_date > current_timestamp;

-- Checking the gender column
SELECT DISTINCT(gender)
FROM hr_data;

-- Checking the race column
SELECT DISTINCT(race)
FROM hr_data;

SELECT *
FROM hr_data
WHERE race IS NULL
	OR gender IS NULL;
	
-- Changing hire date datatype 
UPDATE hr_data
SET hire_date = CASE WHEN hire_date LIKE '%/%' THEN TO_DATE(hire_date, 'mm/dd/YY')
	WHEN hire_date LIKE '%-%' THEN TO_DATE(hire_date, 'mm-dd-YY')
	END;

ALTER TABLE hr_data
ALTER COLUMN TYPE DATE
USING hire_date::date;

-- Exploring the hire date column
SELECT min(hire_date), max(hire_date)
FROM hr_data;

SELECT *
FROM hr_data 
WHERE hire_date > current_timestamp;

-- Changing termdate datatype
UPDATE hr_data
SET term_date = TO_TIMESTAMP(term_date, 'YYYY-MM-DD HH24:MI:SS UTC');

ALTER TABLE hr_data
ALTER COLUMN term_date TYPE TIMESTAMP
USING term_date::timestamp;

-- exploring the termdate column
SELECT min(term_date), max(term_date)
FROM hr_data 
WHERE term_date IS NOT NULL;
	
DELETE FROM hr_data 
WHERE term_date > current_timestamp;
	
-- Exploring other columns
SELECT *
FROM hr_data
WHERE birth_date IS NULL 
	OR hire_date IS NULL;
	
SELECT *
FROM hr_data
WHERE department IS NULL 
	OR job_title IS NULL;

SELECT DISTINCT(department)
FROM hr_data
ORDER BY department;
	
SELECT DISTINCT(jobtitle)
FROM hr_data
ORDER BY job_title;

SELECT DISTINCT(location)
FROM hr_data;

SELECT DISTINCT(location_city)
FROM hr_data
ORDER BY location_city;

SELECT DISTINCT(location_state)
FROM hr_data
ORDER BY location_state;

-- Adding a new column age
ALTER TABLE hr_data
ADD age INT;

UPDATE hr_data
SET age = DATE_PART('year', CURRENT_DATE) - DATE_PART('year', birth_date);

SELECT min(age), avg(age), max(age)
FROM hr_data

SELECT count(*)
FROM hr_data
WHERE age < 18


-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, 
	count(*) AS count
FROM hr_data
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr_data
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT max(age), min(age)
FROM hr_data

SELECT 
	CASE 
		WHEN age < 30 THEN '20-29'
		WHEN age < 40 THEN '30-39'
		WHEN age < 50 THEN '40-49'
		ELSE '50-59'
		END age_group, count(*)
FROM hr_data
GROUP BY age_group
ORDER BY count DESC;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, 
	count(*) AS count
FROM hr_data
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT round(avg(DATE_PART('year', term_date) - 
				 DATE_PART('year', hire_date))::int, 0) avg_emp_length
FROM hr_data
WHERE term_date IS NOT NULL;

-- 6. How does the gender distribution vary across departments?
SELECT department, gender, count(*) employees
FROM hr_data
GROUP BY department, gender
ORDER BY department, employees DESC;

-- 7. What is the distribution of job titles across the company?
SELECT job_title, count(*) employees
FROM hr_data
GROUP BY job_title
ORDER BY count DESC
LIMIT 10;

-- 8. Which department has the highest turnover rate?
WITH department_count AS (
	SELECT department, count(*) total_count,
		SUM(CASE WHEN term_date IS NOT NULL THEN 1 ELSE 0 END) termination_count
	FROM hr_data
	GROUP BY department)

SELECT department, round((termination_count::numeric/total_count::numeric)*100, 1) AS turnover_rate
FROM department_count
ORDER BY turnover_rate DESC
LIMIT 1;

-- 9. What is the turnover rate across jobtitles
WITH job_title_count AS (
	SELECT job_title, count(*) total_count,
		SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) termination_count
	FROM hr_data
	GROUP BY jobtitle)

SELECT job_title, round((termination_count::numeric/total_count::numeric)*100, 1) AS turnover_rate
FROM job_title_count
ORDER BY turnover_rate DESC;

-- 10. How have turnover rates changed each year
WITH cte3 AS (
	SELECT DATE_PART('year', hire_date) AS year,
		count(*) total_count,
		SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) termination_count
	FROM hr_data
	GROUP BY DATE_PART('year', hire_date))

SELECT year, round((termination_count::numeric/total_count::numeric)*100, 1) AS turnover_rate
FROM cte3
ORDER BY turnover_rate DESC;

-- 11. What is the distribution of employees across states?
SELECT location_state, count(*) employees
FROM hr_data
GROUP BY location_state
ORDER BY count DESC, location_state;
