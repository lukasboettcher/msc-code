#ifndef SVFHOOK_HEADER
#define SVFHOOK_HEADER

#include "shared.h"

unsigned int handleGep(void *consG, void *pag, unsigned int id, unsigned int offset);
unsigned int getNodeCount(void *consG);
void handleGepsSVF(void *cg, void *pg, unsigned int *currPts, edgeSet &newPtsEdges);
void getObjects(void *cg, void *pg, unsigned int *memory);
#endif