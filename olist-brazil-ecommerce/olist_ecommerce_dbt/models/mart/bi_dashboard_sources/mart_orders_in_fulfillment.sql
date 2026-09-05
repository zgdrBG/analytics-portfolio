{{
    config(
        materialized='table'
    )
}}

WITH int_orders AS (
    SELECT
        order_id,
        products_purchased,
        number_products_purchased,
        order_status,
        order_purchase_date,
        order_purchase_month,
        order_purchase_year,
        payment_type,
        payment_installments,
        payment_value,
        is_order_paid_in_full,
        days_to_deliver_customer,
        estimated_days_to_deliver_customer,
        estimation_delivery_days_diff,
        is_delivery_late,
        delivery_delay_type
    FROM {{ ref('int_orders') }}
    WHERE is_order_paid
        AND order_status IN (
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
) 

SELECT *
FROM int_orders