WITH staging_products AS (
    SELECT
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    FROM {{ ref('staging_products') }}
),

ordered_items AS (
    SELECT DISTINCT product_id
    FROM {{ ref('staging_order_items') }}
),

categories_translated AS (
    SELECT
        product_category_name,
        product_category_name_english
    FROM {{ ref('product_category_translation') }}
),

products_with_sales AS (
    SELECT
        staging_products.product_id,
        staging_products.product_category_name AS product_category_name_pt,
        categories_translated.product_category_name_english AS product_category_name_en,
        staging_products.product_name_length,
        staging_products.product_description_length,
        staging_products.product_photos_qty,
        staging_products.product_weight_g,
        staging_products.product_length_cm,
        staging_products.product_height_cm,
        staging_products.product_width_cm
    FROM staging_products
    -- only keep products that have sales
    INNER JOIN ordered_items
        ON staging_products.product_id = ordered_items.product_id
    LEFT JOIN categories_translated
        ON staging_products.product_category_name = categories_translated.product_category_name
)

SELECT * FROM products_with_sales
