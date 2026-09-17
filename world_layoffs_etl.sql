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