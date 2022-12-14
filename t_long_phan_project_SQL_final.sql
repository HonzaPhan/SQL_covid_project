SELECT *
FROM covid19_tests;

SELECT 
	country,
	sum(cumulative) ,
	sum(tests_performed)
FROM covid19_tests 
GROUP BY country 
;

/*
 * 1. Time variables - We can choose between astronomical or meteorological seasons, because task is not specified, which one to use
 */

-- Astronomical season
CREATE 
OR REPLACE TABLE t_long_phan_seasons AS 
SELECT
	date,
	country,
	coalesce(tests_performed,0)
	CASE 
		WHEN weekday(date) IN (5,6) THEN "0 - Weekend "
		ELSE "1 - Weekday"
		END AS weekday,
	CASE  
	/*Spring season AS 0*/
		WHEN (dayofmonth(date) BETWEEN 20 AND 31) AND (month(date) in (3)) THEN 0
		WHEN (dayofmonth(date) BETWEEN 1 AND 31) AND (month(date) in (4,5)) THEN 0
		WHEN (dayofmonth(date) BETWEEN 1 AND 19) AND (month(date) in (6)) THEN 0
	/*Summer season AS 1*/
		WHEN (dayofmonth(date) BETWEEN 20 AND 31) AND (month(date) in (6)) THEN 1
		WHEN (dayofmonth(date) BETWEEN 1 AND 31) AND (month(date) in (7,8)) THEN 1
		WHEN (dayofmonth(date) BETWEEN 1 AND 21) AND (month(date) in (9)) THEN 1
	/*Autumn season AS 2*/
		WHEN (dayofmonth(date) BETWEEN 22 AND 31) AND (month(date) in (9)) THEN 2
		WHEN (dayofmonth(date) BETWEEN 1 AND 31) AND (month(date) in (10,11)) THEN 2
		WHEN (dayofmonth(date) BETWEEN 1 AND 21) AND (month(date) in (12)) THEN 2
	/*Winter season AS 3*/
		ELSE 3
		END AS Season_of_year
					
FROM covid19_tests;

-- Meteorological season
CREATE 
OR REPLACE TABLE t_long_phan_seasons AS 
SELECT
	date,
	country,
	coalesce(tests_performed,0), /*We don't want to have null values, so we use replacement 0*/
	CASE 
		WHEN weekday(date) IN (5,6) THEN "0 - Weekend "
		ELSE "1 - Weekday"
		END AS weekday,
	CASE  
	-- Spring
		WHEN month(date) IN (3,4,5) THEN 0
	-- Summer
		WHEN month(date) IN (6,7,8) THEN 1
	-- Autumn
		WHEN month(date) IN (9,10,11) THEN 2
	-- Winter
		ELSE 3
		END AS Season_of_year
					
FROM covid19_tests;

/*
 * 2. State-specific variables
 */
SELECT *
FROM economies 
WHERE country = 'Albania';
SELECT 
	c.country, 
	e.YEAR,
	c.population_density,
	e.gini,
	child_mortality,
	c.median_age_2018 
FROM countries c
JOIN
	(SELECT 
		e.country,
		e.YEAR,
		e.gini,
		round(avg(e.mortaliy_under5),2) AS child_mortality
	 FROM economies e
	 WHERE e.gini IS NOT NULL AND e.mortaliy_under5 IS NOT NULL 
	 GROUP BY e.country) AS e
ON c.country = e.country
ORDER BY c.country,e.year;
/*
 * 3. Weather (affects people's behavior and also the ability of the virus to spread)
 */

WITH rain AS (
  SELECT DISTINCT 
   `weather`.`city` AS `city`, 
   `weather`.`date` AS `date`, 
   `weather`.`time` AS `time`, 
    round(CAST(REPLACE(`weather`.`rain`,' mm','') AS float),2) AS `raining` 
  FROM 
   `weather` 
  WHERE 
   `weather`.`city` IS NOT NULL 
  GROUP BY 
  	date,
  	time
), 
temp AS (
  SELECT DISTINCT 
   `weather`.`city` AS `city`, 
   `weather`.`date` AS `date`, 
    avg(CAST(REPLACE(`weather`.`temp`,' °c','') AS signed)) AS `daily_avg_temperature` 
  FROM 
   `weather` 
  WHERE 
   `weather`.`time` BETWEEN '06:00' 
    AND '18:00' 
    AND`weather`.`city` IS NOT NULL 
  GROUP BY 
  	date,
  	time
), 
wind AS (
  SELECT DISTINCT 
   `weather`.`city` AS `city`, 
   `weather`.`date` AS `date`, 
    max(CAST(REPLACE(`weather`.`gust`,' km/h','') AS signed)) AS `max_wind_gust` 
  FROM 
   `weather` 
  WHERE 
   `weather`.`time` BETWEEN '06:00' 
    AND '18:00' 
    AND`weather`.`city` IS NOT NULL 
  GROUP BY 
  	date,
  	time
) 
SELECT DISTINCT 
  `r`.`city` AS `city`, 
  date_format(`r`.`date`, '%Y-%m-%d') AS `date`, 
  `r`.`time` AS `time`, 
  COUNT(`r`.`raining`) AS `raining`, 
  AVG(`t`.`daily_avg_temperature`) AS `daily_avg_temperature`, 
  MAX(`w`.`max_wind_gust`) AS `max_wind_gust` 
FROM 
	`rain` `r` 
LEFT JOIN `temp` `t` 
	ON `r`.`date` = `t`.`date`
LEFT JOIN `wind` `w` 
	ON `r`.`date` = `w`.`date`
WHERE 
  `r`.`raining` > 0.00
GROUP BY 
	city,
	date,
	time;
