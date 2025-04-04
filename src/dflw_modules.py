import re
import string
from typing import Dict


class DataFlowObject:
    type = "files to review"
    files = list()


def search_edges_in_file(not_table, tables):
    """
    :param not_table:
    :param tables:
    :return:
    """
    # print(f'Analyzing not table script {not_table["name"]}')

    file_content = get_normalized_file_content(
        (get_file_content(not_table["object_source_file_full_path"])))
    words = file_content.split(" ")

    # обрезаем файл для уменьшения времени работы и предотвращения ошибок при переборе yaml части файла
    index = words.index('autodoc-yaml>')
    words = words[index::]

    # print(words)
    found_edges = list()
    for table_key, table in tables.items():
        for i, k in enumerate(words):
            edge = dict()
            if k == table["name"] or k == table["fullname"]:
                # print(
                #     f'\t\t found a table {table["name"]} in script in {i} position source file '
                #     f'{not_table["object_source_file_full_path"]}')
                # following cases
                # ['parametername', ',parametervalue', 'newline', 'from', 'adf.processheaderparameter',  'where']
                if words[i - 1] == "from":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "select"
                    # print(f'\t\t  ===================  found edge =============================== ')
                    # print(f'\t\t  source object table {table["object_key"]} ')
                    # print(f'\t\t  destination object  {not_table["object_key"]} ')
                elif words[i - 1] == "update":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "updated by"
                    # print(f'\t\t  ===================  found edge =============================== ')
                    # print(f'\t\t  source object table n{ot_table["object_key"]} ')
                    # print(f'\t\t  destination object  {table["object_key"]} ')
                elif words[i - 1] == "into" and words[i - 2] == "insert":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "insert by"
                    # print(f'\t\t  ===================  found edge =============================== ')
                    # print(f'\t\t  source object table {not_table["object_key"]} ')
                    # print(f'\t\t  destination object  {table["object_key"]} ')
                elif words[i - 1] == "join" and words[i - 2] == "inner":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "select inner join"
                    # print(f'\t\t  ===================  found edge =============================== ')
                    # print(f'\t\t  source object table {table["object_key"]} ')
                    # print(f'\t\t  destination object  {not_table["object_key"]} ')
                elif words[i - 1] == "join" and words[i - 2] == "outer" and words[i - 3] == "full":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "select full outer join"
                elif words[i - 1] == "join":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "select inner join"
                elif words[i - 1] == "join" and words[i - 2] == "left":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "select left join"

                # else:
                # print(f'*******************************************************************')
                # print(words[i - 7:i + 1], words[i - 2], words[i - 1], words[i])
                # print(edge)
            if bool(edge):
                found_edges.append(edge)
    return found_edges


def get_file_content(filepath: string):
    """ function get file content as a string by filepath
        returns: file content as string
    """
    with open(filepath, 'r', encoding="utf-8-sig") as theFile:
        r = theFile.read()
        return r


def get_normalized_file_content(file_content: string):
    """function expect file content as a string
        1. remove \n
        2. make lower case
        3. replace several tabs with one space
        4. replace several spaces with one space
        returns: normalized file content
    """
    normalized_file_content = file_content.replace('\n', ' [newline] ').replace('\t', ' ').replace('(', ' ') \
        .replace(')', ' ').replace('[', '').replace(']', '').lower()
    normalized_file_content = re.sub(' +', ' ', normalized_file_content)
    return normalized_file_content


def get_object_name(name: string):
    """ function get string and parse DB object
        for example str = [healthmonitor].[usp_scanner_run_create]
        "schema" = "healthmonitor"
        "name" = "usp_scanner_run_create"
        "fullname"
        returns: object_name dict (["schema"],["name"],["fullname"])
    """
    object_name = dict()
    name = name.replace('[', '').replace(']', '').replace(';', '')
    object_name["fullname"] = name
    r = name.split(".")
    if len(r) == 1:
        object_name["schema"] = "dbo"
        object_name["name"] = r[0]
    else:
        object_name["schema"] = r[0]
        object_name["name"] = r[1]
    return object_name


def extract_object_from_file(file_full_path):
    """
    function get dict with file info and will try to extract one
    of the MS SQL server data base objects
    TABLE, STORED PROCEDURE 
    :returns object_name dict (["schema"],["name"],["fullname"],["type"])
    TODO
    deal with the case then create is the last word
    """
    file_content = get_normalized_file_content((get_file_content(file_full_path)))
    words = file_content.split(" ")
    length = len(words)
    object_from_file = dict()
    object_from_file["type"] = "null"
    object_from_file["fullname"] = "null"
    # print(words)
    for i, w in enumerate(words): #w - слова в файле
        # print(file_full_path)
        # print(words)
        if (((words[i - 2] == 'create' and words[i - 1] == 'or'  and words[i] == 'replace') and (i != length)) or (words[i] == "create") and (i != length)): # добавить craete or replace
            #print(f'find create word on position {i} next word "{words[i + 1]}"')
            if ((words[i + 1] == "procedure") or (words[i + 1] == "proc")) :
                # print(f'-----------------find procedure')
                object_from_file["type"] = "stored_procedure"
                object_name = get_object_name(words[i + 2])
                object_from_file["fullname"] = object_name["fullname"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "view":
                #print(f'-----------------find view')
                object_from_file["type"] = "view"
                object_name = get_object_name(words[i + 2])
                object_from_file["fullname"] = object_name["fullname"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "table":
                # print(f'-----------------find table')
                object_from_file["type"] = "table"
                object_name = get_object_name(words[i + 2])
                object_from_file["fullname"] = object_name["fullname"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "function":
                # print(f'-----------------find function')
                object_from_file["type"] = "function"
                object_name = get_object_name(words[i + 2])
                object_from_file["fullname"] = object_name["fullname"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "schema":
                # print(f'-----------------find schema')
                object_from_file["type"] = "schema"
                object_name = get_object_name(words[i + 2])
                object_from_file["fullname"] = object_name["fullname"]
                object_from_file["schema"] = object_name["name"]
                object_from_file["name"] = object_name["name"]
                break

    return object_from_file


if __name__ == '__main__':
    dflw_context = {
        "database"
    }

    file = {
        "filename": "usp_Scanner_Run_Create.sql",
        "filedirname": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX_UK_ETL\\MATRIX_UK_ETL\\healthmonitor\\Stored "
                       "Procedures",
        "fileextension": ".sql",
        "filefullpath": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX_UK_ETL\\MATRIX_UK_ETL\\healthmonitor\\Stored "
                        "Procedures\\usp_Scanner_Run_Create.sql "
    }

    print(f'file name  {file["filename"]}')

    object_from_file = extract_object_from_file(file["filefullpath"])
    print(object_from_file)
