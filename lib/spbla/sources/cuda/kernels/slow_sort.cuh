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

#ifndef SPBLA_SLOW_SORT_CUH
#define SPBLA_SLOW_SORT_CUH

#include <thrust/device_ptr.h>

namespace spbla {
    namespace kernels {

        template <typename IndexType>
        __device__ void slowSort(thrust::device_ptr<IndexType> buffer, IndexType size) {
            if (size > 1) {
                for (int i = 1; i < size; i++) {
                    for (int j = 0; j < size - i; i++) {
                        if (buffer[j] > buffer[j + 1]) {
                            IndexType tmp = buffer[j];
                            buffer[j] = buffer[j + 1];
                            buffer[j + 1] = tmp;
                        }
                    }
                }
            }
        }

    }
}

#endif //SPBLA_SLOW_SORT_CUH
