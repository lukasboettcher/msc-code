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

unordered_set<NodeID> AndersenCustom::processGepPts(Edges &edges, ConstraintGraph *consCG, SVFIR *pag, spbla_vec_t &pts, const GepCGEdge *edge)
{

    unordered_set<NodeID> gepNodes;
    if (SVFUtil::isa<VariantGepCGEdge>(edge))
    {
        // If a pointer is connected by a variant gep edge,
        // then set this memory object to be field insensitive,
        // unless the object is a black hole/constant.
        for (NodeID o : pts)
        {
            if (consCG->isBlkObjOrConstantObj(o))
            {
                gepNodes.insert(o);
                continue;
            }
            const MemObj *mem = pag->getBaseObj(o);
            if (!mem->isFieldInsensitive())
            {
                MemObj *mem = const_cast<MemObj *>(pag->getBaseObj(o));
                mem->setFieldInsensitive();
                consCG->addNodeToBeCollapsed(consCG->getBaseObjVar(o));
            }

            // Add the field-insensitive node into pts.
            NodeID baseId = consCG->getFIObjVar(o);
            gepNodes.insert(baseId);
        }
    }
    else if (const NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(edge))
    {
        // TODO: after the node is set to field insensitive, handling invariant
        // gep edge may lose precision because offsets here are ignored, and the
        // base object is always returned.
        for (NodeID o : pts)
        {
            if (consCG->isBlkObjOrConstantObj(o))
            {
                gepNodes.insert(o);
                continue;
            }

            NodeID fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
            gepNodes.insert(fieldSrcPtdNode);
        }
    }
    return gepNodes;
}

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

    run(grammar_file, edges, (size_t)consCG->getTotalNodeNum(), ptsMap, copyMap);

}
