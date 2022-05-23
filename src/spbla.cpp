#include <spbla/spbla.h>
void parse_rules(
    istream *s,
    unordered_set<string> &epsilon_nonterminals,
    unordered_map<string, unordered_set<string>> &terminal_to_nonterminals,
    vector<pair<string, pair<string, string>>> &rules,
    unordered_set<string> &symbols)
{
    string symbol, line;
    size_t k = 0;
    while (getline(*s, line))
    {
        vector<string> l_syms;
        istringstream linestream(line);
        while (linestream >> symbol)
            l_syms.push_back(symbol);
        symbols.insert(l_syms[0]);
        if (l_syms.size() == 1)
            epsilon_nonterminals.insert(l_syms[0]);
        else if (l_syms.size() == 2)
        {
            terminal_to_nonterminals[l_syms[1]].insert(l_syms[0]);
        }
        else if (l_syms.size() == 3)
        {
            rules.push_back({l_syms[0], {l_syms[1], l_syms[2]}});
        }
    }
}

int main(int argc, char const *argv[])
{
    spbla_Matrix matrix, matrix_copy;

    spbla_Index nvals = 5;
    spbla_Index rows[nvals] = {0, 1};
    spbla_Index cols[nvals] = {1, 2};

    spbla_Initialize(SPBLA_HINT_NO);
    spbla_Matrix_New(&matrix, 10, 10);

    spbla_Matrix_Build(matrix, rows, cols, nvals, SPBLA_HINT_NO);

    // spbla_Matrix_Duplicate(matrix, &matrix_copy);

    spbla_MxM(matrix, matrix, matrix, SPBLA_HINT_ACCUMULATE);

    spbla_Matrix_ExtractPairs(matrix, rows, cols, &nvals);
    spbla_Index nrows, ncols;
    spbla_Matrix_Ncols(matrix, &ncols);
    spbla_Matrix_Nrows(matrix, &nrows);

    for (spbla_Index i = 0; i < nvals; i++)
        std::cout << rows[i] << " " << cols[i] << std::endl;

    spbla_Matrix_Free(matrix);
    spbla_Finalize();
    return 0;
}
