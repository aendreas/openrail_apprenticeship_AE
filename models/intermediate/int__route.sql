{{ config(materialized='view') }}

--WITH source AS (
	--SELECT * FROM {{ ref('stg__schedule')}}
--),

{#expanded_data AS (
    SELECT pk,
        item,
		ordinality as leg_number
    FROM source, jsonb_array_elements(schedule_location) WITH ORDINALITY AS t(item, ordinality)
),

expanded AS (
    SELECT pk,
        CAST(item->>'tiploc_code' AS CHAR(7)) AS tiploc_code, 
        CAST(item->>'arrival' AS CHAR(5)) AS arrival_time,
        CAST(item->>'departure' AS CHAR(5)) AS departure_time,
        CAST(item->>'pass' AS CHAR(45)) AS pass_time,
        CAST(item->>'public_arrival' AS CHAR(4)) AS public_arrival,
        CAST(item->>'public_departure' AS CHAR(4)) AS public_departure,
        CAST(item->>'platform' AS CHAR(3)) AS platform
    FROM expanded_data
),

to_UTC AS (
    SELECT pk,
        tiploc_code,
        {{ char_to_utc('arrival_time') }},
        {{ char_to_utc('departure_time') }},
        {{ char_to_utc('pass_time') }},
        {{ char_to_utc('public_arrival') }},
        {{ char_to_utc('public_departure') }},
        platform
    FROM expanded 
),

fk_from_ts AS (
    SELECT CASE
        WHEN arrival_time IS NOT NULL THEN CAST(arrival_time AS CHAR(4))
        WHEN departure_time IS NOT NULL THEN CAST(departure_time AS CHAR(4))
        WHEN pass_time IS NOT NULL THEN CAST(pass_time AS CHAR(4))
    END AS fk_time, *
    FROM to_UTC
), #} -- NOTE: This was rendered useless since we had no way to link TIPLOC to stanox, maybe it proves useful in combination with location data
WITH source AS (
    SELECT MIN(planned_timestamp), MIN(platform) AS platform,
    train_id, 
    loc_stanox,
    train_id || CAST(planned_timestamp AS DATE) AS pk
    FROM {{ ref('int__movement_messages_no_route_changes_no_cancellations') }} --TODO: change this to use location instead of movements since they later join together anyway
    GROUP BY CAST(planned_timestamp AS DATE), train_id, loc_stanox, platform
),

leg_number AS (
    SELECT * , ROW_NUMBER() OVER (PARTITION BY pk ORDER BY min) AS leg_number
    FROM source
),

first_and_last AS (
    SELECT train_id || CAST(min AS DATE) AS pk, MIN(leg_number) AS first_leg, MAX(leg_number) AS last_leg
    FROM leg_number
    GROUP BY train_id || CAST(min AS DATE)
),

add_first_last_stop_flag AS (
    SELECT sl.*, 
        CASE 
            WHEN sl.leg_number = fl.first_leg THEN 'start'
            WHEN sl.leg_number = fl.last_leg THEN 'end'
            ELSE NULL
        END AS route_flag
    FROM leg_number sl INNER JOIN first_and_last fl ON sl.pk = fl.pk
),

merge_first_last AS (
    SELECT f.pk, f.loc_stanox AS start_loc_fk, f.platform AS start_platform, l.min AS fk_arrival_time, l.loc_stanox AS end_loc_fk, l.platform AS end_platform, l.leg_number
    FROM add_first_last_stop_flag f INNER JOIN add_first_last_stop_flag l ON (f.route_flag LIKE 'start' AND l.route_flag LIKE 'end' AND f.pk = l.pk)
    --WHERE f.fk_time IS NOT NULL
)

SELECT * FROM merge_first_last	 

-- TODO: add primary key to the location
-- TODO: use this as the source of the truth for start and end locations instead of the movements: i.e. there are depots which are the actual starts, but those aren't interesting for reports (yet)