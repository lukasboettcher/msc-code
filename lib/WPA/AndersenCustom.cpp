#include "WPA/AndersenCustom.h"

using namespace SVF;
using namespace SVFUtil;

AndersenCustom *AndersenCustom::customInstance = nullptr;

void AndersenCustom::storeEdge(Edges &edges, NodeID src, NodeID dst, s64_t consEdgeType)
{
    string type = to_string(consEdgeType);
    edges[type].first.push_back((spbla_Index)src);
    edges[type].second.push_back((spbla_Index)dst);
};
void AndersenCustom::fillEdges(Edges &edges)
{
    for (auto &entry : *consCG)
    {
        for (auto &x : entry.second->getOutEdges())
        {
            if (const GepCGEdge *gepEdge = SVFUtil::dyn_cast<GepCGEdge>(x))
            {
                spbla_vec_t pts;
                for (auto &addr_in : entry.second->getAddrInEdges())
                    pts.push_back(addr_in->getSrcID());

                unordered_set<SVF::NodeID> pts_in = processGepPts(edges, consCG, pag, pts, gepEdge);
                for (auto &node : pts_in)
                {
                    storeEdge(edges, node, gepEdge->getDstID(), 0);
                }
            }
            else
            {
                storeEdge(edges, x->getSrcID(), x->getDstID(), x->getEdgeKind());
            }
        }
    }
}

void AndersenCustom::solveWorklist()
{
    // while (!isWorklistEmpty())
    // {
    //     NodeID nodeId = popFromWorklist();
    //     collapsePWCNode(nodeId);
    //     // Keep solving until workList is empty.
    //     processNode(nodeId);
    //     collapseFields();
    // }
    PointsToMap ptsMap, copyMap;
    Edges edges;
    fillEdges(edges);
    string grammar_file = "/home/lukas/Documents/msc-test/graspan_rules/custom/pointsto-streamlines.txt";

}
