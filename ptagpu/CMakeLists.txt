enable_language(CUDA)
add_executable(runptagpu ptagpu.cc)
target_link_libraries(runptagpu ptagpu Svf ${llvm_libs})

add_library(gephandle ${CMAKE_CURRENT_SOURCE_DIR}/gephandle.cc)
target_link_libraries(gephandle Svf ${llvm_libs})

add_library(ptagpu ${CMAKE_CURRENT_SOURCE_DIR}/common.cu)
target_link_libraries(ptagpu ${CUDA_LIBRARIES} gephandle)
set_target_properties(ptagpu PROPERTIES CUDA_ARCHITECTURES "86")