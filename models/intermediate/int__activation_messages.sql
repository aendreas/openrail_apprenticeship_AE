{{ config(materialized='view') }}
WITH activations AS (
    SELECT schedule_end_date, 
        train_id, 
        tp_origin_timestamp, 
        origin_dep_timestamp, 
        toc_id, 
        train_uid, 
        CAST(CASE 
            WHEN schedule_type LIKE 'O' THEN 'P'
            WHEN schedule_type LIKE 'P' THEN 'O'
            ELSE schedule_type
        END AS CHAR) AS schedule_type, 
        sched_origin_stanox, 
        schedule_start_date 
    FROM {{ ref('stg__movement') }}
    WHERE msg_type LIKE '0001' AND
    CONCAT(train_id, CAST(origin_dep_timestamp AS DATE)) NOT IN (SELECT * FROM {{ ref('int__cancellations_and_route_changes') }}) AND 
    schedule_type NOT LIKE 'C'
),

add_fk AS (
    SELECT CONCAT(train_uid, schedule_type, schedule_start_date) AS fk_schedule, * 
    FROM activations
)

SELECT * FROM add_fk