# Docker images for machine learning development

This repository is being migrated to a two-layer image design for Rootless
Docker and VS Code Dev Containers.

- `base/Dockerfile`: CUDA 12.6.3, cuDNN, native build tools, shells, and Node.js 24 LTS
- `python/Dockerfile`: Python 3.11 from deadsnakes, pip, setuptools, wheel, and uv
- Project-specific packages such as PyTorch belong in each project's
  `pyproject.toml` and `uv.lock`.

Both images use the non-root user `user` (UID/GID 1000 by default). The user
has passwordless `sudo` access so that administrative commands remain
explicit.

## Build and smoke test

Run the CPU-independent build and command checks with:

```shell
./scripts/smoke-test.sh
```

The script verifies the native toolchain, Node.js, shells, Python 3.11, uv,
and non-root/sudo behavior. GPU runtime checks such as `nvidia-smi` must be
performed separately on a GPU server with Rootless Docker and the NVIDIA
Container Toolkit configured.

## Legacy environment

The original root-level `Dockerfile` and `docker-compose.yml` are retained
temporarily for comparison until the split images have been validated. They
describe the previous per-user Compose and container-SSH workflow and should
not be used as the basis for new project Dev Containers.
