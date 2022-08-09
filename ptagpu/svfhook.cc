#include "svfhook.h"
#include "Graphs/ConsG.h"

uint handleGep(void *consG, uint id, uint offset)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;

    SVF::LocationSet ls;
    ls.setFldIdx(offset);
    uint fieldSrcPtdNode = cg->getGepObjVar(id, ls);

    return fieldSrcPtdNode;
}

unsigned int getNodeCount(void *consG)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;
    unsigned int numNodes = cg->getTotalNodeNum();
    return numNodes;
}