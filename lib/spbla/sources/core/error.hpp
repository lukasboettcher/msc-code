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

#ifndef SPBLA_ERROR_HPP
#define SPBLA_ERROR_HPP

#include <spbla/spbla.h>
#include <exception>
#include <string>
#include <sstream>

namespace spbla {

    /**
     * Generic library exception.
     * Use this one in particular backend implementations.
     */
    class Exception: public std::exception {
    public:

        Exception(std::string message, std::string function, std::string file, size_t line, spbla_Status status, bool critical)
                : std::exception(),
                  mMessage(std::move(message)),
                  mFunction(std::move(function)),
                  mFile(std::move(file)),
                  mLine(line),
                  nStatus(status),
                  mCritical(critical) {

        }

        Exception(const Exception& e) noexcept = default;
        Exception(Exception&& e) noexcept = default;
        ~Exception() noexcept override = default;

        const char* what() const noexcept override {
            if (!mCached) {
                mCached = true;

                std::stringstream s;
                s << "\"" << getMessage() << "\" in" << std::endl
                  << getFile() << ": line: " << getLine() << " function: " << getFunction();

                mWhatCached = s.str();
            }

            return mWhatCached.c_str();
        }

        const std::string& getMessage() const noexcept {
            return mMessage;
        }

        const std::string& getFunction() const noexcept {
            return mFunction;
        }

        const std::string& getFile() const noexcept {
            return mFile;
        }

        size_t getLine() const {
            return mLine;
        }

        spbla_Status getStatus() const noexcept {
            return nStatus;
        }

        bool isCritical() const noexcept {
            return mCritical;
        }

    private:
        mutable std::string mWhatCached;
        std::string mMessage;
        std::string mFunction;
        std::string mFile;
        size_t mLine;
        spbla_Status nStatus;
        bool mCritical;
        mutable bool mCached = false;
    };

    /**
     * Exceptions with spbla_Status error code parametrisation.
     * @tparam Type Exception error code (type)
     */
    template<spbla_Status Type>
    class TException: public Exception {
    public:
        TException(std::string message, std::string&& function, std::string&& file, size_t line, bool critical)
                : Exception(std::move(message), std::move(function), std::move(file), line, Type, critical)  {

        }

        TException(const TException& other) noexcept = default;
        TException(TException&& other) noexcept = default;
        ~TException() noexcept override = default;
    };

    // Errors exposed to the C API
    using Error = TException<spbla_Status::SPBLA_STATUS_ERROR>;
    using DeviceError = TException<spbla_Status::SPBLA_STATUS_DEVICE_ERROR>;
    using DeviceNotPresent = TException<spbla_Status::SPBLA_STATUS_DEVICE_NOT_PRESENT>;
    using MemOpFailed = TException<spbla_Status::SPBLA_STATUS_MEM_OP_FAILED>;
    using InvalidArgument = TException<spbla_Status::SPBLA_STATUS_INVALID_ARGUMENT>;
    using InvalidState = TException<spbla_Status::SPBLA_STATUS_INVALID_STATE>;
    using BackendError = TException<spbla_Status::SPBLA_STATUS_BACKEND_ERROR>;
    using NotImplemented = TException<spbla_Status::SPBLA_STATUS_NOT_IMPLEMENTED>;

}

// An error, in theory, can recover after this
#define RAISE_ERROR(type, message)                                                      \
    do {                                                                                \
        throw ::spbla::type(message, __FUNCTION__, __FILE__, __LINE__, false);         \
    } while (0);

#define CHECK_RAISE_ERROR(condition, type, message)                                     \
    if (!(condition)) { RAISE_ERROR(type, #condition ": " message); } else { }

// Critical errors, cause library shutdown
#define RAISE_CRITICAL_ERROR(type, message)                                             \
    do {                                                                                \
        throw ::spbla::type(message, __FUNCTION__, __FILE__, __LINE__, true);          \
    } while (0);

#define CHECK_RAISE_CRITICAL_ERROR(condition, type, message)                            \
    if (!(condition)) { RAISE_CRITICAL_ERROR(type, #condition ": " message); } else { }

#endif //SPBLA_ERROR_HPP
