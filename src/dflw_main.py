import dflw_getfiles
import dflw_modules as dflwm
import json
import os


class FilesToReview:
    config = "files to review"
    files = list()


class DataFlowObects:
    config_json = "dataflow.json"
    config_path = "set"
    objects = list()

    def save_as_json(self):
        json_str = json.dumps(self.__dict__)
        with open(path_json_config, 'w') as f1:
            f1.write(json_str)


def prepare_config_in_json(mp: FilesToReview):
    json_str = json.dumps(mp.__dict__)
    with open(path_json_config, 'w') as f1:
        f1.write(json_str)


def save_list_as_json(dflw_objects, folder, file_name):
    """
    dump list to json
    :param dflw_objects: list of dfwl objects
    :param folder:
    :return: none
    """
    json_str = json.dumps(dflw_objects)
    with open(os.path.join(folder, file_name + "." + "json"), 'w') as f1:
        f1.write(json_str)
    pass


if __name__ == '__main__':

    container_name = "matrix_uk_etl"
    container_type = "mssql_database"
    path = r"C:\repos\automapping\adfmanager\src\MATRIX_UK_ETL"
    path_json_config = r"C:\repos\dataflow-doc-generator\output\output-files.json"
    output_folder_path = r"C:\repos\dataflow-doc-generator\output"

    files_sql = [f for f in dflw_getfiles.get_files_by_path(path) if f['fileextension'] == '.sql']

    # prepare a list of scripts for review
    mp = FilesToReview()
    mp.config = "config"
    mp.files = files_sql

    # dump to json file
    prepare_config_in_json(mp)

    # find data flow objects
    dflw_objects = list()

    for file in mp.files:
        print("-------" + file['filename'])
        # TODO - remove for debug
        # if file['filename'] == "Configuration.sql":
        object_from_file = dflwm.extract_object_from_file(file["filefullpath"])
        if object_from_file["type"] != "null":
            object_from_file["container_name"] = container_name
            object_from_file["container_type"] = container_type
            object_from_file["object_source_file_full_path"] = file["filefullpath"]
            object_from_file["object_key"] = container_type + '/' + container_name + '/' + object_from_file[
                "type"] + '/' + object_from_file["fullname"]
            object_from_file["object_key"] = object_from_file["object_key"].replace(' ', '_')
            dflw_objects.append(object_from_file)

    save_list_as_json(dflw_objects, output_folder_path, "dflw_objects")

    # for development read data from file
    OUTPUT_FOLDER_PATH = r"C:\repos\dataflow-doc-generator\output"
    #
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_objects" + "." + "json"), 'r') as f:
        data = json.load(f)

    # print(data)
    keys = list()
    objects = dict()

    for dflwo in data:
        keys.append(dflwo["object_key"])

    objects = dict(zip(keys, data))
    # dict for tables
    tables = {key: value for (key, value) in objects.items() if value["type"] == "table"}
    # dict for other sql objects
    not_tables = {key: value for (key, value) in objects.items() if key not in tables}

    # print(type(tables))
    edges = list()

    for not_table_key, not_table in not_tables.items():
        # print(value_o["object_source_file_full_path"])
        # open file, prepare for analyze,
        e = dflwm.search_edges_in_file(not_table, tables)
        if bool(e):
            edges.extend(e)
    print(edges)

    save_list_as_json(edges, output_folder_path, "dflw_edges")
