# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/tatsylab/mlenv-base:cuda12.6.3
FROM ${BASE_IMAGE}

ARG PYTHON_VERSION=3.11
ARG USER=user

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Keep Ubuntu's system Python intact. The image-wide Python environment lives
# under /opt/python and provides python, python3, pip, and uv on PATH.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        "python${PYTHON_VERSION}" \
        "python${PYTHON_VERSION}-dev" \
        "python${PYTHON_VERSION}-venv" && \
    "python${PYTHON_VERSION}" -m venv /opt/python && \
    /opt/python/bin/python -m pip install --no-cache-dir --upgrade \
        pip \
        setuptools \
        uv \
        wheel && \
    chown -R "${USER}:${USER}" /opt/python && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/python/bin:${PATH} \
    PIP_DISABLE_PIP_VERSION_CHECK=1

USER ${USER}
WORKDIR /workspace

CMD ["/usr/bin/zsh"]
