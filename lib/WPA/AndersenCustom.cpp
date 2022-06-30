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

void AndersenCustom::handleNormalGepEdge(ConstraintEdge *edge)
{
    if (const NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(edge))
    {
        for (NodeID o : ptsMap[normalGepEdge->getSrcID()])
        {

            if (consCG->isBlkObjOrConstantObj(o))
            {
                spblaCheck(spbla_Matrix_SetElement(addr, o, normalGepEdge->getDstID()));
                continue;
            }

            NodeID fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
            spblaCheck(spbla_Matrix_SetElement(addr, fieldSrcPtdNode, normalGepEdge->getDstID()));
        }
    }
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
                spblaCheck(spbla_Matrix_SetElement(addr, src, dst));
                break;
            case 1:
                // copy
                spblaCheck(spbla_Matrix_SetElement(copy, src, dst));
                break;
            case 2:
                // store
                spblaCheck(spbla_Matrix_SetElement(store, src, dst));
                break;
            case 3:
                // load
                spblaCheck(spbla_Matrix_SetElement(load, src, dst));
                break;
            case 4:
                // normal gep
                // handleNormalGepEdge(outEdge);
                spblaCheck(spbla_Matrix_SetElement(copy, src, dst));
                break;
            case 5:
                // var gep
                spblaCheck(spbla_Matrix_SetElement(copy, src, dst));
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
        spblaCheck(spbla_MxM(C, A, B, SPBLA_HINT_ACCUMULATE)); // C += A x B
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
    spblaCheck(spbla_Matrix_New(&out, 1, 1));
    spblaCheck(spbla_Matrix_ExtractSubMatrix(out, m, i, j, 1, 1, SPBLA_HINT_NO));
    spblaCheck(spbla_Matrix_Nvals(out, &nvals));
    spblaCheck(spbla_Matrix_Free(out));
    return nvals;
}

AliasResult AndersenCustom::alias(NodeID a, NodeID b)
{
    // cout << "USING custom alias to check alias between: " << a << " and: " << b << "\n";
    std::set<spbla_Index> ptsA, ptsB;
    ptsA = ptsMap[a];
    ptsB = ptsMap[b];
    for (spbla_Index pta : ptsA)
        for (spbla_Index ptb : ptsB)
            if (pta == ptb)
                return AliasResult::MayAlias;
    return AliasResult::NoAlias;
}

void AndersenCustom::initialize()
{
    cout << "pag constructed, initializing AndersenCustom\n";
    Andersen::initialize();
    spblaCheck(spbla_Initialize(SPBLA_HINT_CUDA_BACKEND));
    setupMatrices();
    fillMatrices();
}

void AndersenCustom::solveWorklist()
{
    // /*
    cout << "running solve worklist\n";
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

    /*
    spbla_Index *rows, *cols, nvals;
    spbla_Matrix_Nvals(addr, &nvals);
    rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(addr, rows, cols, &nvals);

    for (size_t i = 0; i < nvals; i++)
        ptsMap[cols[i]].insert(rows[i]);
    free(rows);
    free(cols);

    spbla_Index addrEdgesBeforeGeps = get_nnz(addr);
    for (ConstraintEdge *directEdge : consCG->getDirectCGEdges())
        handleNormalGepEdge(directEdge);
    spbla_Index addrEdgesAfterGeps = get_nnz(addr);
    cout << (addrEdgesAfterGeps - addrEdgesBeforeGeps) << "\t" << addrEdgesBeforeGeps << " -> " << addrEdgesAfterGeps << endl;
    if (addrEdgesBeforeGeps != get_nnz(addr))
        reanalyze = true;
    */

    // */

    /* add copy edges to consg for visualization; remove later*/

    // spbla_Matrix_Nvals(copy, &nvals);
    // rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    // cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    // spbla_Matrix_ExtractPairs(copy, rows, cols, &nvals);

    // for (size_t i = 0; i < nvals; i++)
    // {
    //     addCopyEdge(rows[i], cols[i]);
    // }

    // print_matrix(addr, 0);

    /* */
}
