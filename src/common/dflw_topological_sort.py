# TODO - remove
#to do прочитать файлик с объектами и получить отдельный список таких -> "object_key": "database/greenplum/view/cis_dsp.v_soi_so_plovdiv"
#открыть файл edges и сделать массив тюплов [("source_object_key", "destination_object_key"), ....] 
#впихнуть всё вниз

#Python program to print topological sorting of a DAG
import json
import os
from collections import defaultdict

#путь до файла с последовательностями
path_to_edges = r"C:\repos\-dumps-\output_greenplum\dflw_edges.json"
path_to_edges_top = r"C:\repos\-dumps-\output_greenplum\dflw_objects.json"
path_to_edges_numbers = r"C:\repos\-dumps-\output_greenplum\dflw_edges_number.json"
path_to_output =  r"C:\repos\-dumps-\output_greenplum"

#чтение файла для нахождения количества вершин и изменения их на числа
with open(path_to_edges) as json_file:
    data = json.load(json_file)
    #print(data)

#чтение файла для нахождения всех вершин
with open(path_to_edges_top) as json_file:
    data_top = json.load(json_file)
    #print(data)

#превращение словесного вида в числовой
dict_of_numbers = {}
count = 0
for i in range(len(data_top)):
    if data_top[i]["object_key"] not in dict_of_numbers:
        dict_of_numbers[data_top[i]["object_key"]] = count
        count += 1

for i in range(len(data)):
    if data[i]["destination_object_key"] not in dict_of_numbers:
        dict_of_numbers[data[i]["destination_object_key"]] = count
        count += 1

#переделывет из числового в словесный
def get_key(dict_of_numbers, number):
    for key, value in dict_of_numbers.items():
        if number == value:
            return key
        
#print(len(count_of_edge))
#Class to represent a graph
class Graph:
    def __init__(self,vertices):
        self.graph = defaultdict(list) #dictionary containing adjacency List
        self.V = vertices #No. of vertices
 
    # function to add an edge to graph
    def addEdge(self,u,v):
        self.graph[u].append(v)
 
    # neighbors generator given key
    def neighbor_gen(self,v):
        for k in self.graph[v]:
            yield k
     
    # non recursive topological sort
    def nonRecursiveTopologicalSortUtil(self, v, visited, stack):
         
        # working stack contains key and the corresponding current generator
        working_stack = [(v,self.neighbor_gen(v))]
         
        while working_stack:
            # get last element from stack
            v, gen = working_stack.pop()
            visited[v] = True
             
            # run through neighbor generator until it"s empty
            for    next_neighbor in gen:
                if not visited[next_neighbor]:  # not seen before?
                    # remember current work
                    working_stack.append((v,gen))
                    # restart with new neighbor
                    working_stack.append((next_neighbor, self.neighbor_gen(next_neighbor)))
                    break
            else:
                # no already-visited neighbor (or no more of them)
                stack.append(v)
                 
    # The function to do Topological Sort.
    def nonRecursiveTopologicalSort(self):
        # Mark all the vertices as not visited
        visited = [False]*self.V
         
        # result stack
        stack = []
 
        # Call the helper function to store Topological
        # Sort starting from all vertices one by one
        for i in range(self.V):
            if not(visited[i]):
                self.nonRecursiveTopologicalSortUtil(i, visited,stack)
        # Print contents of the stack in reverse
        #stack.reverse()
        return stack
 
# находим количество всех графов и делаем сортировку
g = Graph(len(dict_of_numbers))
for i in range(len(data)):
    g.addEdge(dict_of_numbers[data[i]["source_object_key"]], dict_of_numbers[data[i]["destination_object_key"]])

#print("The following is a Topological Sort of the given graph")

#в этой переменной массив сортировки
queue_of_files = g.nonRecursiveTopologicalSort()

count = 0
table = ""
with open(os.path.join(path_to_output, "sorted_edges" + "." + "txt"), "w") as f:    
    for i in range(len(queue_of_files)):
        string = get_key(dict_of_numbers, queue_of_files[i])
        if "schema" in string:
            f.write("{}\n".format(str(string)))
        elif "table" in string:
            table = str(string)
            f.write("{}\n".format(str(string)))
        elif "view" in string:
            #print("view")
            f.write("    {}\n".format(str(string)))
        

#print(queue_of_files)
# This code was based of Neelam Yadav"s code, modified by Suhail Alnahari, Python-ified by Matthias Urlichhs