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

#include <core/library.hpp>
#include <core/error.hpp>
#include <core/matrix.hpp>
#include <backend/backend_base.hpp>
#include <backend/matrix_base.hpp>
#include <io/logger.hpp>

#include <fstream>
#include <iostream>
#include <memory>
#include <iomanip>

#ifdef SPBLA_WITH_CUDA
#include <cuda/cuda_backend.hpp>
#endif

#ifdef SPBLA_WITH_SEQUENTIAL
#include <sequential/sq_backend.hpp>
#endif

#ifdef SPBLA_WITH_OPENCL
#include <opencl/opencl_backend.hpp>
#endif

#define INIT_BACKEND(type)                                  \
    try {                                                   \
        mBackend = std::make_shared<type>();                \
        mBackend->initialize(initHints);                    \
        initialized = mBackend->isInitialized();            \
    } catch (const std::exception& e) {                     \
        handleError(e);                                     \
    }

namespace spbla {

    std::unordered_set<class Matrix*> Library::mAllocated;
    std::shared_ptr<class BackendBase> Library::mBackend = nullptr;
    std::shared_ptr<class Logger>  Library::mLogger = std::make_shared<DummyLogger>();
    bool Library::mRelaxedRelease = false;

    void Library::initialize(hints initHints) {
        CHECK_RAISE_CRITICAL_ERROR(mBackend == nullptr, InvalidState, "Library already initialized");

        bool preferCpu = initHints & SPBLA_HINT_CPU_BACKEND;
        bool preferCuda = initHints & SPBLA_HINT_CUDA_BACKEND;
        bool preferOpenCL = initHints & SPBLA_HINT_OPENCL_BACKEND;
        bool prefer = preferCpu || preferCuda || preferOpenCL;
        bool initialized = false;

#ifdef SPBLA_WITH_CUDA
        // If user do not force something else or force cuda
        if (!prefer || preferCuda) {
            INIT_BACKEND(CudaBackend)

            // Failed to setup cuda, release backend and go to try next
            if (!initialized) {
                mBackend = nullptr;
                mLogger->logWarning("Failed to initialize Cuda backend");
            }
        }
#endif

#ifdef SPBLA_WITH_OPENCL
        // If user do not force something else or force opencl
        if (!initialized && (!prefer || preferOpenCL)) {
            INIT_BACKEND(OpenCLBackend)

            // Failed to setup opencl, release backend and go to try cpu
            if (!initialized) {
                mBackend = nullptr;
                mLogger->logWarning("Failed to initialize OpenCL backend");
            }
        }
#endif

#ifdef SPBLA_WITH_SEQUENTIAL
        if (!initialized) {
            INIT_BACKEND(SqBackend)

            // Failed somehow setup
            if (!initialized) {
                mBackend = nullptr;
                mLogger->logWarning("Failed to initialize Cpu fallback backend");
            }
        }
#endif

        CHECK_RAISE_ERROR(initialized, BackendError, "Failed to select backend");

        // If initialized, post-init actions
        mRelaxedRelease = initHints & SPBLA_HINT_RELAXED_FINALIZE;
        logDeviceInfo();
    }

    void Library::finalize() {
        if (mBackend) {
            // Release all allocated resources implicitly
            if (mRelaxedRelease) {
                LogStream stream(*getLogger());
                stream << Logger::Level::Info << "Enabled relaxed library finalize" << LogStream::cmt;

                for (auto m: mAllocated) {
                    stream << Logger::Level::Warning << "Implicitly release matrix " << m->getDebugMarker() << LogStream::cmt;
                    delete m;
                }

                mAllocated.clear();
            }

            // Some final message
            mLogger->logInfo("** spbla:Finalize backend **");

            // Remember to finalize backend
            mBackend->finalize();
            mBackend = nullptr;

            // Release (possibly setup text logger) logger, reassign dummy
            mLogger = std::make_shared<DummyLogger>();
        }
    }

    void Library::validate() {
        CHECK_RAISE_CRITICAL_ERROR(mBackend != nullptr || mRelaxedRelease, InvalidState, "Library is not initialized");
    }

