CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
		water_source.type_of_water_source,
		location.town_name,
		location.province_name,
		location.location_type,
		water_source.number_of_people_served,
		visits.time_in_queue,
		well_pollution.results
FROM
		visits
LEFT JOIN
		well_pollution
		ON well_pollution.source_id = visits.source_id
INNER JOIN
		location
		ON location.location_id = visits.location_id
INNER JOIN
		water_source
		ON water_source.source_id = visits.source_id
WHERE
		visits.visit_count = 1;


		
-- This section breaks down the data into provinces or towns and source types
WITH province_totals AS (-- This CTE calculates the population of each province
		SELECT
				province_name,
				SUM(people_served) AS total_ppl_serv
		FROM
				combined_analysis_table
		GROUP BY
				province_name
)
SELECT
		ct.province_name,
		-- These case statements create columns for each type of source.
		-- The results are aggregated and percentages are calculated
		ROUND((SUM(CASE WHEN source_type = 'river'
				THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
				THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
				THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
				THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
				THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
		combined_analysis_table ct
JOIN
		province_totals pt ON ct.province_name = pt.province_name
GROUP BY
		ct.province_name
ORDER BY
		ct.province_name;


CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (−− This CTE calculates the population of each town
−− Since there are two Harare towns, group by province_name and town_name
SELECT 
	province_name, 
	town_name, 
	SUM(people_served) AS total_ppl_serv
FROM 
	combined_analysis_table
GROUP BY 
	province_name,town_name
)
SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN −− Since the town names are not unique, join them using a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY −− Group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
