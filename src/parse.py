import sys
import graphviz
# Addr, Copy, Store, Load, Call, Ret, Gep, Phi, Select, Cmp, BinaryOp, UnaryOp, Branch, ThreadFork, ThreadJoin
edges = []
with open(sys.argv[1]) as file:
    lines = file.readlines()
    unique_types = set()
    for line in lines:
        edges.append(line.split())
    
    # create pdf graph for all load/store edges
    dot = graphviz.Digraph()
    for e in [e for e in edges if e[3] in ['2','3']]:
        dot.edge(e[0], e[2], label=e[3])
    dot.render()