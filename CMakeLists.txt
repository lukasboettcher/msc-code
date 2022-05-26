cmake_minimum_required(VERSION 3.4.3)
project(MSC-CODE)

find_package(OpenMP REQUIRED)
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

add_library(spbla SHARED IMPORTED)
set_target_properties(spbla PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/lib/libspbla.so)
add_executable(spbla_main src/spbla.cpp)
target_link_libraries(spbla_main spbla OpenMP::OpenMP_CXX)

# add_executable(inline src/inlining.cpp)
# target_link_libraries(inline ${llvm_libs})
add_library(inline MODULE src/inlining.cpp)