import sys
import matplotlib.pyplot as plt

# pag types   Addr, Copy, Store, Load, Call, Ret, Gep, Phi, Select, Cmp, BinaryOp, UnaryOp, Branch, ThreadFork, ThreadJoin
# consg types Addr, Copy, Store, Load, NormalGep, VariantGep

edgeFile = sys.argv[1]
fig, ax = plt.subplots(figsize=(8,8), dpi=600)
print("splitting lines and converting to ints")
with open(edgeFile) as pagGraph:
        splitLines = [map(int, line.split()) for line in pagGraph]
print("unzipping split lines")
srcs, dsts, types = zip(*splitLines)
print("scatter")
scatter = ax.scatter(srcs, dsts, s=.01, c=types, marker='+', cmap='tab20')
ax.set_title(f"Adjacency for {edgeFile}")
ax.set_xlabel("sources")
ax.set_ylabel("destinations")
legend = ax.legend(*scatter.legend_elements(), title="Edge")
ax.add_artist(legend)
plt.savefig(f'plot-{edgeFile}.png')
