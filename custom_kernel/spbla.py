import pyspbla as sp
import sys
from typing import List, Dict, Any, Tuple, Set, Union

    total = -1
    while total != t.nvals:
        total = t.nvals
        t.mxm(t, out=t, accumulate=True)  # t += t * t

    return t


class EdgeList:
    def __init__(self, init_row: str, init_col: str) -> None:
        self.rows = [int(init_row)]
        self.cols = [int(init_col)]
    def append(self, src: str, dst: str):
        self.rows.append(int(src))
        self.cols.append(int(dst))
    def __len__(self):
        return len(self.rows)

# shape = (2, 2)
# a = sp.Matrix.empty(shape=shape)
# b = sp.Matrix.empty(shape=shape)

# a[0, 1] = True
# b[1, 0] = True

# print(a, sep='\n')
# print(a.mxm(b), sep='\n')
nodes = set()

e_srcs = list()
e_dsts = list()
n_srcs = list()
n_dsts = list()

# a_edges = sp.Matrix.empty(shape=())
# d_edges = sp.Matrix.empty(shape=())

# na_edges = sp.Matrix.from_lists()
# nd_edges = sp.Matrix.empty(shape=())

edge_file = sys.argv[1]
with open(edge_file) as file:
    for line in file:
        if len(line) > 3:
            s, d, t = line.split()
            s_num = int(s)
            d_num = int(d)
            nodes.add(s_num)
            nodes.add(d_num)
            if t == 'e':
                e_srcs.append(s_num)
                e_dsts.append(d_num)
            elif t == 'n':
                n_srcs.append(s_num)
                n_dsts.append(d_num)

print('file contents read, creating sparse matrices')
num_verts = len(nodes)
e_edges = sp.Matrix.from_lists((num_verts,num_verts), e_srcs, e_dsts)
n_edges = sp.Matrix.from_lists((num_verts,num_verts), n_srcs, n_dsts)
# ne_edges = e_edges.transpose()
# nn_edges = n_edges.transpose()

t = n_edges.dup()  # Duplicate matrix where to store result
total = 0  # Current number of values
print('memory set up, running compute now')
while total != t.nvals:
    print(f'running, nnz: {t.nvals}')
    total = t.nvals
    t.mxm(e_edges, out=t, accumulate=True)  # t += t * t

