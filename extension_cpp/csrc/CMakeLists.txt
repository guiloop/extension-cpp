include(pybind_extension)

# process cpu/CMakeLists.txt
add_subdirectory(cpu)

# process cuda/CMakeLists.txt
add_subdirectory(cuda)

pybind_extension(
  NAME
    _C
  COPTS
    -DPY_MODULE_NAME=_C
  SRCS
    module.cpp
  DEFINES 
    PYBIND11_DETAILED_ERROR_MESSAGES=1
  LINKDIRS
    ${TORCH_INSTALL_PREFIX}/lib
  DEPS
    :muladd
    torch
    torch_python
    Python::Module
)
