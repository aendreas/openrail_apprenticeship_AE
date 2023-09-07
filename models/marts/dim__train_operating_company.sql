WITH company_dim AS (
    SELECT * FROM {{ ref('stg__companies') }}
)

SELECT * FROM company_dim