#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include "Graphs/CHG.h"
#include "SVF-FE/LLVMUtil.h"
#include "MemoryModel/PointsTo.h"
#include "WPA/Andersen.h"
#include "WPA/Steensgaard.h"

#include "Graphs/IRGraph.h"

#include <mmxcflr.h>

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

// // statement types Addr, Copy, Store, Load, Call, Ret, Gep, Phi, Select, Cmp, BinaryOp, UnaryOp, Branch, ThreadFork, ThreadJoin

std::string getStmtStr(SVF::GenericEdge<SVF::SVFVar>::GEdgeKind type)
{
    switch (type)
    {
    case SVFStmt::Addr:
        return "Addr";
    case SVFStmt::Copy:
        return "Copy";
    case SVFStmt::Store:
        return "Store";
    case SVFStmt::Load:
        return "Load";
    case SVFStmt::Call:
        return "Call";
    case SVFStmt::Ret:
        return "Ret";
    case SVFStmt::Gep:
        return "Gep";
    case SVFStmt::Phi:
        return "Phi";
    case SVFStmt::Select:
        return "Select";
    case SVFStmt::Cmp:
        return "Cmp";
    case SVFStmt::BinaryOp:
        return "BinaryOp";
    case SVFStmt::UnaryOp:
        return "UnaryOp";
    case SVFStmt::Branch:
        return "Branch";
    case SVFStmt::ThreadFork:
        return "ThreadFork";
    case SVFStmt::ThreadJoin:
        return "ThreadJoin";
    default:
        return "invalid";
    }
}

void storeEdge(size_t &node_ctr, Edges &edges, NodeID src, NodeID dst, s64_t type)
{
    auto adjForType = edges[to_string(type)];
    adjForType.first.push_back((spbla_Index)src);
    adjForType.second.push_back((spbla_Index)dst);
    node_ctr++;
};

void validateSuccessTests(std::string fun, SVFIR *pag, ofstream &test_stream)
{
    // check for must alias cases, whether our alias analysis produce the correct results
    if (const SVFFunction *checkFun = SVFUtil::getFunction(fun))
    {
        if (!checkFun->getLLVMFun()->use_empty())
            outs() << "["
                   << "custom analysis"
                   << "] Checking " << fun << "\n";

        for (Value::user_iterator i = checkFun->getLLVMFun()->user_begin(), e =
                                                                                checkFun->getLLVMFun()->user_end();
             i != e; ++i)
            if (SVFUtil::isCallSite(*i))
            {

                CallSite cs(*i);
                assert(cs.getNumArgOperands() == 2 && "arguments should be two pointers!!");
                Value *V1 = cs.getArgOperand(0);
                Value *V2 = cs.getArgOperand(1);
                NodeID n1 = pag->getValueNode(V1);
                NodeID n2 = pag->getValueNode(V2);

                cout << n1 << "\t" << n2 << "\t" << fun << endl;
                test_stream << n1 << "\t" << n2 << "\t" << fun << endl;

                //     SVF::AliasResult aliasRes = AndersenBase::alias(V1, V2);

                //     bool checkSuccessful = false;
                //     if (fun == "MAYALIAS")
                //     {
                //         if (aliasRes == AliasResult::MayAlias || aliasRes == AliasResult::MustAlias)
                //             checkSuccessful = true;
                //     }
                //     else if (fun == "NOALIAS" )
                //     {
                //         if (aliasRes == AliasResult::NoAlias)
                //             checkSuccessful = true;
                //     }

                //     NodeID id1 = pag->getValueNode(V1);
                //     NodeID id2 = pag->getValueNode(V2);

                //     if (checkSuccessful)
                //         outs() << SVFUtil::sucMsg("\t SUCCESS :") << fun << " check <id:" << id1 << ", id:" << id2 << "> at ("
                //                << SVFUtil::getSourceLoc(*i) << ")\n";
                //     else
                //     {
                //         SVFUtil::errs() << SVFUtil::errMsg("\t FAILURE :") << fun
                //                         << " check <id:" << id1 << ", id:" << id2
                //                         << "> at (" << SVFUtil::getSourceLoc(*i) << ")\n";
                //         assert(false && "test case failed!");
                //     }
            }
            else
                assert(false && "alias check functions not only used at callsite??");
    }
}

