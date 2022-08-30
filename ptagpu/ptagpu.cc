
#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include "shared.h"

using namespace llvm;
using namespace std;
using namespace SVF;

class AndersenCustom : public Andersen
{
public:
    uint *pts = nullptr;
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
        pts = run(consCG->getTotalNodeNum(), &addrEdges, &directEdges, &loadEdges, &storeEdges, consCG, pag);
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