{{ config(materialized='view') }}

WITH scheduled_train AS (
    SELECT "CIF_train_uid",
        "CIF_stp_indicator", 
        schedule_start_date, 
        atoc_code, 
        schedule_days_runs,
		"CIF_power_type",
		"CIF_speed",
		"CIF_operating_characteristics",
		"CIF_train_class",
		"CIF_sleepers",
		"CIF_reservations",
		"CIF_catering_code",
        "CIF_train_category"
    FROM {{ ref('stg__schedule') }}
    WHERE atoc_code IS NOT NULL AND "CIF_stp_indicator" NOT LIKE 'C'
),

add_pk AS (
    SELECT CONCAT(s."CIF_train_uid", s."CIF_stp_indicator", s.schedule_start_date) AS pk, s.* 
    FROM scheduled_train s
),

join_activations AS (
    SELECT a.train_id, a.toc_id, j.*, CAST(a.origin_dep_timestamp AS DATE) AS date
    FROM add_pk j INNER JOIN {{ ref('int__activation_messages') }} a ON (j.pk = CONCAT(a.train_uid, a.schedule_type, a.schedule_start_date))
),

add_fk_toc AS (
    SELECT train_id, pk, "CIF_train_category",
        CONCAT(toc_id, atoc_code) AS fk_toc,
        schedule_days_runs,
		"CIF_power_type",
		"CIF_speed",
		"CIF_operating_characteristics",
		"CIF_train_class",
		"CIF_sleepers",
		"CIF_reservations",
		"CIF_catering_code",
        NOW() AS event_time
    FROM join_activations
)

SELECT * FROM add_fk_toc