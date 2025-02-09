#!/bin/bash

set -ex

# Install VS Code (code-server)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# install VS Code extensions
RUN code-server --install-extension ms-vscode.cmake-tools \
                --install-extension ms-vscode.cpptools-extension-pack \
                --install-extension nvidia.nsight-vscode-edition \
                --install-extension ms-python.python