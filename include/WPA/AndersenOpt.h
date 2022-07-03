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

        virtual inline void solveWorklist()
        {
            cout << "running solveWorklist\n";
            if (runComplete)
            {
                while (!changeSet.empty())
                {
                    NodeID nodeId = changeSet.top();
                    changeSet.pop();
                    collapsePWCNode(nodeId);
                    // process nodes in nodeStack
                    processNode(nodeId);
                    collapseFields();
                }
            }
            else
                AndersenWaveDiff::solveWorklist();
            runComplete = true;
        }

        virtual inline bool addCopyEdge(NodeID src, NodeID dst)
        {
            if (consCG->addCopyCGEdge(src, dst))
            {
                changeSet.push(src);
                changeSet.push(dst);
                updatePropaPts(src, dst);
                return true;
            }
            return false;
        }
    };

}

#endif