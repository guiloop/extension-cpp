# Find Torch dependency.
macro (find_torch)
    include(${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake)
    run_python(TORCH_PREFIX_PATH
        "import torch; print(torch.utils.cmake_prefix_path)"
        "Failed to locate Torch path."
    )
    # Update cmake's `CMAKE_PREFIX_PATH` with torch location.
    list(APPEND CMAKE_PREFIX_PATH ${TORCH_PREFIX_PATH})
    #
    # Import torch cmake configuration.
    # Torch also imports CUDA (and partially HIP) languages with some customizations,
    # so there is no need to do this explicitly with check_language/enable_language,
    # etc.
    #
    find_package(Torch REQUIRED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")
endmacro()