bool processGepPts(size_t &node_ctr, Edges &edges, ofstream &edge_stream, ConstraintGraph *consCG, SVFIR *pag, set<NodeID> &pts, const GepCGEdge *edge)
{

    unordered_set<NodeID> gepNodes;
    if (SVFUtil::isa<VariantGepCGEdge>(edge))
    {
        // If a pointer is connected by a variant gep edge,
        // then set this memory object to be field insensitive,
        // unless the object is a black hole/constant.
        for (NodeID o : pts)
        {
            if (consCG->isBlkObjOrConstantObj(o))
            {
                gepNodes.insert(o);
                continue;
            }
            const MemObj *mem = pag->getBaseObj(o);
            if (!mem->isFieldInsensitive())
            {
                MemObj *mem = const_cast<MemObj *>(pag->getBaseObj(o));
                mem->setFieldInsensitive();
                consCG->addNodeToBeCollapsed(consCG->getBaseObjVar(o));
            }

            // Add the field-insensitive node into pts.
            NodeID baseId = consCG->getFIObjVar(o);
            gepNodes.insert(baseId);
            // add addr edge (inv pts edge)
        }
    }
    else if (const NormalGepCGEdge *normalGepEdge = SVFUtil::dyn_cast<NormalGepCGEdge>(edge))
    {
        // TODO: after the node is set to field insensitive, handling invariant
        // gep edge may lose precision because offsets here are ignored, and the
        // base object is always returned.
        for (NodeID o : pts)
        {
            if (consCG->isBlkObjOrConstantObj(o))
            {
                gepNodes.insert(o);
                continue;
            }

            // if (!matchType(edge->getSrcID(), o, normalGepEdge)) continue;

            NodeID fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
            gepNodes.insert(fieldSrcPtdNode);
            // add addr edge (inv pts edge)
            // cout << "\tfield id: " << fieldSrcPtdNode << endl;
            // addTypeForGepObjNode(fieldSrcPtdNode, normalGepEdge);
        }
    }
    // else
    // {
    //     assert(false && "Andersen::processGepPts: New type GEP edge type?");
    // }

    // NodeID dstId = edge->getDstID();
    // if (unionPts(dstId, tmpDstPts))
    // {
    //     pushIntoWorklist(dstId);
    //     return true;
    // }

    for (auto &node : gepNodes)
    {
        edge_stream << node << "\t" << edge->getDstID() << "\t" << 0 << endl;
        storeEdge(node_ctr, edges, node, edge->getDstID(), 0);
    }

    return true;
}

int main(int argc, char **argv)
{

    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    SVFUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    /*
    cl::ParseCommandLineOptions(arg_num, arg_value,
                                "Whole Program Points-to Analysis\n");

    if (Options::WriteAnder == "ir_annotator")
    {
        LLVMModuleSet::getLLVMModuleSet()->preProcessBCs(moduleNameVec);
    }
    */

    if (argc != 3)
    {
        cout << "./main <rules_path> <bitcode_paths> " << endl;
        return EXIT_FAILURE;
    }

    ifstream rules_f(argv[1]);

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);
    // pag->dump("graph-pag");

    // Addr, Copy, Store, Load, NormalGep, VariantGep
    ConstraintGraph *cg = new ConstraintGraph(pag);
    // cg->dump("graph-cg-init");

    // Andersen* ander = new Andersen(pag);
    // ander->analyze();
    // ander->dumpAllPts();

    ofstream edge_stream, meta_stream;
    edge_stream.open("edges.txt");
    meta_stream.open("meta.txt");

    AdjMatrix *ajm = (AdjMatrix *)malloc(sizeof(AdjMatrix));
    Edges edges;
    size_t node_cnt;

    meta_stream << "total nodes: " << pag->getPAGNodeNum() << "\ttotal edges: " << pag->getPAGEdgeNum() << endl;
    // cout << "total nodes: " << cg->getTotalNodeNum() << "\ttotal edges: " << cg->getTotalEdgeNum() << endl;

    for (auto &entry : *cg)
    {
        // push desc into meta.txt
        // meta_stream << pag->getGNode(entry.second->getId())->toString() << endl;
        // meta_stream << entry.second->toString() << endl;

        for (auto &x : entry.second->getOutEdges())
        {
            // push src dst typ into edges.txt

            if (const GepCGEdge *gepEdge = SVFUtil::dyn_cast<GepCGEdge>(x))
            {
                set<NodeID> pts;
                for (auto &addr_in : entry.second->getAddrInEdges())
                    pts.insert(addr_in->getSrcID());

                processGepPts(node_cnt, edges, edge_stream, cg, pag, pts, gepEdge);
            }
            else
            {
                edge_stream << x->getSrcID() << "\t" << x->getDstID() << "\t" << x->getEdgeKind() << endl;
                // edge_stream << x->getDstID() << "\t" << x->getSrcID() << "\t-" << x->getEdgeKind() << endl;
            }
        }
    }
    ofstream test_stream;
    test_stream.open("test.txt");
    validateSuccessTests("MUSTALIAS", pag, test_stream);
    validateSuccessTests("NOALIAS", pag, test_stream);

    // cg->dump("graph-cg");

    SVFIR::releaseSVFIR();
    SVF::LLVMModuleSet::releaseLLVMModuleSet();
    llvm::llvm_shutdown();
    return 0;
}
