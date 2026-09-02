# syntax=docker/dockerfile:1

ARG CUDA_VERSION=12.6.3
FROM nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu22.04

ARG NODE_MAJOR=24

ENV TZ=Asia/Tokyo \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        automake \
        bash \
        build-essential \
        ca-certificates \
        curl \
        fish \
        gettext \
        git \
        gnupg \
        libgl1 \
        libglib2.0-0 \
        libtool \
        libtool-bin \
        locales \
        ninja-build \
        pkg-config \
        rsync \
        tzdata \
        unzip \
        wget \
        zsh && \
    locale-gen en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

# Install CMake from Kitware and Node.js 24 LTS from NodeSource.
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://apt.kitware.com/keys/kitware-archive-latest.asc \
        | gpg --dearmor -o /etc/apt/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
        > /etc/apt/sources.list.d/kitware.list && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cmake \
        nodejs && \
    rm -rf /var/lib/apt/lists/*

# In Rootless Docker, container UID 0 maps to the unprivileged host user that
# runs the daemon. Using root here keeps bind-mounted files owned by that host
# user without granting host root privileges.
RUN usermod --shell /usr/bin/zsh root && \
    mkdir -p /root/.config/fish /workspace

COPY config/zshrc /root/.zshrc
COPY config/fish/config.fish /root/.config/fish/config.fish

ENV HOME=/root

USER root
WORKDIR /workspace

CMD ["/usr/bin/zsh"]
