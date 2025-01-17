cmake_minimum_required(VERSION 3.5.0)
project(custion_ops VERSION 0.1.0 LANGUAGES C CXX)

# require C++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(custion_ops main.cpp)

include(CTest)
enable_testing()

# process test/CMakeLists.txt
# add_subdirectory(test)

# example library
add_library(sum_integers sum_integers.cpp)

# testing binary
add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test PRIVATE sum_integers)

# define tests
add_test(
  NAME cpp_test
  COMMAND $<TARGET_FILE:cpp_test>
)
