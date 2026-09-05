{{
    config(
        severity='warn'
    )
}}

SELECT order_id
FROM {{ ref('int_orders') }}
WHERE NOT is_order_paid
