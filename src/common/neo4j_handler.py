from neo4j import GraphDatabase
from common.logger import setup_logger

logger = setup_logger()


class Neo4jHandler:
    def __init__(self, uri, user, password):
        """
        Инициализация подключения к Neo4j
        """
        try:
            self.driver = GraphDatabase.driver(uri, auth=(user, password))
            logger.info(f"Установлено подключение к Neo4j: {uri}")
        except Exception as e:
            logger.error(f"Ошибка подключения к Neo4j: {str(e)}")
            raise

    def close(self):
        """
        Закрытие подключения
        """
        if self.driver:
            self.driver.close()
            logger.debug("Подключение к Neo4j закрыто")

    def clear_database(self):
        """
        Очистка базы данных перед загрузкой новых данных
        """
        with self.driver.session() as session:
            try:
                session.run("MATCH (n) DETACH DELETE n")
                logger.info("База данных Neo4j очищена")
            except Exception as e:
                logger.error(f"Ошибка при очистке базы данных: {str(e)}")
                raise

    def create_node(self, object_data):
        """
        Создание узла в графе
        """
        with self.driver.session() as session:
            try:
                # Создаем узел с типом объекта в качестве метки
                query = (
                    f"CREATE (n:{object_data['type']} {{" +
                    f"name: $name, " +
                    f"schema: $schema, " +
                    f"full_name: $full_name, " +
                    f"container_name: $container_name, " +
                    f"container_type: $container_type, " +
                    f"object_key: $object_key" +
                    f"}})"
                )

                session.run(
                    query,
                    name=object_data["name"],
                    schema=object_data["schema"],
                    full_name=object_data["full_name"],
                    container_name=object_data["container_name"],
                    container_type=object_data["container_type"],
                    object_key=object_data["object_key"]
                )
                logger.debug(f"Создан узел: {object_data['object_key']}")
            except Exception as e:
                logger.error(f"Ошибка при создании узла {object_data['object_key']}: {str(e)}")
                raise

    def create_relationship(self, edge_data):
        """
        Создание связи между узлами
        """
        with self.driver.session() as session:
            try:
                # Создаем связь с указанным типом отношения
                # Тип отношения нельзя параметризовать, поэтому используем форматирование строки
                relation_type = edge_data["relation"].replace(" ", "_")  # Убираем пробелы из типа отношения
                query = (
                    "MATCH (source) WHERE source.object_key = $source_key "
                    "MATCH (dest) WHERE dest.object_key = $dest_key "
                    f"CREATE (source)-[r:{relation_type} {{action: $action}}]->(dest)"
                )
                
                session.run(
                    query,
                    source_key=edge_data["source_object_key"],
                    dest_key=edge_data["destination_object_key"],
                    action=edge_data["action"]
                )
                logger.debug(
                    f"Создана связь: {edge_data['source_object_key']} -[{relation_type}]-> "
                    f"{edge_data['destination_object_key']}"
                )
            except Exception as e:
                logger.error(f"Ошибка при создании связи: {str(e)}")
                raise

    def load_data(self, objects, edges):
        """
        Загрузка всех данных в Neo4j
        """
        try:
            logger.info("Начало загрузки данных в Neo4j")

            # Очищаем базу
            self.clear_database()

            # Создаем узлы
            for obj in objects:
                self.create_node(obj)
            logger.info(f"Загружено {len(objects)} узлов")

            # Создаем связи
            for edge in edges:
                self.create_relationship(edge)
            logger.info(f"Загружено {len(edges)} связей")

            logger.info("Загрузка данных в Neo4j завершена успешно")
        except Exception as e:
            logger.error(f"Ошибка при загрузке данных в Neo4j: {str(e)}")
            raise
        finally:
            self.close()
