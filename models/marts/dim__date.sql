{%- set start_date = "2023-03-01" -%}
{%- set end_date = "2023-09-26" -%}


WITH date_dim AS (
    {{ dbt_date.get_date_dimension(start_date, end_date) }}
),

chosen_fields AS (
    SELECT CONCAT(year_number, LPAD(CAST(month_of_year AS CHAR(2)), 2, '0'), LPAD(CAST(day_of_month AS CHAR(2)), 2, '0')) AS pk_yyyymmdd, 
    year_number AS year, 
    month_of_year AS month_int, 
    month_name AS month, 
    day_of_month AS day_int, 
    day_of_week_name AS weekday, 
    week_of_year AS week_int, 
    day_of_week AS weekday_int, 
    quarter_of_year AS quarter
    FROM date_dim
)

SELECT * FROM chosen_fields