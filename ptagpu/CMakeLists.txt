enable_language(CUDA)
add_executable(ptagpu ptagpu.cc)
target_link_libraries(graspan ${CUDA_LIBRARIES})
set_target_properties(graspan PROPERTIES CUDA_ARCHITECTURES "86")
