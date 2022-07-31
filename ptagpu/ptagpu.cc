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
#include <tuple>

using namespace llvm;
using namespace std;
using namespace SVF;

static llvm::cl::opt<std::string> InputFilename(cl::Positional, llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int run(std::vector<std::tuple<uint, uint, uint, uint>> *edges);

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

    SVFIR::releaseSVFIR();

    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}