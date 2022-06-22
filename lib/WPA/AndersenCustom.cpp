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
}
