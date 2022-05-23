#include <spbla/spbla.h>
#include <bits/stdc++.h>

using namespace std;

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

    // ifstream edges_f("/home/lukas/Documents/msc-test/src/edges.txt");
    // ifstream edges_f("/home/lukas/Downloads/Graspan Datasets and Support/Graphs/Linux 4.4-rc5 Dataflow/lnx_arch_df");
    // ifstream edges_f("/home/lukas/Downloads/Graspan Datasets and Support/Graphs/Linux 4.4-rc5 Dataflow/lnx_kernel_df");
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

    cout << "\tAdding Graph Edges" << endl;
    // add edges from graph
    for (auto &term : terminal_to_nonterminals)
    {
        spbla_Matrix tmp;
        spbla_Index *rows, *cols;

        spbla_Matrix_New(&tmp, nodes.size(), nodes.size());
        rows = edge_lists[term.first].first.data();
        cols = edge_lists[term.first].second.data();

        spbla_Matrix_Build(tmp, rows, cols, edge_lists[term.first].first.size(), SPBLA_HINT_NO);

        for (auto &nterm : term.second)
            spbla_Matrix_EWiseAdd(ms[nterm], ms[nterm], tmp, SPBLA_HINT_ACCUMULATE);

        spbla_Matrix_Free(tmp);
    }

    vector<int> rule_rhs_c(rules.size(), -1);
    bool change = true;
    int iter = 1;
    while (change)
    {
        change = false;
        #pragma omp parallel
        #pragma omp single
        for (size_t i = 0; i < rules.size(); i++)
        {
            auto rule = rules[i];
            spbla_Index total = 0;
            spbla_Index before, current, nvals_a, nvals_b;
            spbla_Matrix A,B,C;
            A = ms[rule.second.first];
            B = ms[rule.second.second];
            C = ms[rule.first];

            if (rule_rhs_c[i] == get_nnz(A) + get_nnz(B))
                continue;

            before = get_nnz(ms[rule.first]);


            #pragma omp task depend(in:A,B), depend(inout:C), firstprivate(before, A,B,C)
            while (true)
            {
                cout << "\r[" << iter << "]running for lhs: " << rule.first << ", nnz: " << get_nnz(ms[rule.first]) << flush;
                spbla_MxM(C, A, B, SPBLA_HINT_ACCUMULATE); // C += A x B
                if (get_nnz(C) == before)
                    break;
                before = get_nnz(C);
                change = true;
            }
            cout << endl;
            rule_rhs_c[i] = get_nnz(A) + get_nnz(B);
        }
        iter++;
    }

    for (auto &&s : symbols)
    {
        spbla_Matrix_Free(ms[s]);
    }

    spbla_Finalize();
    return 0;
}
