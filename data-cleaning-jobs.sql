-- showing all columns of uncleaned dataset - job_description shortened for better view
-- Skip to end of document to see preview of cleaned dataset.

SELECT index, job_title, salary_estimate, LEFT(job_description, 50) AS short_job_description, 
rating, company_name, location, headquarters, size, founded, type_of_ownership, industry, 
sector, revenue, competitors
FROM job_data;

---------------------------------------------------------------------------------------------

--counting the number of null values in each column - there are no null values. 
    
SELECT COUNT(*)-COUNT(competitors)
FROM employee_data; 


---------------------------------------------------------------------------------------------

-- adding columns to break up the salary_estimate column. 

ALTER TABLE job_data
ADD salary_source VARCHAR(100),
ADD min_salary_dollars_thousands NUMERIC,
ADD max_salary_dollars_thousands NUMERIC,
ADD avg_salary_dollars_thousands NUMERIC;


SELECT salary_source, min_salary_dollars_thousands,
max_salary_dollars_thousands, avg_salary_dollars_thousands
FROM job_data;


-- populating the new columns manipulating the salary estimate column. 

UPDATE job_data
SET salary_source = TRIM(SUBSTRING(salary_estimate FROM POSITION('(' IN salary_estimate) + 1 
FOR POSITION(')' IN salary_estimate)), ')');

UPDATE job_data
SET min_salary_dollars_thousands =
TRIM(SPLIT_PART(TRIM(SPLIT_PART(salary_estimate, '(', 1)), 'K-$', 1), '$') :: NUMERIC
;

UPDATE job_data
SET max_salary_dollars_thousands = 
TRIM(SPLIT_PART(TRIM(SPLIT_PART(salary_estimate, '(', 1)), '-$', 2), 'K') :: NUMERIC;

UPDATE job_data
SET avg_salary_dollars_thousands = 
ROUND(min_salary_dollars_thousands + 
(max_salary_dollars_thousands - min_salary_dollars_thousands)/2, 1)
;


SELECT salary_source, min_salary_dollars_thousands,
max_salary_dollars_thousands, avg_salary_dollars_thousands
FROM job_data;

-- Dropping the now redundant salary_estimate column.

ALTER TABLE job_data 
DROP salary_estimate;

---------------------------------------------------------------------------------------------


-- adding new column to see if the job requires knowledge of SQL by searching for 'SQL' in the job
-- description.
                                                                             
ALTER TABLE job_data 
ADD job_needs_SQL VARCHAR(30);

UPDATE job_data 
SET job_needs_sql = COALESCE(job_needs_sql, 'Yes')
WHERE job_description ILIKE '%sql%';


UPDATE job_data 
SET job_needs_sql = 'No'
WHERE job_needs_sql IS NULL;


SELECT job_needs_SQL FROM job_data;

---------------------------------------------------------------------------------------------


-- ordering rating column from samllest to largest, showing unknown ratings are denoted by '-1
SELECT rating 
FROM job_data
ORDER BY rating;


-- updating rating column to hold null values where there are missing values, making it easier
-- to perform analysis
UPDATE job_data 
SET rating = NULL
WHERE rating = -1;


SELECT rating 
FROM job_data
ORDER BY rating;

---------------------------------------------------------------------------------------------

-- column showing company name and redundant company rating score. 
SELECT company_name 
FROM job_data;

-- updating table to remove the rating from the company name column.
UPDATE job_data
SET company_name = TRIM(company_name, RIGHT(company_name, 3));

SELECT company_name 
FROM job_data;

---------------------------------------------------------------------------------------------

-- location and headquaters column showing location, headquarters and  state/country they reside in
-- headquarters also has some unknown values denoted by '-1'
    
SELECT location, headquarters
FROM job_data
ORDER BY headquarters;

-- relacing '-1' in headquarters column with 'Unknown'

UPDATE job_data 
SET headquarters = 'Unknown, Unknown'
WHERE headquarters = '-1';

