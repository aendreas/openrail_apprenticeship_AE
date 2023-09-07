WITH source AS (
    SELECT * FROM {{ source('openrail', 'raw_schedules') }}
),

casted AS (
	SELECT 
		CAST("CIF_train_uid" AS CHAR(6)),
		TO_TIMESTAMP(schedule_start_date, 'YYYY-MM-DD') as schedule_start_date,
		TO_TIMESTAMP(schedule_end_date, 'YYYY-MM-DD') as schedule_end_date,
		CAST(LPAD(CAST(schedule_days_runs AS VARCHAR), 7, '0') AS CHAR(7)) AS schedule_days_runs, 
		CAST(train_status AS CHAR),
		CAST("CIF_train_category" AS CHAR(2)),
		CAST("CIF_power_type" AS CHAR(3)),
		CAST("CIF_speed" AS CHAR(3)),
		CAST("CIF_operating_characteristics" AS CHAR(6)),
		CAST("CIF_train_class" AS CHAR),
		CAST("CIF_sleepers" AS CHAR),
		CAST("CIF_reservations" AS CHAR),
		CAST("CIF_catering_code" AS CHAR(2)),
		CAST("CIF_stp_indicator" AS CHAR(1)),
		CAST(atoc_code AS CHAR(2)),
		CAST(REPLACE(REPLACE(schedule_location, 'None', 'null'), '''''', '"') AS JSONB) AS schedule_location
	FROM source 
),

filtered AS (
	SELECT CONCAT("CIF_train_uid", "CIF_stp_indicator", schedule_start_date) AS pk, 
		"CIF_train_uid", 
		"CIF_stp_indicator", 
		schedule_start_date,
		schedule_days_runs,
		train_status,
		"CIF_train_category", 
		"CIF_power_type",
		"CIF_speed",
		"CIF_operating_characteristics",
		"CIF_train_class",
		"CIF_sleepers",
		"CIF_reservations",
		"CIF_catering_code",
		atoc_code, 
		schedule_location 
	FROM casted
	WHERE schedule_end_date >= TO_TIMESTAMP('2023-05-19', 'YYYY-MM-DD') AND 
		"CIF_train_category" IS NOT NULL
)

SELECT * FROM filtered