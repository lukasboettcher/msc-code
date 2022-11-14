
#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include "shared.h"

using namespace llvm;
using namespace std;
using namespace SVF;
using namespace SVFUtil;
using namespace cppUtil;

class AndersenCustom : public Andersen
{
public:
    uint *pts = nullptr;
    edgeSet *tmpPts;
    edgeSet *tmpCopy;
    bool printEdges = false;
    bool deepGepResolution = false;
    edgeSet addrEdges, directEdges, storeEdges, loadEdges;

    std::chrono::high_resolution_clock::time_point before, after;
    std::chrono::duration<double, std::milli> gepTime, indTime;

    AndersenCustom(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : Andersen(_pag, type, alias_check)
    {
        gepTime = std::chrono::nanoseconds(0);
        indTime = std::chrono::nanoseconds(0);
    }
    SVF::AliasResult alias(NodeID node1, NodeID node2)
    {
        if (!pts)
        {
            return AndersenBase::alias(node1, node2);
        }

        if (aliasBV(node1, node2, pts))
        {
            return SVF::AliasResult::MayAlias;
        }
        return SVF::AliasResult::NoAlias;
    }

    void initEdgeSets()
    {
        if (printEdges)
        {
            fprintf(stderr, "%u %lu %lu %lu %lu\n", consCG->getTotalNodeNum(), consCG->getAddrCGEdges().size(), consCG->getDirectCGEdges().size(), consCG->getLoadCGEdges().size(), consCG->getStoreCGEdges().size());
        }

        SVF::NodeID src, dst;

        ConstraintEdge::ConstraintEdgeSetTy &addrs = consCG->getAddrCGEdges();
        for (ConstraintEdge *edge : addrs)
        {
            src = edge->getSrcID();
            dst = edge->getDstID();
            if (printEdges)
                std::cerr << "src: " << src << " dst: " << dst << "\t addr\n";
            addrEdges.first.push_back(src);
            addrEdges.second.push_back(dst);
        }

        ConstraintEdge::ConstraintEdgeSetTy &directs = consCG->getDirectCGEdges();
        for (ConstraintEdge *edge : directs)
        {
            if (CopyCGEdge *copy = SVFUtil::dyn_cast<CopyCGEdge>(edge))
            {
                src = copy->getSrcID();
                dst = copy->getDstID();
                if (printEdges)
                    std::cerr << "src: " << src << " dst: " << dst << "\t copy\n";
                directEdges.first.push_back(src);
                directEdges.second.push_back(dst);
            }
        }

        ConstraintEdge::ConstraintEdgeSetTy &loads = consCG->getLoadCGEdges();
        for (ConstraintEdge *edge : loads)
        {
            src = edge->getSrcID();
            dst = edge->getDstID();
            if (printEdges)
                std::cerr << "src: " << src << " dst: " << dst << "\t load\n";
            loadEdges.first.push_back(src);
            loadEdges.second.push_back(dst);
        }

        ConstraintEdge::ConstraintEdgeSetTy &stores = consCG->getStoreCGEdges();
        for (ConstraintEdge *edge : stores)
        {
            src = edge->getSrcID();
            dst = edge->getDstID();
            if (printEdges)
                std::cerr << "src: " << src << " dst: " << dst << "\t store\n";
            storeEdges.first.push_back(src);
            storeEdges.second.push_back(dst);
        }
    }

    void printObjs()
    {
        GTraits::nodes_iterator I = GTraits::nodes_begin(consCG);
        GTraits::nodes_iterator E = GTraits::nodes_end(consCG);
        for (; I != E; ++I)
        {
            NodeID nodeId = GTraits::getNodeID(*I);
            SVFVar *node = pag->getGNode(nodeId);
            if (SVFUtil::isa<ObjVar>(node))
            {
                if (!pag->isConstantObj(nodeId) && !pag->isNonPointerObj(nodeId))
                {
                    std::cout << nodeId << "\n";
                }
            }
        }
    }

    void analyze()
    {
        initialize();
        initWorklist();
        initEdgeSets();
        do
        {
            reanalyze = false;
            solveWorklist();
            if (updateCallGraph(getIndirectCallsites()))
                reanalyze = true;
        } while (reanalyze);
        finalize();
    }

    virtual inline void solveWorklist()
    {
        std::cout << "starting ptagpu w/ " << consCG->getTotalNodeNum() << " nodes and " << consCG->getTotalEdgeNum() << " Edges!\n";
        pts = run(consCG->getTotalNodeNum(), &addrEdges, &directEdges, &loadEdges, &storeEdges, [&](uint *memory, edgeSet *pts, edgeSet *copy) -> uint
                  { return handleCallgraphCallback(memory, pts, copy); });
        std::cout << "SVF gep time: " << gepTime.count() << "ms" << std::endl;
        std::cout << "SVF ind time: " << indTime.count() << "ms" << std::endl;
    }

    uint handleCallgraphCallback(uint *memory, edgeSet *ptsSet, edgeSet *copySet)
    {
        pts = memory;
        tmpPts = ptsSet;
        tmpCopy = copySet;

        before = std::chrono::high_resolution_clock::now();
        handleGeps();
        after = std::chrono::high_resolution_clock::now();
        gepTime += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);
        printf("  geps done  ");

        before = std::chrono::high_resolution_clock::now();
        updateCallGraph(getIndirectCallsites());
        after = std::chrono::high_resolution_clock::now();
        indTime += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);
        printf("  indcall done  ");

