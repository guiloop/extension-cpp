# Extension cpp

Download and unzip libtorch for MacOS CPU Intel 
```
wget https://download.pytorch.org/libtorch/nightly/cpu/libtorch-macos-x86_64-latest.zip
unzip libtorch-macos-x86_64-latest.zip
```

Create new a CMakeLists.txt file
```
cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(example-app)

find_package(Torch REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

add_executable(example-app example-app.cpp)
target_link_libraries(example-app "${TORCH_LIBRARIES}")
set_property(TARGET example-app PROPERTY CXX_STANDARD 17)

# The following code block is suggested to be used on Windows.
# According to https://github.com/pytorch/pytorch/issues/25457,
# the DLLs need to be copied to avoid memory errors.
if (MSVC)
  file(GLOB TORCH_DLLS "${TORCH_INSTALL_PREFIX}/lib/*.dll")
  add_custom_command(TARGET example-app
                     POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     ${TORCH_DLLS}
                     $<TARGET_FILE_DIR:example-app>)
endif (MSVC)

```

Build
```
mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH=/Users/cat/Downloads/libtorch/ ..
cmake --build . --config Release
```

Execute
```
./example-app
```