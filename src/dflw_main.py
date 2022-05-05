import dflw_getfiles
import dflw_modules as dflwm
import json


class FilesToReview:
    config = "files to review"
    files = list()


def prepareconfiginjson(mp: FilesToReview):
    jsonStr = json.dumps(mp.__dict__)
    with open(path_json_config, 'w') as f1:
        f1.write(jsonStr)


if __name__ == '__main__':

    path = r"C:\repos\automapping\adfmanager\src\MATRIX_UK_ETL"
    path_json_config = r"C:\repos\dataflow-doc-generator\output\output-files.json"

    files_sql = [f for f in dflw_getfiles.get_files_by_path(path) if f['fileextension'] == '.sql']

    # prepare a list of scripts for review
    mp = FilesToReview()
    mp.config = "config"
    mp.files = files_sql

    # dump to json file
    prepareconfiginjson(mp)

    for file in mp.files:
        # print(file['filename'])
        object_from_file = dflwm.extract_object_from_file(file["filefullpath"])
        if object_from_file["type"] != "null":
            print(object_from_file)

    # review files in list
    # try to find CREATE TABLE statement and prepare Object
