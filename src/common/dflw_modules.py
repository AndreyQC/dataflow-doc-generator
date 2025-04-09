import re
import string
from common.logger import setup_logger

logger = setup_logger()


class DataFlowObject:
    type = "files to review"
    files = list()


def search_edges_in_file(not_table, tables):
    """
    Search edges in file
    :param not_table: object for search
    :param tables: list of object where we search
    :return: list of edges
    """
    logger.debug(f"Поиск связей для объекта: {not_table['object_key']}")
    logger.debug(f"Количество таблиц для поиска: {len(tables)}")

    file_content = get_normalized_file_content(
        (get_file_content(not_table["object_source_file_full_path"])))
    words = file_content.split(" ")

    # обрезаем файл для уменьшения времени работы и предотвращения ошибок при переборе yaml части файла
    try:
        index = words.index("autodoc-yaml>")
        words = words[index::]
        logger.debug("Файл успешно обрезан после метки autodoc-yaml")
    except ValueError:
        logger.warning("Метка autodoc-yaml не найдена, поиск будет выполнен по всему файлу")

    found_edges = list()
    for table_key, table in tables.items():
        for i, k in enumerate(words):
            edge = dict()
            if k == table["name"] or k == table["full_name"]:
                logger.debug(f"Найдено совпадение: {k} в позиции {i}")
                if words[i - 1] == "from":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select"
                    logger.debug(f"Создана связь SELECT: {table['object_key']} -> {not_table['object_key']}")
                elif words[i - 1] == "update":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "CHANGE_DATA_IN"
                    edge["action"] = "updated by"
                    logger.debug(f"Создана связь UPDATE: {not_table['object_key']} -> {table['object_key']}")
                elif words[i - 1] == "into" and words[i - 2] == "insert":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "CHANGE_DATA_IN"
                    edge["action"] = "insert by"
                    logger.debug(f"Создана связь INSERT: {not_table['object_key']} -> {table['object_key']}")
                elif words[i - 1] == "into" and words[i - 2] == "merge":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "CHANGE_DATA_IN"
                    edge["action"] = "upsert by"
                    logger.debug(f"Создана связь INSERT: {not_table['object_key']} -> {table['object_key']}")                    
                elif words[i - 1] == "join" and words[i - 2] == "inner":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select inner join"
                    logger.debug(f"Создана связь INNER JOIN: {table['object_key']} -> {not_table['object_key']}")
                elif words[i - 1] == "join" and words[i - 2] == "outer" and words[i - 3] == "full":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select full outer join"
                    logger.debug(f"Создана связь FULL OUTER JOIN: {table['object_key']} -> {not_table['object_key']}")
                elif words[i - 1] == "join":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select inner join"
                    logger.debug(f"Создана связь JOIN: {table['object_key']} -> {not_table['object_key']}")
                elif words[i - 1] == "join" and words[i - 2] == "left":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select left join"
                    logger.debug(f"Создана связь LEFT JOIN: {table['object_key']} -> {not_table['object_key']}")

            if bool(edge):
                found_edges.append(edge)
    
    logger.info(f"Найдено {len(found_edges)} связей для объекта {not_table['object_key']}")
    return found_edges


def get_file_content(file_path: string):
    """ function get file content as a string by filepath
        returns: file content as string
    """
    logger.debug(f"Чтение содержимого файла: {file_path}")
    try:
        with open(file_path, "r", encoding="utf-8-sig") as theFile:
            r = theFile.read()
            logger.debug("Файл успешно прочитан")
            return r
    except Exception:
        logger.exception(f"Ошибка при чтении файла: {file_path}")
        raise


def get_normalized_file_content(file_content: string):
    """function expect file content as a string
        1. remove \n
        2. make lower case
        3. replace several tabs with one space
        4. replace several spaces with one space
        returns: normalized file content
    """
    logger.debug("Нормализация содержимого файла")
    normalized_file_content = file_content.replace("\n", " [newline] ").replace("\t", " ").replace("(", " ") \
        .replace(")", " ").replace("[", "").replace("]", "").lower()
    normalized_file_content = re.sub(" +", " ", normalized_file_content)
    logger.debug("Содержимое файла успешно нормализовано")
    return normalized_file_content


def get_object_name(name: string):
    """ function get string and parse DB object
        for example str = [healthmonitor].[usp_scanner_run_create]
        "schema" = "healthmonitor"
        "name" = "usp_scanner_run_create"
        "full_name" = "healthmonitor.usp_scanner_run_create"
        returns: object_name dict (["schema"],["name"],["fullname"])
    """
    logger.debug(f"Парсинг имени объекта: {name}")
    object_name = dict()
    name = name.replace("[", "").replace("]", "").replace(";", "")
    object_name["full_name"] = name
    r = name.split(".")
    if len(r) == 1:
        object_name["schema"] = "public"
        object_name["name"] = r[0]
        logger.debug(f"Объект без схемы, используется public: {object_name}")
    else:
        object_name["schema"] = r[0]
        object_name["name"] = r[1]
        logger.debug(f"Объект со схемой: {object_name}")
    return object_name


def extract_object_from_file(file_full_path):
    """
    function get dict with file info and will try to extract one
    of the MS SQL server data base objects
    TABLE, STORED PROCEDURE, VIEW, FUNCTION, SCHEMA
    :returns object_name dict (["schema"],["name"],["fullname"],["type"])
    TODO
    deal with the case then create is the last word
    """
    logger.debug(f"Извлечение объекта из файла: {file_full_path}")
    file_content = get_normalized_file_content((get_file_content(file_full_path)))
    words = file_content.split(" ")
    length = len(words)
    object_from_file = dict()
    object_from_file["type"] = "null"
    object_from_file["full_name"] = "null"

    for i, w in enumerate(words):
        if (((words[i - 2] == "create" and words[i - 1] == "or" and words[i] == "replace")
             and (i != length)) or (words[i] == "create") and (i != length)):
            if ((words[i + 1] == "procedure") or (words[i + 1] == "proc")):
                logger.debug("Найдена хранимая процедура")
                object_from_file["type"] = "procedure"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "view":
                logger.debug("Найдено представление")
                object_from_file["type"] = "view"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "table":
                logger.debug("Найдена таблица")
                object_from_file["type"] = "table"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "function":
                logger.debug("Найдена функция")
                object_from_file["type"] = "function"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "schema":
                logger.debug("Найдена схема")
                object_from_file["type"] = "schema"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["name"]
                object_from_file["name"] = object_name["name"]
                break

    logger.info(f"Извлечен объект: {object_from_file}")
    return object_from_file


if __name__ == "__main__":
    try:
        logger.info("Запуск тестового режима")
        dflw_context = {
            "database"
        }

        file = {
            "file_name": "usp_Scanner_Run_Create.sql",
            "file_dir_name": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX\\healthmonitor\\Stored Procedures",
            "file_extension": ".sql",
            "file_full_path": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX\\healthmonitor\\Stored Procedures\\usp_Scanner_Run_Create.sql "
        }

        logger.info(f'Тестовый файл: {file["file_name"]}')

        object_from_file = extract_object_from_file(file["file_full_path"])
        logger.info(f"Результат извлечения: {object_from_file}")
    except Exception:
        logger.exception("Ошибка в тестовом режиме")
        raise
