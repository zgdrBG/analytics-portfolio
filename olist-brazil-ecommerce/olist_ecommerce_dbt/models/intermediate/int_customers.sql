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
        order_id,
        order_purchase_timestamp
    FROM {{ ref('staging_orders') }}
),

customers_and_orders AS (
    SELECT
        staging_customers.customer_unique_id,
        staging_customers.customer_city,
        staging_customers.customer_state,
        order_purchase_timestamp AS latest_order_timestamp
    FROM staging_customers
    -- only keep customers that have made orders
    INNER JOIN staging_orders
        ON staging_customers.customer_order_id = staging_orders.customer_order_id
    QUALIFY ROW_NUMBER() OVER(
        PARTITION BY staging_customers.customer_unique_id
        ORDER BY staging_orders.order_purchase_timestamp DESC
    ) = 1
)

SELECT * FROM customers_and_orders
