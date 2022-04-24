from __future__ import annotations
import sys
import graphviz
from typing import List, Dict, Any, Tuple, Set
from itertools import combinations

class Edge:
    def __init__(self, src: int, dst: int, type: Any) -> None:
        self.src = src
        self.dst = dst
        self.type = type
        # self.name = name
class Node:
    def __init__(self, id, name) -> None:
        self.name = name
        self.id = id
        self.out_edges:Set[Edge] = set()

    def add_out_edge(self, edge: Edge):
        assert(edge.src == self.id)
        if not edge in self.out_edges:
            self.out_edges.add(edge)

    def get_out_edges(self) -> Set[Edge]:
        return self.out_edges
class Graph:
    def __init__(self) -> None:
        self.name2id: Dict[str, int] = {}
        self.id2node: Dict[int, Node] = {}
        self.edges: Set[Edge] = []
        self.nodeTCtr = 0

    def add_or_get_node(self, name: str) -> int:
        if not name in self.name2id:
            self.name2id[name] = self.nodeTCtr
            self.nodeTCtr +=1
            id = self.name2id[name]
            assert(not self.name2id[name] in self.id2node)
            self.id2node[id] = Node(id=id, name=name)
            return id
        else:
            assert(self.name2id[name] in self.id2node)
            id = self.name2id[name]
            return id
        
    def clone_out_edges(self, id_a: int, id_b: int):
        a, b = self.id2node[id_a], self.id2node[id_b]
        # add all edges only in a to b
        for e in a.get_out_edges() - b.get_out_edges():
            self.add_edge(b.id, e.dst, e.type)
        for e in b.get_out_edges() - a.get_out_edges():
            self.add_edge(a.id, e.dst, e.type)

    def add_edge(self, src: int, dst: int, type: Any) -> None:
        new_edge = Edge(src, dst, type)
        if not new_edge in self.edges:
            self.edges.append(new_edge)
        self.id2node[src].add_out_edge(new_edge)
class LLVM2GRAPH:
    def __init__(self, GV=False):
        self.graphPath = sys.argv[1]
        self.outPath = self.graphPath + '.modified'
        self.map = {}
        self.edges = []
        self.counter = 0

        self.LOAD = "3"
        self.STORE = "2"
        self.GV = GV

        self.inFile = open(self.graphPath)
        self.outFile = open(self.outPath, 'w')
        self.dot = graphviz.Digraph()

    def insert_or_get(self, name: str):
        if not name in self.map:
            self.map[name] = self.counter
            self.counter +=1
            return self.map[name]
        else:
            return self.map[name]
    
    def write_to_file(self, src, dst, type):
        
        if type == self.STORE:
            self.outFile.write(f"{self.insert_or_get('&'+src)}\t{self.insert_or_get(src)}\td\t\n")
            self.outFile.write(f"{self.insert_or_get(src)}\t{self.insert_or_get('&'+src)}\t-d\t\n")
            self.outFile.write(f"{self.insert_or_get('&'+src)}\t{dst}\ta\t\n")
        elif type == self.LOAD:
            self.outFile.write(f"{self.insert_or_get(src)}\t{self.insert_or_get(dst)}\td\t\n")
            self.outFile.write(f"{self.insert_or_get(dst)}\t{self.insert_or_get(src)}\t-d\t\n")

    def write_to_graphviz(self, src, dst, type):
        if type == self.STORE:
            self.dot.edge(src, dst, "STORE")
        elif type == self.LOAD:
            self.dot.edge(src, dst, "LOAD")

    def run(self):
        lines = self.inFile.readlines()
        for line in lines:
            self.edges.append(line.split())
        for e in [e for e in self.edges if e[3] in ['2','3']]:
            src, _, dst, type = e
            self.write_to_file(src, dst, type)
            if self.GV:
                self.write_to_graphviz(src, dst, type)
        self.dot.render()
        # for e in [e for e in self.edges if e[3] in ['2','3']]:
        #     print(f"{e}   {self.insert_or_get(e[0])} -> {self.insert_or_get(e[2])}")
        for k, v in self.map.items():
            print(f"{v} - {k}")


main = LLVM2GRAPH(GV=True)
main.run()
