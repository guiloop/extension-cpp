include(cc_library)
include(cc_test)

if(TARGET_DEVICE STREQUAL "cuda")
  cc_library(
    NAME 
      muladd_cuda
    HDRS
      muladd.cuh
    SRCS
      muladd.cu
    DEPS 
      torch
  )

  cc_test(
    NAME
      muladd_cuda_test
    SRCS
      muladd_test.cu
    DEPS
      :muladd_cuda
      torch
      GTest::gtest_main
  )
endif()
