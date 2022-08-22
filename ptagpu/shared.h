#ifndef SHARED_HEADER
#define SHARED_HEADER

#include <vector>

typedef std::pair<std::vector<unsigned int>, std::vector<unsigned int>> edgeSet;
typedef std::pair<std::pair<std::vector<unsigned int>, std::vector<unsigned int>>, std::vector<unsigned int>> edgeSetOffset;

unsigned int *run(unsigned int numNodes, edgeSet *addr, edgeSet *direct, edgeSet *load, edgeSet *store, void *consG, void *pag);
bool aliasBV(unsigned int a, unsigned int b, unsigned int *memory);

#endif