enable_language(CUDA)
find_package(OpenMP REQUIRED)

add_executable(mgpu mgpu.cu)
target_link_libraries(mgpu ${CUDA_LIBRARIES})
set_target_properties(mgpu PROPERTIES CUDA_ARCHITECTURES "86")

add_executable(parallel-test parallel-access.cu)
target_link_libraries(parallel-test OpenMP::OpenMP_CXX)
set_target_properties(parallel-test PROPERTIES CUDA_ARCHITECTURES "86")
target_compile_options(parallel-test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:
    -std=c++17
    --generate-line-info
    --use_fast_math
    --default-stream per-thread
    -O2
    -Xcompiler -fopenmp
    >)