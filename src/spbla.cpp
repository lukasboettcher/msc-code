#include <spbla/spbla.h>
spbla_Index get_nnz(spbla_Matrix m)
{
    spbla_Index nvals;
    spbla_Matrix_Nvals(m, &nvals);
    return nvals;
}

void print_edges(unordered_map<string, pair<vector<spbla_Index>, vector<spbla_Index>>> edge_lists)
{
    for (auto &&i : edge_lists)
    {
        cout << i.first << endl;
        for (size_t j = 0; j < i.second.first.size(); j++)
        {
            cout << i.second.first[j] << i.second.second[j] << endl;
        }
        cout << endl;
    }
}

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
    spbla_Initialize(SPBLA_HINT_CUDA_BACKEND);
    map<string, spbla_Matrix> ms;
    unordered_set<string> epsilon_nonterminals;
    unordered_map<string, unordered_set<string>> terminal_to_nonterminals;
    vector<pair<string, pair<string, string>>> rules;
    unordered_map<string, pair<vector<spbla_Index>, vector<spbla_Index>>> edge_lists;
    unordered_set<spbla_Index> nodes;
    unordered_set<string> symbols;

    ifstream edges_f("/home/lukas/Downloads/Graspan Datasets and Support/Graphs/Linux 4.4-rc5 Points-to/arch_afterInline.txt");
    ifstream rules_f("/home/lukas/Documents/msc-test/src/rules2.txt");

    parse_rules(&rules_f, epsilon_nonterminals, terminal_to_nonterminals, rules, symbols);
    cout << "\tPARSING RULES DONE" << endl;
    parse_edges(&edges_f, edge_lists, nodes);
    cout << "\tPARSING EDGES DONE" << endl;

    cout << "\tCreating Empty Matrices" << endl;
    // create empty initial matrices
    for (auto s : symbols)
    {
        cout << "for: " << s << endl;
        spbla_Matrix matrix;
        spbla_Matrix_New(&matrix, nodes.size(), nodes.size());
        ms[s] = matrix;
    }

    cout << "\tAdding Epsilon Edges" << endl;
    // add epsilon edges
    for (auto s : epsilon_nonterminals)
    {
        spbla_Index *range;
        range = (spbla_Index *)malloc(sizeof(spbla_Index) * nodes.size());
        for (size_t i = 0; i < nodes.size(); i++)
            range[i] = i;
        spbla_Matrix_Build(ms[s], range, range, nodes.size(), SPBLA_HINT_NO);
    }

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
