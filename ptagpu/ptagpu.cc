
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
        ConstraintEdge::ConstraintEdgeSetTy &addrs = consCG->getAddrCGEdges();
        for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = addrs.begin(), eiter = addrs.end(); iter != eiter; ++iter)
        {
            std::cout << "src: " << (*iter)->getSrcID() << " dst: " << (*iter)->getDstID() << "\t addr\n";
            addrEdges.first.push_back((*iter)->getSrcID());
            addrEdges.second.push_back((*iter)->getDstID());
        }

        ConstraintEdge::ConstraintEdgeSetTy &directs = consCG->getDirectCGEdges();
        for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = directs.begin(), eiter = directs.end(); iter != eiter; ++iter)
        {
            std::cout << "src: " << (*iter)->getSrcID() << " dst: " << (*iter)->getDstID() << "\t copy\n";
            if (CopyCGEdge *copy = SVFUtil::dyn_cast<CopyCGEdge>(*iter))
            {
                directEdges.first.push_back(copy->getSrcID());
                directEdges.second.push_back(copy->getDstID());
            }
        }

        ConstraintEdge::ConstraintEdgeSetTy &loads = consCG->getLoadCGEdges();
        for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = loads.begin(), eiter = loads.end(); iter != eiter; ++iter)
        {
            std::cout << "src: " << (*iter)->getSrcID() << " dst: " << (*iter)->getDstID() << "\t load\n";
            loadEdges.first.push_back((*iter)->getSrcID());
            loadEdges.second.push_back((*iter)->getDstID());
        }

        ConstraintEdge::ConstraintEdgeSetTy &stores = consCG->getStoreCGEdges();
        for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = stores.begin(), eiter = stores.end(); iter != eiter; ++iter)
        {
            std::cout << "src: " << (*iter)->getSrcID() << " dst: " << (*iter)->getDstID() << "\t store\n";
            storeEdges.first.push_back((*iter)->getSrcID());
            storeEdges.second.push_back((*iter)->getDstID());
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