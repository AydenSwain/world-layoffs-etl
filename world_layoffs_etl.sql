DROP TABLE IF EXISTS
	layoffs_stg;

CREATE TABLE layoffs_stg
LIKE layoffs;

INSERT layoffs_stg
WITH remove_duplicates AS (
	SELECT *,
	ROW_NUMBER() OVER ( 
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
	FROM layoffs
)
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
FROM remove_duplicates
WHERE row_num = 1;

SELECT *
FROM layoffs_stg;
