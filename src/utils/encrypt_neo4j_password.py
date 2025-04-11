import os
import sys

# Добавляем путь к src в PYTHONPATH
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, src_path)

from common.crypto import get_encrypted_data
from common.logger import setup_logger

logger = setup_logger()


def encrypt_password():
    """
    Утилита для шифрования пароля Neo4j
    """
    try:
        password = input("Введите пароль для Neo4j: ")
        encrypted_password = get_encrypted_data(password)
        print("\nЗашифрованный пароль (скопируйте его в config.yml):")
        print(encrypted_password)
        logger.info("Пароль успешно зашифрован")
    except Exception as e:
        logger.error(f"Ошибка при шифровании пароля: {str(e)}")
        raise


if __name__ == "__main__":
    encrypt_password()
