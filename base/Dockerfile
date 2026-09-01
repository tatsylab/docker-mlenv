# syntax=docker/dockerfile:1

ARG CUDA_VERSION=12.6.3
FROM nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu22.04

ARG NODE_MAJOR=24
ARG USER=user
ARG USER_ID=1000
ARG GROUP_ID=1000

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
        libtool \
        libtool-bin \
        locales \
        ninja-build \
        pkg-config \
        rsync \
        sudo \
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

# Create the non-root development user. Administrative operations remain
# explicit through sudo, but do not require a container-specific password.
RUN groupadd --gid "${GROUP_ID}" "${USER}" && \
    useradd \
        --uid "${USER_ID}" \
        --gid "${GROUP_ID}" \
        --groups sudo \
        --create-home \
        --shell /usr/bin/zsh \
        "${USER}" && \
    echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 0440 "/etc/sudoers.d/${USER}" && \
    mkdir -p "/home/${USER}/.config/fish" /workspace && \
    chown -R "${USER}:${USER}" "/home/${USER}" /workspace

COPY --chown=${USER}:${USER} config/zshrc /home/${USER}/.zshrc
COPY --chown=${USER}:${USER} config/fish/config.fish /home/${USER}/.config/fish/config.fish

ENV HOME=/home/${USER}

USER ${USER}
WORKDIR /workspace

CMD ["/usr/bin/zsh"]
