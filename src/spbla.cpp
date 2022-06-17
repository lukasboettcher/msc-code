#include <mmxcflr.h>

#define spblaCheck(ans) { spblaAssert((ans), __FILE__, __LINE__); }
inline void spblaAssert(spbla_Status code, const char *file, int line, bool abort=true)
{
   if (code != 0) 
   {
      fprintf(stderr,"spbla_assert: %d %s %d\n", code, file, line);
      if (abort) exit(code);
   }
}

using namespace std;

spbla_Index get_nnz(spbla_Matrix m)
{
    spbla_Index nvals;
    spbla_Matrix_Nvals(m, &nvals);
    return nvals;
}

void print_edges(Edges edge_lists)
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

void print_matrix(spbla_Matrix &m, map<spbla_Index, string> *id2node = nullptr)
{
    spbla_Index *rows, *cols, nvals;
    spbla_Matrix_Nvals(m, &nvals);
    rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(m, rows, cols, &nvals);
    cout << "Printing Matrix with nvals: " << nvals << endl;
    for (spbla_Index i = 0; i < nvals; i++)
        if (id2node)
            cout << (*id2node)[rows[i]] << " " << (*id2node)[cols[i]] << endl;
        else
            cout << rows[i] << " " << cols[i] << endl;
    free(rows);
    free(cols);
}

void write_matrix_disk(spbla_Matrix &m, string path)
{
    FILE *fp = fopen(path.c_str(), "w");
    if (fp)
    {
        cerr << "Error opening File at: " << path << endl;
        return;
    }

    spbla_Index *rows, *cols, nvals;
    spbla_Matrix_Nvals(m, &nvals);
    rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(m, rows, cols, &nvals);
    fprintf(fp, "%i\n", nvals);
    for (spbla_Index i = 0; i < nvals; i++)
        fprintf(fp, "%i\t%i\n", rows[i], cols[i]);
    free(rows);
    free(cols);
    fclose(fp);
}

void parse_edges(istream *s, Edges &edge_lists, map<string, spbla_Index> &node2id, map<spbla_Index, string> &id2node, size_t &node_ctr)
{
    string type, src, dst;
    while (*s >> src >> dst >> type)
    {
        if (node2id.find(src) == node2id.end())
        {
            id2node[node_ctr] = src;
            node2id[src] = node_ctr++;
        }

        if (node2id.find(dst) == node2id.end())
        {
            id2node[node_ctr] = dst;
            node2id[dst] = node_ctr++;
        }
        if (!edge_lists.count(type))
            edge_lists[type] = {vector<spbla_Index>(), vector<spbla_Index>()};
        edge_lists[type].first.push_back(node2id[src]);
        edge_lists[type].second.push_back(node2id[dst]);
    }
}

void parse_rules(
    istream *s,
    SymbolSet &epsilon_nonterminals,
    unordered_map<string, SymbolSet> &terminal_to_nonterminals,
    Rules &rules,
    SymbolSet &symbols)
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

spbla_Matrix create_spbla_transpose(spbla_Matrix in)
{
    spbla_Matrix out;
    spbla_Index rows, cols;
    spbla_Matrix_Nrows(in, &rows);
    spbla_Matrix_Ncols(in, &cols);

    spbla_Matrix_New(&out, rows, cols);
    spbla_Matrix_Transpose(out, in, SPBLA_HINT_NO);
    return out;
}

spbla_Matrix load_matrix(string rule, MatrixMap &ms)
{
    spbla_Matrix ret;
    const char negative = '-';
    if (!("-" == rule.substr(0, 1)))
    {
        ret = ms[rule];
    }
    else
    {
        rule.erase(0, 1);
        ret = create_spbla_transpose(ms[rule]);
    }

    return ret;
}

void store_matrix(string rule, MatrixMap &ms, spbla_Matrix to_store)
{
    const char negative = '-';
    if ("-" == rule.substr(0, 1))
    {
        rule.erase(0, 1);
        spbla_Matrix to_store_T = create_spbla_transpose(to_store);
        spblaCheck(spbla_Matrix_EWiseAdd(ms[rule], ms[rule], to_store_T, SPBLA_HINT_NO));
        spbla_Matrix_Free(to_store);
        spbla_Matrix_Free(to_store_T);
    }
}

