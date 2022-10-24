#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"

using namespace llvm;
using namespace std;
using namespace SVF;

static llvm::cl::opt<std::string> InputFilename(cl::Positional,
                                                llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int main(int argc, char **argv)
{

    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    LLVMUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value,
                                "Whole Program Points-to Analysis\n");

    if (Options::WriteAnder == "ir_annotator")
    {
        LLVMModuleSet::getLLVMModuleSet()->preProcessBCs(moduleNameVec);
    }

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);

    /// Create Andersen's pointer analysis
    Andersen *ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

    ConstraintGraph *cg = ander->getConstraintGraph();
    PTACallGraph *callgraph = ander->getPTACallGraph();

    ICFG *icfg = pag->getICFG();

    ofstream pagdump("pag-dump.txt", ios::trunc);
    ofstream icfgdump("icfg-dump.txt", ios::trunc);
    ofstream constrdump("cg-dump.txt", ios::trunc);
    ofstream calldump("call-dump.txt", ios::trunc);

    for (auto node : *pag)
        for (auto outedge : node.second->getOutEdges())
            pagdump << outedge->getSrcID() << "\t" << outedge->getDstID() << "\t" << outedge->getEdgeKind() << "\n";
    for (auto node : *icfg)
        for (auto outedge : node.second->getOutEdges())
            icfgdump << outedge->getSrcID() << "\t" << outedge->getDstID() << "\t" << outedge->getEdgeKind() << "\n";

    for (auto node : *cg)
        for (auto outedge : node.second->getOutEdges())
            if (const NormalGepCGEdge *edge = SVFUtil::dyn_cast<NormalGepCGEdge>(outedge))
                constrdump << edge->getSrcID() << "\t" << edge->getDstID() << "\t" << edge->getEdgeKind() << "\t" << edge->getConstantFieldIdx() << "\n";
            else
                constrdump << outedge->getSrcID() << "\t" << outedge->getDstID() << "\t" << outedge->getEdgeKind() << "\n";

    for (auto node : *callgraph)
        for (auto outedge : node.second->getOutEdges())
            calldump << outedge->getSrcID() << "\t" << outedge->getDstID() << "\t" << outedge->getEdgeKind() << "\n";

    OrderedNodeSet pagNodes;
    for (SVFIR::iterator it = pag->begin(), eit = pag->end(); it != eit; it++)
    {
        pagNodes.insert(it->first);
    }

    for (NodeID n : pagNodes)
    {
        const SVF::PointsTo &pts = ander->getPts(n);
        if (true)
        {
            printf("\n %u -> [", n);
            for (PointsTo::iterator it = pts.begin(); it != pts.end(); ++it)
                printf("%u ", *it);
            printf("]");
        }
    }

    pagdump.close();
    icfgdump.close();
    constrdump.close();
    calldump.close();

    AndersenWaveDiff::releaseAndersenWaveDiff();
    SVFIR::releaseSVFIR();

    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}
