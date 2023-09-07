WITH source AS (
    SELECT * FROM {{ source('openrail', 'raw_movements') }}
),

casted AS (
    SELECT
    CAST(LPAD(CAST(msg_type AS VARCHAR), 4, '0') AS CHAR(4)) AS msg_type,
	CAST(train_id AS CHAR(10)),
	CAST(toc_id AS CHAR(2)),
	CAST(LPAD(CAST(sched_origin_stanox AS VARCHAR), 5, '0') AS CHAR(5)) AS sched_origin_stanox,
	TO_TIMESTAMP(CAST(CAST(origin_dep_timestamp AS BIGINT)/1000 AS INT)) as origin_dep_timestamp,
	CAST(train_uid AS CHAR(6)),
	TO_TIMESTAMP(schedule_start_date, 'YYYY-MM-DD') as schedule_start_date,
	TO_TIMESTAMP(schedule_end_date, 'YYYY-MM-DD') as schedule_end_date,
	CAST(schedule_source AS CHAR),
	CAST(schedule_type AS CHAR),
	TO_TIMESTAMP(tp_origin_timestamp, 'YYYY-MM-DD') as tp_origin_timestamp,
	TO_TIMESTAMP(CAST(CAST(actual_timestamp AS BIGINT)/1000 AS INT)) as actual_timestamp,
	CAST(LPAD(CAST(loc_stanox AS VARCHAR), 5, '0') AS CHAR(5)) AS loc_stanox,
	TO_TIMESTAMP(CAST(CAST(planned_timestamp AS BIGINT)/1000 AS INT)) as planned_timestamp,
	CAST(planned_event_type AS CHAR(11)),
	CAST(event_type AS CHAR(9)),
	CAST(timetable_variation AS SMALLINT),
	CAST(variation_status AS CHAR(9)),
	train_terminated,
	TO_TIMESTAMP(CAST(CAST(dep_timestamp AS BIGINT)/1000 AS INT)) as dep_timestamp,
	CAST(platform AS CHAR(2)),
	TO_TIMESTAMP(CAST(CAST(event_timestamp AS BIGINT)/1000 AS INT)) as event_timestamp,
	CAST(revised_train_id AS CHAR(10)),
	CAST(LPAD(CAST(original_loc_stanox AS VARCHAR), 5, '0') AS CHAR(5)) AS original_loc_stanox,
	TO_TIMESTAMP(CAST(CAST(original_loc_timestamp AS BIGINT)/1000 AS INT)) as original_loc_timestamp,
	TO_TIMESTAMP(CAST(CAST(reinstatement_timestamp AS BIGINT)/1000 AS INT)) as reinstatement_timestamp,
	CAST(LPAD(CAST(orig_loc_stanox AS VARCHAR), 5, '0') AS CHAR(5)) AS orig_loc_stanox,
	TO_TIMESTAMP(CAST(CAST(orig_loc_timestamp AS BIGINT)/1000 AS INT)) as orig_loc_timestamp
    FROM source
),

correct_time AS (
    SELECT
    msg_type,
    train_id,
    toc_id,
    sched_origin_stanox,
    origin_dep_timestamp,
    train_uid,
    schedule_start_date,
    schedule_end_date,
    schedule_source,
    schedule_type,
    tp_origin_timestamp,
    actual_timestamp - interval '1 hour' AS actual_timestamp,
    loc_stanox,
    planned_timestamp - interval '1 hour' AS planned_timestamp,
    planned_event_type,
    event_type,
    timetable_variation,
    variation_status,
    train_terminated,
    dep_timestamp - interval '1 hour' AS dep_timestamp,
    platform,
    event_timestamp,
    revised_train_id,
    original_loc_stanox,
    original_loc_timestamp,
    reinstatement_timestamp,
    orig_loc_stanox,
    orig_loc_timestamp - interval '1 hour' AS orig_loc_timestamp
    FROM casted
)

SELECT * FROM correct_time