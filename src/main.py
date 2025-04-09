import dflw_files
import dflw_modules as dflwm
import json
import os
from config import config


class FilesToReview:
    config = "files to review"
    files = list()


class DataFlowObects:
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


def save_list_as_json(dflw_objects, folder, file_name):
    """
    dump list to json
    :param dflw_objects: list of dfwl objects
    :param folder:
    :return: none
    """
    json_str = json.dumps(dflw_objects)
    with open(os.path.join(folder, file_name + "." + "json"), "w") as f1:
        f1.write(json_str)
    pass


if __name__ == "__main__":
    container_name = config.database["container_name"]
    container_type = config.database["container_type"]
    path = config.get_database_path("sql_files")
    output_folder_path = config.get_database_path("output_folder")

    files_sql = [f for f in dflw_files.get_files_by_path(path) if f["file_extension"] == ".sql"]

    # prepare a list of scripts for review
    mp = FilesToReview()
    mp.config = "config"
    mp.files = files_sql

    prepare_config_in_json(mp)

    # find data flow objects
    db_objects = list()

    for file in mp.files:
        object_from_file = dflwm.extract_object_from_file(file["file_full_path"])
        if object_from_file["type"] != "null":
            object_from_file["container_name"] = container_name
            object_from_file["container_type"] = container_type
            object_from_file["object_source_file_full_path"] = file["file_full_path"]
            object_from_file["object_key"] = container_type + "/" + container_name + "/"
            + object_from_file["type"] + "/" + object_from_file["full_name"]
            object_from_file["object_key"] = object_from_file["object_key"].replace(" ", "_")
            db_objects.append(object_from_file)

    save_list_as_json(db_objects, output_folder_path, "db_objects")

    with open(os.path.join(output_folder_path, "db_objects" + "." + "json"), "r") as f:
        data = json.load(f)

    keys = list()
    objects = dict()

    for dbo in data:
        keys.append(dbo["object_key"])

    objects = dict(zip(keys, data))
    # dict for tables
    tables = {key: value for (key, value) in objects.items() if value["type"] == "table"}
    # dict for other sql objects
    not_tables = {key: value for (key, value) in objects.items() if key not in tables}

    edges = list()

    for not_table_key, not_table in not_tables.items():
        e = dflwm.search_edges_in_file(not_table, tables)
        if bool(e):
            edges.extend(e)

    # search for views
    views = {key: value for (key, value) in objects.items() if value["type"] == "view"}
    for not_table_key, not_table in not_tables.items():
        e = dflwm.search_edges_in_file(not_table, views)
        if bool(e):
            edges.extend(e)

    # search for functions
    functions = {key: value for (key, value) in objects.items() if value["type"] == "function"}
    for not_table_key, not_table in not_tables.items():
        e = dflwm.search_edges_in_file(not_table, functions)
        if bool(e):
            edges.extend(e)

    # search for procedures
    procedures = {key: value for (key, value) in objects.items() if value["type"] == "procedure"}
    for not_table_key, not_table in not_tables.items():
        e = dflwm.search_edges_in_file(not_table, procedures)
        if bool(e):
            edges.extend(e)

    unique_edges = list(map(dict, set(tuple(d.items()) for d in edges)))

    save_list_as_json(unique_edges, output_folder_path, "db_edges")
