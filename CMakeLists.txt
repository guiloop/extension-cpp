cmake_minimum_required(VERSION 3.26)

project(custom_ops)

option(USE_NINJA "Ninja" ON)
option(USE_CCACHE "Attempt using CCache to wrap the compilation" ON)

# require C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_MESSAGE_LOG_LEVEL STATUS)
set(CMAKE_VERBOSE_MAKEFILE ON)

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

# Update cmake's `CMAKE_PREFIX_PATH` with torch location.
include(${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake)

# Add Torch dependency.
run_python(TORCH_PREFIX_PATH
    "import torch; print(torch.utils.cmake_prefix_path)"
    "Failed to locate Torch path."
)
list(APPEND CMAKE_PREFIX_PATH ${TORCH_PREFIX_PATH})

find_package(Torch REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")


# target_link_libraries(custom_ops "${TORCH_LIBRARIES}")
# message(TORCH_LIBRARIES="${TORCH_LIBRARIES}")
# set_property(TARGET custom_ops PROPERTY CXX_STANDARD 17)

# enable CTest
include(CTest)
enable_testing()

add_executable(custom_ops main.cpp)

add_subdirectory(extension_cpp)
