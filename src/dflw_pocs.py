import json
import os
import dflw_modules as dflwm

if __name__ == '__main__':

    # for development read data from file
    OUTPUT_FOLDER_PATH = r"C:\repos\dataflow-doc-generator\dataflow-doc-generator\output"
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
