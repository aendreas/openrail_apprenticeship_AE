{{
  config(
    materialized = 'incremental'
    )
}}

WITH scheduled_train AS (
    SELECT * 
    FROM {{ ref('int__scheduled_train_info') }}
    {% if is_incremental() %}
      WHERE event_time > (SELECT MAX(event_time) FROM {{this}})
    {% endif %}
)

SELECT * FROM scheduled_train