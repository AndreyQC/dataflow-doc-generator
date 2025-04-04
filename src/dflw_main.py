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

    container_name = "postgres"
    container_type = "database"
    path = r"C:\Users\Andrey_Potapov\YandexDisk\Practice\Programs\D&A.Grow\materials\D&A.Grow scripts\work_item\BL-156\pg_dp_deploy_output\ScoreManager_DB" # путь до sql файлов
    path_json_config = r"C:\Users\Andrey_Potapov\YandexDisk\Practice\Programs\D&A.Grow\materials\D&A.Grow scripts\work_item\BL-156\output-reduce-20250225\output-files.json" # путь до output файла
    output_folder_path = r"C:\Users\Andrey_Potapov\YandexDisk\Practice\Programs\D&A.Grow\materials\D&A.Grow scripts\work_item\BL-156\output-reduce-20250225" # путь до папки с output файлами

    files_sql = [f for f in dflw_getfiles.get_files_by_path(path) if f['fileextension'] == '.sql'] # ищем sql файлы 

    # files_sql - список всех sql файлов в заданной директории. есть имя_файла, путь_до_папки_где_лежит, расширение, полный_путь_до_файла

    # prepare a list of scripts for review
    mp = FilesToReview() 
    mp.config = "config"
    mp.files = files_sql

    # красиаво запихиваем mp(files_sql) в json файл

    # dump to json file
    prepare_config_in_json(mp)

    # find data flow objects
    db_objects = list()

    # print(mp)
    for file in mp.files:
        # print("-------" + file['filename'])

        # TODO - remove for debug

        object_from_file = dflwm.extract_object_from_file(file["filefullpath"]) # dflwm.extract_object_from_file парсит файл и находит table, view, schema
        if object_from_file["type"] != "null":
            # если есть данные, то красиво представляем в json формат
            object_from_file["container_name"] = container_name
            object_from_file["container_type"] = container_type
            object_from_file["object_source_file_full_path"] = file["filefullpath"]
            object_from_file["object_key"] = container_type + '/' + container_name + '/' + object_from_file["type"] + '/' + object_from_file["fullname"]
            object_from_file["object_key"] = object_from_file["object_key"].replace(' ', '_')
            db_objects.append(object_from_file)

    db_objects_reduced = [
        {
            "type": item["type"],
            "name": item["fullname"],
            "schema": item["schema"],
            "key": item["object_key"].replace("database", "db").replace("postgres", "pg")
        }
        for item in db_objects
    ]

    save_list_as_json(db_objects, output_folder_path, "db_objects")
    save_list_as_json(db_objects_reduced, output_folder_path, "db_objects_reduced")

    # for development read data from file
    OUTPUT_FOLDER_PATH = r"C:\Users\Andrey_Potapov\YandexDisk\Practice\Programs\D&A.Grow\materials\D&A.Grow scripts\work_item\BL-156\output-reduce-20250225"
    #

    with open(os.path.join(OUTPUT_FOLDER_PATH, "db_objects" + "." + "json"), 'r') as f:
        data = json.load(f)

    # print(data)
    keys = list()
    objects = dict()

    for dbo in data:
        keys.append(dbo["object_key"])

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
    # print(edges)

    # search for views
    views = {key: value for (key, value) in objects.items() if value["type"] == "view"}
    for not_table_key, not_table in not_tables.items():
        # print(value_o["object_source_file_full_path"])
        # open file, prepare for analyze,
        e = dflwm.search_edges_in_file(not_table, views)
        if bool(e):
            edges.extend(e)

    unique_edges = list(map(dict, set(tuple(d.items()) for d in edges)))

    save_list_as_json(unique_edges, output_folder_path, "db_edges")
    db_edges_reduced = [
        {
            "sok": item["source_object_key"].replace("database", "db").replace("postgres", "pg"),
            "dok": item["destination_object_key"].replace("database", "db").replace("postgres", "pg"),
            "relation": item["relation"]
        }
        for item in unique_edges
    ]
    save_list_as_json(db_edges_reduced, output_folder_path, "db_edges_reduced")
