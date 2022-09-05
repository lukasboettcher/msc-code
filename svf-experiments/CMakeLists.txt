# cmake_minimum_required(VERSION 3.4.3)
# project(MSC-CODE)

# find_package(OpenMP REQUIRED)
# find_package(LLVM REQUIRED CONFIG)
# list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
# include(AddLLVM)

# add_definitions(${LLVM_DEFINITIONS})

# set(llvm_libs LLVM)

# include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${LLVM_INCLUDE_DIRS} SVF/include)

add_library(inline MODULE src/inlining.cpp)

add_executable(leak src/leaktest.cpp)
target_link_libraries(leak Svf ${llvm_libs})

add_executable(dump src/dump-andersen.cpp)
target_link_libraries(dump Svf ${llvm_libs})

add_executable(dump-preanalysis src/dump-pag.cpp)
target_link_libraries(dump-preanalysis Svf ${llvm_libs})