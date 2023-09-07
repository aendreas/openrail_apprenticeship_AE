WITH categories AS (
    SELECT * FROM {{ ref('train_category') }}
),

rename AS (
 	SELECT "Code" AS code, 
        "Description" AS description, 
        "Type" AS type
	FROM categories
),

remove_dupes AS (
    SELECT *
    FROM rename
    WHERE type NOT LIKE description
),

casted AS (
    SELECT CAST(code AS CHAR(2)), 
        CAST(description AS VARCHAR), 
        CAST(type AS VARCHAR)
    FROM remove_dupes
)

SELECT * FROM casted