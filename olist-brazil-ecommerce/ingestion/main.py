from snowflake_connector import create_connection

def main():
    with create_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    CURRENT_USER(),
                    CURRENT_DATABASE()
            """)

            result = cursor.fetchall()
            print(result)

if __name__ == "__main__":
    main()