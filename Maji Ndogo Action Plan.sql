CREATE TABLE Project_progress (
		Project_id SERIAL PRIMARY KEY,
		/* Project_id −− Unique key for sources in case the same source is visited more than once in the future */
		source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
		/* source_id −− Each of the sources we want to improve should exist, and should refer to the source table. This ensures data integrity. */
		Address VARCHAR(50), −− Street address
		Town VARCHAR(30),
		Province VARCHAR(30),
		Source_type VARCHAR(50),
		Improvement VARCHAR(50), −− What the engineers should do at that place
		Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
		/* Source_status −− We want to limit the type of information engineers can give us, so we
			limit Source_status.
			− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
			− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
		*/
		Date_of_completion DATE, −− Engineers will add this the day the source has been upgraded.
		Comments TEXT −− Engineers can leave comments. 
);

−− Project_progress_query
SELECT
		water_source.source_id,
		location.address,
  	location.town_name,
		location.province_name,
		water_source.type_of_water_source,
  	visits.time_in_queue,
    well_pollution.results,
    CASE WHEN results IN ('contaminated: biological') THEN 'Install UV and RO filter'
				WHEN results IN ('contaminated: chemical') THEN 'Install RO filters'
        WHEN type_of_water_source = 'river' THEN 'Drill well'
        WHEN type_of_water_source = 'shared_tap' AND time_in_queue > 30 THEN CONCAT('Install',' ', FLOOR(time_in_queue / 30),' ', 'taps nearby')
        WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
		END AS Improvements
FROM
	water_source
LEFT JOIN
	well_pollution 
    ON water_source.source_id = well_pollution.source_id
INNER JOIN
	visits 
    ON water_source.source_id = visits.source_id
INNER JOIN
	location 
    ON location.location_id = visits.location_id
WHERE
	visits.visit_count = 1 
    AND (results != 'Clean'
    OR type_of_water_source IN ('tap_in_home_broken', 'river')
    OR (type_of_water_source = 'shared_tap' AND time_in_queue > 30))
;
