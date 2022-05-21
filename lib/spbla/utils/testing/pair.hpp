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

#ifndef SPBLA_TESTING_PAIR_HPP
#define SPBLA_TESTING_PAIR_HPP

#include <spbla/spbla.h>
#include <unordered_set>

namespace testing {

    struct Pair {
        spbla_Index i;
        spbla_Index j;
    };

    struct PairHash {
    public:
        std::size_t operator()(const Pair &x) const {
            return std::hash<size_t>()(x.i) ^ std::hash<size_t>()(x.j);
        }
    };

    struct PairCmp {
    public:
        bool operator()(const Pair &a, const Pair& b) const {
            return a.i < b.i || (a.i == b.i && a.j < b.j);
        }
    };

    struct PairEq {
    public:
        bool operator()(const Pair &a, const Pair& b)  const {
            return a.i == b.i && a.j == b.j;
        }
    };

    bool operator ==(const Pair& a, const Pair& b) {
        PairEq pairEq;
        return pairEq(a, b);
    }

}

#endif //SPBLA_TESTING_PAIR_HPP
