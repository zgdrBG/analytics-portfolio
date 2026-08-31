from snowflake_connector import create_connection

table_schemas = {
    "olist_customers_dataset.csv": {
        "table": "customers",
        "columns": '''
            customer_id VARCHAR,
            customer_unique_id VARCHAR,
            customer_zip_code_prefix VARCHAR,
            customer_city VARCHAR,
            customer_state VARCHAR
        '''
    },
    # "olist_geolocation_dataset.csv": {
    #     "table": "geolocation",
    #     "columns": '''
    #         geolocation_zip_code_prefix VARCHAR,
    #         geolocation_lat FLOAT,
    #         geolocation_lng FLOAT,
    #         geolocation_city VARCHAR,
    #         geolocation_state VARCHAR
    #     '''
    # },
    "olist_order_items_dataset.csv": {
        "table": "order_items",
        "columns": '''
            order_id VARCHAR,
            order_item_id INTEGER,
            product_id VARCHAR,
            seller_id VARCHAR,
            shipping_limit_date TIMESTAMP,
            price DECIMAL(10, 2),
            freight_value DECIMAL(10, 2)
        '''
    },
    "olist_order_payments_dataset.csv": {
        "table": "order_payments",
        "columns": '''
            order_id VARCHAR,
            payment_sequential INTEGER,
            payment_type VARCHAR,
            payment_installments INTEGER,
            payment_value DECIMAL(10, 2)
        '''
    },
    # "olist_order_reviews_dataset.csv": {
    #     "table": "order_reviews",
    #     "columns": '''
    #         review_id VARCHAR,
    #         order_id VARCHAR,
    #         review_score INTEGER,
    #         review_comment_title VARCHAR,
    #         review_comment_message VARCHAR,
    #         review_creation_date TIMESTAMP,
    #         review_answer_timestamp TIMESTAMP
    #     '''
    # },
    "olist_orders_dataset.csv": {
        "table": "orders",
        "columns": '''
            order_id VARCHAR,
            customer_id VARCHAR,
            order_status VARCHAR,
            order_purchase_timestamp TIMESTAMP,
            order_approved_at TIMESTAMP,
            order_delivered_carrier_date TIMESTAMP,
            order_delivered_customer_date TIMESTAMP,
            order_estimated_delivery_date TIMESTAMP
        '''
    },
    "olist_products_dataset.csv": {
        "table": "products",
        "columns": '''
            product_id VARCHAR,
            product_category_name VARCHAR,
            product_name_lenght INTEGER,
            product_description_lenght INTEGER,
            product_photos_qty INTEGER,
            product_weight_g INTEGER,
            product_length_cm INTEGER,
            product_height_cm INTEGER,
            product_width_cm INTEGER
        '''
    },
    # "olist_sellers_dataset.csv": {
    #     "table": "sellers",
    #     "columns": '''
    #         seller_id VARCHAR,
    #         seller_zip_code_prefix VARCHAR,
    #         seller_city VARCHAR,
    #         seller_state VARCHAR
    #     '''
    # },
    "product_category_name_translation.csv": {
        "table": "product_category_name_translation",
        "columns": '''
            product_category_name VARCHAR,
            product_category_name_english VARCHAR
        '''
    }
}

def create_stage(cursor):
    '''Create the Snowflake internal stage used for raw CSV files.'''

    cursor.execute('''
        CREATE STAGE IF NOT EXISTS raw_stage
        FILE_FORMAT = (
            TYPE = CSV
            FIELD_DELIMITER = ','
            SKIP_HEADER = 1
        )
    ''')

def create_table(cursor, table_name, columns):
    '''Create a raw table if it does not already exist.'''

    cursor.execute(f'''
        CREATE TABLE IF NOT EXISTS raw.{table_name} (
            {columns}
        )
    ''')

def upload_file(cursor, file_path):
    '''Upload a local CSV file to the Snowflake stage.'''

    cursor.execute(
        f"PUT 'file://{file_path}' @raw_stage "
        "AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    )

def load_table(cursor, filename, table_name):
    '''Load the staged CSV into the corresponding raw table.'''

    staged_filename = f"{filename}.gz"

    cursor.execute(f'''
        COPY INTO raw.{table_name}
        FROM @raw_stage/{staged_filename}
        FILE_FORMAT = (
            TYPE = CSV
            FIELD_DELIMITER = ','
            SKIP_HEADER = 1
        )
        ON_ERROR = 'ABORT_STATEMENT'
    ''')

def main():
    connection = create_connection()
    cursor = connection.cursor()

    try:
        create_stage(cursor)

        for filename, config in table_schemas.items():
            file_path = "data/raw/" + filename

            table_name = config["table"]

            print(f"Processing {filename} -> raw.{table_name}")

            create_table(
                cursor,
                table_name,
                config["columns"],
            )

            upload_file(cursor, file_path)
            load_table(cursor, filename, table_name)

            print(f"Loaded raw.{table_name}")

        connection.commit()
        print("Raw ingestion completed successfully.")

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    main()