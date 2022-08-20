#ifndef SVFHOOK_HEADER
#define SVFHOOK_HEADER

#include <vector>

typedef std::pair<std::vector<unsigned int>, std::vector<unsigned int>> edgeSet;
unsigned int handleGep(void *consG, void *pag, unsigned int id, unsigned int offset);
unsigned int getNodeCount(void *consG);
void handleGepsSVF(void *cg, void *pg, unsigned int *currPts, edgeSet &newPtsEdges);
#endif