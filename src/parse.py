from __future__ import annotations
import sys
import graphviz
from typing import List, Dict, Any, Tuple, Set
from itertools import combinations
import subprocess

class Edge:
    def __init__(self, src: int, dst: int, type: Any) -> None:
        self.src = src
        self.dst = dst
        self.type = type
        # self.name = name
    def __str__(self):
        return f'Edge\t{self.src}\t{self.dst}\t{self.type}'
    def __repr__(self) -> str:
        return f'Edge({self.src},{self.dst},{self.type})'
    def __eq__(self, other):
        if type(other) is type(self):
            return self.__dict__ == other.__dict__
        return False
    def __hash__(self):
        return hash((self.src, self.dst, self.type))

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
    def __str__(self):
        return f'Node\t{self.id}\t{self.name}'
    def __repr__(self) -> str:
        return f'Node({self.id},{self.name})'
    def __eq__(self, other):
        if type(other) is type(self):
            return self.__dict__ == other.__dict__
        return False

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

    def print(self):
        for node in self.id2node.values():
            print(node)
        print()
        for e in self.edges:
            print(e)
        print('\n')
    
    def print_gv(self, path=None):
        dot = graphviz.Digraph()
        for e in self.edges:
            src_name = self.id2node[e.src].name
            dst_name = self.id2node[e.dst].name
            dot.edge(src_name, dst_name, label=e.type)
        dot.render(filename=path)

        
# g = Graph()
# ida = g.add_or_get_node('a')
# idb = g.add_or_get_node('b')
# ida2 = g.add_or_get_node('a')
# g.add_edge(ida, idb, 'asdf')
# g.add_edge(ida, idb, 'asdf')

class LLVM2GRAPH:
    def __init__(self, GV=False):
        self.graphPath = sys.argv[1]
        self.outPath = self.graphPath + '.modified'
        self.graph = Graph()
        self.LOAD = "3"
        self.STORE = "2"
        self.CALL = "4"
        self.GV = GV
    
    def write_to_file(self, outPath: str):
        with open(outPath, 'w') as outFile:
            for e in self.graph.edges:
                outFile.write(f'{e.src}\t{e.dst}\t{e.type}\n')

    def add_to_graph(self, src, dst, type):

        src_id = self.graph.add_or_get_node(src)
        src_addr_id = self.graph.add_or_get_node('&'+src)
        dst_id = self.graph.add_or_get_node(dst)

        if type == self.STORE:
            self.graph.add_edge(src_addr_id, src_id, 'd')
            self.graph.add_edge(src_id, src_addr_id, '-d')
            self.graph.add_edge(src_addr_id, dst_id, 'a')
            self.graph.add_edge(dst_id, src_addr_id, '-a')
        elif type == self.LOAD:
            self.graph.add_edge(src_id, dst_id, 'd')
            self.graph.add_edge(dst_id, src_id, '-d')
        elif type == self.CALL:
            self.graph.add_edge(src_id, dst_id, 'a')
            self.graph.add_edge(dst_id, src_id, '-a')

    def run(self):
        with open(self.graphPath) as graphFile:
            # add d, -d and a edges to graph for all STORE and LOAD operations
            # also add a edges for parameter passing
            for src, _, dst, type in [l.split() for l in graphFile.readlines()]:
                if type in ['2','3','4']:
                    self.add_to_graph(src, dst, type)

        for alias_nodes in filter(None,[[edge.dst for edge in v.get_out_edges() if edge.type == '-d'] for k,v in self.graph.id2node.items()]):
            for a,b in combinations(alias_nodes,2):
                self.graph.clone_out_edges(a,b)

        self.graph.print()
        if self.GV:
            self.graph.print_gv()
        self.write_to_file(self.outPath)


clang_in = '../src/test.c'
clang_out = 'out.ll'

clang_cmd = f'clang-12 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm {clang_in} -o {clang_out}'
svf_cmd = f'./main {clang_out}'
subprocess.run(clang_cmd.split())
subprocess.run(svf_cmd.split())

graspan_path = '/home/lukas/Documents/Graspan-C'
main = LLVM2GRAPH(GV=True)
main.run()
