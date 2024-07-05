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


def dfs(v, visited, cycle):
    cycle.append(v)

    visited[v] = True

    for neighbor in G.neighbors(v):
        if not visited[neighbor]:
            dfs(neighbor, visited, cycle)


def generateCycleFromMst(graph):
    startNode = random.choice(list(graph.nodes))
    cycleGraph = nx.Graph()
    global G

    cycleDfs = []
    visited = {node: False for node in graph.nodes}
    dfs(startNode, visited, cycleDfs)
    
    cycleGraph.add_nodes_from(cycleDfs)

    for i in range(len(cycleDfs) - 1):
        cycleGraph.add_edge(cycleDfs[i], cycleDfs[i+1], weight=G[cycleDfs[i]][cycleDfs[i+1]]['weight'])
        
    cycleGraph.add_edge(cycleDfs[len(cycleDfs)-1], cycleDfs[0], weight=G[cycleDfs[len(cycleDfs)-1]][cycleDfs[0]]['weight'])
    return cycleGraph, cycleDfs


def generateRandomPermutation(nodes):
    random.shuffle(nodes)
    return nodes.copy()


def totalWeight(cycle):
    global G
    weight = 0
    for i in range(len(cycle) - 1):
        weight += G[cycle[i]][cycle[i + 1]]['weight']
    weight += G[cycle[len(cycle)-1]][cycle[0]]['weight']

    return weight   


def invert(nodes, i, j):
    newCycle = nodes.copy()
    newCycle[i:j+1] = reversed(nodes[i:j+1])
    return newCycle


def localSearch(nodes, steps=0):
    best = nodes.copy()
    bestWeight = totalWeight(nodes)
    n = len(nodes)

    improvement = True
    while improvement:
        improvement = False
        for i in range(n - 1):
            for j in range(i + 1, n):
                newCycle = invert(best, i, j)
                newCycleWeight = totalWeight(newCycle)

                if newCycleWeight < bestWeight:
                    steps += 1
                    bestWeight = newCycleWeight
                    best = newCycle
                    improvement = True

    return best, steps


def partialLocalSearch(nodes, steps=0):
    best = nodes.copy()
    bestWeight = totalWeight(nodes)
    n = len(nodes)

    improvement = True
    while improvement:
        improvement = False
        for i in range(n):
            index_i = random.randint(0, n-1)
            index_j = random.randint(0, n-1)

            if index_i == 0 and index_j == (n-1):
                continue
            elif index_i == index_j:
                continue
            elif index_i > index_j:
                index_i, index_j = index_j, index_i

            newCycle = invert(best, index_i, index_j)
            newCycleWeight = totalWeight(newCycle)

            if newCycleWeight < bestWeight:
                steps += 1
                bestWeight = newCycleWeight
                best = newCycle
                improvement = True

    return best, steps

xCords = []
yCords = []
vertices = []
edges = []
sortedEdges = []
MST = nx.Graph()
G = nx.Graph()


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
        MST.add_node(vertex.id)
        G.add_node(vertex.id)

    for i in range(len(vertices)):
        for j in range(i + 1, len(vertices)):
            edge = Edge(vertices[i], vertices[j], euclideanDistance(vertices[i], vertices[j]))
            edges.append(edge)
            G.add_edge(edge.v1.id, edge.v2.id, weight=edge.weight)

    sortedEdges = sorted(edges, key=lambda edge: edge.weight)

    mst = kruskal(vertices, sortedEdges)
    mstWeight = 0

    for edge in mst:
        MST.add_edge(edge.v1.id, edge.v2.id, weight=edge.weight)
        mstWeight += edge.weight

    #Zadanie 1

    totalSpanningTreeWeight = 0
    totalSolutionValue = 0
    totalSteps = 0
    bestSolution = float('inf')
    n = len(MST.nodes) 
    iterations = 10 if n > 200 else math.ceil(math.sqrt(n))

    for _ in range(iterations):
        cycleGraph, cycleNodes = generateCycleFromMst(MST)
        
        steps = 0
        cycle, steps = localSearch(cycleNodes)

        solutionValue = totalWeight(cycle)

        if solutionValue < bestSolution:
            bestSolution = solutionValue
            bestCycle = cycle

        totalSolutionValue += solutionValue
        totalSteps += steps

    avgSolutionValue = totalSolutionValue / iterations
    avgSteps = totalSteps / iterations

    print(f"LocalSearch z MST")
    print(f"Waga minimalnego drzewa rozpinającego: {mstWeight}")
    print(f"Średnia wartość uzyskanego rozwiązania: {avgSolutionValue}")
    print(f"Średnia liczba kroków poprawy: {avgSteps}")
    print(f"Najlepsze uzyskane rozwiązanie: {bestSolution}")

    # #Zadanie 2

    totalSpanningTreeWeight = 0
    totalSolutionValue = 0
    totalSteps = 0
    bestSolution = float('inf')
    iterations = 100 if n > 1000 else n

    for _ in range(iterations):
        nodes = generateRandomPermutation(list(MST))
        
        steps = 0
        cycle, steps = localSearch(nodes)

        solutionValue = totalWeight(cycle)

        if solutionValue < bestSolution:
            bestSolution = solutionValue
            bestCycle = cycle

        totalSolutionValue += solutionValue
        totalSteps += steps

    avgSolutionValue = totalSolutionValue / iterations
    avgSteps = totalSteps / iterations

    print(f"LocalSearch z losowej permutacji")
    print(f"Średnia wartość uzyskanego rozwiązania: {avgSolutionValue}")
    print(f"Średnia liczba kroków poprawy: {avgSteps}")
    print(f"Najlepsze uzyskane rozwiązanie: {bestSolution}")

    #Zadanie 3

    totalSpanningTreeWeight = 0
    totalSolutionValue = 0
    totalSteps = 0
    bestSolution = float('inf')
    iterations = 100 if n > 1000 else n

    for _ in range(iterations):
        nodes = generateRandomPermutation(list(MST))
        
        steps = 0
        cycle, steps = partialLocalSearch(nodes)

        solutionValue = totalWeight(cycle)

        if solutionValue < bestSolution:
            bestSolution = solutionValue
            bestCycle = cycle

        totalSolutionValue += solutionValue
        totalSteps += steps

    avgSolutionValue = totalSolutionValue / iterations
    avgSteps = totalSteps / iterations

    print(f"LocalSearch z ograniczonym sasiedztwem z losowej permutacji ")
    print(f"Średnia wartość uzyskanego rozwiązania: {avgSolutionValue}")
    print(f"Średnia liczba kroków poprawy: {avgSteps}")
    print(f"Najlepsze uzyskane rozwiązanie: {bestSolution}")