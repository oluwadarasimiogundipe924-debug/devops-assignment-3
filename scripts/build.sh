#!/usr/bin/env bash

set -u

IMAGE="devops-tool"

echo "======================================"
echo " Assignment 3 - Docker Build"
echo "======================================"
echo

echo "Building Docker image..."

if ! docker build -t "$IMAGE" .; then
    echo "ERROR: Docker build failed."
    exit 1
fi

echo
echo "Running help smoke test..."

if ! docker run --rm "$IMAGE" help >/dev/null 2>&1; then
    echo "ERROR: Docker help test failed."
    exit 1
fi

echo "PASS: Docker help test"

echo
echo "Running system-info smoke test..."

if ! docker run --rm "$IMAGE" system-info >/dev/null 2>&1; then
    echo "ERROR: Docker system-info test failed."
    exit 1
fi

echo "PASS: Docker system-info test"

echo
echo "Running invalid-command smoke test..."

docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    echo "PASS: Invalid command returns exit code 2"
else
    echo "ERROR: Invalid command test failed."
    exit 1
fi

echo
echo "Docker build and smoke tests passed."