        return consCG->getTotalNodeNum();
    }

    void handleGeps()
    {
        // set thread count to 16, depending on the system this might be improved
#pragma omp parallel for num_threads(16)
        for (size_t i = 0; i < consCG->getTotalNodeNum(); i++)
        {
            // SVF::ConstraintNode *node = iter.second;
            SVF::ConstraintNode *node = consCG->getGNode(i);
            for (ConstraintEdge *uedge : node->getGepOutEdges())
            {
                if (GepCGEdge *edge = SVFUtil::dyn_cast<GepCGEdge>(uedge))
                {
                    NodeVector tmpSrcPts;
                    collectFromBitvector(edge->getSrcID(), pts, tmpSrcPts, PTS_CURR);
                    // PointsTo tmpDstPts;
                    NodeVector tmpDstPts;
                    if (SVFUtil::isa<VariantGepCGEdge>(edge))
                    {
                        // If a pointer is connected by a variant gep edge,
                        // then set this memory object to be field insensitive,
                        // unless the object is a black hole/constant.
                        for (NodeID o : tmpSrcPts)
                        {
                            if (!SVF::SVFUtil::isa<SVF::ObjVar>(pag->getGNode(o)))
                                continue;

                            if (consCG->isBlkObjOrConstantObj(o))
                            {
                                tmpDstPts.push_back(o);
                                continue;
                            }

                            if (!pag->getBaseObj(o)->isFieldInsensitive())
                            {
                                MemObj *mem = const_cast<MemObj *>(pag->getBaseObj(o));
#pragma omp critical
                                mem->setFieldInsensitive();
                                // consCG->addNodeToBeCollapsed(consCG->getBaseObjVar(o));
                            }

                            // Add the field-insensitive node into pts.
                            NodeID baseId = consCG->getFIObjVar(o);
                            if (deepGepResolution)
                            {
                                NodeBS &allFields = consCG->getAllFieldsObjVars(baseId);
                                for (NodeBS::iterator fieldIt = allFields.begin(), fieldEit = allFields.end(); fieldIt != fieldEit; fieldIt++)
                                {
                                    NodeID fieldId = *fieldIt;
                                    if (fieldId != baseId)
                                        tmpDstPts.push_back(fieldId);
                                }
                            }
                            tmpDstPts.push_back(baseId);
                        }
                    }
                    else if (const NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(edge))
                    {
                        // TODO: after the node is set to field insensitive, handling invariant
                        // gep edge may lose precision because offsets here are ignored, and the
                        // base object is always returned.
                        for (NodeID o : tmpSrcPts)
                        {
                            if (!SVF::SVFUtil::isa<SVF::ObjVar>(pag->getGNode(o)))
                                continue;

                            if (consCG->isBlkObjOrConstantObj(o) || pag->getBaseObj(o)->isFieldInsensitive())
                            {
                                tmpDstPts.push_back(o);
                                continue;
                            }
                            NodeID fieldSrcPtdNode;
#pragma omp critical
                            fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
                            tmpDstPts.push_back(fieldSrcPtdNode);
                        }
                    }
                    else
                    {
                        assert(false && "Andersen::processGepPts: New type GEP edge type?");
                    }

                    NodeID dstId = edge->getDstID();
#pragma omp critical
                    for (auto ptd : tmpDstPts)
                    {
                        addPts(dstId, ptd);
                    }
                }
            }
        }
    }

    virtual inline void pushIntoWorklist(NodeID id)
    {
        if (!pts)
        {
            return Andersen::pushIntoWorklist(id);
        }
    }

    virtual inline bool addCopyEdge(NodeID src, NodeID dst)
    {
        if (pts)
        {
            tmpCopy->first.push_back(src);
            tmpCopy->second.push_back(dst);

            std::vector<uint> srcPts;
            collectFromBitvector(src, pts, srcPts, PTS);
            for (auto ptd : srcPts)
            {
                addPts(dst, ptd);
            }
        }
        else
            return Andersen::addCopyEdge(src, dst);
        return false;
    }

    virtual inline bool addPts(NodeID id, NodeID ptd)
    {
        if (pts)
        {
            tmpPts->first.push_back(id);
            tmpPts->second.push_back(ptd);
        }
        else
            return getPTDataTy()->addPts(id, ptd);
        return false;
    }

    void fillPtsFromPTAGPU(PointsTo &ptsTarget, NodeID id)
    {
        if (pts)
        {
            NodeVector nv;
            collectFromBitvector(id, pts, nv, PTS);
            for (auto i : nv)
                ptsTarget.set(i);
        }
        else
        {
            const PointsTo &svfPts = getPTDataTy()->getPts(id);
            ptsTarget = svfPts;
        }
    }

    void onTheFlyCallGraphSolve(const CallSiteToFunPtrMap &callsites, CallEdgeMap &newEdges)
    {
        for (CallSiteToFunPtrMap::const_iterator iter = callsites.begin(), eiter = callsites.end(); iter != eiter; ++iter)
        {
            const CallICFGNode *cs = iter->first;
            PointsTo ptsTarget;
            if (cppUtil::isVirtualCallSite(SVFUtil::getLLVMCallSite(cs->getCallSite())))
            {
                const Value *vtbl = cppUtil::getVCallVtblPtr(SVFUtil::getLLVMCallSite(cs->getCallSite()));
                assert(pag->hasValueNode(vtbl));
                NodeID vtblId = pag->getValueNode(vtbl);
                fillPtsFromPTAGPU(ptsTarget, vtblId);
                resolveCPPIndCalls(cs, ptsTarget, newEdges);
            }
            else
            {
                fillPtsFromPTAGPU(ptsTarget, iter->second);
                resolveIndCalls(iter->first, ptsTarget, newEdges);
            }
        }
    }
};

static llvm::cl::opt<std::string> InputFilename(cl::Positional, llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int main(int argc, char **argv)
{
    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    LLVMUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value, "Whole Program Points-to Analysis\n");
    // moduleNameVec.push_back("../../bitcode-samples/bash.bc");

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);

    AndersenCustom *ander = new AndersenCustom(pag);

    ander->analyze();

    SVFIR::releaseSVFIR();

    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}