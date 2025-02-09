include(cc_library)
include(cc_test)
include(pybind_extension)

cc_library(
  NAME 
    muladd
  HDRS
    muladd.h
  SRCS
    muladd.cpp
  DEPS
    torch
)

cc_test(
  NAME
    muladd_test
  SRCS
    muladd_test.cpp
  DEPS
    :muladd
    torch
    GTest::gtest_main
)

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
    torch
    torch_python
    Python::Module
)

