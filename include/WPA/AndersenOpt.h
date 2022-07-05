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
        nanoseconds processTime;
        nanoseconds pwcTime;
        nanoseconds collapseTime;

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
                auto a = std::chrono::steady_clock::now();
                collapsePWCNode(nodeId);
                // process nodes in nodeStack
                auto b = std::chrono::steady_clock::now();
                processNode(nodeId);
                auto c = std::chrono::steady_clock::now();
                collapseFields();
                auto d = std::chrono::steady_clock::now();

                processTime += (c-b);
                pwcTime += (b-a);
                collapseTime += (d-c);
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

            cout << "\tpwctime: " << pwcTime.count()/1e6 <<"ms\n";
            cout << "\tprocesstime: " << processTime.count()/1e6 <<"ms\n";
            cout << "\tcollapse: " << collapseTime.count()/1e6 <<"ms\n";
            
        }
    };

}

#endif