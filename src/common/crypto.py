"""
Module crypto.

This module provides a class, Crypto, for managing encryption and decryption operations using the Fernet cipher.
It includes methods to encrypt and decrypt data.
"""
import os
from typing import Any, Dict, List, Union
from cryptography.fernet import Fernet
import logging

# from constants import SMGR_CIPHER_PREFIX, SMGR_CRYPTO_KEY_ENVOS_NAME

SMGR_CIPHER_PREFIX = "crypto"
SMGR_CRYPTO_KEY_ENVOS_NAME = "ENVOS_CRYPTO_01"
CIPHER_PREFIX = SMGR_CIPHER_PREFIX
ENV_VARIABLE_NAME = SMGR_CRYPTO_KEY_ENVOS_NAME

cipher_key = os.environ[ENV_VARIABLE_NAME]


def get_encrypted_data(text: str) -> str:
    """
    Encrypts the given text using the Fernet cipher.

    :param text: The text to encrypt.
    :return: The encrypted text. Example: "crypto__ENVOS_CRYPTO_01__encrypted_text"
    """
    cipher = Fernet(cipher_key)
    encrypted_text = cipher.encrypt(text.encode('utf-8'))
    encrypted_data = f"{CIPHER_PREFIX}__{ENV_VARIABLE_NAME}__{encrypted_text.decode('utf-8')}"
    return encrypted_data


def get_decrypted_nested_dict(data: Union[Dict, List, str, Any]) -> Union[Dict, List, str, Any]:
    """
    Рекурсивно дешифрует данные в словаре, списке или строке.

    Args:
        data: Данные для дешифрования. Может быть словарем, списком, строкой или другим типом данных.

    Returns:
        Union[Dict, List, str, Any]: Дешифрованные данные той же структуры.

    Examples:
        >>> encrypted_data = {
        ...     "key1": "crypto__ENVOS_CRYPTO_01__encrypted_text1",
        ...     "key2": ["crypto__ENVOS_CRYPTO_01__encrypted_text2"],
        ...     "key3": {"nested": "crypto__ENVOS_CRYPTO_01__encrypted_text3"}
        ... }
        >>> decrypted_data = get_decrypted_nested_dict(encrypted_data)
    """
    if isinstance(data, dict):
        return {
            key: get_decrypted_nested_dict(value)
            for key, value in data.items()
        }
    elif isinstance(data, list):
        return [
            get_decrypted_nested_dict(item)
            for item in data
        ]
    elif isinstance(data, str):
        # Пробуем дешифровать строку, если она не дешифруется - возвращаем как есть
        try:
            return get_decrypted_text(data.strip())
        except Exception:
            return data.strip()
    else:
        # Для всех остальных типов данных возвращаем как есть
        return data


def get_decrypted_text(encrypted_data: str) -> str:
    """
    Decrypts the given encrypted text using the Fernet cipher.

    :param encrypted_data: The encrypted text to decrypt in format "crypto__ENVOS_CRYPTO_01__encrypted_text"
    :return: The decrypted text.
    """
    parts = encrypted_data.split("__")
    if len(parts) != 3 or parts[0] != CIPHER_PREFIX:
        logging.warning("The input string does not have the expected format.")
        return encrypted_data

    key_env_variable = parts[1]
    try:
        cipher_key = os.environ[key_env_variable]
    except KeyError:
        raise Exception(f"The environment variable {key_env_variable} is not set.")

    cipher = Fernet(cipher_key)

    encrypted_text = parts[2]

    try:
        decrypted_text = cipher.decrypt(encrypted_text)
        return decrypted_text.decode("utf-8")
    except Exception as e:
        raise Exception(f"Error decrypting text: {e}")


if __name__ == '__main__':
    s = input("Что зашифровать?")
    print(f"вот что получилось /n[{get_encrypted_data(s)}]")
    s = input("Что расшифровать?")
    print(f"вот что получилось /n[{get_decrypted_text(s)}]")
