{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert'
    )
}}

WITH orders AS (
    SELECT
        CAST(
            {{ replace_double_quotes('order_id') }}
            AS CHAR(32)
        ) AS order_id,
        CAST(
            {{ replace_double_quotes('customer_id') }}
            AS CHAR(32)
        ) AS customer_order_id,
        CAST(order_status AS VARCHAR(30)) AS order_status,
        CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
        CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
        CAST(order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
        CAST(order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
        CAST(order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date
    FROM {{ source('raw', 'orders') }}
    {% if is_incremental() %}

        WHERE order_purchase_timestamp > (
            SELECT MAX(existing_table.order_purchase_timestamp)
            FROM {{ this }} AS existing_table
        )

    {% endif %}
)

SELECT *
FROM orders
