import os

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
            list_of_files.append(os.path.join(root,file))
    for name in list_of_files:
        files_result.append(get_file_info(name))
    return files_result
        

        
def get_file_info(filefullpath):
    """
    function accept file full path and return parsed dict
    :param string: filefullpath
    :return: dict 
    """
    filepath, file_extension = os.path.splitext(filefullpath)
    fileinfo = dict()
    fileinfo['filename'] = os.path.basename(filefullpath)
    fileinfo['filedirname'] = os.path.dirname(filefullpath)
    fileinfo['fileextension'] = file_extension
    fileinfo['filefullpath'] = filefullpath
    return fileinfo
    # print(f"file name  = {fileinfo['filename']} file dir name {fileinfo['filedirname']} ext = {fileinfo['fileextension']}")
    # print(fileinfo)


if __name__ == '__main__':
    
    path =r'C:\repos\automapping\adfmanager\src\MATRIX_UK_ETL'
    

    files_sql = [f for f in get_files_by_path(path) if f['fileextension']=='.sql']

    
    for file in files_sql:
        print(file['filename'])

    #find tables by reviewing files_sql for create table statement
    