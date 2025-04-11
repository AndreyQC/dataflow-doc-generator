from pyvis.network import Network
import json
import os
from common.config import config
from common.logger import setup_logger

logger = setup_logger()


def generate_data_flow_diagram(edges, vertices):
    """
    Генерирует диаграмму потока данных на основе JSON файлов с объектами и связями
    """
    try:
        logger.info("Начало генерации диаграммы потока данных")

        output_folder_path = config.get_database_path('output_folder')
        example_output_folder_path = config.get_database_path('example_output_folder')

        logger.debug(f"Путь к выходной директории: {output_folder_path}")
        logger.debug(f"Путь к примеру выходной директории: {example_output_folder_path}")

        # Чтение объектов
        objects_file = os.path.join(output_folder_path, config.common["vertices_file_name"] + ".json")
        logger.debug(f"Чтение файла объектов: {objects_file}")
        with open(objects_file, "r") as f:
            data = json.load(f)

        # Создание словаря объектов
        keys = [dflwo["object_key"] for dflwo in data]
        objects = dict(zip(keys, data))
        logger.info(f"Загружено {len(objects)} объектов")

        # Создание сети
        net = Network(
            height=config.visualization['height'],
            width=config.visualization['width']
        )
        logger.debug("Создана сеть для визуализации")

        # Добавление узлов
        for i, (object_key, object_value) in enumerate(objects.items()):
            logger.debug(f"Добавление узла: {object_key}")
            object_value["object_id"] = i
            node_color = config.get_visualization_color(object_value["type"])
            net.add_node(
                object_value["object_key"],
                label=f"{object_value['type']} {object_value['name']}",
                shape="box",
                color=node_color
            )

        # Чтение и добавление связей
        edges_file = os.path.join(output_folder_path, config.common["edges_file_name"] + ".json")
        logger.debug(f"Чтение файла связей: {edges_file}")
        with open(edges_file, "r") as f:
            edges_data = json.load(f)

        for edge in edges_data:
            logger.debug(
                f"Добавление связи: {edge['source_object_key']} -> {edge['destination_object_key']}"
            )
            net.add_edge(edge["source_object_key"], edge["destination_object_key"])

        # Настройка и сохранение
        net.show_buttons(filter_=["physics"])
        output_file = os.path.join(example_output_folder_path, "database.html")
        logger.debug(f"Сохранение диаграммы в файл: {output_file}")
        html = net.generate_html()
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html)

        logger.info("Диаграмма потока данных успешно сгенерирована")
        return True

    except Exception:
        logger.exception("Ошибка при генерации диаграммы потока данных")
        raise


if __name__ == "__main__":
    edges = []
    vertices = []
    generate_data_flow_diagram(edges, vertices)
