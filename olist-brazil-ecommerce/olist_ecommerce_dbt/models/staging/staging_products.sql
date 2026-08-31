{{
    config(
        materialized='table'
    )
}}

WITH products AS (
    SELECT
        CAST(
            {{ replace_double_quotes('product_id') }}
            AS CHAR(32)
        ) AS product_id,
        CAST(
            {{ replace_double_quotes('product_category_name') }}
            AS VARCHAR(100)
        ) AS product_category_name,
        CAST(product_name_lenght AS INT) AS product_name_lenght,
        CAST(product_description_lenght AS INT) AS product_description_lenght,
        CAST(product_photos_qty AS INT) AS product_photos_qty,
        CAST(product_weight_g AS INT) AS product_weight_g,
        CAST(product_length_cm AS INT) AS product_length_cm,
        CAST(product_height_cm AS INT) AS product_height_cm,
        CAST(product_width_cm AS INT) AS product_width_cm
    FROM {{ source('raw', 'products') }}
)

SELECT * 
FROM products