void load_matrices(Rule rule, MatrixMap &ms, spbla_Matrix &A, spbla_Matrix &B, spbla_Matrix &C)
{
    // cout << "loading: " << rule.first << " " <<  rule.second.first << " " << rule.second.second << endl;
    A = load_matrix(rule.second.first, ms);
    B = load_matrix(rule.second.second, ms);
    C = load_matrix(rule.first, ms);
}

void store_matrices(Rule rule, MatrixMap &ms, spbla_Matrix &A, spbla_Matrix &B, spbla_Matrix &C)
{
    store_matrix(rule.second.first, ms, A);
    store_matrix(rule.second.second, ms, B);
    store_matrix(rule.first, ms, C);
}

int main(int argc, char const *argv[])
{
    spbla_Initialize(SPBLA_HINT_CUDA_BACKEND);
    MatrixMap ms;
    SymbolSet epsilon_nonterminals;
    unordered_map<string, SymbolSet> terminal_to_nonterminals;
    Rules rules;
    Edges edge_lists;
    size_t node_cnt = 0;
    map<string, spbla_Index> node2id;
    map<spbla_Index, string> id2node;
    SymbolSet symbols;

    if (argc != 3)
    {
        cout << "./spbla_main <edges_path> <rules_path>" << endl;
        return EXIT_FAILURE;
    }

    ifstream edges_f(argv[1]);
    ifstream rules_f(argv[2]);

    parse_rules(&rules_f, epsilon_nonterminals, terminal_to_nonterminals, rules, symbols);
    cout << "\tPARSING RULES DONE" << endl;
    parse_edges(&edges_f, edge_lists, node2id, id2node, node_cnt);
    cout << "\tPARSING EDGES DONE" << endl;

    cout << "\tCreating Empty Matrices" << endl;
    // create empty initial matrices
    for (auto s : symbols)
    {
        cout << "for: " << s << endl;
        spbla_Matrix matrix;
        spbla_Matrix_New(&matrix, node_cnt, node_cnt);
        ms[s] = matrix;
    }

    cout << "\tAdding Epsilon Edges" << endl;
    // add epsilon edges
    for (auto s : epsilon_nonterminals)
    {
        spbla_Index *range;
        range = (spbla_Index *)malloc(sizeof(spbla_Index) * node_cnt);
        for (size_t i = 0; i < node_cnt; i++)
            range[i] = i;
        spblaCheck(spbla_Matrix_Build(ms[s], range, range, node_cnt, SPBLA_HINT_NO));
    }

    cout << "\tAdding Graph Edges" << endl;
    // add edges from graph
    for (auto &term : terminal_to_nonterminals)
    {
        spbla_Matrix tmp;
        spbla_Index *rows, *cols;

        spbla_Matrix_New(&tmp, node_cnt, node_cnt);
        rows = edge_lists[term.first].first.data();
        cols = edge_lists[term.first].second.data();

        spblaCheck(spbla_Matrix_Build(tmp, rows, cols, edge_lists[term.first].first.size(), SPBLA_HINT_NO));

        for (auto &nterm : term.second)
            spblaCheck(spbla_Matrix_EWiseAdd(ms[nterm], ms[nterm], tmp, SPBLA_HINT_ACCUMULATE));

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
            spbla_Matrix A, B, C;

            load_matrices(rule, ms, A, B, C);

            if (rule_rhs_c[i] == get_nnz(A) + get_nnz(B))
                continue;

            before = get_nnz(ms[rule.first]);

            // #pragma omp task depend(in:A,B), depend(inout:C), firstprivate(before, A,B,C)
            while (true)
            {
                cout << "\r[" << iter << "]running for [" << rule.first << " <- " << rule.second.first << " " << rule.second.second << "], nnz: " << get_nnz(ms[rule.first]) << flush;
                spblaCheck(spbla_MxM(C, A, B, SPBLA_HINT_ACCUMULATE)); // C += A x B
                if (get_nnz(C) == before)
                    break;
                before = get_nnz(C);
                change = true;
            }
            cout << endl;
            rule_rhs_c[i] = get_nnz(A) + get_nnz(B);
            store_matrices(rule, ms, A, B, C);
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
