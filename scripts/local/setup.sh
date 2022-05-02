#!/bin/bash

# Make the virtual environment
python -m venv env

# Activate it
source env/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install the required packages
python -m pip install -r scripts/local/requirements.txt

# Cleanup
deactivate
rm -rf mv MiniZincIDE-2.6.2-bundle-linux-x86_64 MiniZincIDE-2.6.2-bundle-linux-x86_64.tgz