from __future__ import annotations
import sys
import graphviz
from typing import List, Dict, Any, Tuple, Set
from itertools import combinations
import subprocess
import time

def count_type():
    with open('edges.txt') as file:
        lines = file.readlines()
        d = dict()
        for line in lines:
            _, _, t = line.split()
            if t in d:
                d[t] = d[t] + 1
            else:
                d[t] = 1
    print(d)

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
        self.edges: Set[Edge] = set()
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

    def add_edge(self, src: int, dst: int, type: Any, add_inverse=False) -> None:
        new_edge = Edge(src, dst, type)
        self.edges.add(new_edge)
        self.id2node[src].add_out_edge(new_edge)
        if add_inverse:
            new_edge_inv = Edge(dst, src, '-'+type)
            self.edges.add(new_edge_inv)
            self.id2node[dst].add_out_edge(new_edge_inv)

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
        dot.render(filename=path, cleanup=True)
    
    def print_file(self, path):
        with open(path, "w") as file:
            for e in self.edges:
                src_name = self.id2node[e.src].name
                dst_name = self.id2node[e.dst].name
                file.write(f'{src_name}\t{dst_name}\t{e.type}\n')
        
# g = Graph()
# ida = g.add_or_get_node('a')
# idb = g.add_or_get_node('b')
# ida2 = g.add_or_get_node('a')
# g.add_edge(ida, idb, 'asdf')
# g.add_edge(ida, idb, 'asdf')

# statement types Addr, Copy, Store, Load, Call, Ret, Gep, Phi, Select, Cmp, BinaryOp, UnaryOp, Branch, ThreadFork, ThreadJoin
# new model       Addr, Copy, Store, Load, NormalGep, VariantGep
# {'2': 609172, '3': 503726, '5': 102173, '0': 200831, '7': 167238, '4': 466359, '1': 382181, '8': 29761, '6': 916449, '10': 301280, '9': 347646, '12': 519719}
class LLVM2GRAPH:
    def __init__(self, GV=False, GPU=False, direct=False):
        self.graphPath = 'edges.txt'
        self.outPath = self.graphPath + '.modified'
        self.graph = Graph()

        self.ADDR = "0"
        self.COPY = "1"
        self.STORE = "2"
        self.LOAD = "3"
        self.NGEP = "4"
        self.VGEP = "5"

        self.GV = GV
        self.GPU = GPU
        self.DIRECT = direct
    
    def write_to_file(self, outPath: str):
        with open(outPath, 'w') as outFile:
            if self.GPU:
                outFile.write(f'{len(self.graph.edges)}\t{self.graph.nodeTCtr}\n')
            for node in self.graph.id2node.values():
                for e in node.get_out_edges():
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
        # elif type == self.CALL or type == self.COPY or type == self.RETURN or type == self.BIN or type == self.SELECT or type == self.PHI or type == self.GEP:
        elif type == self.COPY or type == self.NGEP or type == self.VGEP:
            self.graph.add_edge(src_id, dst_id, 'a')
            self.graph.add_edge(dst_id, src_id, '-a')
        elif type == self.ADDR:
            self.graph.add_edge(src_id, dst_id, '-d')
            self.graph.add_edge(dst_id, src_id, 'd')

            # self.graph.add_edge(dst_id, src_id, 'a')
            # self.graph.add_edge(src_id, dst_id, '-a')

    def add_to_graph_direct(self, src, dst, type):
        src_id = self.graph.add_or_get_node(src)
        dst_id = self.graph.add_or_get_node(dst)
        if type == self.STORE: 
            self.graph.add_edge(src_id, dst_id, 's', add_inverse=True)
        elif type == self.LOAD:
            self.graph.add_edge(src_id, dst_id, 'l', add_inverse=True)
        elif type == self.ADDR:
            self.graph.add_edge(src_id, dst_id, '&', add_inverse=True)
        # elif type == self.CALL or type == self.COPY or type == self.RETURN or type == self.BIN or type == self.SELECT or type == self.PHI or type == self.GEP:
        elif type == self.COPY or type == self.NGEP or type == self.VGEP:
            self.graph.add_edge(src_id, dst_id, 'a', add_inverse=True)

    def run(self):
        with open(self.graphPath) as graphFile:
            # add d, -d and a edges to graph for all STORE and LOAD operations
            # also add a edges for parameter passing
            for src, dst, type in [l.split() for l in graphFile.readlines()]:
                if self.DIRECT:
                    self.add_to_graph_direct(src, dst, type)
                else:
                    self.add_to_graph(src, dst, type)

        # print('adding transitive a edges')
        # for alias_nodes in filter(None,[[edge.dst for edge in v.get_out_edges() if edge.type == '-d'] for k,v in self.graph.id2node.items()]):
        #     for a,b in combinations(alias_nodes,2):
        #         self.graph.clone_out_edges(a,b)

        # self.graph.print()
        if self.GV:
            self.graph.print_gv('pre')
        self.write_to_file(self.outPath)

        if self.GPU:
            if self.DIRECT:
                graspam_cmd = f'/home/lukas/Documents/Graspan-G/bin/comp ../graspan_rules/gpu/rules_pointsto_llvm.txt {self.outPath} 0'
            else:
                graspam_cmd = f'/home/lukas/Documents/Graspan-G/bin/comp ../graspan_rules/gpu/rules_pointsto_with_as.txt {self.outPath} 0'
        else:
            if self.DIRECT:
                graspam_cmd = f'/home/lukas/Documents/Graspan-C/bin/comp {self.outPath} ../graspan_rules/cpu/rules_pointsto_llvm 2 24 24 array'
            else:
                graspam_cmd = f'/home/lukas/Documents/Graspan-C/bin/comp {self.outPath} ../graspan_rules/cpu/rules_pointsto_with_as 2 24 24 array'

        print(f'running: {graspam_cmd}')
        graspan_start = time.time()
        subprocess.run(graspam_cmd.split())
        graspan_end = time.time()
        print(f'graspan done after {graspan_end-graspan_start}')
        print('Reading graspan output edges')
        with open(self.outPath+'.output') as graspan_out:
            lines = graspan_out.readlines()
            # for s, d, t in [(s,d,t) for s, d, t in map(lambda x: x.split(), lines) if t in ['O', 'M', 'V']]:

            for line in map(lambda x: x.split(), lines):
                s, d, t = line
                if t in ['O', 'M', 'V', 'p'] :
                    self.graph.add_edge(int(s), int(d), t)

        
        print('writing graph to edges.txt')
        self.graph.print_file(self.graphPath)

        if self.GV:
            print('writing graph to file after graspan')
            self.graph.print_gv('post')


print('running preprocessing')
clang_in = sys.argv[1]
clang_out = 'out.ll'
clang_cmd = f'clang-12 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm {clang_in} -o {clang_out}'

if not clang_in.split('.')[-1] in ['bc', 'll']:
    subprocess.run(clang_cmd.split())
else:
    clang_out = clang_in
svf_cmd = f'./main {clang_out}'
subprocess.run(svf_cmd.split())

graspan_path = '/home/lukas/Documents/Graspan-C'
main = LLVM2GRAPH(GV=False, GPU=False, direct=True)
main.run()
