{# {{
  config(
    materialized = 'incremental',
    )
}} --NOTE: if you get errors, enclose the config in comments so that the model will default to full load #}

WITH movements AS (
    SELECT * FROM {{ ref('int__movement_messages_with_tiploc') }}
),

leg_number AS (
    SELECT * , ROW_NUMBER() OVER (PARTITION BY train_id,CAST(actual_timestamp AS DATE) ORDER BY actual_timestamp) AS leg_number
    FROM movements
),

earliest_stops AS (
    SELECT *, 'FIRST' AS flag
    FROM leg_number 
    WHERE leg_number = 1
),

latest_stops AS (
    SELECT l.*, 'LAST' AS flag
    FROM leg_number l INNER JOIN (
			SELECT MAX(leg_number), train_id, CAST(actual_timestamp AS DATE) AS date
			FROM leg_number GROUP BY train_id, CAST(actual_timestamp AS DATE)
	) s ON (l.leg_number = s.max AND l.train_id = s.train_id AND s.date = CAST(l.actual_timestamp AS DATE))
),

first_last_merged AS (
	SELECT 
        e.train_id, 
        e.planned_timestamp AS planned_start_timestamp, 
        e.timetable_variation AS delay_start, 
        e.variation_status AS delay_status_start, 
        e.actual_timestamp AS actual_start_timestamp, 
        e.loc_stanox AS start_location, 
        l.planned_timestamp AS planned_end_timestamp, 
        l.timetable_variation AS delay_end, 
        l.variation_status AS delay_status_end, 
        l.actual_timestamp AS actual_end_timestamp, 
        l.loc_stanox AS end_location,
        e.train_id || CAST(e.planned_timestamp AS DATE) AS pk
        -- TODO: add foreign keys for locations
    FROM earliest_stops e INNER JOIN latest_stops l 
            ON (e.train_id = l.train_id AND EXTRACT(HOUR FROM(l.planned_timestamp - e.planned_timestamp)) < 24)
),

join_route AS (
    SELECT a.*, NOW() AS event_time
    FROM first_last_merged a INNER JOIN {{ ref('int__route') }} l ON (a.pk = l.pk)
    WHERE a.end_location = l.end_loc_fk
)

SELECT * FROM join_route