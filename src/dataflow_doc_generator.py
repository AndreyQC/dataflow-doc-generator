from turtle import color
from pyvis.network import Network
import json
import os
import networkx as nx

if __name__ == '__main__':

    # for development read data from file
    OUTPUT_FOLDER_PATH = r"C:\Users\Andrey_Potapov\YandexDisk\Practice\Programs\D&A.Grow\materials\D&A.Grow scripts\work_item\BL-156\output"
    #
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_objects" + "." + "json"), 'r') as f:
        data = json.load(f)

    keys = list()
    objects = dict()

    for dflwo in data:
        keys.append(dflwo["object_key"])

    objects = dict(zip(keys, data))

    net = Network(height='750px', width='100%')

    # assign surrogate keys
    for i, (object_key, object_value) in enumerate(objects.items()):
        print(i)
        print(object_value)
        object_value["object_id"] = i
        color = "lightgreen"
        if object_value["type"] == "table":
            color = "lightblue"
        net.add_node(object_value["object_key"], label=object_value["type"] + " " + object_value["name"], shape='box',
                     color=color)  # node id = 1 and label = Node 1

    # go through edges
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_edges" + "." + "json"), 'r') as f:
        data = json.load(f)

    for v in data:
        print(
            f' source_object_key "{v["source_object_key"]}" object_id = "{objects[v["source_object_key"]]["object_id"]}" destination_object_key  ')
        net.add_edge(v["source_object_key"], v["destination_object_key"])

    net.show_buttons(filter_=['physics'])
    net.show('database.html')
