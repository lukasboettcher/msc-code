#ifndef ANDERSENOPT_H_
#define ANDERSENOPT_H_

#include "WPA/Andersen.h"
#include "MemoryModel/PointsTo.h"
#include <chrono>
using nanoseconds = std::chrono::duration<long long, std::nano>;
namespace SVF
{

    class AndersenOpt : public AndersenWaveDiff
    {

    private:
        bool runComplete = false;
        std::set<NodeID> addCopyNodes;
        std::set<NodeID> reachable;
        nanoseconds processTime;
        nanoseconds pwcTime;
        nanoseconds collapseTime;

        nanoseconds sccTime;
        nanoseconds simpleTime;
        nanoseconds complexTime;

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


        void consReachableNodes(NodeID nodeid)
        {
            if (!reachable.insert(nodeid).second)
                return;

            ConstraintNode *node = consCG->getConstraintNode(nodeid);
            // for (ConstraintEdge *copyout : node->getCopyOutEdges())
            for (ConstraintEdge *copyout : node->getDirectOutEdges())
                consReachableNodes(copyout->getDstID());
        }

        virtual inline void solveWorklist()
        {
            cout << "running solveWorklist\n";
            // /*

            // Initialize the nodeStack via a whole SCC detection
            // Nodes in nodeStack are in topological order by default.
            auto w = std::chrono::steady_clock::now();
            NodeStack &nodeStack = SCCDetect();
            for (NodeID nodeid : addCopyNodes)
                consReachableNodes(nodeid);

            cout << "done scc\n";
            auto x = std::chrono::steady_clock::now();
            sccTime += (x - w);
            // Process nodeStack and put the changed nodes into workList.
            while (!nodeStack.empty())
            {
                NodeID nodeId = nodeStack.top();
                nodeStack.pop();
                auto a = std::chrono::steady_clock::now();
                collapsePWCNode(nodeId);
                // process nodes in nodeStack
                auto b = std::chrono::steady_clock::now();
                processNode(nodeId);
                auto c = std::chrono::steady_clock::now();
                collapseFields();
                auto d = std::chrono::steady_clock::now();

                processTime += (c - b);
                pwcTime += (b - a);
                collapseTime += (d - c);
            }
            cout << "done simple\n";
            auto y = std::chrono::steady_clock::now();
            simpleTime += (y - x);
            // New nodes will be inserted into workList during processing.
            while (!isWorklistEmpty())
            {
                NodeID nodeId = popFromWorklist();
                // process nodes in worklist
                postProcessNode(nodeId);
            }
            cout << "done complex\n";
            auto z = std::chrono::steady_clock::now();
            complexTime += (z - y);
            runComplete = true;
            // */
            cout << "sccTime: " << sccTime.count() / 1e6 << "ms\n";
            cout << "simpletime: " << simpleTime.count() / 1e6 << "ms\n";
            cout << "\tpwctime: " << pwcTime.count() / 1e6 << "ms\n";
            cout << "\tprocesstime: " << processTime.count() / 1e6 << "ms\n";
            cout << "\tcollapse: " << collapseTime.count() / 1e6 << "ms\n";
            cout << "complextime: " << complexTime.count() / 1e6 << "ms\n";
        }
    };

}

#endif