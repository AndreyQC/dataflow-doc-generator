import common.dflw_files as dflw_files
import common.dflw_modules as dflwm
import json
import os
from common.config import config
from common.logger import setup_logger
from common.dflw_doc_generator import generate_data_flow_diagram
from common.neo4j_handler import Neo4jHandler

logger = setup_logger()


class FilesToReview:
    config = "files to review"
    files = list()


class DataFlowObjects:
    config_json = "dataflow.json"
    config_path = "set"
    objects = list()

    def save_as_json(self):
        json_str = json.dumps(self.__dict__)
        with open(config.get_database_path("output_json"), "w") as f1:
            f1.write(json_str)


def prepare_config_in_json(mp: FilesToReview):
    json_str = json.dumps(mp.__dict__)
    with open(config.get_database_path("output_json"), "w") as f1:
        f1.write(json_str)


def save_list_as_json(data_list, output_folder_path, file_name):
    """
    Сохранение списка в JSON файл
    """
    try:
        file_path = os.path.join(output_folder_path, f"{file_name}.json")
        logger.debug(f"Сохранение данных в файл: {file_path}")
        with open(file_path, "w") as f:
            json.dump(data_list, f, indent=2)
        logger.debug("Данные успешно сохранены")
    except Exception:
        logger.exception(f"Ошибка при сохранении файла: {file_path}")
        raise


def process_sql_files():
    """
    Обработка SQL файлов и сохранение результатов
    """
    try:
        logger.info("Начало обработки SQL файлов")

        container_name = config.database["container_name"]
        container_type = config.database["container_type"]
        path = config.get_database_path("source_sql_files")
        output_folder_path = config.get_database_path("output_folder")

        logger.debug(f"Конфигурация: container_name={container_name}, container_type={container_type}")
        logger.debug(f"Путь к исходным файлам: {path}")
        logger.debug(f"Путь для выходных файлов: {output_folder_path}")

        # Получаем список SQL файлов
        files_sql = [f for f in dflw_files.get_files_by_path(path) if f["file_extension"] == ".sql"]
        logger.info(f"Найдено {len(files_sql)} SQL файлов для обработки")

        # Извлекаем объекты из файлов
        db_objects = []
        for file in files_sql:
            logger.debug(f"Обработка файла: {file['file_full_path']}")
            object_from_file = dflwm.extract_object_from_file(file["file_full_path"])
            if object_from_file["type"] != "null":
                object_from_file["container_name"] = container_name
                object_from_file["container_type"] = container_type
                object_from_file["object_source_file_full_path"] = file["file_full_path"]
                object_from_file["object_key"] = (
                    f"{container_type}/{container_name}/"
                    f"{object_from_file['type']}/{object_from_file['full_name']}"
                ).replace(" ", "_")
                db_objects.append(object_from_file)
                logger.debug(f"Добавлен объект: {object_from_file['object_key']}")

        # Сохраняем объекты в JSON
        save_list_as_json(db_objects, output_folder_path, config.common["vertices_file_name"])
        logger.info(f"Сохранено {len(db_objects)} объектов в JSON")

        # Создаем словарь объектов
        keys = [obj["object_key"] for obj in db_objects]
        objects = dict(zip(keys, db_objects))

        # Разделяем объекты по типам
        tables = {k: v for k, v in objects.items() if v["type"] == "table"}
        not_tables = {k: v for k, v in objects.items() if k not in tables}
        views = {k: v for k, v in objects.items() if v["type"] == "view"}
        functions = {k: v for k, v in objects.items() if v["type"] == "function"}
        procedures = {k: v for k, v in objects.items() if v["type"] == "procedure"}

        logger.info(f"Найдено: таблиц - {len(tables)}, представлений - {len(views)}, "
                   f"функций - {len(functions)}, процедур - {len(procedures)}")

        # Ищем связи
        edges = []
        for not_table_key, not_table in not_tables.items():
            # Поиск связей с таблицами
            e = dflwm.search_edges_in_file(not_table, tables)
            if e:
                edges.extend(e)
                logger.debug(f"Найдены связи с таблицами для {not_table_key}")

            # Поиск связей с представлениями
            e = dflwm.search_edges_in_file(not_table, views)
            if e:
                edges.extend(e)
                logger.debug(f"Найдены связи с представлениями для {not_table_key}")

            # Поиск связей с функциями
            e = dflwm.search_edges_in_file(not_table, functions)
            if e:
                edges.extend(e)
                logger.debug(f"Найдены связи с функциями для {not_table_key}")

            # Поиск связей с процедурами
            e = dflwm.search_edges_in_file(not_table, procedures)
            if e:
                edges.extend(e)
                logger.debug(f"Найдены связи с процедурами для {not_table_key}")

        # Удаляем дубликаты связей
        unique_edges = list(map(dict, set(tuple(sorted(d.items())) for d in edges)))
        logger.info(f"Найдено {len(unique_edges)} уникальных связей")

        # Сохраняем связи в JSON
        save_list_as_json(unique_edges, output_folder_path, config.common["edges_file_name"])
        logger.info("Связи сохранены в JSON")

        # Загружаем данные в Neo4j
        neo4j_handler = Neo4jHandler(
            config.neo4j["uri"],
            config.neo4j["user"],
            config.neo4j["password"]
        )
        neo4j_handler.load_data(db_objects, unique_edges)
        logger.info("Данные успешно загружены в Neo4j")

        return True

    except Exception:
        logger.exception("Ошибка при обработке SQL файлов")
        raise


if __name__ == "__main__":
    process_sql_files()
