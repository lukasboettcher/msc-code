#include "svfhook.h"
#include "Graphs/ConsG.h"

uint handleGep(void *consG, void *pag, uint id, uint offset)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;
    SVF::SVFIR *pg = (SVF::SVFIR *)pag;

    SVF::LocationSet ls;
    ls.setFldIdx(offset);

    const SVF::SVFVar *node = pg->getGNode(id);
    if (const SVF::ObjVar *objPN = SVF::SVFUtil::dyn_cast<SVF::ObjVar>(node))
    {
        if (cg->isBlkObjOrConstantObj(id))
        {
            return id;
        }
    }
    else
    {
        return id;
    }

    uint fieldSrcPtdNode = cg->getGepObjVar(id, ls);

    return fieldSrcPtdNode;
}

unsigned int getNodeCount(void *consG)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;
    unsigned int numNodes = cg->getTotalNodeNum();
    return numNodes;
}

void collectFromBitvectorHook(uint src, uint *memory, std::vector<uint> &pts)
{
    uint index = src * 32;
    uint base, next, bits, ptsTarget;

    while (index != UINT_MAX)
    {
        base = memory[index + 30];
        next = memory[index + 31];

        if (base == UINT_MAX)
        {
            break;
        }

        for (size_t j = 0; j < 30; j++)
        {
            bits = memory[index + j];
            for (size_t k = 0; k < 32; k++)
            {
                if (1 << k & bits)
                {
                    // calculate target from bitvector
                    ptsTarget = 960 * base + 32 * j + k;
                    pts.push_back(ptsTarget);
                }
            }
        }
        index = next;
    }
}

uint handleGepsSVF(void *cg, void *pg, uint *currPts, edgeSet &newPtsEdges)
{
    using namespace SVF;

    SVF::ConstraintGraph *consCG = (SVF::ConstraintGraph *)cg;
    SVF::SVFIR *pag = (SVF::SVFIR *)pg;

    // for (SVF::ConstraintGraph::iterator iter = consCG->begin(), eiter = consCG->begin(); iter != eiter; ++iter)
    for (auto iter : *consCG)
    {
        SVF::ConstraintNode *node = iter.second;
        for (ConstraintEdge *uedge : node->getGepOutEdges())
        {
            if (GepCGEdge *edge = SVFUtil::dyn_cast<GepCGEdge>(uedge))
            {
                // const PointsTo &pts = getDiffPts(edge->getSrcID());
                NodeVector pts;
                collectFromBitvectorHook(edge->getSrcID(), currPts, pts);

                // PointsTo tmpDstPts;
                NodeVector tmpDstPts;
                if (SVFUtil::isa<VariantGepCGEdge>(edge))
                {
                    // If a pointer is connected by a variant gep edge,
                    // then set this memory object to be field insensitive,
                    // unless the object is a black hole/constant.
                    for (NodeID o : pts)
                    {
                        if (consCG->isBlkObjOrConstantObj(o))
                        {
                            tmpDstPts.push_back(o);
                            continue;
                        }

                        if (!pag->getBaseObj(o)->isFieldInsensitive())
                        {
                            MemObj *mem = const_cast<MemObj *>(pag->getBaseObj(o));
                            mem->setFieldInsensitive();
                            consCG->addNodeToBeCollapsed(consCG->getBaseObjVar(o));
                        }

                        // Add the field-insensitive node into pts.
                        NodeID baseId = consCG->getFIObjVar(o);
                        tmpDstPts.push_back(baseId);
                    }
                }
                else if (const NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(edge))
                {
                    // TODO: after the node is set to field insensitive, handling invariant
                    // gep edge may lose precision because offsets here are ignored, and the
                    // base object is always returned.
                    for (NodeID o : pts)
                    {

                        if (consCG->isBlkObjOrConstantObj(o) || pag->getBaseObj(o)->isFieldInsensitive())
                        {
                            tmpDstPts.push_back(o);
                            continue;
                        }

                        // if (!matchType(edge->getSrcID(), o, normalGepEdge))
                        //     continue;

                        NodeID fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
                        tmpDstPts.push_back(fieldSrcPtdNode);
                        // addTypeForGepObjNode(fieldSrcPtdNode, normalGepEdge);
                    }
                }
                else
                {
                    assert(false && "Andersen::processGepPts: New type GEP edge type?");
                }

                NodeID dstId = edge->getDstID();

                for (auto pt : tmpDstPts)
                {
                    newPtsEdges.first.push_back(dstId);
                    newPtsEdges.second.push_back(pt);
                }

                // std::cout << newPtsEdges.first.size() << "\n";

                // union pts

                // if (unionPts(dstId, tmpDstPts))
                // {
                //     pushIntoWorklist(dstId);
                //     return true;
                // }
            }
        }
    }

    return consCG->getTotalNodeNum();
}