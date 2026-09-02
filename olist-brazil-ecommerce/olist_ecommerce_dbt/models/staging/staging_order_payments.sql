{{
    config(
        materialized='table'
    )
}}

WITH order_payments AS (
    SELECT
        CAST(
            {{ replace_double_quotes('order_id') }}
            AS CHAR(32)
        ) AS order_id,
        CAST(payment_sequential AS INTEGER) AS payment_sequential,
        CAST(payment_type AS VARCHAR(50)) AS payment_type,
        CAST(payment_installments AS INTEGER) AS payment_installments,
        CAST(payment_value AS NUMBER) AS payment_value
    FROM {{ source('raw', 'order_payments') }}
)

SELECT *
FROM order_payments
