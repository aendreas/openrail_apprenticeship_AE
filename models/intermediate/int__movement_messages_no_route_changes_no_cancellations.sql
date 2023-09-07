WITH movements AS (
    SELECT *
    FROM {{ ref('stg__movement') }}
),

filter_out_wrong_messages AS (
    SELECT * 
    FROM movements
    WHERE CONCAT(train_id, CAST(planned_timestamp AS DATE)) NOT IN (SELECT * FROM {{ ref('int__cancellations_and_route_changes') }})
)

SELECT * FROM filter_out_wrong_messages