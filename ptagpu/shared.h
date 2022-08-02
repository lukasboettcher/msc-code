#ifndef SHARED_HEADER
#define SHARED_HEADER

#include <vector>

typedef std::pair<std::pair<std::vector<unsigned int>, std::vector<unsigned int>>, std::vector<unsigned int>> edgeSet;

int run(unsigned int numNodes, edgeSet *addr, edgeSet *direct, edgeSet *load, edgeSet *store);

#endif