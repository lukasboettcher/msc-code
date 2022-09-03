enable_language(CUDA)
add_executable(runptagpu ptagpu.cc)
target_link_libraries(runptagpu ptagpu Svf ${llvm_libs})

add_library(ptagpu ${CMAKE_CURRENT_SOURCE_DIR}/common.cu)
target_link_libraries(ptagpu ${CUDA_LIBRARIES})
set_target_properties(ptagpu PROPERTIES CUDA_ARCHITECTURES "86")
target_compile_options(ptagpu PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:
    --generate-line-info
    # --device-debug
    --use_fast_math
    >)

file(GLOB filesc "${CMAKE_SOURCE_DIR}/Test-Suite/test_cases_bc/basic_c_tests/*.bc")

foreach(filename ${filesc})
    add_test(
        NAME ptagpu-ctest/${filename}
        COMMAND "runptagpu" ${filename}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endforeach()

file(GLOB filescpp "${CMAKE_SOURCE_DIR}/Test-Suite/test_cases_bc/basic_cpp_tests/*.bc")

foreach(filename ${filescpp})
    add_test(
        NAME ptagpu-cpptest/${filename}
        COMMAND "runptagpu" ${filename}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endforeach()