#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include "MemoryModel/PointerAnalysisImpl.h"
#include "DDA/DDAClient.h"
#include "Util/SCC.h"
#include "DDA/DDAPass.h"
#include "DDA/ContextDDA.h"

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

void write_edge(ofstream &edge_stream, unsigned src, unsigned dst, unsigned type, unsigned offset)
{
    if (offset)
    {
        edge_stream << src << "_" << offset << "\t" << dst << "\t" << type << endl;
        edge_stream << dst << "\t" << src << "_" << offset << "\t"
                    << "-" << type << endl;
    }
    else
    {
        edge_stream << src << "\t" << dst << "\t" << type << endl;
        edge_stream << dst << "\t" << src << "\t"
                    << "-" << type << endl;
    }
}

void printQueryPTS(DDAClient *_client, PointerAnalysis *_pta)
{
    const OrderedNodeSet &candidates = _client->getCandidateQueries();
    for (OrderedNodeSet::const_iterator it = candidates.begin(), eit = candidates.end(); it != eit; ++it)
    {
        const PointsTo &pts = _pta->getPts(*it);
        _pta->dumpPts(*it, pts);
    }
}

class TestDDAClient : public DDAClient
{

public:
    typedef OrderedSet<const PAGNode *> PAGNodeSet;

    TestDDAClient(SVFModule *module) : DDAClient(module) {}
    ~TestDDAClient() {}

    virtual OrderedNodeSet &collectCandidateQueries(SVFIR *pag);

    virtual inline void performStat(PointerAnalysis *pta) {}

private:
    typedef OrderedMap<NodeID, const CallICFGNode *> VTablePtrToCallSiteMap;
    VTablePtrToCallSiteMap vtableToCallSiteMap;
    PAGNodeSet loadSrcNodes;
    PAGNodeSet storeDstNodes;
    PAGNodeSet gepSrcNodes;
};

