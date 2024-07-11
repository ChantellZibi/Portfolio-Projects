--- add email address for each employee
SELECT
  CONCAT(
    LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email −− add it all together
FROM
  employee
;
  
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov')
;

--- check phone number column to ensure they are numbers
SELECT
  LENGTH(phone_number)
FROM
  employee;

--- clean phone number column since the numbers are a string
UPDATE
	employee
SET
	phone_number = TRIM(phone_number)
;

--- Getting familiar with the data
--- How many peopl were surveyed
SELECT
	SUM(number_of_people_served) As Total_number_surveyed
FROM
	water_source
;

--- How many wells, taps and rivers are there?
SELECT
	type_of_water_source,
	COUNT(type_of_water_source) As number_of_sources
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY 
	COUNT(type_of_water_source) DESC
;

--- Average number of people that share a particular types of water sources with an average of 6 people in each home
SELECT
	type_of_water_source,
	ROUND(IF(type_of_water_source = 'tap_in_home', (AVG(number_of_people_served)/6), 
			IF(type_of_water_source = 'tap_in_home_broken',AVG(number_of_people_served)/6, (AVG(number_of_people_served))))) As number_of_people
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY 
	AVG(number_of_people_served)DESC
;

--- percentage of people served per water source
SELECT
	type_of_water_source,
	ROUND(SUM(number_of_people_served)) As total_number_of_people,
  ROUND((SUM(number_of_people_served)/27628140)*100) As percentage_people_served
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY 
	SUM(number_of_people_served)DESC
;

