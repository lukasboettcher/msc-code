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

bool processGepPts(ofstream &edge_stream, ConstraintGraph *consCG, SVFIR *pag, set<NodeID> &pts, const GepCGEdge *edge)
{

    PointsTo tmpDstPts;
    if (SVFUtil::isa<VariantGepCGEdge>(edge))
    {
        // If a pointer is connected by a variant gep edge,
        // then set this memory object to be field insensitive,
        // unless the object is a black hole/constant.
        for (NodeID o : pts)
        {
            if (consCG->isBlkObjOrConstantObj(o))
            {
                tmpDstPts.set(o);
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
            tmpDstPts.set(baseId);

            edge_stream << baseId << "\t" << edge->getDstID() << "\t" << 0 << endl;
            edge_stream << edge->getDstID() << "\t" << baseId << "\t-" << 0 << endl;
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
                tmpDstPts.set(o);
                continue;
            }

            // if (!matchType(edge->getSrcID(), o, normalGepEdge)) continue;

            NodeID fieldSrcPtdNode = consCG->getGepObjVar(o, normalGepEdge->getLocationSet());
            tmpDstPts.set(fieldSrcPtdNode);

            edge_stream << fieldSrcPtdNode << "\t" << edge->getDstID() << "\t" << 0 << endl;
            edge_stream << edge->getDstID() << "\t" << fieldSrcPtdNode << "\t-" << 0 << endl;
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

    return true;
}

int main(int argc, char **argv)
{

    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    SVFUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
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
    // pag->dump("graph");

    // Addr, Copy, Store, Load, NormalGep, VariantGep
    ConstraintGraph *cg = new ConstraintGraph(pag);
    // cg->dump("graph-cg");

    // Andersen* ander = new Andersen(pag);
    // ander->analyze();
    // ander->dumpAllPts();

    ofstream edge_stream, meta_stream;
    edge_stream.open("edges.txt");
    meta_stream.open("meta.txt");

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

                processGepPts(edge_stream, cg, pag, pts, gepEdge);
            }
            else
            {
                edge_stream << x->getSrcID() << "\t" << x->getDstID() << "\t" << x->getEdgeKind() << endl;
                edge_stream << x->getDstID() << "\t" << x->getSrcID() << "\t-" << x->getEdgeKind() << endl;
            }
        }
    }

    SVFIR::releaseSVFIR();
    SVF::LLVMModuleSet::releaseLLVMModuleSet();
    llvm::llvm_shutdown();
    return 0;
}
