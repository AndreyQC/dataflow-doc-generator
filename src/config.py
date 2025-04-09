import yaml


class Config:
    def __init__(self, config_path="config.yml"):
        self.config_path = config_path
        self.config = self._load_config()

    def _load_config(self):
        with open(self.config_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    @property
    def database(self):
        return self.config["database"]

    @property
    def paths(self):
        return self.config["paths"]

    @property
    def visualization(self):
        return self.config["visualization"]

    def get_database_path(self, path_key):
        return self.paths[path_key]

    def get_visualization_color(self, object_type):
        return self.visualization["colors"].get(object_type, self.visualization["colors"]["default"])


config = Config()
