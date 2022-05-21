/**********************************************************************************/
/* MIT License                                                                    */
/*                                                                                */
/* Copyright (c) 2020, 2021 JetBrains-Research                                    */
/*                                                                                */
/* Permission is hereby granted, free of charge, to any person obtaining a copy   */
/* of this software and associated documentation files (the "Software"), to deal  */
/* in the Software without restriction, including without limitation the rights   */
/* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      */
/* copies of the Software, and to permit persons to whom the Software is          */
/* furnished to do so, subject to the following conditions:                       */
/*                                                                                */
/* The above copyright notice and this permission notice shall be included in all */
/* copies or substantial portions of the Software.                                */
/*                                                                                */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     */
/* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    */
/* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  */
/* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  */
/* SOFTWARE.                                                                      */
/**********************************************************************************/

#include <testing/testing.hpp>
#include <cstring>

TEST(spbla_Matrix, Duplicate) {
    spbla_Matrix matrix = nullptr, duplicated = nullptr;
    spbla_Index m = 900, n = 600;
    float density = 0.31;

    testing::Matrix tmatrix = std::move(testing::Matrix::generateSparse(m, n, density));

    ASSERT_EQ(spbla_Initialize(SPBLA_HINT_NO), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Matrix_New(&matrix, m, n), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Build(matrix, tmatrix.rowsIndex.data(), tmatrix.colsIndex.data(), tmatrix.nvals, SPBLA_HINT_VALUES_SORTED), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Matrix_Duplicate(matrix, &duplicated), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(tmatrix.areEqual(duplicated), true);

    ASSERT_EQ(spbla_Matrix_Free(matrix), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Free(duplicated), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Finalize(), SPBLA_STATUS_SUCCESS);
}

TEST(spbla_Matrix, PropertyQuery) {
    spbla_Matrix matrix = nullptr;
    spbla_Index m = 900, n = 600;
    float density = 0.21;

    testing::Matrix tmatrix = std::move(testing::Matrix::generateSparse(m, n, density));

    ASSERT_EQ(spbla_Initialize(SPBLA_HINT_NO), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Matrix_New(&matrix, m, n), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Build(matrix, tmatrix.rowsIndex.data(), tmatrix.colsIndex.data(), tmatrix.nvals, SPBLA_HINT_VALUES_SORTED), SPBLA_STATUS_SUCCESS);

    spbla_Index nrows;
    spbla_Index ncols;
    spbla_Index nvals;

    ASSERT_EQ(spbla_Matrix_Nvals(matrix, &nvals), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Nrows(matrix, &nrows), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Ncols(matrix, &ncols), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(nvals, tmatrix.nvals);
    ASSERT_EQ(nrows, tmatrix.nrows);
    ASSERT_EQ(ncols, tmatrix.ncols);

    ASSERT_EQ(spbla_Matrix_Free(matrix), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Finalize(), SPBLA_STATUS_SUCCESS);
}

TEST(spbla_Matrix, ExtractPairs) {
    spbla_Matrix matrix = nullptr;
    spbla_Index m = 900, n = 600;
    float density = 0.21;

    testing::Matrix tmatrix = std::move(testing::Matrix::generateSparse(m, n, density));

    ASSERT_EQ(spbla_Initialize(SPBLA_HINT_NO), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(spbla_Matrix_New(&matrix, m, n), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Build(matrix, tmatrix.rowsIndex.data(), tmatrix.colsIndex.data(), tmatrix.nvals, SPBLA_HINT_VALUES_SORTED), SPBLA_STATUS_SUCCESS);

    spbla_Index nvals = tmatrix.nvals;
    std::vector<spbla_Index> rows(tmatrix.nvals);
    std::vector<spbla_Index> cols(tmatrix.nvals);

    ASSERT_EQ(spbla_Matrix_ExtractPairs(matrix, rows.data(), cols.data(), &nvals), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(nvals, tmatrix.nvals);
    ASSERT_EQ(spbla_Matrix_Free(matrix), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Finalize(), SPBLA_STATUS_SUCCESS);
}

TEST(spbla_Matrix, Marker) {
    spbla_Matrix matrix = nullptr;
    spbla_Index m, n;

    m = n = 100;

    const spbla_Index BUFFER_SIZE = 100;
    const char* marker = "Test Matrix Marker";
    spbla_Index size = 0;
    char buffer[BUFFER_SIZE];

    ASSERT_EQ(spbla_Initialize(SPBLA_HINT_NO), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_New(&matrix, m, n), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_SetMarker(matrix, marker), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Marker(matrix, nullptr, &size), SPBLA_STATUS_SUCCESS);
    ASSERT_LE(size, BUFFER_SIZE);
    ASSERT_EQ(spbla_Matrix_Marker(matrix, buffer, &size), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Free(matrix), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Finalize(), SPBLA_STATUS_SUCCESS);

    ASSERT_EQ(std::strlen(buffer), size - 1);
    ASSERT_LE(std::strcmp(marker, buffer), 0);

    std::cout << "Source marker: " << marker << std::endl;
    std::cout << "Returned marker: " << buffer << std::endl;
}

TEST(spbla_Matrix, MarkerShort) {
    spbla_Matrix matrix = nullptr;
    spbla_Index m, n;

    m = n = 100;

    const spbla_Index BUFFER_SIZE = 10;
    const char* marker = "Test Matrix Marker";
    spbla_Index size = BUFFER_SIZE;
    char buffer[BUFFER_SIZE];

    ASSERT_EQ(spbla_Initialize(SPBLA_HINT_NO), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_New(&matrix, m, n), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_SetMarker(matrix, marker), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Marker(matrix, buffer, &size), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Matrix_Free(matrix), SPBLA_STATUS_SUCCESS);
    ASSERT_EQ(spbla_Finalize(), SPBLA_STATUS_SUCCESS);

    ASSERT_GE(std::strcmp(marker, buffer), 0);

    std::cout << "Source marker: " << marker << std::endl;
    std::cout << "Returned marker: " << buffer << std::endl;
}

SPBLA_GTEST_MAIN
