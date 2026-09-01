#!/usr/bin/env bash

set -euo pipefail

base_tag="${BASE_TAG:-mlenv-base:test}"
python_tag="${PYTHON_TAG:-mlenv-python:test}"

docker build \
    --file base/Dockerfile \
    --tag "${base_tag}" \
    .

docker run --rm "${base_tag}" bash -lc '
    test "$(id -un)" = root
    test "$(id -u)" -eq 0
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
    test "$(id -un)" = root
    test "$(id -u)" -eq 0
    python --version
    python3 --version
    pip --version
    uv --version
    test "$(python -c "import sys; print(f\"{sys.version_info.major}.{sys.version_info.minor}\")")" = 3.11
'

# Rootless Docker maps container UID/GID 0 to the host user running the daemon.
# Verify that files created through a bind mount retain that host ownership.
if docker info --format '{{json .SecurityOptions}}' | grep -q rootless; then
    bind_test_dir="$(mktemp -d)"
    bind_test_file="${bind_test_dir}/created-in-container"

    cleanup_bind_test() {
        rm -f -- "${bind_test_file}"
        rmdir -- "${bind_test_dir}" 2>/dev/null || true
    }
    trap cleanup_bind_test EXIT

    docker run --rm \
        --mount "type=bind,src=${bind_test_dir},dst=/host-test" \
        "${base_tag}" \
        touch /host-test/created-in-container

    test "$(stat -c %u "${bind_test_file}")" -eq "$(id -u)"
    test "$(stat -c %g "${bind_test_file}")" -eq "$(id -g)"

    cleanup_bind_test
    trap - EXIT
fi
