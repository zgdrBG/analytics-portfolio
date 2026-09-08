{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy='append'
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
        -- fix typos lenght -> length
        CAST(product_name_lenght AS INT) AS product_name_length,
        CAST(product_description_lenght AS INT) AS product_description_length,
        CAST(product_photos_qty AS INT) AS product_photos_qty,
        CAST(product_weight_g AS INT) AS product_weight_g,
        CAST(product_length_cm AS INT) AS product_length_cm,
        CAST(product_height_cm AS INT) AS product_height_cm,
        CAST(product_width_cm AS INT) AS product_width_cm
    FROM {{ source('raw', 'products') }}
    {% if is_incremental() %}

        WHERE product_id NOT IN (
            SELECT existing_table.product_id
            FROM {{ this }} AS existing_table
        )

    {% endif %}
)

SELECT *
FROM products
