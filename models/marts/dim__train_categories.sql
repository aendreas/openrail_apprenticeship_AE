WITH categories_dim AS (
    SELECT * FROM {{ ref('stg__train_categories') }}
)

SELECT * FROM categories_dim