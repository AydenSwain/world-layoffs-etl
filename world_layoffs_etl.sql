-- Drop to allow for easy execution
DROP TABLE IF EXISTS
	layoffs_stg;

CREATE TABLE layoffs_stg
LIKE layoffs_raw;

-- ########### Remove duplicates ###########
INSERT layoffs_stg
WITH remove_duplicates AS (
	SELECT *,
	ROW_NUMBER() OVER ( 
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
	FROM layoffs_raw
)
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
FROM remove_duplicates
WHERE row_num = 1;

-- Test how many duplicates were removed
SELECT 
	(SELECT COUNT(*) FROM layoffs_raw) AS raw_count,
    (SELECT COUNT(*) FROM layoffs_stg) AS cleaned_count,
    (SELECT COUNT(*) FROM layoffs_raw) - (SELECT COUNT(*) FROM layoffs_stg) AS duplicates_removed;
-- Results: 5 duplicates removed

-- ########### Standardize the data ###########
-- Trim text cols
DESCRIBE layoffs_stg;

UPDATE layoffs_stg
SET 
	company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    percentage_laid_off = TRIM(percentage_laid_off),
    stage = TRIM(stage),
    country = TRIM(country);

-- Investigate qualitative cols
SELECT DISTINCT location
FROM layoffs_stg
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_stg
ORDER BY 1;
-- Discrepancy with Crypto

SELECT DISTINCT stage
FROM layoffs_stg
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_stg
ORDER BY 1;
-- Discrepancy with United States

-- Fix Crypto discrepancy
UPDATE layoffs_stg
SET industry = 'Crypto'
WHERE industry = 'CryptoCurrency' OR industry = 'Crypto Currency';

-- Test Crypto fix
SELECT *
FROM layoffs_stg
WHERE industry LIKE 'Crypto%';

-- Fix United States discrepancy
UPDATE layoffs_stg
SET country = 'United States'
WHERE country = 'United States.';

-- Test United States fix
SELECT *
FROM layoffs_stg
WHERE country LIKE 'United States%';

-- Change date from str to date datatype
UPDATE layoffs_stg
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stg
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_stg;