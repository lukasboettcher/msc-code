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

#include <cuda/cuda_matrix.hpp>
#include <utils/csr_utils.hpp>

namespace spbla {

    void CudaMatrix::build(const index *rows, const index *cols, size_t nvals, bool isSorted, bool noDuplicates) {
        if (nvals == 0) {
            mMatrixImpl.zero_dim();  // no content, empty matrix
            return;
        }

        // Build csr structure and store on cpu side
        std::vector<index> rowOffsets;
        std::vector<index> colIndices;

        CsrUtils::buildFromData(getNrows(), getNcols(), rows, cols, nvals, rowOffsets, colIndices, isSorted, noDuplicates);

        // Move actual data to the matrix implementation
        this->transferToDevice(rowOffsets, colIndices);
    }

}