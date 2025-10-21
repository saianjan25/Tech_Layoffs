-- Data Cleaning

	-- DATA SET LINK : https://www.kaggle.com/datasets/swaptr/layoffs-2022
    -- Tracking the tech layoffs reported on the following platforms:
		-- Bloomberg
		-- San Francisco Business Times
		-- TechCrunch
		-- The New York Times
	-- The data availability is from when COVID-19 was declared as a pandemic i.e. 11 March 2020 to present (21 Apr 2025).
	-- Some data such as the sources, list of employees laid off and date of addition has been omitted here and the complete data can be found

-- Checking on data
SELECT * FROM LAYOFFS;

-- 1. Remove Duplicates
-- 2. standardize the data
-- 3. Null values and Blank values
-- 4. Remove any columns

-- Creating a duplicate table for the main data so that manuplation done here dosen't effect the server
CREATE TABLE layoffs_staging 
LIKE layoffs;

-- Checking if the duplicate table got the table scheme of the actual table
SELECT * FROM layoffs_staging;

-- Inserting the data into the dummy table
INSERT layoffs_staging 
SELECT * FROM layoffs;

-- 1. Remove Duplicates
	-- 1.1 checking with row_number as there is no primary key to check for duplicates 
with duplicates as 
( 
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) 
SELECT *
FROM duplicates
WHERE row_num > 1;

	-- 1.2 taking oda as example let's see if they are actually duplicates and are we on the right track of finding the duplicates.
SELECT * 
FROM layoffs_staging
WHERE company = 'Oda';
	-- oops :( we need to partition in row_number with every column in the data to find for the duplicates
    
	-- 1.3 these are our real duplicates 
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
	-- 1.4 let's try this time with Cazoo
SELECT * 
FROM layoffs_staging
WHERE company = 'Cazoo';
	-- As we can see that source and date_added are different but that source link and tells us about the same company layoffs over everything we can say from observation that it is a duplicate record of layoff 

	-- 1.5 Trying to delete duplicates
with duplicates as 
( 
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM
		layoffs_staging
) 
DELETE
FROM duplicates
WHERE row_num > 1;
	-- We cannot operate the delete which is a update to the table on a cte 
    -- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
	-- so let's do it!!

	-- 1.6 Creating a table to add row_number as a new column row_num
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


	-- 1.7 Checking if the duplicate table got the table scheme of the actual table
SELECT * FROM layoffs_staging2;


	-- 1.8 Inserting data into the table
INSERT INTO layoffs_staging2
SELECT *,ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
FROM
	layoffs_staging;
    
    
    -- 1.9 Checking the duplicate data in the new table
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;


	-- 1.10 Deleting the duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;
	-- Two rows efffected the duplicates are deleted
    

-- 2. standardize the data = Finding the issues in data and fixing it
	-- 2.1 Trimming company name so that they are in good format
SELECT company, trim(company) FROM layoffs_staging2;


Update layoffs_staging2
SET company = trim(company);


	-- 2.2 Checking if there is any possible error in the industry name 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;
		-- Everything looks great :)

	-- 2.3 Checking if there is any possible error in the location name 
		-- (Bengaluru, Bengaluru-Non-U.S. are both same 
         -- Brisbane, Brisbane-Non-U.S. are not same because the country changed to united states for Brisbane
         -- Buenos Aires, Buenos Aires,Non-U.S. are same
         -- Cayman Island, Cayman Island,Non-U.S. are both same
         -- Gurugram, Gurugram,Non-U.S. are both same
         -- Kuala Lumpur, Kuala Lumpur,Non-U.S. are both same
         -- London, London,Non-U.S. are both same
         -- Luxembourg,Non-U.s. and Luxembourd,Raleigh are same
         -- Melbourne, Melbourne,Non-U.S. are same
         -- Mumbai, Mumbai,Non-U.S. are same
         -- New Delhi,New York City and  New delhi,Non-U.S. are not same as the country changed to United States for New Delhi,New York City
         -- Singapore, Singapore,Non-U.S. are both same
         -- Tel Aviv, Tel Aviv,Non-U.S. are both same
         -- Vancouver, Vancouver,Non-U.S. are same according to the coutry Canada but not according to country United States)
SELECT DISTINCT location, country
FROM layoffs_staging2
ORDER BY location, country;


SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Vancouver%'
ORDER BY location;

UPDATE layoffs_staging2
SET location = 'Vancouver,Non-U.S.'
WHERE location LIKE 'Vancouver%' AND country = 'Canada';
		-- We have manually checked with all the Distinct locations and countries and changed the name accordingly for the above locations and observations I made
    
    
    -- 2.4 Checking for the industry information date issues
SELECT DISTINCT industry
FROM layoffs_staging2;
		-- Everything looks fine :)
    
    
	-- 2.5 Changing the date and date_added column from text to the Standard date format
