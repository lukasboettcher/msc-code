cmake_minimum_required(VERSION 3.4.3)
project(MSC-CODE)

find_package(OpenMP REQUIRED)
find_package(LLVM REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})

set(llvm_libs LLVM)

include_directories(${CMAKE_SOURCE_DIR}/SVF/include ${LLVM_INCLUDE_DIRS})

find_library(Z3_LIBRARIES NAMES libz3.so)

add_subdirectory(SVF)
add_subdirectory(graspan)
add_subdirectory(ptagpu)
add_subdirectory(mmxcflr)
add_subdirectory(svf-experiments)
