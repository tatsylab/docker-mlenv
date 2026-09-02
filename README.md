# Docker images for machine learning development

This repository provides a two-layer image design for Rootless Docker and VS
Code Dev Containers.

- `base/Dockerfile`: CUDA 12.6.3, cuDNN, native build tools, shells, and Node.js 24 LTS
- `python/Dockerfile`: Python 3.11 from deadsnakes, pip, setuptools, wheel, and uv
- Project-specific packages such as PyTorch belong in each project's
  `pyproject.toml` and `uv.lock`.

The images run as root inside the container. Under Rootless Docker, container
UID/GID 0 maps to the unprivileged host user running the Docker daemon rather
than to host root. This lets a Dev Container write to a bind-mounted project
while keeping the resulting files owned by the host user.

## Use as a Dev Container

The Python template at `templates/python/devcontainer.json` is intended to be
copied into each research project. It uses the published
`ghcr.io/tatsylab/mlenv-python:dev` image, enables all NVIDIA GPUs, provides
16 GB of shared memory, bind-mounts the project at `/workspace`, and uses fish
for the VS Code integrated terminal.

### Prerequisites

Before starting, connect to the GPU server with VS Code Remote - SSH and open
the project directory as the `student` user. The server must have the shared
Rootless Docker daemon and NVIDIA Container Toolkit configured. Install the
Dev Containers extension in VS Code if it is not already available.

### Add the template to a project

Run the following commands from the root of the research project on the GPU
server:

```shell
mkdir -p .devcontainer
curl -fsSL \
  https://raw.githubusercontent.com/tatsylab/docker-mlenv/main/templates/python/devcontainer.json \
  -o .devcontainer/devcontainer.json
```

If this repository has already been cloned, the file can instead be copied
locally:

```shell
mkdir -p .devcontainer
cp /path/to/docker-mlenv/templates/python/devcontainer.json \
  .devcontainer/devcontainer.json
```

Commit the copied `.devcontainer/devcontainer.json` to the research
repository so that future students use the same environment.

### Open the project in the container

1. Open the Command Palette in VS Code.
2. Run `Dev Containers: Reopen in Container`.
3. Wait while VS Code pulls the image and starts the container.
4. Open a new integrated terminal.

Verify the environment inside the container:

```shell
python --version
uv --version
nvidia-smi
```

For a project that already contains `pyproject.toml` and `uv.lock`, install
its dependencies with:

```shell
uv sync
```

Use `uv run <command>` to run commands in the project environment. The
template intentionally does not run `uv sync` automatically because some
projects require different initialization steps.

### Customize a project

Edit the copied `.devcontainer/devcontainer.json` in the research repository
when a project needs additional VS Code extensions or settings. Keep Python
and machine-learning dependencies in `pyproject.toml` and `uv.lock` rather
than adding them to this shared image.

The `dev` image tag follows the latest manually published development image.
A project can replace it with a `sha-<commit SHA>` tag when it needs to pin an
exact shared-image revision. After a new `dev` image is published, run
`Dev Containers: Rebuild Container Without Cache` to ensure that VS Code
pulls the updated image instead of reusing the local copy.

## Build and smoke test

Run the CPU-independent build and command checks with:

```shell
./scripts/smoke-test.sh
```

The script verifies the native toolchain, Node.js, shells, Python 3.11, uv, and
the common OpenGL runtime libraries. When the active Docker daemon is rootless,
it also verifies ownership of a file created through a bind mount. GPU runtime
checks such as `nvidia-smi` must be performed separately on a GPU server with
Rootless Docker and the NVIDIA Container Toolkit configured.
