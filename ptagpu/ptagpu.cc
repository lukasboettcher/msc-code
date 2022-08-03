// #include "SVF-FE/LLVMUtil.h"
// #include "Graphs/SVFG.h"
// #include "WPA/Andersen.h"
// #include "SVF-FE/SVFIRBuilder.h"
// #include "Util/Options.h"
// #include <tuple>
// // #include "common.cuh"
// int run(std::vector<std::tuple<uint, uint, uint, uint>> *edges);
// int main(int argc, char const *argv[])
// {
//     return run(0);
// }

#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include "shared.h"

using namespace llvm;
using namespace std;
using namespace SVF;

static llvm::cl::opt<std::string> InputFilename(cl::Positional, llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int main(int argc, char **argv)
{
    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    SVFUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value, "Whole Program Points-to Analysis\n");
    // moduleNameVec.push_back("../../bitcode-samples/bash.bc");

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);
    ConstraintGraph *cg = new ConstraintGraph(pag);

    edgeSet addrEdges;
    ConstraintEdge::ConstraintEdgeSetTy &addrs = cg->getAddrCGEdges();
    for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = addrs.begin(), eiter = addrs.end(); iter != eiter; ++iter)
    {
        addrEdges.first.first.push_back((*iter)->getSrcID());
        addrEdges.first.second.push_back(0);
        addrEdges.second.push_back((*iter)->getDstID());
    }

    ConstraintEdge::ConstraintEdgeSetTy &directs = cg->getDirectCGEdges();
    edgeSet directEdges;
    for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = directs.begin(), eiter = directs.end(); iter != eiter; ++iter)
    {
        if (CopyCGEdge *copy = SVFUtil::dyn_cast<CopyCGEdge>(*iter))
        {
            directEdges.first.first.push_back(copy->getSrcID());
            directEdges.first.second.push_back(0);
            directEdges.second.push_back(copy->getDstID());
        }
        else if (NormalGepCGEdge *ngep = SVFUtil::dyn_cast<NormalGepCGEdge>(*iter))
        {
            directEdges.first.first.push_back(ngep->getSrcID());
            directEdges.first.second.push_back(ngep->getConstantFieldIdx());
            directEdges.second.push_back(ngep->getDstID());
        }
        else if (VariantGepCGEdge *vgep = SVFUtil::dyn_cast<VariantGepCGEdge>(*iter))
        {
            directEdges.first.first.push_back(vgep->getSrcID());
            directEdges.first.second.push_back(0);
            directEdges.second.push_back(vgep->getDstID());
        }
    }

    ConstraintEdge::ConstraintEdgeSetTy &loads = cg->getLoadCGEdges();
    edgeSet loadEdges;
    for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = loads.begin(), eiter = loads.end(); iter != eiter; ++iter)
    {
        loadEdges.first.first.push_back((*iter)->getSrcID());
        loadEdges.first.second.push_back(0);
        loadEdges.second.push_back((*iter)->getDstID());
    }

    ConstraintEdge::ConstraintEdgeSetTy &stores = cg->getStoreCGEdges();
    edgeSet storeEdges;
    for (ConstraintEdge::ConstraintEdgeSetTy::iterator iter = stores.begin(), eiter = stores.end(); iter != eiter; ++iter)
    {
        storeEdges.first.first.push_back((*iter)->getSrcID());
        storeEdges.first.second.push_back(0);
        storeEdges.second.push_back((*iter)->getDstID());
    }

    std::cout << "starting ptagpu w/ " << cg->getTotalNodeNum() << " nodes and " << cg->getTotalEdgeNum() << " Edges!\n";
    run(cg->getTotalNodeNum(), &addrEdges, &directEdges, &loadEdges, &storeEdges);
    SVFIR::releaseSVFIR();

    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}