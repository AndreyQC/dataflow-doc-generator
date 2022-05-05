import re
import string
from typing import Dict


class DataFlowObject:
    type = "files to review"
    files = list()


def get_filecontent(filepath: string):
    """ function get file content as a string by filepath
        returns: file content as string
    """
    with open(filepath, 'r', encoding="utf-8") as theFile:
        r = theFile.read()
        return r


def get_normalized_filecontent(file_content: string):
    """function expect file content as a string
        1. remove \n
        2. make lower case
        3. replace several tabs with one space
        4. replace several spaces with one space
        returns: normalized file content
    """
    normalized_filecontent = file_content.replace('\n', ' [newline] ').replace('\t', ' ').replace('(', ' ').replace(')', ' ').lower()
    normalized_filecontent = re.sub(' +', ' ', normalized_filecontent)
    return normalized_filecontent

def get_objectname(name: string):
    """ function get string and parse DB object
        for example str = [healthmonitor].[usp_scanner_run_create]
        "schema" = "healthmonitor"
        "name" = "usp_scanner_run_create"
        "fullname"
        returns: objectname dict (["schema"],["name"],["fullname"])                    
    """
    objectname = dict()
    name = name.replace('[', '').replace(']', '')
    objectname["fullname"] = name
    r = name.split(".")
    if len(r) == 1:
        objectname["schema"] = "dbo"
        objectname["name"] = r[0]
    else:
        objectname["schema"] = r[0]
        objectname["name"] = r[1]        
    return objectname


def extract_object_from_file(file):
    """
    function get dict with file info and will try to extract one
    of the MS SQL server data base objects
    TABLE, STORED PROCEDURE 

    TODO
    deal with the case then create is the last word
    """
    filecontent = get_normalized_filecontent((get_filecontent(file)))
    words = filecontent.split(" ")
    lenght = len(words)
    object_from_file = dict()    
    object_from_file["type"] = "null"
    object_from_file["fullname"] = "null"
    # print(words)
    for i, w in enumerate(words):
        if (w == "create") and (i != lenght):
            print(f'find create word on position {i} next word "{words[i + 1]}"')
            if (words[i + 1] == "procedure") or (words[i + 1] == "proc"):
                print(f'-----------------find procedure')
                object_from_file["type"] = "stored procedure"
                objectname = get_objectname(words[i + 2])
                object_from_file["fullname"] = objectname["fullname"]
                object_from_file["schema"] = objectname["schema"]
                object_from_file["name"] = objectname["name"]
                break
            elif words[i + 1] == "view":
                print(f'-----------------find view')
                object_from_file["type"] = "view"
                objectname = get_objectname(words[i + 2])
                object_from_file["fullname"] = objectname["fullname"]
                object_from_file["schema"] = objectname["schema"]
                object_from_file["name"] = objectname["name"]
                break
            elif (words[i + 1] == "table"):
                print(f'-----------------find view')
                object_from_file["type"] = "table"
                objectname = get_objectname(words[i + 2])
                object_from_file["fullname"] = objectname["fullname"]
                object_from_file["schema"] = objectname["schema"]
                object_from_file["name"] = objectname["name"]
                break
            elif (words[i + 1] == "function"):
                print(f'-----------------find view')
                object_from_file["type"] = "table"
                objectname = get_objectname(words[i + 2])
                object_from_file["fullname"] = objectname["fullname"]
                object_from_file["schema"] = objectname["schema"]
                object_from_file["name"] = objectname["name"]
                break
            
    return object_from_file


if __name__ == '__main__':
    dflw_context = {
        "database"
    }

    file = {
        "filename": "usp_Scanner_Run_Create.sql",
        "filedirname": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX_UK_ETL\\MATRIX_UK_ETL\\healthmonitor\\Stored Procedures",
        "fileextension": ".sql",
        "filefullpath": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX_UK_ETL\\MATRIX_UK_ETL\\healthmonitor\\Stored Procedures\\usp_Scanner_Run_Create.sql"
    }

    print(f'file name  {file["filename"]}')
    
    object_from_file = extract_object_from_file(file["filefullpath"])
    print(object_from_file)
