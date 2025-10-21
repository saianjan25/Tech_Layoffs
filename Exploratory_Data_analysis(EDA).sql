-- EXPLORATORY DATA ANALYSIS
	-- Exploring the raw data in the staging table
SELECT * FROM layoffs_staging2;

	-- Checking the earliest and latest dates in the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

	-- Finding the maximum number of layoffs and the highest percentage of layoffs in a single event
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

	-- Identifying companies that laid off 100% of their workforce, ordered by funds raised
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

	-- Summing total layoffs by company, showing which companies laid off the most workers
SELECT company, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

	-- Summing total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

	-- Summing total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

	-- Summing total layoffs by year
SELECT YEAR(`date`) as `year`, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

	-- Summing layoffs by month (year-month format)
SELECT 
	SUBSTRING(`date`,1,7) AS `Month`, 
    SUM(total_laid_off) 
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 DESC;

	-- Calculating cumulative (running) total of layoffs by month
WITH rolling_total AS
(
SELECT 
	SUBSTRING(`date`,1,7) AS `Month`, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 DESC
)
SELECT `Month`,
		total_laid_off,
		SUM(total_laid_off) OVER (ORDER BY `Month`) AS rolling_total
FROM rolling_total;

	-- Layoffs per company per year, ordered by total layoffs
SELECT company, YEAR(`date`) as year, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

	-- Top 5 companies with most layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *, 
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

	-- Layoffs by Year
SELECT YEAR(`date`) AS years, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY years
ORDER BY years;

	-- Industry wise layoffs
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

	-- Country-Wise Layoffs
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


	-- Funding Stage vs % Laid Off
SELECT stage, AVG(percentage_laid_off) AS avg_percent
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY stage
ORDER BY avg_percent DESC;

	-- Companies with Multiple Layoffs
SELECT company, COUNT(*) AS layoff_events, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
HAVING layoff_events > 1
ORDER BY total_layoffs DESC;

	-- Year-over-Year Layoffs by Industry
SELECT 
    industry,
    YEAR(date) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY industry, layoff_year
ORDER BY industry, layoff_year;

	-- Layoffs by Funding Stage per Year
SELECT stage, 
	YEAR(date) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND stage IS NOT NULL AND stage <> ''
GROUP BY stage, layoff_year
ORDER BY stage, layoff_year;

SELECT 
  CASE 
    WHEN stage IN ('Seed', 'Series A', 'Series B') THEN 'Early Stage'
    WHEN stage IN ('Series C', 'Series D', 'Series E', 'Series F') THEN 'Mid Stage'
    WHEN stage IN ('Series G', 'Series H', 'Series I', 'Series J', 'Post-IPO', 'Acquired', 'Private Equity', 'Subsidiary') THEN 'Late Stage'
    ELSE 'Unknown Stage'
  END AS funding_category,
  COUNT(*) AS company_count,
  ROUND(AVG(percentage_laid_off), 3) AS avg_layoff_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL AND stage IS NOT NULL AND stage <> ''
GROUP BY funding_category
ORDER BY avg_layoff_percentage DESC;


	-- percentage Laid Off vs Total Laid Off — Are Small Companies Cutting Deeper
SELECT 
    company,
    total_laid_off,
    percentage_laid_off,
    funds_raised_millions,
    CASE 
        WHEN funds_raised_millions < 500 THEN 'Small Funding'
        WHEN funds_raised_millions BETWEEN 500 AND 1000 THEN 'Mid Funding'
        ELSE 'Large Funding'
    END AS funding_category
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;
