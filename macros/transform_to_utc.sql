{% macro char_to_utc(column_name) %}
    CASE 
        WHEN LENGTH( {{column_name}} ) > 4 THEN CONCAT(
                                                    LPAD(
                                                        CAST(
                                                            MOD(
                                                                CAST(
                                                                    CAST({{column_name}} AS CHAR(4))
                                                                AS SMALLINT)
                                                            - 100 + 2400, 2400)
                                                        AS CHAR(4))
                                                    , 4, '0')
                                                , 'H')
        ELSE LPAD(
                CAST(
                    MOD(
                        CAST(
                            CAST({{column_name}} AS CHAR(4))
                        AS SMALLINT)
                    - 100 + 2400, 2400)
                AS CHAR(4))
            , 4, '0')
    END AS {{ column_name }}
{% endmacro %}