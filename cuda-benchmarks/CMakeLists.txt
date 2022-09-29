enable_language(CUDA)
add_executable(mgpu mgpu.cu)
target_link_libraries(mgpu ${CUDA_LIBRARIES})
set_target_properties(mgpu PROPERTIES CUDA_ARCHITECTURES "86")