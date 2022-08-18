find_package(OpenMP REQUIRED)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${LLVM_INCLUDE_DIRS})

add_executable(main src/main.cpp)
target_link_libraries(main mmxcflr Svf ${llvm_libs})

add_library(spbla SHARED IMPORTED)
set_target_properties(spbla PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/libspbla.so)
add_executable(spbla_main src/spbla.cpp)
target_link_libraries(spbla_main spbla OpenMP::OpenMP_CXX)

add_library(mmxcflr src/mmxcflr.cpp)
target_link_libraries(mmxcflr spbla OpenMP::OpenMP_CXX)