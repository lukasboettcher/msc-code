
#ifndef MMXCFLR_
#define MMXCFLR_

#include "spbla/spbla.h"
#include <bits/stdc++.h>

#define spblaCheck(ans) { spblaAssert((ans), __FILE__, __LINE__); }
inline void spblaAssert(spbla_Status code, const char *file, int line, bool abort=true)
{
   if (code != 0) 
   {
      fprintf(stderr,"spbla_assert: %d %s %d\n", code, file, line);
      if (abort) exit(code);
   }
}

struct AdjMatrix {
    spbla_Index *rows;
    spbla_Index *cols;
    spbla_Index nvals;
};

typedef std::map<std::string, spbla_Matrix> MatrixMap;
typedef std::unordered_set<std::string> SymbolSet;
typedef std::pair<std::string, std::pair<std::string, std::string>> Rule;
typedef std::vector<Rule> Rules;
typedef std::vector<spbla_Index> spbla_vec_t;
typedef std::unordered_map<std::string, std::pair<spbla_vec_t, spbla_vec_t>> Edges;
typedef struct AdjMatrix AdjMatrix;


void run(std::istream &grammar_f, Edges edge_lists, size_t node_cnt, AdjMatrix *adjm);
bool alias(spbla_Index *rows, spbla_Index *cols, spbla_Index nvals, spbla_Index a, spbla_Index b, spbla_Matrix m);


#endif
