import json
import os
import sys
from pathlib import Path

# Добавляем путь к src в PYTHONPATH
src_path = str(Path(__file__).parent.parent)
sys.path.insert(0, src_path)

from common.neo4j_handler import Neo4jHandler
from common.config import Config
from common.logger import setup_logger

logger = setup_logger()


def load_json_file(file_path: str) -> list:
    """
    Загрузка данных из JSON файла
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        logger.debug("Загружен файл: {}".format(file_path))
        return data
    except FileNotFoundError:
        logger.error("Файл не найден: {}".format(file_path))
        sys.exit(1)
    except json.JSONDecodeError as e:
        logger.error("Ошибка при разборе JSON файла {}: {}".format(file_path, str(e)))
        sys.exit(1)
    except Exception as e:
        logger.error("Ошибка при чтении файла {}: {}".format(file_path, str(e)))
        raise


def validate_json_files(vertices_path: str = None, edges_path: str = None) -> tuple[str, str]:
    """
    Проверка наличия и валидация путей к JSON файлам
    """
    try:
        config = Config()
        base_path = config.paths.get('output_folder', '.')

        # Если пути не указаны, используем значения из конфигурации
        if not vertices_path:
            vertices_path = os.path.join(base_path, 'vertices.json')
        if not edges_path:
            edges_path = os.path.join(base_path, 'edges.json')

        # Проверяем, что пути абсолютные
        vertices_path = os.path.abspath(vertices_path)
        edges_path = os.path.abspath(edges_path)

        # Проверяем существование файлов
        if not os.path.exists(vertices_path):
            logger.error("Файл с вершинами не найден: {}".format(vertices_path))
            sys.exit(1)
        if not os.path.exists(edges_path):
            logger.error("Файл со связями не найден: {}".format(edges_path))
            sys.exit(1)

        return vertices_path, edges_path

    except Exception as e:
        logger.error("Ошибка при проверке файлов: {}".format(str(e)))
        sys.exit(1)


def main(vertices_data: list, edges_data: list):
    """
    Основная функция загрузки данных в Neo4j

    Args:
        vertices_data: Список вершин графа
        edges_data: Список связей графа
    """
    try:
        # Загружаем конфигурацию
        config = Config()
        neo4j_config = config.neo4j

        logger.info("Начало загрузки данных в Neo4j")
        logger.info("Количество вершин: {}".format(len(vertices_data)))
        logger.info("Количество связей: {}".format(len(edges_data)))

        # Инициализируем подключение к Neo4j
        handler = Neo4jHandler(
            uri=neo4j_config['uri'],
            user=neo4j_config['user'],
            password=neo4j_config['password']
        )

        # Загружаем данные в Neo4j
        handler.load_data(vertices_data, edges_data)

        logger.info("Загрузка данных в Neo4j успешно завершена")

    except Exception as e:
        logger.error("Ошибка при загрузке данных в Neo4j: {}".format(str(e)))
        sys.exit(1)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Загрузка данных в Neo4j из JSON файлов")
    parser.add_argument("--vertices", help="Путь к файлу vertices.json")
    parser.add_argument("--edges", help="Путь к файлу edges.json")

    args = parser.parse_args()
    if args.vertices is None:
        args.vertices = os.path.join(r"C:\Temp\data-flow-generator-cis\output", "vertices.json")
    if args.edges is None:
        args.edges = os.path.join(r"C:\Temp\data-flow-generator-cis\output", 'edges.json')

    # Проверяем и получаем пути к файлам
    vertices_path, edges_path = validate_json_files(args.vertices, args.edges)

    # Загружаем данные из JSON файлов
    vertices_data = load_json_file(vertices_path)
    edges_data = load_json_file(edges_path)

    # Запускаем основную функцию с загруженными данными
    main(vertices_data, edges_data)
