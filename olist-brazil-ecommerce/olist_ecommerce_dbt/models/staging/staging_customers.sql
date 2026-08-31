{{
    config(
        materialized='table'
    )
}}

WITH deduplicated_data AS (
    SELECT *
    FROM {{ source('raw', 'customers' ) }}
    WHERE 1 = 1
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_id ORDER BY customer_id
    ) = 1
),

customers AS (
    SELECT
        CAST(
            {{ replace_double_quotes('customer_id') }}
            AS CHAR(32)
        ) AS customer_order_id,
        CAST(
            {{ replace_double_quotes('customer_unique_id') }}
            AS CHAR(32)
        ) AS customer_unique_id,
        CAST(
            {{ replace_double_quotes('customer_zip_code_prefix') }}
            AS CHAR(5)
        ) AS customer_zip_code,
        CAST(customer_city AS VARCHAR(100)) AS customer_city,
        CAST(customer_state AS CHAR(2)) AS customer_state
    FROM deduplicated_data
)

SELECT * 
FROM customers