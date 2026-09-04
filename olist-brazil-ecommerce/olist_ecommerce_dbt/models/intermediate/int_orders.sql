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
        /*
        in cases of multiple payment types we consider
        the payment with the biggest non aggregated
        value to be the main payment type
        */
        FIRST_VALUE(payment_type) OVER (
            PARTITION BY order_id ORDER BY payment_value DESC
        ) AS payment_type,
        payment_installments,
        payment_value
    FROM {{ ref('staging_order_payments') }}
),

order_payments_agg AS (
    SELECT 
        order_id,
        payment_type,
        MAX(payment_installments) AS payment_installments,
        SUM(payment_value) AS payment_value
    FROM staging_order_payments
    GROUP BY 1, 2
),

staging_order_items AS (
    SELECT
        order_id,
        LISTAGG(product_id, ', ') AS products_purchased,
        COUNT(product_id) AS number_products_purchased
    FROM {{ ref('staging_order_items') }}
    GROUP BY 1
),

orders_and_payments AS (
    SELECT
        staging_orders.order_id,
        staging_orders.customer_order_id,
        staging_order_items.products_purchased,
        staging_order_items.number_products_purchased,
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
        order_payments_agg.payment_type,
        order_payments_agg.payment_installments,
        order_payments_agg.payment_value,
        order_payments_agg.order_id IS NOT NULL AS is_order_paid,
        COALESCE(order_payments_agg.payment_installments = 1, FALSE) AS is_order_paid_in_full,
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
    LEFT JOIN order_payments_agg
        ON staging_orders.order_id = order_payments_agg.order_id
    LEFT JOIN staging_order_items
        ON staging_orders.order_id = staging_order_items.order_id
)

SELECT * FROM orders_and_payments
