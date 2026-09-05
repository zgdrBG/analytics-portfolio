from snowflake_connector import create_connection

''' Tests if the connection to Snowflake is successful.'''

def test_connection():
    with create_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    CURRENT_USER(),
                    'Connection is successful'
            """)

            result = cursor.fetchall()
            print(result)

if __name__ == "__main__":
    test_connection()