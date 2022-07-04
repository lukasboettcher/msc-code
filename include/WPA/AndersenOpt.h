#ifndef ANDERSENOPT_H_
#define ANDERSENOPT_H_

#include "WPA/Andersen.h"
#include "MemoryModel/PointsTo.h"

namespace SVF
{

    class AndersenOpt : public AndersenWaveDiff
    {

    private:
        bool runComplete = false;
        NodeStack changeSet;

    protected:
    public:
        AndersenOpt(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : AndersenWaveDiff(_pag, type, alias_check) {}

        ~AndersenOpt()
        {
        }

        virtual inline bool addCopyEdge(NodeID src, NodeID dst)
        {
            if (CopyCGEdge *newEdge = consCG->addCopyCGEdge(src, dst))
            {
                // Lcopy.push_back(newEdge);
                addCopyNodes.insert(src);
                updatePropaPts(src, dst);
                return true;
            }
            return false;
        }

        virtual bool processCopy(NodeID node, const ConstraintEdge *edge)
        {
            if (runComplete && reachable.find(node) == reachable.end())
                return false;
            return AndersenWaveDiff::processCopy(node, edge);
        }

        virtual inline void solveWorklist()
        {
            cout << "running solveWorklist\n";
            if (runComplete)
            {
            // /*

            // Initialize the nodeStack via a whole SCC detection
            // Nodes in nodeStack are in topological order by default.
            NodeStack &nodeStack = SCCDetect();
            for (NodeID nodeid : addCopyNodes)
                consReachableNodes(nodeid);

            cout << "done scc\n";
            // Process nodeStack and put the changed nodes into workList.
            while (!nodeStack.empty())
            {
                NodeID nodeId = nodeStack.top();
                nodeStack.pop();
                collapsePWCNode(nodeId);
                // process nodes in nodeStack
                processNode(nodeId);
                collapseFields();
            }
            cout << "simple scc\n";

            // New nodes will be inserted into workList during processing.
            while (!isWorklistEmpty())
            {
                NodeID nodeId = popFromWorklist();
                // process nodes in worklist
                postProcessNode(nodeId);
            }
            cout << "done complex\n";
            runComplete = true;
            // */
        }
    };

}

#endif