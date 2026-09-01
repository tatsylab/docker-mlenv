# Docker images for machine learning development

This repository is being migrated to a two-layer image design for Rootless
Docker and VS Code Dev Containers.

- `base/Dockerfile`: CUDA 12.6.3, cuDNN, native build tools, shells, and Node.js 24 LTS
- `python/Dockerfile`: Python 3.11 from deadsnakes, pip, setuptools, wheel, and uv
- Project-specific packages such as PyTorch belong in each project's
  `pyproject.toml` and `uv.lock`.

The images run as root inside the container. Under Rootless Docker, container
UID/GID 0 maps to the unprivileged host user running the Docker daemon rather
than to host root. This lets a Dev Container write to a bind-mounted project
while keeping the resulting files owned by the host user.

## Build and smoke test

Run the CPU-independent build and command checks with:

```shell
./scripts/smoke-test.sh
```

The script verifies the native toolchain, Node.js, shells, Python 3.11, and uv.
When the active Docker daemon is rootless, it also verifies ownership of a
file created through a bind mount. GPU runtime checks such as `nvidia-smi`
must be performed separately on a GPU server with Rootless Docker and the
NVIDIA Container Toolkit configured.

## Legacy environment

The original root-level `Dockerfile` and `docker-compose.yml` are retained
temporarily for comparison until the split images have been validated. They
describe the previous per-user Compose and container-SSH workflow and should
not be used as the basis for new project Dev Containers.
