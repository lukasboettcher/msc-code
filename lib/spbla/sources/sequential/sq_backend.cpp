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

#include <sequential/sq_backend.hpp>
#include <sequential/sq_matrix.hpp>
#include <core/library.hpp>
#include <io/logger.hpp>
#include <cassert>


namespace spbla {

    void SqBackend::initialize(hints initHints) {
        // No special actions
    }

    void SqBackend::finalize() {
        assert(mMatCount == 0);

        if (mMatCount > 0) {
            LogStream stream(*Library::getLogger());
            stream << Logger::Level::Error
                   << "Lost some (" << mMatCount << ") matrix objects" << LogStream::cmt;
        }
    }

    bool SqBackend::isInitialized() const {
        return true;
    }

    MatrixBase *SqBackend::createMatrix(size_t nrows, size_t ncols) {
        mMatCount++;
        return new SqMatrix(nrows, ncols);
    }

    void SqBackend::releaseMatrix(MatrixBase *matrixBase) {
        mMatCount--;
        delete matrixBase;
    }

    void SqBackend::queryCapabilities(spbla_DeviceCaps &caps) {
        caps.cudaSupported = false;
    }

}
