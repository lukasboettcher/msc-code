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

/*!
 * An example to query alias results of two LLVM values
 */
SVF::AliasResult aliasQuery(PointerAnalysis *pta, Value *v1, Value *v2)
{
    return pta->alias(v1, v2);
}

/*!
 * An example to print points-to set of an LLVM value
 */
std::string printPts(PointerAnalysis *pta, Value *val)
{

    std::string str;
    raw_string_ostream rawstr(str);

    NodeID pNodeId = pta->getPAG()->getValueNode(val);
    const PointsTo &pts = pta->getPts(pNodeId);
    for (PointsTo::iterator ii = pts.begin(), ie = pts.end();
         ii != ie; ii++)
    {
        rawstr << " " << *ii << " ";
        PAGNode *targetObj = pta->getPAG()->getGNode(*ii);
        if (targetObj->hasValue())
        {
            rawstr << "(" << *targetObj->getValue() << ")\t ";
        }
    }

    return rawstr.str();
}

/*!
 * An example to query/collect all successor nodes from a ICFGNode (iNode) along control-flow graph (ICFG)
 */
void traverseOnICFG(ICFG *icfg, const Instruction *inst)
{
    ICFGNode *iNode = icfg->getICFGNode(inst);
    FIFOWorkList<const ICFGNode *> worklist;
    Set<const ICFGNode *> visited;
    worklist.push(iNode);

    /// Traverse along VFG
    while (!worklist.empty())
    {
        const ICFGNode *vNode = worklist.pop();
        for (ICFGNode::const_iterator it = vNode->OutEdgeBegin(), eit =
                                                                      vNode->OutEdgeEnd();
             it != eit; ++it)
        {
            ICFGEdge *edge = *it;
            ICFGNode *succNode = edge->getDstNode();
            if (visited.find(succNode) == visited.end())
            {
                visited.insert(succNode);
                worklist.push(succNode);
            }
        }
    }
}

/*!
 * An example to query/collect all the uses of a definition of a value along value-flow graph (VFG)
 */
void traverseOnVFG(const SVFG *vfg, const Value *val, Set<const VFGNode *> &visited)
{
    SVFIR *pag = SVFIR::getPAG();

    PAGNode *pNode = pag->getGNode(pag->getValueNode(val));
    const VFGNode *vNode = vfg->getDefSVFGNode(pNode);
    FIFOWorkList<const VFGNode *> worklist;
    // Set<const VFGNode *> visited;
    worklist.push(vNode);

    /// Traverse along VFG
    while (!worklist.empty())
    {
        const VFGNode *vNode = worklist.pop();
        for (VFGNode::const_iterator it = vNode->OutEdgeBegin(), eit =
                                                                     vNode->OutEdgeEnd();
             it != eit; ++it)
        {
            VFGEdge *edge = *it;
            VFGNode *succNode = edge->getDstNode();
            if (visited.find(succNode) == visited.end())
            {
                visited.insert(succNode);
                worklist.push(succNode);
            }
        }
    }
    /*
    /// Collect all LLVM Values
    for (Set<const VFGNode *>::const_iterator it = visited.begin(), eit = visited.end(); it != eit; ++it)
    {
        const VFGNode* node = *it;
        /// can only query VFGNode involving top-level pointers (starting with % or @ in LLVM IR)
        /// PAGNode* pNode = vfg->getLHSTopLevPtr(node);
        /// Value* val = pNode->getValue();
        const PAGNode* pNode = vfg->getLHSTopLevPtr(node);
        const Value* val = pNode->getValue();
        auto icfg_node = node->getICFGNode();
    }
    */
}

int main(int argc, char **argv)
{

    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    // system("clang-13 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm {clang_in} -o {clang_out}");
    SVFUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value,
                                "Whole Program Points-to Analysis\n");

    if (Options::WriteAnder == "ir_annotator")
    {
        LLVMModuleSet::getLLVMModuleSet()->preProcessBCs(moduleNameVec);
    }

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    // building PAG and ICFG and CG
    cout << "\tbuilding PAG\n";
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);
    ICFG *icfg = pag->getICFG();
    ConstraintGraph *cg = new ConstraintGraph(pag);

    cout << "running Andersen Analysis\n";
    /// Create Andersen's pointer analysis
    Andersen *ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

    /// Query aliases
    /// aliasQuery(ander,value1,value2);

    /// Print points-to information
    /// printPts(ander, value1);

    /// Call Graph
    PTACallGraph *callgraph = ander->getPTACallGraph();

    SVFGBuilder svfBuilder(true);
    SVFG *svfg = svfBuilder.buildFullSVFG(ander);

    set<const Value *> alloc_values;
    /// ICFG
    cout << "printing alloc funs\n";
    for (auto ret : pag->getCallSiteRets())
    {
        const RetICFGNode *cs = ret.first;

        PTACallGraph::FunctionSet callees;
        callgraph->getCallees(cs->getCallICFGNode(), callees);
        for (auto &fun : callees)
        {
            auto fn_name = fun->getName();
            // cout << fun->getName() << endl;
            if (fn_name.find("alloc") != std::string::npos)
            {
                std::cout << fn_name << '\n';
                auto x = ret.second->getValue();
                alloc_values.insert(x);
            }
        }
    }

    for (auto &val : alloc_values)
    {
        Set<const VFGNode *> visited;
        traverseOnVFG(svfg, val, visited);
        
    }
    

    /// Value-Flow Graph (VFG)
    // VFG* vfg = new VFG(callgraph);

    /// Sparse value-flow graph (SVFG)
    // SVFGBuilder svfBuilder(true);
    // SVFG* svfg = svfBuilder.buildFullSVFG(ander);

    /// Collect uses of an LLVM Value
    /// traverseOnVFG(svfg, value);

    /// Collect all successor nodes on ICFG
    /// traverseOnICFG(icfg, value);

    // clean up memory
    // delete vfg;
    delete svfg;
    AndersenWaveDiff::releaseAndersenWaveDiff();
    SVFIR::releaseSVFIR();

    LLVMModuleSet::getLLVMModuleSet()->dumpModulesToFile(".svf.bc");
    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}
