#!/bin/bash

# Install common dependencies
bash ./scripts/common/install_base.sh

# Install python3
apt-get update -q -y && apt-get install -q -y python3-dev
