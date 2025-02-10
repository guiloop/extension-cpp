# configure vcpkg
# have to set CMAKE_TOOLCHAIN_FILE before first project call.
macro (configure_vcpkg)
  if (DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
    message(STATUS "VCPKG_ROOT found, using vcpkg at $ENV{VCPKG_ROOT}")
  else()
    include(FetchContent)
    if (DEFINED ENV{DEPENDENCES_ROOT})
      set(VCPKG_SOURCE_DIR $ENV{DEPENDENCES_ROOT}/vcpkg-src)
    else()
      set(VCPKG_SOURCE_DIR ${FETCHCONTENT_BASE_DIR}/vcpkg-src)
    endif()

    if (USE_CXX11_ABI)
      FetchContent_Declare(vcpkg
        GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
        GIT_TAG "2024.02.14"
        SOURCE_DIR ${VCPKG_SOURCE_DIR}
      )
    else()
      FetchContent_Declare(vcpkg
        GIT_REPOSITORY "https://github.com/vectorch-ai/vcpkg.git"
        GIT_TAG "ffc42e97c866ce9692f5c441394832b86548422c" # disable cxx11_abi
        SOURCE_DIR ${VCPKG_SOURCE_DIR}
      )
      message(STATUS "Using custom vcpkg with cxx11_abi disabled")
    endif()
    FetchContent_MakeAvailable(vcpkg)

    message(STATUS "Downloading and using vcpkg at ${vcpkg_SOURCE_DIR}")
    set(CMAKE_TOOLCHAIN_FILE ${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake
        CACHE STRING "Vcpkg toolchain file")
  endif()
endmacro()
