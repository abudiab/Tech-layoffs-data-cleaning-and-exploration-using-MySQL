-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove duplicates 
-- 2. Standardize the data
-- 3. Null values or Blank values
-- 4. Remove any irrelevant columns or rows (that are not necessary)

-- Before editing the data irreversibly, let's create a copy of the data where we will do all of our work and still have the raw data untouched.

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging; -- this will copy the schema without the data

-- now we insert the data into our new table

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging; -- now running this will show the data


-- Let's start by identifying any duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num -- We put date inside backticks because date is a keyword in SQL
FROM layoffs_staging;

-- The above code will create a column partitioning by the criteria we laid, and if the row_num value is more than 1, then we have duplicates. 
-- We will put the code above inside a CTE

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Let's check if the result of the above are actually duplicates
SELECT *
FROM layoffs_staging
WHERE company  = 'Oda'; -- The result aren't actually duplicates, so we need to adjust our strategy, we need to partition by every single column to be 100% sure the results are duplicates.

-- Creating a new duplicate cte

WITH new_duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM new_duplicate_cte
WHERE row_num > 1;

-- Do some testing
SELECT *
FROM layoffs_staging
WHERE company  = 'Casper';

-- Duplicates confirmed, now we need to remove the duplicates, and we will use the CTE for that. 

WITH new_duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM new_duplicate_cte
WHERE row_num > 1;

/* Turns out the above doesn't work in MySQL and throws and error.
	Instead, we can create a new table with the row_num colum and deleting the record where the value in that column is equal to 2.
    Shortcut: right-click on the staging table > copy to clipboard > create statement. Then paste  here.
*/

-- Let's change the name of the table to 'layoffs_staging2'
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



SELECT *
FROM layoffs_staging2; -- empty table

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- check duplicates
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 

-- delete duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1; 

-- Check
SELECT *
FROM layoffs_staging2;


-- Standardizing data

-- Trim extra spaces
SELECT company, TRIM(company)
FROM layoffs_staging2
;
-- Update the table
UPDATE layoffs_staging2
SET company = TRIM(company)
;

-- explore the different industries to find things we can improve
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%crypto%';


-- Check other columns
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country Like 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Another way we could've fixed the issue above with the period is by using the TRIM function as below
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Let's fix the date column

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date -- this function changes the string (text) into a Date format. It takes the date column and the format as parameters
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- this currently throws an error because the NULL values are stored as a string of Null ('NULL') rather than the actual NULL value, the function isn't able to handle that.

-- To work around that, we'll change the 'NULL' strings, into the value NULL
UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'NULL';

-- then run the update command
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- this works now!

-- Change the date column data type from text to date data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Handling NULL and Blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
; -- returns empty table because the NULLs in this column are actually strings of Null 'NULL' rather than NULL values.

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL; -- this works now


-- Let's do the NULL string to NULL value fix for all the columns

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

UPDATE layoffs_staging2
SET company = NULL
WHERE company = 'NULL';

UPDATE layoffs_staging2
SET location = NULL
WHERE location = 'NULL';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = 'NULL';

UPDATE layoffs_staging2
SET stage = NULL
WHERE stage = 'NULL';

UPDATE layoffs_staging2
SET country = NULL
WHERE country = 'NULL';

UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

--

-- Let's fix the industry column
SELECT DISTINCT industry
FROM layoffs_staging2; -- this finds that the column has null and blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- we'll try to populate missing or null values from existing data, for example:
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company = 'Airbnb' AND (industry IS NULL OR industry = '');

-- Or the better method

-- Check
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update blank values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate null values from the existing not null values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry  = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Check if that worked
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Now let's see if we can remove the rows where both the total_laid_off and percentage_laid_off are NULL or missing
SELECT *
FROM layoffs_staging2
WHERE (total_laid_off  IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL or percentage_laid_off = '')
;

-- Delete them
DELETE
FROM layoffs_staging2
WHERE (total_laid_off  IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL or percentage_laid_off = '')
;

-- Lastly, we want to remove the row_num column that we added earleir as it is no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Check
SELECT *
FROM layoffs_staging2;

