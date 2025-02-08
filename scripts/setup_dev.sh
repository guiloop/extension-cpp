#!/bin/bash

# Install common dependencies
bash ./scripts/common/install_base.sh

# Install python3
apt-get update -q -y && apt-get install -q -y python3-dev

# Install gcc
export GCC_VERSION=12
apt-get update && apt-get install -y --no-install-recommends software-properties-common gpg-agent
bash ./scripts/common/install_gcc.sh
gcc --version
g++ --version

# Install cmake
export CMAKE_VERSION=3.29.3
if [ -n "${CMAKE_VERSION}" ]; then bash ./scripts/common/install_cmake.sh; fi
cmake --version

# Isntall ninja
export NINJA_VERSION=1.11.1
if [ -n "${NINJA_VERSION}" ]; then bash ./scripts/common/install_ninja.sh; fi
ninja --version

# Install ccache
export CCACHE_VERSION=4.8.3
if [ -n "${CCACHE_VERSION}" ]; then bash ./scripts/common/install_ccache.sh; fi
ccache --version

