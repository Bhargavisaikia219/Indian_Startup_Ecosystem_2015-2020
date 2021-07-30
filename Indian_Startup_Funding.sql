CREATE TABLE 
	start_up
	(	Sr_No numeric, Date date, Startup_Name varchar, IndustryVertical varchar, SubVertical varchar,
		City varchar, InvestorsName varchar, Investment_Type varchar, Amount_in_USD numeric, Remarks varchar	
	)

SELECT *
FROM
	start_up;

--Deleting Sr_no, Remarks as they are not reqd
ALTER TABLE	 
	start_up
DROP COLUMN 
	Sr_No,
DROP COLUMN 
	Remarks;

--Total no. of startups in India and Total investment in startups
SELECT
	COUNT(DISTINCT Startup_Name) AS Total_startups,
	SUM(Amount_in_USD) AS Total_investment
FROM
	start_up;

--Total no. of investors
SELECT
	COUNT(DISTINCT Inverstors) AS Total_investors
FROM
	(SELECT 
		TRIM(REGEXP_SPLIT_TO_TABLE(InvestorsName, ',')) AS Inverstors
	 FROM 
		start_up 
	 WHERE
		InvestorsName NOT IN ('N/A','Not Disclosed')
	) AS Count_investors;
	
--Investments over the years
SELECT
	Date,
 	SUM(Amount_in_USD) AS Yearwise_invest
FROM
	start_up
WHERE
	Amount_in_USD IS NOT null	
GROUP BY
	Date
ORDER BY
	Date;	

--Startup industries w.r.t Funding
SELECT DISTINCT
	IndustryVertical AS Industry,
	SUM(Amount_in_USD) OVER (PARTITION BY IndustryVertical ) AS Funds_per_industry
FROM 
	start_up
WHERE
	IndustryVertical!='nan' AND 
	Amount_in_USD IS NOT null	
ORDER BY
	2 DESC;

--Total funds raised per rounds
SELECT DISTINCT
	Investment_Type AS Investment_Round,
	SUM(Amount_in_USD) OVER (PARTITION BY Investment_Type ORDER BY Investment_Type) AS Funds_per_rounds
FROM
	start_up 
WHERE
	Investment_Type NOT IN ('Venture - Series Unknown', 'null','nan') AND 
	Amount_in_USD IS NOT null													  
ORDER BY 
	2 DESC;

--Startup Geography
WITH Bestplace_startups AS
(
SELECT
	TRIM(REGEXP_SPLIT_TO_TABLE(city, ',')) AS Location,
	Amount_in_USD,
	Startup_Name
FROM
	start_up
)
SELECT DISTINCT
	Location,
	COUNT(Startup_Name) OVER (PARTITION BY Location) AS No_of_startups,
	SUM(Amount_in_USD) OVER (PARTITION BY Location ) AS Totalfunds_per_city
	
FROM
	Bestplace_startups 
WHERE
	Location NOT IN ('Kozhikode', 'Nairobi','nan','Burnsville','USA','Santa Monica','New York/India','Boston','San Francisco','London','India/US','Belgaum','California',
				'San Jose','Missourie','New York','US','USA/India','Cambridge','US/India','Singapore','Menlo Park','India','Palo Alto','India/Singapore') AND 
	Amount_in_USD IS NOT null													  
ORDER BY
	2 DESC;

--Top investors in India 
SELECT DISTINCT
	Inverstors_name,
	SUM(Amount_in_USD) OVER (PARTITION BY Inverstors_name ) AS Funds_per_investor
FROM
	(SELECT 
		TRIM(REGEXP_SPLIT_TO_TABLE(InvestorsName, ',')) AS Inverstors_name,Amount_in_USD
	FROM
		start_up
	WHERE
		Amount_in_USD IS NOT null AND
		InvestorsName NOT IN ('N/A','Not Disclosed')
	) AS Topinvestors											  
ORDER BY
	2 DESC;
	
--Top funded startups
SELECT DISTINCT
	Startup_name,
	SUM(Amount_in_USD) OVER (PARTITION BY Startup_name ) AS Funds_per_startup
FROM
	(SELECT  
		TRIM(Startup_Name) AS Startup_name,Amount_in_USD
	FROM
		start_up
	WHERE
		Amount_in_USD IS NOT null
	) AS Topstartups
ORDER BY
	2 DESC;
