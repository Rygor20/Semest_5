import sys
import io
import os
import math
import random
import networkx as nx
import matplotlib.pyplot as plt


class Vertex:
    def __init__(self, id, x , y):
        self.id = id
        self.x = x
        self.y = y


class Edge:
    def __init__(self, v1, v2, weight):
        self.v1 = v1
        self.v2 = v2
        self.weight = weight


def euclideanDistance(v1, v2):
    distance = math.sqrt((v1.x - v2.x)**2 + (v1.y - v2.y)**2)
    return distance


def find(parent, vertex):
    if parent[vertex] == vertex:
        return vertex
    return find(parent, parent[vertex])


def union(parent, rank, vertex1, vertex2):
    root1 = find(parent, vertex1)
    root2 = find(parent, vertex2)

    if rank[root1] < rank[root2]:
        parent[root1] = root2
    elif rank[root1] > rank[root2]:
        parent[root2] = root1
    else:
        parent[root2] = root1
        rank[root1] += 1


def kruskal(vertices, edges):
    parent = {vertex.id: vertex.id for vertex in vertices}
    rank = {vertex.id: 0 for vertex in vertices}
    mst = []

    for edge in edges:
        if find(parent, edge.v1.id) != find(parent, edge.v2.id):
            mst.append(edge)
            union(parent, rank, edge.v1.id, edge.v2.id)

    return mst


def dfs(v, visited):
    global tspOrder
    tspOrder.append(v)

    visited[v] = True
    print(v, end="->")

    for neighbor in G.neighbors(v):
        if not visited[neighbor]:
            dfs(neighbor, visited)


def generateRandomPermutation(nodes):
    random.shuffle(nodes)
    return nodes.copy()


xCords = []
yCords = []
vertices = []
edges = []
sortedEdges = []
G = nx.Graph()
tspOrder = []


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Correct usage: python3 MST.py <file_path>")
        sys.exit(1)
    
    filePath = sys.argv[1]

    with io.open(filePath, mode='r') as file:
        text = file.readlines()

    for line in text:
        id, x, y = line.split()
        xCords.append(int(x))
        yCords.append(int(y))

    for i in range(len(xCords)):
        x = xCords[i]
        y = yCords[i]
        
        vertex = Vertex(i + 1, x, y)
        vertices.append(vertex)
        G.add_node(vertex.id) #Adding vertex for graphic representation

    for i in range(len(vertices)):
        for j in range(i + 1, len(vertices)):
            edge = Edge(vertices[i], vertices[j], euclideanDistance(vertices[i], vertices[j]))
            edges.append(edge)

    sortedEdges = sorted(edges, key=lambda edge: edge.weight)

    mst = kruskal(vertices, sortedEdges)
    mstWeight = 0
    tspWeight = 0

    print("Minimum Spanning Tree:")
    for edge in mst:
        G.add_edge(edge.v1.id, edge.v2.id, weight=edge.weight)
        mstWeight += edge.weight
        print(f"  Edge {edge.v1.id}-{edge.v2.id} :: {edge.weight}")

    print(f"Total minimal tree weight :: {mstWeight}\n")

    pos = {vertex.id: (vertex.x, vertex.y) for vertex in vertices}
    nx.draw_networkx_nodes(G, pos, node_size=30)
    nx.draw_networkx_edges(G, pos)
    nx.draw_networkx_labels(G, pos, labels={vertex.id: "" for vertex in vertices}, font_size=5)

    visited = {node: False for node in G.nodes}

    start_vertex = list(G.nodes)[0]
    print(type(start_vertex))
    print("Traveling salesman cycle:")
    dfs(start_vertex, visited)
    print(tspOrder[0])

    for i in range(len(tspOrder) - 1):
        v1 = tspOrder[i]
        v2 = tspOrder[i + 1]

        edgeWeight = euclideanDistance(vertices[v1 - 1], vertices[v2 - 1])
        tspWeight += edgeWeight

    tspWeight += euclideanDistance(vertices[tspOrder[-1] - 1], vertices[tspOrder[0] - 1])
    print(f"TSP cycle weight :: {tspWeight}\n")

    isTspWeightLessOrEqual = tspWeight <= 2 * mstWeight
    print(f"Is TSP weight less or equal to 2 * MST weight? :: {isTspWeightLessOrEqual}")

    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)

    dir_name, file_with_extension = os.path.split(filePath)
    file_name = os.path.splitext(file_with_extension)[0]
    plt.savefig(f'Images/MST/{file_name}_mst.jpg')
    
    plt.clf()
    nx.draw_networkx_nodes(G, pos, node_size=30)

    G.remove_edges_from(G.edges)

    for i in range(len(tspOrder) - 1):
        v1 = tspOrder[i]
        v2 = tspOrder[i + 1]
        G.add_edge(v1, v2, weight=euclideanDistance(vertices[v1 - 1], vertices[v2 - 1]))

    G.add_edge(tspOrder[-1], tspOrder[0], weight=euclideanDistance(vertices[tspOrder[-1] - 1], vertices[tspOrder[0] - 1]))

    nx.draw_networkx_edges(G, pos)
    nx.draw_networkx_labels(G, pos, labels={vertex.id: "" for vertex in vertices}, font_size=5)

    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
    plt.savefig(f'Images/TSP/{file_name}_tsp.jpg')

    rolls = [10, 50]

    for roll in rolls:
        cases = int(1000/roll)
        allRolls = []
        perCase = []
        for case in range(cases):
            perGroup = []

            for _ in range(roll):
                tspOrder = generateRandomPermutation(list(G.nodes))

                weight = 0
                for i in range(len(tspOrder) - 1):
                    v1 = tspOrder[i]
                    v2 = tspOrder[i + 1]

                    edgeWeight = euclideanDistance(vertices[v1 - 1], vertices[v2 - 1])
                    weight += edgeWeight

                weight += euclideanDistance(vertices[tspOrder[-1] - 1], vertices[tspOrder[0] - 1])
                perGroup.append(weight)
                allRolls.append(weight)
            
            minValue = min(perGroup)
            perCase.append(minValue)

            os.makedirs(f"Results/{file_name}", exist_ok=True)

            with open(f'Results/{file_name}/results_{roll}.txt', 'a') as file:
                file.write(f'Group {case+1}: {", ".join(map(str, perGroup))}\n')
        
        minAll = min(allRolls)
        average = sum(perCase) / len(perCase)
        print(f"Average from minimums ({cases} groups of {roll} rolls) : {average}")
        print(f"Minimum from all rolls: {minAll}\n")

        with open(f'Results/{file_name}/results_{roll}.txt', 'a') as file:
            file.write(f'{cases} Groups of {roll} rolls:\n')
            file.write(f'  Minimum: {minAll}\n')
            file.write(f'  Average: {average}\n')