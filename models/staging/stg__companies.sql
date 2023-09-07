WITH train_operating_company AS (
    SELECT * FROM {{ ref('companies') }}
),

cleaning AS (
	SELECT *, 
        CASE
            WHEN "Whitelisted" LIKE 'N' THEN 'TRUE'
            WHEN "Whitelisted" LIKE 'Y' THEN 'FALSE'
            ELSE 'TRUE'
		END AS obfuscated  
	FROM train_operating_company
	WHERE "Company Name" NOT LIKE 'Unmapped%' AND
        "Sector Code" IS NOT NULL AND 
        "ATOC Code" IS NOT NULL AND 
        "Sector Code" NOT LIKE '?' AND
        "Company Name" NOT LIKE '%(defunct)'
),

add_primary_key AS (
    SELECT CONCAT("Sector Code","ATOC Code") AS pk, 
    "Company Name" AS name, 
    CAST(obfuscated AS BOOLEAN)
    FROM cleaning
),

casted AS (
    SELECT CAST(pk AS CHAR(4)),
    CAST(name AS VARCHAR),
    obfuscated
    FROM add_primary_key
)

SELECT * FROM casted