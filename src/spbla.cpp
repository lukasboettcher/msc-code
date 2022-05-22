#include <spbla/spbla.h>

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
