cmake_minimum_required(VERSION 3.26)

project(custom_ops LANGUAGES C CXX)

option(USE_CCACHE "Attempt using CCache to wrap the compilation" ON)
option(USE_CXX11_ABI "Use the new C++-11 ABI, which is not backwards compatible." ON)
option(TARGET_DEVICE "CUDA by default, can be overridden by using -DTARGET_DEVICE=... (used by setup.py)" "cuda")

# Convert the bool variable to integer.
if(USE_CXX11_ABI)
  set(USE_CXX11_ABI 1)
  message(STATUS "Using the C++-11 ABI.")
else()
  set(USE_CXX11_ABI 0)
  message(STATUS "Using the pre C++-11 ABI.")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_MESSAGE_LOG_LEVEL STATUS)
set(CMAKE_VERBOSE_MAKEFILE ON)

#
# Supported python versions.  These versions will be searched in order, the
# first match will be selected.  These should be kept in sync with setup.py.
#
set(PYTHON_SUPPORTED_VERSIONS "3.9" "3.10" "3.11" "3.12")

# Supported NVIDIA architectures.
set(CUDA_SUPPORTED_ARCHS "7.0;7.2;7.5;8.0;8.6;8.7;8.9;9.0")

# use ccache to speeds up recompilation
if(USE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE STRING "C compiler launcher")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE STRING "CXX compiler launcher")
    set(CMAKE_CUDA_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE STRING "CUDA compiler launcher")
    message(STATUS "Using ccache: ${CCACHE_PROGRAM}")
    if (DEFINED ENV{CCACHE_DIR})
      message(STATUS "Using CCACHE_DIR: $ENV{CCACHE_DIR}")
    endif()
  else()
    message(WARNING "Could not find ccache. Consider installing ccache to speed up compilation.")
  endif()
endif()

# Setup cmake module path, defines path for include() and find_package()
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Configure vcpkg
# include(${CMAKE_CURRENT_LIST_DIR}/cmake/cfg_vcpkg.cmake)
# configure_vcpkg()

# find_package(Boost REQUIRED)
find_package(Threads REQUIRED)
# find all dependencies from vcpkg
find_package(fmt CONFIG REQUIRED GLOBAL)
# find_package(glog CONFIG REQUIRED)
# find_package(gflags CONFIG REQUIRED)
# find_package(absl CONFIG REQUIRED)
# find_package(Protobuf CONFIG REQUIRED)
# find_package(gRPC CONFIG REQUIRED)
# find_package(re2 CONFIG REQUIRED)
# find_package(folly CONFIG REQUIRED)
# find_package(GTest CONFIG REQUIRED)
# find_package(benchmark CONFIG REQUIRED)
# find_package(nlohmann_json CONFIG REQUIRED)
# find_package(prometheus-cpp CONFIG REQUIRED)
# find_package(RapidJSON CONFIG REQUIRED)

# Configure python
include(${CMAKE_CURRENT_LIST_DIR}/cmake/cfg_python.cmake)
configure_python(${Python_EXECUTABLE} "${PYTHON_SUPPORTED_VERSIONS}")

# Configure CUDDA
include(${CMAKE_CURRENT_LIST_DIR}/cmake/cfg_cuda.cmake)
configure_cuda()

# Configure torch
include(${CMAKE_CURRENT_LIST_DIR}/cmake/cfg_torch.cmake)
configure_torch()

# Configure test
include(${CMAKE_CURRENT_LIST_DIR}/cmake/cfg_test.cmake)
configure_test()

add_executable(custom_ops main.cpp)

add_subdirectory(extension_cpp)
