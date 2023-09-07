WITH two_five_six AS (
    SELECT train_id, CAST(dep_timestamp AS DATE) AS date
    FROM {{ ref('stg__movement') }}
	WHERE msg_type IN ('0002', '0005', '0006')
), 

coi_tid AS (
	SELECT train_id, CAST(event_timestamp AS DATE) AS date
    FROM {{ ref('stg__movement') }}
    WHERE msg_type LIKE '0007'
),

coi_revised_tid AS (
	SELECT revised_train_id AS train_id, CAST(event_timestamp AS DATE) AS date
    FROM {{ ref('stg__movement') }}
    WHERE msg_type LIKE '0007'
),

col AS (
	SELECT train_id, CAST(original_loc_timestamp AS DATE) AS date
    FROM {{ ref('stg__movement') }}
    WHERE msg_type LIKE '0008'
),

unioned AS (
	SELECT train_id, date
	FROM two_five_six 

	UNION 

	SELECT train_id, date 
	FROM coi_tid 

	UNION 

	SELECT train_id, date 
	FROM coi_revised_tid	
	
	UNION 

	SELECT train_id, date 
	FROM col
),

filtered AS (
    SELECT DISTINCT *
	FROM unioned
	WHERE train_id IS NOT NULL AND LENGTH(train_id) = 10
),

final AS (
    SELECT CONCAT(train_id, date) AS train_id_date
	FROM filtered
)

SELECT * FROM final