DROP TABLE IF EXISTS
	layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
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
FROM layoffs_staging;
