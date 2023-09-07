{{ config(materialized='view') }}
WITH movements AS (
    SELECT event_type,
        original_loc_stanox,
        original_loc_timestamp,
        planned_timestamp,
        timetable_variation,
        actual_timestamp,
        platform,
        train_terminated,
        train_id,
        variation_status,
        toc_id,
        loc_stanox,
        planned_event_type
     FROM {{ ref('int__movement_messages_no_route_changes_no_cancellations') }}
    WHERE msg_type LIKE '0003'
)

SELECT * FROM movements

-- TODO: add translation to tiploc