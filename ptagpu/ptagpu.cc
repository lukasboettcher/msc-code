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
    std::vector<std::tuple<uint, uint, uint, uint>> edges;
    for (auto &entry : *cg)
        for (auto &x : entry.second->getOutEdges())
        {
            std::tuple<uint, uint, uint, uint> entry;
            if (const NormalGepCGEdge *gepedge = SVFUtil::dyn_cast<NormalGepCGEdge>(x))
                entry = make_tuple(gepedge->getSrcID(), gepedge->getDstID(), gepedge->getEdgeKind(), gepedge->getConstantFieldIdx());
            else
                entry = make_tuple(x->getSrcID(), x->getDstID(), x->getEdgeKind(), 0);
            edges.push_back(entry);
        }

    std::cout << "starting ptagpu w/ " << cg->getTotalNodeNum() << " nodes and " << cg->getTotalEdgeNum() << " Edges!\n";
    run(cg->getTotalNodeNum(), &edges);
    
    SVFIR::releaseSVFIR();

    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}