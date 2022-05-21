/**********************************************************************************/
/* MIT License                                                                    */
/*                                                                                */
/* Copyright (c) 2021 JetBrains-Research                                          */
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

#include <opencl/opencl_matrix.hpp>
#include <core/error.hpp>
#include <dcsr/dcsr.hpp>
#include <cassert>

namespace spbla {

    void OpenCLMatrix::kronecker(const MatrixBase &aBase, const MatrixBase &bBase, bool checkTime) {
        auto a = dynamic_cast<const OpenCLMatrix*>(&aBase);
        auto b = dynamic_cast<const OpenCLMatrix*>(&bBase);

        CHECK_RAISE_ERROR(a != nullptr, InvalidArgument, "Passed matrix does not belong to OpenCLMatrix class");
        CHECK_RAISE_ERROR(b != nullptr, InvalidArgument, "Passed matrix does not belong to OpenCLMatrix class");

        assert(this->getNrows() == a->getNrows() * b->getNrows());
        assert(this->getNcols() == a->getNcols() * b->getNcols());

        clbool::dcsr::kronecker_product(*clboolState, mMatrixImpl, a->mMatrixImpl, b->mMatrixImpl);
        updateFromImpl();

        assert(this->getNvals() == a->getNvals() * b->getNvals());
        assert(this->getNrows() == a->getNrows() * b->getNrows());
        assert(this->getNcols() == a->getNcols() * b->getNcols());
    }

}