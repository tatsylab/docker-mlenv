#!/usr/bin/env bash

set -euo pipefail

base_tag="${BASE_TAG:-mlenv-base:test}"
python_tag="${PYTHON_TAG:-mlenv-python:test}"

docker build \
    --file base/Dockerfile \
    --tag "${base_tag}" \
    .

docker run --rm "${base_tag}" bash -lc '
    test "$(id -un)" = user
    test "$(id -u)" -ne 0
    sudo -n true
    nvcc --version
    cmake --version
    ninja --version
    node --version
    npm --version
    zsh --version
    fish --version
'

docker build \
    --file python/Dockerfile \
    --build-arg "BASE_IMAGE=${base_tag}" \
    --tag "${python_tag}" \
    .

docker run --rm "${python_tag}" bash -lc '
    test "$(id -un)" = user
    test "$(id -u)" -ne 0
    sudo -n true
    python --version
    python3 --version
    pip --version
    uv --version
    test "$(python -c "import sys; print(f\"{sys.version_info.major}.{sys.version_info.minor}\")")" = 3.11
'
