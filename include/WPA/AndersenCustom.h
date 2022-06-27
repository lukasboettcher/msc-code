#ifndef ANDERSENCUSTOM_H_
#define ANDERSENCUSTOM_H_

#include "WPA/Andersen.h"
#include <mmxcflr.h>
#include "spbla/spbla.h"

namespace SVF
{

    class AndersenCustom : public Andersen
    {

    private:
        static AndersenCustom *customInstance; // static instance

        spbla_Matrix addr;
        spbla_Matrix copy;
        spbla_Matrix load;
        spbla_Matrix store;

    public:
        AndersenCustom(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : Andersen(_pag, type, alias_check) {}

        ~AndersenCustom()
        {
            spbla_Matrix_Free(addr);
            spbla_Matrix_Free(copy);
            spbla_Matrix_Free(load);
            spbla_Matrix_Free(store);
            spbla_Finalize();
        }

        // Create an singleton instance directly instead of invoking llvm pass manager
        static AndersenCustom *createAndersenCustom(SVFIR *_pag)
        {
            if (customInstance == nullptr)
            {
                customInstance = new AndersenCustom(_pag, Andersen_WPA, false);
                customInstance->analyze();
                return customInstance;
            }
            return customInstance;
        }
        static void releaseAndersenCustom()
        {
            if (customInstance)
                delete customInstance;
            customInstance = nullptr;
        }

        virtual void solveWorklist();

    protected:
        virtual void fillEdges(Edges &edges);
        virtual unordered_set<NodeID> processGepPts(Edges &edges, ConstraintGraph *consCG, SVFIR *pag, spbla_vec_t &pts, const GepCGEdge *edge);
        virtual void storeEdge(Edges &edges, NodeID src, NodeID dst, s64_t consEdgeType);
        virtual inline void setupMatrices()
        {
            size_t numNodes;
            numNodes = consCG->getTotalNodeNum();
            spbla_Matrix_New(&addr, numNodes, numNodes);
            spbla_Matrix_New(&copy, numNodes, numNodes);
            spbla_Matrix_New(&load, numNodes, numNodes);
            spbla_Matrix_New(&store, numNodes, numNodes);
        }
        virtual void fillMatrices();
        virtual AliasResult alias(NodeID a, NodeID b);
        virtual spbla_vec_t getPtsTo(NodeID a);
    };

}

#endif