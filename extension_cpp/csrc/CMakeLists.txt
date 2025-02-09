include(cc_library)
include(cc_test)

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
