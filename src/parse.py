import sys
import graphviz


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
