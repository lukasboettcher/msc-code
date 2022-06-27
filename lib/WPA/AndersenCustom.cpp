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

void AndersenCustom::fillMatrices()
{
    for (auto &node : *consCG)
    {
        for (auto &outEdge : node.second->getOutEdges())
        {
            size_t src, dst, type;
            src = outEdge->getSrcID();
            dst = outEdge->getDstID();
            type = outEdge->getEdgeKind();
            switch (type)
            {
            case 0:
                // addr
                spbla_Matrix_SetElement(addr, src, dst);
                break;
            case 1:
                // copy
                spbla_Matrix_SetElement(copy, src, dst);
                break;
            case 2:
                // store
                spbla_Matrix_SetElement(store, src, dst);
                break;
            case 3:
                // load
                spbla_Matrix_SetElement(load, src, dst);
                break;
            case 4:
                // normal gep
                break;
            case 5:
                // var gep
                spbla_Matrix_SetElement(copy, src, dst);
                break;

            default:
                break;
            }
        }
    }
}

void fixpointAlgorithm(spbla_Matrix A, spbla_Matrix B, spbla_Matrix C, bool &change)
{
    spbla_Index before;
    before = get_nnz(C);
    while (true)
    {
        spbla_MxM(C, A, B, SPBLA_HINT_ACCUMULATE); // C += A x B
        if (get_nnz(C) == before)
            break;
        before = get_nnz(C);
        change = true;
    }
};

spbla_Index spbla_GetEntry(spbla_Matrix m, spbla_Index i, spbla_Index j)
{
    spbla_Index nvals;
    spbla_Matrix out;
    spbla_Matrix_New(&out, 1, 1);
    spbla_Matrix_ExtractSubMatrix(out, m, i, j, 1, 1, SPBLA_HINT_NO);
    spbla_Matrix_Nvals(out, &nvals);
    spbla_Matrix_Free(out);
    return nvals;
}

spbla_vec_t AndersenCustom::getPtsTo(NodeID a)
{
    spbla_Matrix out;
    spbla_Index nrows, ncols, nvals, *adjarr, *dummy, i;
    spbla_vec_t ptsList;
    spbla_Matrix_Nrows(addr, &nrows);
    spbla_Matrix_Ncols(addr, &ncols);

    // get column for a, this is the transpose of addr out edges, so pts set for a
    spbla_Matrix_New(&out, nrows, 1);
    spbla_Matrix_ExtractSubMatrix(out, addr, 0, a, nrows, 1, SPBLA_HINT_NO);
    spbla_Matrix_Nvals(out, &nvals);
    adjarr = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    dummy = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(out, adjarr, dummy, &nvals);

    for (i = 0; i < nvals; i++)
        ptsList.push_back(adjarr[i]);

    free(adjarr);
    free(dummy);
    spbla_Matrix_Free(out);

    return ptsList;
}

AliasResult AndersenCustom::alias(NodeID a, NodeID b)
{
    // cout << "USING custom alias to check alias between: " << a << " and: " << b << "\n";
    spbla_vec_t ptsA, ptsB;
    ptsA = getPtsTo(a);
    ptsB = getPtsTo(b);
    for (spbla_Index pta : ptsA)
        for (spbla_Index ptb : ptsB)
            if (pta == ptb)
                return AliasResult::MayAlias;
    return AliasResult::NoAlias;
}

void AndersenCustom::solveWorklist()
{
    // /*
    if (!addr && consCG)
    {
        spbla_Initialize(SPBLA_HINT_CUDA_BACKEND);
        setupMatrices();
        fillMatrices();
    }

    bool change = true;
    while (change)
    {
        change = false;
        {
            spbla_Matrix naddr = create_spbla_transpose(addr);
            fixpointAlgorithm(store, naddr, copy, change);
            spbla_Matrix_Free(naddr);
        }
        {
            fixpointAlgorithm(addr, load, copy, change);
        }
        {
            fixpointAlgorithm(addr, copy, addr, change);
        }
    }
        }
    }

    run(grammar_file, edges, (size_t)consCG->getTotalNodeNum(), ptsMap, copyMap);

    for (auto &i : ptsMap)
    {
        for (auto &j : i.second)
        {
            // cout << i.first << " points to: " << j << "\n";
            addPts(i.first, j);
        }
    }

    for (auto &i : copyMap)
    {
        for (auto &j : i.second)
        {
            addCopyEdge(i.first, j);
        }
    }

    collapseFields();
}
