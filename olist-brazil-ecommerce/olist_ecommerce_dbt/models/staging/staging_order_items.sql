{{
    config(
        materialized='table'
    )
}}

WITH order_items AS (
    SELECT
        CAST(
            {{ replace_double_quotes('order_id') }}
            AS CHAR(32)
        ) AS order_id,
        CAST(
            {{ replace_double_quotes('product_id') }}
            AS CHAR(32)
        ) AS product_id,
        CAST(
            {{ replace_double_quotes('seller_id') }}
            AS CHAR(32)
        ) AS seller_id,
        CAST(order_item_id AS INTEGER) AS order_item_id,
        CAST(price AS NUMBER) AS price,
        CAST(freight_value AS NUMBER) AS freight_value,
        CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_timestamp
    FROM {{ source('raw', 'order_items') }}
)

SELECT *
FROM order_items