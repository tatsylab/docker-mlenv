FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04 AS builder

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=user
ENV HOME=/root
ENV TERM=xterm-256color
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        build-essential \
        libtool \
        libtool-bin \
        automake \
        pkg-config \
        unzip \
        ninja-build \
        gettext && \
    rm -rf /var/lib/apt/lists/*

# Install CMake (latest)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
        | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
        > /etc/apt/sources.list.d/kitware.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends cmake && \
    rm -rf /var/lib/apt/lists/*

# Build NeoVim
RUN git clone --branch stable --depth 1 https://github.com/neovim/neovim $HOME/neovim
RUN cd $HOME/neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04 AS runtime

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=user
ENV HOME=/root
ENV TERM=xterm-256color
SHELL ["/bin/bash", "-c"]

# Timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install some packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        zsh \
        git \
        npm \
        sudo \
        fish \
        curl \
        wget \
        unzip \
        peco \
        rsync \
        nodejs \
        locales \
        gettext \
        luarocks \
        pkg-config \
        build-essential \
        ca-certificates \
        automake \
        ninja-build \
        libtool \
        openssh-server \
        apt-transport-https \
        software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Setup OpenSSH
RUN sed -ri 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -ri 's/(^\s+SendEnv.+)/#\1/' /etc/ssh/ssh_config
RUN mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh

# Setup for SSH
RUN mkdir -p /run/sshd && \
    mkdir -p /var/run/sshd
EXPOSE 22

# Setup Python
RUN apt-add-repository -y ppa:deadsnakes/ppa && \
    apt-get update -y && \
    apt-get install -y \
        python3.9-dev \
        python3.10-dev \
        python3.11-dev \
        python3.12-dev \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install -U pip setuptools wheel poetry uv

# Install CMake (latest)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
        | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
        > /etc/apt/sources.list.d/kitware.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends cmake && \
    rm -rf /var/lib/apt/lists/*

# Install NeoVim
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/nvim

# Install Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg \
    /etc/apt/keyrings/packages.microsoft.gpg
RUN echo "deb [arch=amd64,amd64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    tee /etc/apt/sources.list.d/vscode.list > /dev/null
RUN rm -f packages.microsoft.gpg
RUN apt-get update -y && \
    apt-get install -y code && \
    rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV TZ=Asia/Tokyo
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a user
RUN groupadd -g $GROUP_ID $USERNAME && \
    useradd -ms /usr/bin/zsh -g $GROUP_ID -u $USER_ID $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

    ENV HOME=/home/$USERNAME
USER $USERNAME
SHELL ["/usr/bin/zsh", "-c"]

# Install Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . "$HOME/.cargo/env"

# Copy dotfiles
RUN git clone --depth 1 https://github.com/tatsy/dotfiles $HOME/dotfiles && \
    rsync -avzP $HOME/dotfiles/.zshrc $HOME/.zshrc && \
    rsync -avzP $HOME/dotfiles/.config/ $HOME/.config/ && \
    rsync -avzP $HOME/dotfiles/.vimrc $HOME/.vimrc
RUN mkdir -p $HOME/.config/nvim && \
    rsync -avzP $HOME/dotfiles/.config/nvim/ $HOME/.config/nvim/
RUN mkdir -p $HOME/.config/fish && \
    rsync -avzP $HOME/dotfiles/.config/fish/ $HOME/.config/fish/

# Sheldon
RUN echo 'export PATH=$HOME/.cargo/bin:$PATH' >> $HOME/.zshrc
RUN cargo install sheldon starship --locked
RUN starship preset pastel-powerline -o ~/.config/starship.toml

# Command
WORKDIR $HOME/dev
SHELL ["/usr/bin/zsh", "-c"]
CMD ["/usr/bin/zsh"]
