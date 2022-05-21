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

#include <sequential/sq_matrix.hpp>
#include <sequential/sq_transpose.hpp>
#include <sequential/sq_submatrix.hpp>
#include <sequential/sq_kronecker.hpp>
#include <sequential/sq_ewiseadd.hpp>
#include <sequential/sq_spgemm.hpp>
#include <sequential/sq_reduce.hpp>
#include <utils/csr_utils.hpp>
#include <core/error.hpp>
#include <cassert>

namespace spbla {

    SqMatrix::SqMatrix(size_t nrows, size_t ncols) {
        assert(nrows > 0);
        assert(ncols > 0);

        mData.nrows = nrows;
        mData.ncols = ncols;
    }

    void SqMatrix::setElement(index i, index j) {
        RAISE_ERROR(NotImplemented, "This function is not supported for this matrix class");
    }

    void SqMatrix::build(const index *rows, const index *cols, size_t nvals, bool isSorted, bool noDuplicates) {
        auto nrows = mData.nrows;
        auto ncols = mData.ncols;

        mData.rowOffsets.clear();
        mData.colIndices.clear();

        // Call utility to build csr row offsets and column indices and store in mData vectors
        CsrUtils::buildFromData(nrows, ncols, rows, cols, nvals, mData.rowOffsets, mData.colIndices, isSorted, noDuplicates);

        mData.nvals = mData.colIndices.size();
    }

    void SqMatrix::extract(index *rows, index *cols, size_t &nvals) {
        assert(nvals >= getNvals());
        nvals = getNvals();

        if (nvals > 0) {
            CsrUtils::extractData(getNrows(), getNcols(), rows, cols, nvals, mData.rowOffsets, mData.colIndices);
        }
    }

    void SqMatrix::extractSubMatrix(const MatrixBase &otherBase, index i, index j, index nrows, index ncols,
                                    bool checkTime) {
        auto other = dynamic_cast<const SqMatrix*>(&otherBase);

        CHECK_RAISE_ERROR(other != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");
        CHECK_RAISE_ERROR(other != this, InvalidArgument, "Matrices must differ");

        assert(this->getNrows() == nrows);
        assert(this->getNcols() == ncols);

        this->allocateStorage();
        other->allocateStorage();
        sq_submatrix(other->mData, this->mData, i, j, nrows, ncols);
    }

    void SqMatrix::clone(const MatrixBase &otherBase) {
        auto other = dynamic_cast<const SqMatrix*>(&otherBase);

        CHECK_RAISE_ERROR(other != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");
        CHECK_RAISE_ERROR(other != this, InvalidArgument, "Matrices must differ");

        assert(other->getNrows() == this->getNrows());
        assert(other->getNcols() == this->getNcols());

        this->mData = other->mData;
    }

    void SqMatrix::transpose(const MatrixBase &otherBase, bool checkTime) {
        auto other = dynamic_cast<const SqMatrix*>(&otherBase);

        CHECK_RAISE_ERROR(other != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");

        assert(other->getNcols() == this->getNrows());
        assert(other->getNrows() == this->getNcols());

        CsrData out;
        out.nrows = this->getNrows();
        out.ncols = this->getNcols();

        this->allocateStorage();
        other->allocateStorage();
        sq_transpose(other->mData, out);

        this->mData = std::move(out);
    }

    void SqMatrix::reduce(const MatrixBase &otherBase, bool checkTime) {
        auto other = dynamic_cast<const SqMatrix*>(&otherBase);

        CHECK_RAISE_ERROR(other != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");

        assert(other->getNrows() == this->getNrows());
        assert(1 == this->getNcols());

        CsrData out;
        out.nrows = this->getNrows();
        out.ncols = this->getNcols();

        this->allocateStorage();
        other->allocateStorage();
        sq_reduce(other->mData, out);

        this->mData = std::move(out);
    }

    void SqMatrix::multiply(const MatrixBase &aBase, const MatrixBase &bBase, bool accumulate, bool checkTime) {
        auto a = dynamic_cast<const SqMatrix*>(&aBase);
        auto b = dynamic_cast<const SqMatrix*>(&bBase);

        CHECK_RAISE_ERROR(a != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");
        CHECK_RAISE_ERROR(b != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");

        assert(a->getNcols() == b->getNrows());
        assert(a->getNrows() == this->getNrows());
        assert(b->getNcols() == this->getNcols());

        CsrData out;
        out.nrows = this->getNrows();
        out.ncols = this->getNcols();

        a->allocateStorage();
        b->allocateStorage();
        sq_spgemm(a->mData, b->mData, out);

        if (accumulate) {
            CsrData out2;
            out2.nrows = this->getNrows();
            out2.ncols = this->getNcols();

            this->allocateStorage();
            sq_ewiseadd(this->mData, out, out2);

            std::swap(out2, out);
        }

        this->mData = std::move(out);
    }

    void SqMatrix::kronecker(const MatrixBase &aBase, const MatrixBase &bBase, bool checkTime) {
        auto a = dynamic_cast<const SqMatrix*>(&aBase);
        auto b = dynamic_cast<const SqMatrix*>(&bBase);

        CHECK_RAISE_ERROR(a != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");
        CHECK_RAISE_ERROR(b != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");

        assert(a->getNrows() * b->getNrows() == this->getNrows());
        assert(a->getNcols() * b->getNcols() == this->getNcols());

        CsrData out;
        out.nrows = this->getNrows();
        out.ncols = this->getNcols();

        a->allocateStorage();
        b->allocateStorage();
        sq_kronecker(a->mData, b->mData, out);

        this->mData = std::move(out);
    }

    void SqMatrix::eWiseAdd(const MatrixBase &aBase, const MatrixBase &bBase, bool checkTime) {
        auto a = dynamic_cast<const SqMatrix*>(&aBase);
        auto b = dynamic_cast<const SqMatrix*>(&bBase);

        CHECK_RAISE_ERROR(a != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");
        CHECK_RAISE_ERROR(b != nullptr, InvalidArgument, "Provided matrix does not belongs to sequential matrix class");

        assert(a->getNrows() == this->getNrows());
        assert(a->getNcols() == this->getNcols());
        assert(a->getNrows() == b->getNrows());
        assert(a->getNcols() == b->getNcols());

        CsrData out;
        out.nrows = this->getNrows();
        out.ncols = this->getNcols();

        a->allocateStorage();
        b->allocateStorage();
        sq_ewiseadd(a->mData, b->mData, out);

        this->mData = std::move(out);
    }

    index SqMatrix::getNrows() const {
        return mData.nrows;
    }

    index SqMatrix::getNcols() const {
        return mData.ncols;
    }

    index SqMatrix::getNvals() const {
        return mData.nvals;
    }

    void SqMatrix::allocateStorage() const {
        if (mData.rowOffsets.size() != getNrows() + 1) {
            mData.rowOffsets.clear();
            mData.rowOffsets.resize(getNrows() + 1, 0);
        }
    }
}