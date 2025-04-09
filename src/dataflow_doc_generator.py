from turtle import color
from pyvis.network import Network
import json
import os
import networkx as nx
from config import config
from sql_processor import FilesToReview, DataFlowObects, prepare_config_in_json, save_list_as_json

if __name__ == "__main__":
    # Используем конфигурацию вместо hardcoded значений
    OUTPUT_FOLDER_PATH = config.get_database_path('output_folder')
    
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_objects" + "." + "json"), "r") as f:
        data = json.load(f)

    keys = list()
    objects = dict()

    for dflwo in data:
        keys.append(dflwo["object_key"])

    objects = dict(zip(keys, data))

    net = Network(
        height=config.visualization['height'],
        width=config.visualization['width']
    )

    # assign surrogate keys
    for i, (object_key, object_value) in enumerate(objects.items()):
        print(i)
        print(object_value)
        object_value["object_id"] = i
        node_color = config.get_visualization_color(object_value["type"])
        net.add_node(
            object_value["object_key"],
            label=object_value["type"] + " " + object_value["name"],
            shape="box",
            color=node_color
        )

    # go through edges
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_edges" + "." + "json"), "r") as f:
        data = json.load(f)

    for v in data:
        print(
            f' source_object_key "{v["source_object_key"]}" object_id = "'
            f'{objects[v["source_object_key"]]["object_id"]}" destination_object_key'
        )
        net.add_edge(v["source_object_key"], v["destination_object_key"])

    net.show_buttons(filter_=["physics"])
    net.show("database.html")
