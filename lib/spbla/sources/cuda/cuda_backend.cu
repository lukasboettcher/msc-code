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

#include <cuda/cuda_backend.hpp>
#include <cuda/cuda_matrix.hpp>
#include <core/library.hpp>
#include <io/logger.hpp>

namespace spbla {

    void CudaBackend::initialize(hints initHints) {
        if (CudaInstance::isCudaDeviceSupported()) {
            mInstance = new CudaInstance(initHints & SPBLA_HINT_GPU_MEM_MANAGED);
        }

        // No device. Cannot init this backend
    }

    void CudaBackend::finalize() {
        assert(mMatCount == 0);

        if (mMatCount > 0) {
            LogStream stream(*Library::getLogger());
            stream << Logger::Level::Error
                   << "Lost some (" << mMatCount << ") matrix objects" << LogStream::cmt;
        }

        if (mInstance) {
            delete mInstance;
            mInstance = nullptr;
        }
    }

    bool CudaBackend::isInitialized() const {
        return mInstance != nullptr;
    }

    MatrixBase *CudaBackend::createMatrix(size_t nrows, size_t ncols) {
        mMatCount++;
        return new CudaMatrix(nrows, ncols, getInstance());
    }

    void CudaBackend::releaseMatrix(MatrixBase *matrixBase) {
        mMatCount--;
        delete matrixBase;
    }

    void CudaBackend::queryCapabilities(spbla_DeviceCaps &caps) {
        CudaInstance::queryDeviceCapabilities(caps);
    }

    CudaInstance & CudaBackend::getInstance() {
        return *mInstance;
    }

}