{{
    config(
        materialized='table'
    )
}}

WITH staging_customers AS (
    SELECT
        customer_order_id,
        customer_unique_id
    FROM {{ ref('staging_customers') }}

),

int_orders AS (
    SELECT
        order_id,
        customer_order_id,
        order_status,
        order_purchase_date,
        order_purchase_month,
        order_purchase_year,
        number_products_purchased,
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
    WHERE 
        is_order_paid
        AND order_status IN (
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
),

order_by_customers AS (
    SELECT staging_customers.* EXCLUDE customer_order_id
    FROM int_orders
    LEFT JOIN staging_customers
        USING (customer_order_id)
)

SELECT *
FROM order_by_customers
