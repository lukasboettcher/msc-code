
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
    edgeSet addrEdges, directEdges, storeEdges, loadEdges;
    AndersenCustom(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : Andersen(_pag, type, alias_check) {}
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

        ConstraintEdge::ConstraintEdgeSetTy &addrs = consCG->getAddrCGEdges();
        for (ConstraintEdge *edge : addrs)
        {
            if (printEdges)
                std::cerr << "src: " << edge->getSrcID() << " dst: " << edge->getDstID() << "\t addr\n";
            addrEdges.first.push_back(edge->getSrcID());
            addrEdges.second.push_back(edge->getDstID());
        }

        ConstraintEdge::ConstraintEdgeSetTy &directs = consCG->getDirectCGEdges();
        for (ConstraintEdge *edge : directs)
        {
            if (CopyCGEdge *copy = SVFUtil::dyn_cast<CopyCGEdge>(edge))
            {
                if (printEdges)
                    std::cerr << "src: " << copy->getSrcID() << " dst: " << copy->getDstID() << "\t copy\n";
                directEdges.first.push_back(copy->getSrcID());
                directEdges.second.push_back(copy->getDstID());
            }
        }

        ConstraintEdge::ConstraintEdgeSetTy &loads = consCG->getLoadCGEdges();
        for (ConstraintEdge *edge : loads)
        {
            if (printEdges)
                std::cerr << "src: " << edge->getSrcID() << " dst: " << edge->getDstID() << "\t load\n";
            loadEdges.first.push_back(edge->getSrcID());
            loadEdges.second.push_back(edge->getDstID());
        }

        ConstraintEdge::ConstraintEdgeSetTy &stores = consCG->getStoreCGEdges();
        for (ConstraintEdge *edge : stores)
        {
            if (printEdges)
                std::cerr << "src: " << edge->getSrcID() << " dst: " << edge->getDstID() << "\t store\n";
            storeEdges.first.push_back(edge->getSrcID());
            storeEdges.second.push_back(edge->getDstID());
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
        pts = run(consCG->getTotalNodeNum(), &addrEdges, &directEdges, &loadEdges, &storeEdges, consCG, pag, [&](uint *memory, edgeSet *pts, edgeSet *copy) -> uint
                  { return handleCallgraphCallback(memory, pts, copy); });
    }

    uint handleCallgraphCallback(uint *memory, edgeSet *ptsSet, edgeSet *copySet)
    {
        pts = memory;
        tmpPts = ptsSet;
        tmpCopy = copySet;
        return consCG->getTotalNodeNum();
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
            collectFromBitvector(src, pts, srcPts);
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

    void collectFromBitvector(uint src, uint *memory, std::vector<uint> &pts)
    {
        uint index = getIndex(src, 0);
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
                        ptsTarget = 960 * base + 32 * j + k;
                        pts.push_back(ptsTarget);
                    }
                }
            }
            index = next;
        }
    }

    void fillPtsFromPTAGPU(PointsTo &ptsTarget, NodeID id)
    {
        if (pts)
        {
            NodeVector nv;
            collectFromBitvector(id, pts, nv);
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