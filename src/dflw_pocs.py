import json
import os

if __name__ == '__main__':
    OUTPUT_FOLDER_PATH = r"C:\repos\dataflow-doc-generator\output"

    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_objects" + "." + "json"), 'r') as f_in:
        data = json.load(f_in)

    print(data)
    # 1. get only tables
    # 2. get not tables
    # 2. for each table try to find table in another object
    #    in case of any mentions create an edge between two objects
    keys = list()
    objects = dict()

    for dflwo in data:
        keys.append(dflwo["object_key"])

    objects = dict(zip(keys, data))
    tables = {key: value for (key, value) in objects.items() if value["type"] == "table"}
    not_tables = {key: value for (key, value) in objects.items() if key not in tables}
    print(tables)
    print(not_tables)
