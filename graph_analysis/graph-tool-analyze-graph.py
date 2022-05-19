from graph_tool.all import *
import matplotlib
from numpy import sqrt

g = Graph()
g.load('callgraph_final.dot')

# pos = sfdp_layout(g)
# graph_draw(g, pos, output_size=(1000, 1000), vertex_color=[1,1,1,0],
#            vertex_size=1, edge_pen_width=1.2,
#            vcmap=matplotlib.cm.gist_heat_r, output="price.pdf")

graph_draw(g, output="price.pdf")


deg_in = g.degree_property_map("in")
deg_out = g.degree_property_map("out")

deg_in.a = 4 * (sqrt(deg_in.a) * 0.5 + 0.4)

ebet = betweenness(g)[1]

ebet.a /= ebet.a.max() / 10.

eorder = ebet.copy()

eorder.a *= -1

pos = sfdp_layout(g)

control = g.new_edge_property("vector<double>")

for e in g.edges():

    d = sqrt(sum((pos[e.source()].a - pos[e.target()].a) ** 2)) / 5

    control[e] = [0.3, d, 0.7, d]

graph_draw(g, pos=pos, vertex_size=deg_in, vertex_fill_color=deg_in, vorder=deg_in,

              edge_color=ebet, eorder=eorder, edge_pen_width=ebet,

              edge_control_points=control, # some curvy edges

              output="graph-draw.pdf")