    void Library::setupLogging(const char *logFileName, spbla_Hints hints) {
        CHECK_RAISE_ERROR(logFileName != nullptr, InvalidArgument, "Null file name is not allowed");

        auto lofFile = std::make_shared<std::ofstream>();

        lofFile->open(logFileName, std::ios::out);

        if (!lofFile->is_open()) {
            RAISE_ERROR(InvalidArgument, "Failed to create logging file");
        }

        // Create logger and setup filters && post-actions
        auto textLogger = std::make_shared<TextLogger>();

        textLogger->addFilter([=](Logger::Level level, const std::string& message) -> bool {
            bool all = hints == 0x0 || (hints & SPBLA_HINT_LOG_ALL);
            bool error = hints & SPBLA_HINT_LOG_ERROR;
            bool warning = hints & SPBLA_HINT_LOG_WARNING;

            return all ||
                    (error && level == Logger::Level::Error) ||
                    (warning && level == Logger::Level::Warning);
        });

        textLogger->addOnLoggerAction([=](size_t id, Logger::Level level, const std::string& message) {
            auto& file = *lofFile;

            const auto idSize = 10;
            const auto levelSize = 20;

            file << "[" << std::setw(idSize) << id << std::setw(-1) << "]";
            file << "[" << std::setw(levelSize);
            switch (level) {
                case Logger::Level::Info:
                    file << "Level::Info";
                    break;
                case Logger::Level::Warning:
                    file << "Level::Warning";
                    break;
                case Logger::Level::Error:
                    file << "Level::Error";
                    break;
                default:
                    file << "Level::Always";
            }
            file << std::setw(-1) << "] ";
            file << message << std::endl;
        });

        // Assign new text logger
        mLogger = textLogger;

        // Initial message
        mLogger->logInfo("*** spbla::Logger file ***");

        // Also log device capabilities
        if (isBackedInitialized())
            logDeviceInfo();
    }

    Matrix *Library::createMatrix(size_t nrows, size_t ncols) {
        CHECK_RAISE_ERROR(nrows > 0, InvalidArgument, "Cannot create matrix with zero dimension");
        CHECK_RAISE_ERROR(ncols > 0, InvalidArgument, "Cannot create matrix with zero dimension");

        auto m = new Matrix(nrows, ncols, *mBackend);
        mAllocated.emplace(m);

        LogStream stream(*getLogger());
        stream << Logger::Level::Info << "Create Matrix " << m->getDebugMarker()
               << " (" << nrows << "," << ncols << ")" << LogStream::cmt;

        return m;
    }

    void Library::releaseMatrix(Matrix *matrix) {
        if (mRelaxedRelease && !mBackend) return;

        CHECK_RAISE_ERROR(mAllocated.find(matrix) != mAllocated.end(), InvalidArgument, "No such matrix was allocated");

        LogStream stream(*getLogger());
        stream << Logger::Level::Info << "Release Matrix " << matrix->getDebugMarker() << LogStream::cmt;

        mAllocated.erase(matrix);
        delete matrix;
    }

    void Library::handleError(const std::exception& error) {
        mLogger->log(Logger::Level::Error, error.what());
    }

    void Library::queryCapabilities(spbla_DeviceCaps &caps) {
        caps.name[0] = '\0';
        caps.cudaSupported = false;
        caps.openclSupported = false;
        caps.major = 0;
        caps.minor = 0;
        caps.warp = 0;
        caps.globalMemoryKiBs = 0;
        caps.sharedMemoryPerBlockKiBs = 0;
        caps.sharedMemoryPerMultiProcKiBs = 0;

        mBackend->queryCapabilities(caps);
    }

    void Library::logDeviceInfo() {
        // Log device caps
        spbla_DeviceCaps caps;
        queryCapabilities(caps);

        LogStream stream(*getLogger());
        stream << Logger::Level::Info;

        if (caps.cudaSupported || caps.openclSupported) {
            stream << "Device capabilities:"
                   << " Cuda Type (" << caps.cudaSupported << "),"
                   << " OpenCL Type (" << caps.openclSupported << "),"
                   << " name: " << caps.name << ","
                   << " major: " << caps.major << ","
                   << " minor: " << caps.minor << ","
                   << " warp size: " << caps.warp << ","
                   << " globalMemoryKiBs: " << caps.globalMemoryKiBs << ","
                   << " sharedMemoryPerMultiProcKiBs: " << caps.sharedMemoryPerMultiProcKiBs << ","
                   << " sharedMemoryPerBlockKiBs: " << caps.sharedMemoryPerBlockKiBs;
        }
        else {
            stream << "CPU backend (GPU device is not present)";
        }

        stream << LogStream::cmt;
    }

    bool Library::isBackedInitialized() {
        return mBackend != nullptr;
    }

    class Logger * Library::getLogger() {
        return mLogger.get();
    }

}