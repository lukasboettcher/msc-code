#include "svfhook.h"
#include "Graphs/ConsG.h"

uint handleGep(void *consG, void *pag, uint id, uint offset)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;
    SVF::SVFIR *pg = (SVF::SVFIR *)pag;

    SVF::LocationSet ls;
    ls.setFldIdx(offset);

    const SVF::SVFVar *node = pg->getGNode(id);
    if (const SVF::ObjVar *objPN = SVF::SVFUtil::dyn_cast<SVF::ObjVar>(node))
    {
        if (cg->isBlkObjOrConstantObj(id))
        {
            return id;
        }
    }
    else
    {
        return id;
    }

    uint fieldSrcPtdNode = cg->getGepObjVar(id, ls);

    return fieldSrcPtdNode;
}

unsigned int getNodeCount(void *consG)
{
    SVF::ConstraintGraph *cg = (SVF::ConstraintGraph *)consG;
    unsigned int numNodes = cg->getTotalNodeNum();
    return numNodes;
}