#!/bin/python3

# this python script reads edges of the form "_, dst, _, src, name"
# and applies a simple rewrite rule

ptsEdges = set()
invCopyEdges = set()
newPtsEdges = set()
invLoadEdges = set()
invStoreEdges = set()


fileName = "/home/lukas/Documents/msc-code/build/ptagpu/out.edges"
with open(fileName) as file:
    lines = file.readlines()
    nodecount, numaddr, numcopy, numload, numstore = map(int, lines[0].split())
    for i in range(1, 1+numaddr):
        # print(f"{lines[i]}")
        _, dst, _, src, name = lines[i].split()
        assert(name == 'addr')
        # print(f"{src} {dst}")
        ptsEdges.add((int(src), int(dst)))
    
    i = 1+numaddr
    _, dst, _, src, name = lines[i].split()
    while(name == 'copy'):
        invCopyEdges.add((int(src), int(dst)))
        i +=1
        _, dst, _, src, name = lines[i].split()

    for j in range(i, i+numload):
        # print(f"{lines[i]}")
        _, dst, _, src, name = lines[j].split()
        assert(name == 'load')
        # print(f"{src} {dst}")
        invLoadEdges.add((int(src), int(dst)))

    for j in range(i+numload, i+numload+numstore):
        # print(f"{lines[i]}")
        _, dst, _, src, name = lines[j].split()
        assert(name == 'store')
        # print(f"{src} {dst}")
        invStoreEdges.add((int(src), int(dst)))
    


    # for i in range(1+numaddr, 1+numaddr+numcopy):
    #     # print(f"{lines[i]}")
    #     _, dst, _, src, name = lines[i].split()
    #     assert(name == 'copy')
    #     # print(f"{src} {dst}")
    #     invCopyEdges.add((int(src), int(dst)))

def closure(setA, setB, setC):
    for src, dst in setA:
        for src_p, dst_p in setB:
            if dst == src_p:
                setC.add((src, dst_p))

# closure(invCopyEdges, ptsEdges, newPtsEdges)
closure(invLoadEdges, ptsEdges, newPtsEdges)

newPtsEdges = sorted(newPtsEdges)
# for src, dst in newPtsEdges:
#     print(f"added: {src} {dst}")
print(len(newPtsEdges))
for i in range(nodecount):
    print(f"\n {i} -> [", end='')
    for src, dst in newPtsEdges:
        if src == i:
            print(f"{dst} ", end='')
    print("]", end='')

realnewPtsEdges = set()
closure(invCopyEdges, ptsEdges, realnewPtsEdges)

for src, dst in newPtsEdges:
    if not (src, dst) in invCopyEdges:
        # print(f"new copy from {src} to {dst}")

        for src_p, dst_p in realnewPtsEdges:
            if dst == src_p:
                print(f"yoo found pts edge as result of new copy edge from {src} to {dst_p}")