-- adding columns to separate location and headquarters from the state the location is in
-- and country/state that the headquarters is in.
ALTER TABLE job_data 
ADD location_state VARCHAR(100),
ADD heaquarters_state_or_country VARCHAR(100);

-- populating new columns and updating location and headquaters columns.
UPDATE job_data
SET location_state = SPLIT_PART(location, ',', 2);
UPDATE job_data
SET heaquarters_state_or_country = SPLIT_PART(headquarters, ',', 2);
UPDATE job_data
SET location = SPLIT_PART(location, ',', 1);
UPDATE job_data
SET headquarters = SPLIT_PART(headquarters, ',', 1);

-- location_state has some missing values.
SELECT location, headquarters, location_state, heaquarters_state_or_country
FROM job_data
ORDER BY location_state;

-- assigning the missing values in location_states column with 'Unknown'
UPDATE job_data
SET location_state = 'Unknown'
WHERE location_state = '';

SELECT location, headquarters, location_state, heaquarters_state_or_country
FROM job_data;

---------------------------------------------------------------------------------------------

-- Missing values in all columns denoted by '-1' and 'Uknown', there is also some redundant text
-- in the size and type_of_ownership columns.
    
SELECT size, founded, type_of_ownership, industry, sector FROM job_data;

-- following updates and alterations streamlines text to include essential information and 
-- standardizes missing values, replacing '-1' with 'Unknown.

UPDATE job_data
SET size = REPLACE(TRIM(size, ' employees'), ' to ', '-');

UPDATE job_data
SET size = 'Unknown'
WHERE size = '-1';

ALTER TABLE job_data
ALTER COLUMN founded TYPE VARCHAR(20);

UPDATE job_data
SET founded = 'Unknown'
WHERE founded = '-1';

UPDATE job_data
SET type_of_ownership = REPLACE(REPLACE(REPLACE(type_of_ownership, 'Company - ', '') 
, ' Organization', ''), ' Practice / Firm', ' ');

UPDATE job_data 
SET type_of_ownership = 'Unknown'
WHERE type_of_ownership = '-1';

UPDATE job_data
SET industry = 'Unknown'
WHERE industry = '-1';

UPDATE job_data
SET sector = 'Unknown'
WHERE sector = '-1';


-- Shows cleaned version of affected columns. 
SELECT size, founded, type_of_ownership, industry, sector FROM job_data;

---------------------------------------------------------------------------------------------

-- shows the revenue column, missing values are denoted by 'Unknown/Non-Applicable' and '-1'

SELECT revenue FROM job_data;

-- changing column name to revenue_dollars to remove dollar units from records

ALTER TABLE job_data 
RENAME COLUMN revenue TO revenue_dollars;

UPDATE job_data
SET revenue_dollars = 
REPLACE(REPLACE(TRIM(revenue_dollars, '(USD)'),'$',''), ' to ', '-'); 

-- standardizing missing values.

UPDATE job_data
SET revenue_dollars = 'Unknown'
WHERE revenue_dollars ILIKE '%known / Non-Applicabl%' OR revenue_dollars = '-1';

SELECT revenue_dollars FROM job_data;

---------------------------------------------------------------------------------------------

-- shows missing values in competitors column. 

SELECT competitors FROM job_data;

-- updates missing values.

UPDATE job_data
SET competitors = 'Unknown'
WHERE competitors = '-1';

---------------------------------------------------------------------------------------------

--Shows preview of cleaned dataset with a shortened job description

SELECT index, job_title, min_salary_dollars_thousands, max_salary_dollars_thousands, 
avg_salary_dollars_thousands, salary_source, LEFT(job_description, 50) AS short_job_description,
job_needs_sql, rating, company_name, location, location_state, headquarters, 
heaquarters_state_or_country, size, founded, type_of_ownership, industry, 
sector, revenue_dollars, competitors
FROM job_data;