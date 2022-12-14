/*
this program calculates stats for each bitcode sample

for i in bitcode-samples/* ;do build/ptagpu/ptagpu_stats $i;done
columns: filename, node count, edge count, filesize, density, avg out degree

*/
#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
namespace fs = std::filesystem;

using namespace llvm;
using namespace std;
using namespace SVF;

static llvm::cl::opt<std::string> InputFilename(llvm::cl::Positional,
                                                llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int main(int argc, char **argv)
{

    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    LLVMUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value,
                                "Whole Program Points-to Analysis\n");

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);
    ConstraintGraph *consCG = new ConstraintGraph(pag);

    uint edgeCounter{0};
    ConstraintEdge::ConstraintEdgeSetTy &addrs = consCG->getAddrCGEdges();
    for (ConstraintEdge *edge : addrs)
    {
        edgeCounter++;
    }

    ConstraintEdge::ConstraintEdgeSetTy &directs = consCG->getDirectCGEdges();
    for (ConstraintEdge *edge : directs)
    {
        edgeCounter++;
        if (CopyCGEdge *copy = SVFUtil::dyn_cast<CopyCGEdge>(edge))
        {
        }
        else if (GepCGEdge *gep = SVFUtil::dyn_cast<GepCGEdge>(edge))
        {
            if (NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(gep))
            {
            }
            else if (VariantGepCGEdge *variantGepEdge = SVFUtil::dyn_cast<VariantGepCGEdge>(gep))
            {
            }
        }
    }

    ConstraintEdge::ConstraintEdgeSetTy &loads = consCG->getLoadCGEdges();
    for (ConstraintEdge *edge : loads)
    {
        edgeCounter++;
    }

    ConstraintEdge::ConstraintEdgeSetTy &stores = consCG->getStoreCGEdges();
    for (ConstraintEdge *edge : stores)
    {
        edgeCounter++;
    }

    size_t degreeSum{0};

    for (size_t i = 0; i < consCG->getTotalNodeNum(); i++)
    {
        SVF::ConstraintNode *node = consCG->getGNode(i);
        degreeSum += node->getOutEdges().size();
    }

    double avgOutDegree = (double)degreeSum / (double)consCG->getTotalNodeNum();
    double density = (double)edgeCounter / (double)(consCG->getTotalNodeNum() * (consCG->getTotalNodeNum() - 1));

    printf("%s\t\t%u K\t%u K\t%lu KiB\t%.3e\t%.3f\n", moduleNameVec[0].c_str(), consCG->getTotalNodeNum()/1000, edgeCounter/1000, fs::file_size(moduleNameVec[0]) / 1024, density, avgOutDegree);

    delete consCG;
    SVFIR::releaseSVFIR();
    SVF::LLVMModuleSet::releaseLLVMModuleSet();
    llvm::llvm_shutdown();
    return 0;
}
