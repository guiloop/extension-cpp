# Resolve torch
macro (resolve_torch)
    include(${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake)
    run_python(TORCH_PREFIX_PATH
        "import torch; print(torch.utils.cmake_prefix_path)"
    )
    if (DEFINED TORCH_PREFIX_PATH)
        # Update cmake's `CMAKE_PREFIX_PATH` with torch location.
        list(APPEND CMAKE_PREFIX_PATH ${TORCH_PREFIX_PATH})
        #
        # Import torch cmake configuration.
        # Torch also imports CUDA (and partially HIP) languages with some customizations,
        # so there is no need to do this explicitly with check_language/enable_language,
        # etc.
        #
        find_package(Torch REQUIRED)
        message(STATUS "Found cmake_prefix_path at ${TORCH_PREFIX_PATH}")
    else()
        include(FetchContent)
        set(LIBTORCH_VERSION "2.6.0")
        if (CUDAToolkit_VERSION VERSION_GREATER_EQUAL 12.4)
            # download libtorch with cuda 12.4 from pytorch.org
            if (USE_CXX11_ABI)
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu124/libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}%2Bcu124.zip")
            else()
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu124/libtorch-shared-with-deps-${LIBTORCH_VERSION}%2Bcu124.zip")
            endif()
        elseif(CUDAToolkit_VERSION VERSION_GREATER_EQUAL 12.1)
            # download libtorch with cuda 12.1 from pytorch.org
            if (USE_CXX11_ABI)
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu121/libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}%2Bcu121.zip")
            else()
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu121/libtorch-shared-with-deps-${LIBTORCH_VERSION}%2Bcu121.zip")
            endif()
        elseif(CUDAToolkit_VERSION VERSION_GREATER_EQUAL 11.8)
            # download libtorch ${LIBTORCH_VERSION} with cuda 11.8 from pytorch.org
            if (USE_CXX11_ABI)
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu118/libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}%2Bcu118.zip")
            else()
                set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu118/libtorch-shared-with-deps-${LIBTORCH_VERSION}%2Bcu118.zip")
            endif()
        else()
            # error out if cuda version is not supported
            message(FATAL_ERROR "Unsupported CUDA version: ${CUDAToolkit_VERSION}")
        endif()

        if (DEFINED ENV{DEPENDENCES_ROOT})
            set(LIBTORCH_SOURCE_DIR $ENV{DEPENDENCES_ROOT}/libtorch-src)
        else()
            set(LIBTORCH_SOURCE_DIR ${FETCHCONTENT_BASE_DIR}/libtorch-src)
        endif()

        FetchContent_Declare(libtorch 
            URL ${LIBTORCH_URL} 
            SOURCE_DIR ${LIBTORCH_SOURCE_DIR}
        )
        FetchContent_MakeAvailable(libtorch)

        find_package(Torch REQUIRED PATHS ${libtorch_SOURCE_DIR} NO_DEFAULT_PATH)
        message(STATUS "Using libtorch ${LIBTORCH_VERSION} for cuda ${CUDA_VERSION} at ${libtorch_SOURCE_DIR}")
    endif()

    message(STATUS "TORCH_CXX_FLAGS: ${TORCH_CXX_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")
    message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
endmacro()