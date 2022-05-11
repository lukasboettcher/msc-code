cmake_minimum_required(VERSION 3.4.3)
project(MSC-CODE)

find_package(LLVM REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})

set(llvm_libs LLVM)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${LLVM_INCLUDE_DIRS})

add_executable(main src/main.cpp)
target_link_libraries(main Svf ${llvm_libs})

add_subdirectory(lib)
add_subdirectory(tools)
add_subdirectory(graspan)
