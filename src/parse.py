# Addr, Copy, Store, Load, Call, Ret, Gep, Phi, Select, Cmp, BinaryOp, UnaryOp, Branch, ThreadFork, ThreadJoin
with open('edges.txt') as file:
    lines = file.readlines()
    unique_types = set()
    for line in lines:
        src, _, dst, type = line.split()
        # print(f"{src} {dst} {type}")
        if type == '9':
            print(f"{src} {dst}")
        unique_types.add(int(type))
    print(sorted(unique_types))