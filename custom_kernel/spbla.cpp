/* gcc -L../lib spbla.cpp -lspbla -Wl,-rpath,../lib */

#include "spbla.h"
#include "stdlib.h"
#include "stdio.h"

void print(spbla_Matrix m)
{
    spbla_Index *rows, *cols, nvals;
    spbla_Matrix_Nvals(m, &nvals);
    rows = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    cols = (spbla_Index *)malloc(sizeof(spbla_Index) * nvals);
    spbla_Matrix_ExtractPairs(m, rows, cols, &nvals);

    printf("printing: \n");
    for (size_t i = 0; i < nvals; i++)
        printf("%d %d\n", rows[i], cols[i]);
}

int main(int argc, char **argv)
{
    spbla_Initialize(SPBLA_HINT_CUDA_BACKEND);
    spbla_Index node_cnt, *range;
    spbla_Matrix a, b, c;

    node_cnt = 2;
    spbla_Matrix_New(&a, node_cnt, node_cnt);
    spbla_Matrix_New(&b, node_cnt, node_cnt);
    spbla_Matrix_New(&c, node_cnt, node_cnt);

    spbla_Matrix_SetElement(a, 0, 1);
    spbla_Matrix_SetElement(b, 1, 0);

    size_t ret = spbla_MxM(c, a, b, SPBLA_HINT_ACCUMULATE);

    printf("ret: %ld\n", ret);

    print(a);
    print(b);
    print(c);

    spbla_Matrix_Free(a);
    spbla_Matrix_Free(b);
    spbla_Matrix_Free(c);

    spbla_Finalize();
}
