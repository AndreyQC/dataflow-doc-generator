import os
from common.logger import setup_logger

logger = setup_logger()


def get_files_by_path(path):
    """
    function accept path
    :param string: path
    :return: array of dictionaries
    """
    logger.debug(f"Начало поиска файлов в директории: {path}")
    list_of_files = []
    files_result = []
    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            list_of_files.append(file_path)
            logger.debug(f"Найден файл: {file_path}")

    logger.info(f"Найдено {len(list_of_files)} файлов")

    for name in list_of_files:
        file_info = get_file_info(name)
        files_result.append(file_info)
        logger.debug(f"Обработан файл: {file_info['file_name']}")

    logger.info(f"Обработано {len(files_result)} файлов")
    return files_result


def get_file_info(file_full_path):
    """
    function accept file full path and return parsed dict
    :param string: file_full_path
    :return: dict
    """
    logger.debug(f"Получение информации о файле: {file_full_path}")
    filepath, file_extension = os.path.splitext(file_full_path)
    file_info = dict()
    file_info["file_name"] = os.path.basename(file_full_path)
    file_info["file_dir_name"] = os.path.dirname(file_full_path)
    file_info["file_extension"] = file_extension
    file_info["file_full_path"] = file_full_path
    logger.debug(f"Информация о файле получена: {file_info}")
    return file_info


if __name__ == "__main__":
    try:
        path = r"configure the path to folder with database project"
        logger.info(f"Запуск поиска SQL файлов в директории: {path}")

        files_sql = [f for f in get_files_by_path(path) if f["file_extension"] == ".sql"]
        logger.info(f"Найдено {len(files_sql)} SQL файлов")

        for file in files_sql:
            logger.info(f"SQL файл: {file['file_name']}")
    except Exception:
        logger.exception("Ошибка при поиске файлов")
        raise
