enable_language(CUDA)
find_package(Boost REQUIRED COMPONENTS system thread)
add_executable(graspan main.cpp kernel.cu)
target_link_libraries(graspan pthread ${CUDA_LIBRARIES} ${Boost_LIBRARIES})
