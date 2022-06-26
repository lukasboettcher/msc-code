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

    public:
        AndersenCustom(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : Andersen(_pag, type, alias_check) {}

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
    };

}

#endif