OrderedNodeSet &TestDDAClient::collectCandidateQueries(SVFIR *pag)
{
    setPAG(pag);

    // SVFStmt::SVFStmtSetTy& loads = pag->getSVFStmtSet(SVFStmt::Load);
    // for (SVFStmt::SVFStmtSetTy::iterator iter = loads.begin(), eiter =
    //             loads.end(); iter != eiter; ++iter)
    // {
    //     PAGNode* loadsrc = (*iter)->getSrcNode();
    //     // loadSrcNodes.insert(loadsrc);
    //     addCandidate(loadsrc->getId());
    // }

    SVF::SVFIR::CallSiteSet s = pag->getCallSiteSet();

    for (auto &call : s)
    {
        cout << " {fun: " << call->getFun()->getName() << "}" << endl;
        // TODO, check if params get used w/o check (nullptrs)
        auto params = call->getActualParms();
        for (auto &param : params)
        {
            addCandidate(param->getId());
            cout << "\t" << param->toString() << " :  " << param->getId() << endl;
        }
    }

    // SVFStmt::SVFStmtSetTy& loads = pag->getSVFStmtSet(SVFStmt::Load);
    // for (SVFStmt::SVFStmtSetTy::iterator iter = loads.begin(), eiter =
    //             loads.end(); iter != eiter; ++iter)
    // {
    //     PAGNode* loadsrc = (*iter)->getSrcNode();
    //     // loadSrcNodes.insert(loadsrc);
    //     addCandidate(loadsrc->getId());
    // }

    // SVFStmt::SVFStmtSetTy& stores = pag->getSVFStmtSet(SVFStmt::Store);
    // for (SVFStmt::SVFStmtSetTy::iterator iter = stores.begin(), eiter =
    //             stores.end(); iter != eiter; ++iter)
    // {
    //     PAGNode* storedst = (*iter)->getDstNode();
    //     // storeDstNodes.insert(storedst);
    //     addCandidate(storedst->getId());
    // }
    // SVFStmt::SVFStmtSetTy& geps = pag->getSVFStmtSet(SVFStmt::Gep);
    // for (SVFStmt::SVFStmtSetTy::iterator iter = geps.begin(), eiter =
    //             geps.end(); iter != eiter; ++iter)
    // {
    //     PAGNode* gepsrc = (*iter)->getSrcNode();
    //     // gepSrcNodes.insert(gepsrc);
    //     addCandidate(gepsrc->getId());
    // }
    return candidateQueries;
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
    // pag->dump("pag");

    cout << "\tcreating demand driven pta client\n";
    DDAClient *_client;
    // _client = new DDAClient(svfModule);
    // NodeID q = 17;
    // _client->setQuery(q);
    // q = 28;
    // _client->setQuery(q);

    _client = new TestDDAClient(svfModule);
    _client->initialise(svfModule);

    cout << "\tcreating demand driven pointer analysis\n";
    PointerAnalysis *_pta;
    _pta = new ContextDDA(pag, _client);

    _pta->initialize();
    cout << "\tanswering demand driven pointer queries\n";
    _client->answerQueries(_pta);
    _pta->finalize();

    const OrderedNodeSet &candidates = _client->getCandidateQueries();
    for (OrderedNodeSet::const_iterator it = candidates.begin(), eit = candidates.end(); it != eit; ++it)
    {
        const PointsTo &pts = _pta->getPts(*it);
        // TODO: implement nullptr check here
        if (pts.empty())
            cout << "WARNING\t" << *it << " has no target, dangling ptr" << endl;
        for (PointsTo::iterator it = pts.begin(), eit = pts.end(); it != eit; ++it)
            if (pag->isNullPtr(*it))
                cout << "WARNING\t" << *it << " is a nullptr" << endl; // placeholder
    }

    // _client->performStat(_pta);
    // printQueryPTS(_client, _pta);

    return 0;

    // dumping CG
    ofstream edge_stream;
    edge_stream.open("edges.txt");

    for (auto &entry : *cg)
        for (auto &x : entry.second->getOutEdges())
        {
            if (NormalGepCGEdge *normalGep = SVFUtil::dyn_cast<NormalGepCGEdge>(x))
                write_edge(edge_stream, x->getSrcID(), x->getDstID(), x->getEdgeKind(), normalGep->getConstantFieldIdx());
            else
                write_edge(edge_stream, x->getSrcID(), x->getDstID(), x->getEdgeKind(), 0);
        }

    cout << "\trunning Andersen Analysis\n";
    Andersen *ander = AndersenWaveDiff::createAndersenWaveDiff(pag);
    PTACallGraph *callgraph = ander->getPTACallGraph();

    set<const SVF::SVFVar *> alloc_values;
    set<const SVF::SVFVar *> free_values;

    cout << "\tfinding alloc return vals\n";
    for (auto ret : pag->getCallSiteRets())
    {
        const RetICFGNode *cs = ret.first;
        PTACallGraph::FunctionSet callees;
        callgraph->getCallees(cs->getCallICFGNode(), callees);
        for (auto &fun : callees)
        {
            auto fn_name = fun->getName();
            if (fn_name.find("alloc") != std::string::npos)
            {
                std::cout << fn_name << "\t with id: " << ret.second->getId() << '\n';
                // auto value = ret.second->getValue();
                alloc_values.insert(ret.second);
            }
        }
    }

    cout << "\tfinding free arg vals\n";
    for (auto arg : pag->getCallSiteArgsMap())
    {
        PTACallGraph::FunctionSet callees;
        callgraph->getCallees(arg.first, callees);
        for (auto &fun : callees)
        {
            auto fn_name = fun->getName();
            if (fn_name.find("free") != std::string::npos)
            {
                for (auto &fvar : arg.second)
                {
                    std::cout << fn_name << "\t with id: " << fvar->getId() << '\n';
                    // auto value = fvar->getValue();
                    free_values.insert(fvar);
                }
            }
        }
    }

    for (auto &var : alloc_values)
        edge_stream << var->getId() << "\t" << var->getId() << "\tm\n";
    for (auto &var : free_values)
        edge_stream << var->getId() << "\t" << var->getId() << "\tf\n";

    // SVFGBuilder svfBuilder(true);
    // SVFG *svfg = svfBuilder.buildFullSVFG(ander);

    // for (auto &val : alloc_values)
    // {
    //     Set<const VFGNode *> visited;
    //     traverseOnVFG(svfg, val, visited);
    // }

    // delete svfg;
    AndersenWaveDiff::releaseAndersenWaveDiff();
    SVFIR::releaseSVFIR();

    // LLVMModuleSet::getLLVMModuleSet()->dumpModulesToFile(".svf.bc");
    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    llvm::llvm_shutdown();
    return 0;
}
