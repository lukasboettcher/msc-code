#include "WPA/AndersenCustom.h"

using namespace SVF;
using namespace SVFUtil;

AndersenCustom *AndersenCustom::customInstance = nullptr;

void AndersenCustom::solveWorklist()
{
    // while (!isWorklistEmpty())
    // {
    //     NodeID nodeId = popFromWorklist();
    //     collapsePWCNode(nodeId);
    //     // Keep solving until workList is empty.
    //     processNode(nodeId);
    //     collapseFields();
    // }
}
