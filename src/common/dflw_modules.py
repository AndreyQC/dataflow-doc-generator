import re
import string


class DataFlowObject:
    type = "files to review"
    files = list()


def search_edges_in_file(not_table, tables):
    """
    Search edges in file
    :param not_table: object for search
    :param tables: list of object where we search
    :return: list of edges
    """

    file_content = get_normalized_file_content(
        (get_file_content(not_table["object_source_file_full_path"])))
    words = file_content.split(" ")

    # обрезаем файл для уменьшения времени работы и предотвращения ошибок при переборе yaml части файла
    index = words.index("autodoc-yaml>")
    words = words[index::]

    found_edges = list()
    for table_key, table in tables.items():
        for i, k in enumerate(words):
            edge = dict()
            if k == table["name"] or k == table["full_name"]:
                if words[i - 1] == "from":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select"
                elif words[i - 1] == "update":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "CHANGE_DATA_IN"
                    edge["action"] = "updated by"
                elif words[i - 1] == "into" and words[i - 2] == "insert":
                    edge["source_object_key"] = not_table["object_key"]
                    edge["destination_object_key"] = table["object_key"]
                    edge["relation"] = "CHANGE_DATA_IN"
                    edge["action"] = "insert by"
                elif words[i - 1] == "join" and words[i - 2] == "inner":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select inner join"
                elif words[i - 1] == "join" and words[i - 2] == "outer" and words[i - 3] == "full":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select full outer join"
                elif words[i - 1] == "join":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select inner join"
                elif words[i - 1] == "join" and words[i - 2] == "left":
                    edge["source_object_key"] = table["object_key"]
                    edge["destination_object_key"] = not_table["object_key"]
                    edge["relation"] = "PROVIDE_DATA_TO"
                    edge["action"] = "select left join"

            if bool(edge):
                found_edges.append(edge)
    return found_edges


def get_file_content(file_path: string):
    """ function get file content as a string by filepath
        returns: file content as string
    """
    with open(file_path, "r", encoding="utf-8-sig") as theFile:
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
    normalized_file_content = file_content.replace("\n", " [newline] ").replace("\t", " ").replace("(", " ") \
        .replace(")", " ").replace("[", "").replace("]", "").lower()
    normalized_file_content = re.sub(" +", " ", normalized_file_content)
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
    name = name.replace("[", "").replace("]", "").replace(";", "")
    object_name["fullname"] = name
    r = name.split(".")
    if len(r) == 1:
        object_name["schema"] = "public"
        object_name["name"] = r[0]
    else:
        object_name["schema"] = r[0]
        object_name["name"] = r[1]
    return object_name


def extract_object_from_file(file_full_path):
    """
    function get dict with file info and will try to extract one
    of the MS SQL server data base objects
    TABLE, STORED PROCEDURE, VIEW, FUNCTION, SCHEMA
    :returns object_name dict (["schema"],["name"],["fullname"],["type"])
    TODO
    deal with the case then create is the last word
    """
    file_content = get_normalized_file_content((get_file_content(file_full_path)))
    words = file_content.split(" ")
    length = len(words)
    object_from_file = dict()
    object_from_file["type"] = "null"
    object_from_file["full_name"] = "null"

    for i, w in enumerate(words):
        if (((words[i - 2] == "create" and words[i - 1] == "or" and words[i] == "replace")
             and (i != length)) or (words[i] == "create") and (i != length)):
            if ((words[i + 1] == "procedure") or (words[i + 1] == "proc")):
                # print(f"-----------------find procedure")
                object_from_file["type"] = "procedure"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "view":
                # print(f"-----------------find view")
                object_from_file["type"] = "view"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "table":
                # print(f"-----------------find table")
                object_from_file["type"] = "table"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "function":
                # print(f"-----------------find function")
                object_from_file["type"] = "function"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_name"]
                object_from_file["schema"] = object_name["schema"]
                object_from_file["name"] = object_name["name"]
                break
            elif words[i + 1] == "schema":
                # print(f"-----------------find schema")
                object_from_file["type"] = "schema"
                object_name = get_object_name(words[i + 2])
                object_from_file["full_name"] = object_name["full_ name"]
                object_from_file["schema"] = object_name["name"]
                object_from_file["name"] = object_name["name"]
                break

    return object_from_file


if __name__ == "__main__":
    dflw_context = {
        "database"
    }

    file = {
        "file_name": "usp_Scanner_Run_Create.sql",
        "file_dir_name": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX\\healthmonitor\\Stored Procedures",
        "file_extension": ".sql",
        "file_full_path": "C:\\repos\\automapping\\adfmanager\\src\\MATRIX\\healthmonitor\\Stored Procedures\\usp_Scanner_Run_Create.sql "
    }

    print(f'file name  {file["file_name"]}')

    object_from_file = extract_object_from_file(file["file_full_path"])
    print(object_from_file)
