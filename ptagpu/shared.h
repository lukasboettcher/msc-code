#ifndef SHARED_HEADER
#define SHARED_HEADER

#include <vector>

typedef std::pair<std::vector<unsigned int>, std::vector<unsigned int>> edgeSet;
typedef std::pair<std::pair<std::vector<unsigned int>, std::vector<unsigned int>>, std::vector<unsigned int>> edgeSetOffset;

bool aliasBV(uint a, uint b, uint *memory);

#endif