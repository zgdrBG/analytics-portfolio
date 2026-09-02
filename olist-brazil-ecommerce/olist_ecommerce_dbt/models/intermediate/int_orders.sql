WITH staging_orders AS (
    SELECT
        order_id,
        customer_order_id,
        order_status,
        order_purchase_timestamp,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM {{ ref('staging_orders') }}
),

staging_order_payments AS (
    SELECT
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    FROM {{ ref('staging_order_payments') }}
),

orders_and_payments AS (
    SELECT
        staging_orders.order_id,
        staging_orders.customer_order_id,
        staging_orders.order_status,
        CAST(
            staging_orders.order_purchase_timestamp AS DATE
        ) AS order_purchase_date,
        DATE_PART(
            MONTH, order_purchase_date
        ) AS order_puchase_month,
        DATE_PART(
            YEAR, order_purchase_date
        ) AS order_puchase_year,
        staging_orders.order_delivered_carrier_date,
        staging_orders.order_delivered_customer_date,
        staging_orders.order_estimated_delivery_date,
        staging_order_payments.payment_sequential,
        staging_order_payments.payment_type,
        staging_order_payments.payment_installments,
        staging_order_payments.payment_value,
        staging_order_payments.order_id IS NOT NULL AS is_order_paid,
        COALESCE(staging_order_payments.payment_installments = 1, FALSE) AS is_order_paid_in_full,
        DATEDIFF(
            DAY,
            order_purchase_date,
            staging_orders.order_delivered_customer_date
        ) AS days_to_deliver_customer,
        DATEDIFF(
            DAY,
            staging_orders.order_delivered_customer_date,
            staging_orders.order_estimated_delivery_date
        ) AS estimated_days_to_deliver_customer,
        (
            estimated_days_to_deliver_customer - days_to_deliver_customer
        ) AS estimation_delivery_days_diff,
        COALESCE(estimation_delivery_days_diff >= 0, TRUE) AS is_delivery_late,
        CASE
            WHEN is_delivery_late
                AND estimation_delivery_days_diff >= -3
                    THEN 'Minor'
            WHEN is_delivery_late
                AND estimation_delivery_days_diff >= -7
                    THEN 'Moderate'
            WHEN is_delivery_late
                THEN 'Severe'
            ELSE 'On-time'
        END AS delivery_delay_type
    FROM staging_orders
    LEFT JOIN staging_order_payments
        ON staging_orders.order_id = staging_order_payments.order_id
)

SELECT * FROM orders_and_payments