SELECT `date`,
		str_to_date(`date`, '%m/%d/%Y'),
        `date_added`,
		str_to_date(`date_added`, '%m/%d/%Y')
FROM layoffs_staging2;

	-- Updated the columns to Standard MySql Date format 
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y'),
	`date_added` = str_to_date(`date_added`, '%m/%d/%Y');
	
	-- Updated the Column type of both date and date_added to date from text
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE,
MODIFY COLUMN `date_added` DATE;
	

		-- 2.6 Standardizing the value to int from text for total_laid_off
			-- Keeping NULL values in plcae of Blank values
UPDATE layoffs_staging2
SET total_laid_off = null
WHERE total_laid_off = '';
		
		-- Standardizing the value to int from text
SELECT total_laid_off,CAST(total_laid_off AS UNSIGNED) AS int_value
FROM layoffs_staging2;

		-- Updating the values to int from text
UPDATE layoffs_staging2
SET total_laid_off = CAST(CAST(total_laid_off AS DECIMAL(10,2)) AS UNSIGNED);

		-- Updating the table schema of total_laid_off from text to int
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

SELECT total_laid_off FROM layoffs_staging2;


	-- 2.7 Standardizing the value to decimal from text for percenage_laid_off
		-- Keeping NULL values in plcae of Blank values
UPDATE layoffs_staging2
SET percentage_laid_off = null
WHERE percentage_laid_off = '';

		-- Standardizing the value to decimal from text
SELECT percentage_laid_off,ROUND(CAST(REPLACE(percentage_laid_off, '%', '') AS DECIMAL(5,2)) / 100,2) AS percent_value
FROM layoffs_staging2;

	-- Updating the values to decimal from text
UPDATE layoffs_staging2
SET percentage_laid_off = ROUND(CAST(REPLACE(percentage_laid_off, '%', '') AS DECIMAL(5,2)) / 100,2);

	-- Updating the table schema of percentage_laid_off from text to decimal
ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off DECIMAL(10,2);

SELECT percentage_laid_off FROM layoffs_staging2;


	-- 2.8 Standardizing the value to integers from text for funds_raised
		-- Keeping NULL values in plcae of Blank values
UPDATE layoffs_staging2
SET funds_raised = null
WHERE funds_raised = '';

		-- Standardizing the value to int from text
SELECT funds_raised,CAST(REPLACE(funds_raised, '$', '') AS UNSIGNED) AS fund_raised_in_millions
FROM layoffs_staging2;

		-- Updating the values to int from text
UPDATE layoffs_staging2
SET funds_raised = CAST(REPLACE(funds_raised, '$', '') AS UNSIGNED);

		-- Updating the table schema of funds_raised from text to int
ALTER TABLE layoffs_staging2
CHANGE funds_raised funds_raised_millions INT;

SELECT funds_raised_millions FROM layoffs_staging2;

-- 3. NULL and Blank Values
	-- 3.1 Checking for NULL values in total_laid_off and percentage_laid_off. They are useless if we don't know these columns cause we are working on laid_off measures 
SELECT *
FROM layoffs_staging2
WHERE (total_laid_off = "" OR total_laid_off IS NULL)
AND (percentage_laid_off = "" OR percentage_laid_off IS NULL);


	-- 3.2 Checking NULL values for industry names
		-- Checking null values as well as blank values
SELECT *
FROM layoffs_staging2
WHERE (industry = "" OR industry IS NULL);
	

		-- 3.3 Updating the blanks to null values so that we can work on them
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';


		-- 3.4 Checking if we have any same company in the data list
SELECT *
FROM layoffs_staging2
WHERE company = 'Eyeo';
		-- OOPS :( We failes we cannot populated the data
        
	-- 3.5 Hey Don't worry I will provide you on a example if you want to work on in future ;)
SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;
		-- You will see no values as there is no repeated values to populate from Eyeo and Appsmith :|
        
	-- populating the values 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;
		-- It will do the magic of populating the NULL values for you if there is any record :)
        
	-- 3.6 Checking table again for any null and blank values
SELECT * 
FROM layoffs_staging2;


	-- 4 Dropping the column that we created or any unwanted columns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


		-- Deleting unwanted rows you know the reason (Check for 3.1) why but always delete/update data on a staging or dummy table not on the raw data
DELETE
FROM layoffs_staging2
WHERE (total_laid_off = "" OR total_laid_off IS NULL)
AND (percentage_laid_off = "" OR percentage_laid_off IS NULL);


-- There we go we have completely deleted updated transformed the data all along the journey for a structured and well mannered data for our next EDA project :)
-- Data cleaning is not that easy play around try new things and get the data manuplative according to your needs ;)
-- Always remember to clean data on a dummy or duplicate data so you can always have a copy of raw data incase of any mischiefs or any mistakes :|
-- Thank you