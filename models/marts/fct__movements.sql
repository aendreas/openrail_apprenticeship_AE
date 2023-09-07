WITH train_info AS (
    SELECT train_id, pk AS fk_schedule, fk_toc, "CIF_train_category" AS category_type
    FROM {{ ref('int__scheduled_train_info') }}
),

movements_clean AS (
    SELECT 
        train_id, 
        CONCAT(EXTRACT(YEAR FROM planned_start_timestamp) ,LPAD(CAST(EXTRACT(MONTH FROM planned_start_timestamp) AS CHAR(2)), 2, '0'), LPAD(CAST(EXTRACT(DAY FROM planned_start_timestamp) AS CHAR(2)), 2, '0')) AS fk_yyyymmdd_scheduled_start,
        CONCAT(LPAD(CAST(EXTRACT(HOUR FROM planned_start_timestamp) AS CHAR(2)), 2, '0') ,LPAD(CAST(EXTRACT(MINUTE FROM planned_start_timestamp) AS CHAR(2)), 2, '0')) AS fk_hhmm_scheduled_start, 
        delay_status_start, 
        CASE WHEN delay_status_start LIKE 'EARLY%' THEN - ABS(delay_start) ELSE delay_start END AS delay_start,
        CONCAT(EXTRACT(YEAR FROM actual_start_timestamp) ,LPAD(CAST(EXTRACT(MONTH FROM actual_start_timestamp) AS CHAR(2)), 2, '0'), LPAD(CAST(EXTRACT(DAY FROM actual_start_timestamp) AS CHAR(2)), 2, '0')) AS fk_yyyymmdd_actual_start,
        CONCAT(LPAD(CAST(EXTRACT(HOUR FROM actual_start_timestamp) AS CHAR(2)), 2, '0') ,LPAD(CAST(EXTRACT(MINUTE FROM actual_start_timestamp) AS CHAR(2)), 2, '0')) AS fk_hhmm_actual_start, 
        start_location AS fk_loc_start, 
        CONCAT(EXTRACT(YEAR FROM planned_end_timestamp) ,LPAD(CAST(EXTRACT(MONTH FROM planned_end_timestamp) AS CHAR(2)), 2, '0'), LPAD(CAST(EXTRACT(DAY FROM planned_end_timestamp) AS CHAR(2)), 2, '0')) AS fk_yyyymmdd_scheduled_end,
        CONCAT(LPAD(CAST(EXTRACT(HOUR FROM planned_end_timestamp) AS CHAR(2)), 2, '0') ,LPAD(CAST(EXTRACT(MINUTE FROM planned_end_timestamp) AS CHAR(2)), 2, '0')) AS fk_hhmm_scheduled_end, 
        delay_status_end,
        CASE WHEN delay_status_end LIKE 'EARLY%' THEN - ABS(delay_end) ELSE delay_end END AS delay_end,
        CONCAT(EXTRACT(YEAR FROM actual_end_timestamp) ,LPAD(CAST(EXTRACT(MONTH FROM actual_end_timestamp) AS CHAR(2)), 2, '0'), LPAD(CAST(EXTRACT(DAY FROM actual_end_timestamp) AS CHAR(2)), 2, '0')) AS fk_yyyymmdd_actual_end,
        CONCAT(LPAD(CAST(EXTRACT(HOUR FROM actual_end_timestamp) AS CHAR(2)), 2, '0') ,LPAD(CAST(EXTRACT(MINUTE FROM actual_end_timestamp) AS CHAR(2)), 2, '0')) AS fk_hhmm_actual_end, 
        CAST(EXTRACT(EPOCH FROM actual_end_timestamp-actual_start_timestamp)/60 AS INT) AS actual_journey_duration,
        CAST(EXTRACT(EPOCH FROM planned_end_timestamp-planned_start_timestamp)/60 AS INT) AS theoretical_journey_duration,
        end_location AS fk_loc_end
    FROM {{ ref('int__movements_aggregated_first_last_location') }}
),

join_info_mov AS (
    SELECT t.*, m.*
    FROM train_info t INNER JOIN movements_clean m ON t.train_id = m.train_id
),

add_durations AS (
    SELECT 
        fk_schedule, 
        fk_toc, 
        fk_loc_start, 
        fk_loc_end, 
        fk_hhmm_scheduled_start, 
        fk_hhmm_actual_start, 
        fk_hhmm_scheduled_end, 
        fk_hhmm_actual_end, 
        fk_yyyymmdd_scheduled_start, 
        fk_yyyymmdd_actual_start, 
        fk_yyyymmdd_scheduled_end, 
        fk_yyyymmdd_actual_end, 
        delay_start AS delay_at_departure, 
        delay_end AS total_delay,
        theoretical_journey_duration,
        actual_journey_duration,
        category_type,
        NOW() AS event_time
    FROM join_info_mov
)

SELECT * FROM add_durations