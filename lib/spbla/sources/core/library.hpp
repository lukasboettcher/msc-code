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

#ifndef SPBLA_LIBRARY_HPP
#define SPBLA_LIBRARY_HPP

#include <core/config.hpp>
#include <core/error.hpp>
#include <unordered_set>
#include <memory>

namespace spbla {

    class Library {
    public:
        static void initialize(hints initHints);
        static void finalize();
        static void validate();
        static void setupLogging(const char* logFileName, spbla_Hints hints);
        static class Matrix *createMatrix(size_t nrows, size_t ncols);
        static void releaseMatrix(class Matrix *matrix);
        static void handleError(const std::exception& error);
        static void queryCapabilities(spbla_DeviceCaps& caps);
        static void logDeviceInfo();
        static bool isBackedInitialized();
        static class Logger* getLogger();

    private:
        static std::unordered_set<class Matrix*> mAllocated;
        static std::shared_ptr<class BackendBase> mBackend;
        static std::shared_ptr<class Logger> mLogger;
        static bool mRelaxedRelease;
    };

}

#endif //SPBLA_LIBRARY_HPP