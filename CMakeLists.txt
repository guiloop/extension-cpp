cmake_minimum_required(VERSION 3.26)

project(custom_ops LANGUAGES C CXX)

option(USE_CCACHE "Attempt using CCache to wrap the compilation" ON)
option(TARGET_DEVICE "CUDA by default, can be overridden by using -DTARGET_DEVICE=... (used by setup.py)" "cuda")

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

# use CCache to speeds up recompilation
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

# setup CMake module path, defines path for include() and find_package()
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Find Python dependency.
include(${CMAKE_CURRENT_LIST_DIR}/cmake/find_python.cmake)
find_python(${Python_EXECUTABLE} "${PYTHON_SUPPORTED_VERSIONS}")

# Find CUDDA denpendencies
if(TARGET_DEVICE STREQUAL "cuda")
  enable_language(CUDA)
  # find_package(NCCL REQUIRED)
endif()

# Find Torch dependency.
include(${CMAKE_CURRENT_LIST_DIR}/cmake/find_torch.cmake)
find_torch()

# target_link_libraries(custom_ops "${TORCH_LIBRARIES}")
# message(TORCH_LIBRARIES="${TORCH_LIBRARIES}")
# set_property(TARGET custom_ops PROPERTY CXX_STANDARD 17)

# enable CTest
include(CTest)
enable_testing()

add_executable(custom_ops main.cpp)

add_subdirectory(extension_cpp)
