-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

/* Found that the MAX function isn't working as expected, and that's
 because the values in the total_laid_off column are stored as strings */
 
SELECT total_laid_off
FROM layoffs_staging2;

-- Change the values in the column to integers
UPDATE layoffs_staging2
SET total_laid_off = CAST(total_laid_off AS UNSIGNED);

-- Change the column data type to integer
ALTER TABLE layoffs_staging2
MODIFY total_laid_off INTEGER;

-- Now the max function works as expected
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Continue exploration

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; -- results aren't properly sorted, because the values are stored as strings. 

-- Let's also fix the funds_raised_millions column

-- Change the values in the column to integers
UPDATE layoffs_staging2
SET funds_raised_millions = CAST(funds_raised_millions AS UNSIGNED);

-- Change the column data type to integer
ALTER TABLE layoffs_staging2
MODIFY funds_raised_millions INTEGER;

-- Now let's run the sort by funds raised query again
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Continue the exploration

-- Check which companies laid off the most employees
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Check the earliest and latest date for the data in our data set
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

 -- Check which industry had the most lay offs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Check which countries had the most lay offs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Check which date has the most lay offs
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 2 DESC;

-- Check the most recent lay offs
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- Let's check which year had the most lay offs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Check lay offs by company stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- More advanced exploration
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- Let's create a CTE to query the rolling sum month to month

WITH Rolling_Total AS (
	SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


-- Find company total lay offs grouped by year

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
-- ORDER BY company ASC;
ORDER BY 3 DESC;

-- Find company lay offs, partitioned by year and ordered by dense rank
WITH Company_Year (company, years, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
