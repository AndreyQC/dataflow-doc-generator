import os

# весь этот код отвечает за нахождения пути к файлу

def get_files_by_path(path):
    """
    function accept path
    :param string: path
    :return: array of dictinaries 
    """
    list_of_files = []
    files_result = []
    for root, dirs, files in os.walk(path):
        for file in files:
            list_of_files.append(os.path.join(root, file))
    for name in list_of_files:
        files_result.append(get_file_info(name))
    return files_result


def get_file_info(file_full_path):
    """
    function accept file full path and return parsed dict
    :param string: filefullpath
    :return: dict 
    """
    filepath, file_extension = os.path.splitext(file_full_path)
    file_info = dict()
    file_info['filename'] = os.path.basename(file_full_path)
    file_info['filedirname'] = os.path.dirname(file_full_path)
    file_info['fileextension'] = file_extension
    file_info['filefullpath'] = file_full_path
    return file_info


if __name__ == '__main__':

    path = r'configure the path to folder with database project'

    files_sql = [f for f in get_files_by_path(path) if f['fileextension'] == '.sql']

    for file in files_sql:
        print(file['filename'])

    # find tables by reviewing files_sql for create table statement
