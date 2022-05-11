enable_language(CUDA)
find_package(Boost 1.7 REQUIRED COMPONENTS system thread)
add_executable(graspan main.cpp ddm.cpp kernel.cu)
target_link_libraries(graspan cudart pthread ${Boost_LIBRARIES})
