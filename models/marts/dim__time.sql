{%- set start_date = "to_date('2023-03-01', 'yyyy-mm-dd')" -%}
{%- set end_date = "to_date('2023-03-02', 'yyyy-mm-dd')" -%}
{%- set datepart = "minute" -%}

WITH time_spine AS (
    {{ dbt_utils.date_spine(datepart=datepart, 
                            start_date=start_date,
                            end_date=end_date) }}
),

time_spine_column AS (
    SELECT DATE_{{datepart}} AS AS_OF_DATE FROM time_spine

),

extracted_h_m AS (
    SELECT CAST(EXTRACT(HOUR FROM AS_OF_DATE) AS SMALLINT) AS HOUR, CAST(EXTRACT(MINUTE FROM AS_OF_DATE) AS SMALLINT) AS MINUTE FROM time_spine_column
),

final AS (
    SELECT CAST(lpad(HOUR::varchar, 2, '0') || lpad(MINUTE::varchar, 2, '0') AS CHAR(4)) AS pk_hhmm, * FROM extracted_h_m
)


SELECT * FROM final