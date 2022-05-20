import pyspbla as sp
import sys
from typing import List, Dict, Any, Tuple, Set, Union


def transitive_closure(a: sp.Matrix, b: sp.Matrix, t: sp.Matrix):
    total = -1
    while total != t.nvals:
        total = t.nvals
        a.mxm(b, out=t, accumulate=True)


class Rule:
    def __init__(self, type: int, lhs: str, rhs=None) -> None:
        self.type = type
        self.lhs = lhs
        self.rhs = rhs
        self.rhs_c = -1

    def __repr__(self) -> str:
        return f"Rule {self.lhs} -> {self.rhs}"

    def __eq__(self, other):
        if type(other) is type(self):
            return self.__dict__ == other.__dict__
        return False

    def __hash__(self):
        return hash((self.type, self.lhs, self.rhs))


class EdgeList:
    def __init__(self, init_row: str, init_col: str) -> None:
        self.rows = [int(init_row)]
        self.cols = [int(init_col)]

    def append(self, src: str, dst: str):
        self.rows.append(int(src))
        self.cols.append(int(dst))

    def __len__(self):
        return len(self.rows)


nodes = set()
edgeLists: Dict[str, EdgeList] = dict()
ms: Dict[str, sp.Matrix] = dict()

# simple grammar
# rules = [Rule(1, 'A', 'a'), Rule(1, 'B', 'b'), Rule(2, 'C', ('A', 'B'))]
# dataflow grammar
# rules = [Rule(1, 'E', 'e'), Rule(1, 'N', 'n'), Rule(2, 'N', ('N', 'E'))]
# points to grammar
rules = [
    Rule(1, "D", "d"),
    Rule(1, "-D", "-d"),
    Rule(1, "A", "a"),
    Rule(1, "-A", "-a"),
    Rule(0, "MAs"),
    Rule(0, "AMs"),
    Rule(2, "M", ("DV", "D")),
    Rule(2, "DV", ("-D", "V")),
    Rule(2, "V", ("MAM", "AMs")),
    Rule(2, "V", ("MAs", "AMs")),
    Rule(2, "MAM", ("MAs", "M")),
    Rule(2, "MAs", ("MAs", "MA")),
    Rule(2, "MAs", ("MAs", "-A")),
    Rule(2, "MA", ("M", "-A")),
    Rule(2, "AMs", ("AMs", "AM")),
    Rule(2, "AMs", ("AMs", "A")),
    Rule(2, "AM", ("A", "M")),
]

print("Reading Edges")
edge_file = sys.argv[1]
with open(edge_file) as file:
    for line in file:
        if len(line) > 3:
            s, d, t = line.split()
            nodes.add(s)
            nodes.add(d)
            if t not in edgeLists:
                edgeLists[t] = EdgeList(s, d)
            else:
                edgeLists[t].append(s, d)

# create empty matrices for all symbols in grammar
print("Creating initial empty Matrices for all Symbols")
symbols = set()
for r in rules:
    symbols.add(r.lhs)
    ms[r.lhs] = sp.Matrix.empty((len(nodes), len(nodes)))

print("Filling type 1 Matrices with edge data")
for rule in [r for r in rules if r.type == 1]:
    edges = edgeLists[rule.rhs]
    ms[rule.lhs].build(cols=edges.cols, rows=edges.rows)

print("Adding Epsilon Edges")
for rule in [r for r in rules if r.type == 0]:
    ms[rule.lhs].build(cols=range(len(nodes)), rows=range(len(nodes)))

change = True
iter = 1
while change:
    change = False
    for rule in [r for r in rules if r.type == 2]:
        lhs, (rhs1, rhs2) = rule.lhs, rule.rhs
        # check of rhs has changed, if not, skip
        if rule.rhs_c == ms[rhs1].nvals + ms[rhs2].nvals:
            continue
        # detect whether lhs matrix was changed
        before = ms[lhs].nvals
        while True:
            print(f"\r[{iter}] running for lhs: {lhs}, nnz: {ms[lhs].nvals}", flush=True, end="")
            ms[rhs1].mxm(ms[rhs2], out=ms[lhs], accumulate=True)
            if ms[lhs].nvals == before:
                break
            before = ms[lhs].nvals
            change = True
        print()
        # update rhs state
        rule.rhs_c = ms[rhs1].nvals + ms[rhs2].nvals
    iter += 1

# print results
# for s in symbols:
#     print(s)
#     print(ms[s], sep="\n")
