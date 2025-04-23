#!/bin/bash

set -e  # Exit on error

# Ensure aws CLI is available
which aws || { echo "aws CLI not found"; exit 1; }

# Copy requirements.txt from S3
aws s3 cp s3://builditall-client-data/scripts/requirements.txt /tmp/requirements.txt

# Verify file exists
if [ ! -f /tmp/requirements.txt ]; then
    echo "Failed to copy requirements.txt" >&2
    exit 1
fi

# Install dependencies as hadoop user
pip3 install --no-cache-dir -r /tmp/requirements.txt