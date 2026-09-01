WITH staging_customers AS (
    SELECT
        customer_order_id,
        customer_unique_id,
        customer_zip_code,
        customer_city,
        customer_state
    FROM {{ ref('staging_customers') }}
),

staging_orders AS (
    SELECT
        customer_order_id,
        order_id
    FROM {{ ref('staging_orders') }}
),

customers_and_orders AS (
    SELECT
        staging_customers.customer_unique_id,
        staging_customers.customer_city,
        staging_customers.customer_state,
        COALESCE(
            COUNT(staging_orders.order_id), 0
        ) AS total_orders
    FROM staging_customers
    LEFT JOIN staging_orders
        ON staging_customers.customer_order_id = staging_orders.customer_order_id
    GROUP BY 1, 2, 3
),

customers_ranked AS (
    SELECT
        customers_and_orders.*,
        CASE
            WHEN total_orders <= 2 THEN 'Bronze'
            WHEN total_orders <= 4 THEN 'Silver'
            ELSE 'Gold'
        END AS customer_rank
    FROM customers_and_orders
)

SELECT * FROM customers_ranked
