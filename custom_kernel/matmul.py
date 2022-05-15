# proof of concept for cfpq calculation via matrix multiplication

from typing import List, Dict, Any, Tuple, Set, Union


class Rule:
    def __init__(self, lhs: str, rhs: Union[Tuple[str], str]) -> None:
        self.lhs: str = None
        self.rhs1: str = None
        self.rhs2: str = None
        self.unary: bool = False

        self.lhs = lhs
        if type(rhs) == tuple:
            self.rhs1, self.rhs2 = rhs
        elif type(rhs) == str:
            self.rhs1 = rhs
            self.unary = True

    def __repr__(self) -> str:
        return f"Rule {self.lhs} -> {self.rhs1} {self.rhs2}"


class CFG:
    def __init__(self, N, S, P=[]) -> None:
        self.P: List[Rule] = []
        self.S: Set[str] = set()
        self.N: Set[str] = set()

        self.N = N
        self.S = S
        self.P = P

    def addRule(self, r: Rule):
        # if r.unary:
        #     assert r.rhs1 in self.S
        # else:
        #     assert r.rhs1 in self.N and r.rhs2 in self.N
        self.P.append(r)

    def findProductions(self, a: Set[str], b: Set[str]):
        # print(f'looning at: {a} and {b}')
        result = set()
        for rule in self.P:
            if rule.rhs1 in a and rule.rhs2 in b and not rule.unary:
                result.add(rule.lhs)
        return result


terminals = {"a", "b"}
non_terminals = {"A", "B", "C", "X"}
cfg = CFG(S=terminals, N=non_terminals)
cfg.addRule(Rule(lhs="A", rhs="a"))
cfg.addRule(Rule(lhs="B", rhs="b"))
cfg.addRule(Rule(lhs="C", rhs=("A", "B")))
cfg.addRule(Rule(lhs="X", rhs=("C", "A")))


R, S = 3, 3



# M = [['', 'a', ''],
#     ['', '', 'b'],
#     ['a', '', '']]

M = [[set() for _ in range(S)] for _ in range(R)]
M[0][1].add("A")
M[1][2].add("B")
M[2][0].add("A")

for row in M:
    print(row)
for _ in range(2):
    for i in range(R):
        for j in range(S):
            for k in range(R):
                M[i][j] |= cfg.findProductions(M[i][k],M[k][j])

for row in M:
    print(row)