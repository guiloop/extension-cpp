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

# Include current path
list(APPEND COMMON_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})
list(APPEND COMMON_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/extension_cpp)
list(APPEND COMMON_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/third_party)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake)

#
# Supported python versions.  These versions will be searched in order, the
# first match will be selected.  These should be kept in sync with setup.py.
#
set(PYTHON_SUPPORTED_VERSIONS "3.9" "3.10" "3.11" "3.12")

# Supported NVIDIA architectures.
set(CUDA_SUPPORTED_ARCHS "7.0;7.2;7.5;8.0;8.6;8.7;8.9;9.0")

# Use ccache to speeds up recompilation
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


# Include gflags
add_subdirectory(third_party/gflags)


# Resolve Python executable
file(REAL_PATH ${Python_EXECUTABLE} Python_EXECUTABLE)
find_package(Python COMPONENTS Interpreter Development.Module Development.SABIModule)
if (NOT Python_FOUND)
  message(FATAL_ERROR "Unable to find python matching: ${Python_EXECUTABLE}.")
endif()
set(_VER "${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}")
if (NOT _VER IN_LIST PYTHON_SUPPORTED_VERSIONS)
  message(FATAL_ERROR
    "Python version (${_VER}) is not one of the supported versions: "
    "${PYTHON_SUPPORTED_VERSIONS}.")
endif()
message(STATUS "Found python matching: ${EXECUTABLE}.")


# Resolve CUDA
if(TARGET_DEVICE STREQUAL "cuda")
  enable_language(CUDA)
  find_package(CUDAToolkit REQUIRED)
  # find_package(NCCL REQUIRED)
endif()


# Resolve Torch
run_python(TORCH_CMAKE_PREFIX_PATH
  "import torch; print(torch.utils.cmake_prefix_path)"
  ERR_MSG "Torch not installed. Please install torch."
  ERR_STS FALTAL_ERROR
)
message(STATUS "TORCH_CMAKE_PREFIX_PATH: ${TORCH_CMAKE_PREFIX_PATH}")
# Update cmake's `CMAKE_PREFIX_PATH` with torch location.
list(APPEND CMAKE_PREFIX_PATH ${TORCH_CMAKE_PREFIX_PATH})
#
# Import torch cmake configuration.
# Torch also imports CUDA (and partially HIP) languages with some customizations,
# so there is no need to do this explicitly with check_language/enable_language,
# etc.
#
find_package(Torch REQUIRED)
# find pytorch lib, to allow pybind to take at::Tensor as input/output
find_library(
  TORCH_PYTHON_LIBRARY torch_python PATHS "${TORCH_INSTALL_PREFIX}/lib"
)
message(STATUS "TORCH_CXX_FLAGS: ${TORCH_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")


# Resolve unit test
add_subdirectory(third_party/googletest)
include(GoogleTest)
include(CTest)
enable_testing()


add_executable(custom_ops main.cpp)

add_subdirectory(extension_cpp)
