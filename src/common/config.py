import yaml
from common.logger import setup_logger
from common.crypto import get_decrypted_text

logger = setup_logger()


class Config:
    def __init__(self, config_path="config.yml"):
        logger.debug(f"Инициализация конфигурации из файла: {config_path}")
        self.config_path = config_path
        self.config = self._load_config()
        logger.info("Конфигурация успешно загружена")

    def _load_config(self):
        try:
            logger.debug(f"Загрузка конфигурации из файла: {self.config_path}")
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = yaml.safe_load(f)
            logger.debug("Конфигурация успешно прочитана")
            return config
        except Exception:
            logger.exception(f"Ошибка при загрузке конфигурации из файла {self.config_path}")
            raise

    @property
    def database(self):
        logger.debug("Получение настроек базы данных")
        return self.config["database"]

    @property
    def paths(self):
        logger.debug("Получение путей")
        return self.config["paths"]

    @property
    def common(self):
        logger.debug("Получение настроек общих параметров")
        return self.config["common"]

    @property
    def visualization(self):
        logger.debug("Получение настроек визуализации")
        return self.config["visualization"]

    @property
    def neo4j(self):
        """
        Получение настроек Neo4j с дешифрованием пароля
        """
        logger.debug("Получение настроек Neo4j")
        neo4j_config = self.config["neo4j"].copy()
        try:
            # Пробуем дешифровать пароль, если он зашифрован
            neo4j_config["password"] = get_decrypted_text(neo4j_config["password"])
            logger.debug("Пароль Neo4j успешно дешифрован")
        except Exception as e:
            logger.warning(f"Не удалось дешифровать пароль Neo4j: {str(e)}")
        return neo4j_config

    def get_database_path(self, path_key):
        logger.debug(f"Получение пути для ключа: {path_key}")
        path = self.paths[path_key]
        logger.debug(f"Получен путь: {path}")
        return path

    def get_visualization_color(self, object_type):
        logger.debug(f"Получение цвета для типа объекта: {object_type}")
        color = self.visualization["colors"].get(object_type, self.visualization["colors"]["default"])
        logger.debug(f"Получен цвет: {color}")
        return color


config = Config()
