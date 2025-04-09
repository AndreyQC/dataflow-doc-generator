import json
import os
from common.config import config
from pyvis.network import Network
import common.dflw_modules as dflwm

if __name__ == "__main__":

    
    OUTPUT_FOLDER_PATH = config.get_database_path('output_folder')
    
    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_objects" + "." + "json"), "r") as f:
        data = json.load(f)

    for v in data:
        print(
            f"{v["object_key"].replace("/", "_").replace(".", "_")}   [label="{v["type"]} {v["full_name"]}" shape=box "
            f"color={"lightblue" if v["type"] == "table" else "green"} ];  ")

    with open(os.path.join(OUTPUT_FOLDER_PATH, "dflw_edges" + "." + "json"), "r") as f:
        data = json.load(f)

    for v in data:
        print(
            f"{v["source_object_key"].replace("/", "_").replace(".", "_")} -> {v["destination_object_key"].replace("/", "_").replace(".", "_")}")

