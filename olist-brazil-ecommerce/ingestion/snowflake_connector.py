import os
import snowflake.connector
from cryptography.hazmat.primitives import serialization
from config import snowflake_config

private_key_path = os.path.join(
    os.getcwd(),
    "keys",
    "snowflake_private_key.p8"
)

def load_private_key():
    with open(private_key_path, "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None
        )

    return private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

def create_connection():
    private_key = load_private_key()

    return snowflake.connector.connect(
        **snowflake_config,
        private_key=private_key
    )