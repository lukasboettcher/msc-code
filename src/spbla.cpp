#include <spbla/spbla.h>
void print_matrix(spbla_Matrix &m)
{
    spbla_Index *rows, *cols, nvals;
    spbla_Matrix_Nvals(m, &nvals);
    rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(m, rows, cols, &nvals);
    cout << "Printing Matrix with nvals: " << nvals << endl;
    for (spbla_Index i = 0; i < nvals; i++)
        cout << rows[i] << " " << cols[i] << endl;
    free(rows);
    free(cols);
}

void parse_edges(istream *s, unordered_map<string, pair<vector<spbla_Index>, vector<spbla_Index>>> &edge_lists, unordered_set<spbla_Index> &nodes)
{
    string type;
    spbla_Index src, dst;
    while (*s >> src >> dst >> type)
    {
        nodes.insert(src);
        nodes.insert(dst);
        if (!edge_lists.count(type))
            edge_lists[type] = {vector<spbla_Index>(), vector<spbla_Index>()};
        edge_lists[type].first.push_back(src);
        edge_lists[type].second.push_back(dst);
    }
}

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
