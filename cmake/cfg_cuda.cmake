# Configure CUDDA
macro (configure_cuda)
    if(TARGET_DEVICE STREQUAL "cuda")
        enable_language(CUDA)
        find_package(CUDAToolkit REQUIRED)
        # find_package(NCCL REQUIRED)
    endif()
endmacro()