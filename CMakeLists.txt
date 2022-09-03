cmake_minimum_required(VERSION 3.4.3)
project(MSC-CODE)

find_package(LLVM REQUIRED CONFIG)

include_directories(${CMAKE_SOURCE_DIR}/SVF/include ${LLVM_INCLUDE_DIRS})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
find_library(Z3_LIBRARIES NAMES libz3.so)

enable_testing()

add_subdirectory(SVF)
add_subdirectory(graspan)
add_subdirectory(ptagpu)
add_subdirectory(mmxcflr)
add_subdirectory(svf-experiments)
